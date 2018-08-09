#!/usr/bin/env hy
(require [sincro.util [*]])
(import os
        time
        subprocess
        asyncio
        [xdg [BaseDirectory :as xdg-base-dir]]
        [sincro [config connection player protocol client]])


(defn/a player-conn [path loop]
  (with/a [conn (connection.Mpv path loop)]
    (for [:async msg (.receive conn)]
      (assert msg)
      (print "MPV:" msg)
      (when (= (safe-get msg "event") "end-file")
        (.stop loop)
        (break)))
    (.stop loop)))


(defn/a server-conn [host port loop name room h]
  (with/a [server (connection.Syncplay host port loop)]
    (setv handler (h (fn [msg] (.send server msg))))
    (.send server (protocol.hello :name name :room room))
    (await (.flush server))
    (for [:async msg (.receive server)]
      (print "SERVER:" msg)
      (handler msg))
    (.stop loop)))


(defn handler [reply]
  (protocol.make-handler
    :hello (constantly None)
    :list (constantly None)
    :set (protocol.make-set-handler
           :room-change (constantly None)
           :user-change (constantly None)
           :features-change (constantly None)
           :user-ready (constantly None)
           :controller-identified (constantly None)
           :new-controlled-room (constantly None)
           :set-playlist (constantly None)
           :set-playlist-index (constantly None))
    :state (fn [msg]
             (reply (protocol.send-player-state :paused? True)))
    :chat (constantly None)
    :error (fn [msg] (print (+ "ERROR: " msg)) (quit 1))))


(defmain [&rest args]
  (setv conf (config.load (rest args))
        mpv-socket (os.path.join (xdg-base-dir.get-runtime-dir) "sincro_mpv_socket")
        event-loop (asyncio.get-event-loop))

  (.create-task event-loop (player-conn mpv-socket event-loop))
  (.create-task event-loop (server-conn (get conf "server") (get conf "port") event-loop
                                        (get conf "name") (get conf "room") handler))

  (setv args [(get conf "player-path")
              #*player.mpv-args
              #*(get conf "player-args")
              (+ "--input-ipc-server=" mpv-socket)]
        file (get conf "file"))

  (when file
    (.append args file))

  (with [(subprocess.Popen args)]
    (time.sleep 1)

    (.run-forever event-loop)))
