;; niccolo': a chemicals inventory
;; Copyright (C) 2016  Universita' degli Studi di Palermo

;; This  program is  free  software: you  can  redistribute it  and/or
;; modify it  under the  terms of  the GNU  General Public  License as
;; published  by  the  Free  Software Foundation,  version  3  of  the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :restas.lab)

(defun build-product-diff-table (product old-validity-date old-expire-date old-opening-date)
  (utils:template->string  #p"product-diff.tpl"
                           (list
                            :header                  (format nil
                                                             (_ "Product ~a updated")
                                                             (db:id product))
                            :validity-date-lb        (_ "Validity date")
                            :expire-date-lb          (_ "Expire date")
                            :opening-package-date-lb (_ "Opening package date")
                            :old-validity-date       (decode-datetime-string old-validity-date)
                            :old-expire-date         (decode-datetime-string old-expire-date)
                            :old-opening-date        (decode-date-string     old-opening-date)
                            :new-validity-date
                            (decode-datetime-string (db:validity-date product))
                            :new-expire-date
                            (decode-datetime-string (db:expire-date product))
                            :new-opening-date
                            (decode-date-string (db:opening-package-date product)))))

(defun %error-opening-before (opening date-type-label reference)
  (let ((encoded-opening   (encode-datetime-string opening))
        (encoded-reference (encode-datetime-string reference)))
    (cond
      ((null encoded-opening)
       nil)
      (encoded-reference
       (if (local-time:timestamp< encoded-opening encoded-reference)
           (list (format nil (_ "Error: opening date ~a is older than ~a (~a)")
                         opening
                         date-type-label
                         reference))
           nil))
      (t
       (list (_ "Error: date invalid"))))))

