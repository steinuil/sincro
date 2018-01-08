(import json socket [sincro [message logger]])
(require [sincro.util [*]])


(defclass ConnectionJson [object]
  "Generic connection handler that serializes messages to JSON.
  Meant to be inherited."
  [conn None
   host None
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

  (defm send [dict]
    "Encode messages to JSON and send them"
    (self.log.debug "to" dict)
    (.send self.conn (-> (json.dumps dict)
                         (+ "\r\n")
                         (.encode))))

  (defm host-string []
    "The stringified host"
    (raise NotImplementedError))

  (defm receive []
    "Receive and decode messages"
    (def messages (-> (.recv self.conn 4096)
                      (.decode)
                      (.strip)
                      (.splitlines)))
    (unless (empty? messages)
      (for [line messages]
        (self.log.debug "from" line))
      (list-comp (json.loads line) [line messages]))))


;; Subclasses for mpv and syncplay server connections.
;; Send a dictionary and receive a list of dictionaries.
(defclass Syncplay [ConnectionJson]
  (defm --init-- [host port]
    (setv self.host (, host port)
          self.log (logger.Logger "syncplay-connection")
          self.conn (socket.socket socket.AF_INET socket.SOCK_STREAM))
    (.settimeout self.conn 5))

  (defm host-string []
    (.join ":" (map str self.host))))


(defclass MPV [ConnectionJson]
  (defm --init-- [path]
    (setv self.host (.encode path)
          self.log (logger.Logger "mpv-connection")
          self.conn (socket.socket socket.AF_UNIX socket.SOCK_STREAM)))

  (defm host-string []
    (.decode self.host)))
