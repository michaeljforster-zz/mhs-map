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

(defun render-map (municipality-names &optional (stream *standard-output*))
  (cl-who:with-html-output (stream nil :prologue t)
    (:html
     (:head
      (:meta :charset "utf-8")
      (:meta :http-equiv "X-UA-Compatible" :content "IE=edge")
      (:meta :name "viewport" :content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no")
      (:title (cl-who:esc (concatenate 'string *app-title* ": Map")))
      (:link :rel "stylesheet" :type "text/css" :href (static-uri "vendor/bootstrap-3.3.7-dist/css/bootstrap.min.css"))
      (:link :rel "stylesheet" :type "text/css" :href (static-uri "vendor/bootstrap-select-1.12.1-dist/css/bootstrap-select.min.css"))
      (:link :rel "stylesheet" :type "text/css" :href (static-uri "mhs-map/css/map.css"))
      (:script :type "text/javascript" :src (static-uri "vendor/jquery-3.1.1.js"))
      (:script :type "text/javascript" :src (static-uri "vendor/bootstrap-3.3.7-dist/js/bootstrap.min.js"))
      (:script :type "text/javascript" :src (static-uri "vendor/bootstrap-select-1.12.1-dist/js/bootstrap-select.min.js"))
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
            (:nav :class "navbar navbar-default"
                  (:div :class "navbar-header"
                        (:button :type "button"
                                 :class "navbar-toggle collapsed"
                                 :data-toggle "collapse"
                                 :data-target "#mhs-navbar"
                                 :aria-expanded "false"
                                 (:span :class "sr-only" "Toggle Navigation")
                                 (:span :class "icon-bar")
                                 (:span :class "icon-bar")
                                 (:span :class "icon-bar"))
                        (:button :type "button"
                                 :class "btn btn-default navbar-btn"
                                 :id "mhs-show-map-btn"
                                 "Show Map")
                        (:button :type "button"
                                 :class "btn btn-default navbar-btn"
                                 :id "mhs-show-list-btn"
                                 "Show List"))
                  (:div :class "collapse navbar-collapse"
                        :id "mhs-navbar"
                        (:form :class "navbar-form navbar-right"
                               (:div :class "form-group"
                                     (:select :class "selectpicker"
                                              :id "mhs-filter-within-input"
                                              (:option :value "map-area" "Within map area")
                                              (:optgroup :label "As I move"
                                                         (:option :value "100" "Within 100 m of me")
                                                         (:option :value "1000" "Within 1 km of me")
                                                         (:option :value "10000" "Within 10 km of me")
                                                         (:option :value "100000" "Within 100 km of me")
                                                         (:option :value "1000000" "Within 1000 km of me"))
                                              (:optgroup :label "Within municipality"
                                                         (dolist (m-name municipality-names)
                                                           (cl-who:htm
                                                            (:option :value (cl-who:escape-string m-name)
                                                                     :title (cl-who:escape-string (concatenate 'string
                                                                                                               "Within "
                                                                                                               m-name))
                                                                     (cl-who:esc m-name)))))))

                               (:div :class "form-group"
                                     (:select :class "selectpicker"
                                              :id "mhs-filter-by-site-type-input"
                                              (dolist (st-name (cons "All site types"
                                                                     (sort (copy-list *site-type-names*) #'string<=)))
                                                (cl-who:htm
                                                 (:option :value (cl-who:escape-string st-name)
                                                          (cl-who:esc st-name))))))

                               (:div :class "form-group"
                                     (:select :class "selectpicker"
                                              :id "mhs-filter-by-designation-input"
                                              :multiple t
                                              :title "Has designations"
                                              (:option :value "National" "National")
                                              (:option :value "Provincial" "Provincial")
                                              (:option :value "Municipal" "Municipal")))

                               (:div :class "form-group"
                                     (:input :type "text"
                                             :class "form-control"
                                             :placeholder "keywords")))))
            (:div :id "mhs-content"
                  ;; Manipulate visibility with Bootstrap CSS classes rather than DO .show() and .hide().
                  (:div :id "mhs-map-widget")
                  (:div :class "hidden" :id "mhs-list-widget")))))))

(hunchentoot:define-easy-handler (handle-map :uri (princ-to-string *map-uri*))
    ()
  (hunchentoot:no-cache)
  (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
  (with-database-connection
    (with-output-to-string (stream)
      (render-map (select-municipality-names)
                  stream))))
