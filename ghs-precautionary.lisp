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

(define-constant +name-ghs-precautionary-expl+ "expl" :test #'string=)

(define-constant +name-ghs-precautionary-code+ "code" :test #'string=)

(defun add-new-ghs-precautionary-code (code expl &key (start-from 0) (data-count 1))
  (let* ((errors-msg-1 (concatenate 'list
                                    (regexp-validate (list
                                                      (list code
                                                            +ghs-precautionary-code-re+
                                                            (_ "GHS code invalid"))
                                                      (list expl
                                                            +free-text-re+
                                                            (_ "GHS phrase invalid"))))))
         (errors-msg-2  (when (not errors-msg-1)
                          (unique-p-validate 'db:ghs-precautionary-statement
                                             :code
                                             code
                                             (_ "GHS code already in the database"))))
         (errors-msg (concatenate 'list errors-msg-1 errors-msg-2))
         (success-msg (and (not errors-msg)
                           (list (format nil
                                         (_ "Saved new GHS precautionary statements: ~s - ~s")
                                         code expl)))))
    (when (not errors-msg)
      (let ((ghs (create 'db:ghs-precautionary-statement
                         :code code
                         :explanation expl)))
        (save ghs)))
    (manage-ghs-precautionary-code success-msg
                                   errors-msg
                                   :start-from start-from
                                   :data-count data-count)))

(defun manage-ghs-precautionary-code (infos errors &key (start-from 0) (data-count 1))

  (let* ((all-ghss       (fetch-raw-template-list 'db:ghs-precautionary-statement
                                                  '(:id :code :explanation)
                                                  :delete-link 'delete-ghs-precautionary
                                                  :additional-tpl
                                                  #'(lambda (row)
                                                      (list
                                                       :update-link
                                                       (restas:genurl 'update-precautionary
                                                                      :id (db:id row))))))
         (paginated-ghss (slice-for-pagination all-ghss
                                               (actual-pagination-start start-from)
                                               (actual-pagination-count data-count))))
    (multiple-value-bind (next-start prev-start)
        (pagination-bounds (actual-pagination-start start-from)
                           (actual-pagination-count data-count)
                           'db:ghs-precautionary-statement)
      (with-standard-html-frame (stream (_ "Manage GHS Precautionary Statements")
                                        :infos  infos
                                        :errors errors)
        (html-template:fill-and-print-template #p"add-precautionary.tpl"
                                               (with-back-to-root
                                                   (with-pagination-template
                                                       (next-start
                                                        prev-start
                                                        (restas:genurl 'ghs-precautionary))
                                                     (with-path-prefix
                                                         :code-lb       (_ "Code")
                                                         :statement-lb  (_ "Statement")
                                                         :operations-lb (_ "Operations")
                                                         :code
                                                         +name-ghs-precautionary-code+
                                                         :expl
                                                         +name-ghs-precautionary-expl+
                                                         :data-table    paginated-ghss)))
                                               :stream stream)))))

(define-lab-route ghs-precautionary ("/ghs-precautionary/" :method :get)
  (with-authentication
    (with-pagination (pagination-uri utils:*alias-pagination*)
      (manage-ghs-precautionary-code nil nil
                                     :start-from (session-pagination-start pagination-uri
                                                                           utils:*alias-pagination*)
                                     :data-count
                                     (session-pagination-count pagination-uri
                                                               utils:*alias-pagination*)))))

(define-lab-route add-ghs-precautionary ("/add-ghs-precautionary/" :method :get)
  (with-authentication
    (with-admin-privileges
        (with-pagination (pagination-uri utils:*alias-pagination*)
          (add-new-ghs-precautionary-code (get-parameter +name-ghs-precautionary-code+)
                                          (get-parameter +name-ghs-precautionary-expl+)
                                          :start-from (session-pagination-start pagination-uri
                                                                                utils:*alias-pagination*)
                                          :data-count
                                          (session-pagination-count pagination-uri utils:*alias-pagination*)))
      (manage-ghs-precautionary-code nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-ghs-precautionary ("/delete-ghs-precautionary/:id" :method :get)
  (with-authentication
    (with-admin-privileges
        (with-pagination (pagination-uri utils:*alias-pagination*)
          (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
            (let ((to-trash (single 'db:ghs-precautionary-statement :id id)))
              (when to-trash
                (del (single 'db:ghs-precautionary-statement  :id id)))))
          (restas:redirect 'ghs-precautionary))
      (manage-ghs-precautionary-code nil (list *insufficient-privileges-message*)))))
