;; niccolo': a chemicals inventory
;; Copyright (C) 2018  Universita' degli Studi di Palermo

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

(define-constant +exposition-type-el-root+           "exposition_type"                :test #'equal)

(define-constant +inalation-el+                      "inalation"                      :test #'equal)

(define-constant +skin-possible+                     "skin_possible"                  :test #'equal)

(define-constant +skin-accidental+                   "skin_accidental"                :test #'equal)

(define-constant +physical-state-el-root+            "physical_state"                 :test #'equal)

(define-constant +m-r1+                              "m_r1"                           :test #'equal)

(define-constant +q-r1+                              "q_r1"                           :test #'equal)

(define-constant +m-r2+                              "m_r2"                           :test #'equal)

(define-constant +q-r2+                              "q_r2"                           :test #'equal)

(define-constant +liquid-gas+                        "+liquid-gas+"                   :test #'equal)

(define-constant +highly-volatile+                   "highly_volatile"                :test #'equal)

(define-constant +medium-volatile+                   "medium_volatile"                :test #'equal)

(define-constant +low-volatile+                      "low_volatile"                   :test #'equal)

(define-constant +powder+                            "powder"                         :test #'equal)

(define-constant +solid+                             "solid"                          :test #'equal)

(define-constant +exposition-time-el-root+           "exposition_time"                :test #'equal)

(define-constant +tlv-twa+                           "TLV-TWA"                        :test #'equal)

(define-constant +tlv-stel+                          "TLV-STEL"                       :test #'equal)

(define-constant +tlv-ceiling+                       "TLV-Ceiling"                    :test #'equal)


(define-constant +usage-el-root+                     "usage"                          :test #'equal)

(define-constant +almost-closed-system+              "almost_closed_system"           :test #'equal)

(define-constant +matrix-inclusion+                  "matrix_inclusion"               :test #'equal)

(define-constant +low-dispersion+                    "low_dispersion"                 :test #'equal)

(define-constant +high-dispersion+                   "high_dispersion"                :test #'equal)


(define-constant +quantity-el+                       "quantity"                       :test #'equal)

(define-constant +segment-el+                        "segment"                        :test #'equal)

(define-constant +qmin-el+                           "qmin"                           :test #'equal)

(define-constant +qmax-el+                           "qmax"                           :test #'equal)

(define-constant +min-el+                            "min"                            :test #'equal)

(define-constant +max-el+                            "max"                            :test #'equal)

(define-constant +work-type-root+                    "work"                           :test #'equal)

(define-constant +maintenance+                       "maintenance"                    :test #'equal)

(define-constant +normal-job+                        "normal_job"                     :test #'equal)

(define-constant +cleaning+                          "cleaning"                       :test #'equal)

(define-constant +devices-root+                      "devices"                        :test #'equal)

(define-constant +good-fume-cupboard+                "good_fume_cupboard"             :test #'equal)

(define-constant +bad-fume-cupboard+                 "bad_fume_cupboard"              :test #'equal)

(define-constant +no-fume-cupboard+                  "no_fume_cupboard"               :test #'equal)

(define-constant +written-instructions+              "written_instructions"           :test #'equal)

(define-constant +dpi-coat+                          "dpi_coat"                       :test #'equal)

(define-constant +goggles+                           "goggles"                        :test #'equal)

(define-constant +gloves+                            "gloves"                         :test #'equal)

(define-constant +good-aspiration+                   "good_aspiration"                :test #'equal)

(define-constant +bad-aspiration+                    "bad_aspiration"                 :test #'equal)

(define-constant +no-aspiration+                     "no_aspiration"                  :test #'equal)

(define-constant +other-manipulation-devices+        "other_manipulation_devices"     :test #'equal)

(define-constant +specific-skills+                   "specific_skills"                :test #'equal)

(define-constant +separate-collecting-substances+    "separate_collecting_substances" :test #'equal)

(define-constant +devices-carc-root+                 "devices"
                                                                                      :test #'equal)

(define-constant +closed-lifecycle+                  "closed_lifecycle"
                                                                                      :test #'equal)

(define-constant +good-fume-cupboard-lifecycle+      "good_fume_cupboard_lifecycle"
                                                                                      :test #'equal)

(define-constant +partially-fume-cupboard-lifecycle+ "partially_fume_cupboard_lifecycle"
                                                                                      :test #'equal)

(define-constant +no-fume-cupboard-lifecycle+        "no_fume_cupboard_lifecycle"
                                                                                      :test #'equal)

(define-constant +physical-state-carc+               "physical_state_carc"            :test #'equal)

(define-constant +solid-compact-gel+                 "solid_compact_gel"              :test #'equal)

(define-constant +non-volatile-liquid-cristals+      "non_volatile_liquid_cristals"
                                                                                      :test #'equal)

(define-constant +fluid-powder-volatile-liquid+      "fluid_powder_volatile_liquid"
                                                                                      :test #'equal)

(define-constant +working-temp+                      "working_temp"                   :test #'equal)

(define-constant +threshold+                         "threshold"                      :test #'equal)

(define-constant +value+                             "value"                          :test #'equal)

(define-constant +exposition-time+                   "exposition_time"                :test #'equal)

(define-constant +frequency+                         "frequency"                      :test #'equal)

(define-constant +frac-canc-l-carc+ 25/4                                              :test #'=)

;;; snpa

(define-constant +waste-management-sampling+         "waste_management_sampling"      :test #'equal)

(define-constant +oel-twa+                           "OEL-TWA"                        :test #'equal)

(define-constant +oel-stel+                          "OEL-STEL"                       :test #'equal)

(define-constant +mak+                               "MAK"                            :test #'equal)

(define-constant +closed-system+                     "closed_system"                  :test #'equal)

(define-constant +aspiration+                        "aspiration"                     :test #'equal)

(define-constant +managing-chemical-compatibility+   "managing_chemical_compatibility"
  :test #'equal)

(define-constant +good-fume-cupboard-rel+            "good_fume_cupboard_rel"
                                                                                      :test #'equal)

(define-constant +bad-fume-cupboard-rel+             "bad_fume_cupboard_rel"          :test #'equal)

(define-constant +no-fume-cupboard-rel+              "no_fume_cupboard_rel"           :test #'equal)

(define-constant +dpi-vest+                          "dpi_vest"                       :test #'equal)

(define-constant +yes+                               "yes"                            :test #'equal)

(define-constant +no+                                "no"                             :test #'equal)

;; snpa carc

(define-constant +frac-canc-l-carc-snpa+            25/4                              :test #'=)

(define-constant +closed-opened-sometimes+           "closed_opened_sometimes"        :test #'equal)

(define-constant +gel+                               "gel"                            :test #'equal)

(define-constant +solid-compact+                     "solid_compact"                  :test #'equal)

(define-constant +crystals+                          "crystals"                       :test #'equal)

(define-constant +liquid+                            "liquid"                         :test #'equal)

(define-constant +gas-vapours-fine-powder+           "gas_vapours_fine_powder"        :test #'equal)

(define-constant +all-operations-with-good-fume-cupboard+
    "all_operations_with_good_fume_cupboard"                                          :test #'equal)

(define-constant +some-operations-with-good-fume-cupboard+
    "some_operations_with_good_fume_cupboard"                                         :test #'equal)

(define-constant +inefficient-fume-cupboard+   "inefficient_fume_cupboard"            :test #'equal)
