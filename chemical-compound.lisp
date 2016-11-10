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

(in-package :restas.lab)

(define-constant +name-chem-id+          "id"          :test #'string=)

(define-constant +name-chem-proper-name+ "name"        :test #'string=)

(define-constant +name-chem-cid+         "pubchem-cid" :test #'string=)

(define-constant +name-chem-msds-data+   "msds-pdf"    :test #'string=)

(defun add-new-chem (name msds-filename cid)
  (let* ((errors-msg-1  (regexp-validate (list (list name +free-text-re+ (_ "Name invalid")))))
	 (errors-msg-file (when (and msds-filename
				     (not (pdf-validate-p msds-filename)))
			    (list (_ "Invalid pdf file"))))
	 (errors-msg-2  (when (and (not errors-msg-1)
				   (unique-p-validate
				    'db:chemical-compound
				    :name name
				    (_ "Chemical compound already in the database")))))
	 (errors-msg (concatenate 'list errors-msg-1 errors-msg-2 errors-msg-file))
	 (success-msg (and (not errors-msg)
			   (list (format nil (_ "Saved chemical: ~s") name)))))
    (when (not errors-msg)
      (let ((new-chem (create 'db:chemical-compound
			      :name name
			      :pubchem-cid (if (scan +pos-integer-re+ cid)
					       cid
					       nil)
			      :msds (if msds-filename
					(base64-encode (read-file-into-byte-vector msds-filename))
					nil))))
	(save new-chem)))
    (manage-chem success-msg errors-msg)))

(defun manage-chem (infos errors)
  (let ((all-chem (do-rows (row-idx res)
		      (fetch-raw-template-list 'db:chemical-compound
					       '(:id :name :msds)
					       :delete-link 'delete-chemical
					       :additional-tpl
					       #'(lambda (row)
						   (list
						    :update-chemical-link
						    (restas:genurl 'update-chemical
								   :id (db:id row)))))
		    (let ((row (elt res row-idx)))
		      (setf (elt res row-idx)
			    (nconc row
				   (list
				    :assoc-prec-link
				    (restas:genurl 'assoc-chem-prec :id (getf row :id))
				    :assoc-haz-link
				    (restas:genurl 'assoc-chem-haz :id (getf row :id))
				    :has-msds (if (getf row :msds) t nil)
				    :msds-pdf-link
				    (restas:genurl 'chemical-get-msds :id (getf row :id)))))))))
    (with-standard-html-frame (stream (_ "Manage Chemical Compound")
				      :infos infos
				      :errors errors)
      (html-template:fill-and-print-template #p"add-chemical.tpl"
					     (with-back-to-root
						 (with-path-prefix
						     :name-lb       (_ "Name")
						     :msds-file-lb  (_ "MSDS file")
						     :data-sheet-lb (_ "Data Sheet")
						     :operations-lb (_ "Operations")
						     :id +name-chem-id+
						     :name +name-chem-proper-name+
						     :msds-pdf +name-chem-msds-data+
						     :pubchem-cid +name-chem-cid+
						     :data-table all-chem))
					     :stream stream))))

(define-lab-route chemical-get-msds ("/chemical-msds/:id" :method :get)
  (with-authentication
    (let ((chem (single 'db:chemical-compound :id id)))
      (if chem
	  (if (db:msds chem)
	      (progn
		(setf (header-out :content-type) "application/pdf")
		(base64-decode (db:msds chem)))
	      +http-not-found+)
	  +http-not-found+))))

(define-lab-route chemical ("/chemical/" :method :get)
  (with-authentication
    (manage-chem nil nil)))

(define-lab-route add-chemical ("/add-chemical/" :method :post)
  (with-authentication
    (with-editor-or-above-privileges
	(progn
	  (let ((name     (tbnl:post-parameter +name-chem-proper-name+))
		(cid      (tbnl:post-parameter +name-chem-cid+))
		(filename (get-post-filename +name-chem-msds-data+)))
	    (add-new-chem name filename cid)))
      (manage-chem nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-chemical ("/delete-chemical/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
	    (let ((to-trash (single 'db:chemical-compound :id id)))
	      (when to-trash
		(del (single 'db:chemical-compound :id id)))))
	  (restas:redirect 'chemical))
      (manage-chem nil (list *insufficient-privileges-message*)))))

(define-lab-route subst-msds ("/subst-msds/:id" :method :post)
  (with-authentication
    (with-editor-or-above-privileges
	(progn
	  (let ((has-not-errors  (and (not (regexp-validate (list (list id +pos-integer-re+ ""))))
				      (get-post-filename +name-chem-msds-data+)
				      (pdf-validate-p (get-post-filename +name-chem-msds-data+))))
		(success-msg     (list (_ "MSDS uploaded")))
		(error-general   (list (_ "MSDS not uploaded")))
		(error-not-found (list (format nil
					       (_ "MSDS not uploaded, chemical (id: ~a) not found")
					       id))))
	    (if has-not-errors
		(let ((msds-file (get-post-filename +name-chem-msds-data+))
		      (updated-chem (single 'db:chemical-compound :id id)))
		  (if updated-chem
		      (progn
			(setf (db:msds updated-chem)
			      (base64-encode (read-file-into-byte-vector msds-file)))
			(save updated-chem)
			(manage-chem success-msg nil))
		      (manage-chem nil error-not-found)))
		(manage-chem nil error-general))))
      (manage-chem nil (list *insufficient-privileges-message*)))))
