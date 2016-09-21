(import json socket)
(require sincro.util)

;; Handles the connection. Sends and receives dictionaries.
;; Can be used in (with) blocks.
(defclass Connection [object]
  (defm --init-- [host port &key { "debug" False }]
    (def self.debug debug)
    (def self.host host)
    (def self.port port)
    (def self.conn (socket.socket socket.AF_INET socket.SOCK_STREAM)))

  (defm --enter-- []
    (.settimeout self.conn 5)
    (self.print-debug (.format "Connecting to {}:{}" self.host self.port))
    (.connect self.conn (, self.host self.port))
    self)

  (defm --exit-- [&rest args]
    (try
      (.shutdown self.conn socket.SHUT_RDWR)
      (except [] None)
      (finally
        (do (self.print-debug "Closing connection")
            (.close self.conn)))))

  (defm open []
    (self.--enter--))

  (defm close []
    (self.--exit--))

  (defm print-debug [msg]
    (when self.debug (print (+ "[debug] " msg))))

  (defm send [dict]
    (let [message (json.dumps dict)]
      (.send self.conn (.encode (+ message "\r\n")))
      (self.print-debug (+ "(client) " message))))

  (defm receive []
    (let [message (.strip (.decode (.recv self.conn 4096) "UTF-8"))]
      (unless (= message "")
        (for [l (.splitlines message)]
          (self.print-debug (+ "(server) " l)))
        (list (map json.loads (.splitlines message)))))))
