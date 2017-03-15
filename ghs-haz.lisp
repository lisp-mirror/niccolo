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

(define-constant +name-ghs-hazard-expl+         "expl"         :test #'string=)

(define-constant +name-ghs-hazard-code+         "code"         :test #'string=)

(define-constant +name-ghs-hazard-carcinogenic+ "carcinogenic" :test #'string=)

(define-constant +pictogram-form-key+           "pictogram"    :test #'string=)

(defun all-ghs-hazard-code-select ()
  (query (select (( :as :h.id                         :id)
		  ( :as :h.code                       :code)
		  ( :as :h.explanation                :explanation)
		  ( :as :h.carcinogenic               :carcinogenic)
		  ( :as :ghs-pictogram.pictogram-file :pictogram))
	   (from (:as :ghs-hazard-statement  :h))
	   (left-join :ghs-pictogram   :on (:= :h.pictogram :ghs-pictogram.id)))))

(defun build-template-list-hazard-code (start-from &key (delete-link nil) (update-link nil))
  (let ((raw (map 'list #'(lambda (row)
			    (map 'list
				 #'(lambda (cell)
				     (if (symbolp cell)
					 (make-keyword (string-upcase (symbol-name cell)))
					 cell))
				 row))
		  (all-ghs-hazard-code-select))))
    (do-rows (rown res)
	(slice-for-pagination raw start-from)
      (let* ((row (elt res rown)))
	(setf (getf row :pictogram)
	      (if (stringp (getf row :pictogram))
		  (pictogram->preview-path (getf row :pictogram)
					   (concatenate 'string +images-url-path+
							+ghs-pictogram-web-image-subdir+)
					   :extension +pictogram-web-image-ext+)
		  nil))
	(setf (elt res rown)
	      (nconc row
		     (pictograms-template-struct)
		     (if delete-link
			 (list :delete-link (delete-uri delete-link row))
			 nil)
		     (if update-link
			 (list :update-link (restas:genurl update-link :id (getf row :id)))
			 nil)))))))


(defun add-new-ghs-hazard-code (code expl carcenogenic)
  (let* ((errors-msg-1 (regexp-validate (list
					 (list code +ghs-hazard-code-re+ (_ "GHS code invalid"))
					 (list expl +free-text-re+ (_ "GHS phrase invalid"))
					 (list expl +free-text-re+
					       (_ "GHS Carcinogenic code invalid")))))
	 (errors-msg-2 (when (not errors-msg-1)
			 (unique-p-validate 'db:ghs-hazard-statement
					    :code code
					    (_ "GHS code already in the database"))))
	 (errors-msg (concatenate 'list errors-msg-1 errors-msg-2))
	 (success-msg (and (not errors-msg)
			   (list (format nil (_ "Saved new GHS hazard statements: ~s - ~s")
					 code expl)))))
    (when (not errors-msg)
      (let ((ghs (create 'db:ghs-hazard-statement
			 :code         code
			 :explanation  expl
			 :carcinogenic carcenogenic
			 :pictogram    +pictogram-id-none+)))
	(save ghs)))
    (manage-ghs-hazard-code success-msg errors-msg)))

(defun manage-ghs-hazard-code (infos errors &key (start-from 0))
  (let ((all-ghss (build-template-list-hazard-code (actual-pagination-start start-from)
						   :delete-link  'delete-ghs-hazard
						   :update-link  'update-hazard)))
    (multiple-value-bind (next-start prev-start)
	(pagination-bounds (actual-pagination-start start-from) 'db:ghs-hazard-statement)
      (with-standard-html-frame (stream (_ "Manage GHS Hazard Statements")
					:infos infos :errors errors)
	(html-template:fill-and-print-template #p"add-hazard.tpl"
					       (with-back-to-root
						   (with-pagination-template
						       (next-start prev-start)
						     (with-path-prefix
							 :code-lb           (_ "Code")
							 :statement-lb      (_ "Statement")
							 :carcinogenic-p-lb (_ "Carcinogenic?")
							 :carcinogenic-lb
							 (_ "Carcinogenic (according to IARC)")
							 :operations-lb     (_ "Operations")
							 :code              +name-ghs-hazard-code+
							 :expl              +name-ghs-hazard-expl+
							 :carcinogenic
							 +name-ghs-hazard-carcinogenic+
							 :next-start         next-start
							 :prev-start         prev-start
							 :data-table         all-ghss)))
					       :stream stream)))))

(define-lab-route ghs-hazard ("/ghs-hazard/" :method :get)
  (with-authentication
    (with-pagination (pagination-uri)
      (manage-ghs-hazard-code nil nil
			      :start-from (session-pagination-start pagination-uri)))))

(define-lab-route add-ghs-hazard ("/add-ghs-hazard/" :method :get)
  (with-authentication
    (with-admin-privileges
	(with-pagination (pagination-uri)
	  (add-new-ghs-hazard-code (get-parameter +name-ghs-hazard-code+)
				   (get-parameter +name-ghs-hazard-expl+)
				   (get-parameter +name-ghs-hazard-carcinogenic+)))
      (manage-ghs-hazard-code nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-ghs-hazard ("/delete-ghs-hazard/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
	    (let ((to-trash (single 'db:ghs-hazard-statement :id id)))
	      (when to-trash
		(del (single 'db:ghs-hazard-statement :id id)))))
	  (restas:redirect 'ghs-hazard))
      (manage-ghs-hazard-code nil (list *insufficient-privileges-message*)))))

(define-lab-route assoc-ghs-pictogram ("/assoc-ghs-pictogram/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(with-pagination (pagination-uri)
	  (when (and (not (regexp-validate (list (list id +pos-integer-re+ ""))))
		     (not (regexp-validate (list (list (get-parameter +pictogram-form-key+)
						       +pos-integer-re+ "")))))
	    (let ((h-code (single 'db:ghs-hazard-statement :id id))
		  (pict   (single 'db:ghs-pictogram :id (get-parameter +pictogram-form-key+))))
	      (when (and h-code
			 pict)
		(setf (db:pictogram h-code) (db:id pict))
		(save h-code))))
	  (restas:redirect 'ghs-hazard))
      (manage-ghs-hazard-code nil (list *insufficient-privileges-message*)))))
