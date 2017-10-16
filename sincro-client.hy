#!/usr/bin/env hy
(import [sincro [config connection protocol]])

(defmain [&rest args]
  (def conf (config.load (rest args)))
  (with [conn (connection.Syncplay "syncplay.pl" 8995 :debug True)]
    (.send conn (protocol.hello conf))
    (.receive conn)
    (.send conn (protocol.set "file" "「トレイン to トレイン」 AKA Trainroll 10 hours"))
    (.receive conn)))
