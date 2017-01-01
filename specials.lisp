;;;; specials.lisp

(in-package #:mhs-map)

;;; Text

(defparameter *app-title* "Historic Sites of Manitoba")

(defparameter *app-copyright*
  "Copyright 2012-2014 Manitoba Historical Society. Copyright 2012-2014 Shared Logic Inc.")

;;; Map defaults

(defparameter *default-center* (list 51.4 -98.4)) ; rough center of southern MB
(defparameter *default-zoom* 6) ; 8 okay for desktop, 7 better for iPad, 6 better for Android/iPhone

;;; URIs

(defparameter *admin-login-uri* #u"/mhs-map/admin-login")
(defparameter *admin-logout-uri* #u"/mhs-map/admin-logout")
(defparameter *admin-import-uri* #u"/mhs-map/admin-import")
(defparameter *search-uri* #u"/mhs-map/search")
(defparameter *features-json-uri* #u"/mhs-map/features.json")
(defparameter *map-uri* #u"/mhs-map/map")
(defparameter *mhs-base-uri* nil)
(defparameter *mhs-sites-uri* nil)
(defparameter *static-uri-base* nil)


;;; Encoding

(defparameter *import-from-external-format* :windows-1252)
(defparameter *import-to-external-format* :utf-8)

;;; Database

(defparameter *pg-database* nil)
(defparameter *pg-user* nil)
(defparameter *pg-password* nil)
(defparameter *pg-host* nil)

;;; HTTP

(defparameter *http-port* nil)
(defparameter *http-private-host* nil)
(defparameter *http-private-port* nil)
(defparameter *http-private-protocol* nil)
(defparameter *http-session-max-time* nil)
