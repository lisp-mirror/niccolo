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

(define-constant +g-key+                  :g   :test #'eq)

(define-constant +average-key+            :a   :test #'eq)

(define-constant +standard-deviation-key+ :s   :test #'eq)

(defun process-sensor-output (description results)
  (let* ((values             (json->list results))
	 (resistance         (cdr (assoc +g-key+ values)))
	 (standard-deviation (cdr (assoc +standard-deviation-key+ values)))
	 (average            (cdr (assoc +average-key+ values)))
	 (threshold          (* 1.96 standard-deviation))
    (when (<= (- average threshold)
	      resistance
	      (+ average threshold))
      (send-email (format nil "ALARM sensor ~a" description)
		  (db:email (admin-user))
		  (format nil
			  "Current values:  ~a"
			  values)))
    resistance))
