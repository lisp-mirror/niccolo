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

(defpackage :config
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :envy
   :hunchentoot
   :crane)
  (:export
   :+program-name+
   :local-system-path
   :+openstreetmap-query-url+
   :*default-css-abs-path*
   :*default-css-filename*
   :*message-log-pathname*
   :*access-log-pathname*
   :*error-template-directory*
   :+pubchem-host+
   :+https-port+
   :+https-proxy-port+
   :+hostname+
   :+cas-server-host-name+
   :+cas-server-path-prefix+
   :+cas-service-name+
   :+path-prefix+
   :*ssl-certfile*
   :*ssl-key*
   :+ssl-pass+
   :+https-client-verify-certificate+
   :+use-smtp+
   :+smtp-host+
   :+smtp-from-address+
   :+smtp-port-address+
   :+smtp-autentication+
   :+smtp-ssl+
   :+smtp-subject-mail-prefix+
   :+federated-query-enabled+
   :+federated-query-key+
   :+federated-query-nodes-file+
   :*sensors-script-dir*
   :*sensor-log-dir*
   :*default-www-root*
   :*images-dir*
   :*jquery-ui-images-dir*
   :+spreadsheet-tpl-dir+
   :*css-dir*
   :*js-dir*
   :+images-url-path+
   :*insufficient-privileges-message*
   :*letter-header-text*
   :*waste-letter-body*
   :*risk_phrases*
   :*exposition-type*
   :*physical-state*
   :*exposition-time*
   :*usage*
   :*quantity*
   :*stock*
   :*work*
   :*devices*
   :*devices-carc*
   :*physical-state-carc*
   :*working-temp-carc*
   :*quantity-carc*
   :*exposition-time-carc*
   :*frequency-carc*
   :_
   :n_))

(defpackage :constants
  (:use
   :cl
   :alexandria)
  (:export
   :+ghs-carcinogenic-code+
   :+relative-coord-scaling+
   :+relative-circle-size+
   :+admin-name+
   :+admin-acl-level+
   :+user-acl-level+
   :+editor-acl-level+
   :+user-account-enabled+
   :+user-session+
   :+auth-name-login-name+
   :+auth-name-login-password+
   :+salt-byte-length+
   :+page-margin-top+
   :+page-margin-left+
   :+data-path+
   :+image-unknown-struct-path+
   :+letter-header+
   :+default-font-name+
   :+header-image-export-height+
   :+header-image-export-width+
   :+pictogram-web-image-ext+
   :+ghs-pictogram-web-image-subdir+
   :+adr-pictogram-web-image-subdir+
   :+pictogram-phys-size+
   :+pictogram-id-none+
   :+mime-postscript+
   :+mime-pdf+
   :+mime-sdf+
   :+mime-csv+
   :+security-warning-log-level+
   :+db-invalid-id+
   :+db-invalid-id-number+
   :+search-chem-id+
   :+search-chem-owner+
   :+search-chem-name+
   :+search-chem-building+
   :+search-chem-floor+
   :+search-chem-storage+
   :+search-chem-shelf+
   :+name-validity-date+
   :+name-expire-date+
   :+name-start-pagination+
   :+no-html-tags-at-all+
   :+cookie-key-script-visited+
   :+query-product-path+
   :+query-compound-hazard-path+
   :+post-federated-query-results+
   :+query-visited+
   :+query-http-parameter-key+
   :+query-http-response-key+))

(defpackage :conditions
  (:use :cl)
  (:export
   :not-implemented-error
   :null-reference
   :out-of-bounds
   :length-error
   :different-length-error)
  (:export
   :text))

(defpackage :xml-utils
  (:use :cl
	:alexandria
	:xmls
	:parse-number)
  (:export
   :with-tagmatch
   :with-tagmatch-if-else
   :with-attribute
   :get-list-tags-value
   :define-conffile-reader
   :define-conffile-writer))

(defpackage :configuration-utils
  (:use :cl
	:alexandria
	:xmls)
  (:export
   :define-conffile-reader
   :define-conffile-writer))

