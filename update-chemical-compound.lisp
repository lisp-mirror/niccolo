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

(define-constant +name-chem-id+          "id"          :test #'string=)

(define-constant +name-chem-proper-name+ "name"        :test #'string=)

(define-constant +name-chem-cid+         "pubchem-cid" :test #'string=)

(defun update-chem (id name cid)
  (let* ((errors-msg-1  (regexp-validate (list  (list name +free-text-re+ "Name invalid"))))
	 (errors-msg-id  (regexp-validate (list (list id +pos-integer-re+ "Id invalid"))))
	 (errors-msg-2  (when (and (not errors-msg-1)
				   (not errors-msg-id)
				   (not (single 'db:chemical-compound :id id)))
			  "Chemical compound not in database"))
	 (errors-msg-unique (when (all-null-p errors-msg-1 errors-msg-id errors-msg-2)
			      (exists-with-different-id-validate 'db:chemical-compound
								 id
								 (:name)
								 (name)
								 "Chemical name already in the database with different ID")))
	 (errors-msg (concatenate 'list
				  errors-msg-1
				  errors-msg-id
				  errors-msg-2
				  errors-msg-unique))
	 (success-msg (and (not errors-msg)
			   (list (format nil "Chemical: ~s updated" name)))))
    (if (not errors-msg)
	(let ((new-chem (single 'db:chemical-compound :id id)))
	  (setf (db:name        new-chem) name
		(db:pubchem-cid new-chem) (if (scan +pos-integer-re+ cid)
					      cid
					      nil))
	  (save new-chem)
	  (manage-update-chem (and success-msg id) success-msg errors-msg))
	(manage-chem success-msg errors-msg))))

(defun prepare-for-update-chem (id)
  (prepare-for-update id
		      'db:chemical-compound
		      "Chemical does not exists in database."
		      #'manage-update-chem))

(defun manage-update-chem (id infos errors)
  (let ((new-chem (and id (single 'db:chemical-compound :id id))))
    (with-standard-html-frame (stream "Update Chemical Compound" :infos infos :errors errors)
      (html-template:fill-and-print-template #p"update-chemical.tpl"
					     (with-path-prefix
						 :id   (and id
							    (db:id new-chem))
						 :name-value (and id
								  (db:name new-chem))
						 :cid-value  (and id
								  (db:pubchem-cid new-chem))
						 :name        +name-chem-proper-name+
						 :cid       +name-chem-cid+)
					     :stream stream))))

(define-lab-route update-chemical ("/update-chemical/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (let ((new-name     (get-parameter +name-chem-proper-name+))
		(new-cid      (get-parameter +name-chem-cid+)))
	    (if (and new-name
		     new-cid)
		(update-chem id new-name new-cid)
		(prepare-for-update-chem id))))
      (manage-update-chem nil nil (list *insufficient-privileges-message*)))))
