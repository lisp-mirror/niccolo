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

(in-package :ps-utils)

(define-constant +page-rendering-max-w+    200 :test #'=)

(define-constant +a4-landscape-page-sizes+ (make-instance 'page-size :width 297 :height 210)
  :test #'ps::page-size-equal-p)

(defmacro with-save-restore ((doc) &body body)
  `(progn
     (save ,doc)
     ,@body
     (restore ,doc)))

(defun render-chemprod-barcode-x-y (doc id x y)
  (let ((barcode (make-instance 'brcd:code128))
        (product (crane:single 'db:chemical-product :id (parse-integer id))))
    (set-parameter doc +parameter-key-searchpath+
                      (namestring (local-system-path +data-path+)))
    (brcd:parse barcode (string-utils:encode-barcode (db:id product)))
    (save doc)
    (translate doc
                  (- x (/ (brcd:width barcode) 2))
                  (- (- (height +a4-page-size+) y) (brcd:height barcode)))
    (brcd:draw barcode doc)
    (let ((font (findfont doc +default-font-name+ "" t)))
      (setcolor doc +color-type-fillstroke+ (cl-colors:rgb 0.0 0.0 0.0))
      (setfont doc font 5.0)
      (show-boxed doc (format nil "~a ~a"
                                 (db:id product)
                                 (db:name (crane:single 'db:chemical-compound
                                                        :id (db:compound product))))
                     0
                     0
                     (brcd:width barcode)
                     0
                     +boxed-text-h-mode-center+
                     ""))
    (restore doc)
    (brcd:height barcode)))

(defun render-simple-label-barcode (doc text &key
                                               (w 80.0)
                                               (h 40.0)
                                               (font-size (/ h 2))
                                               (padding 5.0))
  (let ((font (default-font doc))
        (barcode (make-instance 'brcd:code128)))
    (ps:setcolor doc ps:+color-type-fillstroke+ (cl-colors:rgb 0.0 0.0 0.0))
    (ps:setfont doc font font-size)
    (brcd:parse barcode (string-utils:encode-barcode text))
    (with-save-restore (doc)
      (ps:scale doc
                 (/ w (brcd:width barcode))
                 (/ h (+ padding font-size (brcd:height barcode))))
      (with-save-restore (doc)
         (ps:translate doc padding padding)
         (brcd:draw barcode doc))
      (with-save-restore (doc)
        (ps:draw-text-confined-in-box doc
                                      font
                                      text
                                      padding                           ; left
                                      (+ padding (brcd:height barcode)) ; top
                                      (brcd:width barcode)              ; width
                                      font-size                         ; height
                                      :vertical-align :bottom)))
    h))

(defun render-simple-label (doc text &key
                                       (add-barcode t)
                                       (w 80.0)
                                       (h 40.0)
                                       (font-size (/ h 2))
                                       (padding 5.0))
  (if add-barcode
      (render-simple-label-barcode doc text :w w :h h :font-size font-size :padding padding)
      (let ((font (default-font doc)))
        (ps:setcolor doc ps:+color-type-fillstroke+ (cl-colors:rgb 0.0 0.0 0.0))
        (with-save-restore (doc)
          (ps:draw-text-confined-in-box doc
                                        font
                                        text
                                        padding             ; left
                                        padding             ; top
                                        (- w (* 2 padding)) ; width
                                        font-size           ; height
                                        :vertical-align :center))
        h)))

(define-constant +sample-labels-padding+ 1.0 :test #'=)

(defun render-many-sample-barcodes (all-ids w h use-barcode)
  (let ((doc (make-instance 'psdoc :page-size +a4-page-size+))
        (*callback-string* ""))
    (open-doc doc nil)
    (set-parameter doc
                   +parameter-key-searchpath+
                   (namestring (local-system-path +data-path+)))
    (begin-page doc)
    (do ((ids all-ids (rest ids))
         (y  +page-margin-top+)
         (x  +sample-labels-padding+))
        ((null ids))
      (when (validation:id-valid-and-used-p 'db:chemical-sample (first-elt ids))
        (let ((sample (crane:single 'db:chemical-sample :id (first-elt ids))))
          (when (>= (+ x w) +page-rendering-max-w+)
            (setf x +sample-labels-padding+)
            (incf y h))
          (when (> (+ y h) (- (height +a4-page-size+) +page-margin-top+))
            (end-page doc)
            (begin-page doc)
            (setf y +page-margin-top+)
            (setf x +sample-labels-padding+))
          (with-save-restore (doc)
            (translate doc x y)
            (with-save-restore (doc)
              (ps:setlinewidth doc (max 0.1 (/ w 500)))
              (ps:setcolor doc ps:+color-type-fillstroke+ cl-colors:+red+)
              ;; hline
              (ps:moveto doc +sample-labels-padding+ +sample-labels-padding+)
              (ps:lineto doc w +sample-labels-padding+)
              ;; vline
              (ps:moveto doc +sample-labels-padding+ 0)
              (ps:lineto doc +sample-labels-padding+ h)
              (ps:stroke doc))
            (render-simple-label doc
                                 (db:name sample)
                                 :add-barcode use-barcode
                                 :w           w
                                 :h           h))
          (incf x w))))
    (end-page doc)
    (close-doc doc)
    (shutdown)
    *callback-string*))

(defmacro with-a4-lanscape-ps-doc ((doc) &body body)
  `(let ((,doc (make-instance 'psdoc :page-size +a4-landscape-page-sizes+))
         (*callback-string* ""))
     (set-parameter ,doc +parameter-key-imagereuse+ +false+)
     (set-info ,doc +ps-comment-key-orientation+ "Portrait")
     (open-doc ,doc nil)
     (let ((img-header (open-image-file ,doc +image-file-type-eps+
                                           (namestring (local-system-path +letter-header+))
                                           "" 0)))
       (begin-page ,doc)
       (set-parameter ,doc +parameter-key-searchpath+
                         (namestring (local-system-path +data-path+)))
       (place-image ,doc img-header 0.0 (- 210 +header-image-export-height+) 1.0)
       ,@body
       (end-page ,doc)
       (close-doc ,doc)
       (shutdown)
       *callback-string*)))

(defmacro with-custom-size-ps-doc ((doc w h) &body body)
  `(let ((,doc (make-instance 'psdoc :page-size (make-instance 'page-size :width ,w :height ,h)))
         (*callback-string* ""))
     (set-info ,doc +ps-comment-key-orientation+ "Portrait")
     (open-doc ,doc nil)
     (begin-page ,doc)
     (set-parameter ,doc +parameter-key-searchpath+
                    (namestring (local-system-path +data-path+)))
     ,@body
     (end-page ,doc)
     (close-doc ,doc)
     (shutdown)
     *callback-string*))

(defmacro with-a4-ps-doc ((doc) &body body)
  `(let ((,doc (make-instance 'psdoc :page-size +a4-page-size+))
         (*callback-string* ""))
     (open-doc ,doc nil)
     (let ((img-header (open-image-file ,doc +image-file-type-png+
                                           (namestring (local-system-path +letter-header+))
                                           "" 0)))
       (begin-page ,doc)
       (set-parameter ,doc +parameter-key-searchpath+
                         (namestring (local-system-path +data-path+)))
       (place-image ,doc img-header 0.0 (- 297 +header-image-export-height+) 1.0))
       ,@body
       (end-page ,doc)
       (close-doc ,doc)
       (shutdown)
       *callback-string*))

(let ((memoized-font nil)
      (memoized-doc  nil))
  (defun default-font (doc)
    "Note assume +parameter-key-searchpath+ is correctly set"
    (if (and memoized-font
             (or (not memoized-doc)
                 (eq  memoized-doc doc))
             (> memoized-font 0))       ; find-font  return a positive number on
                                        ; success, we  do not want to  memoize a
                                        ; failure
        memoized-font
        (let ((font-handle (findfont doc +default-font-name+ "" t)))
          (setf memoized-font font-handle
                memoized-doc  doc)
          memoized-font))))

(defun render-many-chemprod-barcodes (ids)
  (let ((doc (make-instance 'psdoc :page-size +a4-page-size+))
        (*callback-string* "")
        (saved-barcode-h  0))
    (open-doc doc nil)
    (begin-page doc)
    (loop
       for id in ids
       for y from +page-margin-top+ do
         (when (and (scan validation:+pos-integer-re+ id)
                    (crane:single 'db:chemical-product :id (parse-integer id)))
           (when (> (+ y saved-barcode-h) (- (height +a4-page-size+) +page-margin-top+))
             (end-page doc)
             (begin-page doc)
             (setf y +page-margin-top+))
           (let ((h-barcode (render-chemprod-barcode-x-y doc id (/ (width +a4-page-size+) 2) y)))
             (setf saved-barcode-h (+ h-barcode (* 0.125 h-barcode)))
             (setf y (+ y h-barcode (* 0.125 h-barcode))))))
    (end-page doc)
    (close-doc doc)
    (shutdown)
    *callback-string*))
