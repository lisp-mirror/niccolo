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
   :*risk-phrases*
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
   :*working-temp-carc-snpa*
   :*quantity-carc*
   :*exposition-time-carc*
   :*frequency-carc*
   :*exposition-carc*
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
   :+waste-manager-acl-level+
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
   :+default-ttf-font-name+
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
   :+name-opening-date+
   :+start-pagination-offset+
   :+name-count-pagination+
   :+name-op-pagination+
   :+name-count-pagination-inc+
   :+name-count-pagination-dec+
   :+name-op-pagination-inc+
   :+name-op-pagination-dec+
   :+no-html-tags-at-all+
   :+html-tags-text-minimal-formatting+
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
   :define-conffile-writer
   :get-leaf))

(defpackage :configuration-utils
  (:use :cl
        :alexandria
        :xmls
        :xml-utils)
  (:export
   :define-conffile-reader
   :define-conffile-writer
   :parse-simple-config
   :get-config-val))

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
   :generate-ps-custom-label
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
   :haz-color
   :fire-color
   :reactive-color
   :corrosive-color
   :pubchem-cid
   :other-cid
   :msds
   :structure-file
   :chemical-hazard
   :chemical-precautionary
   :ghs-p
   :ghs-h
   :laboratory
   :complete-name
   :chemical-product
   :validity-date
   :expire-date
   :opening-package-date
   :owner
   :notes
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
   :chemical-sample
   :person-id
   :compliantp
   :laboratory-id
   :checkin-date
   :checkout-date
   :owner-user-db-object
   :with-owner-object
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
   :script-file
   :person
   :surname
   :organization
   :official-id
   :chemical-usage-tracking
   :chemical-id
   :chemical-tracking-data
   :tracking-id
   :track-date
   :track-type))

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
   :id-valid-and-used-p
   :with-id-valid-and-used
   :integer-validate
   :date-validate-p
   :magic-validate-p
   :png-validate-p
   :pdf-validate-p
   :sdf-validate-p
   :other-registry-number-validate-p
   :integer-%-validate
   :integer-positive-validate
   :cookie-key-script-visited-validate
   :user-level-validate-p
   :strip-tags
   :strip-tags-relaxed
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
   :+waste-registration-number-re+
   :+laboratory-name-re+
   :+sample-name-re+))

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
   :fm*
   :*default-epsilon*
   :with-epsilon
   :add-epsilon-rel
   :epsilon<=
   :epsilon>=
   :epsilon=))

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
   :escape-csv-field
   :words
   :lines
   :escape-string-all-but-double-quotes
   :escape-string-all-but-ampersand
   :escape-string-all-but-single-quotes
   :add-slashes
   :ellipsize
   :safe-parse-number))

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
   :parse-mdl
   :parse-mdl-catch-errors))

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
   :with-save-restore
   :render-simple-label
   :render-chemprod-barcode-x-y
   :+a4-landscape-page-sizes+
   :with-a4-lanscape-ps-doc
   :with-a4-ps-doc
   :with-custom-size-ps-doc
   :default-font
   :render-many-chemprod-barcodes
   :render-many-sample-barcodes))

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

