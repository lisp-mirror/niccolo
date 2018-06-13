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

(in-package :restas.lab)

(define-constant +t-key+ :t :test #'eq)

(define-constant +alarm-threshold+ 35.0 :test #'=)

(defun process-sensor-output (description results)
  (let ((temperature (cdr (assoc +t-key+ (json->list results)))))
    (when (> temperature +alarm-threshold+)
      (log-and-mail (db:email (admin-user))
		    (format nil "ALARM sensor ~a" description)
		    (format nil
			  "Current temperature:  ~a, threshold: ~a"
			  temperature +alarm-threshold+)))
    temperature))
