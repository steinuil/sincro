;; Ignore any exceptions raised from inside the body
(defmacro ignore-exceptions [&rest body]
  `(try (do ~@body) (except [] None)))


;; If an exception is raised from inside the body, return `default`
(defmacro rescue-with [default &rest body]
  `(try (do ~@body) (except [] ~default)))


;; Define a method inside a class
(defmacro defm [name args &rest body]
  `(defn ~name [self ~@args] ~@body))


(defmacro incv [var] `(setv ~var (inc ~var)))
(defmacro decv [var] `(setv ~var (dec ~var)))


(defmacro get-with-default [dict default &rest keys]
  `(try (get ~dict ~@keys)
     (except [[KeyError IndexError]] ~default)))


(defmacro safe-get [indexable &rest keys]
  `(try (get ~indexable ~@keys)
     (except [[KeyError IndexError]] None)))


(defn merge-dicts [dest source]
  "Destructively merge dest with source,
  overwriting dest when there's a name clash"
  (for [(, key val) (.items source)]
    (assoc dest key val))
  dest)


(defn tuple? [x]
  (isinstance x tuple))
