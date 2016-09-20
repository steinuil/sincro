; General macros
(defmacro with-file [file thunk]
  `(with [f (open ~file)] (~thunk (.read f))))

; Class-related macros
(defmacro definit [args &rest body]
  `(defn --init-- [self ~@args] ~@body))

(defmacro defenter [&rest body]
  `(defn --enter-- [self] ~@body self))

(defmacro defexit [&rest body]
  `(defn --exit-- [self &rest args] ~@body))

(defmacro defm [name args &rest body]
  `(defn ~name [self ~@args] ~@body))
