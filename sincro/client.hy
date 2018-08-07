(import [sincro [logger protocol]])
(require [sincro.util [*]])


(setv log (logger.Logger "syncplay-handler"))


(defn handle-hello [msg]
  (print (get msg "motd")))


(defn handle-list [msg]
  (for [room msg]
    (for [user (get room "users")]
      (print user))))


(defn print-chat-msg [msg]
  (printf "<{}> {}" (get msg "user") (get msg "message")))


(defn quit-with-error [msg]
  (log.error "server-error" :message msg)
  (quit 1))


(defn handle-state [msg]
  (unless msg (return))
  (printf "Position: {}" (get msg "position")))


(setv handle-set
  (protocol.make-set-handler
    :room-change
    (fn [room] (printf "Room changed to {}" room))
    :user-change
    (fn [msg] (printf "{} changed settings" (get msg "user")))
    :features-change
    (fn [msg] (printf "{} changed features" (get msg "user")))
    :user-ready
    (fn [msg]
      (printf "User {} {}" (get msg "user")
              (if (get msg "ready?") "is ready" "is not ready")))
    :controller-identified
    (fn [x] None)
    :new-controlled-room
    (fn [x] None)
    :set-playlist
    (fn [msg] (print "Playlist changed"))
    :set-playlist-index
    (fn [msg] (printf "Playlist index set to {}" (get msg "index")))))


(setv response-handler
  (protocol.make-handler
    :hello handle-hello
    :set   handle-set
    :state handle-state
    :list  handle-list
    :chat  print-chat-msg
    :error quit-with-error))
