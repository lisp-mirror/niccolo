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

;; web uri

(defun path-prefix-tpl ()
  (list :path-prefix +path-prefix+))

(defmacro with-path-prefix (&rest tpls)
  `(nconc
    (path-prefix-tpl)
    (list ,@tpls)))

(defun alist->query-uri (alist)
  (reduce #'(lambda (o n) (concatenate 'string o (and o "&") (format nil "~a=~a" (car n) (cdr n))))
	  alist :initial-value nil))

(defun local-uri (path)
  (with-output-to-string (stream)
    (puri:render-uri (make-instance 'puri:uri
				    :scheme :https
				    :host +hostname+
				    :port (if (> +https-proxy-port+ 0)
					      +https-proxy-port+
					      +https-port+)
				    :path path)
		     stream)))

(defun local-uri-noport (path)
  (with-output-to-string (stream)
    (puri:render-uri (make-instance 'puri:uri
				    :scheme :https
				    :host +hostname+
				    :path path)
		     stream)))

(defun remote-uri (host port path)
  (with-output-to-string (stream)
    (puri:render-uri (make-instance 'puri:uri
				    :scheme :https
				    :host host
				    :port port
				    :path path)
		     stream)))

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

(defun all-pictograms ()
  (crane:filter 'db:ghs-pictogram))

(defun pictogram->preview-path (orig-path prefix-path &key (extension +pictogram-web-image-ext+))
  (concatenate 'string
	       +path-prefix+
	       (uiop:unix-namestring prefix-path)
	       (string-utils:find-filename-from-path orig-path :extension extension)))

(defun pictograms-alist (&optional (prefix (concatenate 'string +images-url-path+
							+pictogram-web-image-subdir+)))
  (mapcar #'(lambda (r)
	      (cons (db:id r)
		    (pictogram->preview-path (db:pictogram-file r) (uiop:unix-namestring prefix)
					     :extension +pictogram-web-image-ext+)))
	  (all-pictograms)))

(defun pictogram-preview-url (id-pictogram)
  (and (db-utils:object-exists-in-db-p 'db:ghs-pictogram id-pictogram)
       (local-uri (pictogram->preview-path (db:pictogram-file
					    (single 'db:ghs-pictogram :id id-pictogram))
					   (concatenate 'string
							+images-url-path+
							+pictogram-web-image-subdir+)
					   :extension +pictogram-web-image-ext+))))
; rendering

(defun pictograms-template-struct (&optional
				     (prefix (concatenate 'string +images-url-path+
							  +pictogram-web-image-subdir+)))
  (list :pictogram-buttons
	 (mapcar #'(lambda (a) (list :pict-id (car a) :path (cdr a)))
		 (pictograms-alist prefix))))

(defmacro with-standard-html-frame ((stream title &key
					    (infos nil)
					    (errors nil)
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
						  :jquery (restas:genurl 'restas.lab::-js-.route
									 :path "jquery.js")
						  :jquery-ui (restas:genurl
							      'restas.lab::-js-.route
							      :path "jquery-ui.js")
						  :sugar (restas:genurl 'restas.lab::-js-.route
									:path "sugar.js")
						  :title    ,title)
					      :stream ,stream)
       (restas.lab:render-logout-control stream)
       (html-template:fill-and-print-template #p"main-wrapper-header.tpl"
					      nil
					      :stream ,stream)

       (restas.lab:render-main-menu      stream)
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

(defun encode-datetime-string (d)
  (local-time:parse-timestring d))

(defgeneric decode-datetime-string (object))

(defmethod decode-datetime-string ((object local-time:timestamp))
  (local-time:format-timestring nil object :format '(:year "-" (:month 2) "-"
						     (:day 2) " " (:hour 2) ":" (:min 2))))

(defmethod decode-datetime-string ((object string))
  (decode-datetime-string (encode-datetime-string object)))

(defgeneric decode-date-string (object))

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
  (to-log level message)
  (send-email subject to message))
