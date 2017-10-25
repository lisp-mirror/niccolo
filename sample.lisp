; niccolo': a chemicals inventory
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

(define-constant +name-sample-id+                  "id"          :test #'string=)

(define-constant +name-sample-name+                "sname"       :test #'string=)

(define-constant +name-checkin-date+               "chkin-date"  :test #'string=)

(define-constant +name-checkout-date+              "chkout-date" :test #'string=)

(define-constant +name-sample-search-name+         "sname"       :test #'string=)

(define-constant +name-use-barcode-label+          "chkbox-w"    :test #'string=)

(define-constant +name-h-label+                    "h-label"     :test #'string=)

(define-constant +name-w-label+                    "w-label"     :test #'string=)

(defmacro gen-all-sample-select (&body where)
  `(select ((:as :sample.id            :sample-id)
	    (:as :sample.name          :sample-name)
            (:as :sample.quantity      :quantity)
            (:as :sample.units         :units)
            (:as :sample.checkin-date  :checkin-date)
            (:as :sample.checkout-date :checkout-date)
            (:as :sample.notes         :notes)
            (:as :user.username        :owner-name)
            (:as :user.id              :owner-id)
            (:as :lab.id               :lab-id)
            (:as :lab.name             :lab-name))
     (from (:as :chemical-sample :sample))
     (left-join (:as :laboratory :lab) :on (:= :sample.laboratory-id :lab.id))
     (left-join :user                  :on (:= :lab.owner            :user.id))
     ,@where))

(defun build-template-list-samples (raw
                                    &optional
                                      (delete-link nil)
                                      (update-link nil))
  (setf raw (keywordize-query-results raw))
  (do-rows (rown res) raw
    (let* ((row (elt raw rown))
           (encoded-checkin-date  (encode-datetime-string (getf row :checkin-date)))
           (encoded-checkout-date (encode-datetime-string (getf row :checkout-date)))
           (decoded-checkout-date (decode-datetime-string encoded-checkout-date))
           (decoded-checkin-date  (decode-date-string     encoded-checkin-date))
	   (gen-custom-label-link (restas:genurl 'gen-sample-custom-label
						 :id (getf row :sample-id))))
      (setf (elt raw rown)
            (concatenate 'list
                         row
                         (list :checkin-date-encoded   encoded-checkin-date)
                         (list :checkout-date-encoded  encoded-checkout-date)
                         (list :checkin-date-decoded   decoded-checkin-date)
                         (list :checkout-date-decoded  decoded-checkout-date)
			 (list :shortened-notes        (string-utils:ellipsize (getf row :notes)))
                         (list :checkbox-id            (getf row :sample-id))
			 (list :gen-custom-label-link  gen-custom-label-link)
                         (if delete-link
                             (list :delete-link (restas:genurl delete-link
                                                               :id (getf row :sample-id)))
                             nil)
                         (if update-link
                             (list :update-link (restas:genurl update-link
                                                               :id (getf row :sample-id)))
                             nil)))))
    raw)

(defun fetch-sample-by-id (id &optional (delete-link nil) (update-link nil))
  (when id
    (build-template-list-samples (query (gen-all-prod-select (where (:= :sample-id id))))
                                 delete-link
                                 update-link)))

(defun fetch-sample (owner sample-name lab-name &optional
                                                (delete-link nil)
                                                (update-link nil))
  (let ((raw (query (gen-all-sample-select (where
                                            (:and (:like :owner-name
                                                         (prepare-for-sql-like owner))
                                                  (:like :sample-name
                                                         (prepare-for-sql-like sample-name))
                                                  (:like :lab-name
                                                         (prepare-for-sql-like lab-name))))))))
    (build-template-list-samples raw delete-link update-link)))

(defun fetch-sample-min-id (id &optional (delete-link nil) (update-link nil))
  (let ((raw (query (gen-all-sample-select (where
                                            (:> :chemp-id id))))))
    (build-template-list-samples raw delete-link update-link)))

(defun fetch-all-samples (&optional (delete-link nil) (update-link nil))
  (let ((raw (query (gen-all-sample-select))))
    (build-template-list-samples raw delete-link update-link)))

(defun manage-sample (infos errors &key (data nil))
  (with-standard-html-frame (stream
                             (_ "Manage Samples")
                             :errors errors
                             :infos  infos)
    (let ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
	  (json-laboratory    (array-autocomplete-laboratory))
          (json-laboratory-id (array-autocomplete-laboratory-id))
	  (has-local-results-p (> (length data) 0)))
      (html-template:fill-and-print-template #p"add-samples.tpl"
                                             (with-path-prefix
                                                 :add-new-sample-lb       (_ "Add new sample")
						 :search-sample-legend-lb (_ "Search sample")
                                                 :sample-name-lb          (_ "Name")
                                                 :lab-name-lb             (_ "Laboratory")
                                                 :quantity-lb
                                                 (_ "Quantity (Mass or Volume)")
                                                 :units-lb                  (_ "Unit of measure")
                                                 :checkin-date-lb           (_ "Checkin date")
						 :checkout-date-lb          (_ "Checkout date")
                                                 :item-count-lb             (_ "Item count")
                                                 :search-samples-legend-lb  (_ "Search samples")
                                                 :barcode-number-lb
                                                 (_ "Barcode number (ID)")
                                                 :name-lb                   (_ "Name")
                                                 :notes-lb                  (_ "Notes")
                                                 :other-operations-lb       (_ "Other operations")
                                                 :submit-gen-barcode-lb     (_ "Generate")
                                                 :submit-massive-delete-lb  (_ "Delete")
                                                 :sum-quantities-lb         (_ "Sum quantities")
                                                 :select-all-lb             (_ "Select all")
                                                 :deselect-all-lb           (_ "Deselect all")
                                                 :select-lb                 (_ "Select")
                                                 :checkbox-use-barcode-lb   (_ "Draw barcode")
                                                 :notes-lb                  (_ "Notes")
                                                 :operations-lb             (_ "Operations")
                                                 :origin-lb                 (_ "Origin")
                                                 :table-res-header          (_ "Results")
                                                 :width-lb                  (_ "Width (mm)")
                                                 :height-lb                 (_ "Height (mm)")
                                                 :draw-labels-lb            (_ "Generate labels")
                                                 :sample-name               +name-sample-name+
                                                 :labs-id                   +name-lab-id+
                                                 :quantity                  +name-quantity+
                                                 :units                     +name-units+
                                                 :checkin-date              +name-checkin-date+
                                                 :count                     +name-count+
						 :notes                     +name-notes+
						 :sample-search-name
                                                 +name-sample-search-name+
                                                 :submit-massive-delete
                                                 +op-submit-massive-delete+
                                                 :submit-gen-barcode        +op-submit-gen-barcode+
                                                 :w-label                   +name-w-label+
                                                 :h-label                   +name-h-label+
                                                 :checkbox-use-barcode      +name-use-barcode-label+
                                                 :json-laboratory           json-laboratory
                                                 :json-laboratory-id        json-laboratory-id
						 :render-results-p          has-local-results-p
                                                 :data-table                data)
                                               :stream stream))))

(defun gen-lab-actual-name (lab-id prefix sample-id)
  "note: no error check"
  (format nil "~a~a~a" (db:name (single 'db:laboratory :id lab-id)) prefix sample-id))

(defun gen-lab-temp-name (lab-id prefix)
  "note: no error check"
  (format nil "~a~a" (db:name (single 'db:laboratory :id lab-id)) prefix))

(defun add-single-sample (lab-id name quantity units notes checkin-date)
  (with-session-user (user)
    (let* ((errors-msg-1 (regexp-validate (list
                                           (list lab-id
						 +pos-integer-re+
						 (_ "Laboratory id invalid"))
                                           (list name
						 +sample-name-re+
						 (_ "Sample name invalid"))
                                           (list (clean-string notes)
                                                 +free-text-re+
						 (_ "Notes invalid"))
                                           (list quantity
						 +pos-integer-re+
						 (_ "Quantity invalid"))
                                           (list units
						 +free-text-re+
						 (_ "Units invalid")))))
           (errors-msg-lab-not-found (when (and (not errors-msg-1))
				       (with-id-valid-and-used 'db:laboratory lab-id
							       (_ "Laboratory not found"))))
           (errors-msg-checkin-date  (when (not (date-validate-p checkin-date))
				       (list (_ "Checkin date not valid"))))
           (error-not-own            (when (and (not errors-msg-1)
                                                (not errors-msg-lab-not-found))
                                       (let ((lab (single 'db:laboratory :id lab-id)))
                                         (db:with-owner-object (owner lab)
                                           (when (or (not owner)
                                                     (/= (db:id user) (db:id owner)))
                                             (list (format nil
                                                           (_ "You are not in charge of laboratory ~a")
                                                           (db:name lab))))))))
           (errors-msg               (concatenate 'list
                                                  errors-msg-1
                                                  errors-msg-lab-not-found
                                                  errors-msg-checkin-date
                                                  error-not-own))
           (success-msg (and (not errors-msg)
                             (list (_ "Samples saved")))))
      (if (and user
               (not errors-msg))
          (let* ((sample (create 'db:chemical-sample
				 :name          (gen-lab-temp-name lab-id name)
				 :laboratory-id lab-id
				 :quantity      quantity
				 :units         units
				 :checkin-date  (encode-datetime-string checkin-date)
				 :checkout-date nil
				 :notes         (clean-string notes))))
            (save sample) ; useless?
	    (setf (db:name sample) (gen-lab-actual-name lab-id name (db:id sample)))
	    (save sample)
            (values errors-msg success-msg sample))
	  (values errors-msg success-msg nil)))))

(defun search-chemical-sample (id name)
  (let* ((data (if (not (string-empty-p id))
		   (fetch-sample-by-id (%match-or-null id +barcode-id-re+)
					'delete-sample
					'update-chemical-sample)
		   (fetch-sample  ""
				  (%match-or-null name +free-text-re+)
				  ""
				  'delete-sample
				  'update-chemical-sample)))
	 (info-message (if data
			   nil
			   (list (_ "Your query returned no results")))))
    (manage-sample info-message nil :data data)))

(define-lab-route search-sample ("/search-sample/" :method :get)
  (with-authentication
    (if (get-parameter +name-sample-search-name+)
        (search-chemical-sample "" (get-parameter +name-sample-search-name+))
        (manage-sample nil nil))))

(define-lab-route chem-sample ("/samples/" :method :get)
  (with-authentication
    (manage-sample nil nil :data nil)))

(define-lab-route delete-sample ("/delete-sample/:id" :method :get)
  (with-authentication
    (with-session-user (user)
      (when (not (regexp-validate (list (list id +pos-integer-re+ "no"))))
	(let ((to-trash (single 'db:chemical-sample :id (parse-integer id))))
	  (db:with-owner-object (owner to-trash)
	    (let ((owner-id (and owner (db:id owner))))
	      (if (and to-trash
		       owner-id
		       (= (db:id user) owner-id))
		  (progn
		    (del to-trash)
		    (manage-sample (list (format nil (_ "Sample ~a deleted") (db:name to-trash)))
				   nil))
		  (manage-sample nil (list (_ "Sample not deleted")))))))))))

(defmethod db:generate-ps-custom-label ((product db:chemical-sample)
                                        &key
                                          (add-barcode t)
                                          (size-w 80.0)
                                          (size-h 40.0)
                                          (font-size (/ size-h 2))
                                          (padding 5.0))
  (with-authentication
    (with-custom-size-ps-doc (doc size-w size-h)
      (ps-utils:render-simple-label doc
                                    (db:name product)
                                    :add-barcode add-barcode
                                    :w           size-w
                                    :h           size-h
                                    :padding     padding
                                    :font-size   font-size))))

(define-lab-route gen-sample-custom-label ("/sample-custom-label/:id" :method :get)
  (with-authentication
    (let* ((act-product-id (or (scan-to-strings +pos-integer-re+ id) +db-invalid-id+))
	   (product        (single 'db:chemical-sample
				   :id (parse-integer act-product-id))))
      (if product
	  (progn
	    (setf (header-out :content-type) +mime-postscript+)
	    (db:generate-ps-custom-label product))
	  (manage-chem-prod nil (list (_ "Failure")))))))


(define-lab-route add-sample ("/add-sample/" :method :get)
  (with-authentication
    (let ((max-id (get-max-id "chemical-sample")))
      (if (and (get-parameter +name-count+)
               (scan +pos-integer-re+ (get-parameter +name-count+)))
          (let ((errors (loop named add-loop repeat (parse-integer (get-parameter +name-count+)) do
			     (multiple-value-bind (err success)
				 (add-single-sample (get-parameter +name-lab-id+)
						    (get-parameter +name-sample-name+)
						    (get-parameter +name-quantity+)
						    (get-parameter +name-units+)
						    (get-parameter +name-notes+)
						    (get-parameter +name-checkin-date+))
			       (declare (ignore success))
			       (when err
				 (return-from add-loop err))))))
            (if errors
                (manage-sample nil errors)
                (manage-sample (list (_ "Successfully added samples")) nil
			       :data (fetch-sample-min-id max-id
							  'delete-sample
							  'update-chemical-sample))))
          (manage-sample nil (list (_ "Item count must be a positive integer")))))))

(define-lab-route others-op-chem-sample ("/others-op-chem-sample/" :method :post)
  (with-authentication
    (let ((all-ids (remove-if #'(lambda (a) (not (scan +pos-integer-re+ a)))
			      (map 'list #'first (post-parameters*)))))
      (cond
	((post-parameter +op-submit-gen-barcode+)
         (let ((w (safe-parse-number (post-parameter +name-w-label+) 80.0))
               (h (safe-parse-number (post-parameter +name-h-label+) 40.0))
               (use-barcode (post-parameter +name-use-barcode-label+)))
           (setf (header-out :content-type) +mime-postscript+)
           (render-many-sample-barcodes all-ids w h use-barcode)))
	((post-parameter +op-submit-massive-delete+)
         (massive-delete all-ids 'db:chemical-sample
                         (_ "Sample ~a deleted. ")
                         (_ "Sample ~a not deleted. ")
                         #'manage-sample))
	(t
	 (manage-sample nil nil :data nil))))))
