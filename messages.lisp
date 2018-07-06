;; niccolo': a chemicals inventory
;; Copyright (C) 2016  Universita' degli Studi di Palermo

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

(define-constant +name-broadcast-msg-body+    "body"    :test #'string=)

(define-constant +name-broadcast-msg-subject+ "subj"    :test #'string=)

(define-constant +name-registration-num+      "reg-num" :test #'string=)

(define-constant +name-id-message+            "id"      :test #'string=)

(define-constant +name-broadcast-msg-subject+ "subj"    :test #'string=)

(defmacro define-status-codes (&rest codes)
  `(progn
     ,@(loop for code in codes collect
            `(define-constant
                 ,(format-symbol t   "~:@(+msg-status-~a+~)" code)
                 ,(format        nil "~:@(msg-status-~a~)" code)
                 :test #'string=))))

(define-status-codes open deleted closed-unsuccess closed-success)

(defun status-deleted-p-fn ()
  #'(lambda (a)
      (let ((msg (single 'db:message :id (db:message a))))
        (and msg
             (string= (db:status msg) +msg-status-deleted+)))))

(defun status-open-p-fn ()
  #'(lambda (a)
      (let ((msg (single 'db:message :id (db:message a))))
        (and msg
             (string= (db:status msg) +msg-status-open+)))))

(defgeneric send-user-message (object sender-id rcpt-id subject text
                               &key
                                 sent-time
                                 echo-message
                                 parent-message
                                 child-message
                                 email-text
                                 &allow-other-keys))

(defmethod send-user-message  ((object db:message) sender-id rcpt-id subject text
                               &key
                                 (email-text text)
                                 (sent-time (local-time-obj-now))
                                 (echo-message   nil)
                                 (parent-message nil)
                                 (child-message  nil))
  (with-authentication
    (with-session-user (user)
      (let ((db-user   (user-session->user user))
            (rcpt-user (single 'db:user :id rcpt-id)))
        (when (and db-user
                   rcpt-user)
          (let ((msg (create 'db:message
                             :sender    sender-id
                             :recipient rcpt-id
                             :echo-to   echo-message
                             :subject   subject
                             :sent-time sent-time
                             :status    +msg-status-open+
                             :text      text)))
            (create 'db:message-relation
                    :node   (db:id msg)
                    :parent parent-message
                    :child  child-message)
            (create 'db:message-relation
                    :node   parent-message
                    :parent nil
                    :child  (db:id msg))
            (when (db:email db-user)
              (send-email (db:subject msg)
                          (db:email rcpt-user)
                          email-text))
            msg))))))

(defmethod send-user-message  ((object db:expiration-message) sender-id rcpt-id subject text
                               &key
                                 (product-id nil)
                                 &allow-other-keys)
  (when product-id
    (let ((msg (send-user-message (make-instance 'db:message)
                                  sender-id
                                  rcpt-id
                                  subject
                                  text)))
      (create 'db:expiration-message
              :message (db:id msg)
              :product product-id))))

(defmethod send-user-message  ((object db:validity-expired-message) sender-id rcpt-id subject text
                               &key
                                 (product-id nil))
  (when product-id
    (let ((msg (send-user-message (make-instance 'db:message)
                                  sender-id
                                  rcpt-id
                                  subject
                                  text)))
      (create 'db:validity-expired-message
              :message (db:id msg)
              :product product-id))))

(defmethod send-user-message  ((object db:compound-shortage-message) sender-id rcpt-id subject text
                               &key
                                 (compound-id nil))
  (when compound-id
    (let ((msg (send-user-message (make-instance 'db:message)
                                  sender-id
                                  rcpt-id
                                  subject
                                  text)))
      (create 'db:compound-shortage-message
              :message (db:id msg)
              :compound compound-id))))

(defmethod send-user-message  ((object db:waste-message) sender-id rcpt-id subject text
                               &key
                                 (echo-message nil)
                                 (cer-code-id  nil)
                                 (building-id  nil)
                                 (weight       nil)
                                 (adr-ids      '())
                                 (hp-ids       '()))
  (when (and (not (regexp-validate (list (list cer-code-id +integer-re+ "ok"))))
             (not (regexp-validate (list (list building-id +integer-re+ "ok"))))
             (not (regexp-validate (list (list weight +integer-re+ "ok"))))
             (every #'(lambda (a) (null (regexp-validate (list (list a +integer-re+ "ok")))))
                    adr-ids))
    (let* ((msg       (send-user-message (make-instance 'db:message)
                                         sender-id
                                         rcpt-id
                                         subject
                                         text
                                         :echo-message echo-message))
           (waste-msg (create 'db:waste-message
                              :message     (db:id msg)
                              :cer-code-id cer-code-id
                              :building-id building-id
                              :weight      weight)))
      (dolist (adr-id adr-ids)
        (create 'db:waste-message-adr
                :waste-message (db:id waste-msg)
                :adr-code-id   adr-id))
      (dolist (hp-id hp-ids)
        (create 'db:waste-message-hp
                :waste-message (db:id waste-msg)
                :hp-code-id   hp-id))
      msg)))

(defun number-of-msg-sent-to-me ()
  "Only non-deleted"
  (with-session-user (user)
    (length (filter 'db:message
                    :recipient (db:id user)
                    (:!= :status +msg-status-deleted+)))))

(defun create-expiration-messages (expired-product-list)
  "Expired-Product-List comes from evaluation of (fetch-expired-products)"
  (with-session-user (user)
    (let ((admin (single 'db:user :level +admin-acl-level+)))
      (when admin
        (dolist (expired expired-product-list)
          (let ((chemp-id (getf expired :chemp-id)))
            (when (or (null (filter 'db:expiration-message :product chemp-id))
                      (and
                       (some (status-deleted-p-fn)
                             (filter 'db:expiration-message :product chemp-id))
                       (not (some (status-open-p-fn)
                                  (filter 'db:expiration-message :product chemp-id)))))
              (let* ((msg-text (format nil
                                       (_ "Product ~a from building ~a (storage name ~a) has expired.")
                                       (getf expired :chem-name)
                                       (getf expired :building-name)
                                       (getf expired :storage-name))))
                (send-user-message (make-instance 'db:expiration-message)
                                   (db:id admin)
                                   (db:id user)
                                   (_ "Product expired")
                                   msg-text
                                   :product-id chemp-id)))))))))

(defun create-validity-expired-messages (expired-product-list)
  "Expired-Product-List comes from evaluation of (fetch-expired-products)"
  (with-session-user (user)
    (let ((admin (single 'db:user :level +admin-acl-level+)))
      (when admin
        (dolist (expired expired-product-list)
          (let ((chemp-id (getf expired :chemp-id)))
            (when (or (null (filter 'db:validity-expired-message :product chemp-id))
                      (and
                       (some (status-deleted-p-fn)
                             (filter 'db:validity-expired-message :product chemp-id))
                       (not (some (status-open-p-fn)
                                  (filter 'db:validity-expired-message :product chemp-id)))))
              (let* ((msg-text (format nil
                                       (_ "Product ~a from building ~a (storage name ~a) has expired validity date.")
                                       (getf expired :chem-name)
                                       (getf expired :building-name)
                                       (getf expired :storage-name))))
                (send-user-message (make-instance 'db:validity-expired-message)
                                   (db:id admin)
                                   (db:id user)
                                   (_ "Product validity expired")
                                   msg-text
                                   :product-id chemp-id)))))))))

(defun fetch-children-messages (msg-id)
  (sort
   (mapcar #'db:child
           (filter 'db:message-relation (:and (:= :node msg-id)
                                              (:not (:is-null :child)))))
   #'(lambda (a b)
       (timestamp-compare-desc (db:sent-time (single 'db:message :id a))
                               (db:sent-time (single 'db:message :id b))))))

(defun fetch-parent-message (msg-id)
  (first
   (remove-if #'null
              (mapcar #'db:parent
                      (filter 'db:message-relation :node msg-id)))))

(defun children-template (msg-id)
  (list :children (remove-if #'null
                             (mapcar #'(lambda (a)
                                         (let ((msg (single 'db:message :id a)))
                                           (when msg
                                             (list
                                              :child-id a
                                              :url     (restas:genurl 'ws-get-user-message
                                                                      :id a)
                                              :subject (db:subject msg)
                                              :time (decode-datetime-string (db:sent-time msg))))))
                                     (fetch-children-messages msg-id)))))

(defun fetch-template-message-by-id (id)
  (let* ((the-query (select ((:as :message.id        :mid)
                             (:as :message.sent-time :sent-time)
                             (:as :message.subject   :subject)
                             (:as :message.text      :text)
                             (:as :sender.username   :sender-username)
                             (:as :rcpt.username     :rcpt-username))
                      (from :message)
                      (left-join (:as :user :sender) :on (:= :message.sender :sender.id))
                      (left-join (:as :user :rcpt)   :on (:= :message.recipient :rcpt.id))
                      (where (:and (:not (:= :message.status +msg-status-deleted+))
                                   (:= :mid id)))))
         (row (first (keywordize-query-results (query the-query)))))
    (when row
      (let* ((delete-link  (restas:genurl 'delete-expire-message :id (getf row :mid))))
        (setf row
              (nconc row
                     (children-template (getf row :mid))
                     (list :decoded-sent-time (decode-datetime-string (getf row :sent-time)))
                     (list :delete-link delete-link)))))
    row))

(defun build-expiration-template ()
  (with-session-user (user)
    (let* ((the-query (select ((:as :message.id        :msg-id)
                               (:as :message.sent-time :sent-time)
                               (:as :message.subject   :subject)
                               (:as :message.text      :text)
                               (:as :sender.username   :sender-username)
                               (:as :rcpt.username     :rcpt-username)
                               (:as :exp-msg.product   :chemp-id))
                         (from :message)
                         (left-join (:as :user :sender) :on (:= :message.sender :sender.id))
                         (left-join (:as :user :rcpt)   :on (:= :message.recipient :rcpt.id))
                         (inner-join (:as :expiration-message :exp-msg) :on
                                     (:= :message.id :exp-msg.message))
                         (where (:and
                                 (:not (:= :message.status +msg-status-deleted+))
                                 (:= :message.recipient (db:id user))))
                         (order-by (:desc :message.sent-time))))
           (raw (keywordize-query-results (query the-query))))
      (do-rows (rown res) raw
        (let* ((row (elt raw rown))
               (delete-link  (restas:genurl 'delete-expire-message :id (getf row :msg-id)))
               (search-link  (if (not (db-nil-p (getf row :chemp-id)))
                                 (gen-id-product-search-query (getf row :chemp-id))
                                 nil)))
          (setf (elt raw rown)
                (nconc row
                       (list :decoded-sent-time (decode-datetime-string (getf row :sent-time)))
                       (list :delete-link delete-link)
                       (children-template (getf row :msg-id))
                       (list :search-link search-link)
                       (list :chemp-id-string (or (getf row :chemp-id)
                                                  (_ "Product deleted")))))))
      raw)))

(defun build-validity-expired-template ()
  (with-session-user (user)
    (let* ((the-query (select ((:as :message.id        :msg-id)
                               (:as :message.sent-time :sent-time)
                               (:as :message.subject   :subject)
                               (:as :message.text      :text)
                               (:as :sender.username   :sender-username)
                               (:as :rcpt.username     :rcpt-username)
                               (:as :exp-msg.product   :chemp-id))
                         (from :message)
                         (left-join (:as :user :sender) :on (:= :message.sender :sender.id))
                         (left-join (:as :user :rcpt)   :on (:= :message.recipient :rcpt.id))
                         (inner-join (:as :validity-expired-message :exp-msg) :on
                                     (:= :message.id :exp-msg.message))
                         (where (:and
                                 (:not (:= :message.status +msg-status-deleted+))
                                 (:= :message.recipient (db:id user))))
                         (order-by (:desc :message.sent-time))))
           (raw (keywordize-query-results (query the-query))))
      (do-rows (rown res) raw
        (let* ((row (elt raw rown))
               (delete-link  (restas:genurl 'delete-expire-message :id (getf row :msg-id)))
               (search-link  (if (not (db-nil-p (getf row :chemp-id)))
                                 (gen-id-product-search-query (getf row :chemp-id))
                                 nil)))
          (setf (elt raw rown)
                (nconc row
                       (list :decoded-sent-time (decode-datetime-string (getf row :sent-time)))
                       (list :delete-link delete-link)
                       (children-template (getf row :msg-id))
                       (list :search-link search-link)
                       (list :chemp-id-string (or (getf row :chemp-id)
                                                  (_ "Product deleted")))))))
      raw)))

(defun %build-waste-template (user-id &optional (other-status nil))
  (let* ((the-query (select ((:as :message.id                    :msg-id)
                             (:as :message.status                :status)
                             (:as :message.sent-time             :sent-time)
                             (:as :message.subject               :subject)
                             (:as :message.text                  :text)
                             (:as :waste-msg.weight              :weight)
                             (:as :waste-msg.id                  :waste-id)
                             (:as :waste-msg.registration-number :registration-number)
                             (:as :sender.username               :sender-username)
                             (:as :rcpt.username                 :rcpt-username))
                      (from :message)
                      (left-join (:as :user :sender) :on (:= :message.sender :sender.id))
                      (left-join (:as :user :rcpt)   :on (:= :message.recipient :rcpt.id))
                      (inner-join (:as :waste-message :waste-msg) :on
                                  (:= :message.id :waste-msg.message))
                      (where (:and
                              (if other-status
                                  `(:= :message.status ,other-status)
                                  `(:= 1 1))
                              (:not (:= :message.status +msg-status-deleted+))
                              (:= :message.recipient user-id)))
                      (order-by :message.sent-time :desc)))
         (raw (keywordize-query-results (query the-query))))
    raw))

(defun build-waste-template (&optional (other-status nil))
  (with-authentication
    (with-session-user (user)
      (let* ((raw (%build-waste-template (db:id user) other-status)))
        (do-rows (rown res) raw
          (let* ((row (elt raw rown))
                 (delete-link  (restas:genurl 'delete-expire-message :id (getf row :msg-id)))
                 (close-w-success-link (restas:genurl 'close-w-success-message
                                                       :id (getf row :msg-id)))
                 (close-w-failure-link (restas:genurl 'close-w-failure-message
                                                      :id (getf row :msg-id)))
                 (assoc-registration-number-link
                  (restas:genurl 'assoc-registration-waste-message)))
            (setf (elt raw rown)
                  (nconc row
                         (list :decoded-sent-time     (decode-datetime-string (getf row :sent-time)))
                         (list :delete-link           delete-link)
                         (list :close-w-success-link  close-w-success-link)
                         (list :close-w-failure-link  close-w-failure-link)
                         (list :assoc-reg-number-link assoc-registration-number-link)
                         (list :admin-p               (session-waste-manager-p))
                         (list :confirm-msg-lb        (add-slashes (_ "Confirm operation?")))
                         (children-template (getf row :msg-id))))))
        raw))))

(defun %build-shortage-template (user-id &optional (other-status nil))
  (let* ((the-query (select ((:as :message.id        :msg-id)
                             (:as :message.status    :status)
                             (:as :message.sent-time :sent-time)
                             (:as :message.subject   :subject)
                             (:as :message.text      :text)
                             (:as :sender.username   :sender-username)
                             (:as :rcpt.username     :rcpt-username)
                             (:as :rcpt.id           :rcpt-id)
                             (:as :sh-msg.compound   :compound-id))
                      (from :message)
                      (left-join (:as :user :sender) :on (:= :message.sender :sender.id))
                      (left-join (:as :user :rcpt)   :on (:= :message.recipient :rcpt.id))
                      (inner-join (:as :compound-shortage-message :sh-msg) :on
                                  (:= :message.id :sh-msg.message))
                      (where (:and
                              (if other-status
                                  `(:= :message.status ,other-status)
                                  `(:= 1 1))
                              (:not (:= :message.status +msg-status-deleted+))
                              (:= :message.recipient user-id)))
                      (order-by :message.sent-time :desc)))
         (raw (keywordize-query-results (query the-query))))
    raw))

(defun build-shortage-template (&optional (other-status nil))
  (with-authentication
    (with-session-user (user)
      (let* ((raw (%build-shortage-template (db:id user) other-status)))
        (do-rows (rown res) raw
          (let* ((row (elt raw rown))
                 (delete-link  (restas:genurl 'delete-expire-message :id (getf row :msg-id)))
                 (close-w-success-link  (restas:genurl 'close-w-success-message
                                                       :id (getf row :msg-id)))
                 (close-w-failure-link  (restas:genurl 'close-w-failure-message
                                                       :id (getf row :msg-id))))
            (setf (elt raw rown)
                  (nconc row
                         (list :decoded-sent-time (decode-datetime-string (getf row :sent-time)))
                         (list :delete-link delete-link)
                         (list :close-w-success-link close-w-success-link)
                         (list :close-w-failure-link close-w-failure-link)
                         (list :admin-p (session-admin-p))
                         (children-template (getf row :msg-id))))))
        raw))))

(defun fetch-all-chemicals-by-users (id)
  (keywordize-query-results
   (query (select ((:as :chemp.compound :id)
                   (:as :chemp.compound :id))
            (from (:as :chemical-product :chemp))
            (where (:= :chemp.owner id))
            (group-by :chemp.compound)))))

(defun chemical-quantities-total (id)
  (let ((compound-ids (map 'vector #'last-elt (fetch-all-chemicals-by-users id))))
    (loop for compound-id across compound-ids collect
         (let ((all-products (filter 'db:chemical-product :owner id :compound compound-id)))
           (let ((sum (reduce #'(lambda (a b)
                                  (let ((qty   (db:quantity b))
                                        (units (db:units    b)))
                                    (if (scan "^m" units)
                                        (+ a (/ qty 1000))
                                        (+ a qty))))
                              all-products
                              :initial-value 0.0))
                 (threshold (single 'db:chemical-compound-preferences
                                    :owner id :compound compound-id)))
             (list :owner id
                   :id compound-id
                   :quantity sum
                   :threshold (and threshold (db:shortage threshold))))))))

(defun shortage-products-list (user-id)
  (remove-if #'(lambda (a)
                 (or (not (getf a :threshold))
                     (>=   (getf a :quantity)
                           (getf a :threshold))))
             (chemical-quantities-total user-id)))

(defun create-shortage-messages (shortage-products-list)
  "Shortage-products-list comes from evaluation of (shortage-products-list id)"
  (with-session-user (user)
    (let ((admin (single 'db:user :level +admin-acl-level+)))
      (when admin
        (dolist (shortage shortage-products-list)
          (let ((chem-id  (getf shortage :id))
                (owner    (getf shortage :owner))
                (template (build-shortage-template)))
            (when (null (find-if #'(lambda (a)
                                       (and (= (getf a :rcpt-id)
                                               owner)
                                            (= (getf a :compound-id)
                                               chem-id)))
                                 template))
              (let* ((chem (single 'db:chemical-compound :id chem-id))
                     (msg-text (format nil
                                       (_ "Product ~a quantity (~a) below threshold: ~a.")
                                       (db:name chem)
                                       (getf shortage :quantity)
                                       (getf shortage :threshold))))
                (send-user-message (make-instance 'db:compound-shortage-message)
                                   (db:id admin)
                                   (db:id user)
                                   (_ "Product shortage")
                                   msg-text
                                   :compound-id chem-id)))))))))

(defun build-all-specialized-messages ()
  (values (build-expiration-template)
          (build-validity-expired-template)
          (build-waste-template)))

(defun same-message-id-p (row)
  #'(lambda (r)
      (= (getf row :msg-id)
         (getf r :msg-id))))

(defun same-message-children-id-p (row)
  #'(lambda (r)
      (let ((children-id (mapcar #'(lambda (c) (getf c :child-id))
                                 (getf r :children))))
        (find (getf row :msg-id) children-id :test #'=))))

(defun build-general-message-template ()
  (with-session-user (user)
    (let* ((the-query (select ((:as :message.id        :msg-id)
                               (:as :message.sent-time :sent-time)
                               (:as :message.subject   :subject)
                               (:as :message.text      :text)
                               (:as :sender.username   :sender-username)
                               (:as :rcpt.username     :rcpt-username))
                        (from :message)
                        (left-join (:as :user :sender) :on (:= :message.sender :sender.id))
                        (left-join (:as :user :rcpt)   :on (:= :message.recipient :rcpt.id))
                        (inner-join (:as :message-relation :msg-rel) :on
                                    (:=  :msg-rel.node :message.id))
                        (where (:and
                                (:not (:= :message.status +msg-status-deleted+))
                                (:= :message.recipient (db:id user))
                                (:is-null :msg-rel.parent)))))
           (raw (keywordize-query-results (query the-query))))
      (do-rows (rown res) raw
        (let* ((row (elt raw rown))
               (delete-link  (restas:genurl 'delete-expire-message :id (getf row :msg-id))))
          (setf (elt raw rown)
                (nconc row
                       (list :decoded-sent-time (decode-datetime-string (getf row :sent-time)))
                       (list :delete-link delete-link)
                       (children-template (getf row :msg-id))))))
      (multiple-value-bind (exp-message validity-exp-message waste-messages)
          (build-all-specialized-messages)
        (remove-if #'(lambda (a)
                       (or
                        ;; delete expire messages
                        (find-if (same-message-id-p a) exp-message)
                        ;; delete validity expired messages
                        (find-if (same-message-id-p a) validity-exp-message)
                        ;; delete waste-messages
                        (find-if (same-message-id-p a) waste-messages)
                        ;; these are useless maybe
                        (find-if (same-message-children-id-p a) waste-messages)
                        (find-if (same-message-children-id-p a) exp-message)
                        (find-if (same-message-children-id-p a) validity-exp-message)))
                   raw)))))

(defun fetch-expired-messages-linked-to-product (id-product)
  "Note: deleted messages not included"
  (let* ((the-query (select ((:as :message.id :msg-id))
                         (from :message)
                         (inner-join (:as :expiration-message :exp-msg) :on
                                    (:and
                                     (:= :message.id :exp-msg.message)
                                     (:= :exp-msg.product id-product)))
                         (where (:and
                                 (:not (:= :message.status +msg-status-deleted+))))))
         (raw (keywordize-query-results (query the-query))))
    (mapcar #'(lambda (a) (second a)) raw)))

(defun fetch-validity-expired-messages-linked-to-product (id-product)
  "Note: deleted messages not included"
  (let* ((the-query (select ((:as :message.id :msg-id))
                         (from :message)
                         (inner-join (:as :validity-expired-message :exp-msg) :on
                                     (:and
                                      (:= :message.id :exp-msg.message)
                                      (:= :exp-msg.product id-product)))
                         (where (:and
                                 (:not (:= :message.status +msg-status-deleted+))))))
         (raw (keywordize-query-results (query the-query))))
    (mapcar #'(lambda (a) (second a)) raw)))

(defun print-messages (errors infos)
  (with-authentication
    (with-standard-html-frame (stream (_ "Messages") :infos infos :errors errors)
      (html-template:fill-and-print-template #p"messages-common-js.tpl"
                                             (with-path-prefix)
                                             :stream stream)
      (html-template:fill-and-print-template #p"expiration-messages.tpl"
                                             (with-path-prefix
                                                 :expiration-messages-hd-lb (_ "Expired products")
                                                 :product-id-lb    (_ "Product ID")
                                                 :subject-lb       (_ "Subject")
                                                 :sent-time-lb     (_ "Sent at")
                                                 :sender-lb        (_ "Sender")
                                                 :rcpt-lb          (_ "Recipient")
                                                 :message-lb       (_ "Message")
                                                 :operations-lb    (_ "Operations")
                                                 :not-available-lb (_ "Not available")
                                                 :messages (build-expiration-template))
                                             :stream stream)
      (html-template:fill-and-print-template #p"expiration-messages.tpl"
                                             (with-path-prefix
                                                 :expiration-messages-hd-lb (_ "Validity expired products")
                                                 :product-id-lb    (_ "Product ID")
                                                 :subject-lb       (_ "Subject")
                                                 :sent-time-lb     (_ "Sent at")
                                                 :sender-lb        (_ "Sender")
                                                 :rcpt-lb          (_ "Recipient")
                                                 :message-lb       (_ "Message")
                                                 :operations-lb    (_ "Operations")
                                                 :not-available-lb (_ "Not available")
                                                 :messages (build-validity-expired-template))
                                             :stream stream)
      (html-template:fill-and-print-template #p"waste-messages.tpl"
                                             (with-path-prefix
                                                 :waste-messages-hd-lb   (_ "Opened Waste messages")
                                                 :subject-lb             (_ "Subject")
                                                 :sent-time-lb           (_ "Sent at")
                                                 :sender-lb              (_ "Sender")
                                                 :rcpt-lb                (_ "Recipient")
                                                 :message-lb             (_ "Message")
                                                 :operations-lb          (_ "Operations")
                                                 :registration-number-lb (_ "Registration number")
                                                 :name-registration-num  +name-registration-num+
                                                 :name-id-message        +name-id-message+
                                                 :messages (build-waste-template +msg-status-open+))
                                             :stream stream)
      (html-template:fill-and-print-template #p"waste-messages.tpl"
                                             (with-path-prefix
                                                 :waste-messages-hd-lb (_ "Rejected waste messages")
                                                 :subject-lb           (_ "Subject")
                                                 :sent-time-lb         (_ "Sent at")
                                                 :sender-lb            (_ "Sender")
                                                 :rcpt-lb              (_ "Recipient")
                                                 :message-lb           (_ "Message")
                                                 :operations-lb        (_ "Operations")
                                                 :registration-number-lb (_ "Registration number")
                                                 :name-registration-num  +name-registration-num+
                                                 :name-id-message        +name-id-message+
                                                 :messages (build-waste-template +msg-status-closed-unsuccess+))
                                             :stream stream)
      (html-template:fill-and-print-template #p"waste-messages.tpl"
                                             (with-path-prefix
                                                 :waste-messages-hd-lb
                                               (_ "Accepted waste messages")
                                                 :subject-lb             (_ "Subject")
                                                 :sent-time-lb           (_ "Sent at")
                                                 :sender-lb              (_ "Sender")
                                                 :rcpt-lb                (_ "Recipient")
                                                 :message-lb             (_ "Message")
                                                 :operations-lb          (_ "Operations")
                                                 :registration-number-lb (_ "Registration number")
                                                 :name-registration-num  +name-registration-num+
                                                 :name-id-message        +name-id-message+
                                                 :messages (build-waste-template +msg-status-closed-success+))
                                             :stream stream)

      (let ((html-template:*string-modifier* #'identity))
        (html-template:fill-and-print-template #p"user-messages.tpl"
                                               (with-path-prefix
                                                   :user-messages-hd-lb    (_ "Messages")
                                                   :subject-lb             (_ "Subject")
                                                   :sent-time-lb           (_ "Sent at")
                                                   :sender-lb              (_ "Sender")
                                                   :rcpt-lb                (_ "Recipient")
                                                   :message-lb             (_ "Message")
                                                   :operations-lb          (_ "Operations")
                                                   :name-registration-num  +name-registration-num+
                                                   :name-id-message        +name-id-message+
                                                   :messages (build-general-message-template))
                                               :stream stream)))))

(defun waste-message-p (message)
  (single 'db:waste-message :message (db:id message)))

(defun waste-message-deletable-p (user message)
  (and (waste-message-p message) ;; yes, the message is linked to a waste request
       (waste-message-expired-p message) ;; and yes the message is older than a year
       (= (db:id user) (db:recipient message))))

(defun set-delete-message (id &key
                                (deletable-p-fn #'(lambda (user message)
                                                    (if (waste-message-p message)
                                                        (waste-message-deletable-p user message)
                                                        (if (= (db:id user)
                                                               (db:recipient message))
                                                            t
                                                            (session-admin-p))))))
  (with-session-user (user)
    (when (not (regexp-validate (list (list id +pos-integer-re+ "no"))))
      (let ((to-trash (single 'db:message :id (parse-integer id))))
        (when (and to-trash
                   (funcall deletable-p-fn user to-trash))
          (setf (db:status to-trash) +msg-status-deleted+)
          (save to-trash)
          ;; recursive delete
          (let ((children (mapcar #'(lambda (u) (format nil "~a" (db:child u)))
                                  (filter 'db:message-relation :node (db:id to-trash)))))
            (dolist (child-id children)
              (set-delete-message child-id :deletable-p-fn deletable-p-fn))))))))

(define-lab-route delete-expire-message ("/delete-expire-message-prod/:id" :method :get)
  (with-authentication
    (when (not (regexp-validate (list (list id +pos-integer-re+ "no"))))
      (set-delete-message id))
    (restas:redirect 'user-messages)))

(defun email-text-closed-success-user (msg)
  (format nil
          (_ "Your request:~2%----~2%~a~2%----~2%has been approved.")
          (db:text msg)))

(defun email-text-closed-unsuccess-user (msg)
  (format nil
          (_ "Your request:~2%----~2%~a~2%----~2%has been rejected.")
          (db:text msg)))

(defun reply-to (id subject body)
  (with-authentication
    (with-admin-or-waste-manager-credentials
        (let* ((error-no-id (regexp-validate (list (list id
                                                         +integer-re+
                                                         (_ "Invalid message ID provided")))))
               (error-no-message (if (and (not error-no-id)
                                          (not (single 'db:message :id id)))
                                     (_ "No message with ID ~a found")
                                     nil)))
          (if (and (not error-no-id)
                   (not error-no-message))
              (let ((parent (single 'db:message :id id)))
                (send-user-message (make-instance 'db:message)
                                   (db:recipient parent)
                                   (db:recipient parent)
                                   subject
                                   body
                                   :child-message nil
                                   :parent-message id)
                (when (db:echo-to parent)
                  (let ((echo-message (single 'db:message :id (db:echo-to parent))))
                    (when echo-message
                      (send-user-message (make-instance 'db:message)
                                         (db:recipient    parent)
                                         (db:recipient echo-message)
                                         subject
                                         body
                                         :email-text body
                                         :child-message nil
                                         :parent-message (db:id echo-message)))))
                (print-messages nil (list (format nil
                                                  (_ "Replied to Message ~a")
                                                  id))))
              (print-messages (concatenate 'list
                                           error-no-id
                                           error-no-message)
                              nil)))
      (print-messages (list *insufficient-privileges-message*) nil))))

(defun close-w-status-message (id status)
  (with-authentication
    (with-waste-manager-credentials
        (let* ((error-no-id (regexp-validate (list (list id
                                                         +integer-re+
                                                         (_ "Invalid message ID provided")))))
               (error-no-message (if (and (not error-no-id)
                                          (not (single 'db:message :id id)))
                                     (_ "No message with ID ~a found")
                                     nil)))
          (if (and (not error-no-id)
                   (not error-no-message))
              (let ((parent (single 'db:message :id id)))
                (send-user-message (make-instance 'db:message)
                                   (db:recipient parent)
                                   (db:recipient parent)
                                   (_ "Updated status")
                                   (if (string= status +msg-status-closed-success+)
                                       (_ "Closed with success")
                                       (_ "Closed and rejected"))
                                   :child-message nil
                                   :parent-message id)
                (setf (db:status parent) status)
                (save parent)
                (when (db:echo-to parent)
                  (let ((echo-message (single 'db:message :id (db:echo-to parent))))
                    (when echo-message
                      (send-user-message (make-instance 'db:message)
                                         (db:recipient    parent)
                                         (db:recipient echo-message)
                                         (_ "Updated status")
                                         (if (string= status +msg-status-closed-success+)
                                             (_ "Closed with success")
                                             (_ "Closed and rejected"))
                                         :email-text
                                         (if (string= status +msg-status-closed-success+)
                                             (email-text-closed-success-user  echo-message)
                                             (email-text-closed-unsuccess-user echo-message))
                                         :child-message nil
                                         :parent-message (db:id echo-message))
                      (setf (db:status echo-message) status)
                      (save echo-message))))
                (print-messages nil (list (format nil
                                                  (if (string= status +msg-status-closed-success+)
                                                      (_ "Message ~a closed with success")
                                                      (_ "Message ~a closed and rejected"))
                                                  id))))
              (print-messages (concatenate 'list
                                           error-no-id
                                           error-no-message)
                              nil)))
         (print-messages (list (_ "This operation is available for waste manager only.")) nil))))

(define-lab-route close-w-success-message ("/close-success-message/:id" :method :get)
  (close-w-status-message id +msg-status-closed-success+))

(define-lab-route close-w-failure-message ("/close-failure-message/:id" :method :get)
  (close-w-status-message id +msg-status-closed-unsuccess+))

(define-lab-route assoc-registration-waste-message ("/assoc-reg-waste/" :method :get)
  (with-authentication
    (with-waste-manager-credentials
        (let* ((error-reg (regexp-validate (list (list (get-parameter +name-registration-num+)
                                                       +waste-registration-number-re+
                                                       (_ "Registration number format invalid")))))

               (error-msg-id (regexp-validate (list (list (get-parameter +name-id-message+)
                                                          +integer-re+
                                                          (_ "Id not valid")))))
               (message      (and (null error-reg)
                                  (null error-msg-id)
                                  (get-column-from-id (get-parameter +name-id-message+)
                                                      +pos-integer-re+
                                                      'db:waste-message
                                                      #'identity
                                                      :default nil)))
               (wrapper-message (and message
                                     (single 'db:message :id (db:message message)))))
          (when message
            (cond
              ((and wrapper-message
                    (typep message 'db:waste-message)
                    (null  (db:registration-number message))
                    (string= (db:status wrapper-message) +msg-status-closed-success+))
               (setf (db:registration-number message) (get-parameter +name-registration-num+))
               (save message)
               (reply-to (format nil "~a" (db:id wrapper-message))
                         (format nil
                                 (_ "Added registration number ~a")
                                 (get-parameter +name-registration-num+))
                         (format nil
                                 (_ "The registration number ~s has been attached to your message:  ~3%~a")
                                 (get-parameter +name-registration-num+)
                                 (db:text wrapper-message)))
               (print-messages nil
                               (list (format nil
                                             (_ "The registration number ~s has been attached to message: ~a")
                                             (get-parameter +name-registration-num+)
                                             (db:id wrapper-message)))))
              ((and wrapper-message
                    (typep message 'db:waste-message)
                    (null  (db:registration-number message))
                    (string/= (db:status wrapper-message) +msg-status-closed-success+))
               (print-messages (list (_ "Request has not been closed with success."))
                               nil))
              ((and message
                    (typep message 'db:waste-message)
                    (not (null (db:registration-number message))))
               (print-messages (list (_ "The registration number can not be changed"))
                               nil))
              (t
               (print-messages (list (_ "Generic error")) nil)))))
      (manage-chem nil (list (_ "This operation is available for waste manager only."))))))

(defun send-broadcast-message (subject body)
  (let* ((actual-subject (strip-tags subject))
         (actual-body    (strip-tags body))
         (errors (regexp-validate (list (list actual-subject
                                              +free-text-re+
                                              (_ "Subject invalid"))
                                        (list actual-body
                                              +free-text-re+
                                              (_ "Body invalid"))))))
    (if (not errors)
        (progn
          (dolist (user (filter 'db:user))
            (send-user-message (make-instance 'db:message)
                               (admin-id)
                               (db:id user)
                               actual-subject
                               actual-body))
          (manage-broadcast-message (list (format nil
                                                  "Message ~s successfully sent"
                                                  actual-subject))
                                    nil))
         (manage-broadcast-message  nil errors))))

(defun manage-broadcast-message (infos errors)
  (with-standard-html-frame (stream
                             (_ "Broadcast message")
                             :errors errors
                             :infos  infos)
    (html-template:fill-and-print-template #p"broadcast-message.tpl"
                                             (with-path-prefix
                                                 :subject-lb (_ "Subject")
                                                 :body-lb    (_ "Body")
                                                 :subject    +name-broadcast-msg-subject+
                                                 :body       +name-broadcast-msg-body+)
                                             :stream stream)))

(define-lab-route broadcast-message ("/broadcast-message/" :method :get)
  (with-authentication
    (with-admin-credentials
        (if (and (get-parameter +name-broadcast-msg-subject+)
                 (get-parameter +name-broadcast-msg-body+))
            (send-broadcast-message (get-parameter +name-broadcast-msg-subject+)
                                    (get-parameter +name-broadcast-msg-body+))
            (manage-broadcast-message nil nil))
      (manage-broadcast-message nil (list *insufficient-privileges-message*)))))
