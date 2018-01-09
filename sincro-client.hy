#!/usr/bin/env hy
(import [sincro [config connection protocol]])

(defmain [&rest args]
  (setv conf (config.load (rest args))
        file (or (get conf "file") "「トレイン to トレイン」 AKA Trainroll 10 hours"))
  (with [conn (connection.Syncplay "syncplay.pl" 8995)]
    ; use unpack operator on `conf` when a new version of hy is released
    (.send conn (protocol.hello :name (get conf "name") :room (get conf "room")
                                :server-password (get conf "server-password")))
    (.receive conn)
    (.send conn (protocol.request-controlled-room "badboys421"))
    (.receive conn)
    (.receive conn)
    (.receive conn)
    (.receive conn)
  ))
