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

(in-package :validation)

(defun all-not-null-p (&rest vals)
  (notany #'null vals))

(defun all-null-p (&rest vals)
  (every #'null vals))

(defun regexp-validate (data)
  "data -> '(datum regexp error-message)"
  (loop for (data regexp message) in data when (not (scan regexp data)) collect
       message))

(defun unique-p-validate (class unique-column value-to-search-for error-message)
  (and (query (select :* (from class) (where (:= unique-column value-to-search-for))))
       (list error-message)))

(defmacro unique-p-validate* (class unique-columns values-to-search-for error-message)
  `(and (query (select :*
		 (from ,class)
		 (where (:and ,@(loop
				   for c in unique-columns
				   for v in values-to-search-for collect
				     `(:= ,c ,v))))))
	(list ,error-message)))

(defmacro exists-with-different-id-validate (class id unique-columns
					     values-to-search-for error-message)
  `(and (query (select :*
		 (from ,class)
		 (where (:and ,@(concatenate 'list
					    (loop
					       for c in unique-columns
					       for v in values-to-search-for collect
						 `(:= ,c ,v))
					    `((:!= :id ,id)))))))
	(list ,error-message)))

(defun boolean-p-validate (var)
  (or (string= var "0")
      (string= var "1")))

(defun integer-validate (i)
  (parse-integer i :junk-allowed nil))

(defun date-validate-p (d)
  (local-time:parse-timestring d :fail-on-error nil))

(defun magic-validate-p (file magic)
  (if file
      (with-open-file (stream file
			      :direction :input
			      :if-does-not-exist nil
			      :element-type '(unsigned-byte 8))
	(and stream
	     (> (file-length stream) (length magic))
	     (equalp magic (loop repeat (length magic) collect (read-byte stream)))))
      nil))

(defun png-validate-p (file)
  (magic-validate-p file '(#x89 #x50 #x4e #x47 #x0d #x0a #x1a #x0a)))

(defun pdf-validate-p (file)
  (magic-validate-p file '(#x25 #x50 #x44 #x46)))

(defun strip-tags (s)
  (sanitize:clean s +no-html-tags-at-all+))

(define-constant +email-re+ "(?i)[a-z,0-9,\\-,_]+\\.?[a-z,0-9,\\-,_]+@[a-z,0-9,\\-,_]+\\.[a-z,0-9,\\-,_]+" :test #'string=)

(define-constant +ghs-hazard-code-re+        "^((H|EUH)[0-9]+[a-z]?)(\\/?(H|EUH)[0-9]+[a-z]?)?$"
  :test #'string=)

(define-constant +ghs-precautionary-code-re+ "^(P[0-9]+)(\\+P[0-9]+){0,2}$"      :test #'string=)

(define-constant +integer-re+                "^-?[1-9][0-9]*$"                   :test #'string=)

(define-constant +pos-integer-re+            "^[1-9][0-9]*$"                     :test #'string=)

(define-constant +barcode-id-re+             "^[0-9][0-9]*$"                     :test #'string=)

(define-constant +free-text-re+              "^[^;\\\"'<>&]+$"                   :test #'string=)

(define-constant +cer-code-re+               "^CER[0-9]+\\*?$"                   :test #'string=)

(define-constant +adr-code-class-re+         "(^[0-9]$)|(^[0-9]\\.[0-9][A-Z]?$)" :test #'string=)

(define-constant +adr-uncode-re+             "^UN[0-9]{4}$"                      :test #'string=)

(define-constant +adr-code-radioactive+      "^7"                                :test #'string=)

(define-constant +waste-form-weight-re+      "^\\p{N}+\\p{L}{1,2}$"              :test #'string=)

(define-constant +federated-query-product-re+  "(?i)^[a-z]{3,}$"                 :test #'string=)

(define-constant +federated-query-id-re+       "(?i)^.+-[0-9]+"                  :test #'string=)
