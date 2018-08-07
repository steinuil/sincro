#!/usr/bin/env hy
(import sys
        [sincro [config connection logger protocol client]])
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
  ;(logger.set-level "debug")
  (setv conf (config.load (rest args))
        file (or (get conf "file") "Trainroll 10 hours.wmv"))
  (with [conn (connection.Syncplay (get conf "server") (get conf "port"))]
    (.send conn (protocol.hello :name (get conf "name") :room (get conf "room")
                                :server-password (get conf "server-password")))
    (handle (.receive conn))
    (.send conn (protocol.request-controlled-room "badboys421"))
    (handle (.receive conn))
    (.send conn (protocol.send-player-state :position None))
    (handle (.receive conn))
    (.send conn (protocol.get-users))
    (.send conn (protocol.send-player-state :position None))
    (handle (.receive conn))
    (.send conn (protocol.switch-to-room "badboys420"))
    (.send conn (protocol.send-player-state :position None))
    (handle (.receive conn))
    (.send conn (protocol.send-player-state :position None))
    (handle (.receive conn))
    (.send conn (protocol.send-player-state :position None))
    (handle (.receive conn))
  ))
