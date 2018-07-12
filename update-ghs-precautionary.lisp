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

(defun update-prec (id code expl)
  (let* ((errors-msg-1 (regexp-validate (list (list id +pos-integer-re+
                                                    (_ "GHS id invalid"))
                                              (list code
                                                    +ghs-precautionary-code-re+
                                                    (_ "GHS code invalid"))
                                              (list expl
                                                    +free-text-re+
                                                    (_ "GHS phrase invalid")))))
         (errors-msg-2 (when (and (not errors-msg-1)
                                  (not (object-exists-in-db-p 'db:ghs-precautionary-statement id)))
                         (_ "GHS statement does not exists in database.")))
         (errors-msg-unique (when (all-null-p errors-msg-1 errors-msg-2)
                              (exists-with-different-id-validate 'db:ghs-precautionary-statement
                                                                 id
                                                                 (:code)
                                                                 (code)
                                                                 (_ "GHS code already in the database with different ID"))))
         (errors-msg (concatenate 'list errors-msg-1 errors-msg-2 errors-msg-unique))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "GHS precautionary statements updated."))))))
    (if (not errors-msg)
      (let ((new-prec (single 'db:ghs-precautionary-statement :id id)))
        (setf (db:code         new-prec) code
              (db:explanation  new-prec) expl)
        (save new-prec)
        (manage-update-prec (and success-msg id) success-msg errors-msg))
      (manage-ghs-precautionary-code success-msg errors-msg))))

(defun prepare-for-update-prec (id)
  (prepare-for-update id
                      'db:ghs-precautionary-statement
                      (_ "GHS statement does not exists in database.")
                      #'manage-update-prec))

(defun manage-update-prec (id infos errors)
  (let ((new-prec (and id (single 'db:ghs-precautionary-statement :id id))))
    (with-standard-html-frame (stream (_ "Update GHS precautionary statement")
                                      :infos infos :errors errors)
      (html-template:fill-and-print-template #p"update-ghs-precautionary.tpl"
                                             (with-back-uri (ghs-precautionary)
                                               (with-path-prefix
                                                   :code-lb (_ "Code")
                                                   :statement-lb (_ "Statement")
                                                   :id         (and id
                                                                    (db:id new-prec))
                                                   :code-value (and id
                                                                    (db:code new-prec))
                                                   :expl-value (and id
                                                                    (db:explanation new-prec))
                                                   :code         +name-ghs-precautionary-code+
                                                   :expl         +name-ghs-precautionary-expl+))
                                             :stream stream))))

(define-lab-route update-precautionary ("/update-p/:id" :method :get)
  (with-authentication
    (with-admin-credentials
        (progn
          (let ((new-code     (get-clean-parameter +name-ghs-precautionary-code+))
                (new-expl     (get-clean-parameter +name-ghs-precautionary-expl+)))
            (if (and new-code
                     new-expl)
                (update-prec id new-code new-expl)
                (prepare-for-update-prec id))))
      (manage-update-prec nil nil (list *insufficient-privileges-message*)))))
