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
(defun append-two-elements (lst el1 el2)
    (append lst (cond
        ((and (not (null el1)) (null el2)) (list el1))
        ((null el1) nil)
        (t (list el1 el2))
    ))
)
  
(defun remove-even-pair-func (lst1 lst2 ind)
    (let ((ret lst2) (rest (mod ind 4)))
        (if (= rest 2)
            (if (null (nth (+ ind 2) lst1))
                ret
                (remove-even-pair-func lst1 ret (+ ind 2))
            )
            (if (null (nth (+ ind 2) lst1))
                (append-two-elements ret (nth ind lst1) (nth (1+ ind) lst1))
                (remove-even-pair-func lst1 (append-two-elements ret (nth ind lst1) (nth (1+ ind) lst1)) (+ ind 2))
            )
        )
    )
)
  
(defun remove-even-pair (lst)
    (remove-even-pair-func lst nil 0)
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
(defun find-deepest-list-func (lst deep)
    (let ((max-depth deep) (max-depth-list lst))
        (if (and (not (null (car lst))) (listp (car lst)))
            (let ((buffer-list (find-deepest-list-func (car lst) (+ deep 1))))
                (if (> (nth 0 buffer-list) max-depth)
                    (and (setq max-depth (nth 0 buffer-list))
                    (setq max-depth-list (nth 1 buffer-list)))
                )
            )
        )
        (if (not (null lst))
            (let ((buffer-list (find-deepest-list-func (cdr lst) deep)))
                (if (> (nth 0 buffer-list) max-depth)
                    (and (setq max-depth (nth 0 buffer-list))
                    (setq max-depth-list (nth 1 buffer-list)))
                )
            )
        )
        (list max-depth max-depth-list)
    )
)
  
(defun find-deepest-list (lst)
    (nth 1 (find-deepest-list-func lst 0))
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