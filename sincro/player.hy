;; Message types
(setv *position-msg* 1
      *print-msg* 2
      *seek-msg* 3
      *pause-msg* 4
      *unpause-msg* 5
      *file-size-msg* 6
      *file-duration-msg* 7)


(defn command [&rest cmd &kwonly id]
  { "command" (list cmd)
    "request_id" id })


(defn get-property [property &kwonly id]
  (command "get_property" property :id id))


(defn get-position []
  (get-property "time-pos" :id *position-msg*))


(defn seek-to [val]
  (command "seek" val "relative" :id *seek-msg*))


(defn print [msg]
  (command "show-text" msg 2000 :id *print-msg*))


(defn set-pause [pause?]
  (setv p (bool pause?))
  (command "set_property" "pause" p (if p *pause-msg* *unpause-msg*)))


;(setv initialize-mpv
;      (command "observe_property" "filename"))


(setv file-info
      [(get-property "file-size" :id *file-size-msg*)
       (get-property "duration" :id *file-duration-msg*)])


(setv mpv-args
      ["--force-window"
       "--pause"
       "--idle"
       "--no-terminal"
       "--keep-open"])
