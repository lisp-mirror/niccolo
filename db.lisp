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

(in-package :db)

(defgeneric build-description (object))

(defgeneric generate-ps-custom-label (object &key &allow-other-keys))

(defgeneric owner-user-db-object (object))

(defmethod owner-user-db-object (object)
  (and (owner object)
       (db-utils:db-single 'user :id (owner object))))

(defmacro with-owner-object ((owner object) &body body)
  `(let ((,owner (and ,object (db:owner-user-db-object ,object))))
     ,@body))

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
          (build-complete-address (db-utils:db-single 'address :id (address-id object)))))

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
   :uniquep nil))

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

(defgeneric carcinogenic-iarc-p (object))

(defgeneric build-carcinogenic-description (object))

(defmethod carcinogenic-iarc-p ((object string))
  (cl-ppcre:scan +ghs-carcinogenic-code+ object))

(defmethod carcinogenic-iarc-p ((object ghs-hazard-statement))
  (carcinogenic-iarc-p (carcinogenic object)))

(defmethod build-carcinogenic-description ((object ghs-hazard-statement))
  (if (carcinogenic-iarc-p (carcinogenic object))
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

(deftable adr-pictogram ()
  (pictogram-file
   :type text
   :nullp nil
   :uniquep nil))

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
   :nullp nil)
  (pictogram
   :type integer
   :nullp t
   :foreign (adr-pictogram :restrict :cascade)))

(deftable hp-waste-code ()
  (code
   :type text
   :nullp nil
   :uniquep t)
  (explanation
   :type text
   :nullp nil)
  (pictogram
   :type integer
   :nullp t
   :foreign (ghs-pictogram :restrict :cascade)))

(deftable waste-physical-state ()
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
  (other-cid
   :type text
   :nullp t)
  (msds
   :type text
   :nullp t)
  (structure-file
   :type text
   :nullp t)
  (haz-color
   :type  text
   :nullp t)
  (fire-color
   :type  text
   :nullp t)
  (reactive-color
   :type  text
   :nullp t)
  (corrosive-color
   :type  text
   :nullp t))

(defmethod carcinogenic-iarc-p ((object chemical-compound))
  (let ((all-h (mapcar #'(lambda (a) (db-utils:db-single 'ghs-hazard-statement :id (ghs-h a)))
                       (db-utils:db-filter 'chemical-hazard :compound-id (id object)))))
    (remove-if-not #'carcinogenic-iarc-p all-h)))

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
   :foreign (user :cascade :cascade))
  (language
   :type text))

(deftable person ()
  (address-id
    :type integer
    :foreign (address :restrict :cascade))
   (name
    :type text
    :nullp nil)
   (surname
    :type text
    :nullp nil)
   (organization
    :type text
    :nullp nil)
   (official-id
    :type text
    :nullp nil)
   (email
    :type text
    :nullp t))

(defmethod build-description ((object person))
  (format nil "~a ~a, ~a" (name object) (surname object) (organization object)))

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
  (opening-package-date
   :type timestamp
   :nullp t)
  (shelf
   :type integer
   :nullp nil)
  (owner
   :type integer
   :foreign (user :restrict :cascade))
  (notes
   :type text
   :nullp t))

(defmethod print-object ((object chemical-product) stream)
  (format stream
          "~a (~a)"
          (name (db-utils:db-single 'chemical-compound :id (compound object)))
          (id object)))

(defmethod carcinogenic-iarc-p ((object chemical-product))
  (carcinogenic-iarc-p (db-utils:db-single 'chemical-compound :id (compound object))))

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

(deftable laboratory ()
  (name
   :type text
   :nullp nil)
  (complete-name
   :type text)
  (owner
   :type integer
   :foreign (user :restrict :cascade)))

(defmethod owner-user-db-object ((object laboratory))
  (and (owner object)
       (db-utils:db-single 'user :id (owner object))))

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

(deftable chemical-sample ()
  (name
   :type text)
  (person-id
   :type integer
   :foreign (person :restrict :cascade))
  (laboratory-id
   :type integer
   :foreign (laboratory :restrict :cascade))
  (checkin-date
   :type timestamp
   :nullp nil)
  (checkout-date
   :type timestamp)
  (quantity
   :type integer
   :nullp nil)
  (units
   :type text
   :nullp nil)
  (description
   :type text
   :nullp nil)
  (compliantp
   :type integer
   :nullp nil)
  (notes
   :type text
   :nullp t))

(defmethod print-object ((object chemical-sample) stream)
  (format stream "~a" (name object)))

(defmethod owner-user-db-object ((object chemical-sample))
  (let ((lab (db-utils:db-single 'laboratory :id (laboratory-id object))))
    (and lab
         (owner-user-db-object lab))))

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
  (watchedp
   :type text
   :default nil
   :nullp t)
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
   :nullp t)
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
  (registration-number
   :type text)
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

(deftable waste-message-hp ()
  (waste-message
   :type integer
   :foreign (waste-message :cascade :cascade))
  (hp-code-id
   :type integer
   :foreign (hp-waste-code :restrict :cascade)
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

(deftable chemical-usage-tracking ()
  (user-id
   :type integer
   :foreign (user :cascade :cascade))
  (chemical-id
   :type integer
   :foreign (chemical-compound :cascade :cascade)))

(deftable chemical-tracking-data ()
  (tracking-id
   :type integer
   :foreign (chemical-usage-tracking :cascade :cascade))
  (track-date
   :type timestamp
   :nullp nil)
  (track-type
   :type integer
   :nullp nil)
  (data
   :type text
   :nullp nil))

(deftable carcinogenic-logbook ()
  (laboratory-id
   :type integer
   :foreign (laboratory :restrict :cascade))
  (chemical-id
   :type integer
   :foreign (chemical-compound :restrict :cascade))
  (person-id
   :type integer
   :foreign (person :restrict :cascade))
  (worker-code
   :type text
   :nullp nil)
  (work-type
   :type text
   :nullp nil)
  (work-type-code
   :type text
   :nullp nil)
  (work-methods
   :type text
   :nullp nil)
  (quantity
   :type integer
   :nullp nil)
  (units
   :type  text
   :nullp nil)
  (exposition-time
   :type integer
   :nullp nil)
  (canceled
   :type integer
   :nullp t)
  (recording-date
   :type timestamp
   :nullp nil))

(defmethod build-description ((object db:carcinogenic-logbook))
  (let ((lab    (db-utils:db-single 'db:laboratory :id (db:laboratory-id object)))
        (chem   (db:name (db-utils:db-single 'db:chemical-compound :id (db:chemical-id object))))
        (person (db-utils:db-single 'db:person :id (db:person-id object))))
    (format nil
            "\"~a\" \"~a\" \"~a\" \"~a\" \"~a\" \"~a\" \"~a\" \"~a\" \"~a\"~%"
            (string-utils:escape-csv-field (db:complete-name lab))
            (string-utils:escape-csv-field (db:build-description person))
            (string-utils:escape-csv-field chem)
            (string-utils:escape-csv-field (db:worker-code     object))
            (string-utils:escape-csv-field (db:work-type       object))
            (string-utils:escape-csv-field (db:work-type-code  object))
            (string-utils:escape-csv-field (db:work-methods    object))
            (string-utils:escape-csv-field (format nil "~a" (db:exposition-time object)))
            (utils:decode-date-string      (db:recording-date  object)))))
