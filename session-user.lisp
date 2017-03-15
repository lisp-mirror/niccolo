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

(in-package :session-user)

(define-constant +user-private-pagination-offset+ :pagination-offset :test #'string=)

(defclass user-session (db:user)
  ((authorized
   :reader authorized-p
   :writer (setf authorized)
   :initform nil
   :initarg :authorized)
   (private-storage
    :initform  (make-hash-table :test 'eq)
    :initarg   :private-storage
    :accessor  private-storage)))

(defmethod initialize-instance :after ((object user-session) &key &allow-other-keys)
  (with-accessors ((private-storage private-storage)) object
    (setf (gethash +user-private-pagination-offset+ private-storage)
          (make-hash-table :test 'equal))))

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

(defun session-admin-p ()
  (= (db:level (tbnl:session-value +user-session+)) +admin-acl-level+))

(defgeneric account-enabled-p (user))

(defmethod account-enabled-p ((object db:user))
  (and object
       (= (db:account-enabled object) +user-account-enabled+)))

(defmethod account-enabled-p ((object user-session))
  (let ((db-user (user-session->user object)))
    (account-enabled-p db-user)))
