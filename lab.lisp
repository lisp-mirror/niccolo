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

(define-constant +name-ghs-precautionary-expl+         "expl" :test #'string=)

(define-constant +name-ghs-precautionary-code+         "code" :test #'string=)

(define-lab-route root ("/" :method :get)
  #+mini-cas
  (if (hunchentoot:parameter mini-cas:+query-ticket-key+)
      (progn
	(check-with-cas-authenticate () nil)
	(restas:redirect 'root))
      (authenticate (nil nil)
	(with-standard-html-frame (stream "Welcome"))))
  #-mini-cas
    (authenticate (nil nil)
      (with-standard-html-frame (stream "Welcome"))))

(define-lab-route root-login ("/login" :method :post)
  (authenticate ((hunchentoot:parameter +auth-name-login-name+)
		 (hunchentoot:parameter +auth-name-login-password+))
    (with-standard-html-frame (stream "Welcome"))))

(define-lab-route storing-classify ("/storage-classify/" :method :get)
  (authenticate ((hunchentoot:parameter +auth-name-login-name+)
		 (hunchentoot:parameter +auth-name-login-password+))
    (with-standard-html-frame (stream "Classify")
      (html-template:fill-and-print-template #p"classification-tree.tpl"
					     nil
					     :stream stream))))

(define-lab-route acknowledgment ("/acknowledgment" :method :get)
  (authenticate ((hunchentoot:parameter +auth-name-login-name+)
		 (hunchentoot:parameter +auth-name-login-password+))
    (with-standard-html-frame (stream "Acknowledgment")
      (html-template:fill-and-print-template #p"acknowledgment.tpl"
					     nil
					     :stream stream))))

(define-lab-route legal ("/legal" :method :get)
  (authenticate ((hunchentoot:parameter +auth-name-login-name+)
		 (hunchentoot:parameter +auth-name-login-password+))
    (with-standard-html-frame (stream "Acknowledgment")
      (html-template:fill-and-print-template #p"legal.tpl"
					     nil
					     :stream stream))))

(defun time-to-nyan ()
  (let ((decoded (multiple-value-list (get-decoded-time))))
    (and (= (elt decoded 4) 4)
	 (= (elt decoded 3) 1))))

(defun render-main-menu (stream)
  (let ((template (with-path-prefix
		      :has-nyan              (time-to-nyan) ;-)
		      :session-username      (format nil "(~a)"
						     (get-session-username))
		      :logout-link           (with-session-user (user)
					       (if user
						   (restas:genurl 'logout)
						   nil))
		      :login-link           (with-session-user (user)
					      (if (not user)
						  #+mini-cas (cas-login-uri)
						  #-mini-cas (restas:genurl 'logout)
						  nil))
		      :manage-ghs-hazard     (restas:genurl 'ghs-hazard)
		      :manage-ghs-precaution (restas:genurl 'ghs-precautionary)
		      :manage-cer            (restas:genurl 'cer)
		      :manage-adr            (restas:genurl 'adr)
		      :manage-address        (restas:genurl 'address)
		      :manage-building       (restas:genurl 'building)
		      :manage-maps           (restas:genurl 'plant-map)
		      :manage-storage        (restas:genurl 'storage)
		      :manage-chemicals      (restas:genurl 'chemical)
		      :manage-chemical-products (restas:genurl 'chem-prod)
		      :manage-user           (restas:genurl 'user)
		      :change-password       (restas:genurl 'change-pass)
		      :waste-letter          (restas:genurl 'waste-letter)
		      :l-factor-calculator   (restas:genurl 'l-factor)
		      :l-factor-calculator-carc (restas:genurl 'l-factor-carc)
		      :store-classify-tree (restas:genurl 'storing-classify))))
    (html-template:fill-and-print-template #p"main-menu.tpl"
					   template
					   :stream stream)))

;; start the server

(defclass lab-acceptor (restas:restas-ssl-acceptor) ()
  (:default-initargs
   :error-template-directory *error-template-directory*
   :message-log-destination  *message-log-pathname*
   :access-log-destination  *access-log-pathname*
   :document-root          config:*default-www-root*))

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
  (initialize-pictograms-db)
  (restas:start '#:restas.lab
		:acceptor-class 'lab-acceptor
		:hostname config:+hostname+
		:port config:+https-port+
		:ssl-certificate-file config:*ssl-certfile*
		:ssl-privatekey-file config:*ssl-key*
		:ssl-privatekey-password config:+ssl-pass+))
