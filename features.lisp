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

(hunchentoot:define-easy-handler (handle-features :uri (princ-to-string *features-uri*))
    ((south :parameter-type 'parse-coordinate :request-type :get)
     (west :parameter-type 'parse-coordinate :request-type :get)
     (north :parameter-type 'parse-coordinate :request-type :get)
     (east :parameter-type 'parse-coordinate :request-type :get)
     (lat :parameter-type 'parse-coordinate :request-type :get)
     (lng :parameter-type 'parse-coordinate :request-type :get)
     (distance :parameter-type 'parse-distance :request-type :get)
     (municipality-name :parameter-type 'parse-non-empty-string :request-type :get))
  (with-database-connection
    (multiple-value-bind (rows count)
        (cond ((and (not (null south))
                    (not (null west))
                    (not (null north))
                    (not (null east)))
               (select-sites-within-bounds south west north east))
              ((and (not (null lat))
                    (not (null lng))
                    (not (null distance)))
               (select-sites-within-distance lat lng distance))
              ((not (null municipality-name))
               (select-sites-by-municipality municipality-name))
              (t
               (hunchentools:abort-with-bad-request)))
      (let ((municipality (if (null municipality-name)
                              nil
                              (select-municipality municipality-name))))
        (let ((centroid (if (null municipality)
                            nil
                            (make-point :x (municipality-m-lng municipality)
                                        :y (municipality-m-lat municipality)))))
          (hunchentoot:no-cache)
          (setf (hunchentoot:content-type*) "application/json; charset=utf-8")
          (with-output-to-string (stream)
            (geojson-encode-sites rows centroid stream)))))))
