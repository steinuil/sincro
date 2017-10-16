;; Returns the result of the passed function
;; applied to the contents of the file
(defmacro with-input-file [file thunk]
  `(with [f (open ~file)] (~thunk (.read f))))

;; Ignore any errors that a function might raise
(defmacro ignore [fun]
  `(try ~fun
     (except [] None)))

;; Try returning the first, fall back to the
;; second if it fails
(defmacro rescue [fun default]
  `(try ~fun
     (except [] ~default)))

(defn merge [a b]
  (for [key b]
    (assoc a key (get b key)))
  a)

(defn case [type dict] (get dict type))

;; Define method
(defmacro defm [name args &rest body]
  `(defn ~name [self ~@args] ~@body))

(defn tuple? [x]
  (isinstance x tuple))
