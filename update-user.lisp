;: Niccolo' a chemicals inventory
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

(defun update-user (id name email level)
  (let* ((error-id-invalid   (and (not (null id))
                                  (regexp-validate (list
                                                    (list id
                                                          +pos-integer-re+
                                                          (_ "Id invalid"))))))
         (errors-msg-invalid (regexp-validate (list (list name
                                                          +free-text-re+
                                                          (_ "Username invalid"))
                                                    (list email
                                                          +email-re+
                                                          (_ "Email invalid")))))
         (errors-msg-not-already-in-db  (when (and (not errors-msg-invalid)
                                                   (not error-id-invalid)
                                                   (not (object-exists-in-db-p 'db:user id)))
                                          (list (_ "Username not in the database"))))
         (errors-level-invalid          (if (not (user-level-validate-p level))
                                            (list (_ "User level not allowed"))
                                            nil))
         (errors-msg                    (concatenate 'list
                                                     error-id-invalid
                                                     errors-msg-invalid
                                                     errors-msg-not-already-in-db
                                                     errors-level-invalid))
         (success-msg                   (and (not errors-msg)
                                             (list (format nil (_ "Updated user: ~s") name)))))
    (when (and id
               (not errors-msg))
      (let* ((updated-user (single 'db:user :id (parse-integer id))))
        (setf (db:username updated-user) name)
        (setf (db:email    updated-user) email)
        (setf (db:level    updated-user) level)
        (save updated-user)))
    (manage-update-user id success-msg errors-msg)))

(defun prepare-for-update-user (id)
  (prepare-for-update id
                      'db:user
                      (_ "User does not exists in database.")
                      #'manage-update-user))

(defun manage-update-user (id infos errors)
  (let* ((new-user  (and id (single 'db:user :id id)))
         (new-uname (and new-user (db:username new-user)))
         (new-email (and new-user (db:email    new-user)))
         (id        (and new-user (db:id       new-user)))
         (template  (with-back-uri (user)
                      (with-path-prefix
                          :name-lb           (_ "Name")
                          :email-lb          (_ "Email")
                          :level-lb          (_ "Level")
                          :levels-options-lb (_ "Level")
                          :login-value       new-uname
                          :email-value       new-email
                          :id                id
                          :login-email       +name-user-email+
                          :login-name        +name-user-name+
                          :levels-select     +name-user-level+
                          :level-options     +template-decode-acl+))))
    (with-standard-html-frame (stream (_ "Edit user") :infos infos :errors errors)
      (html-template:fill-and-print-template #p"update-user.tpl"
                                             template
                                             :stream stream))))

(define-lab-route edit-user ("/edit-user/:id" :method :get)
  (with-authentication
    (with-admin-credentials
        (progn
          (if (all-not-null-p (get-parameter +name-user-name+)
                              (get-parameter +name-user-email+)
                              (get-parameter +name-user-level+))
              (update-user id
                           (get-parameter +name-user-name+)
                           (get-parameter +name-user-email+)
                           (get-parameter +name-user-level+))
              (prepare-for-update-user id)))
      (manage-address nil (list *insufficient-privileges-message*)))))
