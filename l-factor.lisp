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

(in-package :restas.lab)

(define-constant +h-codes+ "h-codes" :test #'string=)

(define-constant +h-code+  "h-code" :test #'string=)

(defun fetch-all-ghs ()
  (let ((raw (filter 'db:ghs-hazard-statement)))
    (loop for i in raw collect (list :h-code (db:code i)))))

(defun %select-builder (keyword &rest keys)
  (loop for i in keys collect (list keyword (_ i))))

(defun select-exp-types ()
  (%select-builder :exp-type "+inalation-el+" "+skin-possible+" "+skin-accidental+"))

(defun select-phys-state ()
  (%select-builder :phys-state "HIGHLY_VOLATILE" "LOW_VOLATILE" "MEDIUM_VOLATILE"
		   "POWDER" "SOLID"))

(defun select-exp-time-type ()
  (list (list :exp-time-type "TLV-CEILING")
	(list :exp-time-type "TLV-STEL")
	(list :exp-time-type "TLV-TWA")))

(defun select-usage ()
  (%select-builder :usage "+almost-closed-system+"
		   "+matrix-inclusion+"
		   "+low-dispersion+"
		   "+high-dispersion+"))

(defun select-work-type ()
  (%select-builder :work-type
		   "+Maintenance+"
		   "+normal-job+"
		   "+cleaning+"))

(defun select-protection-factors ()
  (%select-builder :protection-factor
		   "+good-fume-cupboard+"
		   "+bad-fume-cupboard+"
		   "+no-fume-cupboard+"
		   "+written-instructions+"
		   "+dpi-coat+"
		   "+goggles+"
		   "+gloves+"
		   "+good-aspiration+"
		   "+bad-aspiration+"
		   "+no-aspiration+"
		   "+other-manipulation-devices+"
		   "+specific-skills+"
		   "+separate-collecting-substances+"))

(defun select-prot-devices ()
  (%select-builder :protective-device
		   "+closed-lifecycle+"
		   "+good-fume-cupboard-lifecycle+"
		   "+partially-fume-cupboard-lifecycle+"
		   "+no-fume-cupboard-lifecycle+"))

(defun select-phys-state-carc ()
  (%select-builder :phys-state
		   "+solid-compact-gel+"
		   "+non-volatile-liquid-cristals+"
		   "+fluid-powder-volatile-liquid+"))

(define-lab-route l-factor ("/l-factor-calculator/" :method :get)
  (with-authentication
    (with-standard-html-frame (stream "Risk Calculator" :errors nil :infos nil)
      (html-template:fill-and-print-template #p"l-factor-calculator.tpl"
					     (with-path-prefix
						 :h-phrase-lb          (_ "H phrase")
						 :exposition-types-lb  (_ "Exposition types")
						 :physical-state-lb    (_ "Physical state")
						 :working-temp-lb     (_ "Working temperature (°C)")
						 :boiling-point-lb     (_ "Boiling point (°C)")
						 :exposition-time-type-lb (_ "Exposition time type")
						 :exposition-time-lb   (_ "Exposition time (min)")
						 :usage-lb             (_ "Usage")
						 :quantity-used-lb     (_ "Quantity used (g)")
						 :quantity-stocked-lb  (_ "Quantity stocked (g)")
						 :work-type-lb         (_ "Work type")
						 :protection-factors-lb (_ "Protection factors")
						 :safety-threshold-lb   (_ "Safety threshold")
						 :results-lb            (_ "Results")
						 :errors-lb             (_ "Errors")
						 :option-h-codes       (fetch-all-ghs)
						 :option-exp-types     (select-exp-types)
						 :option-phys-states   (select-phys-state)
						 :option-exp-time-type (select-exp-time-type)
						 :option-usages        (select-usage)
						 :option-work-types    (select-work-type)
						 :option-protection-factors
						 (select-protection-factors))
					     :stream stream))))

(define-lab-route l-factor-carc ("/l-factor-carc-calculator/" :method :get)
  (with-authentication
    (with-standard-html-frame (stream "Risk Calculator, carcinogenic" :errors nil :infos nil)
      (html-template:fill-and-print-template #p"l-factor-calculator-carc.tpl"
					     (with-path-prefix
						 :protective-devices-lb (_ "Protective devices")
						 :physical-states-lb    (_ "Physical state")
						 :working-temp-lb     (_ "Working temperature (°C)")
						 :boiling-point-lb     (_ "Boiling point (°C)")
						 :quantity-used-lb      (_ "Quantity used (g)")
						 :usage-per-day-lb      (_ "Usage per day (min.)")
						 :usage-per-year-lb     (_ "Usage per year (days)")
						 :results-lb            (_ "Results")
						 :errors-lb             (_ "Errors")
						 :option-protective-devices (select-prot-devices)
						 :option-phys-states   (select-phys-state-carc))
					     :stream stream))))
