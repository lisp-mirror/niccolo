;; niccolo': a chemicals inventory
;; Copyright (C) 2016  Universita' degli Studi di Palermo

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :federated-query)

(defparameter *nodes* '())

(defun all-nodes ()
  *nodes*)

(defstruct node
  (name  "localhost" :type string)
  (port  43          :type fixnum)
  (key   ""          :type string))

(defmacro define-node (name port)
  `(make-node :name ,name :port ,port :key +federated-query-key+))

(defmacro define-nodes-list (&body body)
  `(progn
     ,@(loop for i in body collect
	    `(push ,i *nodes*))))

(defun init-nodes ()
  (setf *nodes* '())
  (load +federated-query-nodes-file+ :if-does-not-exist nil))

(defgeneric find-node (name))

(defmethod find-node ((name string))
  (find name *nodes* :key #'node-name :test #'string=))

(defmethod find-node ((name vector))
  (find name *nodes* :key #'node-name
	:test #'(lambda (a b) (equalp a (utils:get-host-by-name b)))))

(defun check-credentials (node-address key)
  (and (find-node node-address)
       (string=   (node-key (find-node node-address)) key)))

(defmacro with-credentials ((name key) &body body)
  `(if (check-credentials ,name ,key)
       (progn
	 ,@body)
       tbnl:+http-not-found+))

(defmacro with-valid-key ((key) &body body)
  `(if (string= ,key +federated-query-key+)
       (progn
	 ,@body)
       tbnl:+http-not-found+))
