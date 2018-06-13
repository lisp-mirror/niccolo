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

(in-package :views)

(defun json-all-storage-long-desc ()
  (let ((raw (query
              (select (:storage.id
                       (:as :storage.name :stname)
                       :storage.floor-number
                       :building.name
                       :address.line-1
                       :address.city)
                (from :storage)
                (left-join :building :on (:= :building.id :storage.building-id))
                (left-join :address :on  (:= :address.id  :building.address-id))
                (order-by  :storage.id)))))
    (values
     (obj->json-string
      (loop for i in raw collect (obj->json-string (getf i :|id|))))
     (obj->json-string
      (loop for i in raw collect
           (format nil "~a, ~a ~a ~a ~a"
                   (getf i :|stname|)
                   (getf i :|name|)
                   (getf i :|line-1|)
                   (getf i :|city|)
                   (getf i :|floor-number|)))))))
