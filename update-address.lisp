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

(defun update-addr (id line-1 city zipcode link)
  (let* ((errors-msg-1 (concatenate 'list
				    (regexp-validate (list (list id
								 +pos-integer-re+
								 (_ "ID invalid"))
							   (list line-1
								 +free-text-re+
								 (_ "Line-1 invalid"))
							   (list city
								 +free-text-re+
								 (_ "City field invalid"))
							   (list zipcode
								 +free-text-re+
								 (_ "Zipcode invalid"))
							   (list link
								 +free-text-re+
								 (_ "Link invalid"))))))
	 (errors-msg-2  (when (and (not errors-msg-1)
				   (not (object-exists-in-db-p 'db:address id)))
			  (list (_ "Address does not exists in database"))))
	 (errors-msg-unique (when (all-null-p errors-msg-1 errors-msg-2)
			      (exists-with-different-id-validate 'db:address
								 id
								 (:line-1 :city :zipcode)
								 (line-1   city  zipcode)
								 (_ "Address already in the database with different ID"))))
	 (errors-msg (concatenate 'list errors-msg-1 errors-msg-2 errors-msg-unique))
	 (success-msg (and (not errors-msg)
			   (list (_ "Address updated")))))
    (if (not errors-msg)
      (let ((address-updated (single 'db:address :id id)))
	(setf (db:line-1  address-updated) line-1
	      (db:city    address-updated) city
	      (db:zipcode address-updated) zipcode
	      (db:link    address-updated) link)
	(save address-updated)
	(manage-update-address (and success-msg id) success-msg errors-msg))
      (manage-address success-msg errors-msg))))

(defun prepare-for-update-address (id)
  (prepare-for-update id
		      'db:address
		      (_ "Address does not exists in database.")
		      #'manage-update-address))

(defun manage-update-address (id infos errors)
  (let ((new-address (and id
			  (object-exists-in-db-p 'db:address id))))
    (with-standard-html-frame (stream (_ "Update Address") :infos infos :errors errors)
      (html-template:fill-and-print-template #p"update-address.tpl"
					     (with-path-prefix
						 :id         (and id
								  (db:id new-address))
						 :line-1-value (and id
								    (db:line-1 new-address))
						 :city-value (and id
								  (db:city new-address))
						 :link-value (and id
								  (db:link new-address))
						 :zipcode-value  (and id
								      (db:zipcode new-address))
						 :line-1      +name-address-line-1+
						 :city        +name-address-city+
						 :zipcode     +name-address-zipcode+
						 :link        +name-address-link+)
					     :stream stream))))

(define-lab-route update-address ("/update-address/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (let ((new-line-1   (get-parameter +name-address-line-1+))
		(new-city     (get-parameter +name-address-city+))
		(new-zipcode  (get-parameter +name-address-zipcode+))
		(new-link     (get-parameter +name-address-link+)))
	    (if (all-not-null-p new-line-1
				new-city
				new-zipcode
				new-link)
		(update-addr id new-line-1 new-city new-zipcode new-link)
		(prepare-for-update-address id))))
      (manage-update-address nil nil (list *insufficient-privileges-message*)))))
