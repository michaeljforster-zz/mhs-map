;;;; encoding.lisp

(in-package #:mhs-map)

(defun recode (in-stream in-external-format out-stream out-external-format)
  (let ((in-stream (flexi-streams:make-flexi-stream in-stream :external-format in-external-format))
        (out-stream (flexi-streams:make-flexi-stream out-stream :external-format out-external-format)))
    (let ((buffer (make-array 4096 :element-type (flexi-streams:flexi-stream-element-type in-stream))))
      (loop for pos = (read-sequence buffer in-stream)
         while (plusp pos)
         do (write-sequence buffer out-stream :end pos)))))
