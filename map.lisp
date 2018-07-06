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

(define-constant +name-map-data+        "file"  :test #'string=)

(define-constant +name-map-id+          "id"    :test #'string=)

(define-constant +name-map-description+ "desc"  :test #'string=)

(define-constant +name-map-link+        "link"  :test #'string=)

(defun dump-map (id)
  (let ((tmp-file (utils:temp-filename))
        (map      (single 'db:plant-map :id id)))
    (if map
        (with-open-file (stream tmp-file :direction :output :if-exists :error
                                :if-does-not-exist :create
                                :element-type '(unsigned-byte 8))
          (write-sequence (base64-decode (db:data map))
                          stream)
          tmp-file)
        nil)))

(defmacro with-dump-map ((tmp-file id) &body body)
  `(let ((,tmp-file (dump-map ,id)))
     (when ,tmp-file
       (unwind-protect
            (progn ,@body)
         (delete-file ,tmp-file)))))

(define-lab-route display-map ("/render-map/:id/:sc/:tc")
  (with-authentication
    (when (not (regexp-validate (list (list id +pos-integer-re+ "no"))))
      (with-dump-map (tmp-image-file id)
        (setf (header-out :content-type) "image/png")
        (cl-gd:with-image-from-file (bg tmp-image-file :png)
          (multiple-value-bind (old-w old-h)
              (cl-gd:image-size bg)
            (flexi-streams:with-output-to-sequence (stream :element-type '(unsigned-byte 8))
              (cl-gd:with-image* (old-w old-h t)
                (let ((s-coord (clamp (safe-parse-number sc) 0.0 1.0))
                      (t-coord (clamp (safe-parse-number tc) 0.0 1.0))
                      (circle-size (/ (cl-gd:image-width) +relative-circle-size+)))
                  (cl-gd:copy-image bg cl-gd:*default-image* 0 0 0 0 old-w old-h)
                  (let ((red (cl-gd:allocate-color 255 0 0)))
                    ;; move origin to center of image
                    (cl-gd:with-transformation (:x1 (* s-coord (- old-w))
                                                :x2 (* (1- s-coord) (- old-w))
                                                :y1 (* t-coord (- old-h))
                                                :y2 (* (1- t-coord) (- old-h))
                                                :radians t)
                      (cl-gd:draw-arc 0 0 circle-size circle-size 0.0 (* 2 pi)
                                      :center-connect t :filled t :color red))
                    (cl-gd:write-png-to-stream stream)))))))))))

(defun add-new-map (data-file description)
  (let* ((errors-msg-desc (regexp-validate (list (list description +free-text-re+
                                                       (_ "Description invalid")))))
         (errors-msg-file (when (not (png-validate-p data-file))
                            (list "Invalid png file")))
         (errors-msg-unique (unique-p-validate 'db:plant-map
                                               'db:description
                                               description
                                               (format nil
                                                       (_ "Map: ~s Already exists.")
                                                       description)))
         (errors-msg (concatenate 'list errors-msg-desc errors-msg-file errors-msg-unique))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "Map ~s saved") description)))))
    (when (not errors-msg)
      (with-open-file (stream data-file
                              :direction :input
                              :if-does-not-exist :error
                              :element-type '(unsigned-byte 8))
        (let ((raw-data (make-array (file-length stream))))
          (read-sequence raw-data stream)
          (let ((plant-map (create 'db:plant-map
                                   :description description
                                   :data (base64-encode raw-data))))
            (save plant-map)))))
    (manage-map success-msg errors-msg)))

(defun manage-map (infos errors)
  (let* ((all-maps (mapcar #'(lambda (row)
                               (append row (list :link (restas:genurl 'get-plant-map
                                                                      :id
                                                                      (getf row :id)))))
                           (fetch-raw-template-list 'db:plant-map '(:id :description)
                                                    :delete-link 'delete-plant-map
                                                    :additional-tpl
                                                    #'(lambda (row)
                                                        (list
                                                         :update-map-link
                                                         (restas:genurl 'update-map-route
                                                                        :id (db:id row))
                                                         :sensors-map-link
                                                         (restas:genurl 'get-sensors-map
                                                                        :id (db:id row)))))))
         (template (with-back-to-root
                       (with-path-prefix
                           :description-lb    (_ "Description")
                           :map-file-png-lb   (_ "Map File (PNG format only)")
                           :link-lb           (_ "Link")
                           :operations-lb     (_ "Operations")
                           :substitute-map-lb (_ "Substitute map file")
                           :data           +name-map-data+
                           :desc           +name-map-description+
                           :file           +name-map-data+
                           :data-table     all-maps))))
    (with-standard-html-frame (stream
                               "Manage Map"
                               :errors errors
                               :infos  infos)
      (html-template:fill-and-print-template #p"add-map.tpl"
                                             template
                                             :stream stream))))

(define-lab-route delete-plant-map ("/delete-map/:id" :method :get)
  (with-authentication
    (with-admin-credentials
        (progn
          (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
            (del (single 'db:plant-map :id id)))
          (restas:redirect 'plant-map))
      (manage-map nil (list *insufficient-privileges-message*)))))

(define-lab-route get-plant-map ("/get-map/:id")
  (with-authentication
    (if (integer-validate id)
        (let ((raw (single 'db:plant-map :id id)))
          (if raw
              (progn
                (setf (header-out :content-type) "image/png")
                (base64-decode (db:data raw)))
              +http-not-found+))
        +http-not-found+)))

(define-lab-route plant-map ("/map/")
  (with-authentication
    (manage-map nil nil)))

(define-lab-route add-map ("/add-map/" :method :post)
  (with-authentication
      (with-editor-or-above-credentials
          (progn
            (let ((description (tbnl:post-parameter +name-map-description+))
                  (filename    (get-post-filename +name-map-data+)))
              (add-new-map filename description)))
        (manage-map nil (list *insufficient-privileges-message*)))))

(define-lab-route subst-map-file ("/subst-map-file/:id" :method :post)
  (with-authentication
    (with-editor-or-above-credentials
        (progn
          (let ((has-not-errors  (and (not (regexp-validate (list (list id +pos-integer-re+ ""))))
                                      (get-post-filename +name-map-data+)
                                      (png-validate-p (get-post-filename +name-map-data+))))
                (success-msg     (list (_ "Map uploaded")))
                (error-general   (list (_ "Map not uploaded")))
                (error-not-found (list (format nil
                                               (_ "Map file not uploaded, map (id: ~a) not found")
                                               id))))
            (if has-not-errors
                (let ((map-file (get-post-filename +name-map-data+))
                      (updated-map (single 'db:plant-map :id id)))
                  (if updated-map
                      (progn
                        (setf (db:data updated-map)
                              (base64-encode (read-file-into-byte-vector map-file)))
                        (save updated-map)
                        (manage-map success-msg nil))
                      (manage-map nil error-not-found)))
                (manage-map nil error-general))))
      (manage-map nil (list *insufficient-privileges-message*)))))

(define-lab-route get-sensors-map ("/get-sensors-map/:id")
  (with-authentication
    (if (and (integer-validate id)
             (single 'db:plant-map :id id))
        (with-standard-html-frame (stream
                               "Monitor Sensors"
                               :errors nil
                               :infos  nil)
          (html-template:fill-and-print-template #p"monitor-sensors.tpl"
                                                 (with-back-uri (plant-map)
                                                   (with-path-prefix
                                                       :map-id id
                                                       :sensors-data-url
                                                       (restas:genurl 'ws-sensors-associated-w-map
                                                                      :id id)))
                                                 :stream stream)))))
