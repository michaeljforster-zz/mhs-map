;;;; admin-ui.lisp

(in-package #:mhs-map)

(defun render-admin-login (&optional error-message)
  (cl-who:with-html-output-to-string (*standard-output* nil :prologue t)
    (:html
     (:head
      (:title (cl-who:esc (concatenate 'string *app-title* " Admin")))
      (:link :rel "stylesheet" :type "text/css" :href (static-uri "mhs-map/css/reset.css"))
      (:link :rel "stylesheet" :type "text/css" :href (static-uri "mhs-map/css/admin.css")))
     (:body
      (:div :class "clearfix" :id "admin-login-page-wrapper"
            (:div :id "admin-login-box"
                  (:div :id "admin-login-heading"
                        (cl-who:esc (concatenate 'string *app-title* " Admin")))
                  (:form :method "post" :action *admin-login-uri*
                         (when error-message
                           (cl-who:htm (:div :id "admin-login-error-message"
                                             (cl-who:esc error-message))))
                         (:div :class "field-box"
                               (:label :class "field-label"
                                       :for "admin-login-username"
                                       "Admin Username")
                               (:input :class "field-input"
                                       :id "admin-login-username"
                                       :name "username"
                                       :type "text"
                                       :value ""))
                         (:div :class "field-box"
                               (:label :class "field-label"
                                       :for "admin-login-password"
                                       "Password")
                               (:input :class "field-input"
                                       :id "admin-login-password"
                                       :name "password"
                                       :type "password"
                                       :value ""))
                         (:input :id "admin-login-button" :type "submit" :value "Log In")))
            (:div :id "admin-login-splash"
                  (:img :id "admin-login-splash-logo" :src (static-uri "mhs-map/images/mhs-logo.jpg"))
                  (:div :id "admin-login-splash-copyright" (cl-who:esc *app-copyright*))))))))

(hunchentoot:define-easy-handler (handle-admin-login
                                  :uri (princ-to-string *admin-login-uri*))
    ((username :parameter-type 'string :request-type :post :init-form "")
     (password :parameter-type 'string :request-type :post :init-form ""))
  (hunchentoot:start-session)
  (hunchentools:harden-session-cookie)
  (setf (hunchentoot:session-max-time hunchentoot:*session*) app-config:*http-session-max-time*)
  (hunchentoot:no-cache)
  (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
  (if (equal (hunchentoot:request-method*) :post)
      (if (and (string= username app-config:*username*)
               (string= password app-config:*password*))
          (progn
            (setf (hunchentools:session-user) (make-admin-user :username username))
            (hunchentools:delete-session-csrf-token)
            (hunchentools:session-csrf-token)
            (redirect (princ-to-string *admin-import-uri*)))
          (render-admin-login "Bad username and/or password. Please try again."))
      (render-admin-login)))

(hunchentoot:define-easy-handler (handle-admin-logout
                                  :uri (princ-to-string *admin-logout-uri*))
    ()
  (hunchentoot:start-session)
  (hunchentools:harden-session-cookie)
  (hunchentoot:no-cache)
  (hunchentools:delete-session-csrf-token)
  (hunchentools:delete-session-user)
  (redirect (princ-to-string *admin-login-uri*)))

(defun render-admin-import-form (&key site-count error-message)
  (cl-who:with-html-output-to-string (*standard-output* nil :prologue t)
    (:html
      (:head
        (:title (cl-who:esc (concatenate 'string *app-title* " Admin")))
        (:link :rel "stylesheet" :type "text/css" :href (static-uri "mhs-map/css/reset.css"))
        (:link :rel "stylesheet" :type "text/css" :href (static-uri "mhs-map/css/admin.css")))
      (:body
        (:div :class "clearfix" :id "admin-import-page-wrapper"
              (:div :class "clearfix" :id "header"
                    (:div :id "header-logo-box" (:img :src (static-uri "mhs-map/images/mhs-logo.jpg")))
                    (:div :id "header-user-box"
                          (:button :class "header-button"
                                   :onclick (concatenate 'string
                                                         "javascript:window.location.href=\""
                                                         (princ-to-string *admin-logout-uri*)
                                                         "\"")
                                   "Logout")))
              (:div :id "admin-import-box"
                    (:div :id "admin-import-inner-box"
                          (:div :id "admin-import-heading"
                                (cl-who:esc (concatenate 'string *app-title* " Import")))
                          (:div :id "admin-import-notes"
                                "The following CSV column types and order are expected:")
                          (:ul :id "admin-import-column-list"
                               (:li "site - string")
                               (:li "num - integer")
                               (:li "n - optional string")
                               (:li "p - optional string")
                               (:li "m - optional string")
                               (:li "plq - optional string")
                               (:li "sitetype - integer (1-7)")
                               (:li "describe - optional string")
                               (:li "location - optional string")
                               (:li "number - optional string")
                               (:li "keyword - optional string")
                               (:li "file - optional string")
                               (:li "lat - optional float")
                               (:li "lng - optional float"))
                          (when site-count
                            (cl-who:htm (:div :id "admin-import-site-count"
                                              (cl-who:fmt "~D sites in database" site-count))))
                          (:form :id "admin-import-form"
                                 :method "post"
                                 :action *admin-import-uri*
                                 :enctype "multipart/form-data"
                                 (when error-message
                                   (cl-who:htm (:pre :id "admin-import-error-message"
                                                     (cl-who:esc error-message))))
                                 (:div :class "field-box"
                                       (:label :class "field-label"
                                               :for "admin-import-sites-file"
                                               "Select sites file (CSV) to import")
                                       (:input :class "field-input"
                                               :id "admin-import-sites-file"
                                               :name "sites-file"
                                               :type "file"))
                                 (:div :class "field-box"
                                       (:input :class "admin-import-button"
                                               :name "action"
                                               :type "submit"
                                               :value "Import")))))
              (:div :id "footer" (cl-who:esc *app-copyright*)))))))

(defun accept-eof (stream)
  (not (peek-char nil stream nil nil)))

(hunchentoot:define-easy-handler (handle-import-form
                                  :uri (princ-to-string *admin-import-uri*))
    ((action :parameter-type 'string :request-type :post :init-form "")
     (sites-file :request-type :post))
  (hunchentoot:start-session)
  (hunchentools:harden-session-cookie)
  (setf (hunchentoot:session-max-time hunchentoot:*session*) app-config:*http-session-max-time*)
  (hunchentoot:no-cache)
  (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
  (if (equal (hunchentoot:request-method*) :post)
      (let ((the-line-number 0)
            (the-csv-site nil))
        (handler-case
          (progn
            (when sites-file
              (destructuring-bind (pathname file-name content-type)
                  sites-file
                (declare (ignore file-name content-type))
                (cl-fad:with-open-temporary-file (out-stream :direction :output
                                                             :if-exists :supersede
                                                             :element-type '(unsigned-byte 8))
                  (with-open-file (in-stream pathname :element-type '(unsigned-byte 8))
                    (recode in-stream
                            *import-from-external-format*
                            out-stream
                            *import-to-external-format*))
                  (close out-stream)
                  (with-open-file (in-stream (pathname out-stream) :element-type '(unsigned-byte 8))
                    (let ((in-stream
                           (flexi-streams:make-flexi-stream
                            in-stream
                            :external-format *import-to-external-format*)))
                      (with-database-connection
                        (clear-import)
                        (fare-csv:with-rfc4180-csv-syntax ()
                          (fare-csv:read-csv-line in-stream) ; skip header
                          (loop :until (accept-eof in-stream)
                             :do (let ((csv-site (read-csv-site in-stream)))
                                   (incf the-line-number)
                                   (setf the-csv-site csv-site)
                                   (import-site (csv-site-num csv-site)
                                                (csv-site-site csv-site)
                                                (csv-site-describe csv-site)
                                                (s-address (csv-site-number csv-site)
                                                           (csv-site-location csv-site))
                                                (format nil
                                                        "{~{~S~^,~}}"
                                                        (mapcar #'sitetype-st-name (csv-site-sitetypes csv-site)))
                                                (csv-site-keyword csv-site)
                                                (csv-site-file csv-site)
                                                (s-published-p (csv-site-site csv-site))
                                                (csv-site-lat csv-site)
                                                (csv-site-lng csv-site)
                                                (csv-site-n csv-site)
                                                (csv-site-p csv-site)
                                                (csv-site-m csv-site)))))
                        (complete-import)))))))
            (redirect (princ-to-string (puri:copy-uri *admin-import-uri*))))
          (simple-error (e) ; fare-csv defines no specific condition types
            (hunchentoot:log-message* :warning
                                      "ERROR: ~A  LINE: ~D (~A)"
                                      e the-line-number the-csv-site)
            (render-admin-import-form :error-message (format nil
                                                             "ERROR: ~A~%LINE: ~D~%~A"
                                                             e
                                                             the-line-number
                                                             the-csv-site)))
          (postmodern:database-error (e)
            (hunchentoot:log-message* :warning
                                      "DATABASE ERROR: ~A-~A-~A-~A  LINE: ~D (~A)"
                                      (postmodern:database-error-code e)
                                      (postmodern:database-error-message e)
                                      (postmodern:database-error-detail e)
                                      (postmodern:database-error-cause e)
                                      the-line-number
                                      the-csv-site)
            (render-admin-import-form :error-message (format nil
                                                             "ERROR: ~A~%LINE: ~D~%~A"
                                                             (postmodern:database-error-message e)
                                                             the-line-number
                                                             the-csv-site)))))
      (with-database-connection
        (render-admin-import-form :site-count (count-sites)))))
