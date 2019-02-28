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

(defun hazard-compound-summary-json (chem-substring &key (other-pairs nil))
  "Most useful for federated query"
  (with-output-to-string (stream)
    (cl-json:with-array (stream)
      (let* ((compounds (db-filter 'db:chemical-compound
                                (:like :name (prepare-for-sql-like chem-substring)))))
        (loop for compound in compounds do
             (cl-json:as-array-member (stream)
               (let ((p-phrases (map 'vector
                                      #'(lambda (a) (getf a :code))
                                      (fetch-prec-from-compound-id (db:id compound))))
                     (h-phrases (map 'vector
                                     #'(lambda (a) (getf a :code))
                                     (fetch-hazard-from-compound-id (db:id compound)))))
                 (cl-json:encode-json-plist (concatenate 'list
                                                         (list :name (db:name compound)
                                                               :haz  h-phrases
                                                               :prec p-phrases)
                                                         other-pairs)
                                            stream))))))))

(defun manage-assoc-chem-haz-prec-fq (compound infos errors)
  (with-standard-html-frame (stream
                             (_ "Associate security statements to chemical compound")
                             :errors errors
                             :infos  infos)
    (let* ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
           (template          (with-back-uri (chemical)
                                (with-path-prefix
                                    :name-lb               (_ "Name")
                                    :description-lb        (_ "Description")
                                    :operations-lb         (_ "Operations")
                                    :origin-lb             (_ "Origin")
                                    :name-lb               (_ "Name")
                                    :hazard-codes-lb       (_ "GHS Hazard Codes")
                                    :prec-codes-lb         (_ "GHS precautionary statements")
                                    :operations-lb         (_ "Operations")
                                    :lookup-haz-code-url   (restas:genurl 'ws-ghs-h-reverse-lookup)
                                    :lookup-prec-code-url  (restas:genurl 'ws-ghs-p-reverse-lookup)
                                    :compound-name         (db:name compound)
                                    :haz-code-assoc-name   +name-haz-code+
                                    :prec-code-assoc-name  +name-prec-code+
                                    :haz-desc              +name-haz-desc+
                                    :haz-code-id           +name-hazcode-id+
                                    :haz-compound-id       +name-haz-compound-id+
                                    :prec-code-id          +name-preccode-id+
                                    :prec-compound-id      +name-prec-compound-id+
                                    :value-compound-id     (db:id compound)
                                    ;; federated query
                                    :fq-start-url
                                    (restas:genurl 'ws-federated-query-compound-hazard)
                                    :fq-results-url
                                    (restas:genurl 'ws-federated-query-results)
                                    :fq-query-key-param    +query-http-parameter-key+))))
      (html-template:fill-and-print-template #p"assoc-chem-security-fq.tpl"
                                             template
                                             :stream stream))))

(define-lab-route assoc-chem-haz-prec-fq ("/assoc-chem-security-fq/:id" :method :get)
  (with-authentication
    (if (not (regexp-validate (list (list id +pos-integer-re+ ""))))
        (let ((chemical (db-single 'db:chemical-compound :id id)))
          (if chemical
              (manage-assoc-chem-haz-prec-fq chemical nil nil)
              +http-not-found+))
        +http-not-found+)))
