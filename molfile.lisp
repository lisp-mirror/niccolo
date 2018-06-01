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

(in-package :molfile)

(define-constant +magic-number+ "V2000" :test #'string=)

(define-constant +charge-translation-table+
    '((0 . 0)
      (1 . 3)
      (2 . 2)
      (3 . 1)
      (4 . 999) ;; doublet?
      (5 . -1)
      (6 . -2)
      (7 . -3))
  :test #'equalp)

(defun translate-charge (a)
  (or (cdr (assoc a +charge-translation-table+ :test #'=))
      0))

(cl-lex:define-string-lexer lexer
  ("\\p{White_Space}*-?[0-9]+\\.[0-9]{4}"
   (return (values 'float-block  (parse-number $@))))
  ("-[0-9]{1,2} "
   (return (values 'signed-integer-block (parse-integer $@))))
  ("([0-9]{3})|(\\p{White_Space}{2}[0-9]{1})|(\\p{White_Space}{1}[0-9]{2})"
   (return (values 'integer-block (parse-integer $@))))
  ("M  END"
   (return (values 'mend $@)))
  ("^(A|M|S|V)  .+"
   (return (values 'property $@)))
  ("([a-z,A-Z,\\*,#]{3})|([a-z,A-Z,\\*,#]{2}\\p{White_Space}{1})|([a-z,A-Z,\\*,#]{1}\\p{White_Space}{2})"
   (return (values 'atom-label (string-trim '(#\space) $@))))
  ("(-?[0-9]{1})|(\\p{White_Space}[0-9]{1})"
   (return (values 'mass-difference (parse-integer $@))))
  ("\\p{White_Space}{3}"
   (return (values 'empty-integer-block $@)))
  ("\\p{White_Space}*V2000"
   (return (values 'magic-number (string-trim '(#\space) $@))))
  ("\\p{White_Space}"
   (return (values 'single-space  $@)))
  (".+"
   (return (values 'junk  $@))))

(eval-when (:compile-toplevel :load-toplevel :execute)

  (defparameter *parsed-mol-file* nil)

  (defparameter *atoms-count*     -1)

  (defparameter *bonds-count*     -1)

  (defparameter *stop*            nil)

  (defun tokenizer (stream)
    (labels ((%read-line ()
               (let ((raw (read-line stream nil nil)))
                 (and raw
                      (string-trim '(#\Return) raw)))))
      (let ((line nil)
            (lex  nil))
        #'(lambda ()
            (if *stop*
                (values nil nil)
                (progn
                  (when (not line)
                    (setf line (%read-line)
                          lex  (lexer line)))
                  (labels ((next-token ()
                             (multiple-value-bind (symbol value)
                                 (funcall lex)
                               (if symbol
                                   (values symbol value)
                                   (progn
                                     (setf line (%read-line)
                                           lex  (lexer line))
                                     (if line
                                         (next-token)
                                         (values nil nil)))))))
                    (multiple-value-bind (a b)
                        (next-token)
                      ;;(format t "~s ~s~%" a b)
                      (values a b)))))))))

  (defun yy-parse-count-line (&rest params)
    (if (string/= (lastcar params) +magic-number+)
        (error (format nil "Wrong magic number ~a" (lastcar params)))
        (let ((atoms-count  (first params)))
          (setf (connections *parsed-mol-file*)
                (make-fmatrix atoms-count atoms-count))))
    params)

  (defun yy-parse-atom-spec (&rest params)
    (let ((x      (elt params 0))
          (y      (elt params 1))
          (z      (elt params 2))
          (label  (elt params 4))
          (charge (translate-charge (elt params 6))))
      (vector-push-extend (make-instance 'ch-atom
                                         :x      x
                                         :y      y
                                         :z      z
                                         :label  label
                                         :charge charge)
                          (atoms *parsed-mol-file*))))

  (defun yy-parse-bond-spec (&rest params)
    (with-accessors ((connections connections)) *parsed-mol-file*
      (let ((a-idx     (elt params 0))
            (b-idx     (elt params 1))
            (bond-type (elt params 2)))
      (setf (fmref (connections *parsed-mol-file*) (1- a-idx) (1- b-idx)) bond-type)
      (setf (fmref (connections *parsed-mol-file*) (1- b-idx) (1- a-idx)) bond-type))))

  (yacc:define-parser *parser*
    (:print-derives-epsilon t)
    (:start-symbol molfile)
    (:terminals (integer-block empty-integer-block
                               float-block   empty-float-block
                               atom-label    magic-number
                               single-space  mass-difference
                               junk mend property))
    (molfile    (count-line atom-block bond-block properties))
    (count-line
     (atom-count bond-count atom-list-count obsolete chiral-flag stext-count obsolete obsolete
                 obsolete obsolete additional-properties-count magic-number #'yy-parse-count-line))
    (atom-block
     (atom-spec)
     (atom-spec atom-block))
    (bond-block
     (bond-spec)
     (bond-spec bond-block))
    (bond-spec
     (first-atom second-atom bond-type bond-stereo ignored bond-topology reacting-center-status
                 #'yy-parse-bond-spec))
    (atom-spec
     (x y z single-space atom-label mass-difference charge stereo-par hydrogen-count
        stereo-care valence h0 ignored ignored atom-atom-mapping inversion/retention exact-change
        #'yy-parse-atom-spec))
    (properties
     property
     (property properties)
     mend)
    (x                           float-block)
    (y                           float-block)
    (z                           float-block)
    (first-atom                  integer-block empty-integer-block)
    (second-atom                 integer-block empty-integer-block)
    (bond-type                   integer-block empty-integer-block)
    (bond-stereo                 integer-block empty-integer-block)
    (bond-topology               integer-block empty-integer-block)
    (reacting-center-status      integer-block empty-integer-block)
    (charge                      integer-block empty-integer-block)
    (stereo-par                  integer-block empty-integer-block)
    (hydrogen-count              integer-block empty-integer-block)
    (stereo-care                 integer-block empty-integer-block)
    (valence                     integer-block empty-integer-block)
    (h0                          integer-block empty-integer-block)
    (atom-atom-mapping           integer-block empty-integer-block)
    (inversion/retention         integer-block empty-integer-block)
    (exact-change                integer-block empty-integer-block)
    (atom-count                  integer-block)
    (bond-count                  integer-block)
    (atom-list-count             integer-block empty-integer-block)
    (chiral-flag                 integer-block empty-integer-block)
    (stext-count                 integer-block empty-integer-block)
    (additional-properties-count integer-block empty-integer-block)
    (obsolete                    integer-block empty-integer-block)
    (ignored                     integer-block empty-integer-block)
    (magic-number)))

(defun parse-mdl (mol-in-memory)
  (handler-case
      (with-input-from-string (stream mol-in-memory)
        (and
         (read-line stream nil nil)
         (read-line stream nil nil)
         (read-line stream nil nil)
         (let ((*parsed-mol-file* (make-instance 'molecule))
               (*atoms-count*     -1)
               (*bonds-count*     -1))
           (progn
             (yacc:parse-with-lexer (tokenizer stream) *parser*)
             *parsed-mol-file*))))
    (error () nil)))
