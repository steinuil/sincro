(import [sincro [message]]
        [string [Formatter]])
(require [sincro.util [*]])


;; Format with kwargs
(defn vformat [msg fmt]
  ((. (Formatter) vformat) msg [] fmt))


(defclass Logger [object]
  "Create a logger that fetches messages from the messages module
  in the section signaled by the argument."
  [section None]

  (defm --init-- [section]
    (def self.section section))

  (defm __log [t msg rst fmt]
    (print t (vformat (message.fetch self.section msg) fmt) (.join " " (map str rst))))

  (defm debug   [msg &rest rst &kwargs fmt] (self.__log "[debug]"   msg rst fmt))
  (defm info    [msg &rest rst &kwargs fmt] (self.__log "[info]"    msg rst fmt))
  (defm warning [msg &rest rst &kwargs fmt] (self.__log "[warning]" msg rst fmt))
  (defm error   [msg &rest rst &kwargs fmt] (self.__log "[error]"   msg rst fmt)))
