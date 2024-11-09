<p align="center"><b>МОНУ НТУУ КПІ ім. Ігоря Сікорського ФПМ СПіСКС</b></p>  
<p align="center">  
<b>Звіт з лабораторної роботи 2</b><br/>  
"Рекурсія"<br/>  
дисципліни "Вступ до функціонального програмування"  
</p>  
<p align="right"><b>Студент</b>: Яцков Максим Юрійович</p>  
<p align="right"><b>Рік</b>: 2024</p>  

## Загальне завдання  

Реалізуйте дві рекурсивні функції, що виконують деякі дії з вхідним(и) списком(-ами), за можливості/необхідності використовуючи різні види рекурсії. Функції, які необхідно реалізувати, задаються варіантом (п. 2.1.1).
Вимоги до функцій:  
1. Зміна списку згідно із завданням має відбуватись за рахунок конструювання нового списку, а не зміни наявного (вхідного).  
2. Не допускається використання функцій вищого порядку чи стандартних функцій для роботи зі списками, що не наведені в четвертому розділі навчального посібника.  
3. Реалізована функція не має бути функцією вищого порядку, тобто приймати функції в якості аргументів.  
4. Не допускається використання псевдофункцій (деструктивного підходу). 
5. Не допускається використання циклів. 
Кожна реалізована функція має бути протестована для різних тестових наборів. Тести мають бути оформленні у вигляді модульних тестів (див. п. 2.3). 
Додатковий бал за лабораторну роботу можна отримати в разі виконання всіх наступних умов:  
- робота виконана до дедлайну (включно з датою дедлайну)  
- крім основних реалізацій функцій за варіантом, також реалізовано додатковий варіант однієї чи обох функцій, який працюватиме швидше за основну реалізацію, не порушуючи при цьому перші три вимоги до основної реалізації (вимоги 4 і 5 можуть бути порушені), за виключенням того, що в разі необхідності можна також використати стандартну функцію copy-list
## Варіант 9  
1. Написати функцію remove-even-pairs , яка видаляє зі списку кожен третій та четвертий елементи: 
```lisp
CL-USER> (remove-even-pairs '(1 a 2 b 3 c 4))  
(1 A 3 C)  
```
2. Написати функцію find-deepest-list , яка поверне "найглибший" підсписок з вхідного списку:  
```lisp
CL-USER> (find-deepest-list '(1 2 3 4 5))
(1 2 3 4 5)  
CL-USER> (find-deepest-list '(1 (2 (3) 4) 5))  
(3)
```
## Лістинг функції remove-even-pairs  
```lisp  
(defun remove-even-pair (lst)
    (if lst (listp lst)
        (cons (car lst) (cons (cadr lst) (remove-even-pair (cddddr lst))))
        nil
    )
)
```  
### Тестові набори  
```lisp  
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
```  
### Тестування  
```lisp  
* (test-remove)
Running tests for remove-even-pair...
passed... Test 1
passed... Test 2
passed... Test 3
passed... Test 4
NIL
```  
## Лістинг функції find-deepest-list  
```lisp  
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
                        (let ((buf (multiple-value-list (find-deepest-list-func (car lst) (1+ dep)))))
                            (result-comparison buffer buf dep lst)
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
```  
### Тестові набори  
```lisp  
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
```  
### Тестування  
```lisp  
* (test-find)
Running tests for find-deepest-list...
passed... Test 1
passed... Test 2
passed... Test 3
passed... Test 4
passed... Test 5
NIL
```