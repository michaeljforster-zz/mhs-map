;;;; features.lisp

(in-package #:mhs-map)

;; (hunchentoot:define-easy-handler (handle-features-json :uri (princ-to-string *features-json-uri*))
;;     ((string1 :parameter-type 'parse-non-empty-string :request-type :get)
;;      (op2 :parameter-type 'keyword :request-type :get)
;;      (string2 :parameter-type 'parse-non-empty-string :request-type :get)
;;      (op3 :parameter-type 'keyword :request-type :get)
;;      (string3 :parameter-type 'parse-non-empty-string :request-type :get)
;;      (m-name :parameter-type 'parse-non-empty-string :request-type :get)
;;      (st-name :parameter-type 'parse-non-empty-string :request-type :get)
;;      (snd-no-p :parameter-type 'boolean :request-type :get)
;;      (spd-no-p :parameter-type 'boolean :request-type :get)
;;      (smd-no-p :parameter-type 'boolean :request-type :get))
;;   (hunchentoot:no-cache)
;;   (setf (hunchentoot:content-type*) "application/json; charset=utf-8")
;;   (with-database-connection
;;     (multiple-value-bind (rows count)
;;         (select-sites string1
;;                       op2
;;                       string2
;;                       op3
;;                       string3
;;                       m-name
;;                       st-name
;;                       snd-no-p
;;                       spd-no-p
;;                       smd-no-p)
;;       (declare (ignore count))
;;       (with-output-to-string (stream)
;;         (geojson-encode-sites rows stream)))))

(hunchentoot:define-easy-handler (handle-features-within-bounds
                                  :uri (princ-to-string *features-within-bounds-uri*))
    ((south :parameter-type 'wu-decimal:parse-decimal :request-type :get)
     (west :parameter-type 'wu-decimal:parse-decimal :request-type :get)
     (north :parameter-type 'wu-decimal:parse-decimal :request-type :get)
     (east :parameter-type 'wu-decimal:parse-decimal :request-type :get))
  (hunchentoot:no-cache)
  (setf (hunchentoot:content-type*) "application/json; charset=utf-8")
  (with-database-connection
    (multiple-value-bind (rows count)
        (select-sites-within-bounds south west north east)
      (hunchentoot:log-message* :info
                                "HANDLE-FEATURES-WITHIN-BOUNDS: south ~F west ~F north ~F east ~F count ~D"
                                south west north east count)
      (with-output-to-string (stream)
        (geojson-encode-sites rows stream)))))

(hunchentoot:define-easy-handler (handle-features-within-distance
                                  :uri (princ-to-string *features-within-distance-uri*))
    ((lat :parameter-type 'wu-decimal:parse-decimal :request-type :get)
     (lng :parameter-type 'wu-decimal:parse-decimal :request-type :get)
     (distance :parameter-type 'wu-decimal:parse-decimal :request-type :get))
  (hunchentoot:no-cache)
  (setf (hunchentoot:content-type*) "application/json; charset=utf-8")
  (with-database-connection
    (multiple-value-bind (rows count)
        (select-sites-within-distance lat lng distance)
      (hunchentoot:log-message* :info
                                "HANDLE-FEATURES-WITHIN-DISTANCE: lat ~F lng ~F distance ~F count ~D"
                                lat lng distance count)
      (with-output-to-string (stream)
        (geojson-encode-sites rows stream)))))
