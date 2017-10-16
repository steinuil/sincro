(import json socket [sincro [message]])
(require [sincro.util [*]])

;; Generic connection handler.
;; Meant to be inherited.
(defclass ConnectionJson [object]
  [conn None
   host None
   type None
   debug False]

  (defm --enter-- [] (self.open) self)
  (defm --exit-- [&rest args] (self.close))

  (defm open []
    (print (.format (message.fetch self.type "connect") (self.host-string)))
    (.connect self.conn self.host))

  (defm close []
    (print (message.fetch self.type "disconnect"))
    (ignore (.shutdown self.conn socket.SHUT_RDWR))
    (.close self.conn))

  (defm print-debug [sender msg]
    (when self.debug (print (.format "[debug] ({}) {}" sender msg))))

  (defm send [dict]
    (self.print-debug (message.fetch self.type "to") dict)
    (.send self.conn (-> (json.dumps dict) (+ "\r\n") (.encode))))

  (defm receive []
    (print self)
    (def messages (-> (.recv self.conn 4096) (.decode) (.strip) (.splitlines)))
    (unless (empty? messages)
      (for [line messages] (self.print-debug (message.fetch self.type "from") line))
      (list-comp (json.loads line) [line messages]))))

;; Subclasses for mpv and syncplay server connections.
;; Send a dictionary and receive a list of dictionaries.
(defclass Syncplay [ConnectionJson]
  (defm --init-- [host port &key { "debug" False }]
    (def self.debug debug
         self.host (, host port)
         self.type "syncplay-connection"
         self.conn (socket.socket socket.AF_INET socket.SOCK_STREAM))
    (.settimeout self.conn 5))

  (defm host-string []
    (.join ":" (map str self.host))))

(defclass MPV [ConnectionJson]
  (defm --init-- [path &key { "debug" False }]
    (def self.debug debug
         self.host (.encode path)
         self.type "mpv-connection"
         self.conn (socket.socket socket.AF_UNIX socket.SOCK_STREAM)))

  (defm host-string []
    (.decode self.host)))
