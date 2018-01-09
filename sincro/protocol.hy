;; Decodes and encodes messages based on the protocol.
(import sincro hashlib random)
(require [sincro.util [*]])


;; First message expected by the server.
;; Logs into the server if necessary.
(defn hello [&kwonly name room [server-password None]]
  "The first message expected by the server"
  (setv opts { "username" name
               "room" { "name" room }
               "realversion" sincro.syncplay-mimic-version })
  (when server-password
    ; Top security
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


;; Security ahoy
(defn gen-room-password []
  "Generate a random room password in the format AA-000-000"
  (defn n [] (random.randrange 1000))
  (.format "{}-{:03d}-{:03d}"
    (.join "" (map chr (random.sample (range 65 90) 2)))
    (n) (n)))


;; Requesting a controlled room will return that room's name
;; in the format +<name>:<hash> where <hash> is the uppercased first 12
;; chars of a hash generated with the room name, the server salt and password.
(defn request-controlled-room [room]
  "Request a new controlled room"
  { "Set" { "controllerAuth" { "room" room "password" (gen-room-password) } } })


(defn manage-room [room password]
  "Log in as OP of a controlled room
  If 'room' is none log into the current room"
  { "Set" { "controllerAuth" { "room" room "password" p } } })


(defn set-ready [ready &optional [manual? True]]
  "Set your ready status"
  { "Set" { "ready" { "isReady" ready "manuallyInitiated" manual? } } })


(defn set-playlist [files]
  "Change the files in the playlist"
  { "Set" { "playlistChange" { "files" files } } })


(defn skip-to-playlist-index [index]
  "Skip to playlist index, 0-based"
  { "Set" { "playlistIndex" { "index" index } } })


(defn get-users []
  "Request a list of users in your room with their status"
  { "List" None })


(defn send-error [message]
  "Communicate an error to the server"
  { "Error" { "message" message } })


(defn send-chat-message [msg]
  "Send msg to the room chat"
  { "Chat" msg })


;; IgnoringOnTheFly seems to be some kind of locking mechanism,
;; where the server won't send any seeks until the client has ACKed
;; the previous by sending back to the server the current server IOTF status.
;; The same happens for the client: if the client sends a seek to the server,
;; it will increase its local IOTF status and not send any seeks until
;; the server has acknowledged it.
;;
;; It's kind of unnecessary, since the protocol is built on top of TCP
;; which should be ordered and reliable in the first place,
;; so we play along with the server and completely ignore the client part.
(setv *ignored-server-seeks* 0)


(defn send-player-state
  [&kwonly [position 0] [paused? False] [seeked? False] latency rtt]
  ""
  (setv state
    { "playstate" { "position" position
                    "paused" paused?
                    "doSeek" seeked? }
      ; There's also a key called "latencyCalculation", but it's never used.
      "ping" { "clientLatencyCalculation" latency
               "clientRtt" rtt } })
  (when (> *ignored-server-seeks* 0)
    (assoc state "ignoringOnTheFly" { "server" *ignored-server-seeks* }))
  { "State" state })


;;;
;;; Server -> Client communication
;;;

(def responses
    ;; Response to hello, echoes the sent options
  { "Hello"
      ;; We only care about the MOTD
    { "username" 'str
      "room" { "name" 'str }
      "realversion" 'str
      "motd" 'str
      "features" [ 'str ] }

    "Set"
      ;; Name of the room changed
    [ { "room" { "name" 'str } }

      ;; Status of user changed
      ;; TODO investigate the event thing
      { "user"
        { "name" 'str
          "room" { "name" 'str }
          "file" 'str?
          "event" '??? } }

      ;; Response to request of room password
      { "controllerAuth"
        { "success" 'bool
          "user" 'str
          "room" 'str } }

      ;; Another user set a room password
      { "newControlledRoom"
        { "password" 'str
          "roomName" 'str } }

      ;; Another user is ready
      { "ready"
        { "username" 'str
          "isReady" 'bool
          "manuallyInitiated" 'bool } }

      ;; Playlist index changed
      { "playlistIndex"
        { "index" 'int
          "user" 'str } }

      ;; Playlist files changed
      { "playlistChange"
        { "files" 'str
          "user" 'str } } ]

    ;; List of users
    "List" 'str

    ;; Server playing state
    "State"
    { "playstate"
      { "position" 'int
        "paused" 'bool
        "doSeek" '???
        "setBy" 'str|None }

      "ping"
      { "latencyCalculation" 'str?
        "serverRtt" '??? }

      "ignoringOnTheFly"
      { "server" 'int
        "client" 'int } }

    ;; Error message
    "Error" { "message" 'str }

    ;; Chat message
    "Chat" {}
    })
