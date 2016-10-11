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

(define-constant +name-ghs-precautionary-expl+ "expl" :test #'string=)

(define-constant +name-ghs-precautionary-code+ "code" :test #'string=)

(defmacro gen-admissible-cookie-uri ((path) &body symbols)
  `(and
    ,@(loop for symbol in symbols collect
	   `(not ,(if (stringp symbol)
		      `(scan ,symbol ,path)
		      `(scan (restas:genurl ',symbol) ,path))))))

(defun admissible-cookie-redirect-p (path)
  (and (cookie-key-script-visited-validate path)
       (gen-admissible-cookie-uri (path)
	 root-login
	 logout
	 change-pass
	 actual-user-change-pass
	 actual-admin-change-pass
	 "user"
	 "admin"
	 "add"
	 "/ws/"
	 "assoc"
	 "subst"
	 "delete"
	 "update")))

(defun manage-welcome ()
  (with-standard-html-frame (stream (_ "Welcome"))
    (html-template:fill-and-print-template #p"welcome.tpl"
					   (with-path-prefix
					       :num-msg
					     (format nil (n_ "You have ~a message"
							     "You have ~a message"
							     (number-of-msg-sent-to-me))
						     (number-of-msg-sent-to-me))
					     :messages-url (restas:genurl 'user-messages))
					   :stream stream)))

(define-lab-route root ("/" :method :get)
  #+mini-cas
  (if (hunchentoot:parameter mini-cas:+query-ticket-key+)
      (progn
	(check-with-cas-authenticate () nil)
	(if (admissible-cookie-redirect-p (tbnl:cookie-in +cookie-key-script-visited+))
	    (tbnl:redirect (tbnl:cookie-in +cookie-key-script-visited+))
	    (restas:redirect 'root)))
      (authenticate (nil nil)
	(i18n:with-user-translation ((get-session-user-id))
	  (manage-welcome))))
  #-mini-cas
  (authenticate (nil nil)
    (i18n:with-user-translation ((get-session-user-id))
      (manage-welcome))))

(define-lab-route root-login ("/login" :method :post)
  (with-authentication
    (if (admissible-cookie-redirect-p (tbnl:cookie-in +cookie-key-script-visited+))
	(tbnl:redirect (tbnl:cookie-in +cookie-key-script-visited+))
	(manage-welcome))))

(define-lab-route user-messages ("/messages" :method :get)
  (with-authentication
    (with-session-user (user)
      (create-expiration-messages (fetch-expired-products))
      (create-validity-expired-messages (fetch-validity-expired-products))
      (create-shortage-messages (shortage-products-list (db:id user)))
      (print-messages nil nil))))

(define-lab-route storing-classify ("/storage-classify/" :method :get)
  (with-authentication
    (with-standard-html-frame (stream (_ "Classify"))
      (html-template:fill-and-print-template #p"classification-tree.tpl"
					     nil
					     :stream stream))))

(define-lab-route acknowledgment ("/acknowledgment" :method :get)
  (with-authentication
    (with-standard-html-frame (stream (_ "Acknowledgment"))
      (html-template:fill-and-print-template #p"acknowledgment.tpl"
					     nil
					     :stream stream))))

(define-lab-route legal ("/legal" :method :get)
  (with-authentication
    (with-standard-html-frame (stream (_ "Legal"))
      (html-template:fill-and-print-template #p"legal.tpl"
					     nil
					     :stream stream))))
(defun time-to-nyan ()
  (let ((decoded (multiple-value-list (get-decoded-time))))
    (and (= (elt decoded 4) 4)
	 (= (elt decoded 3) 1))))

(defun render-logout-control (stream)
  (let ((template (with-path-prefix
  		      :session-username (format nil "(~a)"
						(get-session-username))
		      :logout-link      (with-session-user (user)
					  (if user
					      (restas:genurl 'logout)
					      nil))
		      :login-link       (with-session-user (user)
					  (if (not user)
					      #+mini-cas (cas-login-uri)
					      #-mini-cas (restas:genurl 'logout)
					      nil)))))
    (html-template:fill-and-print-template #p"logout-control.tpl"
					   template
					   :stream stream)))

(defun render-main-menu (stream)
  (let ((template (with-path-prefix
		      :has-nyan              (time-to-nyan) ;-)
		      :safety-lbl            (_ "Safety")
		      :manage-ghs-hazard     (restas:genurl 'ghs-hazard)
		      :manage-ghs-hazard-lbl (_ "GHS Hazard Codes")
		      :manage-ghs-precaution (restas:genurl 'ghs-precautionary)
		      :manage-ghs-precaution-lbl (_ "GHS precautionary statements")
		      :manage-cer            (restas:genurl 'cer)
		      :manage-cer-lbl        (_ "CER codes")
		      :manage-sensors        (restas:genurl 'sensor)
		      :manage-sensors-lbl    (_ "Manage sensors")
		      :manage-adr            (restas:genurl 'adr)
		      :manage-adr-lbl        (_ "ADR codes")
		      :places-lbl            (_ "Places")
		      :manage-address        (restas:genurl 'address)
		      :manage-address-lbl    (_ "Address")
		      :manage-building       (restas:genurl 'building)
		      :manage-building-lbl   (_ "Building")
		      :manage-maps           (restas:genurl 'plant-map)
		      :manage-maps-lbl       (_ "Maps")
		      :manage-storage        (restas:genurl 'storage)
		      :manage-storage-lbl    (_ "Storage")
		      :chemical-compounds-lbl (_ "Chemical compound")
		      :manage-chemicals      (restas:genurl 'chemical)
		      :manage-chemicals-lbl  (_ "Compound")
		      :chemical-products-lbl (_ "Chemical products")
		      :manage-chemical-products (restas:genurl 'chem-prod)
		      :manage-chemical-products-lbl (_ "Managing")
		      :users-lbl             (_ "Users")
		      :manage-user           (restas:genurl 'user)
		      :manage-user-lbl       (_ "Manage users")
		      :user-messages-lb      (_ "Messages")
		      :user-messages         (restas:genurl 'user-messages)
		      :broadcast-messages-lb (_ "Broadcast messages")
		      :broadcast-messages    (restas:genurl 'broadcast-message)
		      :user-preferences      (restas:genurl 'user-preferences)
		      :user-preferences-lbl  (_ "User preferences")
		      :change-password       (restas:genurl 'change-pass)
		      :change-password-lbl   (_ "Change password")
		      :waste-letter          (restas:genurl 'waste-letter)
		      :waste-letter-lbl      (_ "Hazardous waste form")
		      :waste-stats           (restas:genurl 'waste-statistics)
		      :waste-stats-lbl       (_ "Waste report")
		      :l-factor-calculator   (restas:genurl 'l-factor)
		      :l-factor-calculator-lbl (_ "Chemical risk calculator")
		      :l-factor-calculator-carc (restas:genurl 'l-factor-carc)
		      :l-factor-calculator-carc-lbl (_ "Chemical risk calculator (carcinogenic)")
		      :store-classify-tree (restas:genurl 'storing-classify)
		      :store-classify-tree-lbl   (_ "Chemical classifications for safe storage."))))
    (html-template:fill-and-print-template #p"main-menu.tpl"
					   template
					   :stream stream)))

;; start the server

(defclass lab-acceptor (restas:restas-ssl-acceptor) ()
  (:default-initargs
   :error-template-directory *error-template-directory*
   :message-log-destination  *message-log-pathname*
   :access-log-destination   *access-log-pathname*
   :document-root            config:*default-www-root*))

(defmethod tbnl:acceptor-status-message :around ((object lab-acceptor) http-status-code
						 &key &allow-other-keys)
  (if (= +http-not-found+ http-status-code)
      (call-next-method object
			http-status-code
			:error-code  http-status-code
			:css-file    (read-file-into-string *default-css-abs-path*)
			:path-prefix +path-prefix+)
      (call-next-method)))

(defun initialize-pictogram (name)
  (unless (crane:single 'db:ghs-pictogram :pictogram-file (namestring name))
    (save (create 'db:ghs-pictogram :pictogram-file (namestring name)))))

(defun initialize-pictograms-db ()
  (initialize-pictogram #p"data/ghs-pictograms/acid-red.eps")
  (initialize-pictogram #p"data/ghs-pictograms/skull.eps")
  (initialize-pictogram #p"data/ghs-pictograms/silhouete.eps")
  (initialize-pictogram #p"data/ghs-pictograms/aquatic-pollut-red.eps")
  (initialize-pictogram #p"data/ghs-pictograms/bottle.eps")
  (initialize-pictogram #p"data/ghs-pictograms/exclam.eps")
  (initialize-pictogram #p"data/ghs-pictograms/explos.eps")
  (initialize-pictogram #p"data/ghs-pictograms/flamme.eps")
  (initialize-pictogram #p"data/ghs-pictograms/rondflam.eps")
  (initialize-pictogram #p"data/ghs-pictograms/none.eps"))

(progn
  (open-log)
  (initialize-pictograms-db)
  (fq:init-nodes)
  (init-sensors-thread)
  (to-log :info "Server starting")
  (restas:start '#:restas.lab
		:acceptor-class 'lab-acceptor
		:hostname config:+hostname+
		:port config:+https-port+
		:ssl-certificate-file config:*ssl-certfile*
		:ssl-privatekey-file config:*ssl-key*
		:ssl-privatekey-password config:+ssl-pass+)
  (to-log :info "Server started"))
