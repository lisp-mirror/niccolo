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

(in-package :i18n)

(defun locale-filename (locale)
  (format nil
	  "locale/~a/LC_MESSAGES/~a.lisp"
	  locale
	  (string-downcase (symbol-name +program-name+))))

(defun locale-filepath (locale)
  (local-system-path (locale-filename locale)))

(defun load-translation (locale)
  (let ((cl-i18n:*translation-file-root* ""))
    (cl-i18n:load-language (locale-filepath locale)
			   :locale                   nil
			   :categories               nil
			   :store-plural-function    nil
			   :store-hashtable          nil
			   :update-translation-table nil)))
(defstruct translation
  description
  table
  plural-function)

(defun cons-translations (locale &optional (description locale))
  (multiple-value-bind (table plural-fn)
      (load-translation locale)
    (cons locale (make-translation :description     description
				   :table           table
				   :plural-function plural-fn))))

(defparameter *availables-translations*
  (list (cons-translations "it" "Italiano")))

(defun translation-select-options ()
  (loop for i in *availables-translations* collect
       (list :locale-key (car i) :locale-description (translation-description (cdr i)))))

(defun find-translation (key)
  "Return the 'translation' struct associed with key if exists, nil otherwise"
  (let ((translation (assoc key *availables-translations* :test #'string=)))
    (and translation
	 (cdr translation))))

(defmacro with-user-translation ((user-id) &body body)
  (with-gensyms (locale locale-table locale-plural preferences)
    `(if (> ,user-id 0)
	 (let ((,preferences (crane:single 'db:user-preferences :owner ,user-id)))
	   (if ,preferences
	       (let* ((,locale          (i18n:find-translation     (db:language ,preferences)))
		      (,locale-table    (translation-table           ,locale))
		      (,locale-plural   (translation-plural-function ,locale)))
		 (cl-i18n:with-translation (,locale-table ,locale-plural)
		   ,@body))
	       (handler-bind ((i18n-conditions:no-translation-table-error
			       #'(lambda(e)
				   (declare (ignore e))
				   (invoke-restart 'cl-i18n:return-untranslated))))
		 (cl-i18n:with-translation ((make-hash-table :test 'equal)
					    #'cl-i18n:english-plural-form)
		   ,@body)))))))
