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

(in-package :molecule)

(define-constant +no-bond-matrix-value+ 0 :test #'=)

(defclass ch-atom ()
  ((label
    :initform  nil
    :initarg   :label
    :accessor  label)
   (charge
    :initform  0
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

(defgeneric ch-atom= (a b))

(defmethod  ch-atom= ((a ch-atom) (b ch-atom))
  (and (string= (label a)  (label  b))
       (=       (charge a) (charge b))))

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

(defgeneric valence (object atom-index))

(defgeneric atom@ (object atom-index))

(defgeneric bond-types-count (object atom-index))

(defgeneric all-first-near (object))

(defgeneric first-near (object index))

(defgeneric subgraph-isomorphism (group molecule))

(defmacro with-check-atoms-limits ((atoms index) &body body)
  `(if (< ,index (length ,atoms))
       (progn
         ,@body)
       (error 'conditions:out-of-bounds :idx ,index :seq ,atoms)))

(defmethod valence ((object molecule) atom-index)
  (with-accessors ((atoms atoms) (connections connections)) object
    (with-check-atoms-limits (atoms atom-index)
      (count-if #'(lambda (a) (> a 0)) (fm-row connections atom-index)))))

(defmethod atom@ ((object molecule) atom-index)
  (with-accessors ((atoms atoms)) object
    (with-check-atoms-limits (atoms atom-index)
      (elt atoms atom-index))))

(defmethod bond-types-count ((object molecule) atom-index)
  (with-accessors ((atoms atoms) (connections connections)) object
    (with-check-atoms-limits (atoms atom-index)
      (let* ((bonds       (remove +no-bond-matrix-value+
                                  (fm-row connections atom-index)
                                  :test #'=))
             (bonds-types (reduce #'(lambda (a b) (pushnew b a :test #'=))
                                  bonds
                                  :initial-value '())))
        (loop for i in bonds-types collect
             (cons i (count i bonds :test #'=)))))))

(defstruct neighbour
  (atom)
  (index))

(defmethod all-first-near ((object molecule))
  "Evaluate to  list ofa cons where car is the atom and cdr is the index in molecule's atom list"
  (with-accessors ((atoms atoms) (connections connections)) object
    (loop for row-ct from 0 below (fm-w connections) collect
         (let ((row (fm-row connections row-ct)))
           (loop
              for i from 0 by 1
              for bond in row when (> bond 0) collect
                (make-neighbour :atom (elt atoms i) :index i))))))

(defmethod first-near ((object molecule) index)
  (with-accessors ((atoms atoms) (connections connections)) object
    (assert (< index (length atoms)))
    (let ((row (fm-row connections index)))
      (loop
         for i from 0 by 1
         for bond in row when (> bond 0) collect
           (make-neighbour :atom (elt atoms i) :index i)))))

(defun group-by-bond (row)
  (let ((bond-types (do ((res    '())
                         (source (copy-list row) (rest source)))
                        ((null source) (remove 0 res :test #'=))
                      (pushnew (first source) res :test #'=))))
    (loop for i in bond-types collect
         (cons i (count i row :test #'=)))))

(defun bonds-compatible-p (group group-index molecule molecule-index)
  (let ((group-bonds-grouped    (group-by-bond (fm-row (connections group)    group-index)))
        (molecule-bonds-grouped (group-by-bond (fm-row (connections molecule) molecule-index))))
    (loop for i in group-bonds-grouped do
         (if (assoc (car i) molecule-bonds-grouped)
             (let ((count-in-group    (cdr i))
                   (count-in-molecule (cdr (assoc (car i) molecule-bonds-grouped))))
               (when (> count-in-group count-in-molecule)
                 (return-from bonds-compatible-p nil)))
             (return-from bonds-compatible-p nil)))
    t))

(defun first-near-compatible-p (group group-index molecule molecule-index)
  (let ((first-near-group (and (all-first-near group)
                               (elt (all-first-near group)
                                    group-index)))
        (first-near-molecule (and (all-first-near molecule)
                                  (elt (all-first-near molecule)
                                       molecule-index))))
    (loop for i from 0 below (length first-near-group) do
         (let ((count-group (count (neighbour-atom (elt first-near-group i))
                                   first-near-group
                                   :key #'neighbour-atom
                                   :test #'ch-atom=))
               (count-mol   (count (neighbour-atom (elt first-near-group i))
                                   first-near-molecule
                                   :key #'neighbour-atom
                                   :test #'ch-atom=)))
           (when (< count-mol count-group)
             (return-from first-near-compatible-p nil))))
    t))

(defun %pmatrix-calculate-element (group group-index molecule molecule-index)
  (if (and (<= (valence group    group-index)
               (valence molecule molecule-index))
           (string= (label (atom@ group     group-index))
                    (label (atom@ molecule  molecule-index)))
           (bonds-compatible-p      group group-index molecule molecule-index)
           (first-near-compatible-p group group-index molecule molecule-index))
      1
      0))

(defun permutation-matrix (group molecule)
  (let* ((atom-count-group    (length (atoms group)))
         (atom-count-molecule (length (atoms molecule)))
         (res                 (make-fmatrix atom-count-group
                                            atom-count-molecule)))
    (loop for r from 0 below atom-count-group do
         (loop for c from 0 below atom-count-molecule do
              (setf (fmref res r c)
                    (%pmatrix-calculate-element group    r
                                                molecule c))))
    res))

(defun %flat-adjacency (v r c)
  (declare (ignore r c))
  (if (> v 0)
      1
      0))

(defun translate-atoms-pmatrix (pmatrix atom-index access-fn)
  (position-if #'(lambda (a) (> a 0))
               (funcall access-fn pmatrix atom-index)))

(defun translate-pm-alpha->beta (pmatrix atom-index)
  (translate-atoms-pmatrix pmatrix atom-index #'fm-row))

(defun translate-pm-beta->alpha (pmatrix atom-index)
  "Note: can return nil"
  (translate-atoms-pmatrix pmatrix atom-index #'fm-column))

(defun bonds-alist (connections row)
  (loop
     for i from 0 below (fm-w connections)
     when (> (fmref connections row i) 0)
     collect
       (cons i (fmref connections row i))))

(defun isomorphic-p (alpha beta connections-alpha connections-beta permutation-matrix)
  (let ((res (fm* permutation-matrix (fm-transpose (fm* permutation-matrix beta)))))
    (fm-loop (res r c)
      (when (and (=  (fmref alpha r c) 1)
                 (/= (fmref res   r c) 1))
        (return-from isomorphic-p nil)))
    ;; test bonds
    (loop for a-atom from 0 below (fm-h permutation-matrix) do
         (let ((a-bonds (bonds-alist connections-alpha a-atom))
               (b-atom  (translate-pm-alpha->beta permutation-matrix a-atom)))
           (loop for bond in a-bonds do
                (let* ((b-atom-bond  (translate-pm-alpha->beta permutation-matrix (car bond)))
                       (b-bonds      (bonds-alist connections-beta b-atom-bond)))
                  (let ((bond-in-beta (assoc b-atom b-bonds)))
                    (when (or (not bond-in-beta)
                              (/=  (cdr bond-in-beta) (cdr bond)))
                      (return-from isomorphic-p nil)))))))
    t))

(defun prune (matrix group molecule)
  (let ((copy (fm-flat-copy matrix)))
    (fm-loop (copy i j)
      (when (= (fmref copy i j) 1)
        (let ((neighbors-fragment (first-near group i)))
          (loop for neighbor-fragment in neighbors-fragment do
               (let ((neighbors-molecule (first-near molecule j)))
                 (let ((no-mapping-exists-p t))
                   (loop
                      named inner
                      for neighbor-molecule in neighbors-molecule do
                        (when (= (fmref copy
                                        (neighbour-index neighbor-fragment)
                                        (neighbour-index neighbor-molecule))
                                 1)
                          (setf no-mapping-exists-p nil)
                          (return-from inner t)))
                   (when no-mapping-exists-p
                     (setf (fmref copy i j) 0))))))))
    (if (fm= matrix copy)
        copy
        (prune copy group molecule))))

(defmethod subgraph-isomorphism ((group-alpha molecule) (molecule-beta molecule))
  (let ((permutation-matrix    (permutation-matrix group-alpha molecule-beta))
        (alpha                 (fm-map (connections group-alpha)
                                       #'%flat-adjacency))
        (beta                  (fm-map (connections molecule-beta)
                                       #'%flat-adjacency))
        (results               '()))
    (labels ((column-free-from-ones (matrix target-row column)
               (loop for r from 0 below (fm-h matrix) do
                    (when (and (= (fmref matrix r column) 1)
                               (< r target-row))
                      (return-from column-free-from-ones nil)))
               t)
             (%subgraph-isomorphism (alpha beta perm-mat d)
               (if (< d (fm-h perm-mat)) ;; we are not in the last row
                   (loop for i from 0 below (fm-w perm-mat) do
                        (when (= (fmref perm-mat d i) 1)
                          (let ((pruned (prune perm-mat group-alpha molecule-beta)))
                            (loop for j from 0 below (fm-w perm-mat) do
                                 (when (/= j i)
                                   (setf (fmref pruned d j) 0)))
                            (when (column-free-from-ones pruned d i)
                              (%subgraph-isomorphism alpha beta pruned (1+ d))))))
                   (when (isomorphic-p alpha beta ;; reached max depth here
                                       (connections group-alpha) (connections molecule-beta)
                                       perm-mat)
                     (push perm-mat results) ; maybe will be useful getting all matching some day :)
                     (return-from subgraph-isomorphism t)))))
      (%subgraph-isomorphism alpha beta permutation-matrix 0)
      nil)))