(defpackage :session-user
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :hunchentoot
   :crane
   :config
   :constants)
  (:export
   :+user-private-pagination-offset+
   :+user-private-pagination-count+
   :user-session
   :authorized
   :authorized-p
   :private-storage
   :user->user-session
   :user-session->user
   :get-session-username
   :with-session-user
   :get-session-user-id
   :admin-id
   :admin-user
   :waste-manager-id
   :get-session-level
   :session-admin-p
   :session-waste-manager-p
   :account-enabled-p))

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
   :filter-all-get-params
   :filter-all-post-params
   :get-parameter-non-nil-p
   :get-post-filename
   :get-clean-parameter
   :get-clean-parameter-relaxed
   :get-clean-parameters*
   :post-clean-parameter
   :post-parameter-notags
   :post-clean-parameters*
   :source-origin-header
   :target-origin-header
   :check-origin-target
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
   :with-pagination-template
   :default-pagination-start
   :default-pagination-count
   :with-back-uri
   :with-back-to-root
   :alist->query-uri
   :local-uri
   :local-uri-noport
   :remote-uri
   :delete-uri
   :address-string->vector
   :get-host-by-address
   :get-host-by-name
   :gen-autocomplete-functions
   :prepare-for-update
   :set-cookie-script-visited
   :slice-for-pagination
   :actual-pagination-start
   :actual-pagination-count
   :pagination-bounds
   :*alias-pagination*
   :session-pagination-start
   :session-pagination-count
   :session-pagination-increase
   :session-pagination-decrease
   :with-pagination
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
   :format-time
   :format-time*
   :send-email
   :init-hashtable-equalp
   :temp-filename
   :open-log
   :to-log
   :log-and-mail
   :with-http-ignored-errors
   :load-values-discrete-ranges
   :get-value-discrete-range))

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
   :with-http-png-reply
   :draw-hazard-diamond))

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
   :+devices-root+
   :+exposition-time-el-root+
   :+physical-state-carc-el-root+
   :+devices-collective-el-root+
   :+work-type-root+
   :+usage-el-root+
   :+yes+
   :+no+
   :+closed-opened-sometimes+
   :+aspiration+
   :+managing-chemical-compatibility+
   :+good-fume-cupboard-rel+
   :+bad-fume-cupboard-rel+
   :+no-fume-cupboard-rel+
   :+dpi-vest+
   :+all-operations-with-good-fume-cupboard+
   :+some-operations-with-good-fume-cupboard+
   :+inefficient-fume-cupboard+
   :+quantity-el+
   :+frac-canc-l-carc-snpa+
   :*errors*
   :*exposition-table*
   :*physical-state-table*
   :*exposition-time-table*
   :*quantity-table*
   :*usage-table*
   :*work-table*
   :*devices-table*
   :*physical-state-carc-table*
   :*quantity-carc-table*
   :*device-carc-table*
   :*exposition-carc-table*
   :*frequency-carc-table*
   :read-exposition-type-config
   :read-physical-state-config
   :read-exposition-time-carc-config
   :read-usage-freq-carc-config
   :get-graph-quantity
   :*traslation-keys-table*
   :read-threshold-value-xml
   :untranslate
   :r-factor
   :t-factor
   :s-factor
   :e-factor
   :u-factor
   :q-factor
   :a-factor
   :k-factor
   :s-factor-carc
   :p-factor-carc-extract
   :q-factor-carc
   :e-factor-carc
   :f-factor-carc
   :l-factor-i
   :l-factor-carc-i))

(defpackage :risk-calculator-snpa
  (:use :cl
        :alexandria
        :xmls
        :parse-number
        :config
        :configuration-utils
        :risk-calculator
        :risk-phrases)
  (:export
   :l-factor-i-snpa
   :l-factor-carc-i-snpa))

(restas:define-module :restas.lab.l-factor-snpa
  (:use
   :cl
   :alexandria
   :cl-ppcre
   :hunchentoot
   :crane
   :config
   :constants
   :validation
   :string-utils
   :db-utils
   :utils
   :views)
  (:nicknames :l-fact-snpa)
  (:export
   :select-usage
   :select-quantity-stocked
   :select-work-type
   :select-exp-time-type
   :select-protection-factors
   :l-factor-snpa
   :l-factor-carc-snpa))

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
   :session-user
   :utils
   :views)
  (:export
   :%select-builder
   :with-authentication
   :array-autocomplete-chemical-compound
   :array-autocomplete-chemical-compound-id
   :render-logout-control
   :render-main-menu
   :search-chem-prod
   :+search-chem-id+
   :+search-chem-owner+
   :+search-chem-name+
   :+search-chem-building+
   :+search-chem-floor+
   :+search-chem-storage+
   :+search-chem-shelf+
   ;; risk
   :select-phys-state
   :fetch-all-ghs
   :sort-all-ghs-tpl
   ;; urls
   :ws-l-factor-i-snpa-url
   :ws-l-factor-carc-i-snpa-url))

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
