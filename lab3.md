<p align="center"><b>МОНУ НТУУ КПІ ім. Ігоря Сікорського ФПМ СПіСКС</b></p>
<p align="center">
<b>Звіт з лабораторної роботи 3</b><br/>
"Конструктивний і деструктивний підходи до роботи зі списками"<br/>
дисципліни "Вступ до функціонального програмування"
</p>
<p align="right"><b>Студент</b>: Яцков Максим Юрійович КВ-13</p>
<p align="right"><b>Рік</b>: 2024</p>

## Загальне завдання
Реалізуйте алгоритм сортування чисел у списку двома способами: функціонально і імперативно.
1. Функціональний варіант реалізації має базуватись на використанні рекурсії і конструюванні нових списків щоразу, коли необхідно виконати зміну вхідного списку. Не допускається використання: деструктивних операцій, циклів, функцій вищого порядку або функцій для роботи зі списками/послідовностями, що використовуються як функції вищого порядку. Також реалізована функція не має бути функціоналом (тобто приймати на вхід функції в якості аргументів).
2. Імперативний варіант реалізації має базуватись на використанні циклів і деструктивних функцій (псевдофункцій). Не допускається використання функцій вищого порядку або функцій для роботи зі списками/послідовностями, що використовуються як функції вищого порядку. Тим не менш, оригінальний список цей варіант реалізації також не має змінювати, тому перед виконанням деструктивних змін варто застосувати функцію copy-list (в разі необхідності). Також реалізована функція не має бути функціоналом (тобто приймати на вхід функції в якості аргументів).

Алгоритм, який необхідно реалізувати, задається варіантом (п. 3.1.1). Зміст і шаблон звіту наведені в п. 3.2.

Кожна реалізована функція має бути протестована для різних тестових наборів. Тести мають бути оформленні у вигляді модульних тестів (наприклад, як наведено у п. 2.3).

## Варіант 8
Алгоритм сортування обміном №4 ("шейкерне сортування") за незменшенням.

