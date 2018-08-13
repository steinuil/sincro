(require [sincro.util [*]])
(import json
        curio
        [sincro [message logger]])


(defclass ConnectionJson [object]
  "Generic connection handler that serializes messages to JSON.
  Meant to be inherited."
  [socket None
   host None
   separator None]

  (defm/a --aenter-- []
    (await (self.open)))

  (defm/a --aexit-- [&rest args]
    (await (self.close)))

  (defm/a open []
    (await (.connect self.socket self.host)))

  (defm/a close []
    (await (.close self.socket)))

  (defm/a send* [msgs]
    "Encode a list of messages to JSON and send them"
    (setv bytes (->> (lfor msg msgs
                       (+ (json.dumps msg) self.separator))
                     (.join "")
                     (.encode)))
    (await (.send self.socket bytes)))

  (defm/a send [&rest msgs]
    "Alias for send* that takes variadic arguments"
    (await (self.send* (list msgs))))

  (defm/a receive-iter []
    "Iterator that returns one message at a time"
    (while True
      (setv bytes (await (.recv self.socket 8192)))
      (when (empty? bytes)
        (break))

      (setv messages (->> bytes
                          (.decode)
                          (.strip)
                          (.splitlines)))
      (for [line messages]
        (yield (json.loads line))))))


;; Subclasses for mpv and syncplay server connections.
;; Send a dictionary and receive a list of dictionaries.
(defclass Syncplay [ConnectionJson]
  (defm --init-- [host port]
    (setv self.socket (curio.socket.socket :family curio.socket.AF_INET)
          self.host (, host port)
          self.separator "\r\n")))


(defclass Mpv [ConnectionJson]
  (defm --init-- [path]
    (setv self.socket (curio.socket.socket :family curio.socket.AF_UNIX)
          self.host (.encode path)
          self.separator "\n")))
