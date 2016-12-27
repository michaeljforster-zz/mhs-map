;;;; specials.lisp

(in-package #:mhs-map)

;;; Text

(defparameter *app-title* "Historic Sites of Manitoba")

(defparameter *app-copyright*
  "Copyright 2012-2014 Manitoba Historical Society. Copyright 2012-2014 Shared Logic Inc.")

;;; Map defaults

(defparameter *default-lat-lng* (list 51.4 -98.4)) ; rough center of southern MB
(defparameter *default-zoom* 6) ; 8 okay for desktop, 7 better for iPad, 6 better for Android/iPhone

;;; URIs

(defparameter *admin-login-uri* #u"/mhs-map/admin-login")
(defparameter *admin-logout-uri* #u"/mhs-map/admin-logout")
(defparameter *admin-import-uri* #u"/mhs-map/admin-import")
(defparameter *search-uri* #u"/mhs-map/search")
(defparameter *features-json-uri* #u"/mhs-map/features.json")
(defparameter *map-uri* #u"/mhs-map/map")

;;; Encoding

(defparameter *import-from-external-format* :windows-1252)
(defparameter *import-to-external-format* :utf-8)
