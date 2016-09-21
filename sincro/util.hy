; Returns the result of the passed function
; applied to the contents of the file
(defmacro with-input-file [file thunk]
  `(with [f (open ~file)] (~thunk (.read f))))

; Tries returning the first, falls back to the
; second if it fails
(defmacro rescue [fun default]
  `(try ~fun
     (except [] ~default)))

; Try to merge two dictionaries, only returns
; first if second throws an exception
(defmacro try-merge [a b]
  `(let [res ~a]
     (try (let [o ~b] (for [k o] (assoc res k (get o k))) res)
       (except [] res))))

; Define method
(defmacro defm [name args &rest body]
  `(defn ~name [self ~@args] ~@body))
