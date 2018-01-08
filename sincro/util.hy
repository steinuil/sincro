;; Returns the result of the passed function
;; applied to the contents of the file
(defmacro with-input-file [file fun]
  (setv f (gensym))
  `(with [~f (open ~file)]
     (~fun (.read ~f))))


;; Ignore any exceptions raised from inside the body
(defmacro ignore-exceptions [&rest body]
  `(try (do ~@body) (except [] None)))


;; If an exception is raised from inside the body, return `default`
(defmacro rescue-with [default &rest body]
  `(try (do ~@body) (except [] ~default)))


;; Define a method inside a class
(defmacro defm [name args &rest body]
  `(defn ~name [self ~@args] ~@body))


(defn dget [dict key &key {"default" None}]
  "Like `get` but returns None or the supplied value on failure"
  (try (get dict key)
    (except [[KeyError IndexError]] default)))


(defn merge-dicts [dest source]
  "Destructively merge dest with source,
  overwriting dest when there's a name clash"
  (for [(, key val) (.items source)]
    (assoc dest key val))
  dest)


(defn case [key dict] (get dict key))


(defn tuple? [x]
  (isinstance x tuple))
