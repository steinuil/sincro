#!/usr/bin/env hy
(import [sincro [config connection protocol client]]
        sys)
(require [sincro.util [*]])


(defn handle [p]
  (for [msg p] (client.response-handler msg)))


;(defn handle-mpv-event [ev]
;  (setv name (get ev "event"))
;  (cond [(= ev "start-file")]))


(defn setup-mpv [conn]
  (.send conn { "command" [ "observe_property" "filename" ] }
              { "command" [ "observe_property" "duration" ] }
              { "command" [ "observe_property" "file-size" ] }))


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
  ))
