(import [sincro [message]]
        [string [Formatter]])
(require [sincro.util [*]])


;; Format with kwargs
(defn vformat [msg fmt]
  ((. (Formatter) vformat) msg [] fmt))


(setv *level-debug*   4
      *level-info*    3
      *level-warning* 2
      *level-error*   1
      *level-quiet*   0)


(setv level *level-info*)


(defn set-level [lvl]
  (global level)
  (setv tabl
        { "debug"   *level-debug*
          "info"    *level-info*
          "warning" *level-warning*
          "error"   *level-error*
          "quiet"   *level-quiet* })
  (try (setv level (get tabl lvl))
    (except [[KeyError]]
      (raise (ValueError (+ "Not a valid loglevel: " lvl))))))


(defclass Logger [object]
  "Create a logger that fetches messages from the messages module
  in the section signaled by the argument."
  [section None]

  (defm --init-- [section]
    (setv self.section section))

  (defm __log [t msg rst fmt]
    (print t (vformat (message.fetch self.section msg) fmt) (.join " " (map str rst))))

  (defm debug [msg &rest rst &kwargs fmt]
    (global level)
    (when (>= level *level-debug*)
      (self.__log "[debug]" msg rst fmt)))

  (defm info [msg &rest rst &kwargs fmt]
    (global level)
    (when (>= level *level-info*)
      (self.__log "[info]" msg rst fmt)))

  (defm warning [msg &rest rst &kwargs fmt]
    (global level)
    (when (>= level *level-warning*)
      (self.__log "[warning]" msg rst fmt)))

  (defm error [msg &rest rst &kwargs fmt]
    (global level)
    (when (>= level *level-error*)
      (self.__log "[error]" msg rst fmt))))
