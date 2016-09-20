#!/usr/bin/env hy
(import [sincro [config]])

(defmain [&rest args]
  (let [conf (config.load (cdr args))]
    (print conf)
    ; Do stuff
    ))
