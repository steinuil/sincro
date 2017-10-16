;; Decodes and encodes messages based on the protocol.
(import sincro
        [sincro.util [*]])
(require [sincro.util [*]])


;;;
;;; Client -> Server communication
;;;

;; First message expected by the server.
;; Logs into the server if necessary.
(defn hello [config]
  (def opts {
    "username" (get config "name")
    "room" { "name" (get config "room") }
    "realversion" sincro.syncplay-version })
  (def password (get config "password"))
  (when password (assoc opts "password" password))

  { "Hello" opts })

;; Communicate a change of settings to the server.
;; Takes either one or two arguments, depending on the option.
(defn set [type &rest options]
  (def settings
    (case type
        ;; Sends the current file
        ;; Takes: str
      { "file"
        { "file" (first options) }

        ;; Changes room
        ;; Takes: str
        ;; Or:    str str
        "room"
        (do
          (def room { "room" (first options) })
          (rescue
            (merge room { "password" (get options 1) }) ; TODO hash to md5
            room))

        ;; Set room password?
        ;; Takes: str str
        "room-password"
        { "controllerAuth"
          { "room" (first options)
            "password" (rescue (get options 1) "") } }

        ;; Set status as ready
        ;; Takes: bool
        "ready"
        { "ready"
          { "isReady" (first options)
            "manuallyInitiated"
            (rescue (get options 1) True) } } ; No clue what this is

        ;; Send list of files to be used as playlist
        ;; Takes: [str]
        "playlist"
        { "playlistChange"
          { "files" (first options) } }

        ;; Skip to playlist index (0-based?)
        ;; Takes: int
        "playlist-index"
        { "playlistIndex"
          { "index" (first options) } } }))

  { "Set" settings })

;; Communicate a change of state to the server.
;; TODO investigate and document this
(defn state []
  (def settings
    { "ignoringOnTheFly"
      { "server" 1
        "client" 1 }

      "playstate"
      { "position" 0
        "paused" True
        "doSeek" True } ; wut

      "ping"
      { "latencyCalculation" 0
        "clientRtt" 0
        "clientLatencyCalculation" 0 }})

  { "State" settings })

;; Request user list.
(defn users []
  { "List" None })

;; Communicate error.
(defn error [message]
  { "Error" { "message" message } })


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
      "motd" 'str }

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
    "Error" { "message" 'str } })
