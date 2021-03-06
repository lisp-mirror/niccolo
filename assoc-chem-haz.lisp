;; niccolo': a chemicals inventory
;; Copyright (C) 2016  Universita' degli Studi di Palermo

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, version 3 of the License, or  (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :restas.lab)

(define-constant +name-haz-desc+        "desc"            :test #'string=)

(define-constant +name-haz-code+        "code"            :test #'string=)

(define-constant +name-hazcode-id+      "haz-code-id"     :test #'string=)

(define-constant +name-haz-compound-id+ "haz-compound-id" :test #'string=)

(defun fetch-hazard-from-compound-id (id &optional (delete-link nil))
  (let ((raw (db-query
	      (select ((:as :chem.id               :chem-id)
		       (:as :haz.id                :id)
		       (:as :haz-stat.code         :code)
		       (:as :haz-stat.explanation  :expl)
		       (:as :haz-stat.carcinogenic :carc)
		       (:as :haz-stat.pictogram    :pictogram-id))
		(from (:as :chemical-hazard :haz))
		(left-join (:as :ghs-hazard-statement :haz-stat)
			   :on (:= :haz-stat.id :haz.ghs-h))
		(left-join (:as :chemical-compound :chem)
			   :on (:= :chem.id :haz.compound-id))
		(left-join :ghs-pictogram
			   :on (:= :haz-stat.pictogram :ghs-pictogram.id))
		(where (:= :chem.id id))))))
    (loop for row in raw collect
	 (let ((id            (getf row :|id|))
	       (chem-id       (getf row :|chem-id|))
	       (code          (getf row :|code|))
	       (expl          (getf row :|expl|))
	       (carc          (getf row :|carc|))
	       (pictogram-uri (pictogram-preview-url (getf row :|pictogram-id|))))
	   (append
	    (list :id            id
		  :code          code
		  :desc          (concatenate 'string code " " expl carc
					      (and (string= +ghs-carcinogenic-code+ carc)
						   (_ " Carcinogenic")))
		  :pictogram-uri pictogram-uri)
	    (if delete-link
		(list :delete-link (restas:genurl delete-link :id id :id-chem chem-id))))))))

(defun fetch-assoc-by-ids (haz-id chem-id)
  (db-query (select :*
           (from (:as :chemical-hazard :c))
	   (where (:and (:= :c.ghs-h haz-id)
			(:= :c.compound-id chem-id))))))

(defun fetch-hazard-from-compound (compound &optional (delete-link nil))
  (and compound
       (fetch-hazard-from-compound-id (db:id compound) delete-link)))

(gen-autocomplete-functions db:ghs-hazard-statement db:build-description)

(defun manage-assoc-chem-haz (compound infos errors)
  (let ((hazcodes-owned (fetch-hazard-from-compound compound'delete-assoc-chem-haz)))
    (with-standard-html-frame (stream
 			       (_ "Associate hazardous phrases to chemical compound")
 			       :errors errors
 			       :infos  infos)

      (let* ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
	     (json-addresses    (array-autocomplete-ghs-hazard-statement))
	     (json-addresses-id (array-autocomplete-ghs-hazard-statement-id))
	     (template          (with-back-uri (chemical)
				  (with-path-prefix
				      :name-lb               (_ "Name")
				      :description-lb        (_ "Description")
				      :operations-lb         (_ "Operations")
				      :origin-lb             (_ "Origin")
				      :name-lb               (_ "Name")
				      :hazard-codes-lb       (_ "GHS Hazard Codes")
				      :prec-codes-lb         (_ "GHS precautionary statements")
				      :operations-lb         (_ "Operations")
				      :lookup-haz-code-url
				      (restas:genurl 'ws-ghs-h-reverse-lookup)
				      :lookup-prec-code-url
				      (restas:genurl 'ws-ghs-p-reverse-lookup)
				      :compound-name         (db:name compound)
				      :haz-code-assoc-name   +name-haz-code+
				      :prec-code-assoc-name  +name-prec-code+
				      :haz-desc              +name-haz-desc+
				      :haz-code-id           +name-hazcode-id+
				      :haz-compound-id       +name-haz-compound-id+

				      :prec-code-id          +name-preccode-id+
				      :prec-compound-id      +name-prec-compound-id+

				      :value-haz-compound-id (db:id compound)
				      :json-haz-code         json-addresses
				      :json-haz-id           json-addresses-id
				      ;; federated query
				      :fq-start-url
				      (restas:genurl 'ws-federated-query-compound-hazard)
				      :fq-results-url
				      (restas:genurl 'ws-federated-query-results)
				      :fq-query-key-param    +query-http-parameter-key+
				      :data-table            hazcodes-owned))))
 	(html-template:fill-and-print-template #p"assoc-chem-haz.tpl"
					       template
 					       :stream stream)))))

(defun add-new-assoc-chem-haz (haz-id chem-id)
  (let* ((errors-msg-1 (concatenate 'list
				    (regexp-validate (list
						      (list haz-id
							    +pos-integer-re+
							    (_ "Code invalid"))
						      (list chem-id
							    +pos-integer-re+
							    (_ "Chemical ID invalid"))))))
	 (errors-msg-chem-not-found (when (and (not errors-msg-1)
					       (not (db-single 'db:chemical-compound
							       :id chem-id)))
				      (list (_ "Chemical compound not in database"))))
	 (errors-msg-haz-not-found (when (and (not errors-msg-1)
					      (not (db-single 'db:ghs-hazard-statement
							   :id haz-id)))
				     (list (_ "GHS Hazardous code not in database"))))
	 (error-assoc-exists       (when (and (not errors-msg-1)
					      (fetch-assoc-by-ids haz-id chem-id))
				     (list (_ "GHS Hazardous code already associated with this chemical compound."))))
	 (errors-msg (concatenate 'list
				  errors-msg-1
				  errors-msg-chem-not-found
				  errors-msg-haz-not-found
				  error-assoc-exists))
	 (success-msg (and (not errors-msg)
			   (list (_ "Saved association")))))
    (when (not errors-msg)
      (let ((haz-assoc (db-create'db:chemical-hazard
			       :ghs-h haz-id
			       :compound-id chem-id)))

	(db-save haz-assoc)))
    (manage-assoc-chem-haz (db-single 'db:chemical-compound :id chem-id)
			   success-msg errors-msg)))

(define-lab-route assoc-chem-haz ("/assoc-chem-haz/:id" :method :get)
  (with-authentication
    (if (not (regexp-validate (list (list id +pos-integer-re+ ""))))
	(let ((chemical (db-single 'db:chemical-compound :id id)))
	  (if chemical
	      (manage-assoc-chem-haz chemical nil nil)
	      +http-not-found+))
	+http-not-found+)))

(define-lab-route add-assoc-chem-haz ("/add-assoc-chem-haz/" :method :get)
  (with-authentication
    (with-editor-or-above-credentials
	(progn
	  (add-new-assoc-chem-haz (get-clean-parameter +name-hazcode-id+)
				  (get-clean-parameter +name-haz-compound-id+)))
      (manage-chem nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-assoc-chem-haz ("/delete-assoc-chem-haz/:id/:id-chem" :method :get)
  (with-authentication
    (with-editor-or-above-credentials
	(progn
	  (when (and (not (regexp-validate (list (list id +pos-integer-re+ ""))))
		     (not (regexp-validate (list (list id-chem +pos-integer-re+ "")))))
	    (let ((to-trash (db-single 'db:chemical-hazard :id id)))
	      (when to-trash
		(db-del (db-single 'db:chemical-hazard :id id))))
	    (restas:redirect 'assoc-chem-haz :id id-chem)))
      (manage-chem nil (list *insufficient-privileges-message*)))))


(define-lab-route remove-haz-code-from-chem ("/remove-haz-code-from-chem/:id-haz/:id-chem"
					     :method :get)
  (with-authentication
    (with-editor-or-above-credentials
	(progn
	  (when (and (not (regexp-validate (list (list id-haz  +pos-integer-re+ ""))))
		     (not (regexp-validate (list (list id-chem +pos-integer-re+ "")))))
	    (let ((to-trash (db-single 'db:chemical-hazard :ghs-h id-haz :compound-id id-chem)))
	      (when to-trash
		(db-del to-trash)))
	    (restas:redirect 'assoc-chem-haz :id id-chem)))
      (manage-chem nil (list *insufficient-privileges-message*)))))
