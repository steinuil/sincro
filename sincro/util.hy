(defmacro with-file [file thunk]
  `(with [f (open ~file)] (~thunk (.read f))))

; Define method
(defmacro defm [name args &rest body]
  `(defn ~name [self ~@args] ~@body))
