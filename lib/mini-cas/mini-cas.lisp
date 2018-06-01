;; niccolo': a chemicals inventory
;; Copyright (C) 2016  Universita' degli Studi di Palermo

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, version 3 of the License.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :mini-cas)

(define-constant +uri-login+                   "/login"                :test #'string=)

(define-constant +uri-logout+                  "/logout"               :test #'string=)

(define-constant +uri-validate+                "/validate"             :test #'string=)

(define-constant +uri-service-validate+        "/serviceValidate"      :test #'string=)

(define-constant +uri-proxy-validate+          "/proxyValidate"        :test #'string=)

(define-constant +uri-proxy+                   "/proxy"                :test #'string=)

(define-constant +query-key-value-separator+   "="                     :test #'string=)

(define-constant +query-pair-separator+        "&"                     :test #'string=)

(define-constant +query-ticket-key+            "ticket"                :test #'string=)

(define-constant +query-service-key+           "service"               :test #'string=)

(define-constant +query-request-method-key+    "method"                :test #'string=)

(define-constant +query-request-method+        "GET"                   :test #'string=)

(define-constant +query-username-key+          "username"              :test #'string=)

(define-constant +query-password-key+          "password"              :test #'string=)

(define-constant +query-login-ticket-key+      "lt"                    :test #'string=)

(define-constant +service-protocol+            :https                  :test #'eq)

(define-constant +service-port+                443                     :test #'=)

(define-constant +no-error-status+             200                     :test #'=)

(define-constant +login-response-tag-success+  "authenticationSuccess" :test #'string=)

(define-constant +login-response-tag-user+     "user"                  :test #'string=)

(define-constant +login-response-tag-failure+  "authenticationFailure" :test #'string=)

;;;; testing only. Not part of the actual protocol.
(define-constant +query-login-eventid-key+     "_eventId"              :test #'string=)

(define-constant +query-login-eventid-value+   "submit"                :test #'string=)

(define-constant +query-login-execution-key+   "execution"             :test #'string=)

(defparameter    *server-host-name*            "")

(defparameter    *server-path-prefix*          "")

(defparameter    *service-name*                "")

(defparameter    *cookies*              (make-instance 'cookie-jar))

(defun prefixed-path (path)
  (concatenate 'string *server-path-prefix* path))

(defun make-uri-to-server (path &optional (query nil))
  "Path must not be prefixed"
  (make-instance 'puri:uri
                 :scheme +service-protocol+
                 :port   +service-port+
                 :host   *server-host-name*
                 :path   (prefixed-path path)
                 :query  query))

(defun send-get-request (uri)
  (multiple-value-bind (body status headers)
      (http-request uri
                    :verify      :required
                    :want-stream nil
                    :method      :get
                    :cookie-jar  *cookies*)
    (values body status headers)))

(defun send-post-request (uri parameters)
  (multiple-value-bind (body status headers)
      (http-request uri
                    :verify      :required
                    :want-stream nil
                    :method      :post
                    :cookie-jar  *cookies*
                    :parameters  parameters)
    (values body status headers)))

(defun make-query* (pairs)
  (let ((initial-value ""))
    (reduce #'(lambda (a b)
                (concatenate 'string
                             a
                             (if (string= a initial-value)
                                 ""
                                 +query-pair-separator+)
                             (car b)
                             +query-key-value-separator+
                             (cdr b)))
            pairs
            :initial-value initial-value)))

(defun make-query (&rest pairs)
  (make-query* pairs))


(defun make-service-validate-uri (ticket)
  (make-uri-to-server +uri-service-validate+
                      (make-query (cons +query-service-key+ *service-name*)
                                  (cons +query-ticket-key+  ticket))))

(defun make-login-uri ()
  (make-uri-to-server +uri-login+
                      (make-query (cons +query-service-key+ *service-name*)
                                  (cons +query-request-method-key+
                                        +query-request-method+))))

(defun make-logout-uri ()
  (make-uri-to-server +uri-logout+
                      (make-query (cons +query-service-key+ *service-name*))))

(defun check-response (tag xml-tree)
  (handler-case
      (xmlrep-find-child-tag tag xml-tree)
    (error () nil)))

(defun service-validate (ticket)
  ;; to ensure certificate verification
  (setf (cl+ssl:ssl-check-verify-p) t)
  (cl+ssl:ssl-set-global-default-verify-paths)
  (let ((uri (make-service-validate-uri ticket)))
    (multiple-value-bind (body-raw status)
        (send-get-request uri)
      (if (= status +no-error-status+)
          (let* ((body (if (typep body-raw 'string)
                           body-raw
                           (coerce (map 'vector #'code-char body-raw) 'string)))
                 (response (handler-case (parse body)
                             (error () nil)))
                 (success  (and response
                                (check-response +login-response-tag-success+ response)
                                (string= (xmlrep-tag (check-response +login-response-tag-success+
                                                                     response))
                                         +login-response-tag-success+))))
            (if success
                (let* ((username-tag (first (xmlrep-children
                                             (first (xmlrep-children response)))))
                       (username     (and username-tag
                                          (xmlrep-string-child username-tag))))
                  (if username
                      (values t username)
                      (values nil nil)))
                (if  (and (check-response +login-response-tag-failure+ response)
                          (first (xmlrep-children (first (xmlrep-children response)))))
                     (values nil (first (xmlrep-children (first (xmlrep-children response))))))))
          (values nil nil)))))

(defun test-auth (uname passwd lt-ticket execution-value)
  (let ((uri             (make-uri-to-server +uri-login+
                                             (make-query (cons +query-service-key+
                                                               *service-name*))))
        (post-parameters (list (cons +query-username-key+ uname)
                               (cons +query-password-key+ passwd)
                               (cons +query-login-ticket-key+ lt-ticket)
                               (cons +query-login-execution-key+ execution-value)
                               (cons +query-login-eventid-key+ +query-login-eventid-value+))))
    (send-post-request uri post-parameters)))

(defun test-login ()
  (let ((uri (make-login-uri)))
    (send-get-request uri)))
