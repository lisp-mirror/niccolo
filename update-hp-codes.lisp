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

(defun update-hp-waste-code (id code expl)
  (let* ((errors-msg-1 (regexp-validate (list (list id +pos-integer-re+
                                                    (_ "HP id invalid"))
                                              (list code
                                                    +hp-waste-code-re+
                                                    (_ "HP code invalid"))
                                              (list expl
                                                    +free-text-re+
                                                    (_ "HP phrase invalid")))))
         (errors-msg-2 (when (and (not errors-msg-1)
                                  (not (object-exists-in-db-p 'db:hp-waste-code id)))
                         (_ "HP statement does not exists in database.")))
         (errors-msg-unique (when (all-null-p errors-msg-1 errors-msg-2)
                              (exists-with-different-id-validate 'db:hp-waste-code
                                                                 id
                                                                 (:code)
                                                                 (code)
                                                                 (_ "HP code already in the database with different ID"))))
         (errors-msg (concatenate 'list errors-msg-1 errors-msg-2 errors-msg-unique))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "HP code updated."))))))
    (if (not errors-msg)
      (let ((new-code (single 'db:hp-waste-code :id id)))
        (setf (db:code         new-code) code
              (db:explanation  new-code) expl)
        (save new-code)
        (manage-update-hp-waste-code (and success-msg id) success-msg errors-msg))
      (manage-hp-waste-code success-msg errors-msg))))

(defun prepare-for-update-hp-waste-code (id)
  (prepare-for-update id
                      'db:hp-waste-code
                      (_ "HP statement does not exists in database.")
                      #'manage-update-hp-waste-code))

(defun manage-update-hp-waste-code (id infos errors)
  (let ((new-code (and id (single 'db:hp-waste-code :id id))))
    (with-standard-html-frame (stream (_ "Update HP code statement")
                                      :infos infos :errors errors)
      (html-template:fill-and-print-template #p"update-hp-waste-code.tpl"
                                             (with-back-uri (hp-waste)
                                               (with-path-prefix
                                                   :code-lb      (_ "Code")
                                                   :statement-lb (_ "Statement")
                                                   :id           (and id
                                                                      (db:id new-code))
                                                   :code-value   (and id
                                                                      (db:code new-code))
                                                   :expl-value   (and id
                                                                      (db:explanation new-code))
                                                   :code         +name-hp-waste-code+
                                                   :expl         +name-hp-waste-expl+))
                                             :stream stream))))

(define-lab-route update-hp-waste ("/update-hp-waste/:id" :method :get)
  (with-authentication
    (with-admin-credentials
        (progn
          (let ((new-code     (get-parameter +name-hp-waste-code+))
                (new-expl     (get-parameter +name-hp-waste-expl+)))
            (if (and new-code
                     new-expl)
                (update-hp-waste-code id new-code new-expl)
                (prepare-for-update-hp-waste-code id))))
      (manage-update-hp-waste-code nil nil (list *insufficient-privileges-message*)))))
