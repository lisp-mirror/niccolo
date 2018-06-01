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

(in-package :risk-phrases)

(alexandria:define-constant +phrases-el+ "phrases"
  :test 'string=)

(alexandria:define-constant +label-el+ "label"
  :test 'string=)

(alexandria:define-constant +phrase-el+ "phrase"
  :test 'string=)

(alexandria:define-constant +explanation-el+ "explanation"
  :test 'string=)

(alexandria:define-constant +points-el+ "points"
  :test 'string=)

(defun load-db (path)
  (let ((db '()))
    (macrolet ((get-record (tag node)
		 `(xml-utils:with-tagmatch (,tag ,node)
		    (first (xmls:xmlrep-children ,node)))))
      (with-open-file (stream path :direction :input :if-does-not-exist :error)
	(let ((xmls-list (xmls:parse stream :compress-whitespace t)))
	  (xml-utils:with-tagmatch (+phrases-el+ xmls-list)
	    (mapc #'(lambda (node)
		      (xml-utils:with-tagmatch-if-else (+label-el+ node (nil))
			(let* ((records  (xml-utils:with-tagmatch (+label-el+ node)
					   (xmls:xmlrep-children node)))
			       (phr     (get-record +phrase-el+ (first records)))
			       (expl    (get-record +explanation-el+ (second records)))
			       (points  (parse-number (get-record +points-el+ (third records)))))
			  (push (list phr expl points) db))))
		  (xmls:xmlrep-children xmls-list))))))
    db))

(defparameter *phrases-database* (load-db config:*risk-phrases*))

(defun get-points (key)
  (restart-case
      (third (get-entry key))
    (use-0 () 0)))

(defun get-entry-error (key)
  (let ((ent (find-if #'(lambda (l) (string-equal (first l) key)) *phrases-database*)))
    (if (not (null ent))
	ent
	(error 'conditions:null-reference
	       :text (format nil "Phrase ~a does not exists" key)))))

(defun get-entry (key)
    (restart-case
	(get-entry-error key)
      (use-value (value) value)))
