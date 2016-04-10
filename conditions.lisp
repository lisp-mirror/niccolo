;; Conditions.
;; Copyright (C) 2016  cage

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package conditions)

(define-condition text-error (error)
  ((text
    :initarg :text
    :reader text))
  (:report (lambda (condition stream)
	     (format stream "~a" (text condition))))
  (:documentation "Error that set text"))

(define-condition not-implemented-error (text-error)
  ((text
    :initarg :text
    :reader text))
  (:documentation "Error for not-implemented features"))

(define-condition null-reference (text-error)
  ((text
    :initarg :text
    :reader text))
  (:documentation "Null reference"))


(define-condition out-of-bounds (error)
  ((seq
    :initarg :seq
    :reader seq)
   (idx
    :initarg :idx
    :reader idx))
   (:documentation "Error when you go out of bound"))


(define-condition length-error (text-error)
  ((seq
    :initarg :seq
    :reader seq))
  (:documentation "Length error"))

(define-condition different-length-error (error)
  ((seq1
    :initarg :seq1
    :reader seq1)
   (seq2
    :initarg :seq2
    :reader seq2))
  (:documentation "Length error"))
