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

(defun update-building (id name address-id)
  (let* ((errors-msg-1 (concatenate 'list
                                    (regexp-validate (list (list id
                                                                 +pos-integer-re+
                                                                 (_ "ID invalid"))
                                                           (list address-id
                                                                 +pos-integer-re+
                                                                 (_ "Address id invalid"))
                                                           (list name
                                                                 +free-text-re+
                                                                 (_ "Name invalid"))))))
         (errors-msg-2  (when (and (not errors-msg-1)
                                   (not (object-exists-in-db-p 'db:building id)))
                          (list (_ "Building does not exists in database"))))
         (errors-msg-address-not-found (when (and (not errors-msg-1)
                                                  (not (single 'db:address :id address-id)))
                                         (list (_ "Address not in the database"))))
         (errors-msg-unique (when (all-null-p errors-msg-1 errors-msg-2)
                              (exists-with-different-id-validate 'db:building
                                                                 id
                                                                 (:name :address-id)
                                                                 (name  address-id)
                                                                 (_ "Building already in the database with different ID"))))
         (errors-msg (concatenate 'list
                                  errors-msg-1
                                  errors-msg-2
                                  errors-msg-address-not-found
                                  errors-msg-unique))
         (success-msg (and (not errors-msg)
                           (list (_ "Building updated")))))
    (if (not errors-msg)
      (let ((building-updated (single 'db:building :id id)))
        (setf (db:name       building-updated) name
              (db:address-id building-updated) address-id)
        (save building-updated)
        (manage-update-building (and success-msg id) success-msg errors-msg))
      (manage-building success-msg errors-msg))))

(defun prepare-for-update-building (id)
  (prepare-for-update id
                      'db:building
                      (_ "Building does not exists in database.")
                      #'manage-update-building))

(defun manage-update-building (id infos errors)
  (let* ((html-template:*string-modifier* #'identity)
         (json-addresses    (array-autocomplete-address))
         (json-addresses-id (array-autocomplete-address-id))
         (new-building (and id
                            (object-exists-in-db-p 'db:building id)))
         (template     (with-back-uri (building)
                         (with-path-prefix
                            :name-lb          (_ "Name")
                            :address-lb       (_ "Address")
                            :id               (and id
                                                   (db:id new-building))
                            :name-value       (and id
                                                   (db:name new-building))
                            :address-id-value (and id
                                                   (db:address-id new-building))
                            :address-value    (and id
                                                   (single 'db:address
                                                           :id (db:address-id new-building))
                                                   (db:build-description
                                                    (single 'db:address
                                                            :id (db:address-id new-building))))
                            :name        +name-building-proper-name+
                            :address-id  +name-building-address-id+
                            :json-addresses json-addresses
                            :json-addresses-id json-addresses-id))))
    (with-standard-html-frame (stream (_ "Update Building") :infos infos :errors errors)
      (html-template:fill-and-print-template #p"update-building.tpl"
                                             template
                                             :stream stream))))

(define-lab-route update-building-route ("/update-building/:id" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (let ((new-name       (get-parameter +name-building-proper-name+))
                (new-address-id (get-parameter +name-building-address-id+)))
            (if (and new-name
                     new-address-id)
                (update-building id new-name new-address-id)
                (prepare-for-update-building id))))
      (manage-update-building nil nil (list *insufficient-privileges-message*)))))
