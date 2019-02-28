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

(in-package :restas.lab)

(define-constant +h-codes+ "h-codes" :test #'string=)

(define-constant +h-code+  "h-code" :test #'string=)

(defun fetch-all-ghs ()
  (let ((raw (db-filter 'db:ghs-hazard-statement)))
    (loop for i in raw collect (list :h-code (db:code i)))))

(defun sort-all-ghs-tpl (tpl)
  (sort tpl #'(lambda (a b)
                (let ((parse-fn #'(lambda (e)
                                    (parse-integer (scan-to-strings "[0-9]+" (second e))))))
                  (< (funcall parse-fn a)
                     (funcall parse-fn b))))))


(defun %select-builder (keyword &rest keys)
  (loop for i in keys collect (list keyword (_ i))))

(defun select-exp-types ()
  (%select-builder :exp-type "+inalation-el+" "+skin-possible+" "+skin-accidental+"))

(defun select-phys-state ()
  (%select-builder :phys-state "HIGHLY_VOLATILE" "LOW_VOLATILE" "MEDIUM_VOLATILE"
                   "POWDER" "SOLID"))

(defun select-exp-time-type ()
  (list (list :exp-time-type "TLV-TWA")
        (list :exp-time-type "TLV-CEILING")
        (list :exp-time-type "TLV-STEL")))

(defun select-usage ()
  (%select-builder :usage
                   "+low-dispersion+"
                   "+almost-closed-system+"
                   "+matrix-inclusion+"
                   "+high-dispersion+"))

(defun select-work-type ()
  (%select-builder :work-type
                   "+normal-job+"
                   "+maintenance+"
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
    (let* ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
           (service-link (restas:genurl 'l-factor-i))
           (json-chemical    (array-autocomplete-chemical-compound))
           (json-chemical-id (array-autocomplete-chemical-compound-id))
           (template     (with-back-to-root
                             (with-path-prefix
                                 :service-link              service-link
                                 :lab-name-lb               (_ "Laboratory")
                                 :chem-name-lb              (_ "Chemical name")
                                 :h-phrase-lb               (_ "H phrase")
                                 :exposition-types-lb       (_ "Exposition types")
                                 :physical-state-lb         (_ "Physical state")
                                 :working-temp-lb           (_ "Working temperature (°C)")
                                 :boiling-point-lb          (_ "Boiling point (°C)")
                                 :exposition-time-type-lb   (_ "Exposition time type")
                                 :exposition-time-lb        (_ "Exposition time (min)")
                                 :usage-lb                  (_ "Usage")
                                 :quantity-used-lb          (_ "Quantity used (g)")
                                 :quantity-stocked-lb       (_ "Quantity stocked (g)")
                                 :work-type-lb              (_ "Work type")
                                 :protection-factors-lb     (_ "Protection factors")
                                 :safety-threshold-lb       (_ "Safety threshold")
                                 :notes-lb                  (_ "Notes")
                                 :results-lb                (_ "Results")
                                 :table-res-header          (_ "Results")
                                 :errors-lb                 (_ "Errors")
                                 :sum-quantities-lb         (_ "Sum quantities")
                                 :clear-lb                  (_ "Clear fields")
                                 :operations-lb             (_ "Operations")
                                 :json-chemicals            json-chemical
                                 :json-chemicals-id         json-chemical-id
                                 :option-h-codes            (sort-all-ghs-tpl (fetch-all-ghs))
                                 :option-exp-types          (select-exp-types)
                                 :option-phys-states        (select-phys-state)
                                 :option-exp-time-type      (select-exp-time-type)
                                 :option-usages             (select-usage)
                                 :option-work-types         (select-work-type)
                                 :option-protection-factors (select-protection-factors)))))
      (with-standard-html-frame (stream (_ "Risk Calculator") :errors nil :infos nil)
        (html-template:fill-and-print-template #p"l-factor-calculator.tpl"
                                               template
                                               :stream stream)))))

(define-lab-route l-factor-carc ("/l-factor-carc-calculator/" :method :get)
  (with-authentication
    (let* ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
           (service-link (restas:genurl 'l-factor-carc-i))
           (json-chemical    (array-autocomplete-chemical-compound))
           (json-chemical-id (array-autocomplete-chemical-compound-id))
           (template     (with-back-to-root
                             (with-path-prefix
                                 :service-link              service-link
                                 :lab-name-lb               (_ "Laboratory")
                                 :chem-name-lb              (_ "Chemical name")
                                 :protective-devices-lb     (_ "Protective devices")
                                 :physical-states-lb        (_ "Physical state")
                                 :working-temp-lb           (_ "Working temperature (°C)")
                                 :boiling-point-lb          (_ "Boiling point (°C)")
                                 :quantity-used-lb          (_ "Quantity used (g)")
                                 :usage-per-day-lb          (_ "Usage per day (min.)")
                                 :usage-per-year-lb         (_ "Usage per year (days)")
                                 :notes-lb                  (_ "Notes")
                                 :results-lb                (_ "Results")
                                 :sum-quantities-lb         (_ "Sum quantities")
                                 :clear-lb                  (_ "Clear fields")
                                 :operations-lb             (_ "Operations")
                                 :table-res-header          (_ "Results")
                                 :errors-lb                 (_ "Errors")
                                 :json-chemicals            json-chemical
                                 :json-chemicals-id         json-chemical-id
                                 :option-protective-devices (select-prot-devices)
                                 :option-phys-states        (select-phys-state-carc)))))
      (with-standard-html-frame (stream (_ "Risk Calculator, carcinogenic") :errors nil :infos nil)
        (html-template:fill-and-print-template #p"l-factor-calculator-carc.tpl"
                                               template
                                               :stream stream)))))
