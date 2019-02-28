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

(defun update-sample (id quantity units new-checkout-date notes description compliantp person-id)
  (let* ((clean-notes       (clean-string notes))
         (clean-description (clean-string description))
         (errors-checkout   (if (or (string-empty-p new-checkout-date)
                                  (date-validate-p new-checkout-date))
                              nil
                              (list (_ "Checkout date not properly formatted."))))
         (errors-msg-id      (regexp-validate (list (list id
                                                          +pos-integer-re+
                                                          (_ "Id invalid")))))
         (errors-msg-exists  (when (and
                                    (not errors-msg-id))
                               (with-id-valid-and-used 'db:chemical-sample id
                                                       (_ "Sample not found"))))
         (errors-msg-generic (regexp-validate (list
                                               (list clean-notes
                                                    +free-text-re+
                                                    (_ "Notes invalid"))
                                               (list quantity
                                                     +pos-integer-re+
                                                     (_ "Quantity invalid"))
                                                (list person-id
                                                     +pos-integer-re+
                                                     (_ "Person invalid"))
                                               (list units
                                                     +free-text-re+
                                                     (_ "Units invalid")))))
         (error-person-not-found (when (all-not-null-p errors-checkout
                                                       errors-msg-id
                                                       errors-msg-exists
                                                       errors-msg-generic)
                                   (with-id-valid-and-used 'db:person person-id
                                                           (_ "person not found"))))
         (errors-msg (concatenate 'list
                                  errors-checkout
                                  errors-msg-id
                                  errors-msg-exists
                                  errors-msg-generic
                                  error-person-not-found))
         (success-msg (and (not errors-msg)
                           (list (_ "Sample updated")))))
    (if (not errors-msg)
        (let* ((sample (db-single 'db:chemical-sample :id id)))
          (setf (db:checkout-date sample) (encode-datetime-string new-checkout-date)
                (db:description   sample) clean-description
                ;; note: no need to check input as 'encode-compliantp
                ;; just check for non-nil
                (db:compliantp    sample) (encode-compliantp compliantp)
                (db:quantity      sample) quantity
                (db:units         sample) units
                (db:notes         sample) clean-notes
                (db:person-id     sample) person-id)
          (db-save sample)
          (manage-update-sample (and success-msg id) success-msg errors-msg))
        (manage-update-sample id success-msg errors-msg))))

(defun manage-update-sample (id infos errors)
  (let* ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
         (new-sample (and (safe-parse-number id nil)
                          (db-single 'db:chemical-sample :id (parse-integer id))))
         (decoded-compliantp (and new-sample
                                  (decode-compliantp (db:compliantp new-sample))))
         (json-person        (array-autocomplete-person))
         (json-person-id     (array-autocomplete-person-id))
         (person-object      (and (safe-parse-number id nil)
                                  (db-single 'db:person
                                          :id (db:person-id new-sample))))
         (person-description (and person-object
                                  (db:build-description person-object))))
    (with-standard-html-frame (stream (_ "Update Sample")
                                      :infos infos
                                      :errors errors)
      (html-template:fill-and-print-template #p"update-sample.tpl"
                                             (with-back-uri (chem-sample)
                                               (with-path-prefix
                                                   :checkout-date-lb (_ "Checkout date")
                                                   :quantity-lb      (_ "Quantity (Mass or Volume)")
                                                   :units-lb         (_ "Unit of measure")
                                                   :notes-lb         (_ "Notes")
                                                   :compliantp-lb    (_ "Compliant?")
                                                   :description-lb   (_ "Description")
                                                   :person-lb                 (_ "Person")
                                                   :id               (and id
                                                                          (db:id new-sample))
                                                   :notes            +name-notes+
                                                   :checkout-date    +name-checkout-date+
                                                   :quantity         +name-quantity+
                                                   :units            +name-units+
                                                   :compliantp-name  +name-sample-compliantp+
                                                   :description      +name-sample-description+
                                                   :person-id        +name-person-id+
                                                   :quantity-value     (and id
                                                                          (db:quantity new-sample))
                                                   :units-value        (and id
                                                                          (db:units new-sample))
                                                   :notes-value        (db:notes new-sample)
                                                   :description-value  (db:description new-sample)
                                                   :person-id-value     (db:id person-object)
                                                   :decoded-compliantp decoded-compliantp
                                                   :json-person        json-person
                                                   :json-person-id     json-person-id
                                                   :person-description-value
                                                   person-description
                                                   :checkout-date-value
                                                   (decode-date-string
                                                    (db:checkout-date new-sample))))
                                             :stream stream))))

(define-lab-route update-chemical-sample ("/update-chemical-sample/:id" :method :get)
  (with-authentication
    (with-session-user (user)
      (when (not (regexp-validate (list (list id +pos-integer-re+ "no"))))
        (let* ((to-update (db-single 'db:chemical-sample :id (parse-integer id))))
          (db:with-owner-object (owner to-update)
            (let ((owner-id (and owner (db:id owner))))
              (if (and to-update
                       owner-id
                       (= (db:id user) owner-id))
                  (let ((new-checkout    (get-clean-parameter +name-checkout-date+))
                        (new-quantity    (get-clean-parameter +name-quantity+))
                        (new-units       (get-clean-parameter +name-units+))
                        (new-description (get-clean-parameter +name-sample-description+))
                        (new-compliantp  (get-clean-parameter +name-sample-compliantp+))
                        (new-notes       (get-clean-parameter +name-notes+))
                        (new-person-id   (get-clean-parameter +name-person-id+)))
                    (if new-notes
                        (update-sample id new-quantity new-units new-checkout
                                       new-notes
                                       new-description
                                       new-compliantp
                                       new-person-id)
                        (manage-update-sample id nil nil)))
                  (manage-update-sample id
                                        nil
                                        (list (_ "You are not the owner of this product")))))))))))
