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

(in-package :restas.lab)

(defclass user-session (db:user)
  ((authorized
   :reader authorized-p
   :writer (setf authorized)
   :initform nil
   :initarg :authorized)))

(defun user->user-session (db-user &key (auth t))
  (make-instance 'user-session
		 :id         (db:id       db-user)
		 :username   (db:username db-user)
		 :authorized auth
		 :level      (db:level db-user)
		 :password   (db:password db-user)))

(defun user-session->user (user)
  (and user
       (db:id user)
       (> (db:id user) 0)
       (single 'db:user :id (db:id user))))

(defun authenticate-user (uname password)
  "Return user, if authenticated, nil otherwise"
  (when (and uname password (single 'db:user :username uname))
    (let* ((user            (single  'db:user :username uname)))
      (if (db:chkpass user password)
	  user
	  nil))))

#+mini-cas
(defmacro with-cas-parameters (&body body)
  `(let ((mini-cas:*server-host-name*   +cas-server-host-name+)
	 (mini-cas:*server-path-prefix* +cas-server-path-prefix+)
	 (mini-cas:*service-name*       +cas-service-name+))
     ,@body))

#+mini-cas
(defun cas-login-uri ()
  (with-cas-parameters
      (with-output-to-string (stream nil)
	(puri:render-uri (mini-cas:make-login-uri) stream))))

#+mini-cas
(defmacro check-with-cas-authenticate (() (&body body))
  (with-gensyms (response username user)
    `(with-cas-parameters
       (multiple-value-bind (,response ,username)
	   (mini-cas:service-validate (parameter mini-cas:+query-ticket-key+))
	 (when ,response
	   (let ((,user (single 'db:user :username ,username)))
	     (if ,user
		 (progn
		   (setf (tbnl:session-value +user-session+)
			 (user->user-session ,user :auth t))
		   ,@body)
		 (logout-user))))))))

(defmacro authenticate ((uname password) &body body)
  (alexandria:with-gensyms (the-session the-user db-user)
    `(let* ((,the-session (tbnl:start-session))
	    (,the-user (if ,the-session
			   (tbnl:session-value +user-session+)
			   nil)))
       (if ,the-session
	   (if ,the-user
	       (if (authorized-p ,the-user)
		   (progn ,@body)
		   (progn
		     (render-login-form)
		     (tbnl:remove-session ,the-session)))
	       (let ((,db-user (authenticate-user ,uname ,password)))
		 (if ,db-user
		     (progn
		       (setf (tbnl:session-value +user-session+)
			     (user->user-session ,db-user :auth t))
		       ,@body)
		     (progn
		       (render-login-form)))))
	   (render-login-form)))))

(defun get-session-username ()
  (if (and (tbnl:start-session)
	   (tbnl:session-value +user-session+)
 	   (db:username (tbnl:session-value +user-session+)))
      (db:username (tbnl:session-value +user-session+))
      "Guest"))

(defmacro with-session-user ((user) &body body)
  `(let ((,user (and (tbnl:start-session)
		     (tbnl:session-value +user-session+))))
     ,@body))

(defun get-session-user-id ()
  (if (and (tbnl:start-session)
	   (tbnl:session-value +user-session+)
 	   (db:username (tbnl:session-value +user-session+)))
      (db:id (tbnl:session-value +user-session+))
      0))

(defun admin-id ()
  (db:id (admin-user)))

(defun admin-user ()
  (single 'db:user :level +admin-acl-level+))

(defun get-session-level ()
  (if (and (tbnl:start-session)
	   (tbnl:session-value +user-session+)
 	   (db:username (tbnl:session-value +user-session+)))
      (db:level (tbnl:session-value +user-session+))
      (1+ +user-acl-level+)))

(defun logout-user ()
  (let* ((the-session (tbnl:start-session)))
    (unwind-protect
	 (if the-session
	     (tbnl:remove-session the-session)
	     (tbnl:log-message* :warning "Logout error, session null."))
       #+mini-cas
       (with-cas-parameters
	 (restas:redirect (with-output-to-string (stream)
			    (puri:render-uri (mini-cas:make-logout-uri) stream))))
       #-mini-cas
       (restas:redirect (restas:genurl 'root)))))

(defun session-admin-p ()
  (= (db:level (tbnl:session-value +user-session+)) +admin-acl-level+))

(defmacro admin-or-login ((action) &body body)
  `(if (session-admin-p)
       (progn ,@body)
       (render-login-form ,action)))

(defun render-login-form ()
  (with-standard-html-frame (stream "Welcome")
    #+mini-cas
    (html-template:fill-and-print-template #p"login-form.tpl"
					   nil
					   :stream stream)
    #-mini-cas
    (html-template:fill-and-print-template #p"login-form-no-cas.tpl"
					   (with-path-prefix
					       :login-name +auth-name-login-name+
					       :login-pass +auth-name-login-password+)
					   :stream stream)))

(define-lab-route logout ("/logout" :method :get)
  (authenticate (nil nil)
    (logout-user)
    (restas:redirect 'root)))

(defun account-enabled-p (user)
  (let ((db-user (user-session->user user)))
    (and db-user
	 (= (db:account-enabled db-user) +user-account-enabled+))))

(defmacro with-authentication (&body body)
  "Check if user is authenticated, if true try to set the translation table"
  (with-gensyms (session-user)
    `(authenticate ((tbnl:parameter +auth-name-login-name+)
		    (tbnl:parameter +auth-name-login-password+))
       (i18n:with-user-translation ((get-session-user-id))
	 (with-session-user (,session-user)
	   (if (account-enabled-p ,session-user)
	       (progn
		  ,@body)
	       (logout-user)))))))

(defmacro with-admin-privileges (if-admin if-not)
  `(if (session-admin-p)
       ,if-admin
       ,if-not))
