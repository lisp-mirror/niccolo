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
      (puri:render-uri (make-instance 'puri:uri
				    :scheme :https
				    :host +hostname+
				    :port (if (> +https-proxy-port+ 0)
					      +https-proxy-port+
					      +https-port+)
				    :path (restas:genurl'restas.lab:search-chem-prod)
				    :query (utils:alist->query-uri alist))
		       stream))))


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
  (let ((raw (query
	      (select ((:as :b.id :bid)
		       (:as :b.name :bname)
		       (:as :s.id :sid)
		       (:as :s.name :sname)
		       (:as :s.floor-number :floor)
		       (:as :s.map-id :map-link-id)
		       (:as :s.s-coord :s-coord)
		       (:as :s.t-coord :t-coord))
		(from (:as :storage :s))
		(left-join (:as :building :b) :on (:= :b.id :s.building-id))))))
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
		  :building-name building-name
		  :storage-link storage-link
		  :location-add-link location-add-link
		  :has-storage-link (getf row :|map-link-id|)
		  :qr-string  (gen-qr-code-search-query building-name name)
		  :floor floor)
	    (if delete-link
		(list :delete-link (restas:genurl delete-link :id sid)))
	    (if update-link
		(list :update-storage-link (restas:genurl update-link :id sid))))))))

(gen-autocomplete-functions db:building db:build-description)

(defun manage-storage (infos errors)
  (let ((all-storages (fetch-all-storages 'delete-storage 'update-storage-route)))
    (with-standard-html-frame (stream
			       "Manage Storage Places"
			       :errors errors
			       :infos  infos)
      (let ((html-template:*string-modifier* #'html-template:escape-string-minimal)
	    (json-building    (array-autocomplete-building))
	    (json-building-id (array-autocomplete-building-id)))
	(html-template:fill-and-print-template #p"add-storage.tpl"
					       (with-back-to-root
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
						       :data-table all-storages))
					       :stream stream)))))

(defun add-new-storage (name building-id floor)
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
						   (not (single 'db:building :id building-id)))
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
      (let ((storage (create 'db:storage
			     :name name
			     :building-id  building-id
			     :floor-number floor
			     :s-coord 0
			     :t-coord 0)))
	(save storage)))
    (manage-storage success-msg errors-msg)))

(define-lab-route storage ("/storage/" :method :get)
  (with-authentication
    (manage-storage nil nil)))

(define-lab-route add-storage ("/add-storage/" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
	(progn
	  (add-new-storage (get-parameter +name-storage-proper-name+)
			   (get-parameter +name-storage-building-id+)
			   (get-parameter +name-storage-floor+)))
      (manage-storage nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-storage ("/delete-storage/:id" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
	(progn
	  (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
	    (let ((to-trash (single 'db:storage :id id)))
	      (when to-trash
		(del (single 'db:storage :id id)))))
	  (restas:redirect 'storage))
      (manage-storage nil (list *insufficient-privileges-message*)))))

(define-lab-route assoc-storage-map ("/assoc-storage-map/:mid/:sid" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
	(progn
	  (let* ((x (get-parameter (format nil "~a.x" +map-image-coord-name+)))
		 (y (get-parameter (format nil "~a.y" +map-image-coord-name+)))
		 (errors-msg-1 (concatenate 'list
					    (regexp-validate (list
							      (list mid
								    +pos-integer-re+
								    (_ "Map id invalid"))
							      (list sid
								    +pos-integer-re+
								    (_ "Storage id ivalid"))))))

		 (errors-msg-storage-not-found (when (and (not errors-msg-1)
							  (not (single 'db:storage :id sid)))
						 (list (_ "Storage not in the database"))))
		 (errors-msg-map-not-found (when (and (not errors-msg-1)
						      (not (single 'db:plant-map :id mid)))
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
			      (updated-storage  (single 'db:storage :id sid))) ;; always not null here
			  (setf (db:s-coord updated-storage) sc
				(db:t-coord updated-storage) tc
				(db:map-id  updated-storage)  mid)
			  (save updated-storage)))))
		  (restas:redirect 'storage))
		(restas:redirect 'storage))))
      (manage-storage nil (list *insufficient-privileges-message*)))))

(defmacro gen-list-all-maps (id route-symbol &key (back-route nil))
  (with-gensyms (all-maps)
    `(with-authentication
       (with-editor-or-above-privileges
	   (progn
	     (if (not (regexp-validate (list (list ,id +pos-integer-re+ "no"))))
		 (let ((,all-maps (loop for i in (filter 'db:plant-map) collect
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