## Лістинг функції з використанням конструктивного підходу
```lisp
(defun ftol (lst)
    (if lst
        (if (not (endp (cdr lst)))
            (if (> (car lst) (cadr lst))
                (cons (cadr lst) (ftol (cons (car lst) (cddr lst))))
                (cons (car lst) (ftol (cdr lst)))
            )
            lst
        )
        nil
    )
)

(defun ltof (lst)
    (if lst
        (let ((f (car lst)) (buffer (ltof (cdr lst))))
            (if buffer
                (if (< f (car buffer))
                    (cons f buffer)
                    (cons (car buffer) (cons f (cdr buffer)))
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

(defun shuffle-sort-functional (lst)
    (if (and lst (listp lst))
        (let ((buffer (ltof (ftol lst))))
            (if (not (equal buffer lst))
                (cons (car buffer) (multiple-value-bind (last rest) (last-el-and-list (cdr buffer))
                    (append (shuffle-sort-functional rest) (list last))
                ))
                buffer
            )
        )
        nil
    )
)
```
### Тестові набори
```lisp
(defun check-func(func name input expected)
    (let ((buffer (funcall func input)))
        (format t "~:[FAILED~;passed~]... ~a~%" (equal buffer expected) name)
    )
)

(defun tests (func name)
    (format t "Running tests for ~A...~%" name)
    (check-func func "Test 1" '(7 3 9 1 4 1 4 5 2 1 3) '(1 1 1 2 3 3 4 4 5 7 9))
    (check-func func "Test 2" '(5 3 8 1 2 7 4 6) '(1 2 3 4 5 6 7 8))
    (check-func func "Test 3" '(10 9 5 2 8 3 6 4 7 1) '(1 2 3 4 5 6 7 8 9 10))
    (check-func func "Test 4" '(15 25 5 30 20 10) '(5 10 15 20 25 30))
    (check-func func "Test 5" '(2 2 2 2 2 1 1 1 3 3 3 4 4 4) '(1 1 1 2 2 2 2 2 3 3 3 4 4 4))
    (check-func func "Test 6" '(100 1 50 25 75 10 90 5) '(1 5 10 25 50 75 90 100))
    (check-func func "Test 7" '(0 -5 10 -10 15 -15 20 -20) '(-20 -15 -10 -5 0 10 15 20))
    (handler-case (check-func func "Test 8" '(8 4 3 5 nil 10 9 3) '(nil 3 3 4 5 8 9 10))
        (type-error () (format t "passed... Test 8~%"))
        (error (c) (format t "Error: ~a~%" c))
    )
)
```
### Тестування
```lisp
Running tests for shuffle-sort-functional...
passed... Test 1
passed... Test 2
passed... Test 3
passed... Test 4
passed... Test 5
passed... Test 6
passed... Test 7
passed... Test 8
```
## Лістинг функції з використанням деструктивного підходу
```lisp
(defun swap (lst i j)
    (let ((buffer (nth i lst)))
        (setf (nth i lst) (nth j lst))
        (setf (nth j lst) buffer)
    )
)

(defun swap-elements (lst i j)
    (if (not (or (= i j) (endp (cdr lst))))
        (if (< j i)
            (if (< (nth i lst) (nth j lst))
                (progn
                    (swap lst i j)
                    t
                )
            )
            (if (> (nth i lst) (nth j lst))
                (progn
                    (swap lst i j)
                    t
                )
            )
        )
    )
)

(defun shuffle-sort-imperative (lst)
    (do ((buffer lst) (flag t) (left 0) (right (1- (list-length lst))))
        ((not flag) buffer)
        (setf flag nil)
        (do ((i left (1+ i)))
            ((>= i right))
            (if (swap-elements buffer i (1+ i))
                (setf flag t)
            )
        )
        (if (null flag)
            (return buffer)
        )
        (setf right (1- right))
        (do ((i right (1- i)))
            ((<= i left))
            (if (swap-elements buffer i (1- i))
                (setf flag t)
            )
        )
        (setf left (1+ left))
    )
)
```
### Тестові набори
```lisp
(defun check-func(func name input expected)
    (let ((buffer (funcall func input)))
        (format t "~:[FAILED~;passed~]... ~a~%" (equal buffer expected) name)
    )
)

(defun tests (func name)
    (format t "Running tests for ~A...~%" name)
    (check-func func "Test 1" '(7 3 9 1 4 1 4 5 2 1 3) '(1 1 1 2 3 3 4 4 5 7 9))
    (check-func func "Test 2" '(5 3 8 1 2 7 4 6) '(1 2 3 4 5 6 7 8))
    (check-func func "Test 3" '(10 9 5 2 8 3 6 4 7 1) '(1 2 3 4 5 6 7 8 9 10))
    (check-func func "Test 4" '(15 25 5 30 20 10) '(5 10 15 20 25 30))
    (check-func func "Test 5" '(2 2 2 2 2 1 1 1 3 3 3 4 4 4) '(1 1 1 2 2 2 2 2 3 3 3 4 4 4))
    (check-func func "Test 6" '(100 1 50 25 75 10 90 5) '(1 5 10 25 50 75 90 100))
    (check-func func "Test 7" '(0 -5 10 -10 15 -15 20 -20) '(-20 -15 -10 -5 0 10 15 20))
    (handler-case (check-func func "Test 8" '(8 4 3 5 nil 10 9 3) '(nil 3 3 4 5 8 9 10))
        (type-error () (format t "passed... Test 8~%"))
        (error (c) (format t "Error: ~a~%" c))
    )
)
```
### Тестування
```lisp
Running tests for shuffle-sort-imperative...
passed... Test 1
passed... Test 2
passed... Test 3
passed... Test 4
passed... Test 5
passed... Test 6
passed... Test 7
passed... Test 8
```