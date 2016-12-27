;;;; import.lisp

(in-package #:mhs-map)

(defun parse-coordinate (string)
  (and (string/= string "") (parse-number:parse-real-number string)))

(defun parse-designation (string)
  (and (string/= string "") string))

(defun parse-sitetypes (string)
  (and (string/= string "")
       (mapcar #'(lambda (s) (parse-integer s :junk-allowed t))
	       (split-sequence:split-sequence #\, string))))

(defun read-csv-site (stream)
  (let ((csv (fare-csv:read-csv-line stream)))
    (when csv
      ;; Optional lng handles empty final CSV field
      (destructuring-bind (site num n p m plq sitetypes describe location number keyword file lat &optional (lng ""))
          csv
        (make-csv-site :site site
                       :num (parse-integer num)
                       :n (parse-designation n)
                       :p (parse-designation p)
                       :m (parse-designation m)
                       :plq plq
                       :sitetypes (parse-sitetypes sitetypes)
                       :describe describe
                       :location location
                       :number number
                       :keyword keyword
                       :file file
                       :lat (parse-coordinate lat)
                       :lng (parse-coordinate lng))))))
