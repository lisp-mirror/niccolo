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

(define-constant +name-prec-desc+        "desc"             :test #'string=)

(define-constant +name-preccode-id+      "prec-code-id"     :test #'string=)

(define-constant +name-prec-compound-id+ "prec-compound-id" :test #'string=)

(define-constant +name-prec-code+        "code"             :test #'string=)

(defun fetch-prec-from-compound-id (id &optional (delete-link nil))
  (let ((raw (query
              (select ((:as :chem.id               :chem-id)
                       (:as :prec.id               :id)
                       (:as :prec-stat.code        :code)
                       (:as :prec-stat.explanation :expl))
                (from (:as :chemical-precautionary :prec))
                (left-join (:as :ghs-precautionary-statement :prec-stat)
                           :on (:= :prec-stat.id :prec.ghs-p))
                (left-join (:as :chemical-compound :chem)
                           :on (:= :chem.id :prec.compound-id))
                (where (:= :chem.id id))))))
    (loop for row in raw collect
         (let ((id   (getf row :|id|))
               (chem-id   (getf row :|chem-id|))
               (code (getf row :|code|))
               (expl (getf row :|expl|)))
           (append
            (list :id   id
                  :code code
                  :desc (concatenate 'string code " " expl))
            (if delete-link
                (list :delete-link (restas:genurl delete-link :id id :id-chem chem-id))))))))

(defun fetch-prec-assoc-by-ids (prec-id chem-id)
  (query
   (select :* (from (:as :chemical-precautionary :c))
           (where (:and (:= :c.ghs-p prec-id)
                        (:= :c.compound-id chem-id))))))

(defun fetch-prec-from-compound (compound &optional (delete-link nil))
  (and compound
       (fetch-prec-from-compound-id (db:id compound) delete-link)))

(gen-autocomplete-functions db:ghs-precautionary-statement db:build-description)

(defun manage-assoc-chem-prec (compound infos errors)
  (let ((preccodes-owned (fetch-prec-from-compound compound 'delete-assoc-chem-prec)))
    (with-standard-html-frame (stream
                               (_ "Associate precautionary phrases to chemical compound")
                               :errors errors
                               :infos  infos)

      (let ((html-template:*string-modifier* #'identity)
            (json-addresses    (array-autocomplete-ghs-precautionary-statement))
            (json-addresses-id (array-autocomplete-ghs-precautionary-statement-id)))
        (html-template:fill-and-print-template #p"assoc-chem-prec.tpl"
                                               (with-back-uri (chemical)
                                                 (with-path-prefix
                                                     :name-lb                (_ "Name")
                                                     :description-lb         (_ "Description")
                                                     :operations-lb          (_ "Operations")
                                                     :compound-name          (db:name compound)
                                                     :prec-desc              +name-prec-desc+
                                                     :prec-code-id           +name-preccode-id+
                                                     :prec-compound-id       +name-prec-compound-id+
                                                     :value-prec-compound-id (db:id compound)
                                                     :json-prec-code         json-addresses
                                                     :json-prec-id           json-addresses-id
                                                     :data-table             preccodes-owned))
                                               :stream stream)))))

(defun add-new-assoc-chem-prec (prec-id chem-id)
  (let* ((errors-msg-1 (concatenate 'list
                                    (regexp-validate (list
                                                      (list prec-id
                                                            +pos-integer-re+
                                                            (_ "Code invalid"))
                                                      (list chem-id
                                                            +pos-integer-re+
                                                            (_ "Chemical ID invalid"))))))
         (errors-msg-chem-not-found (when (and (not errors-msg-1)
                                               (not (single 'db:chemical-compound
                                                            :id chem-id)))
                                      (list (_ "Chemical compound not in database"))))
         (errors-msg-prec-not-found (when (and (not errors-msg-1)
                                               (not (single 'db:ghs-precautionary-statement
                                                            :id prec-id)))
                                      (list (_ "GHS Precautionary code not in database"))))
         (error-assoc-exists       (when (and (not errors-msg-1)
                                              (fetch-prec-assoc-by-ids prec-id chem-id))
                                     (list (_ "GHS Precautionary code already associated with this chemical compound."))))
         (errors-msg (concatenate 'list
                                  errors-msg-1
                                  errors-msg-chem-not-found
                                  errors-msg-prec-not-found
                                  error-assoc-exists))
         (success-msg (and (not errors-msg)
                           (list (_ "Saved association")))))
    (when (not errors-msg)
      (let ((prec-assoc (create 'db:chemical-precautionary
                                :ghs-p prec-id
                                :compound-id chem-id)))

        (save prec-assoc)))
    (manage-assoc-chem-prec (single 'db:chemical-compound :id chem-id)
                            success-msg errors-msg)))

(define-lab-route assoc-chem-prec ("/assoc-chem-prec/:id" :method :get)
  (with-authentication
    (if (not (regexp-validate (list (list id +pos-integer-re+ ""))))
        (let ((chemical (single 'db:chemical-compound :id id)))
          (if chemical
              (manage-assoc-chem-prec chemical nil nil)
              +http-not-found+))
        +http-not-found+)))

(define-lab-route add-assoc-chem-prec ("/add-assoc-chem-prec/" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (add-new-assoc-chem-prec (get-parameter +name-preccode-id+)
                                   (get-parameter +name-prec-compound-id+)))
      (manage-chem nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-assoc-chem-prec ("/delete-assoc-chem-prec/:id/:id-chem" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (when (and (not (regexp-validate (list (list id +pos-integer-re+ ""))))
                     (not (regexp-validate (list (list id-chem +pos-integer-re+ "")))))
            (let ((to-trash (single 'db:chemical-precautionary :id id)))
              (when to-trash
                (del (single 'db:chemical-precautionary :id id))))
            (restas:redirect 'assoc-chem-prec :id id-chem)))
      (manage-chem nil (list *insufficient-privileges-message*)))))


(define-lab-route remove-prec-code-from-chem ("/remove-prec-code-from-chem/:id-prec/:id-chem"
                                              :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (when (and (not (regexp-validate (list (list id-prec  +pos-integer-re+ ""))))
                     (not (regexp-validate (list (list id-chem +pos-integer-re+ "")))))
            (let ((to-trash (single 'db:chemical-precautionary
                                    :ghs-p id-prec
                                    :compound-id id-chem)))
              (when to-trash
                (del to-trash)))
            (restas:redirect 'assoc-chem-prec :id id-chem)))
      (manage-chem nil (list *insufficient-privileges-message*)))))
