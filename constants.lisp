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

(in-package :constants)

(define-constant +relative-coord-scaling+      1000.0                        :test #'=)

(define-constant +relative-circle-size+          50.0                        :test #'=)

(define-constant +admin-name+                    "admin"                     :test #'string=)

(define-constant +db-invalid-id+                 "0"                         :test #'string=)

(define-constant +db-invalid-id-number+          0                           :test #'=)

(define-constant +admin-acl-level+               0                           :test #'=)

(define-constant +user-acl-level+                10                          :test #'=)

(define-constant +user-account-enabled+          1                           :test #'=)

(define-constant +user-session+                  'user                       :test 'eq)

(define-constant +auth-name-login-name+          "user"                      :test #'string=)

(define-constant +auth-name-login-password+      "pass"                      :test #'string=)

(define-constant +salt-byte-length+              8                           :test #'=)

(define-constant +ghs-carcinogenic-code+         "1"                         :test #'string=)

(define-constant +page-margin-top+               20                          :test #'=)

(define-constant +page-margin-left+              20                          :test #'=)

(define-constant +data-path+                     #p "data/"                  :test #'equal)

(define-constant +letter-header+                 #p "data/letter-header.png" :test #'equal)

(define-constant +image-unknown-struct-path+     "/images/no-struct.png"     :test #'string=)

(define-constant +header-image-export-height+    25.0                        :test #'=)

(define-constant +default-font-name+             "font"                      :test #'string=)

(define-constant +pictogram-web-image-ext+       "png"                       :test #'string=)

(define-constant +pictogram-web-image-subdir+    "ghs-pictograms/"           :test #'string=)

(define-constant +pictogram-id-none+             10                          :test #'=)

(define-constant +mime-postscript+               "application/postscript"    :test #'string=)

(define-constant +security-warning-log-level+    "SECURITY WARNING"          :test #'string=)

(define-constant +search-chem-id+                "s-id"                      :test #'string=)

(define-constant +search-chem-owner+             "s-owner"                   :test #'string=)

(define-constant +search-chem-name+              "s-name"                    :test #'string=)

(define-constant +search-chem-building+          "s-building"                :test #'string=)

(define-constant +search-chem-floor+             "s-floor"                   :test #'string=)

(define-constant +search-chem-storage+           "s-storage"                 :test #'string=)

(define-constant +search-chem-shelf+             "s-shelf"                   :test #'string=)

(define-constant +name-validity-date+            "validity-date"             :test #'string=)

(define-constant +name-expire-date+              "expire-date"               :test #'string=)

(sanitize:define-sanitize-mode +no-html-tags-at-all+ :elements ())

;; federated query

(define-constant +query-product-path+              "/fq-query-product"           :test #'string=)

(define-constant +post-query-product-results+      "/fq-post-product-res"        :test #'string=)

(define-constant +query-visited+                   "/fq-query-visited"           :test #'string=)

(define-constant +query-http-parameter-key+        "q"                           :test #'string=)

(define-constant +query-http-response-key+         "r"                           :test #'string=)