(defpackage :db
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :envy
   :crane
   :constants)
  (:export
   :build-description
   :id
   :building
   :address
   :line-1
   :city
   :zipcode
   :link
   :build-complete-address
   :building
   :name
   :address-id
   :storage
   :name
   :building-id
   :floor-number
   :map-id
   :s-coord
   :t-coord
   :ghs-pictogram
   :pictogram-file
   :ghs-hazard-statement
   :code
   :explanation
   :carcinogenic
   :pictogram
   :ghs-precautionary-statement
   :cer-code
   :adr-code
   :adr-pictogram
   :uncode
   :code-class
   :hp-waste-code
   :waste-physical-state
   :user
   :email
   :username
   :account-enabled
   :password
   :salt
   :level
   :chkpass
   :user-preferences
   :language
   :chemical-compound
   :pubchem-cid
   :msds
   :structure-file
   :chemical-hazard
   :chemical-precautionary
   :ghs-p
   :ghs-h
   :chemical-product
   :validity-date
   :expire-date
   :owner
   :compound
   :storage
   :quantity
   :units
   :shelf
   :chemical-compound-preferences
   :shortage
   :plant-map
   :description
   :data
   :loans
   :user-from
   :user-to
   :product
   :message
   :sender
   :recipient
   :echo-to
   :sent-time
   :subject
   :status
   :text
   :message-relation
   :node
   :parent
   :child
   :expiration-message
   :validity-expired-message
   :waste-message
   :registration-number
   :compound-shortage-message
   :message
   :cer-code-id
   :building-id
   :weight
   :waste-message-adr
   :waste-message-hp
   :waste-message
   :adr-code-id
   :sensor
   :session-nonce
   :path
   :secret
   :last-access-time
   :last-value
   :script-file))

(defpackage :validation
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :crane
   :config
   :constants)
  (:export
   :all-not-null-p
   :all-null-p
   :regexp-validate
   :unique-p-validate
   :unique-p-validate*
   :exists-with-different-id-validate
   :integer-validate
   :date-validate-p
   :magic-validate-p
   :png-validate-p
   :pdf-validate-p
   :sdf-validate-p
   :integer-%-validate
   :integer-positive-validate
   :cookie-key-script-visited-validate
   :user-level-validate-p
   :strip-tags
   :+ghs-hazard-code-re+
   :+ghs-precautionary-code-re+
   :+hp-waste-code-re+
   :+integer-re+
   :+pos-integer-re+
   :+email-re+
   :+free-text-re+
   :+internet-address-re+
   :+script-file-re+
   :+cer-code-re+
   :+adr-code-class-re+
   :+adr-uncode-re+
   :+adr-code-radioactive+
   :+barcode-id-re+
   :+waste-form-weight-re+
   :+federated-query-product-re+
   :+federated-query-id-re+
   :+waste-registration-number-re+))

(defpackage :math-utils
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :config
   :constants)
  (:export
   ;; matrix
   :fmatrix
   :make-fmatrix
   :fmref
   :fm-w
   :fm-h
   :fm=
   :fm-row
   :fm-column
   :make-same-dimension-fmatrix
   :fm-loop
   :fm-map
   :fm-flat-copy
   :fm-transpose
   :fm*))

(defpackage :string-utils
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :config
   :constants)
  (:export
   :clean-string
   :string-empty-p
   :base64-encode
   :base64-decode
   :sha-encode->string
   :encode-barcode
   :find-filename-from-path
   :random-password
   :escape-csv-field))

(defpackage :molecule
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :parse-number
   :config
   :constants
   :math-utils)
  (:export
   :ch-atom
   :charge
   :label
   :x
   :y
   :z
   :molecule
   :atoms
   :connections
   :valence
   :atom@
   :bond-types-count
   :permutation-matrix
   :subgraph-isomorphism))

(defpackage :molfile
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :parse-number
   :config
   :constants
   :math-utils
   :molecule)
  (:export
   :parse-mdl))

(defpackage :ps-utils
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :cl-pslib
   :config
   :constants)
  (:shadowing-import-from :cl-pslib :rotate)
  (:export
   :render-barcode-x-y
   :with-save-restore
   :+a4-landscape-page-sizes+
   :with-a4-lanscape-ps-doc
   :with-a4-ps-doc
   :default-font
   :render-many-barcodes))

