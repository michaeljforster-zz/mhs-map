;;;; structs.lisp

(in-package #:mhs-map)

(defstruct admin-user
  (username "" :read-only t))

(defstruct csv-site
  (site "" :read-only t)
  (num 0 :read-only t)
  (n "" :read-only t)
  (p "" :read-only t)
  (m "" :read-only t)
  (plq "" :read-only t)
  (sitetypes '() :read-only t)
  (describe "" :read-only t)
  (location "" :read-only t)
  (keyword "" :read-only t)
  (number "" :read-only t)
  (file "" :read-only t)
  (lat nil :read-only t)
  (lng nil :read-only t))
