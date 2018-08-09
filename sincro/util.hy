;; Ignore any exceptions raised from inside the body
(defmacro ignore-exceptions [&rest body]
  `(try (do ~@body) (except [] None)))


;; If an exception is raised from inside the body, return `default`
(defmacro rescue-with [default &rest body]
  `(try (do ~@body) (except [] ~default)))


;; Define a method inside a class
(defmacro defm [name args &rest body]
  `(defn ~(HySymbol name) [self ~@args] ~@body))


(defmacro defm/a [name args &rest body]
  `(defn/a ~(HySymbol name) [self ~@args] ~@body))


(defmacro incv [var] `(setv ~var (inc ~var)))
(defmacro decv [var] `(setv ~var (dec ~var)))


(defmacro safe-get [indexable &rest keys]
  `(try (get ~indexable ~@keys)
     (except [[KeyError IndexError]] None)))


(defn dict-to-tuple [d]
  "Convert a dict with a single key to a tuple"
  (get (lfor [k v] (.items d) (, k v)) 0))


(defmacro printf [fmt &rest args]
  `(print (.format ~fmt ~@args)))
