;; And today's award for the most stupid naming of things
;; goes to getpass, which for some reason is the only module
;; that provides a function to get the username.
;; Stay classy, Python.
(import getpass)

(def options
  { "name" (getpass.getuser)
    "room" "default-room"
    "server" "syncplay.pl"
    "port" 8995
    "password" None
    "player-path" "mpv"
    "player-args" []
    "debug" False })
