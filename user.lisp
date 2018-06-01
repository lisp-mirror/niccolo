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

(define-constant +name-user-name+                 "username"          :test #'string=)

(define-constant +name-user-email+                "email"             :test #'string=)

(define-constant +name-user-password+             "password"          :test #'string=)

(define-constant +name-user-password-2+           "password-2"        :test #'string=)

(define-constant +name-user-old-password+         "old-password"      :test #'string=)

(define-constant +name-address-zipcode+           "zipcode"           :test #'string=)

(define-constant +name-address-link+              "link"              :test #'string=)

(define-constant +name-pref-locale+               "locale"            :test #'string=)

(define-constant +name-pref-email+                "email"             :test #'string=)

(define-constant +name-user-level+                "level"             :test #'string=)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter *admin-acl-level-expl*  "Administrator")

  (defparameter *editor-acl-level-expl* "Editor")

  (defparameter *user-acl-level-expl*   "User")

  (define-constant +template-decode-acl+ (list (list :level +admin-acl-level+
                                                     :expl  *admin-acl-level-expl*)
                                               (list :level +editor-acl-level+
                                                     :expl  *editor-acl-level-expl*)
                                               (list :level +user-acl-level+
                                                     :expl  *user-acl-level-expl*))
    :test #'equalp))

(defun add-new-user (name email password level)
  (let* ((errors-msg-invalid (regexp-validate (list
                                               (list name
                                                     +free-text-re+
                                                     (_ "Username invalid"))
                                               (list password
                                                     +free-text-re+
                                                     (_ "Password invalid"))
                                               (list email
                                                     +email-re+
                                                     (_ "Email invalid")))))
         (errors-msg-already-in-db  (when (and (not errors-msg-invalid)
                                               (single 'db:user
                                                       :username name))
                                      (list (_ "Username already in the database"))))
         (errors-level-invalid      (if (not (user-level-validate-p level))
                                        (list (_ "User level not allowed"))
                                        nil))
         (errors-msg (concatenate 'list
                                  errors-msg-invalid
                                  errors-msg-already-in-db
                                  errors-level-invalid))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "Saved username: ~s") name)))))
    (when (not errors-msg)
      (let* ((salt (generate-salt))
             (new-user (create 'db:user
                               :username        name
                               :email           email
                               :password        (encode-pass salt password)
                               :salt            salt
                               :account-enabled +user-account-enabled+
                               :level           (parse-integer level))))
        (create 'db:user-preferences
                :owner (db:id new-user)
                :language "")
        (save new-user)))
    (manage-user success-msg errors-msg)))

(defun validate-password-match (new-pass new-pass-confirm)
  (if (not (string= new-pass new-pass-confirm))
      (list (_ "Password and confirmation does not match"))
      nil))

(defun validate-change-password (old new-pass new-pass-confirm)
  (let* ((username (get-session-username))
         (updated-user (single 'db:user :username username))
         (errors-msg-invalid (regexp-validate (list
                                               (list old
                                                     +free-text-re+
                                                     (_ "Password invalid"))
                                               (list new-pass
                                                     +free-text-re+
                                                     (_ "New password invalid")))))
         (error-msg-does-not-match  (validate-password-match new-pass new-pass-confirm))
         (errors-msg-not-in-db  (when (and (not errors-msg-invalid)
                                           (not error-msg-does-not-match)
                                           (not (and updated-user
                                                     (db:chkpass updated-user old))))
                                  (list (format nil
                                                (_ "No user ~a found in database with this password")
                                                username))))
         (errors-msg (concatenate 'list
                                  errors-msg-invalid error-msg-does-not-match
                                  errors-msg-not-in-db))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "Password changed for ~s") username)))))
    (values updated-user errors-msg success-msg)))

(defun validate-add-admin-password (new-pass new-pass-confirm)
  (let* ((errors-msg-invalid (regexp-validate (list
                                               (list new-pass
                                                     +free-text-re+
                                                     (_ "New password invalid")))))
         (error-msg-does-not-match  (validate-password-match new-pass new-pass-confirm))
         (errors-msg (concatenate 'list errors-msg-invalid error-msg-does-not-match))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "Password changed for ~s") +admin-name+)))))
    (values errors-msg success-msg)))

(defun change-password (old new-pass new-pass-confirm)
  (multiple-value-bind (updated-user errors-msg success-msg)
      (validate-change-password old new-pass new-pass-confirm)
    (when (not errors-msg)
      (let ((new-salt (generate-salt)))
        (setf (db:password updated-user) (encode-pass new-salt new-pass)
              (db:salt     updated-user)  new-salt)
        (save updated-user)))
    (manage-password-change success-msg errors-msg)))

(defun exists-admin-p ()
  (single 'db:user :level +admin-acl-level+))

(defun add-admin-password (name email new-pass new-pass-confirm)
  (multiple-value-bind (errors-msg success-msg)
      (validate-add-admin-password new-pass new-pass-confirm)
    (declare (ignore success-msg))
    (when (and (not errors-msg)
               (not (exists-admin-p)))
      (let* ((errors-msg-invalid (regexp-validate (list
                                                   (list name
                                                         +free-text-re+
                                                     (_ "Username invalid"))
                                                   (list email
                                                         +email-re+
                                                         (_ "Email invalid"))))))
        (when (not errors-msg-invalid)
          (let* ((new-salt  (generate-salt)))
            (create 'db:user
                    :username name
                    :salt     new-salt
                    :email email
                    :account-enabled +user-account-enabled+
                    :password (encode-pass new-salt new-pass)
                    :level    +admin-acl-level+)))))
    (restas:redirect 'root)))

(defun manage-password-change (infos errors)
  (with-standard-html-frame (stream (_ "Change password") :infos infos :errors errors)
    #+mini-cas
    (html-template:fill-and-print-template #p"change-password.tpl"
                                           (list
                                            :message-lb
                                            (_ "This system  uses a  central authentication  system (CAS).  Ask your  system administrators/Webmaster/IT Department about users identity management."))
                                           :stream stream)
    #-mini-cas
    (html-template:fill-and-print-template #p"change-password-no-cas.tpl"
                                           (with-path-prefix
                                               :old-password-lb (_ "Old password")
                                               :new-password-lb (_ "New password")
                                               :confirm-new-password-lb (_ "Confirm new password")
                                               :old-password +name-user-old-password+
                                               :password     +name-user-password+
                                               :password-2   +name-user-password-2+
                                               :login-pass +name-user-password+)
                                           :stream stream)))

(defun manage-user (infos errors)
  (let* ((all-users (mapcar #'(lambda (a)
                                (append a
                                        (list :active-p (if (= (getf a :account-enabled)
                                                               +user-account-enabled+)
                                                            t
                                                            nil))
                                        (list :level-expl
                                              (fourth
                                               (find-if #'(lambda (tpl)
                                                            (= (second tpl) (getf a :level)))
                                                        +template-decode-acl+)))))
                            (fetch-raw-template-list 'db:user
                                                     '(:username :email :account-enabled :level)
                                                     :delete-link 'delete-user
                                                     :disable-link 'disable-user
                                                     :enable-link  'enable-user)))
         (template  (with-path-prefix
                        :name-lb           (_ "Name")
                        :password-lb       (_ "Password")
                        :email-lb          (_ "Email")
                        :level-lb          (_ "Level")
                        :levels-options-lb (_ "Level")
                        :operations-lb     (_ "Operations")
                        :password-value
                        #+mini-cas (string-utils:clean-string (string-utils:random-password 20))
                        #-mini-cas ""
                        :login-email       +name-user-email+
                        :login-name        +name-user-name+
                        :login-pass        +name-user-password+
                        :levels-select     +name-user-level+
                        :data-table        all-users
                        :level-options     +template-decode-acl+)))
    (with-standard-html-frame (stream (_ "Manage user") :infos infos :errors errors)
      (html-template:fill-and-print-template #p"add-user.tpl"
                                             template
                                             :stream stream))))

(defun change-locale (new-locale-key)
  (with-authentication
    (let ((infos   '())
          (errors  '())
          (user-id (get-session-user-id)))
      (if (> user-id 0)
          (let* ((locale-table (i18n:find-translation new-locale-key))
                 (preferences  (single 'db:user-preferences :owner user-id)))
            (if locale-table
                (progn
                  (if preferences
                      (progn
                        (setf (db:language preferences) new-locale-key)
                        (save preferences))
                      (create 'db:user-preferences :owner user-id :language new-locale-key))
                  (push (format nil
                                (_ "Your language is now ~s")
                                (i18n:translation-description locale-table))
                        infos))
                (push (format nil
                              (_ "No valid translation found for key: ~a")
                              new-locale-key)
                      errors)))
          (push (format nil (_ "No valid user id (id: ~a)") user-id) errors))
      (values infos errors))))

(defun change-email (new-email)
  (with-authentication
    (let ((infos   '())
          (errors  '())
          (user-id (get-session-user-id)))
      (if (> user-id 0)
          (let* ((user (single 'db:user :id user-id))
                 (errors-msg-invalid (regexp-validate (list
                                                       (list new-email
                                                             +email-re+
                                                             (_ "Email invalid"))))))
            (if (not user)
                (push (format nil
                              (_ "User ~a not found")
                              user-id)
                      errors)
                (if errors-msg-invalid
                    (push errors-msg-invalid errors)
                    (let ((old-email (db:email user)))
                      (setf (db:email user) new-email)
                      (save user)
                      (send-user-message (make-instance 'db:message)
                                         (db:id user)
                                         (admin-id)
                                         (_ "Email changed")
                                         (format nil
                                                 (_ "User ~a changed his/hers email from ~a to ~a.")
                                                 (db:username user)
                                                 old-email
                                                 (db:email user)))
                      (push (format nil
                                    (_ "Email changed"))
                            infos)))))
          (push (format nil (_ "No valid user id (id: ~a)") user-id) errors))
      (values infos errors))))

(define-lab-route user ("/user/" :method :get)
  (with-authentication
    (with-admin-privileges
        (manage-user nil nil)
      (manage-address nil (list *insufficient-privileges-message*)))))

(define-lab-route add-user ("/add-user/" :method :post)
  (with-authentication
    (with-admin-privileges
        (add-new-user (post-parameter +name-user-name+)
                      (post-parameter +name-user-email+)
                      (post-parameter +name-user-password+)
                      (post-parameter +name-user-level+))
      (manage-address nil (list *insufficient-privileges-message*)))))

(define-lab-route add-admin-user ("/add-admin/" :method :get)
  (if (not (exists-admin-p))
      (with-standard-html-frame (stream (_ "Add admin user") :errors nil :infos  nil)
        (html-template:fill-and-print-template #p"add-admin.tpl"
                                               (with-path-prefix
                                                   :email       +name-user-email+
                                                   :user-name   +name-user-name+
                                                   :password    +name-user-password+
                                                   :password-2  +name-user-password-2+)
                                               :stream stream))
      (progn
        (to-log +security-warning-log-level+
                "Someone requested ~a page but admin user exists!"
                (restas:genurl 'add-admin-user))
        (restas:redirect 'root))))

(define-lab-route change-pass ("/change-user-pass/" :method :get)
  (with-authentication
    (manage-password-change nil nil)))

(define-lab-route actual-user-change-pass ("/actual-user-change-pass/" :method :post)
  (with-authentication
    (change-password (post-parameter +name-user-old-password+)
                     (post-parameter +name-user-password+)
                     (post-parameter +name-user-password-2+))))

(define-lab-route actual-admin-change-pass ("/actual-admin-change-pass/" :method :post)
  (add-admin-password (post-parameter +name-user-name+)
                      (post-parameter +name-user-email+)
                      (post-parameter +name-user-password+)
                      (post-parameter +name-user-password-2+)))

(define-lab-route delete-user ("/delete-user/:id" :method :get)
  (with-authentication
    (with-admin-privileges
        (progn
          (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
            (let ((to-trash (single 'db:user :id id)))
              (when to-trash
                (del (single 'db:user :id id)))))
          (restas:redirect 'user))
      (manage-address nil (list *insufficient-privileges-message*)))))

(defun %set-user-account-status (id new-status)
  (with-authentication
    (with-admin-privileges
        (progn
          (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
            (let ((user (single 'db:user :id id)))
              (when user
                (setf (db:account-enabled user) new-status)
                (save user))))
          (restas:redirect 'user))
      (manage-address nil (list *insufficient-privileges-message*)))))

(define-lab-route disable-user ("/disable-user-account/:id" :method :get)
  (%set-user-account-status id (lognot +user-account-enabled+)))

(define-lab-route enable-user ("/enable-user-account/:id" :method :get)
  (%set-user-account-status id +user-account-enabled+))

(defun print-preferences-forms (infos errors)
  (with-standard-html-frame (stream
                             (_ "Manage preferences")
                             :infos  infos
                             :errors errors)
    (with-session-user (session-user)
      (let ((user (single 'db:user :id (db:id session-user))))
        (if session-user
            (html-template:fill-and-print-template #p"user-preferences.tpl"
                                                   (with-path-prefix
                                                       :choose-lang-lb    (_ "Change language")
                                                       :change-email-hd   (_ "Change email")
                                                       :email-lb          (_ "Email")
                                                       :login-email       +name-pref-email+
                                                       :login-email-value (db:email user)
                                                       :available-locales (i18n:translation-select-options))
                                                   :stream stream)
            (logout-user))))))

(define-lab-route user-change-locale ("/user-change-locale/" :method :post)
  (with-authentication
    (multiple-value-bind (infos errors)
        (change-locale (tbnl:post-parameter +name-pref-locale+))
      (print-preferences-forms infos errors))))

(define-lab-route user-change-email ("/user-change-email/" :method :post)
  (with-authentication
    (multiple-value-bind (infos errors)
        (change-email (tbnl:post-parameter +name-pref-email+))
      (print-preferences-forms infos errors))))


(define-lab-route user-preferences ("/user-preferences/" :method :get)
  (with-authentication
    (print-preferences-forms nil nil)))
