#!/usr/bin/env hy
(import [sincro [config logger connection protocol]]
        sys)
(require [sincro.util [*]])


(setv log (logger.Logger "syncplay-handler"))


(defn handle-hello [msg]
  (setv motd (safe-get msg "motd"))
  (if motd
    (print motd)
    (log.warning "property-not-found" :property "motd")))


(defn print-chat-msg [msg]
  (try (do (setv message (get msg "message")
                 name (get msg "username"))
           (print (.format "<{}> {}" message name)))
    (except [e KeyError]
      (log.warning "property-not-found" :property (get e.args 0)))))


(defn handle-list [msg]
  (setv users [])
  (for [rooms msg]
    (for [(, room user) (.items rooms)]
      (.append users (get user "username"))))
  (print users))


(defn quit-with-error [msg]
  (setv err (safe-get msg "message"))
  (log.error "server-error" :message err)
  (sys.exit 1))


(setv syncplay-resp-handler
  (protocol.make-handler
    :hello handle-hello
    :set   (fn [x] None)
    :state (fn [x] None)
    :list  handle-list
    :chat  print-chat-msg
    :error quit-with-error))


(defn handle [p]
  (for [msg p] (syncplay-resp-handler msg)))


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
    (print "Average ping:" (protocol.ping.average))
  ))
