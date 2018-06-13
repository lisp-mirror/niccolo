;; niccolo': a chemicals inventory
;; Copyright (C) 2017  Universita' degli Studi di Palermo

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

(define-constant +name-lab-id+                   "id"          :test #'string=)

(define-constant +name-lab-name+                 "name"        :test #'string=)

(define-constant +name-lab-owner+                "resp"        :test #'string=)

(gen-autocomplete-functions db:laboratory db:name)

(defun add-new-laboratory (name &key (start-from 0) (data-count 1))
  (let* ((errors-msg-1 (regexp-validate (list
                                         (list name +laboratory-name-re+
                                               (_ "Laboratory name invalid")))))
         (errors-msg-2 (when (not errors-msg-1)
                         (unique-p-validate 'db:laboratory
                                            :name
                                            name
                                            (_ "Laboratory already in the database"))))
         (errors-msg  (concatenate 'list errors-msg-1 errors-msg-2))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "Saved new laboratory ~s") name)))))
    (when (not errors-msg)
      (let ((lab (create 'db:laboratory
                         :name name)))
        (save lab)))
    (manage-laboratory success-msg
                       errors-msg
                       :start-from start-from
                       :data-count data-count)))

(defun manage-laboratory (infos errors &key (start-from 0) (data-count 1))
  (let ((all-labs (fetch-raw-template-list 'db:laboratory
                                           '(:id :name :owner)
                                           :delete-link 'delete-laboratory
                                           :additional-tpl
                                           #'(lambda (lab)
                                               (when (and lab
                                                          (db:owner lab))
                                                 (let ((user (single 'db:user
                                                                     :id (db:owner lab))))
                                                   (when user
                                                     (list :owner-user
                                                           (db:username user)))))))))
    (multiple-value-bind (next-start prev-start)
        (pagination-bounds (actual-pagination-start start-from)
                           (actual-pagination-count data-count)
                           'db:laboratory)
      (with-standard-html-frame (stream (_ "Manage laboratory") :infos infos :errors errors)
        (html-template:fill-and-print-template #p"add-laboratory.tpl"
                                               (with-back-to-root
                                                   (with-pagination-template
                                                       (next-start
                                                        prev-start
                                                        (restas:genurl 'laboratory))
                                                     (with-path-prefix
                                                         :name-lb       (_ "Name")
                                                         :owner-lb
                                                         (_ "Responsible person")
                                                         :operations-lb (_ "Operations")
                                                         :name         +name-lab-name+
                                                         :owner        +name-lab-owner+
                                                         :next-start   next-start
                                                         :prev-start   prev-start
                                                         :data-table   all-labs)))
                                               :stream stream)))))

(define-lab-route laboratory ("/laboratory/" :method :get)
  (with-authentication
    (with-pagination (pagination-uri utils:*alias-pagination*)
      (manage-laboratory nil nil
                         :start-from (session-pagination-start pagination-uri
                                                               utils:*alias-pagination*)
                         :data-count (session-pagination-count pagination-uri
                                                               utils:*alias-pagination*)))))

(define-lab-route add-laboratory ("/add-laboratory/" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (with-pagination (pagination-uri utils:*alias-pagination*)
          (add-new-laboratory (get-parameter +name-lab-name+)
                              :start-from (session-pagination-start pagination-uri
                                                                    utils:*alias-pagination*)
                              :data-count (session-pagination-count pagination-uri
                                                                    utils:*alias-pagination*)))
      (manage-laboratory nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-laboratory ("/delete-laboratory/:id" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
            (let ((to-trash (single 'db:laboratory :id id)))
              (when to-trash
                (del (single 'db:laboratory :id id)))))
          (restas:redirect 'laboratory))
      (manage-laboratory nil (list *insufficient-privileges-message*)))))
