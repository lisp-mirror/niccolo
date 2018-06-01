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

(defun update-storage (id name building-id floor)
  (let* ((errors-msg-1 (concatenate 'list
                                    (regexp-validate (list (list id
                                                                 +pos-integer-re+
                                                                 (_ "ID invalid"))
                                                           (list building-id
                                                                 +pos-integer-re+
                                                                 (_ "Address id invalid"))
                                                           (list name
                                                                 +free-text-re+
                                                                 (_ "Name invalid"))
                                                           (list floor
                                                                 +free-text-re+
                                                                 (_ "Floor invalid"))))))
         (errors-msg-2  (when (and (not errors-msg-1)
                                   (not (object-exists-in-db-p 'db:storage id)))
                          (list (_ "Storage does not exists in database"))))
         (errors-msg-building-not-found (when (and (not errors-msg-1)
                                                   (not (single 'db:building :id building-id)))
                                         (list (_ "Building not in the database"))))
         (errors-msg-unique (when (all-null-p errors-msg-1 errors-msg-2)
                              (exists-with-different-id-validate 'db:storage
                                                                 id
                                                                 (:name :building-id :floor-number)
                                                                 (name  building-id  floor)
                                                                 (_ "Storage already in the database with different ID"))))
         (errors-msg (concatenate 'list
                                  errors-msg-1
                                  errors-msg-2
                                  errors-msg-building-not-found
                                  errors-msg-unique))
         (success-msg (and (not errors-msg)
                           (list (_ "Storage updated")))))
    (if (not errors-msg)
      (let ((storage-updated (single 'db:storage :id id)))
        (setf (db:name         storage-updated) name
              (db:building-id  storage-updated) building-id
              (db:floor-number storage-updated) floor)
        (save storage-updated)
        (manage-update-storage (and success-msg id) success-msg errors-msg))
      (manage-storage success-msg errors-msg))))

(defun prepare-for-update-storage (id)
  (prepare-for-update id
                      'db:storage
                      (_ "Storage does not exists in database.")
                      #'manage-update-storage))

(defun manage-update-storage (id infos errors)
  (let* ((html-template:*string-modifier* #'identity)
         (json-buildings    (array-autocomplete-building))
         (json-buildings-id (array-autocomplete-building-id))
         (new-storage       (and id
                                 (object-exists-in-db-p 'db:storage id)))
         (template          (with-back-uri (storage)
                              (with-path-prefix
                                  :name-lb          (_ "Name")
                                  :building-lb      (_ "Building")
                                  :floor-lb         (_ "Floor")
                                  :id               (and id
                                                         (db:id new-storage))
                                  :name-value       (and id
                                                         (db:name new-storage))
                                  :building-id-value (and id
                                                          (db:building-id new-storage))
                                  :building-value  (and id
                                                        (single 'db:building
                                                                :id (db:building-id new-storage))
                                                        (db:build-description
                                                         (single 'db:building
                                                                 :id (db:building-id new-storage))))
                                  :floor-value     (and id
                                                        (db:floor-number new-storage))
                                  :name              +name-storage-proper-name+
                                  :building-id       +name-storage-building-id+
                                  :floor             +name-storage-floor+
                                  :json-buildings    json-buildings
                                  :json-buildings-id json-buildings-id))))
    (with-standard-html-frame (stream (_ "Update Storage")
                                      :infos infos :errors errors)
      (html-template:fill-and-print-template #p"update-storage.tpl"
                                             template
                                             :stream stream))))

(define-lab-route update-storage-route ("/update-storage/:id" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (let ((new-name        (get-parameter +name-storage-proper-name+))
                (new-building-id (get-parameter +name-storage-building-id+))
                (new-floor       (get-parameter +name-storage-floor+)))
            (if (and new-name
                     new-building-id
                     new-floor)
                (update-storage id new-name new-building-id new-floor)
                (prepare-for-update-storage id))))
      (manage-update-storage nil nil (list *insufficient-privileges-message*)))))