(defun update-chem-prod (id quantity units new-validity-date new-expire-date new-opening-date)
  (with-session-user (user)
    (let* ((errors-validity  (if (date-validate-p new-validity-date)
                                 nil
                                 (list (_ "Validity date not properly formatted."))))
           (errors-expire  (if (date-validate-p new-expire-date)
                               nil
                               (list (_ "Expire date not properly formatted."))))
           (errors-opening  (if (or (string-empty-p new-opening-date)
                                    (date-validate-p new-opening-date))
                                nil
                                (list (_ "Opening date not properly formatted."))))
           (errors-msg-id  (regexp-validate (list (list id +pos-integer-re+ (_ "Id invalid")))))
           (errors-msg-generic (regexp-validate (list
                                                 (list quantity +pos-integer-re+  (_ "Quantity invalid"))
                                                 (list units    +free-text-re+ (_ "Units invalid")))))
           (errors-msg-exists  (when (and
                                      (not errors-msg-id)
                                      (not (object-exists-in-db-p 'db:chemical-product id)))
                                 (list (_ "Chemical compound not in database"))))
           (errors-opening-before-expiring (and (null errors-validity)
                                                (null errors-expire)
                                                (null errors-opening)
                                                (%error-opening-before new-opening-date
                                                                       (_ "expiring")
                                                                       new-expire-date)))
           (errors-opening-before-validity (and (null errors-validity)
                                                (null errors-expire)
                                                (null errors-opening)
                                                (%error-opening-before new-validity-date
                                                                       (_ "validity")
                                                                       new-validity-date)))
           (errors-msg (concatenate 'list
                                    errors-validity
                                    errors-expire
                                    errors-opening
                                    errors-opening-before-expiring
                                    errors-opening-before-validity
                                    errors-msg-id
                                    errors-msg-generic
                                    errors-msg-exists))
           (success-msg (and (not errors-msg)
                             (list (format nil (_ "Chemical product: ~s updated") id)))))
      (if (not errors-msg)
          (let* ((new-chem          (single 'db:chemical-product :id id))
                 (old-exp-date      (db:expire-date          new-chem))
                 (old-validity-date (db:validity-date        new-chem))
                 (old-opening-date  (db:opening-package-date new-chem)))
            (setf (db:validity-date          new-chem) (encode-datetime-string new-validity-date)
                  (db:expire-date            new-chem) (encode-datetime-string new-expire-date)
                  (db:opening-package-date   new-chem) (encode-datetime-string new-opening-date)
                  (db:quantity               new-chem) (parse-integer quantity)
                  (db:units                  new-chem) units)
            (save new-chem)
            (let ((parent-messages (concatenate 'list
                                                (fetch-expired-messages-linked-to-product (db:id new-chem))
                                                (fetch-validity-expired-messages-linked-to-product (db:id new-chem)))))
              (if parent-messages
                  (dolist (parent-message parent-messages)
                    (send-user-message (make-instance 'db:message)
                                       (db:id user)
                                       (db:id user)
                                       (_ "Product updated")
                                       (build-product-diff-table new-chem
                                                                 old-validity-date
                                                                 old-exp-date
                                                                 old-opening-date)
                                       :parent-message parent-message))
                  (send-user-message (make-instance 'db:message)
                                       (db:id user)
                                       (db:id user)
                                       (_ "Product updated")
                                       (build-product-diff-table new-chem
                                                                 old-validity-date
                                                                 old-exp-date
                                                                 old-opening-date)
                                       :parent-message nil)))
            (manage-update-chem-prod (and success-msg id) success-msg errors-msg))
          (manage-update-chem-prod id success-msg errors-msg)))))

(defun prepare-for-update-chem-product (id)
  (prepare-for-update id
                      'db:chemical-product
                      (_ "This product does not exists in database.")
                      #'manage-update-chem-prod))

(defun manage-update-chem-prod (id infos errors)
  (let ((new-chem-prod (and id (single 'db:chemical-product :id (parse-integer id)))))
    (with-standard-html-frame (stream (_ "Update Chemical product")
                                      :infos infos
                                      :errors errors)
      (html-template:fill-and-print-template #p"update-chemical-product.tpl"
                                             (with-back-uri (chem-prod)
                                               (with-path-prefix
                                                   :expire-date-lb       (_ "Expire date")
                                                   :validity-date-lb     (_ "Validity date")
                                                   :opening-package-date-lb
                                                   (_ "Opening package date")
                                                   :quantity-lb
                                                   (_ "Quantity (Mass or Volume)")
                                                   :units-lb             (_ "Unit of measure")
                                                   :id                   (and id
                                                                              (db:id new-chem-prod))
                                                   :validity-date        +name-validity-date+
                                                   :expire-date          +name-expire-date+
                                                   :opening-package-date
                                                   +name-opening-date+
                                                   :quantity             +name-quantity+
                                                   :units                +name-units+
                                                   :quantity-value
                                                   (and id
                                                        (db:quantity new-chem-prod))
                                                   :units-value       (and id
                                                                           (db:units new-chem-prod))
                                                   :validity-date-value
                                                   (decode-date-string
                                                    (db:validity-date new-chem-prod))
                                                   :expire-date-value
                                                   (decode-date-string
                                                    (db:expire-date new-chem-prod))
                                                   :opening-package-date-value
                                                   (decode-date-string
                                                    (db:opening-package-date new-chem-prod))))
                                             :stream stream))))

(define-lab-route update-chemical-product ("/update-chemical-product/:id/:owner" :method :get)
  (with-authentication
    (with-session-user (user)
      (when (not (regexp-validate (list (list id +pos-integer-re+ "no")
                                        (list owner +pos-integer-re+ "no"))))
        (let ((to-update (single 'db:chemical-product :id (parse-integer id))))
          (if (and to-update
                   (or (session-admin-p)
                       (= (db:id user) (parse-integer owner))))
              (let ((new-expire   (get-parameter +name-expire-date+))
                    (new-validity (get-parameter +name-validity-date+))
                    (new-opening  (get-parameter +name-opening-date+))
                    (new-quantity (get-parameter +name-quantity+))
                    (new-units    (get-parameter +name-units+)))
                (if (and new-expire
                         new-validity)
                    (update-chem-prod id new-quantity new-units new-validity new-expire new-opening)
                    (prepare-for-update-chem-product id)))
              (manage-update-chem-prod id
                                       nil
                                       (list (_ "You are not the owner of this product")))))))))
