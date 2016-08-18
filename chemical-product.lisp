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

(define-constant +name-chem-id+                        "id"                        :test #'string=)

(define-constant +name-chp-storage-id+                 "sid"                       :test #'string=)

(define-constant +name-shelf+                          "shelf"                     :test #'string=)

(define-constant +name-quantity+                       "qty"                       :test #'string=)

(define-constant +name-units+                          "units"                     :test #'string=)

(define-constant +name-count+                          "count"                     :test #'string=)

(define-constant +name-shortage-threshold+             "shortage-thrs"             :test #'string=)

(define-constant +name-notes+                          "notes"                     :test #'string=)

(define-constant +op-submit-gen-barcode+               "Generate barcode"          :test #'string=)

(define-constant +op-submit-lend-to+                   "Lend to"                   :test #'string=)

(define-constant +op-submit-massive-delete+            "Delete selected"           :test #'string=)

(define-constant +op-submit-change-shortage-threshold+ "Change shortage threshold" :test #'string=)

(define-constant +name-username-lending+               "username-lending"          :test #'string=)

(define-constant +name-chem-cid-exists+                "chem-cid-exists"           :test #'string=)

(define-constant +default-shortage-threshold+          5                  :test #'=)

(gen-autocomplete-functions db:chemical-compound db:name)

(defun make-pubchem-2d (cid &key (size :small))
  (let ((path  (format nil "/rest/pug/compound/cid/~a/PNG" cid))
	(query (list (cons "image_size" (if (eq size :small) "small" "large")))))
    (puri:render-uri (make-instance 'puri:uri
				    :scheme :https
				    :host +pubchem-host+ :path path
				    :query (alist->query-uri query))
		     nil)))

(defmacro gen-all-prod-select (&body where)
  `(select ((:as :chemp.id             :chemp-id)
	    (:as :chemp.shelf          :shelf)
	    (:as :chemp.quantity       :quantity)
	    (:as :chemp.units          :units)
	    (:as :chemp.validity-date  :validity-date)
	    (:as :chemp.expire-date    :expire-date)
	    (:as :chemp.notes          :notes)
	    (:as :chem.name            :chem-name)
	    (:as :chem.id              :chem-id)
	    (:as :chem.pubchem-cid     :chem-cid)
	    (:as :user.username        :owner-name)
	    (:as :user.id              :owner-id)
	    (:as :storage.id           :storage-id)
	    (:as :storage.name         :storage-name)
	    (:as :storage.floor-number :storage-floor)
	    (:as :storage.map-id       :storage-map-id)
	    (:as :storage.s-coord      :storage-s-coord)
	    (:as :storage.t-coord      :storage-t-coord)
	    (:as :chemp-prefs.shortage :shortage-threshold)
	    (:as :bui.id               :building-id)
	    (:as :bui.name             :building-name))
     (from (:as :chemical-product      :chemp))
     (left-join :storage                       :on (:= :chemp.storage       :storage.id))
     (left-join (:as :building  :bui)          :on (:= :storage.building-id :bui.id))
     (left-join (:as :address   :addr)         :on (:= :bui.address-id      :addr.id))
     (left-join (:as :chemical-compound :chem) :on (:= :chemp.compound      :chem.id))
     (left-join :user                          :on (:= :chemp.owner         :user.id))
     (left-join (:as :chemical-compound-preferences :chemp-prefs)
		:on
		(:and (:= :chemp-prefs.owner    :user.id)
		      (:= :chemp-prefs.compound :chem.id)))
     ,@where))

(defun actual-image-unknown-struct-path ()
  (concatenate 'string +path-prefix+ +image-unknown-struct-path+))

(defun build-template-list-chemical-prod (raw
					  &optional
					    (delete-link nil)
					    (update-link nil))
  (setf raw (map 'list #'(lambda (row)
			   (map 'list
				#'(lambda (cell)
				    (if (symbolp cell)
					(make-keyword (string-upcase (symbol-name cell)))
					cell))
				row))
		 raw))
  (do-rows (rown res) raw
    (let* ((row (elt raw rown))
	   (building-link    (restas:genurl 'ws-building   :id (getf row :building-id)))
	   (ghs-haz-link     (restas:genurl 'ws-ghs-hazard :id (getf row :chem-id)))
	   (ghs-prec-link    (restas:genurl 'ws-ghs-prec   :id (getf row :chem-id)))
	   (msds-link        (restas:genurl 'chemical-get-msds :id (getf row :chem-id)))
	   (barcode-link     (restas:genurl 'single-barcode :id (getf row :chemp-id)))
	   (thumbnail-link   (if (not (eq (getf row :chem-cid) :nil))
				 (make-pubchem-2d (getf row :chem-cid))
				 (actual-image-unknown-struct-path)))
	   (structure-link   (if (not (eq (getf row :chem-cid) :nil))
				 (make-pubchem-2d (getf row :chem-cid) :size :large)
				 (actual-image-unknown-struct-path)))
	   (remove-loan-link (restas:genurl 'remove-loan :id (getf row :chemp-id)))
	   (lending-user  (fetch-loan (getf row :chemp-id)))
	   (gen-custom-label-link  (restas:genurl 'gen-custom-label :id (getf row :chemp-id)))
	   (encoded-expire-date    (encode-datetime-string (getf row :expire-date)))
	   (encoded-validity-date  (encode-datetime-string (getf row :validity-date)))
	   (decoded-expire-date    (decode-datetime-string encoded-expire-date))
	   (decoded-validity-date  (decode-datetime-string encoded-validity-date)))
      (setf (elt raw rown)
	    (nconc row
		   (list :storage-link
			 (if (not (eq (getf row :storage-map-id) :nil))
			     (gen-map-storage-link (getf row :storage-map-id)
						   (getf row :storage-s-coord)
						   (getf row :storage-t-coord))
			     nil))
		   (list :expire-date-encoded   encoded-expire-date)
		   (list :validity-date-encoded encoded-validity-date)
		   (list :expire-date-decoded   decoded-expire-date)
		   (list :validity-date-decoded decoded-validity-date)
		   (list :building-link building-link)
		   (list :ghs-haz-link  ghs-haz-link)
		   (list :ghs-prec-link ghs-prec-link)
		   (list :msds-link     msds-link)
		   (list :barcode-link  barcode-link)
		   (list :thumbnail-link  thumbnail-link)
		   (list :structure-link  structure-link)
		   (list :checkbox-id   (getf row :chemp-id))
		   (list :chem-cid-exists (not (eq (getf row :chem-cid) :nil)))
		   (list :lending-user  lending-user)
		   (list :remove-lending-link remove-loan-link)
		   (list :gen-custom-label-link gen-custom-label-link)
		   (if delete-link
		       (list :delete-link (restas:genurl delete-link
							 :id    (getf row :chemp-id)
							 :owner (getf row :owner-id)))
		       nil)
		   (if update-link
		       (list :update-link (restas:genurl update-link
							 :id    (getf row :chemp-id)
							 :owner (getf row :owner-id)))
		       nil)))))
  raw)

(defun fetch-loan (product-id)
  (let ((raw (query (select ((:as :u.username :username))
		      (from :loans)
		      (left-join (:as :user :u) :on (:= :loans.user-to :u.id))
		      (where (:= :loans.product product-id))))))
    (cadar raw)))

(defun fetch-expired-products ()
  (with-session-user (user)
    (let* ((expiration-date (next-expiration-date))
	   (expired         (build-template-list-chemical-prod (query (gen-all-prod-select
									(where
									 (:and
									  (:= :chemp.owner (db:id user))
									  (:< :expire-date expiration-date))))))))
      expired)))

(defun fetch-validity-expired-products ()
  (with-session-user (user)
    (let* ((expiration-date (next-expiration-date))
	   (expired         (build-template-list-chemical-prod (query (gen-all-prod-select
									(where
									 (:and
									  (:= :chemp.owner (db:id user))
									  (:< :validity-date expiration-date))))))))
      expired)))

(defun fetch-product-by-id (id &optional (delete-link nil) (update-link nil))
  (build-template-list-chemical-prod (query (gen-all-prod-select (where (:= :chemp-id id))))
				     delete-link
				     update-link))

(defun fetch-product (owner chem-name building-name floor storage-name shelf
		      &optional
			(delete-link nil)
			(update-link nil))
  (let ((raw (query (gen-all-prod-select (where
					  (:and (:like :owner-name
						       (prepare-for-sql-like owner))
						(:like :chem-name
						       (prepare-for-sql-like chem-name))
						(:like :building-name
						       (prepare-for-sql-like building-name))
						(if floor
						    (list := :storage-floor floor)
						    (list := 1 1))
						(:like :storage-name
						       (prepare-for-sql-like storage-name))
						(if shelf
						    (list := :shelf shelf)
						    (list := 1 1))))))))
    (build-template-list-chemical-prod raw delete-link update-link)))

(defun fetch-product-min-id (id &optional (delete-link nil) (update-link nil))
  (let ((raw (query (gen-all-prod-select (where
					  (:> :chemp-id id))))))
    (build-template-list-chemical-prod raw delete-link update-link)))

(defun fetch-all-product (&optional (delete-link nil) (update-link nil))
  (let ((raw (query (gen-all-prod-select))))
    (build-template-list-chemical-prod raw delete-link update-link)))

(defun manage-chem-prod (infos errors &key (data (fetch-all-product 'delete-chem-prod
								    'update-chemical-product)))
  (with-standard-html-frame (stream
			     (_ "Manage Chemical Products")
			     :errors errors
			     :infos  infos)
    (let ((html-template:*string-modifier* #'html-template:escape-string-minimal)
	  (json-chemical    (array-autocomplete-chemical-compound))
	  (json-chemical-id (array-autocomplete-chemical-compound-id)))
      (multiple-value-bind (json-storage-id json-storage)
	  (json-all-storage-long-desc)
	(html-template:fill-and-print-template #p"add-chemical-product.tpl"
					       (with-path-prefix
						   :add-new-product-lb (_ "Add new product")
						   :compound-name-lb  (_ "Compound name")
						   :storage-name-lb   (_ "Storage name")
						   :shelf-lb          (_ "Shelf")
						   :quantity-lb      (_ "Quantity (Mass or Volume)")
						   :units-lb          (_ "Unit of measure")
						   :expire-date-lb    (_ "Expire date")
						   :validity-date-lb  (_ "Validity date")
						   :item-count-lb     (_ "Item count")
						   :search-products-legend-lb (_ "Search products")
						   :barcode-number-lb  (_ "Barcode number (ID)")
						   :owner-lb           (_ "Owner")
						   :name-lb            (_ "Name")
						   :building-lb        (_ "Building")
						   :floor-lb           (_ "Floor")
						   :shelf-lb           (_ "Shelf")
						   :notes-optional-lb  (_ "Notes (optional)")
						   :other-operations-lb (_ "Other operations")
						   :submit-gen-barcode-lb  (_ "Generate barcode")
						   :submit-massive-delete-lb  (_ "Delete")
						   :lending-lb          (_ "Lending")
						   :submit-lend-to-lb   (_ "Lend to")
						   :shortage-threshold-lb (_ "Shortage threshold")
						   :threshold-lb          (_ "Threshold")
						   :submit-shortage-lb    (_ "Change threshold")
						   :user-lb             (_ "User")
						   :sum-quantities-lb   (_ "Sum quantities")
						   :select-all-lb       (_ "Select all")
						   :deselect-all-lb     (_ "Deselect all")
						   :select-lb           (_ "Select")
						   :owner-lb            (_ "Owner")
						   :structure-lb        (_ "Structure")
						   :storage-lb          (_ "Storage")
						   :notes-lb            (_ "Notes")
						   :operations-lb       (_ "Operations")
						   :origin-lb           (_ "Origin")
						   :fq-table-res-header (_ "Results from federated servers")
						   :chemical-id +name-chem-id+
						   :storage-id  +name-chp-storage-id+
						   :shelf       +name-shelf+
						   :quantity    +name-quantity+
						   :units       +name-units+
						   :validity-date  +name-validity-date+
						   :expire-date +name-expire-date+
 						   :count       +name-count+
						   :shortage-threshold +name-shortage-threshold+
						   :shortage-threshold-value
						   +default-shortage-threshold+
						   :submit-change-shortage
						   +op-submit-change-shortage-threshold+
						   :notes       +name-notes+
						   :json-storages-id  json-storage-id
						   :json-storages  json-storage
						   :json-chemicals json-chemical
						   :json-chemicals-id json-chemical-id
						   :value-owner       (get-session-username)
						   :chemp-id          +search-chem-id+
						   :chem-cid-exists  +name-chem-cid-exists+
						   :pubchem-host +pubchem-host+
						   :owner +search-chem-owner+
						   :name  +search-chem-name+
						   :building +search-chem-building+
						   :floor +search-chem-floor+
						   :storage +search-chem-storage+
						   :search-shelf +search-chem-shelf+
						   :submit-gen-barcode +op-submit-gen-barcode+
						   :submit-massive-delete +op-submit-massive-delete+
						   :submit-lend-to     +op-submit-lend-to+
						   :username-lending   +name-username-lending+
						   ;; federated query
						   :fq-start-url  (restas:genurl 'ws-federated-query-product)
						   :fq-results-url (restas:genurl 'ws-federated-query-product-results)
						   :fq-query-key-param +query-http-parameter-key+
						   :data-table data)
					       :stream stream)))))

(defun %match-or-null (s re)
  (let ((match (scan re s)))
    (if (or (string= re +integer-re+)
	    (string= re +pos-integer-re+)
	    (string= re +barcode-id-re+))
	(if match
	    (parse-integer s)
	    nil)
	(if match
	    s
	    ""))))

(defun search-products (id owner chem-name building-name floor storage-name shelf)
  (if (not (string-empty-p id))
      (manage-chem-prod nil nil :data (fetch-product-by-id (%match-or-null id +barcode-id-re+)
							   'delete-chem-prod
							   'update-chemical-product))
      (manage-chem-prod nil nil	:data (fetch-product (%match-or-null owner +free-text-re+)
						     (%match-or-null chem-name +free-text-re+)
						     (%match-or-null building-name +free-text-re+)
						     (%match-or-null floor +integer-re+)
						     (%match-or-null storage-name +free-text-re+)
						     (%match-or-null shelf +pos-integer-re+)
						     'delete-chem-prod
						     'update-chemical-product))))

(defun add-single-chem-prod (chemical-id storage-id shelf quantity units notes
			     validity-date expire-date)
  (with-session-user (user)
    (let* ((errors-msg-1 (regexp-validate (list
					   (list chemical-id +pos-integer-re+  (_ "Chemical invalid"))
					   (list storage-id  +pos-integer-re+  (_ "Storage invalid"))
					   (list shelf       +pos-integer-re+  (_ "Shelf not an integer"))
					   (list (clean-string notes)
						 +free-text-re+ (_ "Notes invalid"))
					   (list quantity    +pos-integer-re+ (_ "Quantity invalid"))
					   (list units       +free-text-re+ (_ "Units invalid")))))
	   (errors-msg-chem-not-found (when (and (not errors-msg-1)
						 (not (single 'db:chemical-compound
							      :id chemical-id)))
					(list (_ "Chemical compound not in the database"))))
	   (errors-msg-stor-not-found (when (and (not errors-msg-1)
						 (not errors-msg-chem-not-found)
						 (not (single 'db:storage
							      :id storage-id)))
					(list (_ "Storage not in the database"))))
	   (errors-msg-validity-date       (when (not (date-validate-p validity-date))
					  (list (_ "Validity date not valid"))))
	   (errors-msg-expire-date       (when (not (date-validate-p expire-date))
					   (list (_ "Expire date not valid"))))
	   (errors-msg (concatenate 'list
				    errors-msg-1
				    errors-msg-chem-not-found
				    errors-msg-stor-not-found
				    errors-msg-validity-date
				    errors-msg-expire-date))
	   (success-msg (and (not errors-msg)
			     (list (format nil (_ "Saved chemical product"))))))
      (when (and user
		 (not errors-msg))
	(let* ((chem (create 'db:chemical-product
			    :compound      chemical-id
			    :storage       storage-id
			    :shelf         shelf
			    :quantity      quantity
			    :units         units
			    :validity-date (encode-datetime-string validity-date)
			    :expire-date   (encode-datetime-string expire-date)
			    :owner         (db:id user)
			    :notes         (clean-string notes))))
	  (save chem))) ; useless?
      (values errors-msg success-msg))))

(define-lab-route search-chem-prod ("/search-chem-prod/" :method :get)
  (with-authentication
    (if (or (get-parameter +search-chem-id+)
	    (get-parameter +search-chem-owner+)
	    (get-parameter +search-chem-name+)
	    (get-parameter +search-chem-building+)
	    (get-parameter +search-chem-floor+)
	    (get-parameter +search-chem-storage+)
	    (get-parameter +search-chem-shelf+))
	(search-products (get-parameter +search-chem-id+)
			 (get-parameter +search-chem-owner+)
			 (get-parameter +search-chem-name+)
			 (get-parameter +search-chem-building+)
			 (get-parameter +search-chem-floor+)
			 (get-parameter +search-chem-storage+)
			 (get-parameter +search-chem-shelf+))
	(manage-chem-prod nil nil))))

(define-lab-route chem-prod ("/chem-prod/" :method :get)
  (with-authentication
    (manage-chem-prod nil nil :data nil)))

(define-lab-route add-chem-prod ("/add-chem-prod/" :method :get)
  (with-authentication
    (let ((max-id (get-max-id "chemical-product")))
      (if (and (get-parameter +name-count+)
	       (scan +pos-integer-re+ (get-parameter +name-count+)))
	  (let ((errors (loop named add-loop repeat (parse-integer (get-parameter +name-count+)) do
			     (let ((actual-notes (regex-replace-all "\\n"
								    (get-parameter +name-notes+)
								    "")))
			       (multiple-value-bind (err success)
				   (add-single-chem-prod (get-parameter +name-chem-id+)
							 (get-parameter +name-chp-storage-id+)
							 (get-parameter +name-shelf+)
							 (get-parameter +name-quantity+)
							 (get-parameter +name-units+)
							 (if (string/= "" actual-notes)
							     actual-notes
							     "none")
							 (get-parameter +name-validity-date+)
							 (get-parameter +name-expire-date+))
				 (declare (ignore success))
				 (when err
				   (return-from add-loop err)))))))
	    (if errors
		(manage-chem-prod nil errors)
		(manage-chem-prod (list (_ "Successfully added products")) nil
				  :data (fetch-product-min-id max-id 'delete-chem-prod))))
	  (manage-chem-prod nil (list (_ "Item count must be a positive integer")))))))

(define-lab-route delete-chem-prod ("/delete-chem-prod/:id/:owner" :method :get)
  (with-authentication
    (with-session-user (user)
      (when (not (regexp-validate (list (list id +pos-integer-re+ "no")
					(list owner +pos-integer-re+ "no"))))
	(let ((to-trash (single 'db:chemical-product :id (parse-integer id))))
	  (if (and to-trash
		   (or (session-admin-p)
		       (= (db:id user) (parse-integer owner))))
	      (progn
		(del to-trash)
		(manage-chem-prod (list (_ "Product deleted")) nil))
	      (manage-chem-prod nil (list (_ "Product not deleted")))))))))

(defun lend-to (from-uid to-username id)
  (let* ((errors-msg-1 (regexp-validate (list
					 (list to-username +free-text-re+ (_ "Username invalid"))
					 (list id          +pos-integer-re+
					       (_ "Id product invalid"))))))
    (if errors-msg-1
	(manage-chem-prod nil errors-msg-1)
	(if (not (single 'db:user :id from-uid))
	    (manage-chem-prod nil (list (_ "You are not an user!")))
	    (if (not (single 'db:user :username to-username))
		(manage-chem-prod nil (list (format nil (_ "There is not any user called ~s")
						    to-username)))
		(if (not (single 'db:chemical-product :id (parse-integer id)))
		    (manage-chem-prod nil (list (_ "Id product invalid")))
		    (if (single 'db:loans :product (parse-integer id))
			(manage-chem-prod nil (list (_ "Product already lent")))
			(if (not (= (db:owner (single 'db:chemical-product
						      :id (parse-integer id)))
				    from-uid))
			    (manage-chem-prod nil (list (_ "You do not own this product")))
			    (if (= (db:id (single 'db:user :username to-username)) from-uid)
				(manage-chem-prod nil (list (_ "You can not lend to yourself")))
				(progn
				  (create 'db:loans
					  :product   (parse-integer id)
					  :user-from from-uid
					  :user-to   (db:id (single 'db:user
								    :username to-username)))
				  (manage-chem-prod (list (format nil (_ "Lent product to ~a")
								  to-username))
						    nil)))))))))))

(define-lab-route remove-loan ("/lending-remove/:id" :method :get)
  (with-authentication
    (let* ((act-product-id (or (scan-to-strings +pos-integer-re+ id) +db-invalid-id+))
	   (loan (single 'db:loans :product (parse-integer act-product-id))))
      (if (and loan
	       (= (get-session-user-id) (db:user-from loan)))
	  (progn
	    (del loan)
	    (manage-chem-prod (list (_ "Success")) nil))
	  (manage-chem-prod nil (list (_ "Failure")))))))

(defun get-code (key row)
  (if (eq (getf key row) :nil)
      ""
      (getf key row)))

(defun generate-ps-custom-label (product)
  (let ((haz-data (keywordize-query-results
		   (query
		    (select ((:as :chem.name               :name)
			     (:as :ghs-h.code              :code-h)
			     (:as :ghs-pict.pictogram-file :pictogram)
			     (:as :user.username           :owner))
		      (from (:as :chemical-product :chemp))
		      (left-join :user
				 :on
				 (:= :chemp.owner          :user.id))
		      (left-join (:as :chemical-compound   :chem)
				 :on
				 (:= :chemp.compound       :chem.id))
		      (left-join (:as :chemical-hazard     :chem-haz)
				 :on
				 (:= :chem-haz.compound-id  :chem.id))
		      (left-join (:as :ghs-hazard-statement :ghs-h)
				 :on
				 (:= :ghs-h.id             :chem-haz.ghs-h))
		      (left-join (:as :ghs-pictogram       :ghs-pict)
				 :on
				 (:= :ghs-pict.id          :ghs-h.pictogram))
		      (where
		       (:= :chemp.id (db:id product)))))))
	(prec-data (keywordize-query-results
		    (query
		     (select ((:as :ghs-p.code              :code-p))
		       (from (:as :chemical-product :chemp))
		       (left-join (:as :chemical-compound   :chem)
				  :on
				  (:= :chemp.compound       :chem.id))
		       (left-join (:as :chemical-precautionary  :chem-prec)
				  :on
				  (:= :chem-prec.compound-id  :chem.id))
		       (left-join (:as :ghs-precautionary-statement :ghs-p)
				  :on
				  (:= :ghs-p.id             :chem-prec.ghs-p))
		       (where
			(:= :chemp.id (db:id product))))))))
    (with-a4-lanscape-ps-doc (doc)
      (let ((font (default-font doc))
	    (h1   20.0)
	    (h2   8.0)
	    (starting-text-area (- (ps:height +a4-landscape-page-sizes+)
				   +header-image-export-height+))
	    (pict-size          +header-image-export-height+))
	(ps:setcolor doc ps:+color-type-fillstroke+ (cl-colors:rgb 0.0 0.0 0.0))
	(ps:setfont doc font 4.0)
	(ps:set-parameter   doc ps:+value-key-linebreak+ ps:+true+)
	(ps:set-parameter   doc ps:+parameter-key-imageencoding+ ps:+image-encoding-type-hex+)
	(with-save-restore (doc)
	  (let ((font (default-font doc)))
	    (ps:setfont doc font h1)
	    (ps:translate doc +page-margin-left+ (- starting-text-area h1))
	    (ps:show-xy doc (getf (elt haz-data 0) :name (_ "error")) 0 0)))
	(loop
	   for row in haz-data
	   for y = (- starting-text-area (* 2.0 h1))  then (- y h2) do
	     (let ((font (default-font doc)))
	       (with-save-restore (doc)
		 (ps:setfont doc font h2)
		 (ps:translate doc +page-margin-left+ y)
		 (ps:show-xy doc (get-code row :code-h) 0 0))))

	(let ((all-prec-str (reduce #'(lambda (a b) (concatenate 'string a "; " b))
				    (loop for row in prec-data collect (get-code row :code-p))))
	      (font (default-font doc))
	      (available-space (- starting-text-area
				  (* 2.0 h1)
				  (* h2  (length haz-data))
				  +page-margin-top+
				  pict-size)))
	  (with-save-restore (doc)
	    (ps:setfont doc font h2)
	    (ps:show-boxed doc
			   all-prec-str
			   +page-margin-left+
			   (- starting-text-area
			      (* 2.0 h1)
			      (* h2  (length haz-data))
			      +page-margin-top+)
			   (- (ps:width +a4-landscape-page-sizes+) 20)
			   0
			   ps:+boxed-text-h-mode-justify+
			   ps:+boxed-text-feature-blind+))
	  (with-save-restore (doc)
	    (let* ((ideal-box-height (ps:point->millimeter (ps:get-value doc ps:+value-key-boxheight+)))
		   (box-height-scale (/ available-space ideal-box-height)))
	      (ps:setfont doc font (min h2 (* h2 box-height-scale)))
	      (ps:show-boxed doc
			     all-prec-str
			     +page-margin-left+
			     (- starting-text-area
				(* 2.0 h1)
				(* h2  (length haz-data)))
			     (- (ps:width +a4-landscape-page-sizes+) 20)
			     0
			     ps:+boxed-text-h-mode-justify+
			     ""))))
	(loop
	   for row in (remove-duplicates haz-data
					 :key  #'(lambda (a) (getf a :pictogram))
					 :test #'string=)
	   for x = +page-margin-left+ then (+ x pict-size) do
	     (with-save-restore (doc)
	       (when (not (eq (getf row :pictogram) :nil))
		 (let* ((pict-path (uiop:unix-namestring (local-system-path (getf row :pictogram))))
			(pict-img  (ps:open-image-file doc
						     ps:+image-file-type-eps+
						     pict-path
						     "" 0)))
		   (ps:translate doc x pict-size)
		   (ps:place-image doc pict-img 0.0 0.0 1.0)))))
	(with-save-restore (doc)
	  (ps:translate doc +page-margin-left+ (/ pict-size 2.0))
	  (ps:show-xy doc
		      (format nil (_ "Owner: ~a. Printing date ~a Validity: ~a Expire: ~a")
			      (and haz-data (getf (elt haz-data 0) :owner))
			      (now-date-for-label)
			      (decode-datetime-string (db::validity-date product))
			      (decode-datetime-string (db::expire-date product)))
		      0 0))))))

(define-lab-route gen-custom-label ("/custom-label/:id" :method :get)
  (with-authentication
    (let* ((act-product-id (or (scan-to-strings +pos-integer-re+ id) +db-invalid-id+))
	   (product        (single 'db:chemical-product
				   :id (parse-integer act-product-id))))
      (if product
	  (progn
	    (setf (header-out :content-type) +mime-postscript+)
	    (generate-ps-custom-label product))
	  (manage-chem-prod nil (list (_ "Failure")))))))

(defun massive-delete (ids)
  (with-authentication
    (with-session-user (user)
      (let ((all-errors   "")
	    (all-messages ""))
	(loop for id in ids do
	     (if (not (regexp-validate (list (list id +pos-integer-re+ (_ "no")))))
		 (let ((product (crane:single 'db:chemical-product :id id)))
		   (if (and (not (null product))
			    (or (session-admin-p)
				(= (db:id user) (db:owner product))))
		       (progn
			 (setf all-messages (concatenate 'string
							 all-messages
							 (format nil
								 (_ "Product ~a deleted. ")
								 id)))
			 (crane:del product))
		       (setf all-errors (concatenate 'string
						     all-errors
						     (concatenate 'string
							 all-messages
							 (format nil
								 (_ "Product ~a not deleted. ")
								 id))))))))
	(manage-chem-prod (and (not (string= "" all-messages))
			       (list all-messages))
			  (and (not (string= "" all-errors))
			       (list all-errors)))))))

(defun manage-threshold (id shortage)
  (with-authentication
    (with-session-user (user)
      (let* ((errors-shortage-not-int  (when (not (integer-positive-validate shortage))
					 (list (_ "Shortage threshold non valid (must be a positive integer"))))
	     (errors-msg-chem-not-found (when (and (not errors-shortage-not-int)
						   (not (single 'db:chemical-compound
								:id id)))
					  (list (_ "Chemical compound not in the database"))))
	     (errors-msg (concatenate 'list
				      errors-shortage-not-int
				      errors-msg-chem-not-found))
	     (success-msg (and (not errors-msg)
			       (list (format nil (_ "Updated chemical shortage threshold."))))))
	(when (and user
		   (not errors-msg))
	  (let ((threshold (single-or-create 'db:chemical-compound-preferences
					     :compound id
					     :owner (db:id user))))
	    (setf (db:shortage threshold) (parse-integer shortage))
	    (save threshold)))
	(manage-chem-prod success-msg errors-msg)))))

(define-lab-route others-op-chem-prod ("/others-op-chem-prod/" :method :post)
  (with-authentication
    (let ((all-ids (remove-if #'(lambda (a) (not (scan +pos-integer-re+ a)))
			      (map 'list #'first (post-parameters*)))))
      (cond
	((post-parameter +op-submit-gen-barcode+)
	 (setf (header-out :content-type) +mime-postscript+)
	 (render-many-barcodes all-ids))
	((post-parameter +op-submit-lend-to+)
	 (lend-to (get-session-user-id) (post-parameter +name-username-lending+)
		  (or (first all-ids) "")))
	((post-parameter +op-submit-massive-delete+)
	 (massive-delete all-ids))
	((post-parameter  +op-submit-change-shortage-threshold+)
	 (manage-threshold  (post-parameter +name-chem-id+)
			    (post-parameter +name-shortage-threshold+)))
	(t
	 (manage-chem-prod nil nil :data nil))))))
