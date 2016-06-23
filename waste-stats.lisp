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

(defmacro gen-select-message-statistics (status group-by-column)
  `(select ((:as (:sum :waste-message.weight) :sum-weight)
	    (:as :cer-code.id                 :cer-id)
	    (:as :user.username               :username)
	    (:as :message.sent-time           :sent-time)
	    (:as :waste-message.weight :weight)
	    (:as :building.name        :building-name)
	    (:as :building.id          :building-id)
	    (:as :address.line-1       :address-line-1)
	    (:as :address.city         :city)
	    (:as :address.zipcode      :zipcode)
	    (:as :cer-code.code        :cer-code))
     (from :waste-message)
     (inner-join :message :on (:and (:= :message.id :waste-message.message)
				    (:= :message.status ,status)
				    (:= :message.recipient (admin-id))))
     (inner-join :building :on (:= :building.id :waste-message.building-id))
     (inner-join :address  :on (:= :address.id  :building.address-id))
     (inner-join :cer-code :on (:= :cer-code.id :waste-message.cer-code-id))
     (inner-join :user     :on (:=  :user.id     :message.sender))
     (group-by ,group-by-column)))

(defmacro define-aggregation-waste-query (group-by-column)
  `(defun ,(format-symbol t "~:@(waste-messages-statistics-by-~a~)" group-by-column)
       (status &optional (last-year-only))
     (let* ((the-query (gen-select-message-statistics status ,group-by-column))
	    (raw (keywordize-query-results (query the-query))))
       (if last-year-only
	   (remove-if (remove-old-waste-stats) raw)
	   raw))))

(define-aggregation-waste-query :cer-id)

(define-aggregation-waste-query :building-id)

(define-aggregation-waste-query :username)

(defun print-waste-statistic (errors infos)
  (with-authentication
    (with-standard-html-frame (stream (_ "Waste report") :infos infos :errors errors)
      (html-template:fill-and-print-template #p"waste-stats-header.tpl"
					     (with-path-prefix
						 :overall-lb (_ "Last year"))
					     :stream stream)
      (html-template:fill-and-print-template #p"waste-stats.tpl"
       					     (with-path-prefix
						 :legend-group-lb (_ "Opened")
						 :not-found-lb (_ "Nothing found")
						 :code-lb   (_ "Code")
						 :weight-lb (_ "Weight (Kg)")
						 :username-lb (_ "Username")
						 :user-group-caption-lb (_ "Grouped by user")
						 :building-description-lb (_ "Building")
						 :buildings-group-caption-lb (_ "Grouped by building")
						 :cer-group-caption-lb (_ "Grouped by CER code")
						 :cer-group (waste-messages-statistics-by-cer-id +msg-status-open+ t)
						 :buildings-group (waste-messages-statistics-by-building-id +msg-status-open+ t)
						 :user-group     (waste-messages-statistics-by-username +msg-status-open+ t))
					     :stream stream)
      (html-template:fill-and-print-template #p"waste-stats.tpl"
					     (with-path-prefix
						 :legend-group-lb (_ "Closed")
						 :not-found-lb (_ "Nothing found")
						 :username-lb (_ "Username")
						 :user-group-caption-lb (_ "Grouped by user")
						 :code-lb   (_ "Code")
						 :weight-lb (_ "Weight (Kg)")
						 :buildings-group-caption-lb (_ "Grouped by building")
						 :cer-group-caption-lb (_ "Grouped by CER code")

						 :building-description-lb (_ "Building")
						 :cer-group (waste-messages-statistics-by-cer-id +msg-status-closed-success+ t)
						 :buildings-group (waste-messages-statistics-by-building-id +msg-status-closed-success+ t)
						 :user-group     (waste-messages-statistics-by-username +msg-status-closed-success+ t))
					     :stream stream)
      (html-template:fill-and-print-template #p"waste-stats.tpl"
					     (with-path-prefix
						 :legend-group-lb (_ "Rejected")
						 :not-found-lb (_ "Nothing found")
						 :username-lb (_ "Username")
						 :user-group-caption-lb (_ "Grouped by user")
						 :code-lb   (_ "Code")
						 :weight-lb (_ "Weight (Kg)")
						 :buildings-group-caption-lb (_ "Grouped by building")
						 :cer-group-caption-lb (_ "Grouped by CER code")

						 :building-description-lb (_ "Building")
						 :cer-group (waste-messages-statistics-by-cer-id +msg-status-closed-unsuccess+ t)
						 :buildings-group (waste-messages-statistics-by-building-id +msg-status-closed-unsuccess+ t)
						 :user-group     (waste-messages-statistics-by-username +msg-status-closed-unsuccess+ t))
					     :stream stream)

      (html-template:fill-and-print-template #p"waste-stats-header.tpl"
					     (with-path-prefix
						 :overall-lb (_ "Overall"))
					     :stream stream)
      (html-template:fill-and-print-template #p"waste-stats.tpl"
       					     (with-path-prefix
						 :legend-group-lb (_ "Opened")
						 :not-found-lb (_ "Nothing found")
						 :code-lb   (_ "Code")
						 :weight-lb (_ "Weight (Kg)")
						 :username-lb (_ "Username")
						 :user-group-caption-lb (_ "Grouped by user")
						 :building-description-lb (_ "Building")
						 :buildings-group-caption-lb (_ "Grouped by building")
						 :cer-group-caption-lb (_ "Grouped by CER code")
						 :cer-group (waste-messages-statistics-by-cer-id +msg-status-open+)
						 :buildings-group (waste-messages-statistics-by-building-id +msg-status-open+)
						 :user-group     (waste-messages-statistics-by-username +msg-status-open+))
					     :stream stream)
      (html-template:fill-and-print-template #p"waste-stats.tpl"
					     (with-path-prefix
						 :legend-group-lb (_ "Closed")
						 :not-found-lb (_ "Nothing found")
						 :username-lb (_ "Username")
						 :user-group-caption-lb (_ "Grouped by user")
						 :code-lb   (_ "Code")
						 :weight-lb (_ "Weight (Kg)")
						 :buildings-group-caption-lb (_ "Grouped by building")
						 :cer-group-caption-lb (_ "Grouped by CER code")

						 :building-description-lb (_ "Building")
						 :cer-group (waste-messages-statistics-by-cer-id +msg-status-closed-success+)
						 :buildings-group (waste-messages-statistics-by-building-id +msg-status-closed-success+)
						 :user-group     (waste-messages-statistics-by-username +msg-status-closed-success+))
					     :stream stream)
      (html-template:fill-and-print-template #p"waste-stats.tpl"
					     (with-path-prefix
						 :legend-group-lb (_ "Rejected")
						 :not-found-lb (_ "Nothing found")
						 :username-lb (_ "Username")
						 :user-group-caption-lb (_ "Grouped by user")
						 :code-lb   (_ "Code")
						 :weight-lb (_ "Weight (Kg)")
						 :buildings-group-caption-lb (_ "Grouped by building")
						 :cer-group-caption-lb (_ "Grouped by CER code")

						 :building-description-lb (_ "Building")
						 :cer-group (waste-messages-statistics-by-cer-id +msg-status-closed-unsuccess+)
						 :buildings-group (waste-messages-statistics-by-building-id +msg-status-closed-unsuccess+)
						 :user-group     (waste-messages-statistics-by-username +msg-status-closed-unsuccess+))
					     :stream stream))))



(define-lab-route waste-statistics ("/print-waste-stats/" :method :get)
  (with-authentication
    (with-admin-privileges
	(print-waste-statistic nil nil)
      (print-messages (list *insufficient-privileges-message*) nil))))
