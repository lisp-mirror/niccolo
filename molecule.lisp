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

(in-package :molecule)

(defclass ch-atom ()
  ((label
    :initform  nil
    :initarg   :label
    :accessor  label)
   (charge
    :initform  nil
    :initarg   :charge
    :accessor  charge)
   (x
    :initform  nil
    :initarg   :x
    :accessor  x)
   (y
    :initform  nil
    :initarg   :y
    :accessor  y)
   (z
    :initform  nil
    :initarg   :z
    :accessor  z)))

(defmethod print-object ((object ch-atom) stream)
  (format stream "[~a~[~:;(~:*~@d)~]]" (label object) (charge object)))

(defclass molecule ()
  ((atoms
    :initform  (make-array 0 :element-type 'atom :adjustable t :fill-pointer t)
    :initarg   :atoms
    :accessor  atoms)
   (connections
    :initform  nil
    :initarg   :connections
    :accessor  connections)))

(defmethod print-object ((object molecule) stream)
  (format stream "~a~%matrix:~%~a" (atoms object) (connections object)))
