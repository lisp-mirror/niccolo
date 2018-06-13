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

(in-package :restas.lab.l-factor-snpa)

(define-constant +h-codes+ "h-codes" :test #'string=)

(define-constant +h-code+  "h-code" :test #'string=)

(defun select-exp-types ()
  (restas.lab:%select-builder :exp-type "+inalation-el+" "+skin-possible+" "+skin-accidental+"))

(defun select-exp-time-type ()
  (restas.lab:%select-builder :exp-time-type
                              "+tlv-twa+"
                              "+tlv-stel+"
                              "+tlv-ceiling+"
                              "+oel-twa+"
                              "+oel-stel+"
                              "+mak+"))

(defun select-usage ()
  (restas.lab:%select-builder :usage
                              "+closed-system+"
                              "+almost-closed-system+"
                              "+closed-opened-sometimes+"
                              "+low-dispersion+"
                              "+high-dispersion+"))

(defun select-quantity-stocked ()
  (restas.lab:%select-builder :quantity-stocked
                              "+yes+"
                              "+no+"))

(defun select-work-type ()
  (restas.lab:%select-builder :work-type
                              "+maintenance+"
                              "+waste-management-sampling+"
                              "+cleaning+"
                              "+normal-job+"))

(defun select-protection-factors ()
  (restas.lab:%select-builder :protection-factor
                              "+good-fume-cupboard-rel+"
                              "+bad-fume-cupboard-rel+"
                              "+no-fume-cupboard-rel+"
                              "+dpi-vest+"
                              "+goggles+"
                              "+gloves+"
                              "+aspiration+"
                              "+other-manipulation-devices+"
                              "+specific-skills+"
                              "+managing-chemical-compatibility+"))

(defun select-prot-devices ()
  (restas.lab:%select-builder :protective-device
                              "+closed-lifecycle+"
                              "+good-fume-cupboard-lifecycle+"
                              "+partially-fume-cupboard-lifecycle+"
                              "+no-fume-cupboard-lifecycle+"))

(defun select-prot-devices-carc ()
  (restas.lab:%select-builder :protective-device
                              "+all-operations-with-good-fume-cupboard+"
                              "+some-operations-with-good-fume-cupboard+"
                              "+inefficient-fume-cupboard+"))

(defun select-phys-state-carc ()
  (restas.lab:%select-builder :phys-state
                              "+gel+"
                              "+solid-compact+"
                              "+crystals+"
                              "+matrix-inclusion+"
                              "+liquid+"
                              "+gas-vapours-fine-powder+"))

(define-lab-route l-factor-snpa ("/l-factor-calculator-snpa/" :method :get)
  (restas.lab:with-authentication
    (let* ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
           (service-link     (restas.lab:ws-l-factor-i-snpa-url))
           (json-chemical    (restas.lab:array-autocomplete-chemical-compound))
           (json-chemical-id (restas.lab:array-autocomplete-chemical-compound-id))
           (template     (with-back-to-root
                             (with-path-prefix
                                 :service-link              service-link
                                 :chem-name-lb              (_ "Chemical name")
                                 :h-phrase-lb               (_ "H phrase")
                                 :exposition-types-lb       (_ "Exposition types")
                                 :physical-state-lb         (_ "Physical state")
                                 :working-temp-lb           (_ "Working temperature (°C)")
                                 :boiling-point-lb          (_ "Boiling point (°C)")
                                 :exposition-time-type-lb   (_ "Exposition time type")
                                 :exposition-time-lb        (_ "Exposition time (min)")
                                 :usage-lb                  (_ "Usage")
                                 :quantity-used-lb          (_ "Quantity used (g or ml)")
                                 :work-type-lb              (_ "Work type")
                                 :collective-protection-factors-lb
                                 (_ "Collective protection factors lb")
                                 :quantity-stocked-minimum-lb
                                 (_ "The minimun quantity of this product, for weekly/daily necessity, is used in this laboratory")
                                 :safety-thresholds-lb      (_ "Format: a line for each entry. Entry is: chemical-name threshold concentration. Concentration must be provided as mass fraction (i.e. (0.0, 1.0))")
                                 :safety-threshold-lb       (_ "Safety threshold")
                                 :results-lb                (_ "Results")
                                 :table-res-header          (_ "Results")
                                 :errors-lb                 (_ "Errors")
                                 :sum-quantities-lb         (_ "Sum quantities")
                                 :clear-lb                  (_ "Clear fields")
                                 :operations-lb             (_ "Operations")
                                 :quantity-stocked-minimum-table-h-lb
                                 (_ "Minumum qty?")
                                 :json-chemicals            json-chemical
                                 :json-chemicals-id         json-chemical-id
                                 :option-h-codes
                                 (restas.lab:sort-all-ghs-tpl (restas.lab:fetch-all-ghs))
                                 :option-exp-types          (select-exp-types)
                                 :option-phys-states        (restas.lab:select-phys-state)
                                 :option-quantity-stocked   (l-fact-snpa:select-quantity-stocked)
                                 :option-exp-time-type      (l-fact-snpa:select-exp-time-type)
                                 :option-usages             (l-fact-snpa:select-usage)
                                 :option-work-types         (l-fact-snpa:select-work-type)
                                 :option-protection-factors (l-fact-snpa:select-protection-factors)))))
      (with-standard-html-frame (stream "Risk Calculator" :errors nil :infos nil)
        (html-template:fill-and-print-template #p"l-factor-calculator-snpa.tpl"
                                               template
                                               :stream stream)))))


(define-lab-route l-factor-carc-snpa ("/l-factor-carc-calculator-snpa/" :method :get)
  (restas.lab:with-authentication
    (let* ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
           (service-link     (restas.lab:ws-l-factor-carc-i-snpa-url))
           (json-chemical    (restas.lab:array-autocomplete-chemical-compound))
           (json-chemical-id (restas.lab:array-autocomplete-chemical-compound-id))
           (template     (with-back-to-root
                             (with-path-prefix
                                 :service-link              service-link
                                 :chem-name-lb              (_ "Chemical name")
                                 :protective-devices-lb     (_ "Protective devices")
                                 :physical-states-lb        (_ "Physical state")
                                 :working-temp-lb           (_ "Working temperature (°C)")
                                 :quantity-used-lb          (_ "Quantity used (g)")
                                 :usage-per-day-lb          (_ "Usage per day (min.)")
                                 :usage-per-year-lb         (_ "Usage per year (days)")
                                 :results-lb                (_ "Results")
                                 :sum-quantities-lb         (_ "Sum quantities")
                                 :clear-lb                  (_ "Clear fields")
                                 :operations-lb             (_ "Operations")
                                 :table-res-header          (_ "Results")
                                 :errors-lb                 (_ "Errors")
                                 :json-chemicals            json-chemical
                                 :json-chemicals-id         json-chemical-id
                                 :option-protective-devices (select-prot-devices-carc)
                                 :option-phys-states        (select-phys-state-carc)))))
      (with-standard-html-frame (stream (_ "Risk Calculator, carcinogenic") :errors nil :infos nil)
        (html-template:fill-and-print-template #p"l-factor-calculator-carc-snpa.tpl"
                                               template
                                               :stream stream)))))
