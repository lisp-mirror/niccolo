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

(in-package :config)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defgeneric local-system-path (path))

  (defmethod local-system-path ((path string))
    (asdf:system-relative-pathname :niccolo
				   (uiop:parse-unix-namestring path)))

  (defmethod local-system-path ((path pathname))
    (asdf:system-relative-pathname :niccolo path)))

;; pubchem config

(define-constant +pubchem-host+ "pubchem.ncbi.nlm.nih.gov" :test #'string=)

;; TBNL config

(defparameter *error-template-directory*
  (local-system-path #p"www/errors/"))

;;;; production config

(setf TBNL:*log-lisp-backtraces-p* t)

(setf TBNL:*show-lisp-errors-p*    nil)

(setf TBNL:*catch-errors-p*        t)

;;;; debug config

;; (setf TBNL:*log-lisp-backtraces-p* t)

;; (setf TBNL:*show-lisp-errors-p*    t)

;; (setf TBNL:*catch-errors-p*        t)


;; (setf TBNL:*log-lisp-backtraces-p* t)

;; (setf TBNL:*show-lisp-errors-p*    nil)

;; (setf TBNL:*catch-errors-p*        nil)


(defparameter *message-log-pathname* (local-system-path #p"log/messages.log"))

(defparameter *access-log-pathname*  (local-system-path #p"log/access.log"))


(define-constant +path-prefix+ "/niccolo" :test #'string=)

;; ssl

(define-constant +https-port+ 8443 :test #'=)

(define-constant +hostname+   "localhost" :test #'string=)

(defparameter *ssl-certfile* (local-system-path #p"ssl/cert.pem"))

(defparameter *ssl-key* (local-system-path #p"ssl/key.pem"))

(define-constant +ssl-pass+   "" :test #'string=)

;; define this with a positive value only if you are using a reverse proxy

(define-constant +https-poxy-port+ -1 :test #'=)

;; cas config

(define-constant +cas-server-host-name+    ""    :test #'string=)

(define-constant +cas-server-path-prefix+  ""    :test #'string=)

(define-constant +cas-service-name+        (concatenate 'string
							"https://"
							+hostname+
							+path-prefix+)
  :test #'string=)

;; templates config

(setf html-template:*default-template-pathname*
      (local-system-path #p"templates/"))

(defparameter *default-css*          (local-system-path #p"www/css/style.css"))

(defparameter *default-www-root*     (local-system-path #p"www/"))

(defparameter *images-dir*           (local-system-path #p"www/images/"))

(defparameter *jquery-ui-images-dir* (local-system-path #p"www/css/images/"))

(defparameter *css-dir*              (local-system-path #p"www/css/"))

(defparameter *js-dir*               (local-system-path #p"www/js/"))

(define-constant +gplv3-logo+       (local-system-path #p"www/images/gplv3.png")    :test 'equal)

(define-constant +lisp-logo+        (local-system-path #p"www/images/lisplogo.png") :test 'equal)

(define-constant +images-url-path+ "/images/"                                       :test #'string=)

(define-constant +openstreetmap-query-url+ "http://nominatim.openstreetmap.org/search.php"
  :test #'string=)

(defun _ (a) (cl-i18n:translate a))

(defparameter *letter-header-text* "header")

;;;;; no need to modify below this line

(define-constant +session-user+ 'user :test 'eq)

(define-constant +post-user-name+ "uname" :test 'string=)

(define-constant +post-user-pass+ "pass" :test 'string=)

(defparameter *insufficient-privileges-message* "Permission denied; this operation is available for administrator only")

;; chemical risk config

(defparameter *risk_phrases*         (local-system-path #p"data/risk/h.xml"))

(defparameter *exposition-type*      (local-system-path #p"data/risk/exposition_type.xml"))

(defparameter *physical-state*       (local-system-path #p"data/risk/physical_state.xml"))

(defparameter *exposition-time*	     (local-system-path #p"data/risk/exposition_time.xml"))

(defparameter *usage*                (local-system-path #p"data/risk/usage.xml"))

(defparameter *quantity*             (local-system-path #p"data/risk/quantity.xml"))

(defparameter *stock*                (local-system-path #p"data/risk/stock.xml"))

(defparameter *work*                 (local-system-path #p"data/risk/work.xml"))

(defparameter *devices*              (local-system-path #p"data/risk/devices.xml"))

(defparameter *devices-carc*         (local-system-path #p"data/risk/devices_carc.xml"))

(defparameter *physical-state-carc*  (local-system-path #p"data/risk/physical_state_carc.xml"))

(defparameter *working-temp-carc*    (local-system-path #p"data/risk/working_temp_carc.xml"))

(defparameter *quantity-carc*        (local-system-path #p"data/risk/quantity_carc.xml"))

(defparameter *exposition-time-carc* (local-system-path #p"data/risk/exposition_time_carc.xml"))

(defparameter *frequency-carc*       (local-system-path #p"data/risk/usage_freq_carc.xml"))
