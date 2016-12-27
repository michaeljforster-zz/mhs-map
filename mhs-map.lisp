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
  (when (null *my-acceptor*)
    (if debugp
        (setf hunchentoot:*catch-errors-p* nil
              hunchentoot:*show-lisp-errors-p* t
              hunchentoot:*show-lisp-backtraces-p* t)
        (setf hunchentoot:*catch-errors-p* t
              hunchentoot:*show-lisp-errors-p* nil
              hunchentoot:*show-lisp-backtraces-p* nil))
    (setf *username* username
          *password* password
          *pg-database* pg-database
          *pg-user* pg-user
          *pg-password* pg-password
          *pg-host* pg-host
          *http-port* http-port
          *http-private-host* http-private-host
          *http-private-port* http-private-port
          *http-private-protocol* http-private-protocol
          *http-session-max-time* http-session-max-time
          *static-uri-base* static-uri-base
          *mhs-base-uri* mhs-base-uri
          *mhs-sites-uri* mhs-sites-uri)
    (push (hunchentoot:create-folder-dispatcher-and-handler
           "/mhs-map/static/"
           (merge-pathnames #p"static/" app-config:*base-directory*))
          hunchentoot:*dispatch-table*)
    (setf hunchentoot:*tmp-directory* #p"/var/tmp/hunchentoot/")
    (setf *my-acceptor*
	  (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor
					    :port *http-port*)))))

(defun stop ()
  (unless (null *my-acceptor*)
    (hunchentoot:stop *my-acceptor*)
    (setf hunchentoot:*dispatch-table* (last hunchentoot:*dispatch-table*))
    (setf *pg-database* nil
          *pg-user* nil
          *pg-password* nil
          *pg-host* nil
          *http-port* nil
          *http-private-host* nil
          *http-private-port* nil
          *http-private-protocol* nil
          *http-session-max-time* nil
          *static-uri-base* nil
          *mhs-base-uri* nil
          *mhs-sites-uri* nil)
    (setf hunchentoot:*tmp-directory* nil)
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
