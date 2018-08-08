(import [sincro.util [*]])
(require [sincro.util [*]])


(defn command [&rest cmd]
  { "command" cmd })


(defn get-property [property]
  (command "get_property" property))


(defn seek-to [val]
  (command "seek" val "relative"))


(defn print [msg]
  (command "show-text" msg))


(setv events
  { "event"
    [ "start-file"
      "end-file"
      "seek"
      "playback-restart"
      "pause"
      "unpause" ] })


(defn toggle-play [&optional play?]
  (if (is play? None)
    (command "cycle" "pause")
    (command "set_property" "pause" play?)))


(setv initialize-mpv
      (command "observe_property" "filename"))


(setv file-info
      [(get-property "file-size")
       (get-property "duration")])
