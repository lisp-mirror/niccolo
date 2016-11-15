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

(let ((db (init-hashtable-equalp))
      (lock  (bt:make-recursive-lock)))

  (defun get-raw-results (query-id)
    (bt:with-recursive-lock-held (lock)
      (gethash query-id db)))

  (defun enqueue-results (query-id res-object)
    (bt:with-recursive-lock-held (lock)
      (if (get-raw-results query-id)
	  (setf (gethash query-id db)
		(concatenate 'list
			     (get-raw-results query-id)
			     (list res-object)))
	  (setf (gethash query-id db)
		(list res-object)))))

  (defun get-serialized-results (query-id)
    (bt:with-recursive-lock-held (lock)
      (let ((raw (get-raw-results query-id)))
	(if raw
	    (with-output-to-string (stream)
	      ;; remove the entry
	      (remhash query-id db)
	      (cl-json:with-array (stream)
		(loop for i in raw do
		     (let ((plists (json->list (response i))))
		       (loop for prod in plists do
			    (cl-json:as-array-member (stream)
			      (cl-json:encode-json prod stream)))))))
	    (with-output-to-string (stream)
	      (cl-json:with-array (stream)
		(loop for i in raw do
		     (cl-json:as-array-member (stream)
		       (cl-json:encode-json-plist raw stream)))))))))

  (defun clear-db ()
    (bt:with-recursive-lock-held (lock)
      (setf db (init-hashtable-equalp)))))
