;; Decodes and encodes messages based on the protocol.
(import [sincro [logger]]
        sincro hashlib secrets time)
(require [sincro.util [*]])


;; First message expected by the server.
;; Logs into the server if necessary.
(defn hello [&kwonly name room [server-password None]]
  "The first message expected by the server"
  (setv opts { "username" name
               "room" { "name" room }
               "realversion" sincro.syncplay-mimic-version })
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


(defn get-users []
  "Request a list of users in your room with their status"
  { "List" None })


(defn send-error [message]
  "Communicate an error to the server"
  { "Error" { "message" message } })


(defn send-chat-message [msg]
  "Send msg to the room chat"
  { "Chat" msg })


;; This is really not necessary.
(defclass PingCalculator [object]
  "Keeps track of the last ping and of the
  exponentially weighted moving average (EWMA) of all the pings"
  [*warmup*    10   ; samples to collect before seeding the EWMA
   ;; The decay factor, or alpha, which determines how much sudden spikes
   ;; in the values affect the average.
   ;; A factor close to 0 is more sensible, close to 1 is more sturdy.
   *decay*     0.7
   samples     0     ; total number of samples
   average-rtt []
   last-rtt    None
   last-forward-delay None]

  (defm add [timestamp sender-rtt]
    (setv rtt (- (time.time) timestamp)
          self.last-rtt rtt)
    (incv self.samples)
    ;; Append the values to a list until we have enough samples,
    ;; then swap out the list with its average and start calculating the EWMA.
    (if (> self.samples self.*warmup*)
        (setv self.average-rtt (+ (* rtt self.*decay*)
                                  (* rtt (- 1 self.*decay*))))
      (do (.append self.average-rtt rtt)
        (when (= self.samples self.*warmup*)
          (setv self.average-rtt (/ (sum self.average-rtt) self.*warmup*)))))
    (setv self.last-forward-delay
          (if (< sender-rtt rtt)
            (+ (/ (self.average) 2)
               (- rtt sender-rtt))
            (/ (self.average) 2))))

  (defm average []
    "Return the average ping"
    (if (< self.samples self.*warmup*)
      ;; Return a simple average until we're warmed up
      (/ (sum self.average-rtt) (len self.average-rtt))
      self.average-rtt)))


;; Play along with the server's ignoringOnTheFly mechanism.
(setv *server-keep-alive* 0)


(def ping (PingCalculator))


(defn send-player-state
  [&kwonly [position 0] [paused False] [seeked False]]
  ""
  (setv state
    { "playstate" { "position" position
                    "paused" paused
                    "doSeek" seeked }
      ; There's also a key called "latencyCalculation", but it's never used.
      "ping" { "clientLatencyCalculation" (time.time)
               "clientRtt" ping.last-rtt } })
  (global *server-keep-alive*)
  (when (> *server-keep-alive* 0)
    (assoc state "ignoringOnTheFly" { "server" *server-keep-alive* })
    (setv *server-keep-alive* 0))
  { "State" state })


;; Response handler
(defn make-handler [&kwonly hello set list state error chat]
  "Takes handler functions for all possible server responses
  and returns a handler function that handles all responses"

  (defn handle-state [msg]
    ;; Handle ping and keep-alive stuff locally
    (setv server-ping (safe-get msg "ping")
          keepalive (safe-get msg "ignoringOnTheFly" "server"))
    (when server-ping
      (ping.add (get server-ping "latencyCalculation") (get server-ping "serverRtt")))
    (when keepalive
      (global *server-keep-alive*)
      (setv *server-keep-alive* keepalive))
    ;; Let the state handler do the rest
    (state msg))

  (setv log (logger.Logger "syncplay-handler")
        handlers { "Hello" hello
                   "Set" set
                   "List" list
                   "State" handle-state
                   "Error" error
                   "Chat" chat })
  (fn [msg]
    (for [(, cmd args) (.items msg)]
      (try ((get handlers cmd) args)
        (except [KeyError]
          (log.warning "unknown-command" :command cmd))))))
