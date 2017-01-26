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

(in-package :string-utils)

(defun clean-string (s)
  (regex-replace-all "[;\\\"'=<>&]" s ""))

(defun string-empty-p (s)
    (or (null s)
	(string= s "")))

(defun base64-encode (raw-data)
  (cl-base64:usb8-array-to-base64-string raw-data))

(defun base64-decode (encoded)
  (cl-base64:base64-string-to-usb8-array encoded))

(defun sha-encode->string (data)
  (let ((sha (ironclad:make-digest 'ironclad:sha256))
        (bin-data (ironclad:ascii-string-to-byte-array data)))
    (ironclad:update-digest sha bin-data)
    (ironclad:byte-array-to-hex-string (ironclad:produce-digest sha))))

(defun encode-barcode (id)
  (format nil "$START-B~8,'0d" id))

(defun find-filename-from-path (path &key (extension nil))
  "UNIX only. Note: file without a proper extension will be ignored"
  (and (stringp path) ; ensure a string
       (multiple-value-bind (match registers)
	   (cl-ppcre:scan-to-strings "/([^/]+)\\.\(.*)" path)
	 (declare (ignore match))
	 (when (and registers
		    (> (length registers) 1))
	   (concatenate 'string
			(elt registers 0)
			"."
			(or extension
			    (elt registers 1)))))))

(defun random-password (&optional (length 12))
  (coerce (loop repeat length collect (code-char (+ 33 (random 93))))
	  'string))

(defun escape-csv-field (field)
  (cl-ppcre:regex-replace-all "\"" field "\"\""))
