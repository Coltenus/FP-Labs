(format t "Lab 4~%")

(defun ftol (lst &key (test #'>) (key #'identity))
    (if lst
        (if (not (endp (cdr lst)))
            (if (funcall test (funcall key (car lst)) (funcall key (cadr lst)))
                (cons (cadr lst) (ftol (cons (car lst) (cddr lst)) :test test :key key))
                (cons (car lst) (ftol (cdr lst) :test test :key key))
            )
            lst
        )
        nil
    )
)

(defun ltof (lst &key (test #'>) (key #'identity))
    (if lst
        (let ((f (car lst)) (buffer (ltof (cdr lst) :test test :key key)))
            (if buffer
                (let ((kf (funcall key f)) (kb (funcall key (car buffer))))
                    (if (or (not (funcall test kf kb))
                            (equalp kf kb))
                        (cons f buffer)
                        (cons (car buffer) (cons f (cdr buffer)))
                    )
                )
                (list f)
            )
        )
        nil
    )
)

(defun last-el-and-list (lst)
    (if lst
        (multiple-value-bind (last rest) (last-el-and-list (cdr lst))
            (if last
                (values last (cons (car lst) rest))
                (values (car lst) nil)
            )
        )
        (values nil nil)
    )
)

(defun shuffle-sort-functional (lst &key (test #'>) (key #'identity))
    (if (and lst (listp lst))
        (let ((buffer (ltof (ftol lst :test test :key key) :test test :key key)))
            (if (not (equal buffer lst))
                (cons (car buffer) (multiple-value-bind (last rest) (last-el-and-list (cdr buffer))
                    (append (shuffle-sort-functional rest :test test :key key) (list last))
                ))
                buffer
            )
        )
        nil
    )
)

(defun check-shuffle (name input expected &key (test #'>) (key #'identity))
    (let ((buffer (shuffle-sort-functional input :test test :key key)))
        (format t "~:[FAILED~;passed~]... ~a~%" (equal buffer expected) name)
    )
)

(defun tests-shuffle (name)
    (format t "Running tests for ~A...~%" name)
    (check-shuffle "Test 1" '(7 3 9 1 4 1 4 5 2 1 3) '(1 1 1 2 3 3 4 4 5 7 9))
    (check-shuffle "Test 2" '(0 -5 10 -10 15 -15 20 -20) '(-20 -15 -10 -5 0 10 15 20))
    (check-shuffle "Test 3" '(8 4 3 5 1 10 9 3) '(1 3 3 4 5 8 9 10))
    (check-shuffle "Test 4" '(7 3 9 1 4 1 4 5 2 1 3) (reverse '(1 1 1 2 3 3 4 4 5 7 9)) :test #'<)
    (check-shuffle "Test 5" '(0 -5 10 -10 15 -15 20 -20) (reverse '(-20 -15 -10 -5 0 10 15 20)) :test #'<)
    (check-shuffle "Test 6" '(8 4 3 5 1 10 9 3) '(10 9 8 5 4 3 3 1) :test #'<)
    (check-shuffle "Test 7" '(7 3 9 1 4 1 4 5 2 1 3) '(9 7 5 4 4 3 3 2 1 1 1) :test #'< :key #'abs)
    (check-shuffle "Test 8" '(0 -5 10 -10 15 -15 20 -20) '(20 -20 15 -15 10 -10 -5 0) :test #'< :key #'abs)
    (check-shuffle "Test 9" '(8 4 3 5 1 10 9 3) '(10 9 8 5 4 3 3 1) :test #'< :key #'abs)
)

(tests-shuffle "shuffle-sort-functional")

(defun replacer (what to &key (count nil) (test #'eql))
  (let ((replace-count 0))
    (lambda (acc item)
        (let ((lst nil) (it nil))
            (if (listp item)
                (progn
                    (setq lst item)
                    (setq it acc))
                (progn
                    (setq lst acc)
                    (setq it item))
            )
            (if (and (funcall test it what)
                    (or (not count)
                        (< replace-count count)))
                (progn
                    (incf replace-count)
                    (cons to lst))
                (cons it lst))
        )
      )))

(defun check-replacer (name input what to expected &key (count nil) (from-end nil))
    (let ((buffer (reduce (replacer what to :count count) input :initial-value '() :from-end from-end)))
        (format t "~:[FAILED~;passed~]... ~a~%" (equal buffer expected) name)
    )
)

(defun tests-replacer (name)
    (format t "Running tests for ~A...~%" name)
    (check-replacer "Test 1" '(1 1 1 4) 1 2 '(4 2 2 2))
    (check-replacer "Test 1" '(1 1 1 4) 1 2 '(4 1 2 2) :count 2)
    (check-replacer "Test 2" '(1 1 1 4) 1 2 '(2 2 2 4) :from-end t)
    (check-replacer "Test 3" '(1 1 1 4) 1 2 '(1 2 2 4) :count 2 :from-end t)
)

(tests-replacer "replacer")


