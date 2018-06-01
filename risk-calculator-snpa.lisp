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

(in-package :risk-calculator-snpa)

(configuration-utils:define-conffile-reader (exposition-time-snpa (+exposition-time-el-root+ nil nil))
    oel-twa
  oel-stel
  tlv-twa
  tlv-stel
  tlv-ceiling
  mak)

(configuration-utils:define-conffile-reader (usage-snpa (+usage-el-root+ nil nil))
    closed_system
  almost_closed_system
  closed_opened_sometimes
  low_dispersion
  high_dispersion)

(defun d-factor-snpa (answer)
  (if (string-equal +yes+ answer)
      1.0
      2.0))

(configuration-utils:define-conffile-reader (work-snpa (+work-type-root+ nil nil))
    maintenance
  normal_job
  cleaning
  waste_management_sampling)

(configuration-utils:define-conffile-reader (devices-snpa (+devices-root+ nil nil))
    good_fume_cupboard_rel
  bad_fume_cupboard_rel
  no_fume_cupboard_rel
  written_instructions
  dpi_vest
  goggles
  gloves
  aspiration
  other_manipulation_devices
  specific_skills
  managing_chemical_compatibility)

(defun vle-threshold (v)
  (second v))

(defun vle-concentration (v)
  (third v))

(defun vle-factor (vals)
  (cond
    ((not (consp vals))
     (push (_ "vl-factors are not a list.") *errors*)
     100.0)
    ((find-if #'(lambda (a) (or (not (numberp (vle-threshold     a)))
                                (not (numberp (vle-concentration a)))))
                  vals)
     (push (_ "vl-factor does not ends with a pair of number.") *errors*)
     100.0)
    (t
     (loop for v in vals minimize (/ (vle-threshold     v)
                                     (vle-concentration v))))))

