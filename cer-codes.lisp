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

(define-constant +name-cer-expl+ "expl" :test #'string=)

(define-constant +name-cer-code+ "code" :test #'string=)

(defun add-new-cer-code (code expl)
  (let* ((errors-msg-1  (regexp-validate (list
					  (list code +cer-code-re+ (_"CER code invalid"))
					  (list expl +free-text-re+ (_ "CER phrase invalid")))))
	 (errors-msg-2  (when (not errors-msg-1)
			  (unique-p-validate 'db:cer-code
					     :code
					     code
					     (_ "CER code already in the database"))))
	 (errors-msg (concatenate 'list errors-msg-1 errors-msg-2))
	 (success-msg (and (not errors-msg)
			   (list (format nil
					 (_ "Saved new CER code: ~s - ~s")
					 code expl)))))
    (when (not errors-msg)
      (let ((ghs (create 'db:cer-code
			 :code code
			 :explanation expl)))
	(save ghs)))
    (manage-cer-code success-msg errors-msg)))

(defun manage-cer-code (infos errors)
  (let ((all-ghss (fetch-raw-template-list 'db:cer-code
					   '(:id :code :explanation)
					   :delete-link 'delete-cer)))
    (with-standard-html-frame (stream (_ "Manage CER codes")
				      :infos  infos
				      :errors errors)

      (html-template:fill-and-print-template #p"add-cer.tpl"
					     (with-back-to-root
						 (with-path-prefix
						     :code-lb        (_ "Code")
						     :statement-lb   (_ "Statement")
						     :delete-lb      (_ "Delete")
						     :explanation-lb (_ "Explanation")
						     :code           +name-cer-code+
						     :expl           +name-cer-expl+
						     :data-table all-ghss))
					     :stream stream))))

(define-lab-route cer ("/cer/" :method :get)
  (with-authentication
    (manage-cer-code nil nil)))

(define-lab-route add-cer ("/add-cer/" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (add-new-cer-code (get-parameter +name-cer-code+)
			    (get-parameter +name-cer-expl+)))
      (manage-cer-code nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-cer ("/delete-cer/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
	    (let ((to-trash (single 'db:cer-code :id id)))
	      (when to-trash
		(del (single 'db:cer-code  :id id)))))
	  (restas:redirect 'cer))
      (manage-cer-code nil (list *insufficient-privileges-message*)))))
