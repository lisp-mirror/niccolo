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

(define-constant +query-chemical-product+             "chemical-product"        :test #'string=)

(define-constant +query-chemical-compound+            "chemical-compound"       :test #'string=)

(define-constant +query-node-visited+                 "visited"                 :test #'string=)

(define-constant +query-http-timeout+                 30                        :test #'=)

(defclass prototype ()
  ((lisp-package
    :initform ""
    :initarg  :lisp-package
    :accessor lisp-package)
   (lisp-class
    :initform ""
    :initarg  :lisp-class
    :accessor lisp-class)))

(defclass json-deserializable ()
  ((prototype
    :initform nil
    :initarg  :prototype
    :accessor prototype)))

(defmethod initialize-instance :after ((object json-deserializable) &key &allow-other-keys)
  (let ((prototype (make-instance 'prototype
				  :lisp-package :federated-query
				  :lisp-class   (class-name (class-of object)))))
    (setf (prototype object) prototype)))

(defclass identified-by-key ()
  ((key
    :initform +federated-query-key+
    :initarg  :key
    :accessor key)))

(defclass query (json-deserializable identified-by-key)
  ((request-type
    :initform +query-chemical-product+
    :initarg  :request-type
    :accessor request-type)
   (request
    :initform ""
    :initarg  :request
    :accessor request)
   (origin-host
    :initform "localhost"
    :initarg  :origin-host
    :accessor origin-host)
   (origin-host-port
    :initform 43
    :initarg  :origin-host-port
    :accessor origin-host-port)
   (id
    :initform nil
    :initarg  :id
    :accessor id)))

(defun make-query (class request &key
				   (id nil)
				   (origin-host nil)
				   (port nil)
				   (request-type +query-chemical-product+))
  (make-instance class
		 :id               (or id (next-query-id))
		 :origin-host      (or origin-host +hostname+)
		 :origin-host-port (or port (if (> +https-proxy-port+ 0)
						+https-proxy-port+
						+https-port+))
		 :request-type (or request-type
				   +query-chemical-product+)
		 :request      request))

(defclass query-response (json-deserializable identified-by-key)
  ((request-type
    :initform +query-chemical-product+
    :initarg  :request-type
    :accessor request-type)
   (response
    :initform nil
    :initarg  :response
    :accessor response)
   (id
    :initform nil
    :initarg  :id
    :accessor id)))

(defun make-query-response (class query-id response &key (key +federated-query-key+))
  (make-instance class
		 :key              key
		 :id               query-id
		 :response         response))

(defclass query-product (query) ())

(defun make-query-product (request &key (id nil) (origin-host nil) (port nil))
  (make-query 'query-product
	      request
	      :id            id
	      :origin-host   origin-host
	      :port          port
	      :request-type  +query-chemical-product+))

(defclass query-product-response (query-response) ())

(defun make-query-product-response (serialized-products query-id)
  (make-query-response 'query-response query-id serialized-products))

(defclass query-chem-compound (query) ())

(defun make-query-chem-compound (request &key (id nil) (origin-host nil) (port nil))
  (make-query 'query-chem-compound
	      request
	      :id            id
	      :origin-host   origin-host
	      :port          port
	      :request-type  +query-chemical-compound+))

(defclass query-chem-compound-response (query-response) ())

(defun make-query-chem-compound-response (serialized-chem-compounds query-id)
  (make-query-response 'query-response query-id serialized-chem-compounds))

(defclass query-visited (query) ())

(defun make-query-visited (id)
  (make-instance 'query-visited :id id))

(defclass visited-response (query-response) ())

(defun make-visited-response (visited-flag id)
  (make-instance 'visited-response
		 :id           id
		 :response     visited-flag
		 :request-type +query-node-visited+))

(defgeneric send-query (object node &key path))

(defmethod send-query ((object query) node &key (path nil))
  (let ((uri (remote-uri (node-name node) (node-port node)
			 (concatenate 'string +path-prefix+ path))))
    (setf (key object) +federated-query-key+)
    (with-http-ignored-errors (+query-http-timeout+)
      (drakma:http-request uri
			   :method :post
			   :verify :required
			   :parameters (list (cons +query-http-parameter-key+
						   (obj->json-string object)))))))

(defmethod send-query ((object query-product) node &key (path +query-product-path+))
  (call-next-method object node :path path))

(defmethod send-query ((object query-chem-compound) node &key (path +query-compound-hazard-path+))
  (call-next-method object node :path path))

(defmethod send-query ((object query-visited) node &key (path +query-visited+))
  (call-next-method object node :path path))

(defgeneric send-response (object destination port &key path))

(defmethod send-response ((object query-response) destination port
			  &key (path +post-federated-query-results+))
  (let ((uri (remote-uri destination port
			 (concatenate 'string +path-prefix+ path))))
    (with-http-ignored-errors (+query-http-timeout+)
      (drakma:http-request uri
			   :method :post
			   :verify :required
			   :parameters (list (cons +query-http-response-key+
						   (obj->json-string object)))))))

(defun federated-query (request)
  (loop for node in (all-nodes) do
       (query-single-node request node))
  (id request))

(defun federated-query-product (request &key (set-me-visited nil))
  (let* ((req (if (stringp request)
		  (make-query-product request)
		  request)))
    (when set-me-visited
      (set-visited (id req)))
    (federated-query req)))

(defun federated-query-chemical-hazard (request)
  (let* ((req (if (stringp request)
		  (make-query-chem-compound request)
		  request)))
    (federated-query req)))

(defun query-single-node (request node)
  (let* ((req-visited      (make-query-visited (id request)))
	 (response-raw     (send-query req-visited node))
	 (response-visited (and response-raw
				(json-string->obj response-raw))))
    (when (and response-visited (not (fq:response response-visited)))
      (send-query request node))))
