#!/usr/bin/env hy
(require [sincro.util [*]])
(import os
        time
        subprocess
        curio
        [xdg [BaseDirectory :as xdg-base-dir]]
        [sincro [config connection player protocol client]])


(defn handler-fn [state reply player-send]
  (protocol.make-handler
    :hello
    (fn/a [msg]
      (assoc state "name" (get msg "name"))
      (assoc state "room" (get msg "room"))
      (print "SERVER VERSION:" (get msg "version"))
      (print "MOTD:" (get msg "motd"))
      (await (reply (protocol.set-ready True)))
      (await (reply (protocol.get-users))))

    :state
    (fn/a [msg]
      (assoc state "position" (get msg "position"))
      (await (reply (protocol.send-player-state
                      :paused? (get state "paused?")
                      :position (get state "position")))))

    :list
    (fn/a [msg]
      (assoc state "users" msg))

    :chat
    (fn/a [msg]
      (print "CHAT:" (.format "<{}>" (get msg "user")) (get msg "message")))

    :error
    (fn/a [msg]
      (print "ERROR:" msg)
      (quit 1))

    :set (fn/a [msg] None)))
;    (protocol.make-set-handler
;           :room-change (constantly None)
;           :user-change (constantly None)
;           :features-change (constantly None)
;           :user-ready (constantly None)
;           :controller-identified (constantly None)
;           :new-controlled-room (constantly None)
;           :set-playlist (constantly None)
;           :set-playlist-index (constantly None))))


(defn/a server-loop [sv state pl-send]
  (with/a [sv]
    (await (.send sv (protocol.hello :name (get state "name") :room (get state "room"))))
    (setv handler (handler-fn state (fn/a [msg] (await (.send sv msg))) pl-send))
    (for [:async msg (.receive-iter sv)]
      (print "SERVER:" msg)
      (await (handler msg)))))


(defn/a player-loop [pl state sv-send]
  (with/a [pl]
    (await (.send pl (player.print "Welcome to sincro")))
    (for [:async msg (.receive-iter pl)]
      (print "PLAYER:" msg)
      (setv event (safe-get msg "event"))
      (when event
        (cond [(= event "end-file") (break)]
              [(= event "pause")
               (assoc state "paused?" True)
               (await (.send pl (player.get-position)))]
              [(= event "unpause")
               (assoc state "paused?" False)
               (await (.send pl (player.get-position)))]))
      (setv data (safe-get msg "data"))
      (when data
        (cond [(= (safe-get msg "request_id") player.*position-msg*)
               (assoc state "position" data)
               (await (sv-send (protocol.send-player-state
                                 :paused? False :position (get state "position"))))])))))


(defn/a main [pl-conn sv-conn state]
  (setv pl (await (curio.spawn player-loop pl-conn state (fn/a [msg] (await (.send sv-conn msg)))))
        sv (await (curio.spawn server-loop sv-conn state (fn/a [msg] (await (.send pl-conn msg))))))
  (await (.wait pl))
  (await (.cancel sv))
  None)


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
          "file" file
          "users" [] }

        player-conn (connection.Mpv mpv-socket)
        server-conn (connection.Syncplay (get conf "server") (get conf "port")))

  (when file
    (.append player-args file))

  (with [(subprocess.Popen player-args)]
    (time.sleep 1)

    (curio.run main player-conn server-conn state :with-monitor True)))
