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

(in-package :risk-calculator)

(defparameter *errors* '())

(defun r-factor (r-keys)
  (if (not (null r-keys))
      (reduce (lambda (a b)
		(handler-bind ((conditions:null-reference
				#'(lambda(e)
				    (progn
				      (push (conditions:text e) *errors*)
				      (invoke-restart 'risk-phrases::use-0)))))
		  (+ a
		     (risk-phrases:get-points b))))
	      r-keys :initial-value 0)
      	(progn
	  (push (_ "No \"H phrases\" found") *errors*)
	  10.0)))

(alexandria:define-constant +exposition-type-el-root+ "exposition_type"
  :test #'equal)

(alexandria:define-constant +inalation-el+ "inalation"
  :test #'equal)

(alexandria:define-constant +skin-possible+ "skin_possible"
  :test #'equal)

(alexandria:define-constant +skin-accidental+ "skin_accidental"
  :test #'equal)

(configuration-utils:define-conffile-reader (exposition-type (+exposition-type-el-root+ nil nil))
    inalation
  skin_possible
  skin_accidental)

(defparameter *exposition-table* (read-exposition-type-config config:*exposition-type*))

(defun t-factor-extract (key)
  (let ((t-fact (gethash key *exposition-table*)))
    (if (not (null t-fact))
	(parse-number t-fact)
	(progn
	  (push (format nil (_ "Exposition type ~a not found") key) *errors*)
	  0.0))))

(defun t-factor (keys)
  (if (not (null keys))
      (reduce (lambda (a b)
		(+ a
		   (t-factor-extract b)))
	      keys :initial-value 0)
      (progn
	(push (_ "Exposition type not specidied") *errors*)
	10.0)))

(alexandria:define-constant +physical-state-el-root+ "physical_state"  :test #'equal)

(alexandria:define-constant +m-r1+                   "m_r1"            :test #'equal)

(alexandria:define-constant +q-r1+                   "q_r1"            :test #'equal)

(alexandria:define-constant +m-r2+                   "m_r2"            :test #'equal)

(alexandria:define-constant +q-r2+                   "q_r2"            :test #'equal)

(alexandria:define-constant +liquid-gas+             "+liquid-gas+"    :test #'equal)

(alexandria:define-constant +highly-volatile+        "highly_volatile" :test #'equal)

(alexandria:define-constant +medium-volatile+        "medium_volatile" :test #'equal)

(alexandria:define-constant +low-volatile+           "low_volatile"    :test #'equal)

(alexandria:define-constant +powder+                 "powder"          :test #'equal)

(alexandria:define-constant +solid+                  "solid"           :test #'equal)

(configuration-utils:define-conffile-reader (physical-state (+physical-state-el-root+ nil nil))
    m_r1
  q_r1
  m_r2
  q_r2
  highly_volatile
  medium_volatile
  low_volatile
  powder
  solid)

(defparameter *physical-state-table* (read-physical-state-config config:*physical-state*))

(defun s-factor-value->string (number)
  (let ((res nil))
    (maphash #'(lambda (k v)
		 (when (= number (parse-number v))
		   (setf res (cl-i18n:translate k))))
	     *physical-state-table*)
    res))

(defun s-factor-table (key)
  (let ((s-fact (gethash key *physical-state-table*)))
    (if (not (null s-fact))
	(parse-number s-fact)
	(progn
	  (push (format nil (_ "Physical state ~a not found") key) *errors*)
	  0.0))))

(defun s-factor-graph (temp boiling-point)
  (cond
    ((< boiling-point (+ (* temp (s-factor-table +m-r1+)) (s-factor-table +q-r1+)))
     (s-factor-table +highly-volatile+))
    ((< (+ (* temp (s-factor-table +m-r1+)) (s-factor-table +q-r1+))
	boiling-point
	(+ (* temp (s-factor-table +m-r2+)) (s-factor-table +q-r2+)))
     (s-factor-table +medium-volatile+))
    (t (s-factor-table +low-volatile+))))

(defun s-factor (state &optional (temp 0) (boiling-point 0))
  (cond
    ((or (string-equal state +powder+)
	 (string-equal state +solid+))
     (s-factor-table state))
    ((or
      (string-equal state +liquid-gas+)
      (string-equal state +highly-volatile+)
      (string-equal state +medium-volatile+)
      (string-equal state +low-volatile+))
     (s-factor-graph temp boiling-point))
    (t
     (push (format nil (_ "Physical state ~a not found") state) *errors*)
     0.0)))

(alexandria:define-constant +exposition-time-el-root+ "exposition_time"
  :test #'equal)

(alexandria:define-constant +tlv-twa+ "TLV-TWA"
   :test #'equal)
(alexandria:define-constant +tlv-stel+ "TLV-STEL"
  :test #'equal)
(alexandria:define-constant +tlv-ceiling+ "TLV-Ceiling"
  :test #'equal)

(configuration-utils:define-conffile-reader (exposition-time (+exposition-time-el-root+ nil nil))
    tlv-twa
  tlv-stel
  tlv-ceiling)

(defparameter *exposition-time-table* (read-exposition-time-config config:*exposition-time*))

(defun e-factor (time key)
  (let ((exposition (gethash key *exposition-time-table*)))
    (if (not (null exposition))
	(/ time (parse-number exposition))
	(progn
	  (push (format nil (_ "Exposition time ~a not found") key) *errors*)
	  0.0))))

(alexandria:define-constant +usage-el-root+ "usage"
  :test #'equal)

(alexandria:define-constant +almost-closed-system+ "almost_closed_system"
   :test #'equal)
(alexandria:define-constant +matrix-inclusion+ "matrix_inclusion"
  :test #'equal)

(alexandria:define-constant +low-dispersion+ "low_dispersion"
  :test #'equal)

(alexandria:define-constant +high-dispersion+ "high_dispersion"
  :test #'equal)

(configuration-utils:define-conffile-reader (usage (+usage-el-root+ nil nil))
    almost_closed_system
  matrix_inclusion
  low_dispersion
  high_dispersion)

(defparameter *usage-table* (read-usage-config config:*usage*))

(defun u-factor (key)
  (let ((usage (gethash key *usage-table*)))
    (if (not (null usage))
	(parse-number usage)
	(progn
	  (push (format nil (_ "Usage ~a not found") key) *errors*)
	  0.0))))

(alexandria:define-constant +quantity-el+ "quantity"
  :test #'equal)

(alexandria:define-constant +segment-el+ "segment"
  :test #'equal)

(alexandria:define-constant +qmin-el+ "qmin"
  :test #'equal)

(alexandria:define-constant +qmax-el+ "qmax"
  :test #'equal)

(alexandria:define-constant +min-el+ "min"
  :test #'equal)

(alexandria:define-constant +max-el+ "max"
  :test #'equal)

(defun line-eqn(a b &optional (thresh 1e-5))
  "Calculate a bidimensional line equation crossing vector a and b.
   Return a list containing m q and two flag indicating if the line is
   parallel to x or y respectively"
  (let ((dy (- (second b) (second a)))
	(dx (- (first b)  (first a))))
    (cond
      ((<= 0 dy thresh) ;parallel to x
       (list 0 (second b) t nil))
      ((<= 0 dx thresh) ; parallel to y
       (list 0 0 nil t))
      (t
       (list (/ dy dx) (- (second a ) (* (/ dy dx) (first a))) nil nil)))))

(defun get-graph-quantity (path)
  "results is a list of elements '(minx max '(equation)), where equation is the results of graphics-utils:line-eqn"
  (labels ((get-segment (node)
	     (xml-utils:with-tagmatch (+segment-el+ node)
	       (setf node (xmls:xmlrep-children node))
	       (let ((qmin (xml-utils:with-tagmatch (+qmin-el+ (first node))
			     (parse-number
			      (first (xmls:xmlrep-children (first node))))))
		     (qmax (xml-utils:with-tagmatch (+qmax-el+ (second node))
			     (parse-number
			      (first (xmls:xmlrep-children (second node))))))
		     (min (xml-utils:with-tagmatch (+min-el+ (third node))
			    (parse-number
			     (first (xmls:xmlrep-children (third node))))))
		     (max (xml-utils:with-tagmatch (+max-el+ (fourth node))
			    (parse-number
			     (first (xmls:xmlrep-children (fourth node)))))))
		 (list qmin qmax (line-eqn (list qmin min) (list qmax max)))))))

    (with-open-file (stream path :direction :input :if-does-not-exist :error)
      (let ((xmls-list (xmls:parse stream)))
	(xml-utils:with-tagmatch (+quantity-el+ xmls-list)
	  (mapcar #'get-segment (xmls:xmlrep-children xmls-list)))))))

(defparameter *quantity-table* (get-graph-quantity config:*quantity*))

(defun q-factor (qty)
  (let ((line (find-if #'(lambda (el) (<= (first el) qty (second el))) *quantity-table*)))
    (if (not (null line))
	(let ((eqn (third line)))
	  (if (third eqn) ; parallel to y
	      (second eqn)
	      (progn
		(+ (* (first eqn) qty) (second eqn)))))
	(push (format nil (_ "Quantity ~a too large") qty) *errors*))))

(defparameter *stock-table* (get-graph-quantity config:*stock*))

(defun d-factor (qty)
  (if (= qty 0)
      1.0
      (let ((*quantity-table* *stock-table*))
	(q-factor qty))))

(alexandria:define-constant +work-type-root+ "work"
  :test #'equal)

(alexandria:define-constant +Maintenance+ "maintenance"
   :test #'equal)

(alexandria:define-constant +normal-job+ "normal_job"
  :test #'equal)

(alexandria:define-constant +cleaning+ "cleaning"
  :test #'equal)

(configuration-utils:define-conffile-reader (work (+work-type-root+ nil nil))
    maintenance
  normal_job
  cleaning)

(defparameter *work-table* (read-work-config config:*work*))

(defun a-factor (key)
  (let ((usage (gethash key *work-table*)))
    (if (not (null usage))
	(parse-number usage)
	(progn
	  (push (format nil (_ "Work type ~a not found") key) *errors*)
	  0.0))))

(alexandria:define-constant +devices-root+ "devices" :test #'equal)

(alexandria:define-constant +good-fume-cupboard+ "good_fume_cupboard" :test #'equal)

(alexandria:define-constant +bad-fume-cupboard+ "bad_fume_cupboard" :test #'equal)

(alexandria:define-constant +no-fume-cupboard+ "no_fume_cupboard" :test #'equal)

(alexandria:define-constant +written-instructions+ "written_instructions" :test #'equal)

(alexandria:define-constant +dpi-coat+ "dpi_coat" :test #'equal)

(alexandria:define-constant +goggles+ "goggles" :test #'equal)

(alexandria:define-constant +gloves+ "gloves" :test #'equal)

(alexandria:define-constant +good-aspiration+ "good_aspiration" :test #'equal)

(alexandria:define-constant +bad-aspiration+ "bad_aspiration" :test #'equal)

(alexandria:define-constant +no-aspiration+ "no_aspiration" :test #'equal)

(alexandria:define-constant +other-manipulation-devices+ "other_manipulation_devices" :test #'equal)

(alexandria:define-constant +specific-skills+ "specific_skills" :test #'equal)

(alexandria:define-constant +separate-collecting-substances+ "separate_collecting_substances" :test #'equal)

(configuration-utils:define-conffile-reader (devices (+devices-root+ nil nil))
    good_fume_cupboard
  bad_fume_cupboard
  no_fume_cupboard
  written_instructions
  dpi_coat
  goggles
  gloves
  good_aspiration
  bad_aspiration
  no_aspiration
  other_manipulation_devices
  specific_skills
  separate_collecting_substances)


(defparameter *devices-table* (read-devices-config config:*devices*))

; NB tutti coefficienti si moltiplicano, in assenza si usa il valore 1

(defun k-factor (keys)
  (labels ((more-than-one (string keys)
	     (> (length (remove-if #'(lambda (i) (not (cl-ppcre:scan string i))) keys)) 1)))
    (if (or (more-than-one "cupboard" keys)
	    (more-than-one "aspiration" keys))
	(progn
	  (push (format nil (_ "Duplicated entry in ~a") keys) *errors*)
	  1)
	(reduce (lambda (a b)
		  (* a
		     (k-factor-extract b)))
		keys :initial-value 1))))


(defun k-factor-extract (key)
  (let ((usage (gethash key *devices-table*)))
    (if (not (null usage))
	(parse-number usage)
	(progn
	  (push (format nil (_ "Devices type ~a not found") key) *errors*)
	  1))))

(defun l-factor-i (r-phrases exposition-types physical-state working-temp boiling-point
		   exposition-time-type exposition-time
		   usage quantity-used quantity-stocked work-type
		   protections-factors safety-threshold)
  (let ((r-factor (r-factor r-phrases))
	(t-factor (t-factor (untranslate exposition-types)))
	(s-factor (s-factor (untranslate physical-state) working-temp boiling-point))
	(e-factor (e-factor exposition-time exposition-time-type))
	(u-factor (u-factor (untranslate usage)))
	(q-factor (q-factor quantity-used))
	(d-factor (d-factor quantity-stocked))
	(a-factor (a-factor (untranslate work-type)))
	(k-factor (k-factor (untranslate protections-factors))))
     ;; (format t "r-factor ~a~%" r-factor)
     ;; (format t "t-factor ~a~%" t-factor)
     ;; (format t "s-factor ~a~%" s-factor)
     ;; (format t "e-factor ~a~%" e-factor)
     ;; (format t "u-factor ~a~%" u-factor)
     ;; (format t "q-factor ~a~%" q-factor)
     ;; (format t "d-factor ~a~%" d-factor)
     ;; (format t "a-factor ~a~%" a-factor)
     ;; (format t "k-factor ~a~%" k-factor)
     ;; (format t "safety-threshold ~a ~%" safety-threshold)
     (values
      (/ (* r-factor t-factor s-factor e-factor q-factor u-factor d-factor a-factor)
	 (* k-factor safety-threshold))
      (list r-factor
	    t-factor
	    s-factor
	    e-factor
	    u-factor
	    q-factor
	    d-factor
	    a-factor
	    k-factor
	    safety-threshold))))

;;;; carcinogenic

(alexandria:define-constant +devices-carc-root+ "devices"
  :test #'equal)

(alexandria:define-constant +closed-lifecycle+ "closed_lifecycle"
   :test #'equal)

(alexandria:define-constant +good-fume-cupboard-lifecycle+ "good_fume_cupboard_lifecycle"
  :test #'equal)

(alexandria:define-constant +partially-fume-cupboard-lifecycle+ "partially_fume_cupboard_lifecycle"
  :test #'equal)

(alexandria:define-constant +no-fume-cupboard-lifecycle+ "no_fume_cupboard_lifecycle"
  :test #'equal)

(configuration-utils:define-conffile-reader (device-carc (+devices-carc-root+ nil nil))
    closed_lifecycle
    good_fume_cupboard_lifecycle
    partially_fume_cupboard_lifecycle
    no_fume_cupboard_lifecycle)

(defparameter *device-carc-table* (read-device-carc-config config:*devices-carc*))

(defun p-factor-carc-extract (key)
  (let ((p-fact (gethash key *device-carc-table*)))
    (if (not (null p-fact))
	(parse-number p-fact)
	(progn
	  (push (format nil (_ "Protective device \"~a\" not found") key) *errors*)
	  0.0))))

(defun p-factor-carc (keys)
  (if (not (null keys))
      (reduce (lambda (a b)
		(+ a
		   (p-factor-carc-extract b)))
	      keys :initial-value 0)
      	(progn
	  (push (_ "Protective device not specified")  *errors*)
	  10.0)))

(configuration-utils:define-conffile-reader (physical-state-carc (+physical_state_carc+ nil nil))
    solid_compact_gel
    non_volatile_liquid_cristals
    fluid_powder_volatile_liquid)

(defparameter *physical-state-carc-table* (read-physical-state-carc-config config:*physical-state-carc*))

(alexandria:define-constant +physical-state-carc+ "physical_state_carc" :test #'equal)

(alexandria:define-constant +solid-compact-gel+ "solid_compact_gel" :test #'equal)

(alexandria:define-constant +non-volatile-liquid-cristals+ "non_volatile_liquid_cristals"
  :test #'equal)

(alexandria:define-constant +fluid-powder-volatile-liquid+ "fluid_powder_volatile_liquid"
  :test #'equal)

(defun s-factor-carc-extract (key)
  (let ((s-fact (gethash key *physical-state-carc-table*)))
    (if (not (null s-fact))
	(parse-number s-fact)
	(progn
	  (push (format nil (_ "Physical state \"~a\" not found") key) *errors*)
	  0.0))))

(defun s-factor-carc (keys)
  (if (not (null keys))
      (reduce (lambda (a b)
		(+ a
		   (s-factor-carc-extract b)))
	      keys :initial-value 0)
      (progn
	(push "Physical state invalid" *errors*)
	10.0)))

(alexandria:define-constant +working-temp+ "working_temp" :test #'equal)

(alexandria:define-constant +threshold+ "threshold" :test #'equal)

(alexandria:define-constant +value+ "value" :test #'equal)

(defun read-threshold-value-xml (path root)
  (labels ((p-threshold (xmls)
	     (xml-utils:get-list-tags-value xmls +threshold+))
	   (p-value (xmls)
	     (xml-utils:get-list-tags-value xmls +value+)))
    (with-open-file (stream path :direction :input :if-does-not-exist :error)
      (let ((xmls-list (xmls:parse stream)))
	(xml-utils:with-tagmatch (root xmls-list)
	  (let* ((thrs (p-threshold (xmls:xmlrep-children xmls-list)))
		 (vals (p-value (first thrs))))
	    (list (mapcar #'parse-number (second thrs))
		  (mapcar #'parse-number (second vals)))))))))

(defparameter *working-temp-carc-table* (read-threshold-value-xml config:*working-temp-carc*
								  +working-temp+))

(defun interval-get-value (interval values twork teb &key comp-first comp-int1 comp-int2 comp-last)
  (loop named main for i from 0 below (length interval) do
       (cond
	 ((= i 0)
	  (when (apply comp-first (list twork (nth i interval) teb))
	    (return-from main (first values))))
	 ((= i (1- (length interval)))
	  (if (apply comp-last (list twork (car (last interval)) teb))
	      (return-from main (car (last values)))
	      (when (and (apply comp-int1 (list twork (nth (1- i) interval) teb))
			 (apply comp-int2 (list twork (nth i interval) teb)))
		(return-from main (nth i values)))))

	 (t
	  (when (and (funcall comp-int1 (* (nth (1- i) interval) teb) twork)
		     (funcall comp-int2 twork (* (nth i interval) teb)))
	    (return-from main (nth i values)))))))

(defun t-factor-carc (twork teb)
  (interval-get-value (first *working-temp-carc-table*) (second *working-temp-carc-table*)
		      twork teb
		      :comp-first #'(lambda (tw in te) (<= tw (* in te)))
		      :comp-int1 #'(lambda (tw in te) (< (* in te) tw))
		      :comp-int2 #'(lambda (tw in te) (<= tw (* in te)))
		      :comp-last #'(lambda (tw in te) (< (* in te) tw))))

(defparameter *quantity-carc-table* (read-threshold-value-xml config:*quantity-carc*
							      +quantity-el+))

(defun q-factor-carc (quantity)
  (interval-get-value (first *quantity-carc-table*) (second *quantity-carc-table*)
		      quantity 1
		      :comp-first #'(lambda (q in i) (declare (ignore i))(< q in))
		      :comp-int1 #'(lambda (q in i) (declare (ignore i))(>= q in))
		      :comp-int2 #'(lambda (q in i) (declare (ignore i))(<= q in))
		      :comp-last #'(lambda (q in i) (declare (ignore i))(> q in))))

(alexandria:define-constant +exposition-time+ "exposition_time"
  :test #'equal)

(configuration-utils:define-conffile-reader (exposition-time-carc (+exposition-time+ nil nil))
    value)

(defparameter *exposition-carc-table* (read-exposition-time-carc-config
				       config:*exposition-time-carc*))

(defun e-factor-carc (min)
  (/ min (parse-number (gethash +value+ *exposition-carc-table*))))

(alexandria:define-constant +frequency+ "frequency" :test #'equal)

(configuration-utils:define-conffile-reader (usage-freq-carc (+exposition-time+ nil nil))
    value)

(defparameter *frequency-carc-table* (read-usage-freq-carc-config config:*frequency-carc*))

(defun f-factor-carc (days)
  (/ days (parse-number (gethash +value+ *frequency-carc-table*))))

(alexandria:define-constant +frac-canc-l-carc+ 25/4)

(defun l-factor-carc-i (protective-device physical-state twork teb quantity-used usage-per-day
			usage-per-year)
  (let* ((p-fact (p-factor-carc (untranslate protective-device)))
	 (s-fact (s-factor-carc (untranslate physical-state)))
	 (t-fact (t-factor-carc twork teb))
	 (q-fact (q-factor-carc quantity-used))
	 (e-fact (e-factor-carc usage-per-day))
	 (f-fact (f-factor-carc usage-per-year))
	 (l-factor (/ (* p-fact s-fact t-fact q-fact e-fact f-fact) +frac-canc-l-carc+)))
    (values l-factor (list p-fact s-fact t-fact q-fact e-fact f-fact))))

;;;; utils
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter *traslation-keys-table* (make-hash-table :test 'equalp))

  (defmacro set-traslation-table (&body keys)
    `(progn
       ,@(mapcar #'(lambda (k) `(setf (gethash ,(string k) *traslation-keys-table*) ,k)) keys)))

  (defun untranslate (el)
    (if (listp el)
	(mapcar #'(lambda (x) (gethash x *traslation-keys-table*)) el)
	(gethash el *traslation-keys-table*)))

  (defun populate-translation-table ()
    (setf (gethash (_ "+inalation-el+") *traslation-keys-table*) +inalation-el+)
    (setf (gethash (_ "+skin-possible+") *traslation-keys-table*) +skin-possible+)
    (setf (gethash (_ "+skin-accidental+") *traslation-keys-table*) +skin-accidental+)
    (setf (gethash (_ "+liquid-gas+") *traslation-keys-table*) +liquid-gas+)
    (setf (gethash (_ "+highly-volatile+") *traslation-keys-table*) +highly-volatile+)
    (setf (gethash (_ "+medium-volatile+") *traslation-keys-table*) +medium-volatile+)
    (setf (gethash (_ "+low-volatile+") *traslation-keys-table*) +low-volatile+)
    (setf (gethash (_ "+powder+") *traslation-keys-table*) +powder+)
    (setf (gethash (_ "+solid+") *traslation-keys-table*) +solid+)
    (setf (gethash (_ "+tlv-twa+") *traslation-keys-table*) +tlv-twa+)
    (setf (gethash (_ "+tlv-stel+") *traslation-keys-table*) +tlv-stel+)
    (setf (gethash (_ "+tlv-ceiling+") *traslation-keys-table*) +tlv-ceiling+)
    (setf (gethash (_ "+almost-closed-system+") *traslation-keys-table*)
	  +almost-closed-system+)
    (setf (gethash (_ "+matrix-inclusion+") *traslation-keys-table*)
	  +matrix-inclusion+)
    (setf (gethash (_ "+low-dispersion+") *traslation-keys-table*) +low-dispersion+)
    (setf (gethash (_ "+high-dispersion+") *traslation-keys-table*) +high-dispersion+)
    (setf (gethash (_ "+Maintenance+") *traslation-keys-table*) +Maintenance+)
    (setf (gethash (_ "+normal-job+") *traslation-keys-table*) +normal-job+)
    (setf (gethash (_ "+cleaning+") *traslation-keys-table*) +cleaning+)
    (setf (gethash (_ "+good-fume-cupboard+") *traslation-keys-table*)
	  +good-fume-cupboard+)
    (setf (gethash (_ "+bad-fume-cupboard+") *traslation-keys-table*)
	  +bad-fume-cupboard+)
    (setf (gethash (_ "+no-fume-cupboard+") *traslation-keys-table*)
	  +no-fume-cupboard+)
    (setf (gethash (_ "+written-instructions+") *traslation-keys-table*)
	  +written-instructions+)
    (setf (gethash (_ "+dpi-coat+") *traslation-keys-table*) +dpi-coat+)
    (setf (gethash (_ "+goggles+") *traslation-keys-table*) +goggles+)
    (setf (gethash (_ "+gloves+") *traslation-keys-table*) +gloves+)
    (setf (gethash (_ "+good-aspiration+") *traslation-keys-table*) +good-aspiration+)
    (setf (gethash (_ "+bad-aspiration+") *traslation-keys-table*) +bad-aspiration+)
    (setf (gethash (_ "+no-aspiration+") *traslation-keys-table*) +no-aspiration+)
    (setf (gethash (_ "+other-manipulation-devices+") *traslation-keys-table*)
	  +other-manipulation-devices+)
    (setf (gethash (_ "+specific-skills+") *traslation-keys-table*)
	  +specific-skills+)
    (setf (gethash (_ "+separate-collecting-substances+") *traslation-keys-table*)
	  +separate-collecting-substances+)
    (setf (gethash (_ "+closed-lifecycle+") *traslation-keys-table*)
	  +closed-lifecycle+)
    (setf (gethash (_ "+good-fume-cupboard-lifecycle+") *traslation-keys-table*)
	  +good-fume-cupboard-lifecycle+)
    (setf (gethash (_ "+partially-fume-cupboard-lifecycle+") *traslation-keys-table*)
	  +partially-fume-cupboard-lifecycle+)
    (setf (gethash (_ "+no-fume-cupboard-lifecycle+") *traslation-keys-table*)
	  +no-fume-cupboard-lifecycle+)
    (setf (gethash (_ "+solid-compact-gel+") *traslation-keys-table*)
	  +solid-compact-gel+)
    (setf (gethash (_ "+non-volatile-liquid-cristals+") *traslation-keys-table*)
	  +non-volatile-liquid-cristals+)
    (setf (gethash (_ "+fluid-powder-volatile-liquid+") *traslation-keys-table*)
	  +fluid-powder-volatile-liquid+))

  (let ((cl-i18n:*translation-file-root* ""))
    (cl-i18n:load-language (local-system-path #p"locale/italian.lisp"))
    (populate-translation-table)))
