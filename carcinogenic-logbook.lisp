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

(defgeneric carc-log-entry->mail (log &key added))

(defmethod carc-log-entry->mail ((log (eql nil)) &key (added t))
  (declare (ignore log added))
  "")

(defmethod carc-log-entry->mail ((log number) &key (added t))
  (carc-log-entry->mail (db-single 'db:carcinogenic-logbook (safe-parse-number log -1))
                        :added added))

(defmethod carc-log-entry->mail ((log db:carcinogenic-logbook) &key (added t))
  (let ((lab (db-single 'db:laboratory :id (db:laboratory-id log)))
        (msg (if added
                 (_ "A log entry related to your carcinogenics substances usage at ~s has been *recorded*:~2% ~a~%")
                 (_ "A log entry related to your carcinogenics substances at ~s has been *canceled*:~2% ~a~%"))))
    (format nil
            msg
            (db:complete-name lab)
            (db:build-description log))))

(defun make-carc-log-units (chemprod)
  (let ((raw-units (db:units chemprod)))
    ;; Sorry... :(
    (cond
      ((string= "ml" raw-units)
       "L")
      ((cl-ppcre:scan "^m+.+" raw-units)
       (subseq raw-units 1))
      (t
       raw-units))))

(defun update-chemprod-carcinogenic-log (chemprod new-quantity new-units old-quantity old-units
                                         new-carc-laboratory-id
                                         new-carc-person-id new-carc-worker-code new-carc-work-type
                                         new-carc-work-type-code new-carc-work-method
                                         new-carc-work-exp-time &key (send-email t))
  "Values are success-log-added log-was-needed log-carc-errors-messages"
  (let* ((actual-old-units    (and (stringp old-units) old-units))
         (actual-new-quantity (normalize-quantity-units (safe-parse-number new-quantity -1)
                                                        new-units))
         (actual-old-quantity (normalize-quantity-units (safe-parse-number old-quantity -1)
                                                        actual-old-units)))
    (if (and (db:carcinogenic-iarc-p chemprod)
             (< actual-new-quantity actual-old-quantity))
        (let* ((errors-msg-generic (regexp-validate (list (list new-carc-laboratory-id
                                                                +pos-integer-re+
                                                                (_ "laboratory ID invalid"))
                                                          (list new-carc-person-id
                                                                +pos-integer-re+
                                                                (_ "Person ID invalid"))
                                                          (list new-carc-worker-code
                                                                +free-text-re+
                                                                (_ "Worker code invalid"))
                                                          (list new-carc-work-type
                                                                +free-text-re+
                                                                (_ "Work type invalid"))
                                                          (list new-carc-work-type-code
                                                                +free-text-re+
                                                                (_ "Work type code invalid"))
                                                          (list new-carc-work-method
                                                                +free-text-re+
                                                                (_ "Work method invalid"))
                                                          (list new-carc-work-exp-time
                                                                +pos-integer-re+
                                                                (_ "Exposition type invalid")))))
               (error-not-associed-lab (when (and (null errors-msg-generic)
                                                  (not (user-lab-associed-p (get-session-user-id)
                                                                            new-carc-laboratory-id)))
                                         (list (_ "You are not in charge for this laboratory"))))
               (error-msg-person-not-exists  (when (and (all-null-p errors-msg-generic
                                                                    error-not-associed-lab)
                                                        (not (object-exists-in-db-p
                                                              'db:person new-carc-person-id)))
                                               (list (_ "Person does not exists in database"))))
               (errors-msg (concatenate 'list
                                        errors-msg-generic
                                        error-msg-person-not-exists
                                        error-not-associed-lab))
               (success-msg (and (not errors-msg)
                                 (format nil (_ "Saved carcinogenic log entry")))))
          ;; "Values are success-log-added log-was-needed log-carc-errors-messages"
          (if success-msg
              (let ((log-entry (db-create'db:carcinogenic-logbook
                                       :chemical-id     (db:compound chemprod)
                                       :laboratory-id   new-carc-laboratory-id
                                       :person-id       new-carc-person-id
                                       :worker-code     new-carc-worker-code
                                       :work-type       new-carc-work-type
                                       :work-type-code  new-carc-work-type-code
                                       :work-methods    new-carc-work-method
                                       :exposition-time new-carc-work-exp-time
                                       :recording-date  (local-time-obj-now)
                                       :quantity        (- actual-old-quantity
                                                           actual-new-quantity)
                                       :units           (make-carc-log-units chemprod)))
                    (person    (db-single 'db:person new-carc-person-id)))
                (when (and send-email
                           (db:email person))
                  (send-email (_ "Carcinogenic log entry")
                              (db:email person)
                              (carc-log-entry->mail log-entry)))
                (values log-entry t nil))
              (values nil t errors-msg)))
        (values t nil nil))))

(defun filter-carcinogenic-logs (lab-id)
  (when lab-id
    (let ((one-year-ago (crane.inflate-deflate:deflate (local-time:timestamp- (local-time:now)
                                                                              1 :year))))
      (db-query (select ((:as :carc.id         :log-id)
                      :worker-code
                      :work-type
                      :work-type-code
                      :work-methods
                      :quantity
                      :units
                      :exposition-time
                      :canceled
                      :recording-date
                      (:as :person-id       :person-id)
                      (:as :chem.other-cid  :chem-cid)
                      (:as :chem.name       :chem-name)
                      (:as :l.name          :lab-name)
                      (:as :l.complete-name :lab-fullname))
               (from (:as :carcinogenic-logbook  :carc))
               (left-join (:as :chemical-compound :chem) :on (:= :carc.chemical-id   :chem.id))
               (left-join (:as :person            :p)    :on (:= :carc.person-id     :p.id))
               (left-join (:as :laboratory        :l)    :on (:= :carc.laboratory-id :l.id))
               (where (:and (:= :l.id lab-id)
                            (:> :carc.recording-date
                                one-year-ago))))))))

(defun build-template-carc-logbook (lab-id start-from data-count &key (delete-link nil))
  (let ((raw (keywordize-query-results (filter-carcinogenic-logs lab-id))))
    (do-rows (rown res)
        (slice-for-pagination raw start-from data-count)
      (let* ((row (elt res rown)))
        (setf (elt res rown)
              (concatenate 'list
                           row
                           (list :canceledp (not (db-nil-p (getf row :canceled))))
                           (list :quantity-rounded
                                 (format nil "~,4f" (getf row :quantity)))
                           (list :worker
                                 (db:build-description (db-single 'db:person
                                                               :id (getf row :person-id))))
                           (if delete-link
                               (list :delete-link (delete-uri delete-link row :id-keyword :log-id))
                               nil)))))))

(defun manage-carc-logbook (lab-id infos errors &key (start-from 0) (data-count 1))
  (let ((html-template:*string-modifier* #'escape-string-all-but-double-quotes)
        (all-logs (build-template-carc-logbook lab-id
                                               (actual-pagination-start start-from)
                                               (actual-pagination-count data-count)
                                               :delete-link  'delete-carcinogenic-logbook-entry))
        (json-laboratory           (array-autocomplete-laboratory (get-session-user-id)))
        (json-laboratory-id        (array-autocomplete-laboratory-id (get-session-user-id))))
    (multiple-value-bind (next-start prev-start)
        (pagination-bounds (actual-pagination-start start-from)
                           (actual-pagination-count data-count)
                           'db:ghs-hazard-statement)
      (with-standard-html-frame (stream (_ "Carcinogenic Logbook")
                                        :infos infos :errors errors)
        (html-template:fill-and-print-template #p"carcinogenic-logbook.tpl"
                                               (with-back-to-root
                                                   (with-pagination-template
                                                       (next-start
                                                        prev-start
                                                        (restas:genurl 'carcinogenic-logbook ))
                                                     (with-path-prefix
                                                         :next-start         next-start
                                                         :prev-start         prev-start
                                                         :worker-lb          (_ "Worker")
                                                         :laboratory-id-lb   (_ "Laboratory ID")
                                                         :laboratory-name-lb (_ "Laboratory")
                                                         :quantity-lb
                                                         (_ "Quantity (Mass or Volume)")
                                                         :units-lb           (_ "Unit of measure")
                                                         :person-id-lb       (_ "Worker")
                                                         :worker-code-lb     (_ "Worker code")
                                                         :work-type-lb       (_ "Work type")
                                                         :work-type-code-lb
                                                         (_ "Work type (ID code)")
                                                         :work-methods-lb    (_ "Work methods")
                                                         :exposition-time-lb
                                                         (_ "Exposition time (min)")
                                                         :chemical-name-lb
                                                         (_ "Product name")
                                                         :log-canceled-p-lb
                                                         (_ "Canceled")
                                                         :operations-lb      (_ "Operations")
                                                         :labs-id            +name-lab-id+
                                                         :json-laboratory    json-laboratory
                                                         :json-laboratory-id json-laboratory-id
                                                         :data-table         all-logs)))
                                               :stream stream)))))

(define-lab-route delete-carcinogenic-logbook-entry ("/del-carcinogenic-loogbook/:id" :method :get)
  (with-authentication
    (with-pagination (pagination-uri utils:*alias-pagination*)
      (let* ((log-id (safe-parse-number id -1))
             (log    (db-single 'db:carcinogenic-logbook :id log-id)))
        (if (and log
                 (user-lab-associed-p (get-session-user-id)
                                      (db-single 'db:laboratory
                                              :id (db:laboratory-id log))))
            (let ((person (db-single 'db:person :id (db:person-id log))))
              (setf (db:canceled log) 1)
              (db-save log)
              (when (db:email person)
                (send-email (_ "Carcinogenic log entry canceled")
                            (db:email person)
                            (carc-log-entry->mail log :added nil)))
              (manage-carc-logbook (db:laboratory-id log)
                                   (list (format nil (_ "Log ~a marked as canceled") log-id))
                                   nil
                                   :start-from (session-pagination-start pagination-uri
                                                                         utils:*alias-pagination*)
                                   :data-count (session-pagination-count pagination-uri
                                                                         utils:*alias-pagination*)))
            (manage-carc-logbook nil
                                 nil
                                 (list (_ "Log non cancelled"))
                                 :start-from (session-pagination-start pagination-uri
                                                                       utils:*alias-pagination*)
                                 :data-count
                                 (session-pagination-count pagination-uri
                                                           utils:*alias-pagination*)))))))

(define-lab-route carcinogenic-logbook ("/carcinogenic-logbook/" :method :get)
  (with-authentication
    (with-pagination (pagination-uri utils:*alias-pagination*)
      (let ((lab-id (get-clean-parameter +name-lab-id+)))
        (manage-carc-logbook (safe-parse-number lab-id nil)
                             nil nil
                             :start-from (session-pagination-start pagination-uri
                                                                   utils:*alias-pagination*)
                             :data-count (session-pagination-count pagination-uri
                                                                   utils:*alias-pagination*))))))
