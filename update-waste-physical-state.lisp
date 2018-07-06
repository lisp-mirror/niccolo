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

(defun update-waste-physical-state (id expl)
  (let* ((errors-msg-1 (regexp-validate (list (list id +pos-integer-re+
                                                    (_ "Physical state id invalid"))
                                              (list expl
                                                    +free-text-re+
                                                    (_ "Physical state invalid")))))
         (errors-msg-2 (when (and (not errors-msg-1)
                                  (not (object-exists-in-db-p 'db:waste-physical-state id)))
                         (_ "physical state does not exists in database.")))
         (errors-msg-unique (when (all-null-p errors-msg-1 errors-msg-2)
                              (exists-with-different-id-validate 'db:waste-physical-state
                                                                 id
                                                                 (:explanation)
                                                                 (expl)
                                                                 (_ "Physical state code already in the database with different ID"))))
         (errors-msg (concatenate 'list errors-msg-1 errors-msg-2 errors-msg-unique))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "physical state updated."))))))
    (if (not errors-msg)
      (let ((new-phys (single 'db:waste-physical-state :id id)))
        (setf (db:explanation  new-phys) expl)
        (save new-phys)
        (manage-update-waste-phys-state (and success-msg id) success-msg errors-msg))
      (manage-waste-phys-state success-msg errors-msg))))

(defun prepare-for-update-waste-phys-state (id)
  (prepare-for-update id
                      'db:waste-physical-state
                      (_ "physical state does not exists in database.")
                      #'manage-update-waste-phys-state))

(defun manage-update-waste-phys-state (id infos errors)
  (let ((new-phys (and id (single 'db:waste-physical-state :id id))))
    (with-standard-html-frame (stream (_ "Update waste physical state")
                                      :infos infos :errors errors)
      (html-template:fill-and-print-template #p"update-waste-phys-state.tpl"
                                             (with-back-uri (waste-phys-state)
                                               (with-path-prefix
                                                   :explanation-lb (_ "Statement")
                                                   :id         (and id
                                                                    (db:id new-phys))
                                                   :expl-value (and id
                                                                    (db:explanation new-phys))
                                                   :expl        +name-waste-phys-state-expl+))
                                             :stream stream))))

(define-lab-route update-waste-phys-state ("/update-waste-phys-state/:id" :method :get)
  (with-authentication
    (with-admin-credentials
        (progn
          (let ((new-expl     (get-parameter +name-waste-phys-state-expl+)))
            (if new-expl
                (update-waste-physical-state id new-expl)
                (prepare-for-update-waste-phys-state id))))
      (manage-update-waste-phys-state nil nil (list *insufficient-privileges-message*)))))
