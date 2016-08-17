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

(define-constant +query-chemical-product+ "chemical-product" :test #'string=)

(defclass query ()
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
    :initform (next-query-id)
    :initarg  :id
    :accessor id)
   (key
    :initform ""
    :initarg  :key
    :accessor key)))

(defclass query-response ()
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

(defclass query-product (query) ())

(defclass product-response ()
  ((name
    :initform ""
    :initarg  :name
    :accessor name)
   (place
    :initform ""
    :initarg  :place
    :accessor place)))

(defclass query-product-response (query-response) ())

(defun make-query-product (name &key (id nil) (origin-host nil) (port nil))
  (make-instance 'query-product
		 :id               (or id (next-query-id))
		 :origin-host      (or origin-host +hostname+)
		 :origin-host-port (or port (if (> +https-proxy-port+ 0)
						+https-proxy-port+
						+https-port+))
		 :request-type +query-chemical-product+
		 :request      name))


(defclass query-visited (query) ())

(defclass visited-response (query-response) ())

(defgeneric send-query (object node &key path))

(defmethod  send-query ((object query) node &key (path nil))
  (let ((uri (remote-uri (node-name node) (node-port node)
			 (concatenate 'string +path-prefix+ path))))
    (setf (key object) (node-key node))
    (drakma:http-request uri
			 :method :post
			 :verify :required
			 :parameters (list (cons +query-http-parameter-key+
						 (obj->json-string object))))))

(defmethod  send-query ((object query-product) node &key (path +query-product-path+))
  ;; TODO per prima cosa vedere se l'host e' stato visitato, solo se non lo e' stato mandare la richiesta
  (call-next-method object node :path path))

(defun test-query-product (name)
  (init-nodes)
  (let ((req (make-query-product name)))
    (send-query req (find-node "localhost"))))
