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

(define-constant +name-ghs-precautionary-expl+ "expl" :test #'string=)

(define-constant +name-ghs-precautionary-code+ "code" :test #'string=)

(defun add-new-ghs-precautionary-code (code expl)
  (let* ((errors-msg-1 (concatenate 'list
				    (regexp-validate (list
						      (list code
							    +ghs-precautionary-code-re+
							    "GHS code invalid")
						      (list expl
							    +free-text-re+
							    "GHS phrase invalid")))))
	 (errors-msg-2  (when (not errors-msg-1)
			  (unique-p-validate 'db:ghs-precautionary-statement
					     :code
					     code
					     "GHS code already in the database")))
	 (errors-msg (concatenate 'list errors-msg-1 errors-msg-2))
	 (success-msg (and (not errors-msg)
			   (list (format nil
					 "Saved new GHS precautionary statements: ~s - ~s"
					 code expl)))))
    (when (not errors-msg)
      (let ((ghs (create 'db:ghs-precautionary-statement
			 :code code
			 :explanation expl)))
	(save ghs)))
    (manage-ghs-precautionary-code success-msg errors-msg)))

(defun manage-ghs-precautionary-code (infos errors)
  (let ((all-ghss (fetch-raw-template-list 'db:ghs-precautionary-statement
					   '(:id :code :explanation)
					   :delete-link 'delete-ghs-precautionary
					   :additional-tpl
					   #'(lambda (row)
					       (list
						:update-link
						(restas:genurl 'update-precautionary
							       :id (db:id row)))))))
    (with-standard-html-frame (stream "Manage GHS Precautionary Statements"
				      :infos  infos
				      :errors errors)

      (html-template:fill-and-print-template #p"add-precautionary.tpl"
					     (with-path-prefix
						 :code +name-ghs-precautionary-code+
						 :expl +name-ghs-precautionary-expl+
						 :data-table all-ghss)
					     :stream stream))))

(define-lab-route ghs-precautionary ("/ghs-precautionary/" :method :get)
  (with-authentication
    (manage-ghs-precautionary-code nil nil)))

(define-lab-route add-ghs-precautionary ("/add-ghs-precautionary/" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (add-new-ghs-precautionary-code (get-parameter +name-ghs-precautionary-code+)
					  (get-parameter +name-ghs-precautionary-expl+)))
      (manage-ghs-precautionary-code nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-ghs-precautionary ("/delete-ghs-precautionary/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
	    (let ((to-trash (single 'db:ghs-precautionary-statement :id id)))
	      (when to-trash
		(del (single 'db:ghs-precautionary-statement  :id id)))))
	  (restas:redirect 'ghs-precautionary))
      (manage-ghs-precautionary-code nil (list *insufficient-privileges-message*)))))
