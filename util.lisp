;;;; util.lisp

(in-package #:mhs-map)

(defun getenv (name)
  (sb-unix::posix-getenv name))

(defun getenv-integer (name)
  (parse-integer (getenv name)))

(defun getenv-keyword (name)
  (intern (string-upcase (getenv "HTTPPRIVATEPROTOCOL")) :keyword))

(defun getenv-uri (name)
  (puri:uri (getenv name)))

(defun redirect (uri)
  (hunchentoot:redirect (princ-to-string uri)
                        :host *http-private-host*
                        :port *http-private-port*
                        :protocol *http-private-protocol*))

(let (static-uri-base)
  (defun static-uri (relative-uri)
    (when (null static-uri-base)
      (setf static-uri-base (puri:uri *static-uri-base*)))
    (puri:merge-uris relative-uri static-uri-base)))

(defun pair (list)
  (pairlis list list))

(defun parse-non-empty-string (x)
  (if (stringp x)
      (let ((x (string-trim '(#\Space #\Tab #\Newline) x)))
        (and (string/= "" x) x))
      nil))

(defun parse-coordinate (x)
  (ignore-errors (wu-decimal:parse-decimal x)))

(defun parse-distance (x)
  (ignore-errors (wu-decimal:parse-decimal x)))

(defun format-uri-query (string1
                         op2
                         string2
                         op3
                         string3
                         m-name
                         st-name
                         snd-no-p
                         spd-no-p
                         smd-no-p
                         &optional submitp)
  (format nil
          "string1=~A&op2=~A&string2=~A&op3=~A&string3=~A&m-name=~A&st-name=~A~:[~;&snd-no-p=t~]~:[~;&spd-no-p=t~]~:[~;&smd-no-p=t~]~:[~;&submit=t~]"
          (cl-who:escape-string string1)
          op2
          (cl-who:escape-string string2)
          op3
          (cl-who:escape-string string3)
          (cl-who:escape-string m-name)
          (cl-who:escape-string st-name)
          snd-no-p
          spd-no-p
          smd-no-p
          submitp))
