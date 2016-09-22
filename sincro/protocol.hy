;; Decodes and encodes messages based on the protocol.
(import sincro)
(require sincro.util)

;; First message expected by the server.
;; Logs into the server if necessary.
(defn hello [config]
  (def opts {
    "username" (get config "name")
    "room" { "name" (get config "room") }
    "realversion" sincro.syncplay-version })

  (let [password (get config "password")]
    (when password (assoc opts "password" password)))

  { "Hello" opts })

;; Communicates a change of settings to the server.
;; Takes either one or two arguments, depending on the option.
(defn set [type &rest options]
  (def settings
    (case type
        ; Sends the current file
        ; Takes: str
      { "file"
        { "file" (first options) }

        ; Changes room
        ; Takes: str
        ; Or:    str str
        "room"
        { "room"
          (try-merge { "room" (first options) }
                     { "password" (get options 1) }) } ; should be md5 hash

        ; Set room password?
        ; Takes: str str
        "room-password"
        { "controllerAuth"
          { "room" (first options)
            "password" (last options) } }

        ; Set status as ready
        ; Takes: bool
        "ready"
        { "ready"
          { "isReady" (first options)
            "manuallyInitiated"
            (rescue (get options 1) True) } } ; No clue what this is

        ; Send list of files to be used as playlist
        ; Takes: [str]
        "playlist"
        { "playlistChange"
          { "files" (first options) } }

        ; Skip to playlist index (0-based?)
        ; Takes: int
        "playlist-index"
        { "playlistIndex"
          { "index" (first options) } } }))

  { "Set" settings })

;; Communicate error
(defn error [message]
  { "Error" { "message" message } })

;; Helper
(defn case [type dict] (get dict type))
