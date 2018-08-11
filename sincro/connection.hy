(require [sincro.util [*]])
(import json socket asyncio
        [sincro [message logger]])


(defclass ConnectionJson [object]
  "Generic connection handler that serializes messages to JSON.
  Meant to be inherited."
  [conn None
   reader None
   writer None
   separator None]

  (defm/a --aenter-- []
    (await (self.open)))

  (defm/a --aexit-- [&rest args]
    (self.close))

  (defm/a open []
    (setv [self.reader self.writer] (await self.conn)))

  (defm close []
    (.close self.writer))

  (defm send* [msgs]
    "Encode a list of messages to JSON and send them"
    (.writelines self.writer
      (map (fn [msg] (.encode (+ (json.dumps msg) self.separator)))
           msgs)))

  (defm send [&rest msgs]
    "Alias for send* that takes variadic arguments"
    (self.send* (list msgs)))

  (defm/a flush []
    "Flush the write buffer"
    (await (.drain self.writer)))

  (defm/a receive []
    (setv bytes (await (.read self.reader 4096)))
    (when (empty? bytes)
      (return))
    (->> bytes
         (.decode)
         (.strip)
         (.splitlines)
         (map json.loads)
         (list)))

  (defm/a receive-iter []
    "Iterator that returns one message at a time"
    (while True
      (setv bytes (await (.read self.reader 4096)))
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
  (defm --init-- [host port loop]
    (setv self.conn (asyncio.open-connection :host host :port port :loop loop
                                             :family socket.AF_INET)
          self.separator "\r\n")))


(defclass Mpv [ConnectionJson]
  (defm --init-- [path loop]
    (setv self.conn (asyncio.open-unix-connection :path (.encode path) :loop loop)
          self.separator "\n")))
