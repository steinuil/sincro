;; Config options have three sources, in ascending order of importance:
;;  - defaults: sincro.default.options
;;  - file: User config file, ./conf.yaml by default
;;  - cli: Command line arguments

;; cli overrides file, file overrides defaults.
;; Unrecognized file options are simply discarded.

(import [sincro [default message]]
        [sincro.util [dget]]
        argparse yaml)
(require [sincro.util [*]])


(defn load [cli-args]
  "Load the config options from all locations and return them in a dict"
  (setv cli (parse-cli cli-args))
  (when cli.version
    (quit (message.fetch "various" "version")))

  (setv config-path (or cli.config-path default.config-path)
        file (rescue-with {} (with-input-file config-path yaml.load))
        cli-dict (vars cli)
        final {})

  (for [(, key default-val) (.items default.options)]
    (setv val (or (dget cli-dict key)
                  (dget file key)
                  default-val))
    (assoc final key val))

  (assoc final "file" cli.file)

  final)


(defn parse-cli [arguments]
  (setv msg (fn [type] (message.fetch "argument" type))
        parser (argparse.ArgumentParser
                 :description (msg "description")
                 :epilog (msg "epilog"))
        argument parser.add-argument)

  (argument "-s" "--server"
    :metavar "address" :type str :help (msg "server"))
  (argument "--port"
    :metavar "number" :type int :help (msg "port"))
  (argument "-p" "--server-password"
    :metavar "server-password" :type str :help (msg "server-password"))

  (argument "-n" "--name"
    :metavar "username" :type str :help (msg "name"))
  (argument "-r" "--room"
    :metavar "room" :type str :help (msg "room"))

  (argument "--player-path"
    :metavar "path" :type str :help (msg "player-path"))
  (argument "--config-path"
    :metavar "path" :type str :help (msg "config-path"))
  (argument "-V" "--version"
    :action "store_true" :help (msg "version"))

  (argument "file"
    :metavar "file" :type str :nargs "?" :help (msg "file"))
  (argument "player-args"
    :metavar "player-args" :type str :nargs "*" :help (msg "player-args"))

  (parser.parse-args arguments))
