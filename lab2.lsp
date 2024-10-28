(defun remove-even-pair (lst)
    (if lst
        (cons (car lst) (cons (cadr lst) (remove-even-pair (cddddr lst))))
        nil
    )
)

(defun check-remove (name input expected)
    (format t "~:[FAILED~;passed~]... ~a~%"
    (equal (remove-even-pair input) expected)
    name))

(defun test-remove ()
    (format t "Running tests for remove-even-pair...~%")
    (check-remove "Test 1" '(1 2 3 4 5 6 7 8 9 10) '(1 2 5 6 9 10))
    (check-remove "Test 2" '(1 a 2 b 3 c 4) '(1 A 3 C))
    (check-remove "Test 3" '() '())
    (check-remove "Test 4" '(a b (c d) e (12 3) 4 5) '(a b (12 3) 4))
)

(test-remove)

(defun result-comparison (buffer buf dep lst)
    (if (> (first buf) dep)
        (values-list buf)
        (if (<= (first buffer) dep)
            (values-list (list dep lst))
        )
    )
)

(defun find-deepest-list-func (lst dep)
    (if (and lst (listp lst))
        (let ((buffer (multiple-value-list (find-deepest-list-func (cdr lst) dep))))
            (if (listp (second buffer))
                (cond
                    ((listp (car lst))
                        (progn
                            (let ((buf (multiple-value-list (find-deepest-list-func (car lst) (1+ dep)))))
                                (result-comparison buffer buf dep lst)
                            )
                            (let ((buf (multiple-value-list (find-deepest-list-func (car lst) (1+ dep)))))
                                (result-comparison buffer buf dep lst)
                            )
                        )
                    )
                    ((<= (first buffer) dep)
                        (values-list (list dep lst))
                    )
                    (t (values-list buffer))
                )
            )
        )
        (values-list (list dep nil))
    )
)

(defun find-deepest-list (lst)
    (second (multiple-value-list (find-deepest-list-func lst 0)))
)

(defun check-find (name input expected)
    (format t "~:[FAILED~;passed~]... ~a~%"
    (equal (find-deepest-list input) expected)
    name))

(defun test-find ()
    (format t "Running tests for find-deepest-list...~%")
    (check-find "Test 1" '(1 (2 (3) 4) 5) '(3))
    (check-find "Test 2" '(1 2 3 4 5) '(1 2 3 4 5))
    (check-find "Test 3" '(1 (2 (3 (4 (5))))) '(5))
    (check-find "Test 4" '() '())
    (check-find "Test 5" '(1 2 3 4 5 (6 7 8 9 10)) '(6 7 8 9 10))
)

(test-find)