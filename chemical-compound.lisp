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

(define-constant +name-chem-id+          "id"             :test #'string=)

(define-constant +name-chem-proper-name+ "name"           :test #'string=)

(define-constant +name-chem-cid+         "pubchem-cid"    :test #'string=)

(define-constant +name-chem-other-cid+   "other-cid"    :test #'string=)

(define-constant +name-chem-msds-data+   "msds-pdf"       :test #'string=)

(define-constant +name-chem-struct-data+ "structure-file" :test #'string=)

(defun add-new-chem (name msds-filename struct-filename cid other-cid
                     &key (start-from 0) (data-count 1))
  (let* ((errors-msg-1  (regexp-validate (list (list name +free-text-re+ (_ "Name invalid")))))
         (errors-msg-msds-file (when (and msds-filename
                                          (not (pdf-validate-p msds-filename)))
                                 (list (_ "Invalid pdf file"))))
         (errors-msg-struct-file (when (and struct-filename
                                            (not (sdf-validate-p struct-filename)))
                                   (list (_ "Invalid structure file"))))
         (errors-msg-2  (when (and (not errors-msg-1)
                                   (unique-p-validate
                                    'db:chemical-compound
                                    :name name
                                    (_ "Chemical compound already in the database")))))
         (error-msg-other-cid (when (and (not (string-empty-p other-cid))
                                         (not (other-registry-number-validate-p other-cid)))
                                (list (_ "Chemical identifier format not valid"))))
         (errors-msg (concatenate 'list
                                  errors-msg-1
                                  errors-msg-2
                                  errors-msg-msds-file
                                  errors-msg-struct-file
                                  error-msg-other-cid))
         (success-msg (and (not errors-msg)
                           (list (format nil (_ "Saved chemical: ~s") name)))))
    (when (not errors-msg)
      (let ((new-chem (create 'db:chemical-compound
                              :name name
                              :other-cid   (if (string-empty-p other-cid)
                                               nil
                                               other-cid)
                              :pubchem-cid (if (scan +pos-integer-re+ cid)
                                               cid
                                               nil)
                              :msds        (if msds-filename
                                               (base64-encode
                                                (read-file-into-byte-vector msds-filename))
                                               nil)
                              :structure-file (if struct-filename
                                                  (read-file-into-string struct-filename)
                                                  nil))))
        (save new-chem)))
    (manage-chem success-msg errors-msg
                 :start-from start-from
                 :data-count data-count)))

(defun manage-chem (infos errors &key (start-from 0) (data-count 1))
  (let* ((all-chem       (do-rows (row-idx res) ; TODO refactor
                             (fetch-raw-template-list 'db:chemical-compound
                                                      '(:id :pubchem-cid :other-cid :name
                                                        :msds :structure-file)
                                                      :delete-link 'delete-chemical
                                                      :additional-tpl
                                                      #'(lambda (row)
                                                          (list
                                                           :update-chemical-link
                                                           (restas:genurl 'update-chemical
                                                                          :id (db:id row)))))
                           (let ((row (elt res row-idx)))
                             (setf (elt res row-idx)
                                   (nconc row
                                          (list
                                           :haz-diamond-url
                                           (restas:genurl 'display-hazard-diamond
                                                          :id (getf row :id))
                                           :toggle-haz-diamond-haz-link
                                           (restas:genurl 'toggle-haz-diamond-haz
                                                          :id (getf row :id))
                                           :toggle-haz-diamond-fire-link
                                           (restas:genurl 'toggle-haz-diamond-fire
                                                          :id (getf row :id))
                                           :toggle-haz-diamond-corrosive-link
                                           (restas:genurl 'toggle-haz-diamond-corrosive
                                                          :id (getf row :id))
                                           :toggle-haz-diamond-reactive-link
                                           (restas:genurl 'toggle-haz-diamond-reactive
                                                          :id (getf row :id))
                                           :assoc-prec-link
                                           (restas:genurl 'assoc-chem-prec :id (getf row :id))
                                           :assoc-haz-link
                                           (restas:genurl 'assoc-chem-haz :id (getf row :id))
                                           :assoc-sec-fq-link
                                           (restas:genurl 'assoc-chem-haz-prec-fq
                                                          :id (getf row :id))
                                           :has-msds (if (getf row :msds) t nil)
                                           :has-struct-file (if (getf row :structure-file) t nil)
                                           :msds-pdf-link
                                           (restas:genurl 'chemical-get-msds :id (getf row :id))
                                           :struct-file-link
                                           (restas:genurl 'chemical-get-struct-file
                                                          :id (getf row :id))))))))
         (paginated-chem (slice-for-pagination all-chem
                                               (actual-pagination-start start-from)
                                               (actual-pagination-count data-count))))
    (multiple-value-bind (next-start prev-start)
        (pagination-bounds (actual-pagination-start start-from)
                           (actual-pagination-count data-count)
                           'db:chemical-compound)
      (with-standard-html-frame (stream (_ "Manage Chemical Compound")
                                        :infos infos
                                        :errors errors)
        (html-template:fill-and-print-template #p"add-chemical.tpl"
                                               (with-back-to-root
                                                   (with-pagination-template
                                                       (next-start
                                                        prev-start
                                                        (restas:genurl 'chemical))
                                                     (with-path-prefix
                                                         :name-lb        (_ "Name")
                                                         :pubchem-cid-lb
                                                         (_ "pubchem CID")
                                                         :other-cid-lb
                                                         (_ "Other registration number")
                                                         :msds-file-lb   (_ "MSDS file")
                                                         :data-sheet-lb  (_ "Data Sheet")
                                                         :struct-file-lb (_ "Stucture file")
                                                         :haz-diamond-lb (_ "Hazard")
                                                         :operations-lb  (_ "Operations")
                                                         :id             +name-chem-id+
                                                         :name           +name-chem-proper-name+
                                                         :msds-pdf       +name-chem-msds-data+
                                                         :struct-data    +name-chem-struct-data+
                                                         :pubchem-cid    +name-chem-cid+
                                                         :other-cid      +name-chem-other-cid+
                                                         :data-table     paginated-chem)))
                                               :stream stream)))))

(defun get-chem-data-column (id column-fn)
  (when (integer-positive-validate id)
    (let ((chem (single 'db:chemical-compound :id id)))
      (if chem
          (funcall column-fn chem)
          nil))))

(define-lab-route chemical-get-msds ("/chemical-msds/:id" :method :get)
  (with-authentication
    (let ((msds (get-chem-data-column id #'db:msds)))
      (if msds
          (progn
            (setf (header-out :content-type) +mime-pdf+)
            (base64-decode msds))
          +http-not-found+))))

(define-lab-route chemical-get-struct-file ("/chemical-struct/:id" :method :get)
  (with-authentication
    (let ((structure-file (get-chem-data-column id #'db:structure-file)))
      (if structure-file
          (progn
            (setf (header-out :content-type) +mime-sdf+)
            structure-file)
          +http-not-found+))))

(define-lab-route chemical ("/chemical/" :method :get)
  (with-authentication
    (with-pagination (pagination-uri utils:*alias-pagination*)
      (manage-chem nil nil
                   :start-from (session-pagination-start pagination-uri utils:*alias-pagination*)
                   :data-count (session-pagination-count pagination-uri
                                                         utils:*alias-pagination*)))))

(define-lab-route add-chemical ("/add-chemical/" :method :post)
  (with-authentication
    (with-editor-or-above-privileges
        (with-pagination (pagination-uri utils:*alias-pagination*)
          (let ((name            (tbnl:post-parameter +name-chem-proper-name+))
                (cid             (tbnl:post-parameter +name-chem-cid+))
                (other-cid       (tbnl:post-parameter +name-chem-other-cid+))
                (msds-filename   (get-post-filename +name-chem-msds-data+))
                (struct-filename (get-post-filename +name-chem-struct-data+)))
            (add-new-chem name msds-filename struct-filename cid other-cid
                          :start-from (session-pagination-start pagination-uri utils:*alias-pagination*)
                          :data-count (session-pagination-count pagination-uri
                                                                utils:*alias-pagination*))))
      (manage-chem nil (list *insufficient-privileges-message*)))))

(define-lab-route delete-chemical ("/delete-chemical/:id" :method :get)
  (with-authentication
    (with-admin-privileges
        (progn
          (when (not (regexp-validate (list (list id +pos-integer-re+ ""))))
            (let ((to-trash (single 'db:chemical-compound :id id)))
              (when to-trash
                (del (single 'db:chemical-compound :id id)))))
          (restas:redirect 'chemical))
      (manage-chem nil (list *insufficient-privileges-message*)))))

(define-lab-route subst-msds ("/subst-msds/:id" :method :post)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (let ((has-not-errors  (and (not (regexp-validate (list (list id +pos-integer-re+ ""))))
                                      (get-post-filename +name-chem-msds-data+)
                                      (pdf-validate-p (get-post-filename +name-chem-msds-data+))))
                (success-msg     (list (_ "MSDS uploaded")))
                (error-general   (list (_ "MSDS not uploaded")))
                (error-not-found (list (format nil
                                               (_ "MSDS not uploaded, chemical (id: ~a) not found")
                                               id))))
            (if has-not-errors
                (let ((msds-file (get-post-filename +name-chem-msds-data+))
                      (updated-chem (single 'db:chemical-compound :id id)))
                  (if updated-chem
                      (progn
                        (setf (db:msds updated-chem)
                              (base64-encode (read-file-into-byte-vector msds-file)))
                        (save updated-chem)
                        (manage-chem success-msg nil))
                      (manage-chem nil error-not-found)))
                (manage-chem nil error-general))))
      (manage-chem nil (list *insufficient-privileges-message*)))))

(define-lab-route subst-struct-file ("/subst-struct-file/:id" :method :post)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (let ((has-not-errors  (and (integer-positive-validate id)
                                      (get-post-filename +name-chem-struct-data+)
                                      (sdf-validate-p (get-post-filename +name-chem-struct-data+))))
                (success-msg     (list (_ "Structure uploaded")))
                (error-general   (list (_ "Structure not uploaded")))
                (error-not-found (list (format nil
                                               (_ "Structure not uploaded, chemical (id: ~a) not found")
                                               id))))
            (if has-not-errors
                (let ((struct-file  (get-post-filename +name-chem-struct-data+))
                      (updated-chem (single 'db:chemical-compound :id id)))
                  (if updated-chem
                      (progn
                        (setf (db:structure-file updated-chem)
                              (read-file-into-string struct-file))
                        (save updated-chem)
                        (manage-chem success-msg nil))
                      (manage-chem nil error-not-found)))
                (manage-chem nil error-general))))
      (manage-chem nil (list *insufficient-privileges-message*)))))

(defun %toggle-color (id color-fn)
  (let ((has-not-errors (and (regexp-validate (list (list id +pos-integer-re+ "")))
                             (object-exists-in-db-p 'db:chemical-compound id))))
    (when (not has-not-errors)
      (let ((old-value (get-chem-data-column id color-fn))
            (updated-chem (single 'db:chemical-compound :id id)))
        (when updated-chem
          (setf (slot-value updated-chem color-fn)
                (if old-value nil "1"))
          (save updated-chem))))))

(define-lab-route toggle-haz-diamond-haz ("/toggle-blue/:id" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (%toggle-color id 'db:haz-color)
          (restas:redirect 'chemical))
      (manage-chem nil (list *insufficient-privileges-message*)))))

(define-lab-route toggle-haz-diamond-fire ("/toggle-red/:id" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (%toggle-color id 'db:fire-color)
          (restas:redirect 'chemical))
      (manage-chem nil (list *insufficient-privileges-message*)))))

(define-lab-route toggle-haz-diamond-corrosive ("/toggle-yellow/:id" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (%toggle-color id 'db:corrosive-color)
          (restas:redirect 'chemical))
      (manage-chem nil (list *insufficient-privileges-message*)))))

(define-lab-route toggle-haz-diamond-reactive ("/toggle-green/:id" :method :get)
  (with-authentication
    (with-editor-or-above-privileges
        (progn
          (%toggle-color id 'db:reactive-color)
          (restas:redirect 'chemical))
      (manage-chem nil (list *insufficient-privileges-message*)))))
