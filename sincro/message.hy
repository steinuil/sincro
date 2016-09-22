(import sincro)

(defn fetch [type name]
  (get (get messages type) name))

(def messages
  { "argument"
    { "description" "Synchronize the playback of multiple players over the network"
      "epilog" "If no arguments are supplied, the default config values will be used"
      "server" "Server name or address"
      "port" "Server port"
      "password" "Room password"
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
    { "connect" "[mpv] Connecting to {}"
      "disconnect" "[mpv] Disconnecing"
      "to" "to mpv"
      "from" "from mpv" }

    "syncplay-connection"
    { "connect" "[client] Connecting to {}:{}"
      "disconnect" "[client] Disconnecting"
      "to" "client"
      "from" "server" }

    "various"
      { "version" (.format "sincro v{}, based on syncplay v{}" sincro.version sincro.syncplay-version) }
  })
