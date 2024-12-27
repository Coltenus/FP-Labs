<p align="center"><b>МОНУ НТУУ КПІ ім. Ігоря Сікорського ФПМ СПіСКС</b></p>
<p align="center">
<b>Звіт з лабораторної роботи 5</b><br/>
"Робота з базою даних"<br/>
дисципліни "Вступ до функціонального програмування"
</p>
<p align="right"><b>Студент</b>: Яцков Максим Юрійович КВ-13</p>
<p align="right"><b>Рік</b>: 2024</p>

## Загальне завдання
В роботі необхідно реалізувати утиліти для роботи з базою даних, заданою за варіантом (п. 5.1.1). База даних складається з кількох таблиць. Таблиці представлені у вигляді CSV файлів. При зчитуванні записів з таблиць, кожен запис має бути представлений певним типом в залежності від варіанту: структурою, асоціативним списком або геш-таблицею.
1. Визначити структури або утиліти для створення записів з таблиць (в залежності від типу записів, заданого варіантом).
2. Розробити утиліту(-и) для зчитування таблиць з файлів.
3. Розробити функцію select , яка отримує на вхід шлях до файлу з таблицею, а також якийсь об'єкт, який дасть змогу зчитати записи конкретного типу або структури. Це може бути ключ, список з якоюсь допоміжною інформацією, функція і т. і. За потреби параметрів може бути кілька. select повертає лямбда-вираз, який, в разі виклику, виконує "вибірку" записів з таблиці, шлях до якої було передано у select . При цьому лямбда-вираз в якості ключових параметрів може отримати на вхід значення полів записів таблиці, для того щоб обмежити вибірку лише заданими значеннями (виконати фільтрування). Вибірка повертається у
вигляді списку записів.
4. Написати утиліту(-и) для запису вибірки (списку записів) у файл.
5. Написати функції для конвертування записів у інший тип (в залежності від варіанту):
- структури у геш-таблиці
- геш-таблиці у асоціативні списки
- асоціативні списки у геш-таблиці
6. Написати функцію(-ї) для "красивого" виводу записів таблиці.

## Варіант 12
- База даних: <b>Космічні апарати</b>
- Тип записів: <b>Асоціативний список</b>

