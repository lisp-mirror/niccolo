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

(define-constant +name-user-lab-user-id+ "user-id"            :test #'string=)

(define-constant +name-labs-name+        "labs"               :test #'string=)

(defun fetch-user-labs-template ()
  (let* ((all-users      (filter 'db:user))
         (all-labs       (filter 'db:laboratory)))
    (loop for user in all-users collect
         (append (list :username      (db:username user)
                       :user-id       +name-user-lab-user-id+
                       :user-id-value (db:id       user)
                       :list-labs     (loop for lab in all-labs collect
                                           (list :lab-id-checkbox (db:id   lab)
                                                 :lab-id-name     +name-labs-name+
                                                 :lab-name        (db:name lab)
                                                 :checked         (and (db:owner lab)
                                                                       (= (db:owner lab)
                                                                          (db:id user))))))))))

(defun manage-assoc-user-lab (infos errors &key (start-from 0) (data-count 1))
  (let ((labs-template (fetch-user-labs-template)))
    (multiple-value-bind (next-start prev-start)
        (pagination-bounds (actual-pagination-start start-from)
                           (actual-pagination-count data-count)
                           'db:user)
      (let* ((template        (with-back-to-root
                                (with-pagination-template
                                    (next-start
                                     prev-start
                                     (restas:genurl 'assoc-user-lab))
                                  (with-path-prefix
                                      :username-lb   (_ "Username")
                                      :user-id-lb    (_ "User ID")
                                      :operations-lb (_ "Operations")
                                      :data-table    labs-template)))))
        (with-standard-html-frame (stream
                                   (_ "Associate User to Laboratories")
                                   :errors errors
                                   :infos  infos)
          (html-template:fill-and-print-template #p"assoc-user-labs.tpl"
                                                 template
                                                 :stream stream))))))

(defun add-assoc-user-lab (user-id lab-ids)
  (flet ((valid-id-lab-p (lab-id)
           (and (every #'null
                       (regexp-validate (list (list lab-id
                                                        +pos-integer-re+ "")))) ;; nil if valid
                (single 'db:laboratory :id lab-id))))
    (let* ((errors-msg-1 (with-id-valid-and-used 'db:user user-id (_ "User invalid")))
           (errors-msg-2 nil)
           (errors-msg   (concatenate 'list errors-msg-1 errors-msg-2))
           (success-msg  (list (format nil
                                       (_ "User ~s associed with: ")
                                       (db:username (single 'db:user :id user-id))))))
      (when (not errors-msg)
        ;; adding
        (loop for lab-id in lab-ids do
             (if (valid-id-lab-p lab-id)
                 (let ((lab (single 'db:laboratory :id lab-id)))
                   (setf (db:owner lab) user-id)
                   (save lab)
                   (setf success-msg (concatenate 'list
                                                  success-msg
                                                  (list (format nil "~a" (db:name lab))))))
                 (setf errors-msg (concatenate 'list
                                               errors-msg
                                               (list (format nil (_ "invalid id provided")))))))
      ;; removing
        (let* ((all-lab-ids   (mapcar #'db:id (filter 'db:laboratory)))
               (associed-ids  (mapcar #'parse-integer (remove-if-not #'valid-id-lab-p lab-ids)))
               (to-delete-ids (set-difference all-lab-ids associed-ids :test #'=)))
          (loop for to-delete-id in to-delete-ids do
               (when-let ((lab (single 'db:laboratory :id to-delete-id :owner user-id)))
                 (setf (db:owner lab) nil)
                 (save lab)))))
      (values success-msg errors-msg))))

(define-lab-route assoc-user-lab ("/assoc-user-lab/" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (with-pagination (pagination-uri utils:*alias-pagination*)
          (let ((infos  nil)
                (errors nil))
            (when (get-parameter-non-nil-p +name-user-lab-user-id+)
              (multiple-value-bind (infos-from-add error-from-add)
                  (add-assoc-user-lab (get-parameter +name-user-lab-user-id+)
                                      (filter-all-get-params +name-labs-name+))
                (setf infos  infos-from-add
                      errors error-from-add)))
            (manage-assoc-user-lab infos errors
                                   :start-from
                                   (session-pagination-start pagination-uri
                                                             utils:*alias-pagination*)
                                   :data-count
                                   (session-pagination-count pagination-uri
                                                             utils:*alias-pagination*))))
      (manage-address nil (list *insufficient-privileges-message*)))))