(defpackage :db-utils
    (:use
     :cl
     :alexandria
     :cl-ppcre
     :config
     :constants
     :crane)
    (:export
     :do-rows
     :fetch-raw-list
     :prepare-for-sql-like
     :keywordize-query-results
     :get-max-id
     :object-exists-in-db-p
     :query-low-level
     :db-nil-p
     :if-db-nil-else
     :count-all
     :get-column-from-id))

(defpackage :db-config
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :envy
   :hunchentoot
   :crane))

(defpackage :utils
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :hunchentoot
   :crane
   :config
   :constants)
  (:export
   :+uri-query-start+
   :define-lab-route
   :get-post-filename
   :cat-salt-password
   :encode-pass
   :generate-salt
   :obj->json-string
   :json-string->obj
   :plist->json
   :json->list
   :chemical-products-template->json-string
   :path-prefix-tpl
   :with-path-prefix
   :with-back-uri
   :with-back-to-root
   :alist->query-uri
   :local-uri
   :local-uri-noport
   :remote-uri
   :address-string->vector
   :get-host-by-address
   :get-host-by-name
   :gen-autocomplete-functions
   :prepare-for-update
   :set-cookie-script-visited
   :with-standard-html-frame
   :fetch-raw-template-list
   :template->string
   :pictograms-alist
   :pictograms-template-struct
   :pictogram->preview-path
   :pictogram-preview-url
   :now-date-for-label
   :encode-datetime-string
   :decode-datetime-string
   :decode-date-string
   :decode-time-string
   :local-time-obj-now
   :next-expiration-date
   :waste-message-expired-p
   :timestamp-compare-desc
   :timestamp-compare-asc
   :remove-old-waste-stats
   :send-email
   :init-hashtable-equalp
   :temp-filename
   :open-log
   :to-log
   :log-and-mail
   :with-http-ignored-errors))

(defpackage :i18n
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :config
   :constants)
  (:export
   :*availables-translations*
   :translation
   :translation-description
   :translation-table
   :translation-select-options
   :find-translation
   :with-user-translation))

(defpackage :images-utils
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :config
   :constants)
  (:export
   :fill-bg
   :draw-graph-x-axe
   :draw-graph-point-norm
   :draw-graph
   :with-http-png-reply))

(defpackage :views
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :hunchentoot
   :crane
   :config
   :constants
   :db
   :utils)
  (:export
   :json-all-storage-long-desc))

(defpackage :risk-phrases
  (:use :cl
	:xmls
	:xml-utils
	:parse-number)
  (:export
   :+phrases-el+
   :+label-el+
   :+phrase-el+
   :+explanation-el+
   :+points-el+
   :load-db
   :*phrases-database*
   :get-points
   :get-entry-error
   :get-entry))

(defpackage :risk-calculator
  (:use :cl
	:alexandria
	:xmls
	:parse-number
	:config)
  (:export
   :*errors*
   :l-factor-i
   :l-factor-carc-i))

(restas:define-module :restas.lab
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :hunchentoot
   :crane
   :config
   :constants
   :validation
   :ps-utils
   :string-utils
   :db-utils
   :utils
   :views)
  (:export
   :render-logout-control
   :render-main-menu
   :search-chem-prod
   :+search-chem-id+
   :+search-chem-owner+
   :+search-chem-name+
   :+search-chem-building+
   :+search-chem-floor+
   :+search-chem-storage+
   :+search-chem-shelf+))

(defpackage :federated-query
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :hunchentoot
   :crane
   :config
   :constants
   :validation
   :ps-utils
   :string-utils
   :db-utils
   :utils
   :views)
  (:nicknames :fq)
  (:export
   :all-nodes
   :node
   :init-nodes
   :find-node
   :check-credentials
   :with-credentials
   :with-valid-key
   :request
   :origin-host
   :origin-host-port
   :id
   :key
   :send-query
   :send-response
   :federated-query-product
   :federated-query-chemical-hazard
   :federated-query
   :query-visited-p
   :set-visited
   :clear-visited
   :response
   :make-query-product-response
   :make-query-product
   :make-query-chem-compound
   :make-query-chem-compound-response
   :make-visited-response
   :get-raw-results
   :get-serialized-results
   :enqueue-results
   :clear-db))
