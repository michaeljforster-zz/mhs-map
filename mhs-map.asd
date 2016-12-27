;;;; mhs-map.asd

(asdf:defsystem #:mhs-map
  :description "MHS Fast, Portable, User-Configurable Map of Manitoba Historic Sites"
  :author "Michael J. Forster <mike@sharedlogic.ca>"
  :license "MIT"
  :version "0.2"
  :serial t
  :depends-on (#:sb-posix
               #:swank
               #:alexandria
               #:flexi-streams
               #:fare-csv
               #:parse-number
	       #:split-sequence
               #:cl-json
               #:postmodern
               #:puri
               #:hunchentoot
               #:cl-who
               #:sli-hunchentools
               #:parenscript)
  :components ((:file "package")
               (:file "util")
               (:file "specials")
               (:file "structs")
               (:file "database")
               (:file "encoding")
               (:file "import")
               (:file "geojson")
               (:file "features")
               (:file "admin-ui")
               (:file "search")
               (:file "map")
               (:file "mhs-map")))

(defpackage #:app-config
  (:export #:*base-directory*
           #:*username*
           #:*password*
           #:*mhs-base-uri*
           #:*mhs-sites-uri*
           #:*pg-database*
           #:*pg-user*
           #:*pg-password*
           #:*pg-host*
           #:*http-port*
           #:*http-private-host*
           #:*http-private-port*
           #:*http-private-protocol*
           #:*http-session-max-time*
           #:*static-uri-base*
           #:*swank-port*))

(defun app-config::getenv (name)
  (sb-unix::posix-getenv name))

(defparameter app-config:*base-directory* 
  (make-pathname :name nil :type nil :defaults *load-truename*))

(defparameter app-config:*username*
  (app-config::getenv "USERNAME"))

(defparameter app-config:*password*
  (app-config::getenv "PASSWORD"))

(defparameter app-config:*mhs-base-uri*
  (app-config::getenv "MHSBASEURI"))

(defparameter app-config:*mhs-sites-uri*
  (app-config::getenv "MHSSITESURI"))

(defparameter app-config:*pg-database*
  (app-config::getenv "PGDATABASE"))

(defparameter app-config:*pg-user*
  (app-config::getenv "PGUSER"))

(defparameter app-config:*pg-password*
  (app-config::getenv "PGPASSWORD"))

(defparameter app-config:*pg-host*
  (app-config::getenv "PGHOST"))

(defparameter app-config:*http-port*
  (parse-integer (app-config::getenv "HTTPPORT")))

(defparameter app-config:*http-private-host*
  (app-config::getenv "HTTPPRIVATEHOST"))

(defparameter app-config:*http-private-port*
  (parse-integer (app-config::getenv "HTTPPRIVATEPORT")))

(defparameter app-config:*http-private-protocol*
  (intern (string-upcase (app-config::getenv "HTTPPRIVATEPROTOCOL")) :keyword))

(defparameter app-config:*http-session-max-time*
  (parse-integer (app-config::getenv "HTTPSESSIONMAXTIME")))

(defparameter app-config:*static-uri-base*
  (app-config::getenv "STATICURIBASE"))

(defparameter app-config:*swank-port*
  (parse-integer (app-config::getenv "SWANKPORT")))
