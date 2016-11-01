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

(defun update-map (id description)
  (let* ((errors-msg-1  (regexp-validate (list (list description
						     +free-text-re+
						     (_ "Description invalid")))))
	 (errors-msg-id (regexp-validate (list (list id
						     +pos-integer-re+
						     (_ "Id invalid")))))
	 (errors-msg-2  (when (and (not errors-msg-1)
				   (not errors-msg-id)
				   (not (single 'db:plant-map :id id)))
			  (_ "Map not in database")))
	 (errors-msg-unique (when (all-null-p errors-msg-1 errors-msg-id errors-msg-2)
			      (exists-with-different-id-validate 'db:plant-map
								 id
								 (:description)
								 (description)
								 (_ "Map description already in the database with different ID"))))
	 (errors-msg (concatenate 'list
				  errors-msg-1
				  errors-msg-id
				  errors-msg-2
				  errors-msg-unique))
	 (success-msg (and (not errors-msg)
			   (list (format nil (_ "Map: ~s updated") description)))))
    (if (not errors-msg)
	(let ((new-map (single 'db:plant-map :id id)))
	  (setf (db:description new-map) description)
	  (save new-map)
	  (manage-update-map (and success-msg id) success-msg errors-msg))
	(manage-map success-msg errors-msg))))

(defun prepare-for-update-map (id)
  (prepare-for-update id
		      'db:plant-map
		      (_ "Map does not exists in database.")
		      #'manage-update-map))

(defun manage-update-map (id infos errors)
  (let ((new-map (and id (single 'db:plant-map :id id))))
    (with-standard-html-frame (stream (_ "Update Map") :infos infos :errors errors)
      (html-template:fill-and-print-template #p"update-map.tpl"
					     (with-back-uri (plant-map)
					       (with-path-prefix
						   :description-lb (_ "Description")
						   :id         (and id
								    (db:id new-map))
						   :desc-value (and id
								    (db:description new-map))
						   :desc        +name-map-description+))
					     :stream stream))))

(define-lab-route update-map-route ("/update-map/:id" :method :get)
  (with-authentication
    (with-admin-privileges
	(let ((new-description (get-parameter +name-map-description+)))
	  (if new-description
	      (update-map id new-description)
	      (prepare-for-update-map id)))
      (manage-update-map nil nil (list *insufficient-privileges-message*)))))
