;; Config options have three sources, in ascending order of importance:
;;  - defaults: sincro.default.options
;;  - file: User config file, ./conf.yaml by default
;;  - cli: Command line arguments

;; cli overrides file, file overrides defaults.
;; Unrecognized file options are simply discarded.

(import [sincro [default message]]
        argparse yaml)
(require [sincro.util [*]])

(defn load [cli-args]
  (def args (parse-cli cli-args))
  (when args.version
    (quit (message.fetch "various" "version")))

  (def conf-file (or args.config-path "conf.yaml"))
  (merge (rescue (with-input-file conf-file yaml.laod) {})
         args))

;; Merge all options
;; First merge the file options with the cli ones,
;; then override the defaults with the result of the above.
(defn merge [file args]
  (for [arg (.items (vars args))]
    (def (, key val) arg)
    (unless (not val)
      (assoc file key val)))

  (def config default.options)
  (for [key config]
    (try (assoc config key (get file key))
      (except [] (continue))))

  config)

(defn parse-cli [arguments]
  (def msg (fn [type] (message.fetch "argument" type))
       parser (argparse.ArgumentParser
               :description (msg "description")
               :epilog (msg "epilog"))
       argument parser.add-argument)

  (argument "-s" "--server"
    :metavar "address" :type str :help (msg "server"))
  (argument "--port"
    :metavar "number" :type int :help (msg "port"))
  (argument "-p" "--password"
    :metavar "password" :type str :help (msg "password"))

  (argument "-n" "--name"
    :metavar "username" :type str :help (msg "name"))
  (argument "-r" "--room"
    :metavar "room" :type str :help (msg "room"))

  (argument "--player-path"
    :metavar "path" :type str :help (msg "player-path"))
  (argument "--config-path"
    :metavar "path" :type str :help (msg "config-path"))
  (argument "-d" "--debug"
    :action "store_true" :help (msg "debug"))
  (argument "-V" "--version"
    :action "store_true" :help (msg "version"))

  (argument "file"
    :metavar "file" :type str :nargs "?" :help (msg "file"))
  (argument "player-args"
    :metavar "player-args" :type str :nargs "*" :help (msg "player-args"))

  (parser.parse-args arguments))