## Лістинг реалізації завдання
```lisp
(defun split-string (str sep &key (buffer "") (lst nil))
    (if (not (characterp sep))
        (error "Invalid separator")
    )
    (if (not (stringp str))
        (error "Invalid string")
    )
    (if (not (stringp buffer))
        (error "Invalid buffer")
    )
    (if (and str (> (length str) 0) (not (and (= (length str) 1) (char= (char str 0) #\Return))))
        (progn
            (if (char= (char str 0) sep)
                (progn
                    (setq lst (append lst (list buffer)))
                    (setq buffer "")
                )
                (setq buffer (concatenate 'string buffer (subseq str 0 1)))
            )
            (split-string (subseq str 1) sep :buffer buffer :lst lst)
        )
        (append lst (list buffer))
    )
)

(defun select (file-name keyword &key (lst '()))
    "Read the contents of a file into a list of strings."
    (lambda (&key (start 1) (end nil) (assoc-pos nil) (assoc-neg nil))
        (setq lst '())
        (if (or (null start) (<= start 0))
            (error "Invalid start value")
        )
        (if (and end (or (< end start)))
            (error "Invalid end value")
        )
        (with-open-file (stream file-name :direction :input :if-does-not-exist :error)
            (loop for i from 1 to start do
                (read-line stream nil)
            )
            (do ((line (read-line stream nil) (read-line stream nil))
                (counter start (1+ counter)))
                ((null line) nil)
                (if (and end (= counter end))
                    (return)
                )
                (let ((lst-split (split-string line #\,)) (assoc-lst nil))
                    (case keyword
                        (:company (if (= (length lst-split) 5)
                                (progn
                                    (setq assoc-lst nil)
                                    (setq assoc-lst (acons :id (parse-integer (nth 0 lst-split)) assoc-lst))
                                    (setq assoc-lst (acons :name (nth 1 lst-split) assoc-lst))
                                    (setq assoc-lst (acons :country (nth 2 lst-split) assoc-lst))
                                    (setq assoc-lst (acons :type (nth 3 lst-split) assoc-lst))
                                    (setq assoc-lst (acons :founded (nth 4 lst-split) assoc-lst))
                                )
                                (error "Invalid company data")
                            )
                        )
                        (:spaceship (if (= (length lst-split) 5)
                                (progn 
                                    (setq assoc-lst nil)
                                    (setq assoc-lst (acons :id (parse-integer (nth 0 lst-split)) assoc-lst))
                                    (setq assoc-lst (acons :name (nth 1 lst-split) assoc-lst))
                                    (setq assoc-lst (acons :company (parse-integer (nth 2 lst-split)) assoc-lst))
                                    (setq assoc-lst (acons :mission-type (nth 3 lst-split) assoc-lst))
                                    (setq assoc-lst (acons :first-launch-date (nth 4 lst-split) assoc-lst))
                                )
                                (error "Invalid spaceship data")
                            )
                        )
                        (t (error "Invalid keyword"))
                    )
                    (let ((result t))
                        (if (and (null assoc-pos) (null assoc-neg))
                            (setq result t)
                            (loop for val in assoc-lst do
                                (let ((pos-val (assoc (car val) assoc-pos)) (neg-val (assoc (car val) assoc-neg)))
                                    (if (and pos-val (not (equalp (cdr val) (cdr pos-val))))
                                        (setq result nil)
                                    )
                                    (if (and neg-val (equalp (cdr val) (cdr neg-val)))
                                        (setq result nil)
                                    )
                                    (if (not result)
                                        (return)
                                    )
                                )
                            )
                        )
                        (if result
                            (setq lst (append lst (list assoc-lst)))
                        )
                    )
                )
            )
        )
        lst
    )
)

(defun print-data (csv-data keyword &key (text nil))
    (if (not (listp csv-data))
        (error "Invalid CSV data")
    )
    (if (and text (not (stringp text)))
        (error "Invalid text")
    )
    (if text
        (format t "~a~%" text)
    )
    (case keyword
        (:company (format t "~3a ~16a ~12a ~16a ~a~%" "ID" "Name" "Country" "Type" "Founded"))
        (:spaceship (format t "~3a ~16a ~7a ~16a ~a~%" "ID" "Name" "Company" "Mission Type" "First Launch Date"))
        (t (error "Invalid keyword"))
    )
    (loop for row in csv-data do
        (case keyword
            (:company (format t "~3d ~16a ~12a ~16a ~a" (cdr (assoc :id row))
                                                (cdr (assoc :name row))
                                                (cdr (assoc :country row))
                                                (cdr (assoc :type row))
                                                (cdr (assoc :founded row)))
            )
            (:spaceship (format t "~3d ~16a ~7d ~16a ~a" (cdr (assoc :id row))
                                                    (cdr (assoc :name row))
                                                    (cdr (assoc :company row))
                                                    (cdr (assoc :mission-type row))
                                                    (cdr (assoc :first-launch-date row)))
            )
            (t (error "Invalid keyword"))
        )
        (format t "~%")
    )
    (format t "~%")
)

(defun print-object-t (id spaceships companies keyword)
    (if (not (listp spaceships))
        (error "Invalid spaceships data")
    )
    (if (not (listp companies))
        (error "Invalid companies data")
    )
    (let ((object nil) (objects-list nil))
        (case keyword
            (:spaceship (setq objects-list spaceships))
            (:company (setq objects-list companies))
            (t (error "Invalid keyword"))
        )
        (loop for row in objects-list do
            (if (= id (cdr (assoc :id row)))
                (setq object row)
            )
            (if object
                (return)
            )
        )
        (if object
            (case keyword
                (:spaceship
                    (format t "Spaceship ID: ~a~%" (cdr (assoc :id object)))
                    (format t "Spaceship: ~a~%" (cdr (assoc :name object)))
                    (format t "Company: ")
                    (let ((company nil))
                        (loop for r in companies do
                            (if (= (cdr (assoc :company object)) (cdr (assoc :id r)))
                                (setq company r)
                            )
                            (if company
                                (return)
                            )
                        )
                        (if company
                            (format t "~a~%" (cdr (assoc :name company)))
                            (format t "not found~%")
                        )
                    )
                    (format t "Mission Type: ~a~%" (cdr (assoc :mission-type object)))
                    (format t "First Launch Date: ~a~%" (cdr (assoc :first-launch-date object)))
                )
                (:company
                    (format t "Company ID: ~a~%" (cdr (assoc :id object)))
                    (format t "Company: ~a~%" (cdr (assoc :name object)))
                    (format t "Country: ~a~%" (cdr (assoc :country object)))
                    (format t "Type: ~a~%" (cdr (assoc :type object)))
                    (format t "Founded: ~a~%" (cdr (assoc :founded object)))
                    (format t "Spaceships: ")
                    (let ((spships '()))
                        (loop for s in spaceships do
                            (if (= (cdr (assoc :id object)) (cdr (assoc :company s)))
                                (setq spships (append spships (list s)))
                            )
                        )
                        (if spships
                            (progn
                                (format t "~a" (cdr (assoc :name (nth 0 spships))))
                                (loop for i from 1 to (1- (length spships)) do
                                    (format t ", ~a" (cdr (assoc :name (nth i spships)))))
                            )
                            (format t "not found")
                        )
                    )
                )
            )
            (format t "Object with ID ~a not found" id)
        )
        (format t "~%")
    )
)

(defun save-data (data file-name keyword)
    (if (not (listp data))
        (error "Invalid data")
    )
    (if (not (stringp file-name))
        (error "Invalid file name")
    )
    (with-open-file (stream file-name :direction :output :if-exists :supersede)
        (case keyword
            (:company (format stream "ID,Name,Country,Type,Founded"))
            (:spaceship (format stream "ID,Name,Company ID,Mission Type,First Launch Date"))
            (t (error "Invalid keyword"))
        )
        (if (> (length data) 0)
            (progn
                (format stream "~%")
                (case keyword
                    (:company (format stream "~d,~a,~a,~a,~a" (cdr (assoc :id (nth 0 data)))
                                                            (cdr (assoc :name (nth 0 data)))
                                                            (cdr (assoc :country (nth 0 data)))
                                                            (cdr (assoc :type (nth 0 data)))
                                                            (cdr (assoc :founded (nth 0 data))))
                    )
                    (:spaceship (format stream "~d,~a,~d,~a,~a" (cdr (assoc :id (nth 0 data)))
                                                            (cdr (assoc :name (nth 0 data)))
                                                            (cdr (assoc :company (nth 0 data)))
                                                            (cdr (assoc :mission-type (nth 0 data)))
                                                            (cdr (assoc :first-launch-date (nth 0 data))))
                    )
                    (t (error "Invalid keyword"))
                )
                (mapc (lambda (it)
                    (format stream "~%")
                    (case keyword
                        (:company (format stream "~d,~a,~a,~a,~a" (cdr (assoc :id it))
                                                                (cdr (assoc :name it))
                                                                (cdr (assoc :country it))
                                                                (cdr (assoc :type it))
                                                                (cdr (assoc :founded it)))
                        )
                        (:spaceship (format stream "~d,~a,~d,~a,~a" (cdr (assoc :id it))
                                                                (cdr (assoc :name it))
                                                                (cdr (assoc :company it))
                                                                (cdr (assoc :mission-type it))
                                                                (cdr (assoc :first-launch-date it)))
                        )
                        (t (error "Invalid keyword"))
                    )
                ) (subseq data 1))
            )
        )
    )
)

(defun add-row (data row keyword &key (assoc-pos nil) (assoc-neg nil))
    (if (not (listp data))
        (error "Invalid data")
    )
    (if (not (listp row))
        (error "Invalid row")
    )
    (if (not (keywordp keyword))
        (error "Invalid keyword")
    )
    (let ((exists nil))
        (loop for r in data do
            (if (= (cdr (assoc :id r)) (car row))
                (setq exists t)
            )
        )
        (if (not exists)
            (let ((assoc-lst nil))
                (case keyword
                    (:company (if (= (length row) 5)
                            (progn
                                (setq assoc-lst nil)
                                (setq assoc-lst (acons :id (car row) assoc-lst))
                                (setq assoc-lst (acons :name (nth 1 row) assoc-lst))
                                (setq assoc-lst (acons :country (nth 2 row) assoc-lst))
                                (setq assoc-lst (acons :type (nth 3 row) assoc-lst))
                                (setq assoc-lst (acons :founded (nth 4 row) assoc-lst))
                            )
                            (error "Invalid company data")
                        )
                    )
                    (:spaceship (if (= (length row) 5)
                            (progn 
                                (setq assoc-lst nil)
                                (setq assoc-lst (acons :id (car row) assoc-lst))
                                (setq assoc-lst (acons :name (nth 1 row) assoc-lst))
                                (setq assoc-lst (acons :company (nth 2 row) assoc-lst))
                                (setq assoc-lst (acons :mission-type (nth 3 row) assoc-lst))
                                (setq assoc-lst (acons :first-launch-date (nth 4 row) assoc-lst))
                            )
                            (error "Invalid spaceship data")
                        )
                    )
                    (t (error "Invalid keyword"))
                )
                (let ((result t))
                    (if (and (null assoc-pos) (null assoc-neg))
                        (setq result t)
                        (loop for val in assoc-lst do
                            (let ((pos-val (assoc (car val) assoc-pos)) (neg-val (assoc (car val) assoc-neg)))
                                (if (and pos-val (not (equalp (cdr val) (cdr pos-val))))
                                    (setq result nil)
                                )
                                (if (and neg-val (equalp (cdr val) (cdr neg-val)))
                                    (setq result nil)
                                )
                                (if (not result)
                                    (return)
                                )
                            )
                        )
                    )
                    (if result
                        (setq data (append data (list assoc-lst)))
                    )
                )
            )
        )
    )
    data
)

(defun delete-row (data id keyword)
    (if (not (listp data))
        (error "Invalid data")
    )
    (if (not (integerp id))
        (error "Invalid ID")
    )
    (if (not (keywordp keyword))
        (error "Invalid keyword")
    )
    (if (not (or (eq keyword :company) (eq keyword :spaceship)))
        (error "Invalid keyword")
    )
    (let ((exists nil))
        (loop for r in data do
            (if (= (cdr (assoc :id r)) id)
                (setq exists t)
            )
        )
        (if exists
            (setq data (remove-if (lambda (x) (= (cdr (assoc :id x)) id)) data))
        )
    )
    data
)

(defun convert-assoc-hash (lst)
    (let ((result '()))
        (loop for row in lst do
            (let ((hash (make-hash-table)))
                (loop for val in row do
                    (setf (gethash (intern (symbol-name (car val))) hash) (cdr val))
                )
                (setq result (append result (list hash)))
            )
        )
        result
    )
)

(defun print-data-hash (data keyword &key (text nil))
    (if (not (listp data))
        (error "Invalid data")
    )
    (if (and text (not (stringp text)))
        (error "Invalid text")
    )
    (if text
        (format t "~a~%" text)
    )
    (case keyword
        (:company (format t "~3a ~16a ~12a ~16a ~a~%" "ID" "Name" "Country" "Type" "Founded"))
        (:spaceship (format t "~3a ~16a ~7a ~16a ~a~%" "ID" "Name" "Company" "Mission Type" "First Launch Date"))
        (t (error "Invalid keyword"))
    )
    (loop for row in data do
        (case keyword
            (:company (format t "~3d ~16a ~12a ~16a ~a" (gethash 'id row)
                                                (gethash 'name row)
                                                (gethash 'country row)
                                                (gethash 'type row)
                                                (gethash 'founded row))
            )
            (:spaceship (format t "~3d ~16a ~7d ~16a ~a" (gethash 'id row)
                                                    (gethash 'name row)
                                                    (gethash 'company row)
                                                    (gethash 'mission-type row)
                                                    (gethash 'first-launch-date row))
            )
            (t (error "Invalid keyword"))
        )
        (format t "~%")
    )
    (format t "~%")
)
```
### Тестові набори та утиліти
```lisp
(defun check-output (fn name &key (first nil))
  (let ((captured-output
         (with-output-to-string (*standard-output*)
           (funcall fn))) (buffer ""))
        (if first
            (with-open-file (stream (format nil "./~a-output.txt" name) :direction :output :if-exists :supersede)
                (format stream "~a" captured-output)
            ))
        (with-open-file (stream (format nil "./~a-output.txt" name) :direction :input :if-does-not-exist :error)
            (do ((line (read-line stream nil) (read-line stream nil)))
                ((null line) nil)
                (setq buffer (format nil "~a~a~%" buffer line))
            )
        )
        (format t "~:[FAILED~;passed~]... ~a~%" (string= captured-output buffer) name))
)

(defun check-saved-file (file-name name &key (first nil))
    (let ((buffer1 "") (buffer2 ""))
        (with-open-file (stream file-name :direction :input :if-does-not-exist :error)
            (do ((line (read-line stream nil) (read-line stream nil)))
                ((null line) nil)
                (setq buffer1 (format nil "~a~a" buffer1 line))
            )
        )
        (if first
            (with-open-file (stream (format nil "./~a-output.txt" name) :direction :output :if-exists :supersede)
                (format stream "~a" buffer1)
            ))
        (with-open-file (stream (format nil "./~a-output.txt" name) :direction :input :if-does-not-exist :error)
            (do ((line (read-line stream nil) (read-line stream nil)))
                ((null line) nil)
                (setq buffer2 (format nil "~a~a" buffer2 line))
            )
        )
        (format t "~:[FAILED~;passed~]... ~a~%" (string= buffer1 buffer2) name)
    )
)

(defun tests (file-name-companies file-name-spaceships)
    (format t "Lab 5~%")
    (let ((companies-check (select file-name-companies :company))
          (spaceships-check (select file-name-spaceships :spaceship))
          (companies-data nil)
          (spaceships-data nil)
          (filtered-companies-1 nil)
          (filtered-companies-2 nil)
          (filtered-companies-hash nil))
        (setq companies-data (funcall companies-check))
        (check-output (lambda () (print-data companies-data :company)) "test1")
        (setq spaceships-data (funcall spaceships-check))
        (check-output (lambda () (print-data spaceships-data :spaceship)) "test2")
        (check-output (lambda () (print-object-t 1 spaceships-data companies-data :spaceship)) "test3")
        (check-output (lambda () (print-object-t 4 spaceships-data companies-data :spaceship)) "test4")
        (check-output (lambda () (print-object-t 20 spaceships-data companies-data :spaceship)) "test5")
        (check-output (lambda () (print-object-t 1 spaceships-data companies-data :company)) "test6")
        (check-output (lambda () (print-object-t 9 spaceships-data companies-data :company)) "test7")
        (check-output (lambda () (print-object-t 20 spaceships-data companies-data :company)) "test8")
        (setq filtered-companies-1 (funcall companies-check :start 5 :end 12))
        (setq filtered-companies-2 (funcall companies-check :start 5 :end 12
                    :assoc-pos (acons :type "Private" nil)
                    :assoc-neg (acons :country "New Zealand" nil)))
        (check-output (lambda () (print-data filtered-companies-1 :company :text "Filtered companies 1:")) "test9")
        (setq filtered-companies-1 (add-row filtered-companies-1 '(13 "Company 13" "Australia" "Private" "2023") :company))
        (setq filtered-companies-1 (add-row filtered-companies-1 '(13 "Company 14" "Australia" "Private" "2023") :company))
        (setq filtered-companies-1 (delete-row filtered-companies-1 7 :company))
        (setq filtered-companies-1 (delete-row filtered-companies-1 16 :company))
        (check-output (lambda () (print-data filtered-companies-1 :company :text "Filtered companies 1:")) "test10")
        (check-output (lambda () (print-data filtered-companies-2 :company :text "Filtered companies 2:")) "test11")
        (save-data filtered-companies-1 "./filtered-companies-1.csv" :company)
        (check-saved-file "./filtered-companies-1.csv" "test12")
        (save-data filtered-companies-2 "./filtered-companies-2.csv" :company)
        (check-saved-file "./filtered-companies-2.csv" "test13")
        (setq filtered-companies-hash (convert-assoc-hash filtered-companies-1))
        (check-output (lambda () (print-data-hash filtered-companies-hash :company :text "Filtered companies hash:")) "test14")
))
```
### Тестування
```lisp
* (tests "./companies.csv" "./spaceships.csv")
Lab 5
passed... test1
passed... test2
passed... test3
passed... test4
passed... test5
passed... test6
passed... test7
passed... test8
passed... test9
passed... test10
passed... test11
passed... test12
passed... test13
passed... test14
NIL
```