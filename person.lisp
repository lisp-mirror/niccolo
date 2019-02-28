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

(define-constant +name-person-id+            "person-id"     :test #'string=)

(define-constant +name-person-name+          "name"          :test #'string=)

(define-constant +name-person-address-id+    "code"          :test #'string=)

(define-constant +name-person-surname+       "surname"       :test #'string=)

(define-constant +name-person-organization+  "orgranization" :test #'string=)

(define-constant +name-person-official-id+   "official-id"   :test #'string=)

(gen-autocomplete-functions db:person db:build-description)

(defun all-person-select ()
  (db-query (select ((:as :p.id           :id)
                     (:as :p.name         :name)
                     (:as :p.surname      :surname)
                     (:as :p.address-id   :address-id)
                     (:as :p.organization :organization)
                     (:as :p.official-id  :official-id)
                     (:as :p.email        :email))
              (from (:as :person  :p)))))

(defun build-template-list-person (start-from data-count
                                        &key (delete-link nil) (update-link nil))
  (let ((raw (map 'list #'(lambda (row)
                            (map 'list
                                 #'(lambda (cell)
                                     (if (symbolp cell)
                                         (make-keyword (string-upcase (symbol-name cell)))
                                         cell))
                                 row))
                  (all-person-select))))
    (do-rows (rown res)
        (slice-for-pagination raw start-from data-count)
      (let* ((row (elt res rown)))
        (setf (getf row :complete-address)
              (db:build-description (db-single 'db:address :id (getf row :address-id))))
        (setf (elt res rown)
              (concatenate 'list
                           row
                           (if delete-link
                               (list :delete-link (delete-uri delete-link row))
                               nil)
                           (if update-link
                               (list :update-link (restas:genurl update-link :id (getf row :id)))
                               nil)))))))

(defun ensure-person-id (a &optional (default -1))
  (floor (safe-parse-number a default)))

(defun add-new-person (name surname organization official-id address-id email
                       &key (start-from 0) (data-count 1))
  (let* ((errors-msg-1 (regexp-validate (list
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
                                               (_ "Official id"))
                                         (list address-id
                                               +pos-integer-re+
                                               (_ "Address"))
                                         (list email
                                               +email-re+
                                               (_ "Email invalid")))))
         (errors-msg-2 (when (not errors-msg-1)
                         (unique-p-validate* 'db:person
                                            (:name  :surname :organization)
                                            (name   surname  organization)
                                            (_ "Person already in the database"))))
         (error-address (when (and (all-null-p errors-msg-1 errors-msg-2)
                                   (not (db-single 'db:address
                                                :id (ensure-person-id address-id -1))))
                          (list (_ "Address invalid"))))

         (errors-msg (concatenate 'list errors-msg-1 errors-msg-2 error-address))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "Saved new person: ~s - ~s")
                                         name surname)))))
    (when (not errors-msg)
      (let ((new-person (db-create'db:person
                         :name         name
                         :surname      surname
                         :address-id   (ensure-person-id address-id 0)
                         :organization organization
                         :official-id  official-id
                         :email        email)))
        (db-save new-person)))
    (manage-person  success-msg
                    errors-msg
                    :start-from start-from
                    :data-count data-count)))

(defun manage-person (infos errors &key (start-from 0) (data-count 1))
  (let ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
        (all-persons (build-template-list-person (actual-pagination-start start-from)
                                                 (actual-pagination-count data-count)
                                                 :delete-link  'delete-person
                                                 :update-link  'update-person-route))
        (json-addresses    (array-autocomplete-address))
        (json-addresses-id (array-autocomplete-address-id)))
    (multiple-value-bind (next-start prev-start)
        (pagination-bounds (actual-pagination-start start-from)
                           (actual-pagination-count data-count)
                           'db:ghs-hazard-statement)
      (with-standard-html-frame (stream (_ "Manage Person")
                                        :infos infos :errors errors)
        (html-template:fill-and-print-template #p"add-person.tpl"
                                               (with-back-to-root
                                                   (with-pagination-template
                                                       (next-start
                                                        prev-start
                                                        (restas:genurl 'person))
                                                     (with-path-prefix
                                                         :name-lb         (_ "Name")
                                                         :surname-lb      (_ "Surname")
                                                         :address-lb      (_ "Address")
                                                         :organization-lb (_ "Organization")
                                                         :official-id-lb  (_ "Official ID")
                                                         :operations-lb   (_ "Operations")
                                                         :email-lb        (_ "Email")
                                                         :name            +name-person-name+
                                                         :surname         +name-person-surname+
                                                         :address-id      +name-person-address-id+
                                                         :organization    +name-person-organization+
                                                         :official-id     +name-person-official-id+
                                                         :email           +name-email+
                                                         :json-addresses    json-addresses
                                                         :json-addresses-id json-addresses-id
                                                         :next-start        next-start
                                                         :prev-start        prev-start
                                                         :data-table        all-persons)))
                                               :stream stream)))))

(define-lab-route person ("/person/" :method :get)
  (with-authentication
    (with-editor-or-above-credentials
        (with-pagination (pagination-uri utils:*alias-pagination*)
          (manage-person nil nil
                         :start-from (session-pagination-start pagination-uri
                                                               utils:*alias-pagination*)
                         :data-count (session-pagination-count pagination-uri
                                                               utils:*alias-pagination*)))
      (manage-chem-prod nil (list *insufficient-privileges-message*)))))

(define-lab-route add-person ("/add-person/" :method :get)
  (with-authentication
    (with-editor-or-above-credentials
        (with-pagination (pagination-uri utils:*alias-pagination*)
          (add-new-person (get-clean-parameter +name-person-name+)
                          (get-clean-parameter +name-person-surname+)
                          (get-clean-parameter +name-person-organization+)
                          (get-clean-parameter +name-person-official-id+)
                          (get-clean-parameter +name-person-address-id+)
                          (get-clean-parameter +name-email+)
                          :start-from (session-pagination-start pagination-uri
                                                                utils:*alias-pagination*)
                          :data-count (session-pagination-count pagination-uri
                                                                utils:*alias-pagination*)))
      (manage-person nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-person ("/delete-person/:id" :method :get)
  (with-authentication
    (with-editor-or-above-credentials
        (progn
          (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
            (let ((to-trash (db-single 'db:person :id id)))
              (when to-trash
                (db-del (db-single 'db:person :id id)))))
          (restas:redirect 'person))
      (manage-person nil (list *insufficient-privileges-message*)))))
