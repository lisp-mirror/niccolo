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

(in-package :db-utils)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun query-low-level (sql database-name)
    "Bypass crane and execute sql query with dbi"
    (when (crane.config:debugp)
      (format t "~&Query: ~A~&" sql))
    (dbi:execute (dbi:prepare (crane.connect:get-connection database-name) sql))))

(defmacro do-rows ((row res) table &body body)
  `(let ((,res ,table))
     (loop for ,row from 0 below (length ,res) do ,@body)
     ,res))

(defun fetch-raw-list (what)
  (crane:filter what))

(defun prepare-for-sql-like (s)
  (if (cl-ppcre:scan validation:+free-text-re+ s)
      (format nil "%~a%" s)
      "%"))

(defun keywordize-query-results (raw)
  (map 'list #'(lambda (row)
		 (map 'list
		      #'(lambda (cell)
			  (if (symbolp cell)
			      (make-keyword (string-upcase (symbol-name cell)))
			      cell))
		      row))
       raw))

(defun get-max-id (table)
  (or (second (dbi:fetch (query-low-level (format nil "select max (id) from \"~a\"" table)
					  crane:*default-db*)))
      0))

(defun object-exists-in-db-p (class id)
  (crane:single class :id id))
