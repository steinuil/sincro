(import [sincro [logger protocol]])
(require [sincro.util [*]])


(defn ui-print [msg] (print msg))


(setv log (logger.Logger "syncplay-handler"))


(defn handle-hello [msg]
  (setv motd (safe-get msg "motd"))
  (if motd
    (ui-print motd)
    (log.warning "property-not-found" :property "motd")))


(defn handle-list [msg]
  (setv users [])
  (for [rooms msg]
    (for [(, room user) (.items rooms)]
      (.append users (get user "username"))))
  (ui-print users))


(defn print-chat-msg [msg]
  (try (do (setv message (get msg "message")
                 user (get msg "username"))
           (ui-print (.format "<{}> {}" message user)))
    (except [e KeyError]
      (log.warning "property-not-found" :property (get e.args 0)))))


(defn quit-with-error [msg]
  (setv err (safe-get msg "message"))
  (log.error "server-error" :message err)
  (quit 1))


(setv response-handler
  (protocol.make-handler
    :hello handle-hello
    :set   (fn [x] None)
    :state (fn [x] None)
    :list  handle-list
    :chat  print-chat-msg
    :error quit-with-error))
