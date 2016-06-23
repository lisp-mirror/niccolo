;; niccolo': a chemicals inventory
;; Copyright (C) 2016  Universita' degli Studi di Palermo

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :federated-query)

(let ((checklist (make-hash-table))
      (lock  (bt:make-lock)))

  (defun query-visited-p (query-id)
    (bt:with-lock-held (lock)
      (gethash query-id checklist)))

  (defun set-visited (query-id)
    (bt:with-lock-held (lock)
      (setf (gethash query-id checklist) 1)))

  (defun clear-visited ()
    (bt:with-lock-held (lock)
      (setf checklist (make-hash-table)))))
