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

(define-constant +name-waste-phys-state-expl+         "expl"         :test #'string=)

(gen-autocomplete-functions db:waste-physical-state
                            db:explanation)


(defun all-waste-phys-state-select ()
  (db-query (select (( :as :wp.id          :id)
                     ( :as :wp.explanation :explanation))
              (from (:as :waste-physical-state :wp))
              (order-by (:asc :wp.explanation)))))

(defun build-template-list-waste-phys-state (&key (delete-link nil) (update-link nil))
  (let ((raw (map 'list #'(lambda (row)
                            (map 'list
                                 #'(lambda (cell)
                                     (if (symbolp cell)
                                         (make-keyword (string-upcase (symbol-name cell)))
                                         cell))
                                 row))
                  (all-waste-phys-state-select))))
  (do-rows (rown res) raw
    (let* ((row (elt raw rown)))
      (setf (elt raw rown)
            (nconc row
                   (if delete-link
                       (list :delete-link (restas:genurl delete-link :id (getf row :id)))
                       nil)
                   (if update-link
                       (list :update-link (restas:genurl update-link :id (getf row :id)))
                       nil)))))
  raw))

(defun add-new-waste-phys-state (explanation)
  (let* ((errors-msg-1 (regexp-validate (list
                                         (list explanation +free-text-re+ (_ "Input invalid")))))
         (errors-msg-2 (when (not errors-msg-1)
                         (unique-p-validate 'db:waste-physical-state
                                            :explanation explanation
                                            (_ "Physical state already in the database"))))
         (errors-msg (concatenate 'list errors-msg-1 errors-msg-2))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "Saved new physical state: ~s")
                                         explanation)))))
    (when (not errors-msg)
      (let ((state (db-create'db:waste-physical-state
                         :explanation  explanation)))
        (db-save state)))
    (manage-waste-phys-state success-msg errors-msg)))

(defun manage-waste-phys-state (infos errors)
  (let ((all-phy-state (build-template-list-waste-phys-state
                        :delete-link 'delete-waste-phys-state
                        :update-link 'update-waste-phys-state)))
    (with-standard-html-frame (stream (_ "Manage waste physical state")
                                      :infos infos :errors errors)
      (html-template:fill-and-print-template #p"add-waste-physical-state.tpl"
                                             (with-back-to-root
                                                 (with-path-prefix
                                                     :explanation-lb (_ "Statement")
                                                     :operations-lb  (_ "Operations")
                                                     :expl           +name-waste-phys-state-expl+
                                                     :data-table     all-phy-state))
                                             :stream stream))))

(define-lab-route waste-phys-state ("/waste-phys-state/" :method :get)
  (with-authentication
    (manage-waste-phys-state nil nil)))

(define-lab-route add-waste-phys-state ("/add-waste-phys-state/" :method :get)
  (with-authentication
    (with-admin-credentials
        (progn
          (add-new-waste-phys-state (get-clean-parameter +name-waste-phys-state-expl+)))
      (manage-waste-phys-state nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-waste-phys-state ("/delete-waste-phys-state/:id" :method :get)
  (with-authentication
    (with-admin-credentials
        (progn
          (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
            (let ((to-trash (db-single 'db:waste-physical-state :id id)))
              (when to-trash
                (db-del (db-single 'db:waste-physical-state :id id)))))
          (restas:redirect 'waste-phys-state))
      (manage-waste-phys-state nil (list *insufficient-privileges-message*)))))
