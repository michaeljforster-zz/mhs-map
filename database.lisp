;;;; database.lisp

(in-package #:mhs-map)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro with-database-connection (&body body)
    `(postmodern:with-connection
         (list *pg-database*
               *pg-user*
               *pg-password*
               *pg-host*)
       ,@body)))

(defun db-null-to-nil (x)
  (if (eql x :null) nil x))

(defun nil-to-db-null (x)
  (if (null x) :null x))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defmacro define-struct-row-reader (structure-name &rest slot-specs)
    (alexandria:with-unique-names (fields list row)
      (let ((row-reader-name (alexandria:symbolicate structure-name (string-upcase "-row-reader")))
            (default-constructor-name (alexandria:symbolicate (string-upcase "make-")
                                                              structure-name))
            (i -1))
        (flet ((make-slot-description (slot-spec)
                 (destructuring-bind (slot-name slot-initform &optional slot-pg-reader)
                     slot-spec
                   `(,slot-name ,slot-initform :read-only t)))
               (make-arg (slot-spec)
                 (destructuring-bind (slot-name slot-initform &optional slot-pg-reader)
                     slot-spec
                   `(,(alexandria:make-keyword slot-name)
                      (postmodern:coalesce (funcall (or ,slot-pg-reader #'identity)
                                                    (cl-postgres:next-field (aref ,fields ,(incf i))))
                                           ,slot-initform)))))
          `(progn
             (defstruct ,structure-name
               ,@(mapcar #'make-slot-description slot-specs))
             (cl-postgres:def-row-reader ,row-reader-name (,fields)
               (let ((,list '()))
                 (do ((,row (cl-postgres:next-row) (cl-postgres:next-row)))
                     ((null ,row))
                   (push (,default-constructor-name
                             ,@(alexandria:mappend #'make-arg slot-specs))
                         ,list))
                 (nreverse ,list)))))))))

(defun s-address (number location)
  (let ((list '()))
    (when (string/= "" number)
      (push number list))
    (when (string/= "" location)
      (push location list))
    (format nil "~{~A~^ ~}" (nreverse list))))


(defparameter *site-type-names*
  (list "Featured site"
        "Museum/Archives"
        "Building"
        "Monument"
        "Cemetery"
        "Location"
        "Other"))

(defun sitetype-st-name (sitetype)
  (ccase sitetype
    (1 "Featured site")
    (2 "Museum/Archives")
    (3 "Building")
    (4 "Monument")
    (5 "Cemetery")
    (6 "Location")
    (7 "Other")))

(defun s-published-p (site)
  (not (alexandria:starts-with-subseq "</a>" site :test #'string-equal)))

(postmodern:defprepared clear-import
    (:select (:clear-import)) :none)

(postmodern:defprepared-with-names import-site (s-no
                                                s-name
                                                m-name
                                                s-address
                                                st-names
                                                s-keyword
                                                s-url
                                                s-published-p
                                                lat
                                                lng
                                                snd-no
                                                spd-no
                                                smd-no)
  ((:select (:import-site '$1
                          '$2
                          '$3
                          '$4
                          (:raw "$5::varchar array")
                          '$6
                          '$7
                          '$8
                          '$9
                          '$10
                          '$11
                          '$12
                          '$13 ))
   s-no
   s-name
   m-name
   s-address
   st-names
   s-keyword
   s-url
   s-published-p
   (nil-to-db-null lat)
   (nil-to-db-null lng)
   (nil-to-db-null snd-no)
   (nil-to-db-null spd-no)
   (nil-to-db-null smd-no))
  :none)

(postmodern:defprepared complete-import
    (:select (:complete-import)) :none)

(postmodern:defprepared count-sites
    (:select (:count '*) :from 'site) :single)

(postmodern:defprepared select-municipality-names
    (:order-by (:select 'm-name :from 'municipality) 'm-name) :column)

(postmodernity:defpgstruct municipality
  m-name
  m-lat
  m-lng)

(postmodern:defprepared select-municipalities
    (:order-by
     (:select 'm-name
              (:as (:st-y 'm-geometry) 'm-lat) ; yes, Y is latitude; don't coalesce, use NIL
              (:as (:st-x 'm-geometry) 'm-lng) ; yes, X is longitude; don't coalesce, use NIL
              :from 'municipality)
     'm-name)
  :municipalitys) ; No, not a miss-spelling

(postmodern:defprepared-with-names select-municipality (m-name)
  ((:order-by
    (:select 'm-name
             (:as (:st-y 'm-geometry) 'm-lat) ; yes, Y is latitude; don't coalesce, use NIL
             (:as (:st-x 'm-geometry) 'm-lng) ; yes, X is longitude; don't coalesce, use NIL
             :from 'municipality
             :where (:= 'm-name '$1))
    'm-name)
   m-name)
  :municipality)

(postmodernity:defpgstruct site
  s-no
  s-name
  m-name
  s-address
  st-name
  (s-url #'(lambda (string) (ignore-errors (puri:parse-uri string))))
  s-published-p
  s-lat
  s-lng
  snd-no
  spd-no
  smd-no)

(postmodern:defprepared-with-names select-sites-within-bounds (south west north east)
  ((:order-by
    (:select 's-no
             's-name
             'm-name
             's-address
             'st-name
             's-url
             's-published-p
             (:as (:st-y 'sg-geometry) 's-lat) ; yes, Y is latitude; don't coalesce, use NIL
             (:as (:st-x 'sg-geometry) 's-lng) ; yes, X is longitude; don't coalesce, use NIL
             'snd-no ; don't coalesce, use NIL
             'spd-no ; don't coalesce, use NIL
             'smd-no ; don't coalesce, use NIL
             :from 'site
             :inner-join 'site-geo :using ('s-no)
             :left-join 'site-national-designation :using ('s-no)
             :left-join 'site-provincial-designation :using ('s-no)
             :left-join 'site-municipal-designation :using ('s-no)
             :where (:st-within 'sg-geometry
                                (:st-setsrid
                                 ;; NOTE: st-makebox2d (lower-left-point upper-right-point)
                                 ;; NOTE: st-makepoint (x/lng y/lat)
                                 (:st-makebox2d
                                  ;; NOTE: st-makepoint (west south)
                                  (:st-makepoint '$2 '$1)
                                  ;; NOTE: st-makepoint (east north)
                                  (:st-makepoint '$4 '$3))
                                 4326)))
    's-name)
   south
   west
   north
   east)
  :sites)

(postmodern:defprepared-with-names select-sites-within-distance (lat lng distance)
  ((:order-by
    (:select 's-no
             's-name
             'm-name
             's-address
             'st-name
             's-url
             's-published-p
             (:as (:st-y 'sg-geometry) 's-lat) ; yes, Y is latitude; don't coalesce, use NIL
             (:as (:st-x 'sg-geometry) 's-lng) ; yes, X is longitude; don't coalesce, use NIL
             'snd-no ; don't coalesce, use NIL
             'spd-no ; don't coalesce, use NIL
             'smd-no ; don't coalesce, use NIL
             :from 'site
             :inner-join 'site-geo :using ('s-no)
             :left-join 'site-national-designation :using ('s-no)
             :left-join 'site-provincial-designation :using ('s-no)
             :left-join 'site-municipal-designation :using ('s-no)
             :where (:st-dwithin 'sg-geography
                                 (:geography
                                  (:st-transform
                                   (:st-setsrid
                                    ;; NOTE: st-makepoint (x/lng y/lat)
                                    (:st-makepoint '$2 '$1)
                                    *default-srid*)
                                   *default-srid*))
                                 '$3))
    's-name)
   lat
   lng
   distance)
  :sites)

(postmodern:defprepared-with-names select-sites-by-municipality (m-name)
  ((:order-by
    (:select 's-no
             's-name
             'm-name
             's-address
             'st-name
             's-url
             's-published-p
             (:as (:st-y 'sg-geometry) 's-lat) ; yes, Y is latitude; don't coalesce, use NIL
             (:as (:st-x 'sg-geometry) 's-lng) ; yes, X is longitude; don't coalesce, use NIL
             'snd-no ; don't coalesce, use NIL
             'spd-no ; don't coalesce, use NIL
             'smd-no ; don't coalesce, use NIL
             :from 'site
             :inner-join 'site-geo :using ('s-no)
             :left-join 'site-national-designation :using ('s-no)
             :left-join 'site-provincial-designation :using ('s-no)
             :left-join 'site-municipal-designation :using ('s-no)
             :where (:= 'm-name '$1))
    's-name)
   m-name)
  :sites)

(defun make-binary-logical-form (a op b)
  (if (not (and op b))
      a
      (ecase op
        ((:and :or)
         `(,op ,a ,b))
        (:not
         `(:and ,a (:not ,b))))))

(defun combine-logical-forms (&rest forms)
  (reduce #'(lambda (&optional acc form)
              (destructuring-bind (op b)
                  form
                (make-binary-logical-form acc op b)))
          forms
          :initial-value t))

(defun make-ilike-form (attribute-name pattern)
  `(:ilike ',attribute-name ,pattern))

(defun make-ilike-name-address-form (string)
  (if (null string)
      nil
      (let ((pattern (format nil "%~A%" string)))
        `(:or ,(make-ilike-form 's-name pattern)
              ,(make-ilike-form 'm-name pattern)
              ,(make-ilike-form 's-address pattern)
              ,(make-ilike-form 's-keyword pattern)))))

(defun make-select-sites-form (where-form)
  `(:order-by
    (:select 's-no
             's-name
             'm-name
             's-address
             'st-name
             's-url
             's-published-p
             (:as (:st-y 'sg-geometry) 's-lat) ; yes, Y is latitude; don't coalesce, use NIL
             (:as (:st-x 'sg-geometry) 's-lng) ; yes, X is longitude; don't coalesce, use NIL
             'snd-no ; don't coalesce, use NIL
             'spd-no ; don't coalesce, use NIL
             'smd-no ; don't coalesce, use NIL
             :from 'site
             :left-join 'site-geo :using ('s-no)
             :left-join 'site-national-designation :using ('s-no)
             :left-join 'site-provincial-designation :using ('s-no)
             :left-join 'site-municipal-designation :using ('s-no)
             ,@where-form)
    's-name))

(defparameter *select-site-sql*
  (s-sql:sql-compile (make-select-sites-form '(:where (:= 's-no '$1)))))

(defun make-select-sites-sql (keyword1
                              op2
                              keyword2
                              op3
                              keyword3
                              m-name
                              st-name
                              snd-no-p
                              spd-no-p
                              smd-no-p)
  (flet ((make-sql (form)
           (s-sql:sql-compile (make-select-sites-form `(:where ,form)))))
    (let ((keyword-form (combine-logical-forms (list :and (make-ilike-name-address-form keyword1))
                                               (list op2 (make-ilike-name-address-form keyword2))
                                               (list op3 (make-ilike-name-address-form keyword3))))
          (designation-form '()))
      (when snd-no-p (push '(:not-null 'snd-no) designation-form))
      (when spd-no-p (push '(:not-null 'spd-no) designation-form))
      (when smd-no-p (push '(:not-null 'smd-no) designation-form))
      (cond
        ((and m-name st-name)
         (values (make-sql `(:and ,keyword-form
				  ,@designation-form
				  (:= 'm-name '$1)
				  (:or (:= 'st-name '$2)
				       (:in '$2
					    (:select 'st-name :from 'site-secondary-site-type :where (:= 's-no 'site.s-no))))))
                 (list m-name st-name)))
        (m-name
         (values (make-sql `(:and ,keyword-form ,@designation-form (:= 'm-name '$1)))
                 (list m-name)))
        (st-name
         (values (make-sql `(:and ,keyword-form
				  ,@designation-form
                                  (:or (:= 'st-name '$1)
				       (:in '$1
					    (:select 'st-name :from 'site-secondary-site-type :where (:= 's-no 'site.s-no))))))
                 (list st-name)))
        (t
         (values (make-sql `(:and ,keyword-form ,@designation-form))
                 nil))))))

;; (define-struct-row-reader site
;;   (s-no 0)
;;   (s-name "")
;;   (m-name "")
;;   (s-address "")
;;   (st-name "")
;;   (s-url #u"" #'(lambda (string) (ignore-errors (puri:parse-uri string))))
;;   (s-published-p nil)
;;   (s-lat nil)
;;   (s-lng nil)
;;   (snd-no nil)
;;   (spd-no nil)
;;   (smd-no nil))

;; (defun select-site (s-no &optional (database postmodern:*database*))
;;   (cl-postgres:prepare-query database "" *select-site-sql*)
;;   (first (cl-postgres:exec-prepared database "" (list s-no) 'site-row-reader)))

;; (defun select-sites (keyword1
;;                      op2
;;                      keyword2
;;                      op3
;;                      keyword3
;;                      m-name
;;                      st-name
;;                      snd-no-p
;;                      spd-no-p
;;                      smd-no-p
;;                      &optional (database postmodern:*database*))
;;   (multiple-value-bind (sql args)
;;       (make-select-sites-sql keyword1
;;                              op2
;;                              keyword2
;;                              op3
;;                              keyword3
;;                              m-name
;;                              st-name
;;                              snd-no-p
;;                              spd-no-p
;;                              smd-no-p)
;;     (cl-postgres:prepare-query database "" sql)
;;     (cl-postgres:exec-prepared database "" args 'site-row-reader)))
