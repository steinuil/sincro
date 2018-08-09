#!/usr/bin/env hy
(require [sincro.util [*]])
(import sys
        os
        time
        subprocess
        [xdg [BaseDirectory :as xdg]]
        [sincro [config connection logger player protocol client]])


(defn handle [p]
  (for [msg p] (client.response-handler msg)))


;(defn handle-mpv-event [ev]
;  (setv name (get ev "event"))
;  (cond [(= ev "start-file")]))


(defn setup-mpv [conn]
  (.send conn { "command" [ "observe_property" "filename" ] }
              { "command" [ "observe_property" "duration" ] }
              { "command" [ "observe_property" "file-size" ] }))


(setv mpv-args
      ["--force-window"
       "--pause"
       "--idle"
       "--no-terminal"
       "--keep-open"])


(defmain [&rest args]
  ;(logger.set-level "debug")
  (setv conf (config.load (rest args))
        mpv-socket (os.path.join (xdg.get-runtime-dir) "sincro_mpv_socket"))

  (print mpv-socket)

  (with [(subprocess.Popen [(get conf "player-path")
                     #*mpv-args
                     #*(get conf "player-args")
                     (+ "--input-ipc-server=" mpv-socket)])]
  (time.sleep 1)

  (with [pconn (connection.Mpv mpv-socket)]
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

      (.send pconn (player.command "quit"))
  )))
  (print "ogre"))
