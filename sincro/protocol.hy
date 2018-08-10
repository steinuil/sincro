;; Decodes and encodes messages based on the protocol.
(require [sincro.util [*]])
(import [sincro [logger util ping]]
        sincro hashlib secrets time)


;; First message expected by the server.
;; Logs into the server if necessary.
(defn hello [&kwonly name room [server-password None]]
  "The first message expected by the server"
  (setv features { "chat" False
                   "sharedPlaylists" False
                   "featureList" True
                   "readiness" True
                   "managedRooms" True })
  (setv opts { "username" name
               "room" { "name" room }
               "version" "1.2.255"
               "realversion" sincro.syncplay-mimic-version
               "features" features })
  (when server-password
    (assoc opts "password" (.hexdigest (hashlib.md5 server-password))))
  { "Hello" opts })


(defn send-file [name &kwonly duration size [path None]]
  "Send the file you're currently playing"
  (setv file { "name" name
               "duration" duration
               "size" size })
  (when path
    (assoc file "path" path))
  { "Set" { "file" file } })


(defn switch-to-room [name]
  "Switch to the room `name`"
  ; There's also a possible password parameter, but it's never used
  { "Set" { "room" { "name" name } } })


;; Syncplay not using 'secrets' doesn't mean we're excused for not doing it.
(defn gen-room-password []
  "Generate a random room password in the format AA-000-000"
  (defn n [x] (secrets.randbelow (inc x)))
  (.format "{}-{:03d}-{:03d}"
    (.join "" (map (fn [_] (chr (+ 65 (n 25)))) (range 2)))
    (n 999) (n 999)))


;; Requesting a controlled room of name <name> will put you in a room
;; named +<name>:<hash> and give you back the password to invite other OPs.
(defn request-controlled-room [room]
  "Request a new controlled room"
  { "Set" { "controllerAuth" { "room" room "password" (gen-room-password) } } })


(defn manage-room [room password]
  "Log in as OP of a controlled room
  If 'room' is none log into the current room"
  { "Set" { "controllerAuth" { "room" room "password" password } } })


(defn set-ready [ready &optional [manual? True]]
  "Set your ready status"
  { "Set" { "ready" { "isReady" ready "manuallyInitiated" manual? } } })


(defn set-playlist [files]
  "Change the files in the playlist"
  { "Set" { "playlistChange" { "files" files } } })


(defn skip-to-playlist-index [index]
  "Skip to playlist index, 0-based"
  { "Set" { "playlistIndex" { "index" index } } })


(defn set-features [features]
  "Send a list of supported features"
  { "Set" { "features" features } })


(defn get-users []
  "Request a list of users in your room with their status"
  { "List" None })


(defn send-error [message]
  "Communicate an error to the server"
  { "Error" { "message" message } })


(defn send-chat-message [msg]
  "Send msg to the room chat"
  { "Chat" msg })


;; Play along with the server's ignoringOnTheFly mechanism.
(setv *server-keep-alive* 0)


(setv curr-ping (ping.Ping))


(defn send-player-state
  [&kwonly paused? [position None] [seeked? False]]
  ""
  (setv state
    { "playstate" { "position" position
                    "paused" paused?
                    "doSeek" seeked? }
      ; There's also a key called "latencyCalculation", but it's never used.
      "ping" { "clientLatencyCalculation" (time.time)
               "clientRtt" curr-ping.last-rtt } })
  (global *server-keep-alive*)
  (when (> *server-keep-alive* 0)
    (assoc state "ignoringOnTheFly" { "server" *server-keep-alive* })
    (setv *server-keep-alive* 0))
  { "State" state })


;; Response handler
(defn make-handler [&kwonly hello set list state error chat]
  "Takes handler functions for all possible server responses
  and returns a handler function that handles all responses"
  (setv log (logger.Logger "syncplay-handler")
        handlers { "Hello" (comp hello handle-hello)
                   "Set" set
                   "List" (comp list handle-list)
                   "State" (comp state handle-state)
                   "Error" (comp error handle-error)
                   "Chat" (comp chat handle-chat) })
  (fn [msg]
    (setv [cmd args] (util.dict-to-tuple msg))
    (try ((get handlers cmd) args)
      (except [KeyError]
        (log.warning "unknown-command" :command cmd)))))


(defn handle-hello [args]
  { "name" (get args "username")
    "room" (get args "room" "name")
    "version" (or (safe-get args "realversion") (safe-get args "version"))
    "motd" (ignore-exceptions (.strip (get args "motd")))
    "features" (or (safe-get args "features") {}) })


(defn handle-user-change [msg]
  (setv [user settings] (util.dict-to-tuple msg)
        event (safe-get settings "event")
        out { "user" user
              "room" (safe-get settings "room" "name")
              "file" (safe-get settings "file")
              "event" None
              "version" None
              "features" {} })
  (when event
    (cond [(in "joined" event)
           (assoc out "event" "joined")
           (assoc out "version" (get event "version"))
           (assoc out "features" (get event "features"))]
          [(in "left" event)
           (assoc out "event" "left")]))
  out)


(defn make-set-handler
  [&kwonly room-change user-change features-change user-ready
           controller-identified new-controlled-room
           set-playlist-index set-playlist]

  (setv set-handlers
    { "room" (comp room-change (fn [msg] (safe-get msg "name")))
      "user" (comp user-change handle-user-change)
      "features" (comp features-change (fn [msg] { "user" (get msg "username")
                                                   "features" (get msg "features") }))
      "ready" (comp user-ready (fn [msg] { "user" (get msg "username")
                                           "ready?" (get msg "isReady")
                                           "manual?" (safe-get msg "manuallyInitiated") }))
      "controllerAuth" controller-identified
      "newControlledRoom" (comp new-controlled-room (fn [msg] { "room" (get msg "roomName")
                                                                "password" (get msg "password") }))
      "playlistIndex" set-playlist-index
      "playlistChange" set-playlist })

  (fn [msg]
    (setv [cmd args] (util.dict-to-tuple msg))
    (try ((get set-handlers cmd) args)
      (except [KeyError]
        (log.warning "unknown-command" :command cmd)))))


(defn handle-state [msg]
  ;; We don't send client ignoringOnTheFly statuses, so we shouldn't receive
  ;; any either.
  (setv keep-alive (safe-get msg "ignoringOnTheFly" "server")
        play-state (safe-get msg "playstate")
        server-ping (safe-get msg "ping"))
  (when server-ping
    (curr-ping.add (get server-ping "latencyCalculation") (get server-ping "serverRtt")))
  (when keep-alive
    (global *server-keep-alive*)
    (setv *server-keep-alive* keep-alive))
  (when play-state
    { "position" (or (safe-get play-state "position") 0)
      "paused?" (safe-get play-state "paused")
      "seeked?" (safe-get play-state "doSeek")
      "set-by" (safe-get play-state "setBy") }))


(defn handle-list [msg]
  (lfor (, room users) (.items msg)
    { "room" room
      "users"
      (lfor (, user settings) (.items users)
        { "user" user
          "file" (or (safe-get settings "file") None)
          "controller?" (safe-get settings "controller")
          "ready?" (safe-get settings "isReady")
          "features" (or (safe-get settings "features") {}) }) }))


(defn handle-chat [msg]
  { "user" (get msg "username")
    "message" (get msg "message") })


(defn handle-error [msg]
  (get msg "message"))
