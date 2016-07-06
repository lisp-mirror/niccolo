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

(define-lab-route ws-building ("/ws/building/:id" :method :get)
  (with-authentication
    (let* ((error-msg-no-int (regexp-validate (list (list id +pos-integer-re+
							  (_ "Map id invalid")))))
	   (error-msg-storage-not-found (when (and (not error-msg-no-int)
						   (not (single 'db:building :id id)))
					  (list (_ "Storage not in the database"))))
	   (all-errors (append error-msg-no-int error-msg-storage-not-found)))
      (if (not all-errors)
	  (obj->json-string (plist-alist (fetch-single-building id)))
	  +http-not-found+))))

(define-lab-route ws-ghs-hazard ("/ws/GHS-haz/:id" :method :get)
  (with-authentication
    (let* ((error-msg-no-int (regexp-validate (list (list id
							  +pos-integer-re+
							  (_ "Chemical compound id invalid")))))
	   (error-msg-storage-not-found (when (and (not error-msg-no-int)
						   (not (single 'db:chemical-compound :id id)))
					  (list (_ "Chemical compound not in the database"))))
	   (all-errors (append error-msg-no-int error-msg-storage-not-found)))
      (if (not all-errors)
	  (obj->json-string (loop for i in (fetch-hazard-from-compound-id id) collect
				(plist-alist i)))
	  +http-not-found+))))

(define-lab-route ws-ghs-prec ("/ws/GHS-prec/:id" :method :get)
  (with-authentication
    (let* ((error-msg-no-int (regexp-validate (list (list id
							  +pos-integer-re+
							  (_ "Chemical compound id invalid")))))
	   (error-msg-storage-not-found (when (and (not error-msg-no-int)
						   (not (single 'db:chemical-compound :id id)))
					  (list (_ "Chemical compound not in the database"))))
	   (all-errors (append error-msg-no-int error-msg-storage-not-found)))
      (if (not all-errors)
	  (obj->json-string (loop for i in (fetch-prec-from-compound-id id) collect
				(plist-alist i)))
	  +http-not-found+))))

(define-lab-route single-barcode ("/gen-barcode/:id" :method :get)
  (with-authentication
    (if (and (scan +pos-integer-re+ id)
	     (single 'db:chemical-product :id (parse-integer id)))
	(progn
	  (setf (header-out :content-type) +mime-postscript+)
	  (let ((doc (make-instance 'ps:psdoc :page-size ps:+a4-page-size+)))
	    (let ((ps:*callback-string* ""))
	      (ps:open-doc doc nil)
	      (ps:begin-page doc)
	      (render-barcode-x-y doc id (/ (ps:width ps:+a4-page-size+) 2) +page-margin-top+)
	      (ps:end-page doc)
	      (ps:close-doc doc)
	      (ps:shutdown)
	      ps:*callback-string*)))
	+http-not-found+)))

(defun %extract-parse (key bag &optional (default "1.0"))
  (parse-number:parse-number (or (cdr (assoc key bag)) default)))

(define-lab-route l-factor-i ("/l-factor/" :method :post)
  (with-authentication
    (if  (tbnl:post-parameter "req")
	 (progn
	   (let* ((params  (json:decode-json-from-string (tbnl:post-parameter "req")))
		  (risk-calculator:*errors* '())
		  (results (risk-calculator:l-factor-i (cdr (assoc :r-phrases params))
						       (cdr (assoc :exposition-types params))
						       (cadr (assoc :physical-state params))
						       (%extract-parse :working-temp params)
						       (%extract-parse :boiling-point params)
						       (cadr (assoc :exposition-time-type params))
						       (%extract-parse :exposition-time params)
						       (cadr (assoc :usage params))
						       (%extract-parse :quantity-used params)
						       (%extract-parse :quantity-stocked params)
						       (cadr (assoc :work-type params))
						       (cdr (assoc :protections-factor params))
						       (if (> (%extract-parse :safety-threshold
									      params)
							      0.0)
							   (%extract-parse :safety-threshold params)
							   1.0))))
	     (utils:plist->json (list :res results :err risk-calculator:*errors*))))
	 (utils:plist->json (list :res "0.0" :err (_ "empty request"))))))

(define-lab-route l-factor-carc-i ("/l-factor-carc/" :method :post)
  (with-authentication
    (let* ((params  (json:decode-json-from-string (tbnl:post-parameter "req")))
	   (risk-calculator:*errors* '())
	   (results (risk-calculator:l-factor-carc-i (cdr (assoc :protective-device params))
						     (cdr (assoc :physical-state params))
						     (%extract-parse :twork params)
						     (%extract-parse :teb params)
						     (%extract-parse :quantity-used params)
						     (%extract-parse :usage-per-day params)
						     (%extract-parse :usage-per-year params))))
      (utils:plist->json (list :res results :err risk-calculator:*errors*)))))

(define-lab-route ws-get-user-message ("/ws/user-messages/:id" :method :get)
  (with-authentication
    (let* ((error-msg-no-int (regexp-validate (list (list id
							  +pos-integer-re+
							  (_ "Id message invalid")))))
	   (error-msg-not-found (when (and (not error-msg-no-int)
					   (not (single 'db:message :id id)))
				  (list (_ "Message not found"))))
	   (all-errors (append error-msg-no-int error-msg-not-found)))
      (if (not all-errors)
	  (let ((template (fetch-template-message-by-id id)))
	    (plist->json template))
	  +http-not-found+))))

;;;; federated query

(defmacro with-federated-query-enabled (&body body)
  `(if +federated-query-enabled+
       (progn
	 ,@body)
       +http-not-found+))

(define-lab-route ws-query-product (+query-product-path+ :method :post)
  (with-federated-query-enabled
    (let ((query (json-string->obj (tbnl:post-parameter +query-http-parameter-key+))))
      (if query
	  (fq:with-credentials ((address-string->vector (tbnl:remote-addr*)) (fq:key query))
	    (let* ((products-query (gen-all-prod-select (where
							 (:like :chem-name
								(prepare-for-sql-like (fq:request query))))))
		   (products-plists (build-template-list-chemical-prod (query products-query)))
		   (products-serialized (chemical-products-template->json-string products-plists
										 :other-pairs
										 (cons :host +hostname+)))
		   (response (fq:make-query-product-response products-serialized
							     (fq:id query)))
		   (origin-host                (fq:origin-host query))
		   (origin-host-port           (fq:origin-host-port query)))
	      (if (and origin-host
		       origin-host-port
		       (fq:find-node origin-host))
		  (progn
		    ;; spawn request
		    (let ((req (fq::make-query-product (fq:request query)
						       :id          (fq:id query)
						       :origin-host origin-host
						       :port        origin-host-port)))
		      (fq::federated-query-product req))
		    (when products-plists
		      (fq:send-response response origin-host origin-host-port
					:path +post-query-product-results+))
		    +http-ok+)
		  +http-not-found+)))
	  +http-not-found+))))

(define-lab-route ws-query-product-results (+post-query-product-results+ :method :post)
  (with-federated-query-enabled
    (let ((response (json-string->obj (tbnl:post-parameter +query-http-response-key+))))
      (if response
	  (fq:with-credentials ((address-string->vector (tbnl:remote-addr*)) (fq:key response))
	    (when (fq:id response)
	      (fq:enqueue-results (fq:id response) response)
	      (tbnl:log-message* :info
				 "received product-query ~a from ~a. -> ~a"
				 (fq:id response)
				 (get-host-by-address (address-string->vector (tbnl:remote-addr*)))
				 (tbnl:post-parameter +query-http-response-key+)))

	    +http-ok+)
	  +http-not-found+))))

(define-lab-route ws-query-visited (+query-visited+ :method :post)
  (with-federated-query-enabled
    (let* ((query (json-string->obj (tbnl:post-parameter +query-http-parameter-key+))))
      (if query
	  (fq:with-credentials ((address-string->vector (tbnl:remote-addr*)) (fq:key query))
	    (tbnl:log-message* :info
			       "received visited query ~a from ~a."
			       (fq:id query)
			       (get-host-by-address (address-string->vector (tbnl:remote-addr*))))
	    (let* ((query-id  (and query    (fq:id query)))
		   (visited-p (and query-id (fq:set-visited query-id))))
	      (obj->json-string (fq:make-visited-response visited-p query-id))))
	  +http-not-found+))))

(define-lab-route ws-federated-query-product ("/fq-product" :method :get)
  (with-federated-query-enabled
    (with-authentication
      (let ((errors (regexp-validate (list (list (tbnl:get-parameter +query-http-parameter-key+)
						 +federated-query-product-re+
						 (_ "no"))))))
	(if (not errors)
	    (fq:federated-query-product (tbnl:get-parameter +query-http-parameter-key+))
	    +http-not-found+)))))

(define-lab-route ws-federated-query-product-results ("/fq-product-res" :method :get)
  (with-federated-query-enabled
    (with-authentication
      (let ((errors (regexp-validate (list (list (tbnl:get-parameter +query-http-parameter-key+)
						 +federated-query-id-re+
						 (_ "no"))))))
	(if (not errors)
	    (fq:get-serialized-results (tbnl:get-parameter +query-http-parameter-key+))
	    +http-not-found+)))))
