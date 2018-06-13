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

(define-constant +name-address-line-1+  "line-1"  :test #'string=)

(define-constant +name-address-city+    "city"    :test #'string=)

(define-constant +name-address-zipcode+ "zipcode" :test #'string=)

(define-constant +name-address-link+    "link"    :test #'string=)

(defun generate-openstreetmap-link (line-1 city)
  (format nil "~a/?q=~a ~a" +openstreetmap-query-url+ line-1 city))

(defun add-new-address (line-1 city zipcode link)
  (let* ((errors-msg-1 (concatenate 'list
                                    (regexp-validate (list (list line-1
                                                                 +free-text-re+
                                                                 (_ "Line-1 invalid"))
                                                           (list city
                                                                 +free-text-re+
                                                                 (_ "City field invalid"))
                                                           (list zipcode
                                                                 +free-text-re+
                                                                 (_ "Zipcode invalid"))))))
         (errors-msg-link (when (not (null link))
                            (regexp-validate (list (list link
                                                         +free-text-re+
                                                         (_ "Link invalid"))))))
         (errors-msg-2  (when (and (all-null-p errors-msg-1 errors-msg-link)
                                   (single 'db:address
                                           :line-1  line-1
                                           :city    city
                                           :zipcode zipcode))
                          (list (_ "Address already in the database"))))
         (errors-msg (concatenate 'list errors-msg-1 errors-msg-2))
         (success-msg (and (not errors-msg)
                           (list (format nil
                                         (_ "Saved address: ~s - ~s ~s")
                                         line-1 zipcode city)))))
    (when (not errors-msg)
      (let ((address (create 'db:address
                             :line-1 line-1
                             :city city
                             :zipcode zipcode
                             :link (if (string-empty-p link)
                                       (generate-openstreetmap-link line-1 city)
                                       link))))
        (save address)))
    (manage-address success-msg errors-msg)))

(defun manage-address (infos errors)
  (let ((all-addresses (fetch-raw-template-list 'db:address
                                                '(:id :line-1 :city :zipcode :link)
                                                :delete-link 'delete-address
                                                :additional-tpl
                                                #'(lambda (row)
                                                    (list
                                                     :update-address-link
                                                     (restas:genurl 'update-address
                                                                    :id (db:id row)))))))
    (with-standard-html-frame (stream (_ "Manage Address") :infos infos :errors errors)
      (html-template:fill-and-print-template #p"add-address.tpl"
                                             (with-back-to-root
                                               (with-path-prefix
                                                   :address-lb (_ "Address")
                                                   :link-lb    (_ "Link")
                                                   :operation-lb (_ "Operation")
                                                   :zipcode-lb   (_ "Zipcode")
                                                   :line-1 +name-address-line-1+
                                                   :city +name-address-city+
                                                   :zipcode +name-address-zipcode+
                                                   :link    +name-address-link+
                                                   :data-table all-addresses))
                                             :stream stream))))

(define-lab-route address ("/address/" :method :get)
  (with-authentication
    (manage-address nil nil)))

(define-lab-route add-address ("/add-address/" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (add-new-address (get-parameter +name-address-line-1+)
                           (get-parameter +name-address-city+)
                           (get-parameter +name-address-zipcode+)
                           (get-parameter +name-address-link+)))
      (manage-address nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-address ("/delete-address/:id" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
            (let ((to-trash (single 'db:address :id id)))
              (when to-trash
                (del (single 'db:address :id id)))))
          (restas:redirect 'address))
      (manage-address nil (list *insufficient-privileges-message*)))))
