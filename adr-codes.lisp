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

(define-constant +name-adr-expl+       "expl"       :test #'string=)

(define-constant +name-adr-code-class+ "code-class" :test #'string=)

(define-constant +name-adr-uncode+     "uncode"     :test #'string=)

(defun add-new-adr-code (code-class uncode expl)
  (let* ((errors-msg-1  (regexp-validate (list
					  (list code-class +adr-code-class-re+
						"ADR code class invalid")
					  (list uncode +adr-uncode-re+
						"UN code invalid")
					  (list expl +free-text-re+
						"ADR phrase invalid"))))
	 (errors-msg-2  (when (not errors-msg-1)
			  (unique-p-validate* 'db:adr-code
					     (:uncode)
					     (uncode)
					     "ADR code already in the database")))
	 (errors-msg (concatenate 'list errors-msg-1 errors-msg-2))
	 (success-msg (and (not errors-msg)
			   (list (format nil
					 "Saved new ADR code: ~s - ~s"
					 code-class expl)))))
    (when (not errors-msg)
      (let ((ghs (create 'db:adr-code
			 :code-class code-class
			 :uncode uncode
			 :explanation expl)))
	(save ghs)))
    (manage-adr-code success-msg errors-msg)))

(defun manage-adr-code (infos errors)
  (let ((all-ghss (fetch-raw-template-list 'db:adr-code
					   '(:id :code-class :uncode :explanation)
					   :delete-link 'delete-adr)))
    (with-standard-html-frame (stream "Manage ADR codes"
				      :infos  infos
				      :errors errors)
      (html-template:fill-and-print-template #p"add-adr.tpl"
					     (with-path-prefix
						 :code-class +name-adr-code-class+
						 :uncode     +name-adr-uncode+
						 :expl       +name-adr-expl+
						 :data-table all-ghss)
					     :stream stream))))

(define-lab-route adr ("/adr/" :method :get)
  (with-authentication
    (manage-adr-code nil nil)))

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
	  (restas:redirect 'adr))
      (manage-adr-code nil (list *insufficient-privileges-message*)))))