(defparameter *working-temp-carc-snpa*
  (local-system-path #p"data/risk-snpa/working-temp-carc.xml"))

(defparameter *t-factor-carc-table-snpa*
  (utils:load-values-discrete-ranges *working-temp-carc-snpa*))

(defun t-factor-carc-snpa (temp)
  (utils:get-value-discrete-range *t-factor-carc-table-snpa* temp))

(configuration-utils:define-conffile-reader (physical-state-carc-snpa (+physical_state_carc+ nil nil))
    gel
  solid_compact
  crystals
  matrix_inclusion
  liquid
  gas_vapours_fine_powder)

(configuration-utils:define-conffile-reader
    (collective-protect-carc-snpa (+physical_state_carc+ nil nil))

    all_operations_with_good_fume_cupboard
  some_operations_with_good_fume_cupboard
  inefficient_fume_cupboard)

(defun p-factor-carc-snpa (protection)
  (p-factor-carc-extract protection))

(let* ((risk-phrases           (local-system-path #p"data/risk-snpa/h.xml"))
       (exposition-type        (local-system-path #p"data/risk-snpa/exposition-type.xml"))
       (physical-state         (local-system-path #p"data/risk-snpa/physical-state.xml"))
       (exposition-time        (local-system-path #p"data/risk-snpa/exposition-time.xml"))
       (usage                  (local-system-path #p"data/risk-snpa/usage.xml"))
       (quantity               (local-system-path #p"data/risk-snpa/quantity.xml"))
       (stock                  (local-system-path #p"data/risk-snpa/stock.xml"))
       (work                   (local-system-path #p"data/risk-snpa/usage-type.xml"))
       (devices                (local-system-path #p"data/risk-snpa/devices.xml"))
       (devices-carc           (local-system-path #p"data/risk-snpa/devices-collective.xml"))
       (physical-state-carc    (local-system-path #p"data/risk-snpa/physical-state-carc.xml"))
       (working-temp-carc      (local-system-path #p"data/risk-snpa/working-temp-carc.xml"))
       (quantity-carc          (local-system-path #p"data/risk-snpa/quantity-carc.xml"))
       (exposition-time-carc   (local-system-path #p"data/risk-snpa/exposition-time-carc.xml"))
       (frequency-carc         (local-system-path #p"data/risk-snpa/usage-freq-carc.xml"))
       (phrases-database       (load-db                          risk-phrases))
       (exposition-table       (read-exposition-type-config      exposition-type))
       (physical-state-table   (read-physical-state-config       physical-state))
       (exposition-time-table  (read-exposition-time-snpa-config exposition-time))
       (usage-table            (read-usage-snpa-config           usage))
       (quantity-table         (get-graph-quantity               quantity))
       (work-table             (read-work-snpa-config            work))
       (devices-table          (read-devices-snpa-config         devices)))

  (defun l-factor-i-snpa (r-phrases exposition-types physical-state working-temp boiling-point
                          exposition-time-type exposition-time
                          usage quantity-used quantity-stocked-minimum work-type
                          protections-factors safety-thresholds)
    (let* ((*risk-phrases*            risk-phrases)
           (*exposition-type*         exposition-type)
           (*physical-state*          physical-state)
           (*exposition-time*         exposition-time)
           (*usage*                   usage)
           (*quantity*                quantity)
           (*stock*                   stock)
           (*work*                    work)
           (*devices*                 devices)
           (*physical-state-carc*     physical-state-carc)
           (*working-temp-carc*       working-temp-carc)
           (*quantity-carc*           quantity-carc)
           (*exposition-time-carc*    exposition-time-carc)
           (*frequency-carc*          frequency-carc)
           (*phrases-database*        phrases-database)
           (*exposition-table*        exposition-table)
           (*physical-state-table*    physical-state-table)
           (*exposition-time-table*   exposition-time-table)
           (*usage-table*             usage-table)
           (*quantity-table*          quantity-table)
           (*work-table*              work-table)
           (*devices-table*           devices-table)
           (r-factor   (r-factor      r-phrases))
           (t-factor   (t-factor      (untranslate exposition-types)))
           (s-factor   (s-factor      (untranslate physical-state) working-temp boiling-point))
           (e-factor   (e-factor      exposition-time exposition-time-type))
           (u-factor   (u-factor      (untranslate usage)))
           (q-factor   (q-factor      quantity-used))
           (d-factor   (d-factor-snpa (untranslate quantity-stocked-minimum)))
           (a-factor   (a-factor      (untranslate work-type)))
           (k-factor   (k-factor      (untranslate protections-factors)))
           (vle-factor (vle-factor    safety-thresholds)))
      ;; (format t "r-factor ~a~%" r-factor)
      ;; (format t "t-factor ~a~%" t-factor)
      ;; (format t "s-factor ~a~%" s-factor)
      ;; (format t "e-factor ~a~%" e-factor)
      ;; (format t "u-factor ~a~%" u-factor)
      ;; (format t "q-factor ~a~%" q-factor)
      ;; (format t "d-factor ~a~%" d-factor)
      ;; (format t "a-factor ~a~%" a-factor)
      ;; (format t "k-factor ~a~%" k-factor)
      ;; (format t "vle-factor ~a~%" vle-factor)
      (values
       (/ (* r-factor t-factor s-factor e-factor q-factor u-factor d-factor a-factor)
          (* k-factor vle-factor))
       (list r-factor
             t-factor
             s-factor
             e-factor
             u-factor
             q-factor
             d-factor
             a-factor
             k-factor
             vle-factor
             safety-thresholds
             *errors*))))
  ;; carc

  (defun l-factor-carc-i-snpa (physical-state twork collective-protection
                               quantity-used usage-per-day
                               usage-per-year)
    (let* ((*physical-state-carc-table* (read-physical-state-carc-snpa-config     physical-state-carc))
           (*device-carc-table*         (read-collective-protect-carc-snpa-config devices-carc))
           (*quantity-carc-table*       (read-threshold-value-xml                 quantity-carc
                                                                                  +quantity-el+))
           (*frequency-carc-table*      (read-usage-freq-carc-config              frequency-carc))
           (*exposition-carc-table*     (read-exposition-time-carc-config         exposition-time-carc))
           (t-fact                      (t-factor-carc-snpa twork))
           (s-fact                      (s-factor-carc      (untranslate physical-state)))
           (p-fact                      (p-factor-carc-snpa (untranslate collective-protection)))
           (q-fact                      (q-factor-carc quantity-used))
           (e-fact                      (e-factor-carc usage-per-day))
           (f-fact                      (f-factor-carc usage-per-year))
           (l-factor                    (/ (* p-fact s-fact t-fact q-fact e-fact f-fact)
                                           +frac-canc-l-carc-snpa+)))
      ;; (format t "t-factor ~a~%" t-fact)
      ;; (format t "s-factor ~a~%" s-fact)
      ;; (format t "p-factor ~a~%" p-fact)
      ;; (format t "q-factor ~a~%" q-fact)
      ;; (format t "e-factor ~a~%" e-fact)
      ;; (format t "f-factor ~a~%" f-fact)
      (values l-factor (list p-fact s-fact t-fact q-fact e-fact f-fact *errors*)))))
