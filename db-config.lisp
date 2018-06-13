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

(in-package :db-config)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (setup
   :migrations-directory (config:local-system-path #p"migrations/")
   :databases (list :main
                    (list :type :sqlite3
                          :name (uiop:unix-namestring (config:local-system-path #p"lab.db"))))
   ;; use debug t for query printing
   :debug nil)
  (connect)
  ;; set foreign_keys support
  ;; (crane:query-low-level "PRAGMA foreign_keys = ON;" crane:*default-db*)
  ;; next two statement activates autocommit
  (db-utils:query-low-level "BEGIN TRANSACTION;" crane:*default-db*)
  (db-utils:query-low-level "COMMIT;" crane:*default-db*))
