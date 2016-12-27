;;;; mhs-map.lisp

(in-package #:mhs-map)

;;; "mhs-map" goes here. Hacks and glory await!

(defvar *my-acceptor* nil)

(defun start (&key debugp)
  (unless *my-acceptor*
    (setf hunchentoot:*catch-errors-p* (not debugp)
          hunchentoot:*show-lisp-errors-p* debugp
          hunchentoot:*show-lisp-backtraces-p* debugp
          hunchentoot:*tmp-directory* #p"/var/tmp/hunchentoot/") ; /tmp too small
    (push (hunchentoot:create-folder-dispatcher-and-handler
           "/mhs-map/static/"
           (merge-pathnames #p"static/" app-config:*base-directory*))
          hunchentoot:*dispatch-table*)
    (setf *my-acceptor*
	  (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor
					    :port app-config:*http-port*)))))

(defun stop ()
  (when *my-acceptor*
    (hunchentoot:stop *my-acceptor*)
    (setf hunchentoot:*dispatch-table* (last hunchentoot:*dispatch-table*))
    (setf *my-acceptor* nil)))

(defun set-handler (signo handler)
  (sb-sys:enable-interrupt signo
                           #'(lambda (signo context info)
                               (declare (ignore context info))
                               (signal-handler signo))))

(defun signal-handler (signo)
  (format t "~A received~%" signo)
  (sb-ext:quit :unix-status 1))

;;; For buildapp startup

(defun main (argv)
  (declare (ignore argv))
  (set-handler sb-posix:sigabrt #'signal-handler)
  (set-handler sb-posix:sighup #'signal-handler)
  (set-handler sb-posix:sigint #'signal-handler)
  (set-handler sb-posix:sigterm #'signal-handler)
  (start)
  (loop (sleep 1)))
