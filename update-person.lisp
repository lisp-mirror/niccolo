;; niccolo': a chemicals inventory
;; Copyright (C) 2018  Universita' degli Studi di Palermo

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

(defun update-person (id name surname organization official-id address-id)
  (let* ((errors-msg-1 (concatenate 'list
                                    (regexp-validate (list
                                                      (list id
                                                            +pos-integer-re+
                                                            (_ "ID invalid"))
                                                      (list address-id
                                                            +pos-integer-re+
                                                            (_ "Address id invalid"))
                                                      (list name
                                                            +free-text-re+
                                                            (_ "Name invalid"))
                                                      (list surname
                                                            +free-text-re+
                                                            (_ "Surname invalid"))
                                                      (list organization
                                                            +free-text-re+
                                                            (_ "Organization"))
                                                      (list official-id
                                                            +free-text-re+
                                                            (_ "Official id"))))))
         (errors-msg-2  (when (and (not errors-msg-1)
                                   (not (object-exists-in-db-p 'db:person id)))
                          (list (_ "Person does not exists in database"))))
         (errors-msg-address-not-found (when (and (not errors-msg-1)
                                                  (not (single 'db:address :id address-id)))
                                         (list (_ "Address not in the database"))))
         (errors-msg-unique (when (all-null-p errors-msg-1 errors-msg-2
                                              errors-msg-address-not-found)
                              (exists-with-different-id-validate 'db:person
                                                                 id
                                                                 (:name :surname :organization)
                                                                 (name  surname  organization)
                                                                 (_ "Person already in the database with different ID"))))
         (errors-msg (concatenate 'list
                                  errors-msg-1
                                  errors-msg-2
                                  errors-msg-address-not-found
                                  errors-msg-unique))
         (success-msg (and (not errors-msg)
                           (list (_ "Person updated")))))
    (if (not errors-msg)
      (let ((person-updated (single 'db:person :id id)))
        (setf (db:name         person-updated) name
              (db:surname      person-updated) surname
              (db:address-id   person-updated) address-id
              (db:organization person-updated) organization
              (db:official-id  person-updated) official-id)
        (save person-updated)
        (manage-update-person (and success-msg id) success-msg errors-msg))
      (manage-update-person id success-msg errors-msg))))

(defun prepare-for-update-person (id)
  (prepare-for-update id
                      'db:person
                      (_ "person does not exists in database.")
                      #'manage-update-person))

(defun manage-update-person (id infos errors)
  (let* ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
         (json-addresses    (array-autocomplete-address))
         (json-addresses-id (array-autocomplete-address-id))
         (new-person (and id
                          (object-exists-in-db-p 'db:person id)))
         (template     (with-back-uri (person)
                         (with-path-prefix
                             :name-lb         (_ "Name")
                             :surname-lb      (_ "Surname")
                             :address-lb      (_ "Address")
                             :organization-lb (_ "Organization")
                             :official-id-lb  (_ "Official ID")
                             :operations-lb   (_ "Operations")
                             :name            +name-person-name+
                             :surname         +name-person-surname+
                             :address-id      +name-person-address-id+
                             :organization    +name-person-organization+
                             :official-id     +name-person-official-id+
                             :id              (and id
                                                   (db:id new-person))
                             :name-value      (and id
                                                   (db:name new-person))
                             :surname-value   (and id
                                                   (db:surname new-person))
                             :address-id-value (and id
                                                    (db:address-id new-person))
                             :address-value    (and id
                                                    (single 'db:address
                                                            :id (db:address-id new-person))
                                                    (db:build-description
                                                     (single 'db:address
                                                             :id (db:address-id new-person))))
                             :official-id-value  (and id
                                                     (db:official-id new-person))
                             :organization-value (and id
                                                      (db:organization new-person))
                             :json-addresses json-addresses
                             :json-addresses-id json-addresses-id))))
    (with-standard-html-frame (stream (_ "Update Person") :infos infos :errors errors)
      (html-template:fill-and-print-template #p"update-person.tpl"
                                             template
                                             :stream stream))))

(define-lab-route update-person-route ("/update-person/:id" :method :get)
  (with-authentication
    (with-editor-or-above-credentials
        (progn
          (let ((new-name         (get-parameter +name-person-name+))
                (new-surname      (get-parameter +name-person-surname+))
                (new-address-id   (get-parameter +name-person-address-id+))
                (new-organization (get-parameter +name-person-organization+))
                (new-official-id  (get-parameter +name-person-official-id+)))
            (if (all-not-null-p new-name
                                new-surname
                                new-address-id
                                new-organization
                                new-official-id)
                (update-person (ensure-person-id id)
                               new-name
                               new-surname
                               new-organization
                               new-official-id
                               new-address-id)
                (prepare-for-update-person id))))
      (manage-update-person nil nil (list *insufficient-privileges-message*)))))
