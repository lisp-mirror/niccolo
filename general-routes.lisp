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

(in-package :restas.lab)

(eval-when (:compile-toplevel :load-toplevel :execute)

  (defun cat-prefix (a)
    (concatenate 'string config:+path-prefix+ a))

  (restas:mount-module -images- (#:restas.directory-publisher)
    (:url (cat-prefix "/images/"))
    (restas.directory-publisher:*directory* *images-dir*)
    (restas.directory-publisher:*autoindex* t))

  (restas:mount-module -jquery-ui-images- (#:restas.directory-publisher)
    (:url (cat-prefix"/css/images/"))
    (restas.directory-publisher:*directory* *jquery-ui-images-dir*)
    (restas.directory-publisher:*autoindex* t))

  (restas:mount-module -css- (#:restas.directory-publisher)
    (:url (cat-prefix"/css/"))
    (restas.directory-publisher:*directory* *css-dir*)
    (restas.directory-publisher:*autoindex* t))

  (restas:mount-module -js- (#:restas.directory-publisher)
    (:url (cat-prefix"/js/"))
    (restas.directory-publisher:*directory* *js-dir*)
    (restas.directory-publisher:*autoindex* t)))
