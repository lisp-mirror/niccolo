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

(defun update-lab (id name complete-name)
    (let* ((errors-msg-1      (regexp-validate (list
                                                (list name +laboratory-name-re+
                                                      (_ "Laboratory name invalid"))
                                                (list complete-name +free-text-re+
                                                      (_ "Laboratory complete name invalid")))))
           (errors-msg-2      (when (and (not errors-msg-1)
                                         (not (object-exists-in-db-p 'db:laboratory id)))
                                (_ "Laboratory does not exists in database")))
           (errors-msg-unique
            (when (all-null-p errors-msg-1 errors-msg-2)
              (exists-with-different-id-validate 'db:ghs-hazard-statement
                                                 id
                                                 (:name :complete-name)
                                                 (name  complete-name)
                                                 (_ "laboratory already in the database with different ID"))))
           (errors-msg  (concatenate 'list errors-msg-1 errors-msg-2 errors-msg-unique))
           (success-msg (and (not errors-msg)
                             (list (format nil (_ "Laboratory ~s updated") name)))))
      (if (not errors-msg)
          (let ((new-laboratory (db-single 'db:laboratory :id id)))
            (setf (db:name          new-laboratory) name
                  (db:complete-name new-laboratory) complete-name)
            (db-save new-laboratory)
            (manage-update-laboratory (and success-msg id) success-msg errors-msg))
          (manage-ghs-hazard-code success-msg errors-msg))))

(defun prepare-for-update-laboratory (id)
  (prepare-for-update id
                      'db:laboratory
                      (_ "This laboratory does not exists in database.")
                      #'manage-update-laboratory))

(defun manage-update-laboratory (id infos errors)
  (let ((new-laboratory (and id (db-single 'db:laboratory :id id))))
    (with-standard-html-frame (stream (_ "Update laboratory")
                                      :infos infos :errors errors)
      (html-template:fill-and-print-template #p"update-laboratory.tpl"
                                             (with-back-uri (laboratory)
                                               (with-path-prefix
                                                   :name-lb          (_ "Name")
                                                   :complate-name-lb (_ "Complete name")
                                                   :id               (and id
                                                                          (db:id new-laboratory))
                                                   :name-value       (and id
                                                                          (db:name new-laboratory))
                                                   :complete-name-value
                                                   (and id
                                                        (db:complete-name new-laboratory))
                                                   :name             +name-lab-name+
                                                   :complete-name    +name-lab-complete-name+))
                                             :stream stream))))

(define-lab-route update-laboratory ("/update-laboratory/:id" :method :get)
  (with-authentication
    (with-admin-credentials
        (progn
          (let ((new-name          (get-clean-parameter +name-lab-name+))
                (new-complete-name (get-clean-parameter +name-lab-complete-name+)))
            (if (and new-name
                     new-complete-name)
                (update-lab id new-name new-complete-name)
                (prepare-for-update-laboratory id))))
      (manage-update-laboratory nil nil (list *insufficient-privileges-message*)))))
