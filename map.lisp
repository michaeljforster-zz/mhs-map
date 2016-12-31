;;;; map.lisp

(in-package #:mhs-map)

(defun render-map (string1
                   op2
                   string2
                   op3
                   string3
                   m-name
                   st-name
                   snd-no-p
                   spd-no-p
                   smd-no-p)
  (cl-who:with-html-output-to-string (*standard-output* nil :prologue t)
    (:html
     (:head
      (:meta :name "viewport" :content "initial-scale=1.0, user-scalable=no")
      (:title (cl-who:esc (concatenate 'string *app-title* ": Map")))
      (:link :rel "stylesheet" :type "text/css" :href (static-uri "mhs-map/css/reset.css"))
      (:link :rel "stylesheet" :type "text/css" :href (static-uri "mhs-map/css/map.css"))
      (:script :type "text/javascript" :src "/mhs-map/static/closure-library/closure/goog/base.js")
      (:script :type "text/javascript"
               (cl-who:str
                (ps:ps
                  (ps:chain goog (require "goog.dom"))
                  (ps:chain goog (require "goog.events"))
                  (ps:chain goog (require "goog.events.EventType"))
                  (ps:chain goog (require "goog.net.XhrIo")))))
      (:script :type "text/javascript" :src "https://maps.googleapis.com/maps/api/js?v=3&sensor=false")
      (:script :type "text/javascript"
               (cl-who:str
                (ps:ps*
                 `(progn
                    (defvar *default-lat-lng* (ps:new (ps:chain google maps (-lat-lng ,@*default-lat-lng*))))
                    (defvar *default-zoom* ,*default-zoom*)
                    (defvar *current-search-uri* ,(princ-to-string (puri:copy-uri *search-uri*
                                                                                  :query (format-uri-query (or string1 "")
                                                                                                           (or op2 :and)
                                                                                                           (or string2 "")
                                                                                                           (or op3 :and)
                                                                                                           (or string3 "")
                                                                                                           (or m-name "")
                                                                                                           (or st-name "")
                                                                                                           snd-no-p
                                                                                                           spd-no-p
                                                                                                           smd-no-p
                                                                                                           t))))
                    (defvar *mhs-base-uri* ,(princ-to-string (puri:uri *mhs-base-uri*)))
                    (defvar *icons-uri* ,(princ-to-string (static-uri "mhs-map/images/icons/")))
                    (defvar *features-json-uri*
                      ,(princ-to-string (puri:copy-uri *features-json-uri*
                                                       :query (format-uri-query (or string1 "")
                                                                                (or op2 :and)
                                                                                (or string2 "")
                                                                                (or op3 :and)
                                                                                (or string3 "")
                                                                                (or m-name "")
                                                                                (or st-name "")
                                                                                snd-no-p
                                                                                spd-no-p
                                                                                smd-no-p))))))))
      (:script :type "text/javascript"
               (cl-who:str
                (ps:ps

                  (defun xhr-get-json (url success-function)
                    (ps:chain goog net -xhr-io
                              (send url
                                    #'(lambda (event)
                                        (let ((xhr (ps:@ event target)))
                                          (if (ps:chain xhr (is-success))
                                              (funcall success-function
                                                       (ps:chain xhr (get-response-json)))
                                              (alert (+ "Error: "
                                                        (ps:chain xhr (get-status-text))))))))))
                  
                  (defvar *map-options* (ps:create :center *default-lat-lng* :zoom *default-zoom*))

                  (defvar *map* nil)

                  (defvar *info-window* (ps:new (ps:chain google maps (-info-window (ps:create)))))

                  (defun link-control (control-div)
                    (setf (ps:@ control-div class-name) "link-control-box")
                    (let ((control-ui (ps:chain document (create-element "div"))))
                      (setf (ps:@ control-ui class-name) "link-control-outline-box")
                      (setf (ps:@ control-ui title) "Click to return to search page")
                      (ps:chain control-div (append-child control-ui))
                      (let ((control-text (ps:chain document (create-element "div"))))
                        (setf (ps:@ control-text class-name) "link-control-content-box")
                        (setf (ps:@ control-text inner-h-t-m-l)
                              (ps:who-ps-html (:span :class "link-control-content-text" "Search for sites")))
                        (ps:chain control-ui (append-child control-text))
                        (ps:chain google maps event
                                  (add-dom-listener control-ui
                                                    "click"
                                                    #'(lambda ()
                                                        (ps:chain window location (assign *current-search-uri*))))))))

                  (defun site-type-icon-uri (st-name)
                    (cond ((= st-name "Featured site") "icon_feature.png")
                          ((= st-name "Museum/Archives") "icon_museum.png")
                          ((= st-name "Building") "icon_building.png")
                          ((= st-name "Monument") "icon_monument.png")
                          ((= st-name "Cemetery") "icon_cemetery.png")
                          ((= st-name "Location") "icon_location.png")
                          ((= st-name "Other") "icon_other.png")))

                  (defun add-marker (map feature)
                    (let ((coordinates (ps:@ feature geometry coordinates))
                          (properties (ps:@ feature properties)))
                      (let ((lat-lng (ps:new (ps:chain google maps
                                                       (-lat-lng (aref coordinates 1)     ; Y is latitude
                                                                 (aref coordinates 0))))) ; X is longitude
                            (s-no (ps:@ properties s-no))
                            (s-name (ps:@ properties s-name))
                            (m-name (ps:@ properties m-name))
                            (s-address (ps:@ properties s-address))
                            (st-name (ps:@ properties st-name))
                            (s-url (ps:@ properties s-url)))
                        (let ((icon (ps:create :url (+ *icons-uri* (site-type-icon-uri st-name))
                                               :size (ps:new (ps:chain google maps (-size 32 32)))
                                               :origin (ps:new (ps:chain google maps (-point 0 0)))
                                               :anchor (ps:new (ps:chain google maps (-point 16 16)))))
                              (s (+ s-name ", " m-name (if (= s-address "") "" (+ ", " s-address)))))
                          (let ((marker (ps:new
                                         (ps:chain google maps
                                                   (-marker (ps:create :position lat-lng
                                                                       :icon icon
                                                                       :title s-name
                                                                       :map map)))))
                                (content (ps:who-ps-html
                                          (:div :class "info-window-content-box"
                                                (:div :class "info-window-site-name-box"
                                                      (:a :class "info-window-site-link"
                                                          :href (+ *mhs-base-uri* s-url)
                                                          :target "_blank"
                                                          s))))))
                            (ps:chain google maps event
                                      (add-listener marker
                                                    "click"
                                                    #'(lambda (event)
                                                        (ps:chain *info-window* (set-content content))
                                                        (ps:chain *info-window* (open map marker))))))))))

                  (defun initialize ()
                    (setf *map*
                          (ps:new (ps:chain google maps
                                            (-map (ps:chain document
                                                            (get-element-by-id "map-canvas"))
                                                  *map-options*))))

                    (let ((control-div (ps:chain document (create-element "div"))))
                      (let ((control (ps:new (link-control control-div)))
                            (position (ps:@ google maps -control-position "TOP_CENTER")))
                        (setf (ps:@ control-div index) 1)
                        (let ((foo (ps:getprop *map* 'controls position)))
                          (ps:chain foo (push control-div)))))

                    (xhr-get-json *features-json-uri*
                                  #'(lambda (results)
                                      (dolist (feature (ps:@ results features))
                                        (add-marker *map* feature)))))

                  (ps:chain google maps event (add-dom-listener window "load" #'initialize))))))
     (:body
      (:div :id "map-canvas")))))

(hunchentoot:define-easy-handler (handle-map :uri (princ-to-string *map-uri*))
    ((submit :parameter-type 'parse-non-empty-string :request-type :get)
     (string1 :parameter-type 'parse-non-empty-string :request-type :get)
     (op2 :parameter-type 'keyword :request-type :get)
     (string2 :parameter-type 'parse-non-empty-string :request-type :get)
     (op3 :parameter-type 'keyword :request-type :get)
     (string3 :parameter-type 'parse-non-empty-string :request-type :get)
     (m-name :parameter-type 'parse-non-empty-string :request-type :get)
     (st-name :parameter-type 'parse-non-empty-string :request-type :get)
     (snd-no-p :parameter-type 'boolean :request-type :get)
     (spd-no-p :parameter-type 'boolean :request-type :get)
     (smd-no-p :parameter-type 'boolean :request-type :get))
  (hunchentoot:no-cache)
  (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
  (render-map string1
              op2
              string2
              op3
              string3
              m-name
              st-name
              snd-no-p
              spd-no-p
              smd-no-p))
