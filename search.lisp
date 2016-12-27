;;;; search.lisp

(in-package #:mhs-map)

(defun render-search (string1
                      ops2
                      op2
                      string2
                      ops3
                      op3
                      string3
                      m-names
                      m-name
                      st-names
                      st-name
                      snd-no-p
                      spd-no-p
                      smd-no-p
                      rows
                      count)
  (flet ((render-select (name options selected)
           (cl-who:with-html-output (*standard-output*)
             (:select :class "field-select" :name name :id name
                      (dolist (x options)
                        (destructuring-bind (label . value) x
                          (cl-who:htm
                           (:option :value (cl-who:escape-string value)
                                    :selected (string= selected value)
                                    (cl-who:esc label)))))))))
    (cl-who:with-html-output-to-string (*standard-output* nil :prologue t)
      (:html
        (:head
          (:title (cl-who:esc (concatenate 'string *app-title* ": Map Search")))
          (:link :rel "stylesheet" :type "text/css" :href (static-uri "mhs-map/css/reset.css"))
          (:link :rel "stylesheet" :type "text/css" :href (static-uri "mhs-map/css/search.css")))
        (:body
          (:div :class "clearfix" :id "page-box"
                (:div :class "clearfix" :id "page-header-box"
                      (:div :id "page-header-title-box"
                            (:a :href (princ-to-string (puri:uri *mhs-sites-uri*))
                                :id "page-header-link"
                                (cl-who:esc *app-title*))
                            ": Map Search"))
                (:div :class "clearfix" :id "page-body-box"
                      (:div :class "form-box"
                            (:form :method "get" :action *search-uri*
                                   (:input :type "hidden" :name "go" :value "t")
                                   (:div :class "field-box"
                                         (:label :class "field-label" "Keywords: ")
                                         (:input :type "text" :class "field-input" :id "string1" :name "string1"
                                                 :value (cl-who:escape-string (or string1 ""))))
                                   (:div :class "field-box"
                                         (render-select "op2" ops2 op2)
                                         (:input :type "text" :class "field-input" :id "string2" :name "string2"
                                                 :value (cl-who:escape-string (or string2 ""))))
                                   (:div :class "field-box"
                                         (render-select "op3" ops3 op3)
                                         (:input :type "text" :class "field-input" :id "string3" :name "string3"
                                                 :value (cl-who:escape-string (or string3 ""))))
                                   (:div :class "field-box"
                                         (:label :class "field-label" :for "m-name" "Municipality: ")
                                         (render-select "m-name" m-names (or m-name "")))
                                   (:div :class "field-box"
                                         (:label :class "field-label" :for "st-name" "Type: ")
                                         (render-select "st-name" st-names (or st-name "")))
                                   (:div :class "field-box"
                                         (:label :class "field-label" "Only: ")
                                         (:input :type "checkbox" :class "field-input" :id "snd-no-p" :name "snd-no-p" :value "t" :checked snd-no-p)
                                         (:label :class "field-post-label" :for "snd-no-p" "Nationally designated sites"))
                                   (:div :class "field-box"
                                         (:input :type "checkbox" :class "field-input" :id "spd-no-p" :name "spd-no-p" :value "t" :checked spd-no-p)
                                         (:label :class "field-post-label" :for "spd-no-p" "Provincially designated sites"))
                                   (:div :class "field-box"
                                         (:input :type "checkbox" :class "field-input" :id "smd-no-p" :name "smd-no-p" :value "t" :checked smd-no-p)
                                         (:label :class "field-post-label" :for "smd-no-p" "Municipally designated sites"))
                                   (:div :class "field-box"
                                         (:input :type "submit" :class "field-button" :name "submit" :value "Search")
                                         (:input :type "button" :class "field-button" :value "Reset"
                                                 :onclick (concatenate 'string
                                                                       "javascript:window.location.assign(\""
                                                                       (princ-to-string *search-uri*)
                                                                       "\")"))
                                         (:input :type "button" :class "field-button" :value "Display Map"
                                                 :onclick (concatenate 'string
                                                                       "javascript:window.location.assign(\""
                                                                       (princ-to-string (puri:copy-uri *map-uri*
                                                                                                       :query (format-uri-query (or string1 "")
                                                                                                                                (or op2 :and)
                                                                                                                                (or string2 "")
                                                                                                                                (or op3 :and)
                                                                                                                                (or string3 "")
                                                                                                                                (or m-name "")
                                                                                                                                (or st-name "")
                                                                                                                                snd-no-p
                                                                                                                                spd-no-p
                                                                                                                                smd-no-p)))
                                                                       "\")")))))
                      (:div :class "form-note" (cl-who:fmt "~D sites matched your query." count))
                      (:div :class "data-browser"
                            (:table :class "data-browser-table"
                                    (:thead :class "data-browser-heading"
                                            (:tr :class "data-browser-heading-row"
                                                 (:th :class "data-browser-heading-column data-browser-left-column" "Name")
                                                 (:th :class "data-browser-heading-column data-browser-left-column" "Municipality")
                                                 (:th :class "data-browser-heading-column data-browser-left-column" "Address")
                                                 ;; (:th :class "data-browser-heading-column data-browser-left-column" "Primary Type")
                                                 ;; (:th :class "data-browser-heading-column data-browser-right-column" "N")
                                                 ;; (:th :class "data-browser-heading-column data-browser-right-column" "P")
                                                 ;; (:th :class "data-browser-heading-column data-browser-right-column" "M")
                                                 ))
                                    (:tbody :class "data-browser-body"
                                            (let ((even-row-p t))
                                              (dolist (row rows)
                                                (cl-who:htm
                                                 (:tr :class (if even-row-p
                                                                 "data-browser-data-row data-browser-even-row"
                                                                 "data-browser-data-row data-browser-odd-row")
                                                      :onmouseout "javascript:this.classList.remove(\"data-browser-hover-row\")"
                                                      :onmouseover "javascript:this.classList.add(\"data-browser-hover-row\")"
                                                      (:td :class "data-browser-data-column data-browser-left-column"
                                                           (let ((s-url (site-s-url row))
                                                                 (s-name (site-s-name row)))
                                                             (if (puri:uri= s-url #u"")
                                                                 (cl-who:esc s-name)
                                                                 (cl-who:htm
                                                                  (:a :href (princ-to-string (puri:merge-uris s-url (puri:uri *mhs-base-uri*)))
                                                                      :target "_blank"
                                                                      (cl-who:esc s-name))))))
                                                      (:td :class "data-browser-data-column data-browser-left-column"
                                                           (cl-who:esc (site-m-name row)))
                                                      (:td :class "data-browser-data-column data-browser-left-column"
                                                           (cl-who:esc (site-s-address row)))
                                                      ;; (:td :class "data-browser-data-column data-browser-left-column"
                                                      ;;      (cl-who:esc (site-st-name row)))
                                                      ;; (:td :class "data-browser-data-column data-browser-right-column"
                                                      ;;      (cl-who:fmt "~:[~;Yes~]" (site-snd-no row)))
                                                      ;; (:td :class "data-browser-data-column data-browser-right-column"
                                                      ;;      (cl-who:fmt "~:[~;Yes~]" (site-spd-no row)))
                                                      ;; (:td :class "data-browser-data-column data-browser-right-column"
                                                      ;;      (cl-who:fmt "~:[~;Yes~]" (site-smd-no row)))
                                                      ))
                                                (setf even-row-p (not even-row-p))))))))
                (:div :id "page-footer-box" (cl-who:esc *app-copyright*))))))))

(hunchentoot:define-easy-handler (handle-search :uri (princ-to-string *search-uri*))
    ((gop :real-name "go" :parameter-type 'boolean :request-type :get)
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
  (let ((ops2-3 (sort (pair (list "AND" "NOT" "OR")) #'string<= :key #'car)))
    (flet ((render (rows count)
             (render-search string1
                            ops2-3
                            op2
                            string2
                            ops2-3
                            op3
                            string3
                            (acons "*ALL*" "" (sort (pair (select-municipality-names)) #'string<= :key #'car))
                            m-name
                            (acons "*ALL*" "" (sort (pair *site-type-names*) #'string<= :key #'car))
                            st-name
                            snd-no-p
                            spd-no-p
                            smd-no-p
                            rows
                            count)))
      (with-database-connection
        (if gop
            (multiple-value-bind (rows count)
                (select-sites string1
                              op2
                              string2
                              op3
                              string3
                              m-name
                              st-name
                              snd-no-p
                              spd-no-p
                              smd-no-p)
              (render rows count))
            (render '() 0))))))
