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

(defun render-search-widget (municipality-names
                             site-type-names
                             &optional (stream *standard-output*))
  (cl-who:with-html-output (stream)
    (:div :id "mhs-search-widget" :class "panel panel-default"
          (:div :class "panel-heading"
                (:h3 :class "panel-title" "Search"))
          (:div :class "panel-body"
                (:div :class "form-group"
                      (:select :class "selectpicker"
                               :id "mhs-filter-within-input"
                               :data-width "auto"
                               (:option :value "map-area" "Within map area")
                               (:optgroup :label "As I move, within"
                                          (:option :value "100" :title "Within 100 m of me" "100 m of me")
                                          (:option :value "1000" :title "Within 1 km of me" "1 km of me")
                                          (:option :value "10000" :title "Within 10 km of me" "10 km of me")
                                          (:option :value "100000" :title "Within 100 km of me" "100 km of me")
                                          (:option :value "1000000" :title "Within 1000 km of me" "1000 km of me"))
                               (:optgroup :label "Within municipality"
                                          (dolist (m-name municipality-names)
                                            (cl-who:htm
                                             (:option :value (cl-who:escape-string m-name)
                                                      :title (cl-who:escape-string
                                                              (concatenate 'string
                                                                           "Within "
                                                                           m-name))
                                                      (cl-who:esc m-name)))))))
                (:div :class "form-group"
                      (:select :class "selectpicker"
                               :data-width "auto"
                               :id "mhs-st-name-input"
                               (dolist (x (cons (cons "" "All site types")
                                                (sort (mapcar #'(lambda (x) (cons x x)) site-type-names) #'string<= :key #'car)))
                                 (cl-who:htm
                                  (:option :value (cl-who:escape-string (car x))
                                           (cl-who:esc (cdr x)))))))
                (:div :class "form-group"
                      (:select :class "selectpicker"
                               :id "mhs-designation-input"
                               :multiple t
                               :title "Has designations"
                               (:option :value "National" "National")
                               (:option :value "Provincial" "Provincial")
                               (:option :value "Municipal" "Municipal")))
                (:div :class "form-group form-inline"
                      (:input :type "text" :class "form-control" :placeholder "keyword" :id "mhs-keyword1-input"))
                (:div :class "form-group form-inline"
                      (:select :class "selectpicker"
                               :data-width "auto"
                               :id "mhs-op2-input"
                               (:option :value "AND" "AND")
                               (:option :value "NOT" "NOT")
                               (:option :value "OR" "OR"))
                      (:input :type "text" :class "form-control"
                              :placeholder "keyword" :id "mhs-keyword2-input"))
                (:div :class "form-group form-inline"
                      (:select :class "selectpicker"
                               :data-width "auto"
                               :id "mhs-op3-input"
                               (:option :value "AND" "AND")
                               (:option :value "NOT" "NOT")
                               (:option :value "OR" "OR"))
                      (:input :type "text" :class "form-control"
                              :placeholder "keyword" :id "mhs-keyword3-input"))
                (:div :class "form-group"
                      (:button :class "btn btn-primary" :id "mhs-update-map-btn" "Update Map"))))))

(defun render-map (municipality-names
                   site-type-names
                   &optional (stream *standard-output*))
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
                    (defvar *municipality-mode-zoom* ,*municipality-mode-zoom*)
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
      (:div :class "fluid-container" :id "mhs-container"
            (:div :class "row" :id "mhs-page-header-row"
                  (:div :class "col-md-12"
                        (:h1 (cl-who:esc *app-title*))))
            (:div :class "row" :id "mhs-nav-row"
                  (:div :class "col-md-12"
                        (:ul :class "nav nav-tabs"
                             (:li :role "presentation" :id "mhs-map-tab"
                                  (:a :href "#" :id "mhs-map-btn" "Map"))
                             (:li :role "presentation" :id "mhs-list-tab"
                                  (:a :href "#" :id "mhs-list-btn" "List"))
                             (:li :role "presentation" :id "mhs-search-tab" :class "active"
                                  (:a :href "#" :id "mhs-search-btn" "Search")))))
            ;; NOTE: We specify the widgets in this order so that the
            ;; map widget will be the default when stacked.
            (:div :class "row" :id "mhs-content-row"
                  (:div :class "col-md-7 mhs-col" :id "mhs-map-col"
                        (:div :id "mhs-map-widget"))
                  (:div :class "col-md-2 mhs-col" :id "mhs-list-col"
                        (:div :id "mhs-list-widget"))
                  (:div :class "col-md-3 mhs-col" :id "mhs-search-col"
                        (render-search-widget municipality-names
                                              site-type-names
                                              stream))))))))

(hunchentoot:define-easy-handler (handle-map :uri (princ-to-string *map-uri*))
    ()
  (hunchentoot:no-cache)
  (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
  (with-database-connection
    (with-output-to-string (stream)
      (render-map (select-municipality-names)
                  *site-type-names*
                  stream))))
