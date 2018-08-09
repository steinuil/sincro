(require [sincro.util [*]])
(import sys
        os
        time
        subprocess
        socket
        json
        asyncio
        [xdg [BaseDirectory :as xdg-base-dir]]
        [sincro [config connection logger player protocol client]])


(defn/a server-conn [loop]
  (setv [reader writer] (await (asyncio.open_connection :host "syncplay.pl"
                                                          :port 8995
                                                          :family socket.AF_INET
                                                          :loop loop))
        handler (protocol.make-handler
                  :hello (fn [msg] (print (get msg "motd")))
                  :list (fn [msg] (for [room msg] (for [user (get room "users")] (print user))))
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
                           (setv resp (protocol.send-player-state))
                           (.write writer (.encode (+ (json.dumps resp) "\r\n"))))
                  :chat (constantly None)
                  :error (fn [msg] (print (+ "ERROR: " msg)) (quit 1))))

  (print "connected")

  (.write writer (.encode (+ (json.dumps (protocol.hello :name "steen" :room "badboys420")) "\r\n")))
  (await (.drain writer))
  (print "written")
  (while True
    (setv messages (->> (await (.read reader 4096))
                        (.decode)
                        (.strip)
                        (.splitlines)
                        (map json.loads)
                        (list)))
    (print messages)
    (for [msg messages]
      (handler msg))))


(defn/a mpv-conn [sock loop]
  (setv [reader writer] (await (asyncio.open_unix_connection :path (.encode sock)
                                                        :loop loop)))
  (print "connected to mpv")
  (while True
    (setv messages (->> (await (.read reader 4096))
                        (.decode)
                        (.strip)
                        (.splitlines)
                        (map json.loads)
                        (list)))
    (unless (empty? messages) (print "MPV:" messages))
    (for [msg messages]
      (when (= (safe-get msg "event") "end-file")
        (.stop loop)))
    ))



(defmain [&rest args]
  (setv event-loop (asyncio.get-event-loop)
        mpv-socket (os.path.join (xdg-base-dir.get-runtime-dir) "sincro_mpv_socket"))
  (.create-task event-loop (server-conn event-loop))
  (.create-task event-loop (mpv-conn mpv-socket event-loop))
  (with [(subprocess.Popen ["mpv" #*player.mpv-args #*[] (+ "--input-ipc-server=" mpv-socket)])]
    (time.sleep 2)
    (.run-forever event-loop)))
