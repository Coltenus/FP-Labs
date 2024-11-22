<p align="center"><b>МОНУ НТУУ КПІ ім. Ігоря Сікорського ФПМ СПіСКС</b></p>
<p align="center">
<b>Звіт з лабораторної роботи 4</b><br/>
"Функції вищого порядку та замикання"<br/>
дисципліни "Вступ до функціонального програмування"
</p>
<p align="right"><b>Студент</b>: Яцков Максим Юрійович</p>
<p align="right"><b>Рік</b>: 2024</p>

## Загальне завдання
Завдання складається з двох частин:
1. Переписати функціональну реалізацію алгоритму сортування з лабораторної роботи 3 з такими змінами: використати функції вищого порядку для роботи з послідовностями (де це доречно); додати до інтерфейсу функції (та використання в реалізації) два ключових параметра: key та test , що працюють аналогічно до того, як працюють параметри з такими назвами в функціях, що працюють з послідовностями. При цьому key має виконатись мінімальну кількість разів.
2. Реалізувати функцію, що створює замикання, яке працює згідно із завданням за варіантом (див. п 4.1.2). Використання псевдо-функцій не забороняється, але, за можливості, має бути мінімізоване.

## Варіант першої частини 8
Алгоритм сортування обміном №4 ("шейкерне сортування") за незменшенням.

## Лістинг реалізації першої частини завдання
```lisp
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
```
### Тестові набори та утиліти першої частини
```lisp
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
```
### Тестування першої частини
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
passed... Test 9
```

## Варіант другої частини 12
Написати функцію replacer , яка має два основні параметри what і to та два ключові параметри — test та count . repalcer має повернути функцію, яка при застосуванні в якості першого аргументу reduce робить наступне: при обході списку з кінця, кожен елемент списка-аргумента reduce , для якого функція test , викликана з цим елементом та значенням what , повертає значення t (або не nil ), заміняється на значення to . Якщо count передане у функцію, заміна виконується count разів. Якщо count не передане тоді обмежень на кількість разів заміни немає. test має значення за замовчуванням #'eql . Обмеження, які накладаються на використання функції-результату replacer при передачі у reduce визначаються розробником (тобто, наприклад, необхідно чітко визначити, якими мають бути значення ключових параметрів функції reduce from-end та initial-value ).
```lisp
CL-USER> (reduce (replacer 1 2)
    '(1 1 1 4)
    :from-end ...
    :initial-value ...)
(2 2 2 4)
CL-USER> (reduce (replacer 1 2 :count 2)
    '(1 1 1 4)
    :from-end ...
    :initial-value ...)
(1 2 2 4)
```

## Лістинг функції з використанням деструктивного підходу
```lisp
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
```
### Тестові набори та утиліти
```lisp
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
```
### Тестування
```lisp
Running tests for replacer...
passed... Test 1
passed... Test 1
passed... Test 2
passed... Test 3
```