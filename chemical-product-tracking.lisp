;; niccolo': a chemicals inventory
;; Copyright (C) 2018  Universita' degli Studi di Palermo

;; This  program is  free  software: you  can  redistribute it  and/or
;; modify it  under the  terms of  the GNU  General Public  License as
;; published by the Free Software  Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :restas.lab)

(define-constant +tracking-type-quantity+  10  :test #'=)

(defun chemical-tracked-p (product-id user-id)
  (when-let ((compound (chem-prod->chem-compound product-id)))
    (single 'db:chemical-usage-tracking
            :chemical-id (db:id compound)
            :user-id     user-id)))

(defun sum-chem-quantity (user-id chemical-id)
  (when-let ((products (filter 'db:chemical-product
                               :owner    (safe-parse-number user-id     -1)
                               :compound (safe-parse-number chemical-id -1))))
    (reduce #'(lambda (sum-so-far product)
                (let ((scale (if (cl-ppcre:scan "(?i)^m" (db:units product))
                                 1e-3
                                 1.0)))
                  (+ sum-so-far (* scale (db:quantity product)))))
            products
            :initial-value 0.0)))

(defun find-tracking (user-id chemical-id)
  (single 'db:chemical-usage-tracking
          :user-id     (safe-parse-number user-id     -1)
          :chemical-id (safe-parse-number chemical-id -1)))

(defun find-chemical-tracking (chemprod-id user-id tracking-type)
  (when-let* ((chemical (chem-prod->chem-compound (safe-parse-number chemprod-id -1)))
              (tracking (find-tracking user-id (db:id chemical))))
    (keywordize-query-results (query (select :*
                                       (from  (:as :chemical-tracking-data :track))
                                       (where (:and (:= :track.track-type  tracking-type)
                                                    (:= :track.tracking-id (db:id tracking))))
                                       (order-by :track.track-date :asc))))))

(defun tracking-add-record-qty (user-id chemical-id)
  (when-let* ((tracking (find-tracking user-id chemical-id)))
    (create 'db:chemical-tracking-data
            :tracking-id (db:id tracking)
            :track-date  (local-time-obj-now)
            :track-type  +tracking-type-quantity+
            :data        (sum-chem-quantity user-id chemical-id))))

(define-lab-route add-chemical-tracking ("/add-track-chemical/:id-product" :method :get)
  (with-authentication
    (with-session-user (user)
      (let ((compound (chem-prod->chem-compound id-product)))
        (when (and compound
                   (null (unique-p-validate* 'db:chemical-usage-tracking
                                             (:user-id :chemical-id)
                                             ((db:id user) (db:id compound))
                                             "ok")))
          (create 'db:chemical-usage-tracking
                  :user-id      (db:id user)
                  :chemical-id  (db:id compound))
          (tracking-add-record-qty (db:id user) (db:id compound))))
      (restas:redirect 'search-chem-prod)))
  +http-ok+)

(define-lab-route remove-chemical-tracking ("/remove-track-chemical/:id-product" :method :get)
  (with-authentication
    (with-session-user (user)
      (when-let* ((compound (chem-prod->chem-compound id-product))
                  (tracking (single! 'db:chemical-usage-tracking
                                     :user-id      (db:id user)
                                     :chemical-id  (db:id compound))))

        (del tracking))
      (restas:redirect 'search-chem-prod)))
  +http-ok+)

(defun generate-tracking-graph (time-format chemical-id)
  (with-authentication
    (with-session-user (user)
      (let* ((error-valid-id (regexp-validate (list (list chemical-id
                                                          +pos-integer-re+
                                                          "Errors"))))
             (error-not-exists (if (and (null error-valid-id)
                                        (object-exists-in-db-p 'db:chemical-product
                                                               chemical-id))
                                   nil
                                   t)))
        (if (or error-valid-id
                error-not-exists)
            +http-not-found+
            (let ((tracking-data (find-chemical-tracking (safe-parse-number chemical-id -1)
                                                         (db:id user)
                                                         +tracking-type-quantity+)))
              (let* ((xs-raw (mapcar #'(lambda (a)
                                         (let ((time (encode-datetime-string (getf a
                                                                                   :track-date))))
                                           (format-time* time time-format)))
                                     tracking-data))
                     (ys-raw (mapcar #'(lambda (a) (getf a :data)) tracking-data))
                     (combined-data (remove-duplicates (mapcar #'cons xs-raw ys-raw)
                                                       :test #'(lambda (a b)
                                                                 (string= (car a) (car b)))))
                     (xs      (mapcar #'car combined-data))
                     (ys      (mapcar #'cdr combined-data)))
                (images-utils:draw-graph xs ys))))))))

(define-lab-route graph-chem-quantity-months ("/images/qty-months/:chemical-id")
  (generate-tracking-graph '(:year "-" :short-month) chemical-id))

(define-lab-route graph-chem-quantity-days ("/images/qty-days/:chemical-id")
  (generate-tracking-graph '(:year "-" :short-month "-" :day) chemical-id))

(defun manage-tracking-chem-prod (infos errors &key (chemprod-id nil))
  (let ((chemical (chem-prod->chem-compound chemprod-id)))
    (with-standard-html-frame (stream
                               (format nil (_ "Track chemical usage of: ~s") (db:name chemical))
                               :errors errors
                               :infos  infos)
      (html-template:fill-and-print-template #p"track-chemical-product.tpl"
                                             (with-path-prefix
                                                 :tracking-quantity-latest-months
                                               (restas:genurl 'graph-chem-quantity-months
                                                              :chemical-id chemprod-id)
                                               :tracking-quantity-latest-days
                                               (restas:genurl 'graph-chem-quantity-days
                                                              :chemical-id chemprod-id))
                                             :stream stream))))

(define-lab-route tracking-chem-prod ("/tracking-chem-prod/:id-product" :method :get)
  (with-authentication
    (manage-tracking-chem-prod nil nil :chemprod-id (safe-parse-number id-product -1))))
