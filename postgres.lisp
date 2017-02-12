;;;; postgres.lisp

(in-package #:mhs-map)

(defun prepare-and-execute (connection sql parameters &optional (row-reader 'cl-postgres:ignore-row-reader))
  (cl-postgres:prepare-query connection "" sql)
  (cl-postgres:exec-prepared connection "" parameters row-reader))
