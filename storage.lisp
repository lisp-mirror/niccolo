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

(define-constant +name-storage-proper-name+   "name"                       :test #'string=)

(define-constant +name-storage-id+            "id"                         :test #'string=)

(define-constant +name-storage-floor+         "floor"                      :test #'string=)

(define-constant +name-storage-building-name+ "buiding-name"               :test #'string=)

(define-constant +name-storage-building-id+   "building-id"                :test #'string=)

(define-constant +name-map-image-id+          "name-map-image-id"          :test #'string=)

(define-constant +map-image-id+               "name-map-id"                :test #'string=)

(define-constant +map-image-name-building-id+ "map-image-name-building-id" :test #'string=)

(define-constant +map-image-coord-name+       "coord"                      :test #'string=)

(defun gen-uri-search-query (&key
                               (id-product "")
                               (building   "")
                               (storage    ""))
  (with-output-to-string (stream)
    (let ((alist (list (cons +search-chem-id+       id-product)
                       (cons +search-chem-owner+    "")
                       (cons +search-chem-name+     "")
                       (cons +search-chem-building+ building)
                       (cons +search-chem-floor+    "")
                       (cons +search-chem-storage+  storage)
                       (cons +search-chem-shelf+    ""))))
      (let ((uri (local-uri (restas:genurl 'restas.lab:search-chem-prod)
                            :query (utils:alist->query-uri alist))))
        (princ uri stream)))))

(defun gen-qr-code-search-query (building storage)
  (gen-uri-search-query :building building :storage storage))

(defun gen-id-product-search-query (id)
  (gen-uri-search-query :id-product id))

(defun gen-map-storage-link (id sc tc)
  (restas:genurl 'display-map
                 :id id
                 :sc (/ sc +relative-coord-scaling+)
                 :tc (- 1.0 (/ tc  +relative-coord-scaling+))))

(defun fetch-all-storages (&optional (delete-link nil) (update-link))
  (let ((raw (db-query (select ((:as :b.id :bid)
                                (:as :b.name :bname)
                                (:as :s.id :sid)
                                (:as :s.name :sname)
                                (:as :s.floor-number :floor)
                                (:as :s.map-id :map-link-id)
                                (:as :s.s-coord :s-coord)
                                (:as :s.t-coord :t-coord))
                         (from (:as :storage :s))
                         (left-join (:as :building :b) :on (:= :b.id :s.building-id))
                         (order-by (:asc :s.name))))))
     (loop for row in raw collect
          (let* ((sid           (getf row :|sid|))
                 (bid           (getf row :|bid|))
                 (name          (getf row :|sname|))
                 (building-name (getf row :|bname|))
                 (building-link (restas:genurl 'ws-building :id bid))
                 (storage-link  (gen-map-storage-link (getf row :|map-link-id|)
                                                      (getf row :|s-coord|)
                                                      (getf row :|t-coord|)))
                 (location-add-link (restas:genurl 'list-all-storage-maps :storage-id sid))
                 (floor         (getf row :|floor|)))
            (append
             (list :storage-id sid :name name :building-link building-link
                   :building-name     building-name
                   :storage-link      storage-link
                   :location-add-link location-add-link
                   :has-storage-link  (db-non-nil-p (getf row :|map-link-id|))
                   :qr-string         (gen-qr-code-search-query building-name name)
                   :floor             floor)
             (if delete-link
                 (list :delete-link (restas:genurl delete-link :id sid)))
             (if update-link
                 (list :update-storage-link (restas:genurl update-link :id sid))))))))

(gen-autocomplete-functions db:building db:build-description)

(defun manage-storage (infos errors &key (start-from 0) (data-count 1))
  (let* ((all-storages       (fetch-all-storages 'delete-storage 'update-storage-route))
         (paginated-storages (slice-for-pagination all-storages
                                                   (actual-pagination-start start-from)
                                                   (actual-pagination-count data-count))))
    (multiple-value-bind (next-start prev-start)
        (pagination-bounds (actual-pagination-start start-from)
                           (actual-pagination-count data-count)
                           'db:storage)
      (with-standard-html-frame (stream
                                 "Manage Storage Places"
                                 :errors errors
                                 :infos  infos)
        (let ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
              (json-building    (array-autocomplete-building))
              (json-building-id (array-autocomplete-building-id)))
          (html-template:fill-and-print-template #p"add-storage.tpl"
                                                 (with-back-to-root
                                                     (with-pagination-template
                                                         (next-start
                                                          prev-start
                                                          (restas:genurl 'storage))
                                                       (with-path-prefix
                                                         :name-lb       (_ "Name")
                                                         :building-lb   (_ "Building")
                                                         :floor-lb      (_ "Floor")
                                                         :map-lb        (_ "Map")
                                                         :operations-lb (_ "Operations")
                                                         :name        +name-storage-proper-name+
                                                         :building-id +name-storage-building-id+
                                                         :floor       +name-storage-floor+
                                                         :json-buildings    json-building
                                                         :json-buildings-id json-building-id
                                                         :data-table        paginated-storages)))
                                                 :stream stream))))))

(defun add-new-storage (name building-id floor &key (start-from 0) (data-count 1))
  (let* ((errors-msg-1 (concatenate 'list
                                    (regexp-validate (list
                                                      (list name
                                                            +free-text-re+
                                                            (_ "Name invalid"))
                                                      (list building-id
                                                            +pos-integer-re+
                                                            (_ "Building invalid"))
                                                      (list floor
                                                            +free-text-re+
                                                            (_ "Floor invalid"))))))
         (errors-msg-building-not-found (when (and (not errors-msg-1)
                                                   (not (db-single 'db:building :id building-id)))
                                          (list (_ "Building not in the database"))))
         (errors-msg-already-in-db (when (and (not errors-msg-1)
                                              (not errors-msg-building-not-found))
                                     (unique-p-validate* 'db:storage
                                                         (:name :building-id :floor-number)
                                                         (name building-id floor)
                                                         (_ "Storage already in the database"))))
         (errors-msg (concatenate 'list
                                  errors-msg-1
                                  errors-msg-building-not-found
                                  errors-msg-already-in-db))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "Saved storage: ~s") name)))))
    (when (not errors-msg)
      (let ((storage (db-create'db:storage
                             :name name
                             :building-id  building-id
                             :floor-number floor
                             :s-coord 0
                             :t-coord 0)))
        (db-save storage)))
    (manage-storage success-msg
                    errors-msg
                    :start-from start-from
                    :data-count data-count)))

(define-lab-route storage ("/storage/" :method :get)
  (with-authentication
    (with-pagination (pagination-uri utils:*alias-pagination*)
      (manage-storage nil nil
                      :start-from (session-pagination-start pagination-uri utils:*alias-pagination*)
                      :data-count (session-pagination-count pagination-uri
                                                            utils:*alias-pagination*)))))

(define-lab-route add-storage ("/add-storage/" :method :get)
  (with-authentication
    (with-editor-or-above-credentials
        (with-pagination (pagination-uri utils:*alias-pagination*)
          (add-new-storage (get-clean-parameter +name-storage-proper-name+)
                           (get-clean-parameter +name-storage-building-id+)
                           (get-clean-parameter +name-storage-floor+)
                           :start-from (session-pagination-start pagination-uri
                                                                 utils:*alias-pagination*)
                           :data-count (session-pagination-count pagination-uri
                                                                 utils:*alias-pagination*)))
      (manage-storage nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-storage ("/delete-storage/:id" :method :get)
  (with-authentication
    (with-editor-or-above-credentials
        (progn
          (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
            (let ((to-trash (db-single 'db:storage :id id)))
              (when to-trash
                (db-del (db-single 'db:storage :id id)))))
          (restas:redirect 'storage))
      (manage-storage nil (list *insufficient-privileges-message*)))))

(define-lab-route assoc-storage-map ("/assoc-storage-map/:mid/:sid" :method :get)
  (with-authentication
    (with-editor-or-above-credentials
        (progn
          (let* ((x (get-clean-parameter (format nil "~a.x" +map-image-coord-name+)))
                 (y (get-clean-parameter (format nil "~a.y" +map-image-coord-name+)))
                 (errors-msg-1 (concatenate 'list
                                            (regexp-validate (list
                                                              (list mid
                                                                    +pos-integer-re+
                                                                    (_ "Map id invalid"))
                                                              (list sid
                                                                    +pos-integer-re+
                                                                    (_ "Storage id ivalid"))))))

                 (errors-msg-storage-not-found (when (and (not errors-msg-1)
                                                          (not (db-single 'db:storage :id sid)))
                                                 (list (_ "Storage not in the database"))))
                 (errors-msg-map-not-found (when (and (not errors-msg-1)
                                                      (not (db-single 'db:plant-map :id mid)))
                                             (list (_ "Map not in the database"))))
                 (error-no-coords          (regexp-validate (list (list x
                                                                        +pos-integer-re+
                                                                        (_ "x coordinate not valid"))
                                                                  (list y
                                                                        +pos-integer-re+
                                                                        (_ "y coordinate not valid")))))
                 (errors-msg (concatenate 'list
                                          errors-msg-1
                                          errors-msg-storage-not-found
                                          errors-msg-map-not-found
                                          error-no-coords))
                 (success-msg (and (not errors-msg)
                                   (list (format nil (_ "Saved maps coordinates"))))))
            (if success-msg
                (progn
                  (with-dump-map (tmp-image-file mid)
                    (cl-gd:with-image-from-file (bg tmp-image-file :png)
                      (multiple-value-bind (w h)
                          (cl-gd:image-size bg)
                        (let ((sc (round (* +relative-coord-scaling+ (/ (parse-integer x) w))))
                              (tc (round (* +relative-coord-scaling+ (/ (parse-integer y) h))))
                              (updated-storage  (db-single 'db:storage :id sid))) ;; always not null here
                          (setf (db:s-coord updated-storage) sc
                                (db:t-coord updated-storage) tc
                                (db:map-id  updated-storage)  mid)
                          (db-save updated-storage)))))
                  (restas:redirect 'storage))
                (restas:redirect 'storage))))
      (manage-storage nil (list *insufficient-privileges-message*)))))

(defmacro gen-list-all-maps (id route-symbol &key (back-route nil))
  (with-gensyms (all-maps)
    `(with-authentication
       (with-editor-or-above-credentials
           (progn
             (if (not (regexp-validate (list (list ,id +pos-integer-re+ "no"))))
                 (let ((,all-maps (loop for i in (db-filter 'db:plant-map) collect
                                       (list :map-image-src     (restas:genurl 'get-plant-map
                                                                               :id (db:id i))
                                             :map-image-desc    (db:description i)
                                             :action            (restas:genurl ',route-symbol
                                                                               :mid (db:id i)
                                                                               :sid ,id)
                                             :coord-name        +map-image-coord-name+
                                             :name-map-image-id +name-map-image-id+
                                             :map-image-id      (db:id i)
                                             :map-image-name-building-id
                                             +map-image-name-building-id+
                                             :map-image-building-id      ,id))))
                   (with-standard-html-frame (stream
                                              "Add Map"
                                              :errors nil
                                              :infos  nil)
                     (html-template:fill-and-print-template #p"list-all-maps.tpl"
                                                            ,(if back-route
                                                                 `(with-back-uri (,back-route)
                                                                    (list :all-images ,all-maps))
                                                                 `(list :all-images ,all-maps))
                                                            :stream stream)))
                 +http-not-found+))
         (manage-storage nil (list *insufficient-privileges-message*))))))

(define-lab-route list-all-storage-maps ("/storage-list-all-maps/:storage-id" :method :get)
  (gen-list-all-maps storage-id assoc-storage-map :back-route storage))
