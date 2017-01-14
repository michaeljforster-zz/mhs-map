;;;; map.lisp

(in-package #:mhs-map)

(defun compile-paren-file ()
  (let ((paren-filespec (merge-pathnames #p"map.paren" app-config:*base-directory*))
        (js-filespec (merge-pathnames #p"static/mhs-map/js/map.js" app-config:*base-directory*)))
    (with-open-file (stream js-filespec :direction :output :if-exists :supersede)
      (let ((ps:*parenscript-stream* stream))
        (ps:ps-compile-file paren-filespec)))))

(defun render-map (&optional (stream *standard-output*))
  (cl-who:with-html-output (stream nil :prologue t)
    (:html
     (:head
      (:meta :name "viewport" :content "initial-scale=1.0, user-scalable=no")
      (:title (cl-who:esc (concatenate 'string *app-title* ": Map")))
      (:link :rel "stylesheet" :type "text/css" :href (static-uri "mhs-map/css/reset.css"))
      (:link :rel "stylesheet" :type "text/css" :href (static-uri "mhs-map/css/map.css"))
      (:script :type "text/javascript" :src "static/vendor/jquery-3.1.1.js")
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
                    (defvar *features-within-bounds-uri* ,(princ-to-string *features-within-bounds-uri*))
                    (defvar *features-within-distance-uri* ,(princ-to-string *features-within-distance-uri*))))))
      (:script :type "text/javascript" :src (static-uri "mhs-map/js/map.js"))
      (:script :type "text/javascript"
               (cl-who:str
                (ps:ps
                  (ps:chain google maps event (add-dom-listener window "load" #'initialize))))))
     (:body
      (:button :id "list-button" "Display List")
      (:button :id "map-button" "Display Map")
      (:div :id "list-view")
      (:div :id "map-canvas")))))

(hunchentoot:define-easy-handler (handle-map :uri (princ-to-string *map-uri*))
    ()
  (hunchentoot:no-cache)
  (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
  (with-output-to-string (stream)
    (render-map stream)))
