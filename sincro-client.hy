#!/usr/bin/env hy
(import [sincro [config protocol]])

(defmain [&rest args]
  (let [conf (config.load (cdr args))]
    (with [conn (protocol.Connection "syncplay.pl" 8995 :debug True)]
      (.send conn (protocol.hello conf))
      (.receive conn))
    ))
