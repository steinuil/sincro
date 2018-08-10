#!/usr/bin/env hy
(require [sincro.util [*]])
(import os
        time
        subprocess
        asyncio
        [xdg [BaseDirectory :as xdg-base-dir]]
        [sincro [config connection player protocol client]])


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


(defn/a queue-loop [queue send]
  (while True
    (setv msg (await (.get queue)))
    (print "QUEUE:" msg)
    (send msg)))


(defn/a server-loop [conn event-loop player-queue server-queue handler-fn]
  (with/a [server conn]
    (setv send-fn (fn [msg] (.send server msg))
          handler (handler-fn send-fn))
    (.create-task event-loop (queue-loop server-queue send-fn))

    (for [:async msg (.receive-iter server)]
      (print "SERVER:" msg)
      (handler msg))
    (.stop event-loop)))


(defn/a player-loop [conn event-loop player-queue server-queue]
  (with/a [pl conn]
    (setv send-fn (fn [msg] (.send pl msg)))
    (.create-task event-loop (queue-loop player-queue send-fn))

    (for [:async msg (.receive-iter pl)]
      (print "PLAYER:" msg)
      (when (= (safe-get msg "event") "end-file")
        (break)))
    (.stop event-loop)))


(defmain [&rest args]
  (setv conf (config.load (rest args))
        mpv-socket (os.path.join (xdg-base-dir.get-runtime-dir) "sincro_mpv_socket")
        event-loop (asyncio.get-event-loop))

  (setv player-conn (connection.Mpv mpv-socket event-loop)
        server-conn (connection.Syncplay (get conf "server") (get conf "port") event-loop)
        player-queue (asyncio.Queue :loop event-loop)
        server-queue (asyncio.Queue :loop event-loop))

  (.create-task event-loop (player-loop player-conn event-loop player-queue server-queue))
  (.create-task event-loop (server-loop server-conn event-loop player-queue server-queue handler))

  (.put-nowait server-queue (protocol.hello :name (get conf "name") :room (get conf "room")))

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
