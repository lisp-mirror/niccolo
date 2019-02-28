; niccolo': a chemicals inventory
;; Copyright (C) 2016  Universita' degli Studi di Palermo

;; This  program is  free  software: you  can  redistribute it  and/or
;; modify it  under the  terms of  the GNU  General Public  License as
;; published by the Free Software  Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :restas.lab)

(define-constant +name-sample-id+                  "id"           :test #'string=)

(define-constant +name-sample-name+                "sname"        :test #'string=)

(define-constant +name-sample-description+         "sdescription" :test #'string=)

(define-constant +name-sample-compliantp+          "compliant"    :test #'string=)

(define-constant +name-checkin-date+               "chkin-date"   :test #'string=)

(define-constant +name-checkout-date+              "chkout-date"  :test #'string=)

(define-constant +name-sample-search-name+         "sname"        :test #'string=)

(define-constant +name-use-barcode-label+          "chkbox-w"     :test #'string=)

(define-constant +name-h-label+                    "h-label"      :test #'string=)

(define-constant +name-w-label+                    "w-label"      :test #'string=)

(defun encode-compliantp (c)
  (if c
      1
      0))

(defun decode-compliantp (c)
  (= c 1))

(defmacro gen-all-sample-select (&body where)
  `(select ((:as :sample.id            :sample-id)
            (:as :sample.person-id     :person-id)
            (:as :sample.name          :sample-name)
            (:as :sample.quantity      :quantity)
            (:as :sample.units         :units)
            (:as :sample.checkin-date  :checkin-date)
            (:as :sample.checkout-date :checkout-date)
            (:as :sample.notes         :notes)
            (:as :sample.description   :description)
            (:as :sample.compliantp    :compliantp)
            (:as :user.username        :owner-name)
            (:as :user.id              :owner-id)
            (:as :person.id            :person-id)
            (:as :lab.id               :lab-id)
            (:as :lab.name             :lab-name)
            (:as :lab.complete-name    :lab-complete-name))
     (from (:as :chemical-sample :sample))
     (left-join (:as :laboratory :lab) :on (:= :sample.laboratory-id :lab.id))
     (left-join :user                  :on (:= :lab.owner            :user.id))
     (left-join :person                :on (:= :sample.person-id     :person.id))
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
           (decoded-person        (db:build-description   (db-single 'db:person
                                                                  :id (getf row :person-id))))
           (gen-custom-label-link (restas:genurl 'gen-sample-custom-label
                                                 :id (getf row :sample-id))))
      (setf (elt raw rown)
            (concatenate 'list
                         row
                         (list :checkin-date-encoded   encoded-checkin-date)
                         (list :checkout-date-encoded  encoded-checkout-date)
                         (list :checkin-date-decoded   decoded-checkin-date)
                         (list :checkout-date-decoded  decoded-checkout-date)
                         (list :person-description     decoded-person)
                         (list :shortened-notes        (string-utils:ellipsize (getf row :notes)))
                         (list :shortened-description
                               (string-utils:ellipsize (getf row :description)))
                         (list :decoded-compliantp     (decode-compliantp (getf row :compliantp)))
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
    (build-template-list-samples (db-query (gen-all-prod-select (where (:= :sample-id id))))
                                 delete-link
                                 update-link)))

(defun fetch-sample (owner sample-name lab-name &optional
                                                (delete-link nil)
                                                (update-link nil))
  (let ((raw (db-query (gen-all-sample-select (where
                                               (:and (:like :user.username
                                                            (prepare-for-sql-like owner))
                                                     (:like :sample.name
                                                            (prepare-for-sql-like sample-name))
                                                     (:like :lab.name
                                                            (prepare-for-sql-like lab-name))))))))
    (build-template-list-samples raw delete-link update-link)))

(defun fetch-sample-min-id (id &optional (delete-link nil) (update-link nil))
  (let ((raw (db-query (gen-all-sample-select (where
                                               (:> :sample.id id))))))
    (build-template-list-samples raw delete-link update-link)))

(defun fetch-all-samples (&optional (delete-link nil) (update-link nil))
  (let ((raw (db-query (gen-all-sample-select))))
    (build-template-list-samples raw delete-link update-link)))

(defun manage-sample (infos errors &key (data nil))
  (with-standard-html-frame (stream
                             (_ "Manage Samples")
                             :errors errors
                             :infos  infos)
    (let ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
          (json-laboratory    (array-autocomplete-laboratory (get-session-user-id)))
          (json-laboratory-id (array-autocomplete-laboratory-id (get-session-user-id)))
          (json-person        (array-autocomplete-person))
          (json-person-id     (array-autocomplete-person-id))
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
                                                 :description-lb            (_ "Description")
                                                 :compliantp-lb             (_ "Compliant?")
                                                 :person-lb                 (_ "Person")
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
                                                 :description
                                                 +name-sample-description+
                                                 :compliantp-name           +name-sample-compliantp+
                                                 :person-id                 +name-person-id+
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
                                                 :json-person               json-person
                                                 :json-person-id            json-person-id
                                                 :render-results-p          has-local-results-p
                                                 :data-table                data)
                                               :stream stream))))

(defun gen-lab-actual-name (lab-id prefix sample-id)
  "note: no error check"
  (format nil "~a~a~a" (db:name (db-single 'db:laboratory :id lab-id)) prefix sample-id))

(defun gen-lab-temp-name (lab-id prefix)
  "note: no error check"
  (format nil "~a~a" (db:name (db-single 'db:laboratory :id lab-id)) prefix))

(defun add-single-sample (lab-id name quantity units description compliantp notes
                          checkin-date person-id)
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
                                                 (_ "Units invalid"))
                                           (list description
                                                 +free-text-re+
                                                 (_ "Description invalid"))
                                           (list person-id
                                                 +pos-integer-re+
                                                 (_ "Person  invalid")))))
           (errors-msg-lab-not-found (when (and (not errors-msg-1))
                                       (with-id-valid-and-used 'db:laboratory lab-id
                                                               (_ "Laboratory not found"))))
           (errors-msg-checkin-date  (when (not (date-validate-p checkin-date))
                                       (list (_ "Checkin date not valid"))))
           (error-not-own            (when (and (not errors-msg-1)
                                                (not errors-msg-lab-not-found))
                                       ;; TODO change with 'user-lab-associed-p
                                       (let ((lab (db-single 'db:laboratory :id lab-id)))
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
          (let* ((sample (db-create'db:chemical-sample
                                 :name          (gen-lab-temp-name lab-id name)
                                 :compliantp    (encode-compliantp compliantp)
                                 :description   description
                                 :laboratory-id lab-id
                                 :quantity      quantity
                                 :units         units
                                 :checkin-date  (encode-datetime-string checkin-date)
                                 :checkout-date nil
                                 :person-id     person-id
                                 :notes         (clean-string notes))))
            (db-save sample) ; useless?
            (setf (db:name sample) (gen-lab-actual-name lab-id name (db:id sample)))
            (db-save sample)
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
    (if (get-clean-parameter +name-sample-search-name+)
        (search-chemical-sample "" (get-clean-parameter +name-sample-search-name+))
        (manage-sample nil nil))))

(define-lab-route chem-sample ("/samples/" :method :get)
  (with-authentication
    (manage-sample nil nil :data nil)))

(define-lab-route delete-sample ("/delete-sample/:id" :method :get)
  (with-authentication
    (with-session-user (user)
      (when (not (regexp-validate (list (list id +pos-integer-re+ "no"))))
        (let ((to-trash (db-single 'db:chemical-sample :id (parse-integer id))))
          (db:with-owner-object (owner to-trash)
            (let ((owner-id (and owner (db:id owner))))
              (if (and to-trash
                       owner-id
                       (= (db:id user) owner-id))
                  (progn
                    (db-del to-trash)
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
           (product        (db-single 'db:chemical-sample
                                   :id (parse-integer act-product-id))))
      (if product
          (progn
            (setf (header-out :content-type) +mime-postscript+)
            (db:generate-ps-custom-label product))
          (manage-chem-prod nil (list (_ "Failure")))))))


(define-lab-route add-sample ("/add-sample/" :method :get)
  (with-authentication
    (let ((max-id (get-max-id "chemical-sample")))
      (if (and (get-clean-parameter +name-count+)
               (scan +pos-integer-re+ (get-clean-parameter +name-count+)))
          (let ((errors (loop named add-loop repeat (parse-integer (get-clean-parameter +name-count+)) do
                             (multiple-value-bind (err success)
                                 (add-single-sample (get-clean-parameter +name-lab-id+)
                                                    (get-clean-parameter +name-sample-name+)
                                                    (get-clean-parameter +name-quantity+)
                                                    (get-clean-parameter +name-units+)
                                                    (get-clean-parameter +name-sample-description+)
                                                    (get-clean-parameter +name-sample-compliantp+)
                                                    (get-clean-parameter +name-notes+)
                                                    (get-clean-parameter +name-checkin-date+)
                                                    (get-clean-parameter +name-person-id+))
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
                              (map 'list #'first (post-clean-parameters*)))))
      (cond
        ((post-clean-parameter +op-submit-gen-barcode+)
         (let ((w (safe-parse-number (post-clean-parameter +name-w-label+) 80.0))
               (h (safe-parse-number (post-clean-parameter +name-h-label+) 40.0))
               (use-barcode (post-clean-parameter +name-use-barcode-label+)))
           (setf (header-out :content-type) +mime-postscript+)
           (render-many-sample-barcodes all-ids w h use-barcode)))
        ((post-clean-parameter +op-submit-massive-delete+)
         (massive-delete all-ids 'db:chemical-sample
                         (_ "Sample ~a deleted. ")
                         (_ "Sample ~a not deleted. ")
                         #'manage-sample))
        (t
         (manage-sample nil nil :data nil))))))
