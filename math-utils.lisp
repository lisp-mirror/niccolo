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

(in-package :math-utils)

(deftype fmatrix ()
  `(simple-array fixnum (* *)))

(defun make-fmatrix (r c)
  (make-array (list r c)
              :element-type    'fixnum
              :initial-element 0
              :adjustable      nil
              :fill-pointer    nil
              :displaced-to    nil))

(defun fmref (m r c)
  (aref m r c))

(defsetf fmref (m r c) (value)
  `(setf (aref ,m ,r ,c) ,value))

(defun fm-w (m)
  "# of columns"
  (declare (optimize (speed 3) (safety 0) (debug 0)))
  (declare (fmatrix m))
  (array-dimension m 1))

(defun fm-h (m)
  "# of rows"
  (declare (optimize (speed 3) (safety 0) (debug 0)))
  (declare (fmatrix m))
  (array-dimension m 0))

(defun fm= (a b)
  (declare (optimize (speed 3) (safety 0) (debug 0)))
  (declare (fmatrix a b))
  (flet ((all-equals ()
           (loop
              for r fixnum from 0 below (fm-h a)
              for c fixnum from 0 below (fm-w a) do
                (when (/= (the fixnum (fmref a r c))
                          (the fixnum (fmref b r c)))
                  (return-from all-equals nil)))
           t))
    (and (= (the fixnum (fm-w a))
            (the fixnum (fm-w b)))
         (= (the fixnum (fm-h a))
            (the fixnum (fm-h b)))
         (all-equals))))

(defun fm-row (m index)
  (declare (optimize (speed 3) (safety 0) (debug 0)))
  (declare (fmatrix m))
  (declare (fixnum index))
  (loop
     for i fixnum from 0 below (fm-w m) collect
       (fmref m index i)))

(defun fm-column (m index)
  (declare (optimize (speed 3) (safety 0) (debug 0)))
  (declare (fmatrix m))
  (declare (fixnum index))
  (loop
     for j fixnum from 0 below (fm-h m) collect
       (fmref m j index)))

(defun make-same-dimension-fmatrix (m)
  (make-fmatrix (fm-h m) (fm-w m)))

(defmacro fm-loop ((m r c) &body body)
  `(loop for ,r fixnum from 0 below (fm-h ,m) do
        (loop for ,c fixnum from 0 below (fm-w ,m) do
             ,@body)))

(defun fm-map (m predicate)
  (declare (optimize (speed 3) (safety 0) (debug 0)))
  (declare (fmatrix m))
  (declare (function predicate))
  (let ((res (make-same-dimension-fmatrix m)))
    (declare (fmatrix res))
    (fm-loop (m r c)
       (setf (fmref res r c)
             (funcall predicate (fmref m r c) r c)))
    res))

(defun fm-flat-copy (m)
  (fm-map m #'(lambda (v r c)
                (declare (ignore r c))
                v)))

(defun fm-transpose (m)
  (let ((res (make-fmatrix (fm-w m) (fm-h m))))
    (fm-loop (m r c)
       (setf (fmref res c r) (fmref m r c)))
    res))

(defun fm* (lhs rhs)
   (declare (fmatrix lhs rhs))
   (assert (= (fm-w lhs) (fm-h rhs)))
   (let ((res (make-fmatrix (fm-h lhs) (fm-w rhs))))
     (fm-loop (res r c)
        (setf (fmref res r c)
              (reduce #'+
                      (map 'list
                           #'*
                           (fm-row lhs r)
                           (fm-column rhs c)))))
     res))
