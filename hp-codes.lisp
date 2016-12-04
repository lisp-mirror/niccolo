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

(define-constant +name-hp-waste-expl+         "expl"         :test #'string=)

(define-constant +name-hp-waste-code+         "code"         :test #'string=)

(defun all-hp-waste-code-select ()
  (query (select (( :as :hp.id                        :id)
		  ( :as :hp.code                      :code)
		  ( :as :hp.explanation               :explanation)
		  ( :as :ghs-pictogram.pictogram-file :pictogram))
	   (from (:as :hp-waste-code :hp))
	   (left-join :ghs-pictogram :on (:= :hp.pictogram :ghs-pictogram.id)))))

(defun build-template-list-hp-waste-code (&key (delete-link nil) (update-link nil))
  (let ((raw (map 'list #'(lambda (row)
			    (map 'list
				 #'(lambda (cell)
				     (if (symbolp cell)
					 (make-keyword (string-upcase (symbol-name cell)))
					 cell))
				 row))
		  (all-hp-waste-code-select))))
  (do-rows (rown res) raw
    (let* ((row (elt raw rown)))
      (setf (getf row :pictogram)
	    (if (stringp (getf row :pictogram))
		(pictogram->preview-path (getf row :pictogram)
					 (concatenate 'string +images-url-path+
						      +ghs-pictogram-web-image-subdir+)
					 :extension +pictogram-web-image-ext+)
		nil))
      (setf (elt raw rown)
	    (nconc row
		   (pictograms-template-struct)
		   (if delete-link
		       (list :delete-link (restas:genurl delete-link :id (getf row :id)))
		       nil)
		   (if update-link
		       (list :update-link (restas:genurl update-link :id (getf row :id)))
		       nil)))))
  raw))

(defun add-new-hp-waste-code (code expl)
  (let* ((errors-msg-1 (regexp-validate (list
					 (list code +hp-waste-code-re+ (_ "HP code invalid"))
					 (list expl +free-text-re+     (_ "HP phrase invalid")))))
	 (errors-msg-2 (when (not errors-msg-1)
			 (unique-p-validate 'db:hp-waste-code
					    :code code
					    (_ "HP code already in the database"))))
	 (errors-msg (concatenate 'list errors-msg-1 errors-msg-2))
	 (success-msg (and (not errors-msg)
			   (list (format nil (_ "Saved new HP hazard statements: ~s - ~s")
					 code expl)))))
    (when (not errors-msg)
      (let ((ghs (create 'db:hp-waste-code
			 :code         code
			 :explanation  expl
			 :pictogram    +pictogram-id-none+)))
	(save ghs)))
    (manage-hp-waste-code success-msg errors-msg)))

(defun manage-hp-waste-code (infos errors)
  (let ((all-hps (build-template-list-hp-waste-code
		   :delete-link 'delete-hp-waste
		   :update-link 'update-hp-waste)))
    (with-standard-html-frame (stream (_ "Manage HP Statements")
				      :infos infos :errors errors)
      (html-template:fill-and-print-template #p"add-hp-waste.tpl"
					     (with-back-to-root
						 (with-path-prefix
						     :code-lb       (_ "Code")
						     :statement-lb  (_ "Statement")
						     :operations-lb (_ "Operations")
						     :code          +name-hp-waste-code+
						     :expl          +name-hp-waste-expl+
						     :data-table    all-hps))
					     :stream stream))))

(define-lab-route hp-waste ("/hp-waste/" :method :get)
  (with-authentication
    (manage-hp-waste-code nil nil)))

(define-lab-route add-hp-waste ("/add-hp-waste/" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (add-new-hp-waste-code (get-parameter +name-hp-waste-code+)
				   (get-parameter +name-hp-waste-expl+)))
      (manage-hp-waste-code nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-hp-waste ("/delete-hp-waste/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
	    (let ((to-trash (single 'db:hp-waste-code :id id)))
	      (when to-trash
		(del (single 'db:hp-waste-code :id id)))))
	  (restas:redirect 'hp-waste))
      (manage-hp-waste-code nil (list *insufficient-privileges-message*)))))

(define-lab-route assoc-hp-pictogram ("/assoc-hp-pictogram/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (when (and (not (regexp-validate (list (list id +pos-integer-re+ ""))))
		     (not (regexp-validate (list (list (get-parameter +pictogram-form-key+)
						       +pos-integer-re+ "")))))
	    (let ((h-code (single 'db:hp-waste-code :id id))
		  (pict   (single 'db:ghs-pictogram :id (get-parameter +pictogram-form-key+))))
	      (when (and h-code
			 pict)
		(setf (db:pictogram h-code) (db:id pict))
		(save h-code))))
	  (restas:redirect 'hp-waste))
      (manage-ghs-hazard-code nil (list *insufficient-privileges-message*)))))
