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

(in-package :db-utils)

(defparameter *db-lock* (bt:make-recursive-lock))

(defmacro with-global-lock (&body body)
  `(bt:with-recursive-lock-held (*db-lock*)
     (crane:with-transaction ()
       ,@body)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun query-low-level (sql database-name)
    "Bypass crane and execute sql query with dbi"
    (when (crane.config:debugp)
      (format t "~&Query: ~A~&" sql))
    (with-global-lock
      (dbi:execute (dbi:prepare (crane.connect:get-connection database-name) sql)))))

(defmacro db-filter (class &rest params)
  `(with-global-lock
    (crane:filter ,class ,@params)))

(defmacro db-single (class &rest params)
  `(with-global-lock
    (crane:single ,class ,@params)))

(defmacro db-single! (class &rest params)
  `(with-global-lock
    (crane:single! ,class ,@params)))

(defmacro db-single-or-create (class &rest params)
  `(with-global-lock
     (crane:single-or-create ,class ,@params)))

(defmacro db-create (class &rest params)
  `(with-global-lock
    (crane:create ,class ,@params)))

(defun db-save (obj)
  (with-global-lock
    (crane:save obj)))

(defun db-del (obj)
  (with-global-lock
    (crane:del obj)))

(defun db-query (query &optional database-name)
  (with-global-lock
    (query query database-name)))

(defmacro do-rows ((row res) table &body body)
  `(let ((,res ,table))
     (loop for ,row from 0 below (length ,res) do ,@body)
     ,res))

(defun fetch-raw-list (what)
  (db-filter what))

(defun prepare-for-sql-like (s)
  (if (cl-ppcre:scan +free-text-re+ s)
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
  (db-single class :id id))

(defmacro if-db-nil-else (expr else)
  `(if (not (db-nil-p ,expr))
       ,expr
       ,else))

(defun db-nil-p (a)
  (or (null a)
      (eq a :nil)
      (eq a :null)))

(defun db-non-nil-p (a)
  (not (db-nil-p a)))

(defun count-all (class)
  (second (first (db-query (select ((:as (:count :*) :ct))
                             (from class))))))

(defun get-column-from-id (id re object column-fn &key (default ""))
  (let ((obj-db (db-single object :id (if (scan-to-strings re id)
                                       (parse-integer id)
                                       +db-invalid-id-number+))))
    (if obj-db
        (funcall column-fn obj-db)
        default)))
