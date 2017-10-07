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

(defun update-sample (id quantity units new-checkout-date notes)
  (let* ((clean-notes     (clean-string notes))
	 (errors-checkout (if (or (string-empty-p new-checkout-date)
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
                                               (list units
                                                     +free-text-re+
                                                     (_ "Units invalid")))))
         (errors-msg (concatenate 'list
                                  errors-checkout
                                  errors-msg-id
				  errors-msg-exists
                                  errors-msg-generic))
         (success-msg (and (not errors-msg)
                           (list (_ "Sample updated")))))
    (if (not errors-msg)
        (let* ((sample (single 'db:chemical-sample :id id)))
          (setf (db:checkout-date sample) (encode-datetime-string new-checkout-date)
                (db:quantity      sample) quantity
                (db:units         sample) units
		(db:notes         sample) clean-notes)
          (save sample)
          (manage-update-sample (and success-msg id) success-msg errors-msg))
        (manage-update-sample id success-msg errors-msg))))

(defun manage-update-sample (id infos errors)
  (let ((new-sample (and id (single 'db:chemical-sample :id (parse-integer id)))))
    (with-standard-html-frame (stream (_ "Update Sample")
                                      :infos infos
                                      :errors errors)
      (html-template:fill-and-print-template #p"update-sample.tpl"
                                             (with-back-uri (chem-sample)
                                               (with-path-prefix
                                                   :checkout-date-lb (_ "Checkout date")
                                                   :quantity-lb      (_ "Quantity (Mass or Volume)")
                                                   :units-lb         (_ "Unit of measure")
						   :notes-lb          (_ "Notes")
                                                   :id               (and id
                                                                          (db:id new-sample))
						   :notes            +name-notes+
                                                   :checkout-date    +name-checkout-date+
                                                   :quantity         +name-quantity+
                                                   :units            +name-units+
                                                   :quantity-value   (and id
                                                                          (db:quantity new-sample))
                                                   :units-value      (and id
                                                                          (db:units new-sample))
						   :notes-value      (db:notes new-sample)
                                                   :checkout-date-value
                                                   (decode-date-string
                                                    (db:checkout-date new-sample))))
                                             :stream stream))))

(define-lab-route update-chemical-sample ("/update-chemical-sample/:id" :method :get)
  (with-authentication
    (with-session-user (user)
      (when (not (regexp-validate (list (list id +pos-integer-re+ "no"))))
        (let* ((to-update (single 'db:chemical-sample :id (parse-integer id))))
	  (db:with-owner-object (owner to-update)
	    (let ((owner-id (and owner (db:id owner))))
	      (if (and to-update
		       owner-id
		       (= (db:id user) owner-id))
		  (let ((new-checkout (get-parameter +name-checkout-date+))
			(new-quantity (get-parameter +name-quantity+))
			(new-units    (get-parameter +name-units+))
			(new-notes    (get-parameter +name-notes+)))
		    (if new-notes
			(update-sample id new-quantity new-units new-checkout new-notes)
			(manage-update-sample id nil nil)))
		  (manage-update-sample id
					nil
					(list (_ "You are not the owner of this product")))))))))))
