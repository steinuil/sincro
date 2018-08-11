#!/usr/bin/env hy
(require [sincro.util [*]])
(import os
        time
        subprocess
        asyncio
        [xdg [BaseDirectory :as xdg-base-dir]]
        [sincro [config connection player protocol client]])


(defn handler-fn [state reply player-send]
  (protocol.make-handler
    :hello
    (fn [msg]
      (assoc state "name" (get msg "name"))
      (assoc state "room" (get msg "room"))
      (print "SERVER VERSION:" (get msg "version"))
      (print "MOTD:" (get msg "motd")))

    :state
    (fn [msg]
      (assoc state "position" (get msg "position"))
      (reply (protocol.send-player-state :paused? (get state "paused?")
                                         :position (get state "position"))))

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
    :chat (constantly None)
    :error (fn [msg] (print (+ "ERROR: " msg)) (quit 1))))


(defn/a server-loop [sv state event-loop pl-send]
  (with/a [sv]
    (.send sv (protocol.hello :name (get state "name") :room (get state "room")))
    (setv handler (handler-fn state (fn [msg] (.send sv msg)) pl-send))
    (for [:async msg (.receive-iter sv)]
      (print "SERVER:" msg)
      (handler msg)
      (await (.flush sv))))
  (.stop event-loop))


(setv *position-msg* 1)


(defn/a player-loop [pl state event-loop sv-send]
  (with/a [pl]
    (.send pl (player.print "Welcome to sincro"))
    (for [:async msg (.receive-iter pl)]
      (print "PLAYER:" msg)
      (setv event (safe-get msg "event"))
      (when event
        (cond [(= event "end-file") (break)]
              [(= event "pause")
               (assoc state "paused?" True)
               (.send pl (player.get-property "time-pos" :id *position-msg*))]
              [(= event "unpause")
               (assoc state "paused?" False)
               (.send pl (player.get-property "time-pos" :id *position-msg*))]))
      (setv data (safe-get msg "data"))
      (when data
        (cond [(= (safe-get msg "request_id") *position-msg*)
               (assoc state "position" data)
               (sv-send (protocol.send-player-state :paused? False
                                                    :position (get state "position")))]))
      (await (.flush pl))))
  (.stop event-loop))


(defmain [&rest args]
  (setv conf (config.load (rest args))
        mpv-socket (os.path.join (xdg-base-dir.get-runtime-dir) "sincro_mpv_socket")

        player-args [(get conf "player-path")
                     #*player.mpv-args
                     #*(get conf "player-args")
                     (+ "--input-ipc-server=" mpv-socket)]
        file (get conf "file")

        state
        { "paused?" True
          "name" (get conf "name")
          "room" (get conf "room")
          "position" 0
          "file" file }

        event-loop (asyncio.get-event-loop)
        player-conn (connection.Mpv mpv-socket event-loop)
        server-conn (connection.Syncplay (get conf "server") (get conf "port") event-loop))

  (.create-task event-loop (player-loop player-conn state event-loop (fn [msg] (.send server-conn msg))))
  (.create-task event-loop (server-loop server-conn state event-loop (fn [msg] (.send player-conn msg))))

  (when file
    (.append player-args file))

  (with [(subprocess.Popen player-args)]
    (time.sleep 1)

    (.run-forever event-loop)))
