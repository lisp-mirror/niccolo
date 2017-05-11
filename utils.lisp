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

(in-package :utils)

(define-constant +uri-query-start+ "?" :test #'string=)

(defmacro define-lab-route (name params &body body)
  `(restas:define-route ,name ,(append (list (concatenate 'string
							  +path-prefix+
							  (if (symbolp (first params))
							      (symbol-value (first params))
							      (first params))))
				       (rest params))
     (when (and (not (validation:cookie-key-script-visited-validate
		      (tbnl:cookie-in +cookie-key-script-visited+)))
		(string-not-equal (concatenate 'string +path-prefix+ "/")
				  (tbnl:script-name*)))
       (set-cookie-script-visited (tbnl:request-uri*)))
     ,@body))

;; credentials

(defun cat-salt-password (salt password)
  (concatenate 'string salt password))

(defun generate-salt ()
  (let ((vec (make-array +salt-byte-length+ :element-type '(unsigned-byte 8))))
    (loop for i from 0 below (length vec) do
	 (setf (elt vec i) (random 256)))
    (string-utils:base64-encode vec)))

(defun encode-pass (salt pass)
  (string-utils:sha-encode->string (cat-salt-password salt pass)))

;; web/json

(defun obj->json-string (object)
  (with-output-to-string (stream)
    (cl-json:encode-json object stream)))

(defun json-string->obj (serialized)
   (handler-case
       (cl-json:with-decoder-simple-clos-semantics
	 (cl-json:decode-json-from-string serialized))
     (json:json-syntax-error () nil)
     (end-of-file            () nil)))

(defun plist->json (obj)
  (cl-json:encode-json-plist-to-string obj))

(defun json->list (serialized)
  (handler-case
      (cl-json:decode-json-from-string serialized)
    (json:json-syntax-error () nil)
    (end-of-file            () nil)))

(defun chemical-products-template->json-string (products &key (other-pairs nil))
  (with-output-to-string (stream)
    (cl-json:with-array (stream)
      (loop for i in products do
	   (when other-pairs
	     (setf (getf i (car other-pairs)) (cdr other-pairs)))
	   (cl-json:as-array-member (stream)
	       (cl-json:encode-json-plist i stream))))))

(defmacro gen-autocomplete-functions (class data-fn)
  (let* ((class-string (string-upcase (symbol-name class)))
	 (fn-name-common   (if (find ":" class-string)
			       (subseq class-string (1+ (position ":" class-string)))
			       class-string))
	 (fn-name      (format-symbol t "~:@(array-autocomplete-~a~)" fn-name-common))
	 (fn-name-id   (format-symbol t "~:@(array-autocomplete-~a-id~)" fn-name-common)))
    `(progn
       (defun ,fn-name ()
	 ,(with-gensyms (all)
             `(let ((,all (sort (filter (quote ,class))  #'< :key #'db:id)))
		(obj->json-string
		 (loop for i in ,all collect
		      (,data-fn i))))))
       (defun ,fn-name-id ()
	 ,(with-gensyms (all)
	    `(let ((,all (sort (filter (quote ,class)) #'< :key #'db:id)))
	       (obj->json-string
		(loop for i in ,all collect
		     (db:id i)))))))))

;; web/tbnl

(defun get-post-filename (name)
  (and (> (length (tbnl:post-parameter name)) 2)
       (elt (tbnl:post-parameter name) 0)))

(defun source-origin-header ()
  "Fallback to referrer if origin is not present"
  (let ((origin-list   (cl-ppcre:split "\\p{Z}+" (tbnl:header-in* :origin)))
	(referrer-list (tbnl:referer)))
    (if (not (null origin-list))
	(setf origin-list (mapcar #'puri:parse-uri origin-list))
	(setf origin-list (list (puri:parse-uri referrer-list))))
    origin-list))

(defun target-origin-header ()
  (let ((proxy-origin (tbnl:header-in* :x-forwarded-host))
	(host         (tbnl:host)))
    (if proxy-origin
	proxy-origin
	host)))

(defun check-origin-target ()
  (let* ((origin       (first (source-origin-header)))
         (origin-host  (puri:uri-host origin))
         (origin-port  (format nil "~a" (puri:uri-port origin)))
         (target       (cl-ppcre:split ":" (target-origin-header)))
         (target-host  (first target))
         (target-port  (second target)))
    (and origin
         (string= origin-host target-host)
         (string= origin-port target-port))))

;; web uri

(defun path-prefix-tpl ()
  (list :path-prefix +path-prefix+))

(defun back-button-tpl (route)
  (list :back-button     (restas:genurl route)
	:back-button-lbl (_ "Back")))

(defmacro with-back-uri ((route) tpl)
  `(nconc
    (back-button-tpl ',route)
    ,tpl))

(defmacro with-back-to-root (tpl)
  `(with-back-uri (restas.lab::root)
     ,tpl))

(defmacro with-path-prefix (&rest tpls)
  `(nconc
    (path-prefix-tpl)
    (list ,@tpls)))

(defmacro with-pagination-template ((next-start
				     prev-start
				     pagination-next-page-url)
				    tpl)
  `(nconc (list :pagination-op-name       +name-op-pagination+
		:pagination-count-name    +name-count-pagination+
		:pagination-inc           +name-op-pagination-inc+
		:pagination-dec           +name-op-pagination-dec+
		:pagination-more-items    +name-count-pagination-inc+
		:pagination-less-items    +name-count-pagination-dec+
		:pagination-next-page-url ,pagination-next-page-url
		:next-start               ,next-start
		:prev-start               ,prev-start)
	 ,tpl))

(defun alist->query-uri (alist &key (prepend-character ""))
  (concatenate 'string
	       prepend-character
	       (reduce #'(lambda (o n) (concatenate 'string o
						    (and o "&")
						    (format nil "~a=~a" (car n) (cdr n))))
		       alist
		       :initial-value nil)))

(defun local-uri (path &key (query nil))
  (with-output-to-string (stream)
    (if query
	(puri:render-uri (make-instance 'puri:uri
					:scheme :https
					:host   +hostname+
					:port   (if (> +https-proxy-port+ 0)
						    +https-proxy-port+
						    +https-port+)
					:path   path
					:query  query)
			 stream)
	(puri:render-uri (make-instance 'puri:uri
					:scheme :https
					:host   +hostname+
					:port   (if (> +https-proxy-port+ 0)
						    +https-proxy-port+
						    +https-port+)
					:path   path)
			 stream))))


(defun local-uri-noport (path &key (query nil))
  (with-output-to-string (stream)
    (if query
	(puri:render-uri (make-instance 'puri:uri
				    :scheme :https
				    :host   +hostname+
				    :path   path
				    :query  query)
			 stream)
	(puri:render-uri (make-instance 'puri:uri
					:scheme :https
					:host   +hostname+
					:path   path)
			 stream))))

(defun remote-uri (host port path)
  (with-output-to-string (stream)
    (puri:render-uri (make-instance 'puri:uri
				    :scheme :https
				    :host   host
				    :port   port
				    :path   path)
		     stream)))

(defun delete-uri (link-symbol row)
  (restas:genurl link-symbol :id (getf row :id)))

;; web, "lab" specific

(defun prepare-for-update (id class error-msg-not-exists success-fn)
  (let* ((errors-msg-id (validation:regexp-validate (list (list id
								validation:+pos-integer-re+
								(_ "Id invalid")))))
	 (errors-msg-1  (when (and (not errors-msg-id)
				   (not (db-utils:object-exists-in-db-p class id)))
			  error-msg-not-exists))
	 (errors-msg (concatenate 'list errors-msg-id errors-msg-1))
	 (success-msg (and (not errors-msg) (_ "Ok"))))
    (if (not errors-msg)
	(funcall success-fn (and success-msg id) nil errors-msg)
	(progn
	  (to-log +security-warning-log-level+
		  "Someone tried to modify a ~s with id ~s but such object does not exists in database!"
		  class id)
	  +http-not-found+))))


(defun set-cookie-script-visited (value)
  (tbnl:set-cookie +cookie-key-script-visited+ :value value
		   :secure    t
		   :path      "/"
		   :http-only t
		   :max-age   60
		   :domain    +hostname+))

;; web rendering


;; pagination


(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter *alias-pagination* (make-hash-table :test 'equal)))

(defun slice-for-pagination (sequence start count)
  (if sequence
      (subseq sequence
	      (clamp start 0 (length sequence))
	      (clamp (+ start count)
		     0
		     (length sequence)))
      nil))

(defun actual-bounds (start)
  (cond
    ((and (numberp start)
	  (>=      start 0))
     start)
    ((validation:integer-positive-validate start)
     (parse-integer start))
    (t
     0)))

(defun actual-pagination-start (start)
  (actual-bounds start))

(defun actual-pagination-count (start)
  (actual-bounds start))

(defun pagination-bounds (start count table)
  (values (if (< (+ start count)
		 (db-utils:count-all (alexandria:make-keyword table)))
	      (+ start count)
	      nil)
	  (if (>= (- start count) 0)
	      (- start count)
	      nil)))

(defmacro with-pagination-start-hashtable ((user pagination-hashtable)
					   &body body)
  `(with-accessors ((private-storage session-user:private-storage)) ,user
     (let ((,pagination-hashtable (gethash session-user:+user-private-pagination-offset+
					   private-storage)))
       ,@body)))

(defun session-pagination-values (uri-path session-hashtable alias-hashtable)
  (let* ((alias (gethash uri-path alias-hashtable)))
    (multiple-value-bind (results existsp)
	(if alias
	    (gethash alias    session-hashtable)
	    (gethash uri-path session-hashtable))
      (values results existsp alias))))

(defun session-pagination-start (uri-path alias-hashtable)
  (session-user:with-session-user (user)
    (if user
	(with-pagination-start-hashtable (user pagination-start-hashtable)
	  (multiple-value-bind (results existsp)
	      (session-pagination-values uri-path pagination-start-hashtable alias-hashtable)
	    (when (not results)
	      (setf results 0)
	      (setf existsp t))
	    (values results existsp)))
	(values nil nil))))

(defun session-pagination-change (uri-path new-value alias-hashtable)
  (session-user:with-session-user (user)
    (when user
      (with-pagination-start-hashtable (user pagination-start-hashtable)
	(multiple-value-bind (results existsp in-alias)
	    (session-pagination-values uri-path pagination-start-hashtable alias-hashtable)
	  (declare (ignore results existsp))
	  (if in-alias
	      (setf (gethash in-alias pagination-start-hashtable)
		    new-value)
	      (setf (gethash uri-path pagination-start-hashtable)
		    new-value)))))))

(defun session-pagination-increase (uri-path alias-hashtable
				    &optional (delta +start-pagination-offset+))
  (session-user:with-session-user (user)
    (when user
      (let ((old-value (session-pagination-start uri-path alias-hashtable)))
	(session-pagination-change uri-path (+ old-value delta) alias-hashtable)))))

(defun session-pagination-decrease (uri-path alias-hashtable
				    &optional (delta +start-pagination-offset+))
  (session-user:with-session-user (user)
    (when user
      (let ((old-value (session-pagination-start uri-path alias-hashtable)))
	(session-pagination-change uri-path
				   (max 0
					(- old-value delta))
				   alias-hashtable)))))
;;;; pagination count

(defmacro with-pagination-count-hashtable ((user pagination-hashtable) &body body)
  `(with-accessors ((private-storage session-user:private-storage)) ,user
     (let ((,pagination-hashtable (gethash session-user:+user-private-pagination-count+
					   private-storage)))
       ,@body)))

(defun session-pagination-count (uri-path alias-hashtable)
  (session-user:with-session-user (user)
    (if user
	(with-pagination-count-hashtable (user pagination-count-hashtable)
	  (multiple-value-bind (results existsp)
	      (session-pagination-values uri-path pagination-count-hashtable alias-hashtable)
	    (when (not results)
	      (setf results +start-pagination-offset+)
	      (setf existsp t))
	    (values results existsp)))
	(values nil nil))))

(defun session-pagination-count-change (uri-path new-value alias-hashtable)
  (session-user:with-session-user (user)
    (when user
      (with-pagination-count-hashtable (user pagination-count-hashtable)
	(multiple-value-bind (results existsp in-alias)
	    (session-pagination-values uri-path pagination-count-hashtable alias-hashtable)
	  (declare (ignore results existsp))
	  (if in-alias
	      (setf (gethash in-alias pagination-count-hashtable)
		    new-value)
	      (setf (gethash uri-path pagination-count-hashtable)
		    new-value)))))))

(defun session-pagination-count-increase (uri-path alias-hashtable
					  &optional (delta +start-pagination-offset+))
  (session-user:with-session-user (user)
    (when user
      (let ((old-value (session-pagination-count uri-path alias-hashtable)))
	(session-pagination-count-change uri-path (+ old-value delta) alias-hashtable)))))

(defun session-pagination-count-decrease (uri-path alias-hashtable
					  &optional (delta +start-pagination-offset+))
  (session-user:with-session-user (user)
    (when user
      (let ((old-value (session-pagination-count uri-path alias-hashtable)))
	(session-pagination-count-change uri-path
                                         (max +start-pagination-offset+
                                              (- old-value delta))
					 alias-hashtable)))))

(defmacro with-pagination ((uri alias-hashtable) &body body)
  (with-gensyms (page-modification-move page-modification-change-window)
    `(let ((,uri (tbnl:script-name*))
	   (,page-modification-move          (get-parameter +name-op-pagination+))
           (,page-modification-change-window (get-parameter +name-count-pagination+)))
       (when ,page-modification-change-window
         (if (string= ,page-modification-change-window +name-count-pagination-inc+)
	     (session-pagination-count-increase ,uri ,alias-hashtable)
	     (session-pagination-count-decrease ,uri ,alias-hashtable)))
       (when ,page-modification-move
	 (if (string= ,page-modification-move +name-op-pagination-inc+)
	     (session-pagination-increase ,uri
					  ,alias-hashtable
					  (session-pagination-count ,uri ,alias-hashtable))
	     (session-pagination-decrease ,uri
					  ,alias-hashtable
					  (session-pagination-count ,uri ,alias-hashtable))))
       ,@body)))

;; net addresses

;; net dns

(defun address-string->vector (address-string)
  (map 'vector #'parse-integer (cl-ppcre:split "\\." address-string)))

(defgeneric get-host-by-address (address))

#+sbcl (defmethod get-host-by-address ((address vector))
	 (handler-case
	     (sb-bsd-sockets::host-ent-name (sb-bsd-sockets:get-host-by-address address))
	   (error () nil)))

#+sbcl (defmethod get-host-by-address ((address string))
	 (handler-case
	     (get-host-by-address (address-string->vector address))
	   (error () nil)))

#-sbcl (defun get-host-by-address (address)
	 (warn "Sorry, get-host-by-address not implemented for your compiler"))

#+sbcl (defun get-host-by-name (name)
	 (handler-case
	     (sb-bsd-sockets::host-ent-address (sb-bsd-sockets:get-host-by-name name))
	   (error () nil)))

#-sbcl (defun get-host-by-name (name)
	 (warn "Sorry, get-host-by-address not implemented for your compiler"))

;; pictograms

(defun all-pictograms (class)
  (crane:filter class))

(defun pictogram->preview-path (orig-path prefix-path &key (extension +pictogram-web-image-ext+))
  (concatenate 'string
	       +path-prefix+
	       (uiop:unix-namestring prefix-path)
	       (string-utils:find-filename-from-path orig-path :extension extension)))

(defun pictograms-alist (&optional
			   (class  'db:ghs-pictogram)
			   (prefix (concatenate 'string +images-url-path+
							+ghs-pictogram-web-image-subdir+)))
  (mapcar #'(lambda (r)
	      (cons (db:id r)
		    (pictogram->preview-path (db:pictogram-file r) (uiop:unix-namestring prefix)
					     :extension +pictogram-web-image-ext+)))
	  (all-pictograms class)))

(defun pictogram-preview-url (id-pictogram
			      &optional
				(prefix (concatenate 'string +images-url-path+
						     +ghs-pictogram-web-image-subdir+)))
  (and (db-utils:object-exists-in-db-p 'db:ghs-pictogram id-pictogram)
       (local-uri (pictogram->preview-path (db:pictogram-file
					    (single 'db:ghs-pictogram :id id-pictogram))
					   prefix
					   :extension +pictogram-web-image-ext+))))
; rendering

(defun pictograms-template-struct (&optional
				     (class  'db:ghs-pictogram)
				     (prefix (concatenate 'string +images-url-path+
							  +ghs-pictogram-web-image-subdir+)))
  (list :pictogram-buttons
	 (mapcar #'(lambda (a) (list :pict-id (car a) :path (cdr a)))
		 (pictograms-alist class prefix))))

(defmacro with-standard-html-frame ((stream title &key
					    (infos nil)
					    (errors nil)
					    (use-animated-logo-p nil)
					    (css-file *default-css-filename*))
				    &body body)
  `(with-output-to-string (,stream)
     (html-template:fill-and-print-template #p"header.tpl"
					    (with-path-prefix
						:css-file (restas:genurl
							   'restas.lab::-css-.route
							   :path ,css-file)
						:jquery-ui-css (restas:genurl
								'restas.lab::-css-.route
								:path "jquery-ui.min.css")
						:anim-css (restas:genurl
							   'restas.lab::-css-.route
							   :path "anim.css")
						:jquery (restas:genurl 'restas.lab::-js-.route
								       :path "jquery.js")
						:jquery-ui (restas:genurl
							    'restas.lab::-js-.route
							    :path "jquery-ui.js")
						:sugar (restas:genurl 'restas.lab::-js-.route
								      :path "sugar.js")
						:mustache (restas:genurl 'restas.lab::-js-.route
									 :path "mustache.js")
						:title    ,title)
					    :stream ,stream)
     (restas.lab:render-logout-control stream)
     (html-template:fill-and-print-template #p"main-wrapper-header.tpl"
					    nil
					    :stream ,stream)

     (restas.lab:render-main-menu      stream :use-animated-logo-p ,use-animated-logo-p)
     (html-template:fill-and-print-template #p"main-content-wrapper-header.tpl"
					    nil
					    :stream ,stream)

     (html-template:fill-and-print-template #p"section-title.tpl"
					    (list :title ,title)
					    :stream ,stream)
     (html-template:fill-and-print-template #p"messages.tpl"
					    (list :display-messages-p (or ,errors
									  ,infos)
						  :add-errors-p ,errors
						  :errors ,(when errors
								 `(loop for e in ,errors collect
								       (list :error e)))
						  :add-infos-p ,infos
						  :infos ,(when infos
								`(loop for e in ,infos collect
								      (list :info e))))
					    :stream ,stream)
     ,@body
     (html-template:fill-and-print-template #p"main-content-wrapper-footer.tpl"
					    nil
					    :stream ,stream)
     (html-template:fill-and-print-template #p"main-wrapper-footer.tpl"
					    nil
					    :stream ,stream)
     (html-template:fill-and-print-template #p"footer.tpl"
					    (with-path-prefix
						:acknowledgment-lb (_ "Acknowledgment")
						:legal-lb          (_ "Legal"))
					    :stream ,stream)))

(defun fetch-raw-template-list (what template-keyword &key
							(delete-link nil)
							(disable-link nil)
							(enable-link  nil)
							(additional-tpl nil))
  (let ((raw (filter what)))
    (loop for data in raw collect
	 (let ((plist '()))
	   (loop
	      for kw in template-keyword do
		(push (slot-value data (format-symbol :db "~:@(~a~)" kw)) plist)
		(push kw plist))
	   (when delete-link
	     (push (restas:genurl delete-link :id (db:id data)) plist)
	     (push :delete-link plist))
	   (when disable-link
	     (push (restas:genurl disable-link :id (db:id data)) plist)
	     (push :disable-link plist))
	   (when enable-link
	     (push (restas:genurl enable-link :id (db:id data)) plist)
	     (push :enable-link plist))
	   (when additional-tpl
	     (if (functionp additional-tpl)
		 (setf plist (nconc plist (funcall additional-tpl data)))
		 (setf plist (nconc plist additional-tpl))))
	   plist))))

(defun template->string (file template &optional (escaping-fn  #'(lambda (s) s)))
  "Note: by default no escaping is applied!"
  (let ((html-template:*string-modifier* escaping-fn))
    (with-output-to-string (stream)
      (html-template:fill-and-print-template file
					     template
					     :stream stream))))

;; date/time

(defun now-date-for-label ()
  (let ((decoded (multiple-value-list (get-decoded-time))))
    (format nil "(yyyy-mm-dd): ~a-~2,'0-d-~2,'0d"
	    (elt decoded 5) ; year
	    (elt decoded 4) ; month
	    (elt decoded 3)))) ; day

(defun local-time-obj-now ()
  (local-time:now))

(defun encode-datetime-string (d &optional (fallback nil))
  (handler-case
      (local-time:parse-timestring d)
     (error () fallback)))

(defgeneric decode-datetime-string (object))

(defmethod decode-datetime-string ((object (eql nil)))
  "")

(defmethod decode-datetime-string ((object local-time:timestamp))
  (local-time:format-timestring nil object :format '(:year "-" (:month 2) "-"
						     (:day 2) " " (:hour 2) ":" (:min 2))))

(defmethod decode-datetime-string ((object string))
  (decode-datetime-string (encode-datetime-string object)))

(defgeneric decode-date-string (object))

(defmethod decode-date-string ((object (eql nil)))
  "")

(defmethod decode-date-string ((object local-time:timestamp))
  (local-time:format-timestring nil object :format '(:year "-" (:month 2) "-"
						     (:day 2))))

(defmethod decode-date-string ((object string))
  (decode-date-string (encode-datetime-string object)))

(defgeneric decode-time-string (object))

(defmethod decode-time-string ((object local-time:timestamp))
  (local-time:format-timestring nil object :format '((:hour 2) ":" (:min 2))))

(defmethod decode-time-string ((object string))
  (decode-time-string (encode-datetime-string object)))

(defun next-expiration-date ()
  (local-time:timestamp+ (local-time:now) 7 :day))

(defun waste-message-expired-p (message)
  (local-time:timestamp< (db:sent-time message)
			 (local-time:timestamp- (local-time:now) 1 :year)))

(defun timestamp-compare-desc (a b)
  (local-time:timestamp> a b))

(defun timestamp-compare-asc (a b)
  (local-time:timestamp< a b))

(defun remove-old-waste-stats ()
  (let ((jan (local-time:adjust-timestamp (local-time:today)
	       (set :month 1)
	       (set :day-of-month 1))))
    #'(lambda (a)
	(local-time:timestamp< (encode-datetime-string (getf a :sent-time))
			       jan))))

;; mail

(defun send-email (subject to message)
  (when +use-smtp+
    (cl-smtp:send-email +smtp-host+
			+smtp-from-address+
			to
			(concatenate 'string +smtp-subject-mail-prefix+ subject)
			(validation:strip-tags message)
			:ssl  +smtp-ssl+
			:port +smtp-port-address+
			:authentication +smtp-autentication+)))

;; hashtables

(defun init-hashtable-equalp ()
  (make-hash-table :test 'equalp))

;; filesystem

(defun temp-filename ()
  (nix:mktemp (namestring (uiop/stream:temporary-directory))))

;; log facility

(defun open-log ()
  (nix:openlog (symbol-name +program-name+) 0))

(defun to-log (priority format &rest args)
  (apply #'nix:syslog priority format args))

(defun log-and-mail (to subject message &key (level :warning))
  (to-log level (concatenate 'string subject " " message))
  (send-email subject to message))


;; http error handling

(defmacro with-http-ignored-errors ((timeout) &body body)
  `(handler-case
       (trivial-timeout:with-timeout (,timeout)
	 ,@body)
     (error () nil)))
