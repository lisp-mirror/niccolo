;; niccolo': a chemicals inventory
;; Copyright (C) 2016  Universita' degli Studi di Palermo

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :restas.lab)

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

(defmethod send-user-message  ((object db:waste-message) sender-id rcpt-id subject text
			       &key
				 (echo-message nil)
				 (cer-code-id  nil)
				 (building-id  nil)
				 (weight       nil)
				 (adr-ids      '()))
  (format t "validation -> ~a ~a ~a ~a"
	  (regexp-validate (list (list cer-code-id +integer-re+ "ok")))
	  (regexp-validate (list (list building-id +integer-re+ "ok")))
	  (regexp-validate (list (list weight +integer-re+ "ok")))
	  (every #'(lambda (a) (regexp-validate (list (list a +integer-re+ "ok"))))
		 adr-ids))
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
      msg)))

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
					      :time    (decode-datetime-string (db:sent-time msg))))))
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
	       (delete-link  (restas:genurl 'delete-expire-message :id (getf row :msg-id))))
	  (setf (elt raw rown)
		(nconc row
		       (list :decoded-sent-time (decode-datetime-string (getf row :sent-time)))
		       (list :delete-link delete-link)
		       (children-template (getf row :msg-id))
		       (list :chemp-id-string (if-db-nil-else (getf row :chemp-id)
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
	       (delete-link  (restas:genurl 'delete-expire-message :id (getf row :msg-id))))
	  (setf (elt raw rown)
		(nconc row
		       (list :decoded-sent-time (decode-datetime-string (getf row :sent-time)))
		       (list :delete-link delete-link)
		       (children-template (getf row :msg-id))
		       (list :chemp-id-string (if-db-nil-else (getf row :chemp-id)
							      (_ "Product deleted")))))))
      raw)))

(defun %build-waste-template (user-id &optional (other-status nil))
  (let* ((the-query (select ((:as :message.id        :msg-id)
			     (:as :message.status    :status)
			     (:as :message.sent-time :sent-time)
			     (:as :message.subject   :subject)
			     (:as :message.text      :text)
			     (:as :sender.username   :sender-username)
			     (:as :rcpt.username     :rcpt-username))
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
      (html-template:fill-and-print-template #p"expiration-messages.tpl"
					     (with-path-prefix
						 :expiration-messages-hd-lb (_ "Expired products")
						 :product-id-lb  (_ "Product ID")
						 :subject-lb     (_ "Subject")
						 :sent-time-lb   (_ "Sent at")
						 :sender-lb    (_ "Sender")
						 :rcpt-lb      (_ "Recipient")
						 :message-lb   (_ "Message")
						 :operations-lb (_ "Operations")
						 :messages (build-expiration-template))
					     :stream stream)
      (html-template:fill-and-print-template #p"expiration-messages.tpl"
					     (with-path-prefix
						 :expiration-messages-hd-lb (_ "Validity expired products")
						 :product-id-lb  (_ "Product ID")
						 :subject-lb     (_ "Subject")
						 :sent-time-lb   (_ "Sent at")
						 :sender-lb    (_ "Sender")
						 :rcpt-lb      (_ "Recipient")
						 :message-lb   (_ "Message")
						 :operations-lb (_ "Operations")
						 :messages (build-validity-expired-template))
					     :stream stream)
      (html-template:fill-and-print-template #p"waste-messages.tpl"
					     (with-path-prefix
						 :waste-messages-hd-lb (_ "Opened Waste messages")
						 :subject-lb     (_ "Subject")
						 :sent-time-lb   (_ "Sent at")
						 :sender-lb    (_ "Sender")
						 :rcpt-lb      (_ "Recipient")
						 :message-lb   (_ "Message")
						 :operations-lb (_ "Operations")
						 :messages (build-waste-template +msg-status-open+))
					     :stream stream)
      (html-template:fill-and-print-template #p"waste-messages.tpl"
					     (with-path-prefix
						 :waste-messages-hd-lb (_ "Rejected waste messages")
						 :subject-lb     (_ "Subject")
						 :sent-time-lb   (_ "Sent at")
						 :sender-lb    (_ "Sender")
						 :rcpt-lb      (_ "Recipient")
						 :message-lb   (_ "Message")
						 :operations-lb (_ "Operations")
						 :messages (build-waste-template +msg-status-closed-unsuccess+))
					     :stream stream)
      (html-template:fill-and-print-template #p"waste-messages.tpl"
					     (with-path-prefix
						 :waste-messages-hd-lb (_ "Accepted waste messages")
						 :subject-lb     (_ "Subject")
						 :sent-time-lb   (_ "Sent at")
						 :sender-lb    (_ "Sender")
						 :rcpt-lb      (_ "Recipient")
						 :message-lb   (_ "Message")
						 :operations-lb (_ "Operations")
						 :messages (build-waste-template +msg-status-closed-success+))
					     :stream stream)

      (let ((html-template:*string-modifier* #'identity))
	(html-template:fill-and-print-template #p"user-messages.tpl"
					       (with-path-prefix
						   :user-messages-hd-lb (_ "Messages")
						   :subject-lb     (_ "Subject")
						   :sent-time-lb   (_ "Sent at")
						   :sender-lb    (_ "Sender")
						   :rcpt-lb      (_ "Recipient")
						   :message-lb   (_ "Message")
						   :operations-lb (_ "Operations")
						   :messages (build-general-message-template))
					       :stream stream)))))

(defun waste-message-deletable-p (message)
  (let ((waste-msg (single 'db:waste-message :message (db:id message))))
    (and waste-msg ;; yes, the message is linked to a waste request
	 (waste-message-expired-p message)))) ;; and yes the message is older than a year

(defun set-delete-message (id &key
				(deletable-p-fn #'(lambda (user message)
						    (and (waste-message-deletable-p message)
							 (or (session-admin-p)
							     (= (db:id user)
								(db:recipient message)))))))
  (with-session-user (user)
    (when (not (regexp-validate (list (list id +pos-integer-re+ "no"))))
      (let ((to-trash (single 'db:message :id (parse-integer id))))
	(when (and to-trash
		   (funcall deletable-p-fn user to-trash))
	  (setf (db:status to-trash) +msg-status-deleted+)
	  (save to-trash)))))) ; TODO recursively delete (set status) all children!

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

(defun close-w-status-message (id status)
  (with-authentication
    (with-admin-privileges
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
      	 (print-messages (list *insufficient-privileges-message*) nil))))

(define-lab-route close-w-success-message ("/close-success-message/:id" :method :get)
  (close-w-status-message id +msg-status-closed-success+))

(define-lab-route close-w-failure-message ("/close-failure-message/:id" :method :get)
  (close-w-status-message id +msg-status-closed-unsuccess+))
