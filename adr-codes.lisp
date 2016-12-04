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

(define-constant +name-adr-expl+           "expl"       :test #'string=)

(define-constant +name-adr-code-class+     "code-class" :test #'string=)

(define-constant +name-adr-uncode+         "uncode"     :test #'string=)

(define-constant +start-pagination-offset+ 10           :test #'=)

(defun all-adr-code-select ()
  (query (select (( :as :adr.id                       :id)
		  ( :as :adr.uncode                   :uncode)
		  ( :as :adr.code-class               :code-class)
		  ( :as :adr.explanation              :explanation)
		  ( :as :adr-pictogram.pictogram-file :pictogram))
	   (from (:as :adr-code :adr))
	   (left-join :adr-pictogram :on (:= :adr.pictogram :adr-pictogram.id)))))

(defun build-template-list-adr-code (start-from &key (delete-link nil) (update-link nil))
  (let ((raw (map 'list #'(lambda (row)
			    (map 'list
				 #'(lambda (cell)
				     (if (symbolp cell)
					 (make-keyword (string-upcase (symbol-name cell)))
					 cell))
				 row))
		  (all-adr-code-select))))
    (do-rows (rown res)	(subseq raw
				(max 0 start-from)
				(min (length raw) (+ start-from
						     +start-pagination-offset+)))
      (let* ((row           (elt res rown))
	     (pict-template (pictograms-template-struct 'db:adr-pictogram
							(concatenate 'string
								     +images-url-path+
								     +adr-pictogram-web-image-subdir+))))
	(setf (getf row :pictogram)
	      (if (stringp (getf row :pictogram))
		  (pictogram->preview-path (getf row :pictogram)
					   (concatenate 'string
							+images-url-path+
							+adr-pictogram-web-image-subdir+)
					   :extension +pictogram-web-image-ext+)
		  nil))
	(setf (elt res rown)
	      (concatenate 'list
			   row
			   pict-template
			   (if delete-link
			       (list :delete-link
				     (concatenate 'string
						  (restas:genurl delete-link :id (getf row :id))
						  (alist->query-uri (list (cons +name-start-pagination+
										start-from))
								    :prepend-character
								    +uri-query-start+)))
			       nil)
			   (if update-link
			       (list :update-link (restas:genurl update-link :id (getf row :id)))
			       nil)))))))

(defun add-new-adr-code (code-class uncode expl)
  (let* ((errors-msg-1  (regexp-validate (list
					  (list code-class +adr-code-class-re+
						(_ "ADR code class invalid"))
					  (list uncode +adr-uncode-re+
						(_ "UN code invalid"))
					  (list expl +free-text-re+
						(_ "ADR phrase invalid")))))
	 (errors-msg-2  (when (not errors-msg-1)
			  (unique-p-validate* 'db:adr-code
					     (:uncode)
					     (uncode)
					     (_ "ADR code already in the database"))))
	 (errors-msg (concatenate 'list errors-msg-1 errors-msg-2))
	 (success-msg (and (not errors-msg)
			   (list (format nil
					 (_ "Saved new ADR code: ~s - ~s")
					 code-class expl)))))
    (when (not errors-msg)
      (let ((ghs (create 'db:adr-code
			 :code-class code-class
			 :uncode uncode
			 :explanation expl)))
	(save ghs)))
    (manage-adr-code success-msg errors-msg)))

(defun manage-adr-code (infos errors &key (start-from "0"))
  (let* ((actual-start (%actual-start start-from))
	 (all-adrs     (build-template-list-adr-code actual-start
						     :delete-link 'delete-adr
						     :update-link nil))
	 (next-start   (if (< (+ actual-start +start-pagination-offset+)
			      (count-all :adr-code))
			   (+ actual-start +start-pagination-offset+)
			   nil))
	 (prev-start   (if (>= (- actual-start +start-pagination-offset+) 0)
			   (- actual-start +start-pagination-offset+)
			   nil)))
    (with-standard-html-frame (stream (_ "Manage ADR codes")
				      :infos  infos
				      :errors errors)
      (html-template:fill-and-print-template #p"add-adr.tpl"
					     (with-back-to-root
						 (with-path-prefix
						     :class-lb   (_ "Class")
						     :un-code-lb (_ "UN Code")
						     :explanation-lb (_ "Explanation")
						     :uncode-ex-lb (_ "UNCode (for example UN1000)")
						     :proper-shipping-lb (_ "Proper Shipping Name")
						     :delete-lb          (_ "Delete")
						     :code-class         +name-adr-code-class+
						     :uncode             +name-adr-uncode+
						     :expl               +name-adr-expl+
						     :start-from-name    +name-start-pagination+
						     :start-from-value   start-from
						     :next-start         next-start
						     :prev-start         prev-start
						     :data-table all-adrs))
					     :stream stream))))

(defun %actual-start (start)
  (if (integer-positive-validate start)
      (parse-integer start)
      0))

(define-lab-route adr ("/adr/" :method :get)
  (with-authentication
    (manage-adr-code nil nil :start-from (get-parameter +name-start-pagination+))))

(define-lab-route add-adr ("/add-adr/" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (add-new-adr-code (get-parameter +name-adr-code-class+)
			    (get-parameter +name-adr-uncode+)
			    (get-parameter +name-adr-expl+)))
      (manage-adr-code nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-adr ("/delete-adr/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
	    (let ((to-trash (single 'db:adr-code :id id)))
	      (when to-trash
		(del (single 'db:adr-code  :id id)))))
	  (manage-adr-code nil nil :start-from (get-parameter +name-start-pagination+)))
      (manage-adr-code nil (list *insufficient-privileges-message*)))))

(define-lab-route assoc-adr-pictogram ("/assoc-adr-pictogram/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (when (and (not (regexp-validate (list (list id +pos-integer-re+ ""))))
		     (not (regexp-validate (list (list (get-parameter +pictogram-form-key+)
						       +pos-integer-re+ "")))))
	    (let ((adr-code (single 'db:adr-code :id id))
		  (pict     (single 'db:adr-pictogram :id (get-parameter +pictogram-form-key+))))
	      (when (and adr-code
			 pict)
		(setf (db:pictogram adr-code) (db:id pict))
		(save adr-code))))
	  (manage-adr-code nil nil :start-from (get-parameter +name-start-pagination+)))
      (manage-adr-code nil (list *insufficient-privileges-message*)))))
