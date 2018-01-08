#!/usr/bin/env hy
(import [sincro [config connection protocol]])

(defmain [&rest args]
  (setv conf (config.load (rest args))
        file (or (get conf "file") "「トレイン to トレイン」 AKA Trainroll 10 hours"))
  (with [conn (connection.Syncplay "syncplay.pl" 8995)]
    (.send conn (protocol.hello conf))
    (.receive conn)
    (.send conn (protocol.set "file" file))
    (.receive conn)))
