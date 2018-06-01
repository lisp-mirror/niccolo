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

(let ((count 0)
      (lock  (bt:make-lock)))
  (defun next-query-id ()
    (bt:with-lock-held (lock)
      (prog1
          (format nil
                  "~a-~a-~a:~a"
                  +hostname+
                  +https-port+
                  count
                  (utils:local-time-obj-now))
        (incf count)))))

(defun query-id-timestamp (query-id)
  (let ((raw (cl-ppcre:scan-to-strings ":.*$" query-id)))
    (and raw
         (utils:encode-datetime-string (subseq raw 1)))))
