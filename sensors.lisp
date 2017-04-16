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

(define-constant +mac-header+                :mac          :test #'eq)

(define-constant +nonce-header+              :nonce        :test #'eq)

(define-constant +sensor-http-timeout+       5             :test #'=)

(define-constant +sensor-read-delay+         60            :test #'=)

(define-constant +sensor-error-status+       :error        :test #'eq)

(define-constant +sensor-ok-status+          :ok           :test #'eq)

(define-constant +name-sensor-description+   "description" :test #'string=)

(define-constant +name-sensor-address+       "address"     :test #'string=)

(define-constant +name-sensor-id+            "id"          :test #'string=)

(define-constant +name-sensor-path+          "path"        :test #'string=)

(define-constant +name-sensor-secret-name+   "secret"      :test #'string=)

(define-constant +name-sensor-script+        "script"      :test #'string=)

(defun sensor-nonce ()
  (format nil "~{~:@(~x~)~}" (map 'list #'char-code (random-password 8))))

(defun build-mac (clear secret nonce)
  (sha-encode->string (concatenate 'string nonce clear secret)))

(defun build-script-path (script)
  (uiop:merge-pathnames* *sensors-script-dir* script))

(defgeneric build-log-path (sensor))

(defmethod build-log-path ((sensor db:sensor))
  (build-log-path (db:id sensor)))

(defmethod build-log-path ((sensor number))
  (uiop:merge-pathnames* *sensor-log-dir* (format nil "~a.log" sensor)))

(defun dump-sensor-log-line (sensor)
  (let ((log-file (build-log-path sensor)))
    (with-open-file (stream log-file
			    :direction         :output
			    :if-exists         :append
			    :if-does-not-exist :create)
      (format stream "~a ~a~%" (db:last-access-time sensor) (db:last-value sensor)))))

(defun process-sensor-output (description results)
  (declare (ignore description))
  results)

(defun %ask-sensors (description address path secret nonce script)
  (multiple-value-bind (res status-code headers)
      (handler-case
	  (trivial-timeout:with-timeout (+sensor-http-timeout+)
	    (drakma:http-request (concatenate 'string "http://" address path)
				 :method :get
				 :additional-headers (list (cons +mac-header+
								 (build-mac path secret nonce))
							   (cons +nonce-header+
								 nonce))))
	(error () nil))
    (if (and res
	     (= status-code +http-ok+))
	(let ((mac-sensor   (cdr (assoc +mac-header+ headers)))
	      (mac-expected (build-mac res secret nonce)))
	  (if (string-equal mac-sensor mac-expected)
	      (progn
		(when (uiop:probe-file* script)
		  (load script))
		(values (process-sensor-output description res) t))
	      (let ((msg (format nil
				 (_ "Sensor ~a (~a) failed MAC authentication, an attack?")
				 description
				 address)))
		(log-and-mail (db:email (admin-user))
			      (_ "Security alert")
			      msg)
		(values nil nil))))
	(let ((msg (format nil
			   "Sensor ~a (~a) returned error code ~a"
			   description
			   address
			   status-code)))
	  (log-and-mail (db:email (admin-user))
			(_ "Sensors comunication failure")
			msg)
	  (values nil nil)))))

(defmacro defun-w-lock (name parameters &body body)
  `(defun ,name ,parameters
     (bt:with-recursive-lock-held (lock)
       ,@body)))

(let ((lock  (bt:make-recursive-lock)))

  (defgeneric ask-sensors (object))

  (defmethod ask-sensors ((object db:sensor))
    (bt:with-recursive-lock-held (lock)
      (let ((now (local-time-obj-now)))
	(setf (db:session-nonce object) (sensor-nonce))
	(save object)
	(multiple-value-bind (res successp)
	    (%ask-sensors (db:description   object)
	                  (db:address       object)
			  (db:path          object)
			  (db:secret        object)
			  (db:session-nonce object)
			  (build-script-path (db:script-file object)))
	  (setf (db:last-access-time object) now)
	  (if successp
	      (progn
		(setf (db:status object) +sensor-ok-status+)
		(setf (db:last-value object) res)
		(dump-sensor-log-line object))
	      (setf (db:status object) +sensor-error-status+))
	  (save object)))))

  ;; web routines

  (defun-w-lock fetch-all-sensors (&optional (delete-link nil) (update-link))
    (let ((raw (query
		(select ((:as :s.id                :sid)
			 (:as :s.description       :description)
			 (:as :s.address           :address)
			 (:as :s.path              :path)
			 ;(:as :s.secret            :secret)
			 (:as :s.script-file       :script)
			 (:as :s.status            :status)
			 (:as :s.last-access-time  :access-time)
			 (:as :s.last-value        :last-value)
			 (:as :s.map-id            :map-link-id)
			 (:as :s.s-coord           :s-coord)
			 (:as :s.t-coord           :t-coord))
		  (from (:as :sensor :s))))))
      (loop for row in raw collect
	   (let* ((sid           (getf row :|sid|))
		  (description   (getf row :|description|))
		  (address       (getf row :|address|))
		  (secret        (getf row :|secret|))
		  (script        (getf row :|script|))
		  (access-time   (decode-datetime-string (getf row :|access-time|)))
		  (value         (getf row :|last-value|))
		  (status        (getf row :|status|))
		  (path          (getf row :|path|))
		  (sensor-link   (gen-map-storage-link (getf row :|map-link-id|)
						       (getf row :|s-coord|)
						       (getf row :|t-coord|)))
		  (s-coord       (getf row :|s-coord|))
		  (t-coord       (getf row :|t-coord|))
		  (location-add-link (restas:genurl 'list-all-sensors-maps :sensor-id sid)))
	     (append
	      (list :sensor-id         sid
		    :description       description
		    :address           address
		    :secret            secret
		    :script            script
		    :last-access-time  access-time
		    :last-value        value
		    :status            status
		    :path              path
		    :sensor-link       sensor-link
		    :location-add-link location-add-link
		    :graph-sensor-link (restas:genurl 'display-sensor-log-graph :id sid)
		    :map-id            (getf row :|map-link-id|)
		    :s-coord           (float (/ s-coord +relative-coord-scaling+))
		    :t-coord           (float (/ t-coord +relative-coord-scaling+))
		    :has-sensor-log    (if (uiop:file-exists-p (build-log-path sid))
					   t
					   nil)
		    :has-sensor-link   (getf row :|map-link-id|))
	      (if delete-link
		  (list :delete-link (restas:genurl delete-link :id sid)))
	      (if update-link
		  (list :update-sensor-link (restas:genurl update-link :id sid))))))))

  (defun no-thread-support ()
    (list (_ "There is no threads system available for the software on your platform therefore sensors monitoring will not works; please consider supporting the development of the compiler SBCL (www.sbcl.org) to improve threads system.")))

  (defun-w-lock manage-sensor (infos errors &key (start-from 0) (data-count 1))
    (let* ((all-sensors     (fetch-all-sensors 'delete-sensor 'update-sensor-route))
	   (paginated-items (slice-for-pagination all-sensors
						  (actual-pagination-start start-from)
						  (actual-pagination-count data-count)))
           (actual-infos    (append #-thread-support (no-thread-support) infos)))

      (multiple-value-bind (next-start prev-start)
	  (pagination-bounds (actual-pagination-start start-from)
			     (actual-pagination-count data-count)
			     'db:sensor)
	(with-standard-html-frame (stream
				   "Manage Sensor Places"
				   :errors errors
				   :infos  actual-infos)
	  (let ((html-template:*string-modifier* #'html-template:escape-string-minimal))
	    (html-template:fill-and-print-template #p"add-sensor.tpl"
						   (with-back-to-root
						       (with-pagination-template
							   (next-start
							    prev-start
							    (restas:genurl 'sensor))
							 (with-path-prefix
							     :map-lb              (_ "Map")
							     :description-lb      (_ "Description")
							     :address-lb          (_ "Address")
							     :path-lb             (_ "Path")
							     :secret-lb           (_ "Secret key")
							     :script-lb           (_ "Script")
							     :status-lb           (_ "Status")
							     :last-access-time-lb (_ "Last access")
							     :last-value-lb       (_ "Last value")
							     :operations-lb       (_ "Operations")
							     :description
							     +name-sensor-description+
							     :address       +name-sensor-address+
							     :path          +name-sensor-path+
							     :secret
							     +name-sensor-secret-name+
							     :script        +name-sensor-script+
							     :data-table    paginated-items)))
						     :stream stream))))))

  (defun-w-lock add-new-sensor (description address path secret script
					    &key (start-from 0) (data-count 1))
    (let* ((errors-msg-1 (concatenate 'list
				      (regexp-validate (list
							(list description
							      +free-text-re+
							      (_ "Description invalid"))
							(list address
							      +internet-address-re+
							      (_ "Address invalid"))
							(list path
							      +free-text-re+
							      (_ "Path invalid"))
							(list secret
							      +free-text-re+
							      (_ "Secret key invalid"))
							(list script
							      +script-file-re+
							      (_ "Script file invalid"))))))
	   (errors-msg-already-in-db (when (not errors-msg-1)
				       (unique-p-validate* 'db:sensor
							   (:address :path)
							   (address  path)
							   (_ "Sensor already in the database"))))
	   (errors-msg (concatenate 'list
				    errors-msg-1
				    errors-msg-already-in-db))
	   (success-msg (and (not errors-msg)
			     (list (format nil (_ "Saved sensor: ~s") description)))))
      (when (not errors-msg)
	(let ((sensor (create 'db:sensor
			      :description description
			      :address     address
			      :path        path
			      :secret      secret
			      :status      +sensor-ok-status+
			      :script-file script
			      :last-access-time (local-time-obj-now)
			      :s-coord 0
			      :t-coord 0)))
	  (save sensor)))
      (manage-sensor success-msg errors-msg
		     :start-from start-from
		     :data-count data-count)))

  (define-lab-route sensor ("/sensor/" :method :get)
    (with-authentication
      (with-pagination (pagination-uri utils:*alias-pagination*)
	(manage-sensor nil nil
		       :start-from (session-pagination-start pagination-uri
							     utils:*alias-pagination*)
                       :data-count (session-pagination-count pagination-uri
							     utils:*alias-pagination*)))))

  (define-lab-route add-sensor ("/add-sensor/" :method :get)
    (with-authentication
      (with-admin-privileges
	  (with-pagination (pagination-uri utils:*alias-pagination*)
	    (add-new-sensor (get-parameter +name-sensor-description+)
			    (get-parameter +name-sensor-address+)
			    (get-parameter +name-sensor-path+)
			    (get-parameter +name-sensor-secret-name+)
			    (get-parameter +name-sensor-script+)
			    :start-from (session-pagination-start pagination-uri
								  utils:*alias-pagination*)
			    :data-count (session-pagination-count pagination-uri
								  utils:*alias-pagination*)))
	(manage-sensor nil (list *insufficient-privileges-message*)))))

  (define-lab-route delete-sensor ("/delete-sensor/:id" :method :get)
    (with-authentication
      (with-admin-privileges
	  (with-pagination (pagination-uri utils:*alias-pagination*)
	    (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
	      (let ((to-trash (single 'db:sensor :id id)))
		(when to-trash
		  (del (single 'db:sensor :id id)))))
	    (restas:redirect 'sensor))
	(manage-sensor nil (list *insufficient-privileges-message*)))))

  (define-lab-route assoc-sensor-map ("/assoc-sensor-map/:mid/:sid" :method :get)
    (with-authentication
      (with-admin-privileges
	  (bt:with-recursive-lock-held (lock)
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
									(_ "Sensor id ivalid"))))))

		     (errors-msg-sensor-not-found (when (and (not errors-msg-1)
							     (not (single 'db:sensor :id sid)))
						    (list (_ "Sensor not in the database"))))
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
					      errors-msg-sensor-not-found
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
				  (updated-sensor  (single 'db:sensor :id sid))) ;; always not null here
			      (setf (db:s-coord updated-sensor) sc
				    (db:t-coord updated-sensor) tc
				    (db:map-id  updated-sensor)  mid)
			      (save updated-sensor)))))
		      (restas:redirect 'sensor))
		    (restas:redirect 'sensor)))))
	(manage-sensor nil (list *insufficient-privileges-message*)))))

  ;; updating

  (defun-w-lock update-sensor (id description address path secret script)
    (let* ((errors-msg-1 (concatenate 'list
				      (regexp-validate (list
							(list description
							      +free-text-re+
							      (_ "Description invalid"))
							(list address
							      +internet-address-re+
							      (_ "Address invalid"))
							(list path
							      +free-text-re+
							      (_ "Path invalid"))
							(list secret
							      +free-text-re+
							      (_ "Secret key invalid"))
							(list script
							      +script-file-re+
							      (_ "Script file invalid"))))))
	   (errors-msg-unique (when (all-null-p errors-msg-1)
				(exists-with-different-id-validate 'db:sensor
								   id
								   (:address :path)
								   (address path)
								   (_ "Sensor already in the database with different ID"))))
	   (errors-msg (concatenate 'list
				    errors-msg-1
				    errors-msg-unique))
	   (success-msg (and (not errors-msg)
			     (list (format nil (_ "Updated sensor: ~s") description)))))
      (if (not errors-msg)
	  (let ((sensor (single 'db:sensor :id id)))
	    (setf (db:description sensor) description)
	    (setf (db:address     sensor) address)
	    (setf (db:path        sensor) path)
	    (setf (db:secret      sensor)  secret)
	    (setf (db:status      sensor) +sensor-ok-status+)
	    (setf (db:script-file sensor) script)
	    (setf (db:status      sensor) +sensor-ok-status+)
	    (save sensor)
	    (manage-update-sensor (and success-msg id) success-msg errors-msg))
	  (manage-sensor success-msg errors-msg))))

  (defun prepare-for-update-sensor (id)
    (prepare-for-update id
			'db:sensor
			(_ "Sensor does not exists in database.")
			#'manage-update-sensor))

  (defun manage-update-sensor (id infos errors)
    (let* ((html-template:*string-modifier* #'identity)
	   (new-sensor (and id
			    (object-exists-in-db-p 'db:sensor id)))
	   (template   (with-back-uri (sensor)
			 (with-path-prefix
			     :description-lb    (_ "Description")
			     :address-lb        (_ "Address")
			     :path-lb           (_ "Path")
			     :secret-lb         (_ "Secret key")
			     :script-lb         (_ "Script")
			     :id                (and id
						     (db:id new-sensor))
			     :description-value (and id
						     (db:description new-sensor))
			     :address-value     (and id
						     (db:address new-sensor))
			     :path-value        (and id
						     (db:path new-sensor))
			     :secret-value     (and id
						    (db:secret new-sensor))
			     :script-value     (and id
						    (db:script-file new-sensor))
			     :description      +name-sensor-description+
			     :address          +name-sensor-address+
			     :path             +name-sensor-path+
			     :secret           +name-sensor-secret-name+
			     :script           +name-sensor-script+))))
      (with-standard-html-frame (stream (_ "Update Sensor")
					:infos infos :errors errors)
	(html-template:fill-and-print-template #p"update-sensor.tpl"
					       template
					       :stream stream))))

  (define-lab-route update-sensor-route ("/update-sensor/:id" :method :get)
    (with-authentication
      (with-admin-privileges
	  (progn
	    (let ((new-description (get-parameter +name-sensor-description+))
		  (new-address     (get-parameter +name-sensor-address+))
		  (new-path        (get-parameter +name-sensor-path+))
		  (new-secret      (get-parameter +name-sensor-secret-name+))
		  (new-script      (get-parameter +name-sensor-script+)))
	      (if (and new-description
		       new-address
		       new-path
		       new-secret
		       new-script)
		  (update-sensor id new-description new-address new-path new-secret new-script)
		  (prepare-for-update-sensor id))))
	(manage-update-sensor nil nil (list *insufficient-privileges-message*)))))

  (define-lab-route list-all-sensors-maps ("/sensors-list-all-maps/:sensor-id" :method :get)
    (gen-list-all-maps sensor-id assoc-sensor-map :back-route sensor))

  (define-lab-route ws-sensors-associated-w-map ("/ws/sensors/maps/:id" :method :get)
    (with-authentication
      (let* ((error-msg-no-int (regexp-validate (list (list id +pos-integer-re+
							    (_ "Map id invalid")))))
	     (error-msg-map-not-found (when (and (not error-msg-no-int)
						 (not (single 'db:plant-map
							      :id (parse-integer id))))
					(list (_ "Map not in the database"))))
	     (all-errors (append error-msg-no-int error-msg-map-not-found)))
	(if (not all-errors)
	    (let ((raw (remove-if #'(lambda (a)
				      (or (null (getf a :map-id))
					  (/=   (getf a :map-id)
						(parse-integer id))))
				  (fetch-all-sensors))))
	      (with-output-to-string (stream)
		(cl-json:with-array (stream)
		  (loop for i in raw do
		       (let ((alist (plist-alist i)))
			 (cl-json:as-array-member (stream)
			   (cl-json:encode-json alist stream)))))))
	    +http-not-found+))))

  (defun sensor-update-loop ()
    (do ()
	(nil ())
      (let ((all-sensors (filter 'db:sensor)))
	(loop for sensor in all-sensors do
	     (ask-sensors sensor))
	(sleep +sensor-read-delay+))))

  (defun init-sensors-thread ()
    (bt:make-thread #'sensor-update-loop)))
