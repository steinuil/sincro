(import getpass)

(def options {
  "name" (getpass.getuser)
  "room" "default-room"
  "server" "syncplay.pl"
  "port" 8995
  "password" None
  "player-path" "mpv"
  "player-args" []
  "debug" false })
