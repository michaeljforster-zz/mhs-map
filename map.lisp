;;;; map.lisp

(in-package #:mhs-map)

(defun render-map (&optional (stream *standard-output*))
  (cl-who:with-html-output (stream nil :prologue t)
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
                    (defvar *current-center* (ps:new (ps:chain google maps (-lat-lng ,@*default-center*))))
                    (defvar *current-zoom* ,*default-zoom*)
                    (defvar *mhs-base-uri* ,(princ-to-string (puri:uri *mhs-base-uri*)))
                    (defvar *icons-uri* ,(princ-to-string (static-uri "mhs-map/images/icons/")))
                    (defvar *features-json-uri* ,(princ-to-string *features-json-uri*))))))
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
                  
                  (defvar *map-options* (ps:create :center *current-center* :zoom *current-zoom*))

                  (defvar *map* nil)

                  (defvar *site-info-window* (ps:new (ps:chain google maps (-info-window (ps:create)))))

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
                        )))

                  (defun site-type-icon-uri (st-name)
                    (cond ((= st-name "Featured site") "icon_feature.png")
                          ((= st-name "Museum/Archives") "icon_museum.png")
                          ((= st-name "Building") "icon_building.png")
                          ((= st-name "Monument") "icon_monument.png")
                          ((= st-name "Cemetery") "icon_cemetery.png")
                          ((= st-name "Location") "icon_location.png")
                          ((= st-name "Other") "icon_other.png")))

                  (defvar *markers* '())
                  
                  (defun delete-markers ()
                    (dolist (marker *markers*)
                      (ps:chain marker (set-map nil)))
                    (setf *markers* '()))
                  
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
                                          (:div :class "site-info-window-content-box"
                                                (:div :class "site-info-window-site-name-box"
                                                      (:a :class "site-info-window-site-link"
                                                          :href (+ *mhs-base-uri* s-url)
                                                          :target "_blank"
                                                          s))))))
                            (ps:chain google maps event
                                      (add-listener marker
                                                    "click"
                                                    #'(lambda (event)
                                                        (ps:chain *site-info-window* (set-content content))
                                                        (ps:chain *site-info-window* (open map marker)))))
                            (ps:chain *markers* (push marker)))))))

                  (defun format-results-info-window-content (center zoom bounds count)
                    (+ "Center: " center "<br>"
                       "Zoom: " zoom "<br>"
                       "Bounds: " bounds "<br>"
                       "Sites within bounds:  " count))

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

                    (let ((results-info-window (ps:new (ps:chain google maps (-info-window (ps:create))))))

                      ;; https://developers.google.com/maps/documentation/javascript/events
                      ;;
                      ;; Note:
                      ;; 
                      ;;     Tip: If you're trying to detect a change in
                      ;;     the viewport, be sure to use the specific
                      ;;     bounds_changed event rather than
                      ;;     constituent zoom_changed and center_changed
                      ;;     events. ...
                      ;;
                      ;; However, because bounds_changed appears to fire
                      ;; repeatedly during a pan or resize, we listen
                      ;; for the idle event instead:
                      ;; 
                      ;;     This event is fired when the map becomes
                      ;;     idle after panning or zooming.
                      (ps:chain *map* (add-listener "idle"
                                                    #'(lambda ()
                                                        (setf *current-center* (ps:chain *map* (get-center)))
                                                        (setf *current-zoom* (ps:chain *map* (get-zoom)))
                                                        (let ((bounds (ps:chain *map* (get-bounds))))
                                                          (let ((south-west (ps:chain bounds (get-south-west)))
                                                                (north-east (ps:chain bounds (get-north-east))))
                                                            (let ((south (ps:chain south-west (lng)))
                                                                  (west (ps:chain south-west (lat)))
                                                                  (north (ps:chain north-east (lng)))
                                                                  (east (ps:chain north-east (lat))))
                                                              (xhr-get-json (+ *features-json-uri*
                                                                               "?south=" south
                                                                               "&west=" west
                                                                               "&north=" north
                                                                               "&east=" east)
                                                                            #'(lambda (results)
                                                                                (ps:chain console (log "Deleting markers"))
                                                                                (delete-markers)
                                                                                (let ((sites-count (ps:@ results features length)))
                                                                                  (ps:chain console (log (+ "Populating markers: " sites-count)))
                                                                                  (dolist (feature (ps:@ results features))
                                                                                    (add-marker *map* feature))
                                                                                  (ps:chain results-info-window
                                                                                            (set-content (format-results-info-window-content *current-center*
                                                                                                                                             *current-zoom*
                                                                                                                                             bounds
                                                                                                                                             sites-count)))
                                                                                  (ps:chain results-info-window (set-position *current-center*))
                                                                                  (ps:chain results-info-window (open *map*)))))))))))))

                  (ps:chain google maps event (add-dom-listener window "load" #'initialize))))))
     (:body
      (:div :id "map-canvas")))))

(hunchentoot:define-easy-handler (handle-map :uri (princ-to-string *map-uri*))
    ()
  (hunchentoot:no-cache)
  (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
  (with-output-to-string (stream)
    (render-map stream)))
