(import sincro)


(defn fetch [section name]
  (get messages section name))


;; IMPORTANT: Messages with format arguments should always use named placeholders,
;; so that they can be used as keyword arguments when formatting with the Logger.
(def messages
  { "argument"
    { "description" "Synchronize the playback of multiple players over the network"
      "epilog" "If no arguments are supplied, the default config values will be used"
      "server" "Server name or address"
      "port" "Server port"
      "server-password" "Server password"
      "name" "Desired username"
      "room" "Desired room"
      "config-path" "Override path to the config file"
      "debug" "Debug mode"
      "version" "Print version and quit"
      "file" "File to be played"
      "player-path" "Path to the player executable"
      "player-args" "Player arguments, prepend with '--' if the options start with '-'"
    }

    "mpv-connection"
    { "connect" "Connecting to {server}"
      "disconnect" "Disconnecting"
      "to" "to mpv"
      "from" "from mpv" }

    "syncplay-connection"
    { "connect" "Connecting to {server}"
      "disconnect" "Disconnecting"
      "to" "client"
      "from" "server" }

    "syncplay-handler"
    { "unknown-command" "Don't know how to handle command {command}"
    }

    "various"
      { "version" (.format "sincro v{}, based on syncplay v{}" sincro.version sincro.syncplay-mimic-version) }
  })
