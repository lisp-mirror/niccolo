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
   :*default-css*
   :*message-log-pathname*
   :*access-log-pathname*
   :*error-template-directory*
   :+pubchem-host+
   :+https-port+
   :+https-poxy-port+
   :+hostname+
   :+cas-server-host-name+
   :+cas-server-path-prefix+
   :+cas-service-name+
   :+path-prefix+
   :*ssl-certfile*
   :*ssl-key*
   :+ssl-pass+
   :*default-www-root*
   :*images-dir*
   :*jquery-ui-images-dir*
   :*css-dir*
   :*js-dir*
   :+images-url-path+
   :*insufficient-privileges-message*
   :*letter-header-text*
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
   :_))

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
   :+pictogram-web-image-ext+
   :+pictogram-web-image-subdir+
   :+pictogram-id-none+
   :+mime-postscript+
   :+security-warning-log-level+
   :+db-invalid-id+
   :+db-invalid-id-number+
   :+search-chem-id+
   :+search-chem-owner+
   :+search-chem-name+
   :+search-chem-building+
   :+search-chem-floor+
   :+search-chem-storage+
   :+search-chem-shelf+))

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
   :uncode
   :code-class
   :user
   :username
   :password
   :salt
   :level
   :chkpass
   :user-preferences
   :language
   :chemical-compound
   :pubchem-cid
   :msds
   :chemical-hazard
   :chemical-precautionary
   :ghs-p
   :ghs-h
   :chemical-product
   :owner
   :compound
   :storage
   :quantity
   :shelf
   :plant-map
   :description
   :data
   :loans
   :user-from
   :user-to
   :product))

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
   :+ghs-hazard-code-re+
   :+ghs-precautionary-code-re+
   :+integer-re+
   :+pos-integer-re+
   :+email-re+
   :+free-text-re+
   :+cer-code-re+
   :+adr-code-class-re+
   :+adr-uncode-re+
   :+adr-code-radioactive+
   :+barcode-id-re+
   :+waste-form-weight-re+))

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
   :find-filename-from-path))

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
     :constants)
    (:export
     :do-rows
     :fetch-raw-list
     :prepare-for-sql-like
     :keywordize-query-results
     :get-max-id
     :object-exists-in-db-p
     :query-low-level))

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
   :define-lab-route
   :get-post-filename
   :cat-salt-password
   :encode-pass
   :generate-salt
   :obj->json-string
   :plist->json
   :path-prefix-tpl
   :with-path-prefix
   :alist->query-uri
   :local-uri
   :local-uri-noport
   :gen-autocomplete-functions
   :prepare-for-update
   :with-standard-html-frame
   :fetch-raw-template-list
   :pictograms-alist
   :pictograms-template-struct
   :pictogram->preview-path
   :pictogram-preview-url
   :now-date-for-label))

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
   :search-chem-prod
   :+search-chem-id+
   :+search-chem-owner+
   :+search-chem-name+
   :+search-chem-building+
   :+search-chem-floor+
   :+search-chem-storage+
   :+search-chem-shelf+))
