(import [sincro [message logger]] json socket)
(require [sincro.util [*]])


(defclass ConnectionJson [object]
  "Generic connection handler that serializes messages to JSON.
  Meant to be inherited."
  [conn None
   host None
   separator None
   log None]

  ;; Make sure "with" works correctly
  (defm --enter-- [] (self.open) self)
  (defm --exit-- [&rest args] (self.close))

  (defm open []
    (self.log.info "connect" :server (self.host-string))
    (.connect self.conn self.host))

  (defm close []
    (self.log.info "disconnect")
    (ignore-exceptions
      (.shutdown self.conn socket.SHUT_RDWR))
    (.close self.conn))

  (defm send* [msgs]
    "Encode a list of messages to JSON and send them"
    (unless (empty? msgs)
      (for [msg msgs]
        (self.log.debug "to" msg))
      (.send self.conn
        (->> (lfor msg msgs (+ (json.dumps msg) self.separator))
             (.join "")
             (.encode)))))

  (defm send [&rest msgs]
    "Like send*, but takes variadic arguments"
    (self.send* (list msgs)))

  (defm host-string []
    "The stringified host"
    (raise NotImplementedError))

  (defm receive []
    "Receive and decode messages"
    (setv messages (-> (.recv self.conn 4096)
                       (.decode)
                       (.strip)
                       (.splitlines)))
    (unless (empty? messages)
      (for [line messages]
        (self.log.debug "from" line))
      (lfor line messages (json.loads line)))))


;; Subclasses for mpv and syncplay server connections.
;; Send a dictionary and receive a list of dictionaries.
(defclass Syncplay [ConnectionJson]
  (defm --init-- [host port]
    (setv self.host (, host port)
          self.log (logger.Logger "syncplay-connection")
          self.separator "\r\n"
          self.conn (socket.socket socket.AF_INET socket.SOCK_STREAM))
    (.settimeout self.conn 5))

  (defm host-string []
    (.join ":" (map str self.host))))


(defclass Mpv [ConnectionJson]
  (defm --init-- [path]
    (setv self.host (.encode path)
          self.log (logger.Logger "mpv-connection")
          self.separator "\n"
          self.conn (socket.socket socket.AF_UNIX socket.SOCK_STREAM)))

  (defm host-string []
    (.decode self.host)))
