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

(in-package :images-utils)

(defmacro with-http-png-reply ((w h) &body body)
  (with-gensyms (stream)
    `(progn
       (setf (tbnl:header-out :content-type) "image/png")
       (flexi-streams:with-output-to-sequence (,stream :element-type '(unsigned-byte 8))
	 (cl-gd:with-image* (,w ,h t)
	   ,@body
	   (cl-gd:write-png-to-stream ,stream))))))

(define-constant +graph-x-offset+         0.1  :test #'=)

(define-constant +graph-y-offset+         0.1  :test #'=)

(define-constant +tic-h+                 -5    :test #'=)

(define-constant +big-tic-h+             -8    :test #'=)

(define-constant +graph-point-radius+     0.007 :test #'=)

(define-constant +default-graph-w+     1366    :test #'=)

(define-constant +default-graph-h+      768    :test #'=)

(defun coord->norm (a max)
  (clamp (/ a max) 0.0 1.0))

(defun norm->coord (a max)
  (clamp (* a max) 0 max))

(defmacro with-allocated-color ((color r g b) &body body)
  `(let ((,color (cl-gd:allocate-color ,r ,g ,b)))
     ,@body
     (cl-gd:deallocate-color ,color)))

(defun fill-bg (r g b)
  (with-allocated-color (color r g b)
    (cl-gd:draw-rectangle* 0 0
			   (cl-gd:image-width)
			   (cl-gd:image-height)
			   :filled t
			   :color color)))

(defun graph-x-origin ()
  (norm->coord +graph-x-offset+ (cl-gd:image-width)))

(defun graph-y-end ()
  (norm->coord +graph-y-offset+ (cl-gd:image-height)))

(defun graph-x-end ()
  (- (cl-gd:image-width) (norm->coord +graph-x-offset+ (cl-gd:image-width))))

(defun graph-y-origin ()
  (- (cl-gd:image-height) (norm->coord +graph-y-offset+ (cl-gd:image-height))))

(defmacro with-normalized-draw ((x y) &body body)
  (with-gensyms (x-offset-denorm y-offset-denorm
		 x-denorm        y-denorm)
  `(let* ((,x-offset-denorm (norm->coord +graph-x-offset+ (cl-gd:image-width)))
	  (,y-offset-denorm (norm->coord +graph-y-offset+ (cl-gd:image-height)))
	  (,x-denorm        (norm->coord ,x (- (cl-gd:image-width)  ,x-offset-denorm)))
	  (,y-denorm        (norm->coord ,y (- (cl-gd:image-height) ,y-offset-denorm))))
     (cl-gd:with-transformation (:x1     (- (+ ,x-offset-denorm ,x-denorm))
				 :y1     (- (+ ,y-offset-denorm ,y-denorm))
				 :width  (+ (cl-gd:image-width)  ,x-offset-denorm)
				 :height (+ (cl-gd:image-height) ,y-offset-denorm))
       ,@body))))

(defun draw-graph-point-norm (x y r g b)
  (with-allocated-color (color r g b)
    (with-allocated-color (contour 60 60 60)
    (with-normalized-draw (x y)
      (let ((radius (norm->coord +graph-point-radius+ (cl-gd:image-width))))
	(cl-gd:draw-arc 0 0
			radius radius
			0.0 (* 2 pi)
			:center-connect t
			:filled t
			:color color)
	(cl-gd:draw-arc 0 0
			radius radius
			0.0 (* 2 pi)
			:center-connect nil
			:filled nil
			:color contour))))))

(defun draw-graph-x-axis (&key (tics-number 10) (major 2) (tics-label '("12:00" "01:00" "02:00")))
  (with-allocated-color (color 0 0 0)
    (let ((untransformed-w (cl-gd:image-width))
	  (untransformed-h (cl-gd:image-height)))
      (with-normalized-draw (0.0 0.0)
	(cl-gd:draw-line 0
			 0
			 (- (cl-gd:image-width)
			    (* 2.0 (norm->coord +graph-x-offset+ untransformed-w)))
			 0
			 :color color)
	(loop
	   for i           from  0.0 below 1.01 by (/ 1.0 tics-number)
	   for m           from  0
	   for label-index from  0 by 1
	   do
	     (with-normalized-draw (i 0.0)
	       (cl-gd:draw-line 0
				0
				0
				(if (= (rem m major) 0)
				    +big-tic-h+
				    +tic-h+)
				:color color)
	       (if (and (or (= (rem m major) 0)
			    (< (length tics-label) 100))
			(< label-index (length tics-label)))
		   (cl-gd:draw-string 0
				      (- (norm->coord +graph-y-offset+ untransformed-h))
				      (elt tics-label label-index)
				      :font :medium-bold
				      :up t
				      :color color))))))))

(defun %fractional-part (a magn)
  (multiple-value-bind (i f)
      (round (/ a magn))
    (declare (ignore i))
    f))

(defun %sign (a)
  (if (< a 0)
      -1
      +1))

(defun prune-tics-y-axis (min max min-value max-value tics-suggested step)
  (let* ((all-positive (loop for i from 0.0 below  (+ max step) by step collect i))
	 (all-negative (loop for i from (- step) downto (- min step) by step collect i))
	 (all          (remove-if #'(lambda (a)
				      (or (< a (- min-value step))
					  (> a (+ max-value step))))
				  (nconc (reverse all-negative) all-positive))))
    (if (<= (length all) tics-suggested)
	all
	(prune-tics-y-axis min max min-value max-value tics-suggested (* 2 step)))))

(defun scale-y-axis (labels-axis tics-number)
  (let* ((num-axis  (mapcar #'parse-number:parse-number labels-axis))
	 (max-axis  (reduce #'max num-axis))
	 (min-axis  (reduce #'min num-axis))
	 (magn-max (expt 10  (truncate (log (max 1e-10 (abs max-axis)) 10))))
	 (magn-min (expt 10  (truncate (log (max 1e-10 (abs min-axis)) 10)))) ; dealing with 0...
	 (max      (* (%sign max-axis)
		      (+ (abs max-axis)
			 (- magn-max (abs (* magn-max
					     (%fractional-part max-axis
							       magn-max)))))))
	 (min      (* (%sign min-axis)
		      (+ (abs min-axis)
			 (- magn-min (abs (* magn-min
					     (%fractional-part min-axis
							       magn-min)))))))
	 (all      (prune-tics-y-axis min max min-axis max-axis tics-number (max (/ magn-max 10)
										 (/ magn-min 10)))))
     all))

(defun draw-graph-y-axis (&key
			   (tics-number 10)
			   (major 2)
			   (tics-label '("0.00" "2.00" "4.00" "6.00" "8.00" "10.00")))
  (with-allocated-color (color 0 0 0)
    (let* ((untransformed-w (cl-gd:image-width))
	   (untransformed-h (cl-gd:image-height))
	   (actual-y-label  (scale-y-axis tics-label tics-number))
	   (tic-step        (/ 1.0 (1- (length actual-y-label)))))
      (with-normalized-draw (0.0 0.0)
	(cl-gd:draw-line 0 0                                                          ; x1 y1
			 0 (- (cl-gd:image-height)                                    ;
			      (* 2.0 (norm->coord +graph-y-offset+ untransformed-h))) ; x2 y2
			 :color color)
	(loop
	   for i     from 0.0 to 1.01 by tic-step
	   for m     from 0
	   for label in actual-y-label
	   do
	     (with-normalized-draw (0.0 i)
	       (cl-gd:draw-line 0
				0
				(if (= (rem m major) 0)
				    +big-tic-h+
				    +tic-h+)
				0
				:color color)
	       (if (= (rem m major) 0)
		   (cl-gd:draw-string (- (norm->coord +graph-x-offset+ untransformed-w))
				      0
				      (format nil "~,2f" label)
				      :font :medium-bold
				      :up nil
				      :color color))))))))

(defun draw-graph (xs ys &optional
			   (y-tics-number 20)
			   (major-tic 2))
  (images-utils:with-http-png-reply (+default-graph-w+ +default-graph-h+)
    (if (and (> (length xs) 1)
	     (> (length ys) 1)
	     (= (length xs)
		(length ys)))
	(let* ((actual-y-range (scale-y-axis ys y-tics-number))
	       (max-y          (reduce #'max actual-y-range))
	       (min-y          (reduce #'min actual-y-range))
	       (x-step   (/ 1.0 (length xs)))
	       (slope    (/ 1.0 (- max-y min-y)))
	       (q        (- (* slope min-y)))
	       (norm-y   (map 'vector
			      #'(lambda (a) (+ (* slope
						  (parse-number:parse-number a))
					       q))
			      ys))
	       (norm-x   xs))
	  (fill-bg 255 255 255)
	  (draw-graph-x-axis :tics-number (length xs)
			     :major       (max 1 (truncate (/ (length xs) 10)))
			     :tics-label  norm-x)
	  (draw-graph-y-axis :tics-number y-tics-number
			     :major       major-tic
			     :tics-label  ys)
	  (loop
	     for i from 0
	     for x from 0.0 by x-step
	     for y across norm-y      do
	       (draw-graph-point-norm x
				      y
				      255 0 0)))

	(with-allocated-color (fg 255 255 0)
	  (fill-bg 0 0 0)
	  (cl-gd:draw-string (truncate (* 0.1 (cl-gd:image-width)))
			     (truncate (* 0.1 (cl-gd:image-height)))
			     (_ "Error occurred while processing data")
			     :font :giant
			     :up nil
			     :color fg)))))

(defun %draw-subdiamond (r g b x y size &optional (filled t))
  (with-allocated-color (color r g b)
    (with-allocated-color (bg 0 0 0)
      (let ((fg-x (1+ x))
	    (fg-y (1+ y)))
	(cl-gd:draw-rectangle* x y (+ x size) (+ y size) :filled filled :color bg)
	(when filled
	  (cl-gd:draw-rectangle* fg-x fg-y
				 (+ fg-x (- size 2))
				 (+ fg-y (- size 2))
				 :filled filled
				 :color  color))))))

(defun draw-hazard-diamond (size &key (hazard t) (fire t) (reactive t) (corrosive t))
  (let* ((diag         (floor (sqrt (* 2 (expt size 2)))))
	 (inner-size   (1- size))
	 (inner-size/2 (floor (/ inner-size 2))))
    (images-utils:with-http-png-reply (diag diag)
      (with-allocated-color (transparent 255 255 255)
	(fill-bg 255 255 255)
	(setf (cl-gd:transparent-color) transparent)
	(cl-gd:with-image (orig size size t)
	  (cl-gd:with-default-image (orig)
	    (fill-bg 255 255 255)
	    (when hazard
	      (%draw-subdiamond 0 0 255 0 0 inner-size/2))
	    (when fire
	      (%draw-subdiamond 255 0 0 inner-size/2 0 inner-size/2))
	    (when reactive
	      (%draw-subdiamond 255 255 0 0 inner-size/2 inner-size/2))
	    (when corrosive
	      (%draw-subdiamond 0 255 0 inner-size/2 inner-size/2 inner-size/2))
	    (%draw-subdiamond 0 0 0 0            0            inner-size/2 nil)
	    (%draw-subdiamond 0 0 0 inner-size/2 0            inner-size/2 nil)
	    (%draw-subdiamond 0 0 0 0            inner-size/2 inner-size/2 nil)
	    (%draw-subdiamond 0 0 0 inner-size/2 inner-size/2 inner-size/2 nil))
	  (cl-gd:copy-image orig
			    cl-gd:*default-image*
			    0 0
			    (/ diag 2) (/ diag 2)
			    size size
			    :rotate t
			    :angle  45))))))
