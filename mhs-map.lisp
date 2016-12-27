;;;; mhs-map.lisp

(in-package #:mhs-map)

;;; "mhs-map" goes here. Hacks and glory await!

(defvar *my-acceptor* nil)

(defun start (&key debugp
                (username "")
                (password "")
                (pg-database "mhs_map")
                (pg-user "postgres")
                (pg-password "")
                (pg-host "localhost")
                (http-port 4242)
                (http-private-host "127.0.0.1")
                (http-private-port 4242)
                (http-private-protocol :http)
                (http-session-max-time 10800)
                (static-uri-base #u"http://127.0.0.1:4242/mhs-map/static/")
                (mhs-base-uri #u"http://www.mhs.mb.ca/docs/sites/")
                (mhs-sites-uri #u"http://www.mhs.mb.ca/docs/sites/index.shtml"))
  (unless *my-acceptor*
    (setf hunchentoot:*catch-errors-p* (not debugp)
          hunchentoot:*show-lisp-errors-p* debugp
          hunchentoot:*show-lisp-backtraces-p* debugp
          hunchentoot:*tmp-directory* #p"/var/tmp/hunchentoot/") ; /tmp too small
    (setf *username* username)
    (setf *password* password)
    (setf *pg-database* pg-database)
    (setf *pg-user* pg-user)
    (setf *pg-password* pg-password)
    (setf *pg-host* pg-host)
    (setf *http-port* http-port)
    (setf *http-private-host* http-private-host)
    (setf *http-private-port* http-private-port)
    (setf *http-private-protocol* http-private-protocol)
    (setf *http-session-max-time* http-session-max-time)
    (setf *static-uri-base* static-uri-base)
    (setf *mhs-base-uri* mhs-base-uri)
    (setf *mhs-sites-uri* mhs-sites-uri)
    (push (hunchentoot:create-folder-dispatcher-and-handler
           "/mhs-map/static/"
           (merge-pathnames #p"static/" app-config:*base-directory*))
          hunchentoot:*dispatch-table*)
    (setf *my-acceptor*
	  (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor
					    :port *http-port*)))))

(defun stop ()
  (when *my-acceptor*
    (hunchentoot:stop *my-acceptor*)
    (setf hunchentoot:*dispatch-table* (last hunchentoot:*dispatch-table*))
    (setf *pg-database* nil)
    (setf *pg-user* nil)
    (setf *pg-password* nil)
    (setf *pg-host* nil)
    (setf *http-port* nil)
    (setf *http-private-host* nil)
    (setf *http-private-port* nil)
    (setf *http-private-protocol* nil)
    (setf *http-session-max-time* nil)
    (setf *static-uri-base* nil)
    (setf *mhs-base-uri* nil)
    (setf *mhs-sites-uri* nil)
    (setf *my-acceptor* nil)))

(defun set-handler (signo handler)
  (sb-sys:enable-interrupt signo
                           #'(lambda (signo context info)
                               (declare (ignore context info))
                               (signal-handler signo))))

(defun signal-handler (signo)
  (format t "~A received~%" signo)
  (sb-ext:quit :unix-status 1))

(defun main (argv)
  (declare (ignore argv))
  (set-handler sb-posix:sigabrt #'signal-handler)
  (set-handler sb-posix:sighup #'signal-handler)
  (set-handler sb-posix:sigint #'signal-handler)
  (set-handler sb-posix:sigterm #'signal-handler)
  (start :username (getenv "USERNAME")
         :password (getenv "PASSWORD")
         :pg-database (getenv "PGDATABASE")
         :pg-user (getenv "PGUSER")
         :pg-password (getenv "PGPASSWORD")
         :pg-host (getenv "PGHOST")
         :http-port (getenv-integer "HTTPPORT")
         :http-private-host (getenv "HTTPPRIVATEHOST")
         :http-private-port (getenv-integer "HTTPPRIVATEPORT")
         :http-private-protocol (getenv-keyword "HTTPPRIVATEPROTOCOL")
         :http-session-max-time (getenv-integer "HTTPSESSIONMAXTIME")
         :static-uri-base (getenv-uri "STATICURIBASE")
         :mhs-base-uri (getenv-uri "MHSBASEURI")
         :mhs-sites-uri (getenv-uri "MHSSITESURI"))
  (loop (sleep 1)))
