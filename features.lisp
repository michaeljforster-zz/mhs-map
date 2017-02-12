;;;; features.lisp

(in-package #:mhs-map)

(hunchentoot:define-easy-handler (handle-features :uri (princ-to-string *features-uri*))
    ((south :parameter-type 'parse-coordinate :request-type :get)
     (west :parameter-type 'parse-coordinate :request-type :get)
     (north :parameter-type 'parse-coordinate :request-type :get)
     (east :parameter-type 'parse-coordinate :request-type :get)
     (lat :parameter-type 'parse-coordinate :request-type :get)
     (lng :parameter-type 'parse-coordinate :request-type :get)
     (distance :parameter-type 'parse-distance :request-type :get)
     (m-name :parameter-type 'parse-non-empty-string :request-type :get)
     (st-name :parameter-type 'parse-non-empty-string :request-type :get)
     (snd-no-p :parameter-type 'boolean :request-type :get)
     (spd-no-p :parameter-type 'boolean :request-type :get)
     (smd-no-p :parameter-type 'boolean :request-type :get)
     (keyword1 :parameter-type 'parse-non-empty-string :request-type :get)
     (op2 :parameter-type 'keyword :request-type :get)
     (keyword2 :parameter-type 'parse-non-empty-string :request-type :get)
     (op3 :parameter-type 'keyword :request-type :get)
     (keyword3 :parameter-type 'parse-non-empty-string :request-type :get))
  (with-database-connection
    (multiple-value-bind (rows count)
        (cond ((and (not (null south))
                    (not (null west))
                    (not (null north))
                    (not (null east)))
               (select-sites-within-bounds south west north east
                                           st-name
                                           snd-no-p spd-no-p smd-no-p
                                           keyword1 op2 keyword2 op3 keyword3))
              ((and (not (null lat))
                    (not (null lng))
                    (not (null distance)))
               (select-sites-within-distance lat lng distance
                                             st-name
                                             snd-no-p spd-no-p smd-no-p
                                             keyword1 op2 keyword2 op3 keyword3))
              ((not (null m-name))
               (select-sites-within-municipality m-name
                                                 st-name
                                                 snd-no-p spd-no-p smd-no-p
                                                 keyword1 op2 keyword2 op3 keyword3))
              (t
               (hunchentools:abort-with-bad-request)))
      (let ((centroid (if (null m-name)
                          nil
                          (municipality-centroid (select-municipality m-name)))))
        (hunchentoot:no-cache)
        (setf (hunchentoot:content-type*) "application/json; charset=utf-8")
        (with-output-to-string (stream)
          (geojson-encode-sites rows centroid stream))))))
