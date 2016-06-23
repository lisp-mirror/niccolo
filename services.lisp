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

(define-lab-route ws-query-product (+query-product-path+ :method :post)
  (let ((query (json-string->obj (tbnl:post-parameter +query-http-parameter-key+))))
    (if query
	(fq:with-credentials ((host) (fq:key query))
	  nil)
	;; se si fare la query sql sempre ripulendo l'input anche se e' inutile
	;; se ci sono risultati mandarli all'host origine tramite ws-query-product-results
      +http-not-found+)))

(define-lab-route ws-query-product-results (+post-query-product-results+ :method :post)
  (break))

(define-lab-route ws-query-visited (+query-visited+ :method :post)
  (let* ((query (json-string->obj (tbnl:post-parameter +query-http-parameter-key+))))
    (if query
	(fq:with-credentials ((host) (fq:key query))
	  (let* ((query-id  (and query (fq:id query)))
		 (visited-p (and query-id (fq:query-visited-p query-id))))
	    (when query-id
	      (fq:set-visited query-id))
	    (obj->json-string (fq:make-visited-response visited-p query-id))))
	+http-not-found+)))
