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

(define-constant +name-waste-user-name+          "name"        :test #'string=)

(define-constant +name-waste-cer-id+             "cer"         :test #'string=)

(define-constant +name-waste-description+        "desc"        :test #'string=)

(define-constant +name-waste-building-id+        "building-id" :test #'string=)

(define-constant +name-waste-lab-num+            "lab-num"     :test #'string=)

(define-constant +name-waste-weight+             "weight"     :test #'string=)

(define-constant +name-select-adr+               "select-adr"  :test #'string=)

(gen-autocomplete-functions db:cer-code db:code)

(defun adr-list ()
  (let ((raw (filter 'db:adr-code)))
    (loop for i in raw collect
	 (list :adr-id         (db:id i)
	       :adr-uncode     (db:uncode i)
	       :adr-code-class (db:code-class i)
	       :adr-expl       (db:explanation i)))))

(defun collect-all-adr (parameters)
  (loop for i in parameters when (string= +name-select-adr+ (car i)) collect
       (strip-tags (cdr i))))

(defun manage-waste-letter (infos errors)
  (with-standard-html-frame (stream
			     (_ "Hazardous waste form")
			     :errors errors
			     :infos  infos)
    (let ((html-template:*string-modifier* #'identity)
	  (json-cer    (array-autocomplete-cer-code))
	  (json-cer-id (array-autocomplete-cer-code-id))
	  (json-building    (array-autocomplete-building))
	  (json-building-id (array-autocomplete-building-id)))
      (html-template:fill-and-print-template #p"waste-letter.tpl"
					     (with-back-to-root
						 (with-path-prefix
						     :name-lb          (_ "Name")
						     :building-lb      (_ "Building")
						     :laboratory-lb    (_ "Laboratory")
						     :weight-lb        (_ "Weight (Kg)")
						     :description-lb   (_ "Description")
						     :name             +name-waste-user-name+
						     :cer-id           +name-waste-cer-id+
						     :building-id      +name-waste-building-id+
						     :lab-num          +name-waste-lab-num+
						     :weight           +name-waste-weight+
						     :description      +name-waste-description+
						     :json-cer         json-cer
						     :json-cer-id      json-cer-id
						     :json-building    json-building
						     :json-building-id json-building-id
						     :adr-list         (adr-list)))
					       :stream stream))))

(define-lab-route waste-letter ("/waste-letter/" :method :get)
  (with-authentication
      (manage-waste-letter nil nil)))

(defun letter-adr-codes (adrs)
  (if (= 1 (length adrs))
      (format nil "il codice ADR: ~a" (first adrs))
      (format nil
	      "i seguenti codici ADR: ~a"
	      (reduce #'(lambda (a b) (format nil "~a, ~a" a b))
		      adrs))))

(defun write-letter (user lab-num address weight cer body adrs)
  (let ((actual-address (cond
			  ((scan "^[aeiouAEIOU]" address)
			   (format nil "l'~a" address))
			  ((scan "(^.+[aeAE] )|([aeAE]$)" address)
			   (format nil "la ~a" address))
			  (t
			   (format nil "il ~a" address)))))
    (format nil
	    *waste-letter-body*
	    user lab-num actual-address weight body cer
	    (letter-adr-codes adrs))))

(defun get-column-from-id (id re object column-fn &key (default ""))
  (let ((obj-db (single object :id (if (scan-to-strings re id)
				       (parse-integer id)
				       +db-invalid-id-number+))))
    (if obj-db
	(funcall column-fn obj-db)
	default)))

(defun generate-letter (username lab-number building-id weight cer-id body adrs)
  (let ((all-adrs (loop for i in (map 'list #'parse-integer
				      (remove-if #'null
						 (map 'list
						      #'(lambda (a)
							  (scan-to-strings +pos-integer-re+ a))
						      adrs)))
		       collect
		       (single 'db:adr-code :id i)))
 	(actual-cer (get-column-from-id cer-id
					+pos-integer-re+
					'db:cer-code
					#'db:code
					:default "*Attenzione: non hai indicato un codice esistente nel database*"))
	(building   (get-column-from-id building-id
					+pos-integer-re+
					'db:building
					#'db:name
					:default "*Attenzione: non hai indicato un edificio esistente nel database*")))
    (with-a4-ps-doc (doc)
      (let ((font (default-font doc)))
	(ps:setcolor doc ps:+color-type-fillstroke+ (cl-colors:rgb 0.0 0.0 0.0))
	(ps:setfont doc font 4.0)
	(ps:set-parameter doc ps:+value-key-linebreak+ ps:+true+)
	(ps:set-parameter doc ps:+parameter-key-imageencoding+ ps:+image-encoding-type-hex+)
	(ps:show-boxed doc
		       (format nil *letter-header-text*)
		       80
		       (- (ps:height ps:+a4-page-size+) +page-margin-top+)
		       100
		       0
		       ps:+boxed-text-h-mode-center+ "")
	(cond
	  ((not (scan +integer-re+  weight))
	   (ps:show-boxed doc "Attenzione! Non hai indicato correttamente il peso."
			+page-margin-left+
			(- (ps:height ps:+a4-page-size+) +page-margin-top+ +header-image-export-height+)
			(- (ps:width ps:+a4-page-size+) (* 2.0 +page-margin-left+))
			0
			ps:+boxed-text-h-mode-left+
			""))

	  ((null all-adrs)
	   (ps:show-boxed doc "Attenzione! Non hai indicato il codice ADR."
			+page-margin-left+
			(- (ps:height ps:+a4-page-size+) +page-margin-top+ +header-image-export-height+)
			(- (ps:width ps:+a4-page-size+) (* 2.0 +page-margin-left+))
			0
			ps:+boxed-text-h-mode-left+
			""))
	  ((string= actual-cer "")
	   (ps:show-boxed doc "Attenzione! Non hai indicato il codice CER."
			+page-margin-left+
			(- (ps:height ps:+a4-page-size+) +page-margin-top+ +header-image-export-height+)
			(- (ps:width ps:+a4-page-size+) (* 2.0 +page-margin-left+))
			0
			ps:+boxed-text-h-mode-left+
			""))
	  ((find-if #'(lambda (a) (scan +adr-code-radioactive+ (db:code-class a))) all-adrs)
	   (ps:show-boxed doc "Attenzione! Il codice ADR selezionato indica una sostanza radioattiva. Contattare i tecnici per procedere allo smaltimento."
			  +page-margin-left+
			  (- (ps:height ps:+a4-page-size+)
			     +page-margin-top+
			     +header-image-export-height+)
			  (- (ps:width ps:+a4-page-size+) (* 2.0 +page-margin-left+))
			  0
			  ps:+boxed-text-h-mode-left+
			  ""))
	  (t
	   (let* ((msg-text (write-letter username lab-number building weight actual-cer body
					  (mapcar #'(lambda (a) (format nil "~a (classe ~a)"
									(db:uncode a)
									(db:code-class a)))
						  all-adrs)))
		  (reminder-message (send-user-message (make-instance 'db:waste-message)
						       (get-session-user-id)
						       (get-session-user-id)
						       (_ "Waste production")
						       msg-text
						       :parent-message nil
						       :child-message nil
						       :cer-code-id cer-id
						       :building-id building-id
						       :weight      weight
						       :adr-ids     adrs)))
	     ;; message for admin
	     (send-user-message (make-instance 'db:waste-message)
				(get-session-user-id)
				(admin-id)
				(_ "Waste production")
				msg-text
				:parent-message nil
				:child-message  nil
				:echo-message   (db:id reminder-message)
				:cer-code-id    cer-id
				:building-id    building-id
				:weight         weight
				:adr-ids        adrs)
	     (ps:show-boxed doc msg-text
			    +page-margin-left+
			    (- (ps:height ps:+a4-page-size+)
			       +page-margin-top+
			       +header-image-export-height+)
			    (- (ps:width ps:+a4-page-size+) (* 2.0 +page-margin-left+))
			    0
			    ps:+boxed-text-h-mode-left+
			    "")
	     (let ((sign-pos (ps:get-value doc ps:+boxed-text-value-boxheight+)))
	       (ps:show-boxed doc
			      "In fede."
			      +page-margin-left+
			      (- (ps:height ps:+a4-page-size+)
				 (/ sign-pos 2.5)
				 +page-margin-top+
				 +header-image-export-height+)
			      (- (ps:width ps:+a4-page-size+) (* 2.0 +page-margin-left+))
			      0
			      ps:+boxed-text-h-mode-right+ "")))))))))

(define-lab-route write-waste-letter ("/write-waste-letter/" :method :get)
  (with-authentication
    (setf (header-out :content-type) +mime-postscript+)
    (generate-letter (strip-tags (get-parameter +name-waste-user-name+))
		     (strip-tags (get-parameter +name-waste-lab-num+))
		     (strip-tags (get-parameter +name-waste-building-id+))
		     (strip-tags (get-parameter +name-waste-weight+))
		     (strip-tags (get-parameter +name-waste-cer-id+))
		     (strip-tags (get-parameter +name-waste-description+))
		     (collect-all-adr (get-parameters*)))))
