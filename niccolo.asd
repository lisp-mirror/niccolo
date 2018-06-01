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

(asdf:defsystem :niccolo
  :description "Chemicals inventory"
  :author "cage <cage@katamail.com>"
  :version "1.0.0-RC1"
  :license "GPLv3"
  :depends-on (#-asdf3 :uiop
               :alexandria
               :cl-ppcre-unicode
               :trivial-timeout
               :bordeaux-threads
               :cl-lex
               :yacc
               :dbi
               :envy
               :crane
               :local-time
               :cl-smtp
               :sanitize
               :parse-number
               :html-template
               :osicat
               :xmls
               :log4cl
               :cl-base64
               :ironclad
               :cl-who
               :cl-json
               :cl-i18n
               :flexi-streams
               :cl-csv
               :cl-gd
               :cl-pslib
               :cl-pslib-barcode
               :drakma
               :puri
               :hunchentoot
               :restas
               :restas-directory-publisher
               #+mini-cas :mini-cas)
  :serial t
  :components ((:file "package")
               (:file "config")
               (:file "constants")
               (:file "conditions")
               (:file "xml-utils")
               (:file "configuration-utils")
               (:file "general-routes")
               (:file "math-utils")
               (:file "string-utils")
               (:file "molecule")
               (:file "molfile")
               (:file "validation")
               (:file "ps-utils")
               (:file "db-utils")
               (:file "db-config")
               (:file "db")
               (:file "session-user")
               (:file "utils")
               (:file "i18n")
               (:file "images-utils")
               (:file "risk-phrases")
               (:file "risk-calculator-const")
               (:file "risk-calculator")
               (:file "risk-calculator-snpa")
               (:file "authentication")
               (:file "views")
               (:file "messages")
               (:file "address")
               (:file "update-address")
               (:file "building")
               (:file "update-building")
               (:file "ghs-haz")
               (:file "update-ghs-hazard")
               (:file "ghs-precautionary")
               (:file "update-ghs-precautionary")
               (:file "cer-codes")
               (:file "adr-codes")
               (:file "hp-codes")
               (:file "update-hp-codes")
               (:file "waste-physical-state")
               (:file "update-waste-physical-state")
               (:file "map")
               (:file "update-map")
               (:file "chemical-compound")
               (:file "update-chemical-compound")
               (:file "assoc-chem-prec")
               (:file "assoc-chem-haz")
               (:file "assoc-chem-haz-prec-federated-query")
               (:file "storage")
               (:file "update-storage")
               (:file "user")
               (:file "chemical-product")
               (:file "update-chemical-product")
	       (:file "laboratory")
	       (:file "assoc-user-lab")
	       (:file "sample")
	       (:file "update-sample")
               (:file "waste-letter")
               (:file "waste-stats")
               (:file "sensors")
               (:file "l-factor")
               (:file "l-factor-snpa")
               (:module federated-query
                        :components ((:file "query-id")
                                     (:file "nodes")
                                     (:file "status-visited")
                                     (:file "query-object")
                                     (:file "result-products")))
               (:file "services")
               (:file "lab")))
