#!/usr/bin/env hy
(import [sincro [config connection protocol]])
(require [sincro.util [*]])


(defn handle [p]
  (for [payload p]
    (when (in "State" payload)
      (setv ping (get payload "State" "ping"))
      (protocol.ping.add (get ping "latencyCalculation") (get ping "serverRtt"))

      (setv server-ignore (get-with-default payload None "State" "ignoringOnTheFly" "server"))
      (when server-ignore
        (setv protocol.*ignored-server-seeks* server-ignore)))))


(defmain [&rest args]
  (setv conf (config.load (rest args))
        file (or (get conf "file") "「トレイン to トレイン」 AKA Trainroll 10 hours"))
  (with [conn (connection.Syncplay "syncplay.pl" 8995)]
    ; use unpack operator on `conf` when a new version of hy is released
    (.send conn (protocol.hello :name (get conf "name") :room (get conf "room")
                                :server-password (get conf "server-password")))
    (handle (.receive conn))
    (.send conn (protocol.request-controlled-room "badboys421"))
    (handle (.receive conn))
    (.send conn (protocol.send-player-state :position None))
    (handle (.receive conn))
    (.send conn (protocol.send-player-state :position None))
    (handle (.receive conn))
    (.send conn (protocol.send-player-state :position None))
    (handle (.receive conn))
    (.send conn (protocol.send-player-state :position None))
    (handle (.receive conn))
    (.send conn (protocol.send-player-state :position None))
    (handle (.receive conn))
    (print (protocol.ping.average))
  ))
