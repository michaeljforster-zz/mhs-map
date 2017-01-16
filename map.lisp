;;;; map.lisp

(in-package #:mhs-map)

(defun compile-paren-files ()
  (compile-paren-file "util")
  (compile-paren-file "model")
  (compile-paren-file "widget")
  (compile-paren-file "map"))

(defun compile-paren-file (filename)
  (let ((paren-filespec (merge-pathnames (make-pathname :name filename :type "paren") app-config:*base-directory*))
        (js-filespec (merge-pathnames (make-pathname :name filename :type "js")
                                      (merge-pathnames "static/mhs-map/js/"
                                                        app-config:*base-directory*))))
    (with-open-file (stream js-filespec :direction :output :if-exists :supersede)
      (let ((ps:*parenscript-stream* stream))
        (ps:ps-compile-file paren-filespec)))))

(defun render-map (&optional (stream *standard-output*))
  (cl-who:with-html-output (stream nil :prologue t)
    (:html
     (:head
      (:meta :charset "utf-8")
      (:meta :http-equiv "X-UA-Compatible" :content "IE=edge")
      (:meta :name "viewport" :content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no")
      (:title (cl-who:esc (concatenate 'string *app-title* ": Map")))
      (:link :rel "stylesheet" :type "text/css" :href (static-uri "vendor/bootstrap-3.3.7-dist/css/bootstrap.min.css"))
      (:link :rel "stylesheet" :type "text/css" :href (static-uri "mhs-map/css/map.css"))
      (:script :type "text/javascript" :src (static-uri "vendor/jquery-3.1.1.js"))
      (:script :type "text/javascript" :src (static-uri "vendor/bootstrap-3.3.7-dist/js/bootstrap.min.js"))
      (:script :type "text/javascript" :src "https://maps.googleapis.com/maps/api/js?v=3&sensor=false")
      (:script :type "text/javascript"
               (cl-who:str
                (ps:ps*
                 `(progn
                    (defvar *default-center* (ps:new (ps:chain google maps (-lat-lng ,@*default-center*))))
                    (defvar *default-zoom* ,*default-zoom*)
                    (defvar *geolocation-options*
                      (ps:create
                       :enable-high-accuracy 'true
                       :maximum-age 10000
                       :timeout 27000))
                    (defvar *mhs-base-uri* ,(princ-to-string (puri:uri *mhs-base-uri*)))
                    (defvar *icons-uri* ,(princ-to-string (static-uri "mhs-map/images/icons/")))
                    (defvar *features-uri* ,(princ-to-string *features-uri*))))))
      (:script :type "text/javascript" :src (static-uri "mhs-map/js/util.js"))
      (:script :type "text/javascript" :src (static-uri "mhs-map/js/model.js"))
      (:script :type "text/javascript" :src (static-uri "mhs-map/js/widget.js"))
      (:script :type "text/javascript" :src (static-uri "mhs-map/js/map.js"))
      (:script :type "text/javascript"
               (cl-who:str
                (ps:ps
                  (ps:chain google maps event (add-dom-listener window "load" #'initialize))))))
     (:body
      (:div :class "fluid-container"
            (:div :class "row"
                  (:div :class "col-md-12"
                        (:button :id "list-button" "Display List")
                        (:button :id "map-button" "Display Map")))
            (:div :id "list-view")
            (:div :id "map-canvas"))))))

(hunchentoot:define-easy-handler (handle-map :uri (princ-to-string *map-uri*))
    ()
  (hunchentoot:no-cache)
  (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
  (with-output-to-string (stream)
    (render-map stream)))
