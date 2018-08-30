;; niccolo': a chemicals inventory
;; Copyright (C) 2016  Universita' degli Studi di Palermo

;; This  program is  free  software: you  can  redistribute it  and/or
;; modify it  under the  terms of  the GNU  General Public  License as
;; published  by  the  Free  Software Foundation,  version  3  of  the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :restas.lab)

(define-constant +name-ghs-precautionary-expl+ "expl" :test #'string=)

(define-constant +name-ghs-precautionary-code+ "code" :test #'string=)

(defmacro gen-inadmissible-cookie-uri ((path) &body symbols)
  `(and
    ,@(loop for symbol in symbols collect
           `(not ,(if (stringp symbol)
                      `(scan ,symbol ,path)
                      `(scan (restas:genurl ',symbol) ,path))))))

(defun admissible-cookie-redirect-p (path)
  (and (cookie-key-script-visited-validate path)
       (gen-inadmissible-cookie-uri (path)
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

(defmacro define-pagination-alias (a alias-to-a)
  `(setf (gethash (restas:genurl ,a) utils:*alias-pagination*)
         (restas:genurl ,alias-to-a)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (progn
    (define-pagination-alias 'add-laboratory        'laboratory)
    (define-pagination-alias 'add-ghs-hazard        'ghs-hazard)
    (define-pagination-alias 'add-ghs-precautionary 'ghs-precautionary)
    (define-pagination-alias 'add-cer               'cer)
    (define-pagination-alias 'add-adr               'adr)
    (define-pagination-alias 'add-ghs-precautionary 'ghs-precautionary)
    (define-pagination-alias 'add-storage           'storage)
    (define-pagination-alias 'add-person            'person)
    (define-pagination-alias 'add-chemical          'chemical)))

(defun manage-welcome ()
  (with-standard-html-frame (stream (_ "Welcome"))
    (html-template:fill-and-print-template #p"welcome.tpl"
                                           (with-path-prefix
                                               :num-msg
                                             (format nil (n_ "You have ~a message"
                                                             "You have ~a messages"
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

(define-lab-route user-messages ("/messages/" :method :get)
  (with-authentication
    (with-session-user (user)
      (let* ((raw-query (get-clean-parameter +name-msg-search-query+))
             (query (and (not (string-utils:string-empty-p raw-query))
                         (clean-string raw-query))))
        (create-expiration-messages (fetch-expired-products))
        (create-validity-expired-messages (fetch-validity-expired-products))
        (create-shortage-messages (shortage-products-list (db:id user)))
        (print-messages nil nil :query query)))))

(define-lab-route storing-classify ("/storage-classify/" :method :get)
  (with-authentication
    (with-standard-html-frame (stream (_ "Classify"))
      (html-template:fill-and-print-template #p"classification-tree.tpl"
                                             (with-back-to-root '())
                                             :stream stream))))

(define-lab-route acknowledgment ("/acknowledgment" :method :get)
  (with-authentication
    (with-standard-html-frame (stream (_ "Acknowledgment"))
      (html-template:fill-and-print-template #p"acknowledgment.tpl"
                                             (with-back-to-root '())
                                             :stream stream))))

(define-lab-route legal ("/legal" :method :get)
  (with-authentication
    (with-standard-html-frame (stream (_ "Legal"))
      (html-template:fill-and-print-template #p"legal.tpl"
                                             (with-back-to-root '())
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

(defun render-main-menu (stream &key (use-animated-logo-p nil))
  (let ((template (with-path-prefix
                      :message-count-service-url (restas:genurl 'ws-get-messages-counts)
                      :message-count-key         +ws-message-count-key+
                      :has-nyan              (time-to-nyan) ;-)
                      :use-animated-logo-p   use-animated-logo-p
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
                      :manage-hp-waste-lbl   (_ "HP waste codes")
                      :manage-hp-waste       (restas:genurl 'hp-waste)
                      :carcinogenic-log-lbl  (_ "Carcinogenic usage logbook")
                      :carcinogenic-log      (restas:genurl 'carcinogenic-logbook)
                      :manage-waste-phys-state-lbl   (_ "Waste physical state")
                      :manage-waste-phys-state       (restas:genurl 'waste-phys-state)
                      :places-lbl                    (_ "Places")
                      :manage-address                (restas:genurl 'address)
                      :manage-address-lbl            (_ "Address")
                      :manage-building               (restas:genurl 'building)
                      :manage-building-lbl           (_ "Building")
                      :manage-laboratories           (restas:genurl 'laboratory)
                      :manage-laboratories-lbl       (_ "Laboratories")
                      :manage-maps                   (restas:genurl 'plant-map)
                      :manage-maps-lbl               (_ "Maps")
                      :manage-storage                (restas:genurl 'storage)
                      :manage-storage-lbl            (_ "Storage")
                      :chemical-compounds-lbl        (_ "Chemical compound")
                      :manage-chemicals              (restas:genurl 'chemical)
                      :manage-chemicals-lbl          (_ "Compound")
                      :chemical-products-lbl         (_ "Chemical products")
                      :manage-chemical-products-lbl  (_ "Managing")
                      :manage-chemical-products      (restas:genurl 'chem-prod)
                      :import-chemical-products-lbl  (_ "Import")
                      :import-chemical-products      (restas:genurl 'get-import-chem-prod)
                      :samples-lbl                   (_ "Samples")
                      :manage-samples-lbl            (_ "Manage")
                      :manage-samples                (restas:genurl 'chem-sample)
                      :users-lbl                     (_ "Users")
                      :manage-user                   (restas:genurl 'user)
                      :manage-user-lbl               (_ "Manage users")
                      :manage-user-lab               (restas:genurl 'assoc-user-lab)
                      :manage-user-lab-lbl           (_ "Associate users and laboratories")
                      :user-messages-lb              (_ "Messages")
                      :user-messages                 (restas:genurl 'user-messages)
                      :broadcast-messages-lb         (_ "Broadcast messages")
                      :broadcast-messages            (restas:genurl 'broadcast-message)
                      :user-preferences              (restas:genurl 'user-preferences)
                      :user-preferences-lbl          (_ "User preferences")
                      :change-password               (restas:genurl 'change-pass)
                      :change-password-lbl           (_ "Change password")
                      :waste-letter                  (restas:genurl 'waste-letter)
                      :waste-letter-lbl              (_ "Hazardous waste form")
                      :waste-stats                   (restas:genurl 'waste-statistics)
                      :waste-stats-lbl               (_ "Waste report")
                      :persons-lbl                   (_ "Persons")
                      :manage-person-lbl             (_ "Manage persons")
                      :manage-person                 (restas:genurl 'person)
                      :l-factor-calculator           (restas:genurl 'l-factor)
                      :l-factor-calculator-lbl       (_ "Chemical risk calculator")
                      :l-factor-calculator-snpa      (restas:genurl 'risk-snpa.l-factor-snpa)
                      :l-factor-calculator-snpa-lbl  (_ "Chemical risk calculator (snpa)")
                      :l-factor-calculator-carc      (restas:genurl 'l-factor-carc)
                      :l-factor-calculator-carc-lbl  (_ "Chemical risk calculator (carcinogenic)")
                      :l-factor-calculator-carc-snpa (restas:genurl 'risk-snpa.l-factor-carc-snpa)
                      :l-factor-calculator-carc-snpa-lbl
                      (_ "Chemical risk calculator (snpa, carcinogenic)")
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

(defun initialize-pictogram (class path)
  (unless (crane:single class :pictogram-file (namestring path))
    (save (create class :pictogram-file (namestring path)))))

(defun initialize-ghs-pictogram (path)
  (initialize-pictogram 'db:ghs-pictogram path))

(defun initialize-adr-pictogram (path)
  (initialize-pictogram 'db:adr-pictogram path))

(defun initialize-ghs-pictograms-db ()
  (initialize-ghs-pictogram #p"data/ghs-pictograms/acid-red.eps")
  (initialize-ghs-pictogram #p"data/ghs-pictograms/skull.eps")
  (initialize-ghs-pictogram #p"data/ghs-pictograms/silhouete.eps")
  (initialize-ghs-pictogram #p"data/ghs-pictograms/aquatic-pollut-red.eps")
  (initialize-ghs-pictogram #p"data/ghs-pictograms/bottle.eps")
  (initialize-ghs-pictogram #p"data/ghs-pictograms/exclam.eps")
  (initialize-ghs-pictogram #p"data/ghs-pictograms/explos.eps")
  (initialize-ghs-pictogram #p"data/ghs-pictograms/flamme.eps")
  (initialize-ghs-pictogram #p"data/ghs-pictograms/rondflam.eps")
  (initialize-ghs-pictogram #p"data/ghs-pictograms/none.eps"))

(defun initialize-adr-pictograms-db ()
  (initialize-adr-pictogram #p"data/adr-pictograms/1-1.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/1-2.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/1-3.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/1-4.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/1-5.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/1-6.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/5-2red.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/5-2red_noir.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/acide.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/blan-red.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/bleu4.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/bleu4_noir.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/jaune5-1.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/rouge2.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/rouge2_noir.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/rouge3.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/rouge3_noir.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/skull_2.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/skull6.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/stripes.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/vert_blanc-1.eps")
  (initialize-adr-pictogram #p"data/adr-pictograms/vert.eps"))

(defun init-ssl-client ()
  (when +https-client-verify-certificate+
    (setf (cl+ssl:ssl-check-verify-p) t)
    (cl+ssl:ssl-set-global-default-verify-paths)))

(defun init-db-default-values ()
  (initialize-ghs-pictograms-db)
  (initialize-adr-pictograms-db))

(restas:mount-module risk-snpa (:restas.lab.l-factor-snpa))

(defun main ()
  (init-ssl-client)
  (init-db-default-values)
  (open-log)
  (fq:init-nodes)
  ;; on some platform, for example arm  when sbcl is used, there is no
  ;; thread support
  #+thread-support (init-sensors-thread)
  (to-log :info "Server starting")
  (restas:start '#:restas.lab
                :acceptor-class 'lab-acceptor
                :hostname config:+hostname+
                :port config:+https-port+
                :ssl-certificate-file config:*ssl-certfile*
                :ssl-privatekey-file config:*ssl-key*
                :ssl-privatekey-password config:+ssl-pass+)
  (to-log :info "Server started"))
