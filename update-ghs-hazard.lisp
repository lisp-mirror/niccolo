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

(defun update-haz (id code expl carcinogenic)
  (let* ((errors-msg-1 (regexp-validate (list
                                         (list id   +pos-integer-re+ (_ "GHS id invalid"))
                                         (list code +ghs-hazard-code-re+ (_ "GHS code invalid"))
                                         (list expl +free-text-re+ (_ "GHS phrase invalid"))
                                         (list expl +free-text-re+
                                               (_ "GHS Carcinogenic code invalid")))))
         (errors-msg-2 (when (and (not errors-msg-1)
                                  (not (object-exists-in-db-p 'db:ghs-hazard-statement id)))
                         (_ "GHS statement does not exists in database.")))
         (errors-msg-unique (when (all-null-p errors-msg-1 errors-msg-2)
                              (exists-with-different-id-validate 'db:ghs-hazard-statement
                                                                 id
                                                                 (:code)
                                                                 (code)
                                                                 (_ "GHS code already in the database with different ID"))))
         (errors-msg (concatenate 'list errors-msg-1 errors-msg-2 errors-msg-unique))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "GHS hazard statements updated."))))))
    (if (not errors-msg)
      (let ((new-haz (single 'db:ghs-hazard-statement :id id)))
        (setf (db:code         new-haz) code
              (db:explanation  new-haz) expl
              (db:carcinogenic new-haz) carcinogenic)
        (save new-haz)
        (manage-update-haz (and success-msg id) success-msg errors-msg))
      (manage-ghs-hazard-code success-msg errors-msg))))

(defun prepare-for-update-haz (id)
  (prepare-for-update id
                      'db:ghs-hazard-statement
                      (_ "GHS statement does not exists in database.")
                      #'manage-update-haz))

(defun manage-update-haz (id infos errors)
  (let ((new-haz (and id (single 'db:ghs-hazard-statement :id id))))
    (with-standard-html-frame (stream (_ "Update GHS hazard statement")
                                      :infos infos :errors errors)
      (html-template:fill-and-print-template #p"update-ghs-hazard.tpl"
                                             (with-back-uri (ghs-hazard)
                                               (with-path-prefix
                                                   :code-lb           (_ "Code")
                                                   :statement-lb      (_ "Statement")
                                                   :carcinogenic-p-lb (_ "Carcinogenic?")
                                                   :id         (and id
                                                                    (db:id new-haz))
                                                   :code-value (and id
                                                                    (db:code new-haz))
                                                   :expl-value (and id
                                                                    (db:explanation new-haz))
                                                   :carcinogenic-value
                                                   (and id
                                                        (db:carcinogenic new-haz))
                                                   :code         +name-ghs-hazard-code+
                                                   :expl         +name-ghs-hazard-expl+
                                                   :carcinogenic +name-ghs-hazard-carcinogenic+))
                                             :stream stream))))

(define-lab-route update-hazard ("/update-h/:id" :method :get)
  (with-authentication
    (with-admin-credentials
        (progn
          (let ((new-code     (get-clean-parameter +name-ghs-hazard-code+))
                (new-expl     (get-clean-parameter +name-ghs-hazard-expl+))
                (new-carc     (get-clean-parameter +name-ghs-hazard-carcinogenic+)))
            (if (and new-code
                     new-expl
                     new-carc)
                (update-haz id new-code new-expl new-carc)
                (prepare-for-update-haz id))))
      (manage-update-haz nil nil (list *insufficient-privileges-message*)))))
