(import [sincro.util [*]])
(require sincro.util)

(defn fetch [property]
  { "command" [ "get_property" property ] })

(def events
  { "event"
    [ "start-file"
      "end-file"
      "seek"
      "playback-restart"
      "pause"
      "unpause" ] })
