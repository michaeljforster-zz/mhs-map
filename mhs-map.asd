;;;; mhs-map.asd

(asdf:defsystem #:mhs-map
  :description "MHS Fast, Portable, User-Configurable Map of Manitoba Historic Sites"
  :author "Michael J. Forster <mike@sharedlogic.ca>"
  :license "MIT"
  :version "0.2"
  :serial t
  :depends-on (#:sb-posix
               #:alexandria
               #:wu-decimal
               #:flexi-streams
               #:fare-csv
               #:parse-number
	       #:split-sequence
               #:cl-json
               #:postmodern
               #:postmodernity
               #:puri
               #:hunchentoot
               #:cl-who
               #:hunchentools
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
  (:export #:*base-directory*))

(defparameter app-config:*base-directory* 
  (make-pathname :name nil :type nil :defaults *load-truename*))
