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

(in-package :db)

(defgeneric build-description (object))

(deftable plant-map ()
  (description
   :type text
   :nullp nil)
  (data
   :type text
   :nullp nil))

(deftable address ()
  (line-1
   :type text
   :nullp nil)
  (city
   :type text
   :nullp nil)
  (zipcode
   :type text
   :nullp nil)
  (link
   :type text
   :nullp t))

(defgeneric build-complete-address (object))

(defmethod build-complete-address ((object address))
  (concatenate 'string (line-1 object) " " (zipcode object) " " (city object)))

(defmethod build-description ((object address))
  (build-complete-address object))

(deftable building ()
  (name
   :type text
   :nullp nil)
  (address-id
   :type integer
   :foreign (address :restrict :cascade)))

(defmethod build-description ((object building))
  (format nil "~a ~a"
	  (name object)
	  (build-complete-address (single 'address :id (address-id object)))))

(deftable storage ()
  (name
   :type text
   :nullp nil)
  (building-id
   :type integer
   :foreign (building :restrict :cascade))
  (floor-number
   :type text
   :nullp nil)
  (map-id
   :type integer
   :foreign (plant-map)
   :nullp t)
  (safe-storage-type
   :type text
   :nullp t)
  (s-coord
   :type integer
   :nullp nil)
  (t-coord
   :type integer
   :nullp nil))

(deftable ghs-pictogram ()
  (pictogram-file
   :type text
   :nullp nil
   :uniquep t))

(deftable ghs-hazard-statement ()
  (code
   :type text
   :nullp nil
   :uniquep t)
  (explanation
   :type text
   :nullp nil)
  (carcinogenic
   :type text
   :nullp nil
   :default 0)
  (pictogram
   :type integer
   :nullp t
   :foreign (ghs-pictogram :restrict :cascade)))

(defgeneric build-carcinogenic-description (object))

(defmethod build-carcinogenic-description ((object ghs-hazard-statement))
  (if (string= (carcinogenic object) +ghs-carcinogenic-code+)
      "Carcinogenic according IARC"
      ""))

(defmethod build-description ((object ghs-hazard-statement))
  (format nil "~a ~a ~@[(~a)~] ~a" (code object) (explanation object) (carcinogenic object)
	  (build-carcinogenic-description object)))

(deftable cer-code ()
  (code
   :type text
   :nullp nil
   :uniquep t)
  (explanation
   :type text
   :nullp nil))

(deftable adr-code ()
  (uncode
   :type text
   :nullp nil
   :uniquep t)
  (code-class
   :type text
   :nullp nil
   :uniquep nil)
  (explanation
   :type text
   :nullp nil))

(deftable ghs-precautionary-statement ()
  (code
   :type text
   :nullp nil
   :uniquep t)
  (explanation
   :type text
   :nullp nil))

(defmethod build-description ((object ghs-precautionary-statement))
  (format nil "~a ~a" (code object) (explanation object)))

(deftable chemical-compound ()
  (name
   :type text
   :nullp nil
   :uniquep t)
  (pubchem-cid
   :type text
   :nullp t)
  (msds
   :type text
   :nullp t))

(deftable user ()
  (username
   :type text
   :nullp nil)
  (email
   :type text
   :nullp nil)
  (salt
   :type text
   :nullp nil)
  (password
   :type text
   :nullp nil)
  (account-enabled
   :type integer
   :default 1
   :nullp nil)
  (level
   :type integer
   :nullp nil))

(defgeneric chkpass (object pass))

(defmethod chkpass ((object user) pass)
  (string=
   (db:password object)
   (utils:encode-pass (db:salt object) pass)))

(deftable user-preferences ()
  (owner
   :type integer
   :foreign (user :restrict :cascade))
  (language
   :type text))

(deftable chemical-product ()
  (compound
   :type integer
   :foreign (chemical-compound :restrict :cascade))
  (storage
   :type integer
   :foreign (storage :restrict :cascade))
  (quantity
   :type integer
   :nullp nil)
  (units
   :type text
   :nullp nil)
  (validity-date
   :type timestamp
   :nullp nil)
  (expire-date
   :type timestamp
   :nullp nil)
  (shelf
   :type integer
   :nullp nil)
  (owner
   :type integer
   :foreign (user :restrict :cascade))
  (notes
   :type text
   :nullp t))

(deftable chemical-compound-preferences ()
  (owner
   :type integer
   :foreign (user :restrict :cascade))
  (compound
   :type integer
   :foreign (chemical-compound :restrict :cascade))
  (shortage
   :type integer))

(deftable chemical-hazard ()
  (ghs-h
   :type integer
   :foreign (ghs-hazard-statement :restrict :cascade))
  (compound-id
   :type integer
   :foreign (chemical-compound :restrict :cascade)))

(deftable chemical-precautionary ()
  (ghs-p
   :type integer
   :foreign (ghs-precautionary-statement :restrict :cascade))
  (compound-id
   :type integer
   :foreign (chemical-compound :restrict :cascade)))

(deftable loans ()
  (product
   :type integer
   :foreign (chemical-product :restrict :cascade))
  (user-from
   :type integer
   :foreign (user :restrict :cascade))
  (user-to
   :type integer
   :foreign (user :restrict :cascade)))

(deftable message ()
  (sender
   :type integer
   :foreign (user :restrict :cascade)
   :nullp nil)
  (recipient
   :type integer
   :foreign (user :restrict :cascade)
   :nullp nil)
  (echo-to
   :type integer
   :foreign (message :restrict :cascade)
   :nullp t)
  (status
   :type text
   :nullp nil)
  (sent-time
   :type timestamp
   :nullp nil)
  (subject
   :type text
   :nullp nil)
  (text
   :type text))

(deftable message-relation ()
  (node
   :type integer
   :foreign (message :restrict :cascade)
   :nullp nil)
  (parent
   :type integer
   :foreign (message :restrict :cascade)
   :nullp t)
  (child
   :type integer
   :foreign (message :restrict :cascade)
   :nullp t))

(deftable expiration-message ()
  (message
   :type integer
   :foreign (message :cascade :cascade)
   :nullp nil)
  (product
   :type integer
   :foreign (chemical-product :set-null :cascade)))

(deftable validity-expired-message ()
  (message
   :type integer
   :foreign (message :cascade :cascade)
   :nullp nil)
  (product
   :type integer
   :foreign (chemical-product :set-null :cascade)))

(deftable compound-shortage-message ()
  (message
   :type integer
   :foreign (message :cascade :cascade)
   :nullp nil)
  (compound
   :type integer
   :foreign (chemical-compound :set-null :cascade)))

(deftable waste-message ()
  (message
   :type integer
   :foreign (message :cascade :cascade))
  (cer-code-id
   :type integer
   :foreign (cer-code :restrict :cascade))
  (building-id
   :type integer
   :foreign (building :restrict :cascade))
  (weight
   :type integer
   :nullp nil))

(deftable waste-message-adr ()
  (waste-message
   :type integer
   :foreign (waste-message :cascade :cascade))
  (adr-code-id
   :type integer
   :foreign (adr-code :restrict :cascade)
   :nullp nil))

(deftable sensor ()
  (session-nonce
   :type text)
  (map-id
   :type integer
   :foreign (plant-map :restrict :cascade))
  (address
   :type text
   :nullp nil)
  (path
   :type text
   :nullp nil)
  (description
   :type text
   :nullp nil)
  (secret
   :type text
   :nullp nil)
  (status
   :type text
   :nullp nil)
  (last-access-time
   :type timestamp)
  (last-value
   :type text)
  (script-file
   :type text
   :nullp nil)
  (s-coord
   :type integer
   :nullp nil)
  (t-coord
   :type integer
   :nullp nil))
