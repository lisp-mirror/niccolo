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

(define-constant +name-building-proper-name+     "name"       :test #'string=)

(define-constant +name-building-id+              "id"         :test #'string=)

(define-constant +name-building-address+         "address"    :test #'string=)

(define-constant +name-building-address-id+      "address-id" :test #'string=)

(define-constant +name-building-address-link+    "link"       :test #'string=)

(defun fetch-single-building (id)
  (let ((raw (query
	      (select ((:as :buil.id :bid)
		       :buil.name
		       (:as :add.line-1 :address)
		       :add.city
		       :add.zipcode
		       (:as :add.link :address-link))
		(from (:as :building :buil))
		(left-join (:as :address :add) :on (:= :add.id :buil.address-id))
		(where (:= :bid id))))))
    (and raw
	 (let* ((row (elt raw 0))
		(id      (getf row :|bid|))
		(name    (getf row :|name|))
		(address (concatenate 'string
				      (getf row :|address|) " "
				      (getf row :|city|)    " "
				      (getf row :|zipcode|)))
		(link    (getf row :|address-link|)))
	   (list :id id :name name :address address :link link)))))

(defun fetch-all-buildings (&optional (delete-link nil) (update-link nil))
  (let ((raw (query
	      (select ((:as :buil.id :bid)
		       :buil.name
		       (:as :add.line-1 :address)
		       :add.city
		       :add.zipcode
		       (:as :add.link :address-link))
		(from (:as :building :buil))
		(left-join (:as :address :add) :on (:= :add.id :buil.address-id))))))
    (loop for row in raw collect
	 (let ((id      (getf row :|bid|))
	       (name    (getf row :|name|))
	       (address (format nil "~a ~a ~a"
				     (getf row :|address|)
				     (getf row :|zipcode|)
				     (getf row :|city|)))
	       (link    (getf row :|address-link|)))
	   (append
	    (list :id id :name name :address address :link link)
	     (when delete-link
	       (list :delete-link (restas:genurl delete-link :id id)))
	     (when update-link
	       (list :update-link (restas:genurl update-link :id id))))))))

(gen-autocomplete-functions db:address db:build-complete-address)

(defun manage-building (infos errors)
  (let ((all-buildings (fetch-all-buildings 'delete-building 'update-building-route)))
    (with-standard-html-frame (stream
			       (_ "Manage Buildings")
			       :errors errors
			       :infos  infos)
      (let ((html-template:*string-modifier* #'identity)
	    (json-addresses    (array-autocomplete-address))
	    (json-addresses-id (array-autocomplete-address-id)))
	(html-template:fill-and-print-template #p"add-building.tpl"
					       (with-path-prefix
						   :name-lb       (_ "Name")
						   :address-lb    (_ "Address")
						   :link-lb       (_ "Link")
						   :operations-lb (_ "Operations")
						   :id         +name-building-id+
						   :name       +name-building-proper-name+
						   :address    +name-building-address+
						   :address-id +name-building-address-id+
						   :link       +name-building-address-link+
						   :json-addresses json-addresses
						   :json-addresses-id json-addresses-id
						   :data-table all-buildings)
					       :stream stream)))))

(defun add-new-building (name address-id)
  (let* ((errors-msg-1 (concatenate 'list
				    (regexp-validate   (list
							(list name
							      +free-text-re+
							      (_ "Name invalid"))))
				    (regexp-validate (list
						      (list address-id
							    +pos-integer-re+
							    (_ "Address invalid"))))))
	 (errors-msg-address-not-found (when (and (not errors-msg-1)
						  (not (single 'db:address :id address-id)))
					 (list "Address not in the database")))
	 (errors-msg-already-in-db (when (or (not errors-msg-1)
					     (not errors-msg-address-not-found))
				     (unique-p-validate* 'db:building
							 (:name :address-id)
							 (name  address-id)
							 (_ "Building already in the database"))))
	 (errors-msg (concatenate 'list
				  errors-msg-1
				  errors-msg-already-in-db
				  errors-msg-address-not-found))
	 (success-msg (and (not errors-msg)
			   (list (format nil (_ "Saved building: ~s - ~s") name
					 (db:build-complete-address
					  (single 'db:address :id address-id)))))))
    (when (not errors-msg)
      (let ((building (create 'db:building
			      :name name
			      :address-id address-id)))

	(save building)))
    (manage-building success-msg errors-msg)))

(define-lab-route building ("/building/" :method :get)
  (with-authentication
    (manage-building nil nil)))

(define-lab-route add-building ("/add-building/" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (add-new-building (get-parameter +name-building-proper-name+)
			    (get-parameter +name-building-address-id+)))
      (manage-building nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-building ("/delete-building/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(progn
	  (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
	    (let ((to-trash (single 'db:building :id id)))
	      (when to-trash
		(del (single 'db:building :id id)))))
	  (restas:redirect 'building))
      (manage-building nil (list *insufficient-privileges-message*)))))
