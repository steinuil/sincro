;; And today's award for the most stupid naming of things
;; goes to getpass, which for some reason is the only module
;; that provides a function to get the username.
;; Stay classy, Python.
(import getpass)

(setv options
  { "name" (getpass.getuser)
    "room" "default-room"
    "server" "syncplay.pl"
    "port" 8995
    "server-password" None
    "player-path" "mpv"
    "player-args" [] })


(setv config-path "conf.yaml")
