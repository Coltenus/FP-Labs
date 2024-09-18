<p align="center"><b>МОНУ НТУУ КПІ ім. Ігоря Сікорського ФПМ СПіСКС</b></p>
<p align="center">
<b>Звіт з лабораторної роботи 1</b><br/>
"Обробка списків з використанням базових функцій"<br/>
дисципліни "Вступ до функціонального програмування"
</p>
<p align="right"><b>Студент</b>: <i>Яцков Максим Юрійович КВ-13</i></p>
<p align="right"><b>Рік</b>:<i> 2024</i></p>

## Загальне завдання

```lisp
;; Пункт 1
* (defvar *list*)
*LIST*
* (setq *list* (list 1 (cons 'c' (2 3)) 3 (cons nil ()) () (cons 1 2) (cons () 1)))
(1 (C 2 3) 3 (NIL) NIL (1 . 2) (NIL . 1))

;; Пункт 2
* (car *list*)
1

;; Пункт 3
* (cdr *list*)
((C 2 3) 3 (NIL) NIL (1 . 2) (NIL . 1))

;; Пункт 4
* (car (cdddr *list*))
(NIL)
* (NTH 3 *list*)
(NIL)

;; Пункт 5
* (NTH 6 *list*)
(NIL . 1)

;; Пункт 6
* (ATOM (NTH 2 *list*))
T
* (ATOM (NTH 5 *list*))
NIL
* (ATOM (NTH 0 *list*))
T
* (LISTP (NTH 1 *list*))
T
* (LISTP (NTH 4 *list*))
T
* (LISTP (NTH 0 (NTH 5 *list*)))
NIL

;; Пункт 7
* (EQUAL (NTH 5 *list*) (NTH 6 *list*))
NIL
* (EQUAL (NTH 6 *list*) (NTH 6 *list*))
T
* (EQUALP (cdr (NTH 5 *list*)) (NTH 1 (NTH 1 *list*)))
T
* (EQUALP (NTH 3 *list*) (NTH 4 *list*))
NIL
* (EVENP (NTH 2 *list*))
NIL
* (EVENP (NTH 1 (NTH 1 *list*)))
T

;; Пункт 8
* (APPEND *list* (NTH 1 *list*))
(1 (C 2 3) 3 (NIL) NIL (1 . 2) (NIL . 1) C 2 3)
```
## Варіант 8

![[lab-1-variant.png]]


```lisp
* (setq *list1* (list 6 'D))
(6 D)
* (setq *list2* (list (list 4 (rest *list1*) 5) 'E 'F *list1*))
((4 (D) 5) E F (6 D))
```
