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

(in-package :restas.lab)

(define-constant +name-waste-user-name+          "name"              :test #'string=)

(define-constant +name-waste-cer-id+             "cer"               :test #'string=)

(define-constant +name-waste-description+        "desc"              :test #'string=)

(define-constant +name-waste-building-id+        "building-id"       :test #'string=)

(define-constant +name-waste-phys-id+            "physical-state-id" :test #'string=)

(define-constant +name-waste-lab-id+             "lab-id"           :test #'string=)

(define-constant +name-waste-weight+             "weight"            :test #'string=)

(define-constant +name-select-adr+               "select-adr"        :test #'string=)

(define-constant +name-select-hp+                "select-hp"         :test #'string=)

(gen-autocomplete-functions db:cer-code db:code)

(defun lab-id->name (id)
  (let ((res (single 'db:laboratory :id id)))
    (if res
        (db:name res)
        (_ "Laboratory unknown"))))

(defun adr-list ()
  (let ((raw (filter 'db:adr-code)))
    (loop for i in raw collect
         (list :adr-id         (db:id i)
               :adr-uncode     (db:uncode i)
               :adr-code-class (db:code-class i)
               :adr-expl       (db:explanation i)))))

(defun hp-list ()
  (let ((raw (filter 'db:hp-waste-code)))
    (loop for i in raw collect
         (list :hp-id         (db:id i)
               :hp-code       (db:code i)
               :hp-expl       (db:explanation i)))))

(defun %collect-all (parameters name)
  (loop for i in parameters when (string= name (car i)) collect
       (strip-tags (cdr i))))

(defun collect-all-adr (parameters)
  (%collect-all parameters +name-select-adr+))

(defun collect-all-hp (parameters)
  (%collect-all parameters +name-select-hp+))

(defun manage-waste-letter (infos errors)
  (with-standard-html-frame (stream
                             (_ "Hazardous waste form")
                             :errors errors
                             :infos  infos)
    (let ((html-template:*string-modifier* #'identity)
          (json-cer         (array-autocomplete-cer-code))
          (json-cer-id      (array-autocomplete-cer-code-id))
          (json-building    (array-autocomplete-building))
          (json-building-id (array-autocomplete-building-id))
          (json-labs        (array-autocomplete-laboratory))
          (json-labs-id     (array-autocomplete-laboratory-id))
          (json-phys        (array-autocomplete-waste-physical-state))
          (json-phys-id     (array-autocomplete-waste-physical-state-id)))
      (html-template:fill-and-print-template #p"waste-letter.tpl"
                                             (with-back-to-root
                                                 (with-path-prefix
                                                     :name-lb            (_ "Name")
                                                     :building-lb        (_ "Building")
                                                     :laboratory-lb      (_ "Laboratory")
                                                     :weight-lb          (_ "Weight (Kg)")
                                                     :description-lb     (_ "Description")
                                                     :waste-physical-state-lb
                                                     (_ "Physical state")
                                                     :name               +name-waste-user-name+
                                                     :cer-id             +name-waste-cer-id+
                                                     :building-id        +name-waste-building-id+
                                                     :phys-id            +name-waste-phys-id+
                                                     :lab-id             +name-waste-lab-id+
                                                     :weight             +name-waste-weight+
                                                     :description        +name-waste-description+
                                                     :json-cer           json-cer
                                                     :json-cer-id        json-cer-id
                                                     :json-building      json-building
                                                     :json-building-id   json-building-id
                                                     :json-laboratory    json-labs
                                                     :json-laboratory-id json-labs-id
                                                     :json-phys          json-phys
                                                     :json-phys-id       json-phys-id
                                                     :hp-list            (hp-list)
                                                     :adr-list           (adr-list)))
                                               :stream stream))))

(define-lab-route waste-letter ("/waste-letter/" :method :get)
  (with-authentication
      (manage-waste-letter nil nil)))

(defun letter-adr-codes (adrs)
  (if (= 1 (length adrs))
      (format nil "il codice ADR: ~a" (first adrs))
      (format nil
              "i seguenti codici ADR: ~a"
              (reduce #'(lambda (a b) (format nil "~a, ~a" a b))
                      adrs))))

(defun letter-hp-codes (hps)
  (if (= 1 (length hps))
      (format nil "il codice HP: ~a" (first hps))
      (format nil
              "i seguenti codici HP: ~a"
              (reduce #'(lambda (a b) (format nil "~a, ~a" a b))
                      hps))))

(defun write-letter (user lab-id address weight cer phys-state body adrs hps)
  (let ((actual-address (cond
                          ((scan "^[aeiouAEIOU]" address)
                           (format nil "l'~a" address))
                          ((scan "(^.+[aeAE] )|([aeAE]$)" address)
                           (format nil "la ~a" address))
                          (t
                           (format nil "il ~a" address)))))
    (format nil
            *waste-letter-body*
            user
            (lab-id->name lab-id)
            actual-address
            weight
            body
            cer
            (letter-adr-codes adrs)
            (letter-hp-codes hps)
            phys-state)))

(defun validate-letter-request (username lab-id building-id weight cer-id
                               phys-state-id body adrs hp-codes)
  (let* ((all-adrs   (%get-all-objects-from-dirty-ids 'db:adr-code adrs))
         (all-hp     (%get-all-objects-from-dirty-ids 'db:hp-waste-code hp-codes))
         (phys-state (get-column-from-id phys-state-id
                                         +pos-integer-re+
                                         'db:waste-physical-state
                                         #'db:explanation
                                         :default nil))
         (actual-cer (get-column-from-id cer-id
                                         +pos-integer-re+
                                         'db:cer-code
                                         #'db:code
                                         :default nil))
         (building   (get-column-from-id building-id
                                         +pos-integer-re+
                                         'db:building
                                         #'db:name
                                         :default nil))
         (errors     '()))
      (when (string-empty-p username)
       (push (_ "User not specified") errors))
      (when (string-empty-p lab-id)
       (push (_ "Laboratory not specified") errors))
      (when (string-empty-p building)
       (push (_ "Building not specified") errors))
      (when (string-empty-p weight)
       (push (_ "Weight not specified") errors))
      (when (string-empty-p actual-cer)
       (push (_ "CER not specified") errors))
      (when (string-empty-p phys-state)
       (push (_ "Physical state not specified") errors))
      (when (string-empty-p body)
       (push (_ "Letter's body empty") errors))
      (when (null all-adrs)
       (push (_ "ADR codes empty") errors))
      (when (null all-hp)
       (push (_ "HP codes empty") errors))
      errors))

(defun generate-letter (username lab-id building-id weight cer-id
                        phys-state-id body adrs hp-codes)
  (let ((errors (validate-letter-request username lab-id building-id weight cer-id
                                         phys-state-id body adrs hp-codes)))
    (if (null errors)
        (let* ((all-adrs   (%get-all-objects-from-dirty-ids 'db:adr-code adrs))
               (all-hp     (%get-all-objects-from-dirty-ids 'db:hp-waste-code hp-codes))
               (phys-state (get-column-from-id phys-state-id
                                               +pos-integer-re+
                                               'db:waste-physical-state
                                               #'db:explanation
                                               :default
                                               (_ "*warning: no valid physical state*")))
               (actual-cer (get-column-from-id cer-id
                                               +pos-integer-re+
                                               'db:cer-code
                                               #'db:code
                                               :default
                                               (_ "*Warning: no such cer code*")))
               (building   (get-column-from-id building-id
                                               +pos-integer-re+
                                               'db:building
                                               #'db:name
                                               :default
                                               (_ "*warning: no such building*")))
               (msg-text (write-letter username lab-id building weight actual-cer
                                       phys-state body
                                       (mapcar #'(lambda (a) (format nil "~a (classe ~a)"
                                                                     (db:uncode a)
                                                                     (db:code-class a)))
                                               all-adrs)
                                       (mapcar #'(lambda (a) (db:code a))
                                               all-hp)))
               (reminder-message (send-user-message (make-instance 'db:waste-message)
                                                    (get-session-user-id)
                                                    (get-session-user-id)
                                                    (_ "Waste production")
                                                    msg-text
                                                    :parent-message nil
                                                    :child-message nil
                                                    :cer-code-id cer-id
                                                    :building-id building-id
                                                    :weight      weight
                                                    :adr-ids     adrs
                                                    :hp-ids      hp-codes))
               ;; message for admin
               (admin-message (send-user-message (make-instance 'db:waste-message)
                                                 (get-session-user-id)
                                                 (admin-id)
                                                 (_ "Waste production")
                                                 msg-text
                                                 :parent-message nil
                                                 :child-message  nil
                                                 :echo-message   (db:id reminder-message)
                                                 :cer-code-id    cer-id
                                                 :building-id    building-id
                                                 :weight         weight
                                                 :adr-ids        adrs
                                                 :hp-ids         hp-codes)))
          (values (generate-waste-label (db:id admin-message) username lab-id building-id weight
                                        cer-id phys-state-id adrs hp-codes)
                  nil))
        (values errors t))))

(defun %get-label-pictogram (class objects)
  (remove-if #'null
             (map 'list #'(lambda (a)
                            (and (db:pictogram a)
                                 (single class
                                         :id (db:pictogram a))))
                  objects)))

(defun %get-all-objects-from-dirty-ids (class ids)
  (remove-if #'null
             (loop for i in (map 'list #'parse-integer
                                 (remove-if #'null
                                            (map 'list
                                                 #'(lambda (a)
                                                     (scan-to-strings +pos-integer-re+ a))
                                                 ids)))
                collect
                  (single class :id i))))

(defun %draw-pictograms-row (doc objs y)
  (let ((x-offset   0.0)
        (y-offset   0.0)
        (starting-y y)
        (pics       (remove-duplicates objs
                                       :key  #'db:pictogram-file
                                       :test #'string=)))
    (loop
       for pics-ct from 0 below (length pics)
       for x-ct = 0 then (+ x-ct 1) do ; assumig all images have the same sizes
         (let* ((pict-path (uiop:unix-namestring
                            (local-system-path (db:pictogram-file (elt pics pics-ct))))))
           (multiple-value-bind (image-handle w h) ; w and h are in mm
               (ps:open-image-file doc
                                   ps:+image-file-type-eps+
                                   pict-path
                                   "" 0)
             (let* ((scaling  (/ +pictogram-phys-size+ w))
                    (w-scaled (* w scaling))
                    (h-scaled (* h scaling)))
               (setf x-offset (* 1/20 w-scaled))
               (setf y-offset (* 1/20 h-scaled))
               (if (< (+ (* x-ct w-scaled) w-scaled x-offset)
                      (ps:width +a4-landscape-page-sizes+))
                   (ps:place-image doc
                                   image-handle
                                   (+ x-offset (* x-ct w-scaled))
                                   (- y h-scaled y-offset)
                                   scaling)
                   (if (> (- (- y h-scaled) h-scaled y-offset)
                          0)
                       (progn
                         (setf x-ct -1)
                         (decf y h-scaled)
                         (decf pics-ct))
                       (progn
                         (ps:end-page doc)
                         (ps:begin-page doc)
                         (setf x-ct -1)
                         (setf y    starting-y)
                         (decf pics-ct))))))))))

(defun generate-waste-label (id-message username lab-id building-id weight
                             cer-id phys-state-id adrs hp-codes)

  (let* ((all-adrs      (%get-all-objects-from-dirty-ids 'db:adr-code adrs))
         (adr-pictogram (%get-label-pictogram 'db:adr-pictogram all-adrs))
         (all-hp        (%get-all-objects-from-dirty-ids 'db:hp-waste-code hp-codes))
         (hp-pictogram  (%get-label-pictogram 'db:ghs-pictogram all-hp))
         (phys-state  (get-column-from-id phys-state-id
                                          +pos-integer-re+
                                          'db:waste-physical-state
                                          #'db:explanation
                                          :default
                                          (_ "*warning: no valid physical state*")))
         (cer-code (get-column-from-id cer-id
                                       +pos-integer-re+
                                       'db:cer-code
                                       #'db:code
                                       :default
                                       (_ "*Warning: no such cer code*")))
         (cer-desc (get-column-from-id cer-id
                                       +pos-integer-re+
                                       'db:cer-code
                                       #'db:explanation
                                       :default
                                       (_ "*Warning: no such cer code*")))
         (building   (get-column-from-id building-id
                                         +pos-integer-re+
                                         'db:building
                                         #'db:name
                                         :default
                                         (_ "*warning: no such building*"))))
    (with-a4-lanscape-ps-doc (doc)
      (let* ((font (default-font doc))
             (h1   20.0)
             (h2   10.0)
             (h3    5.0)
             (h4    3.0)
             (top-offset         (* 2 h3))
             (starting-text-area (- (ps:height +a4-landscape-page-sizes+)
                                    +header-image-export-height+))
             (y                  (- starting-text-area (+ h1 h2)))
             (box-h              (* 1/7 (ps:height +a4-landscape-page-sizes+)))
             (box-w              (- (ps:width +a4-landscape-page-sizes+)
                                    (* 2 +page-margin-left+))))
        (ps:setcolor doc ps:+color-type-fillstroke+ (cl-colors:rgb 0.0 0.0 0.0))
        (ps:setfont doc font 4.0)
        (ps:set-parameter   doc ps:+value-key-linebreak+ ps:+true+)
        (ps:set-parameter   doc ps:+parameter-key-imageencoding+ ps:+image-encoding-type-hex+)
        ;; header
        (with-save-restore (doc)
          (ps:setfont   doc font h3)
          (ps:translate doc
                        +header-image-export-width+
                        (- (ps:height +a4-landscape-page-sizes+) top-offset))
          (ps:show-xy   doc *letter-header-text* 0 0)
          (ps:translate doc 0 (- h3))
          (ps:setfont   doc font h4)
          (ps:show-xy   doc (format nil (_"ID request: ~a") id-message) 0 0)
          (ps:translate doc 0 (- h4))
          (ps:show-xy   doc (format nil "~a ~a ~a"
                                    username
                                    (lab-id->name lab-id)
                                    building)
                        0 0))
        (with-save-restore (doc)
          (if (find-if #'(lambda (a) (scan +adr-code-radioactive+ (db:code-class a))) all-adrs)
              (ps:draw-text-confined-in-box doc
                                            font
                                            (_ "WARNING: this adr code is associed with radioactive substance. Contact the techincal staff for assistance")
                                            +page-margin-left+
                                            (- y (* box-h 2))
                                            box-w
                                            (* box-h 2)
                                            :vertical-align    :bottom
                                            :horizontal-align  ps:+boxed-text-h-mode-justify+
                                            :maximum-font-size (* 2 h1))
              (progn
                (ps:draw-text-confined-in-box doc
                                              font
                                              cer-code
                                              +page-margin-left+
                                              y
                                              box-w
                                              box-h
                                              :horizontal-align  ps:+boxed-text-h-mode-justify+
                                              :maximum-font-size h1)
                (decf y box-h)
                (ps:draw-text-confined-in-box doc
                                              font
                                              cer-desc
                                              +page-margin-left+
                                              y
                                              box-w
                                              box-h
                                              :horizontal-align  ps:+boxed-text-h-mode-justify+
                                              :maximum-font-size h2)
                (decf y box-h)
                (ps:draw-text-confined-in-box doc
                                              font
                                              (format nil
                                                      (_ "HP codes: ~{~a ~}")
                                                      (mapcar #'db:code all-hp))
                                              +page-margin-left+ y
                                              box-w box-h
                                              :horizontal-align  ps:+boxed-text-h-mode-justify+
                                              :maximum-font-size h2)
                (decf y box-h)
                (ps:draw-text-confined-in-box doc
                                              font
                                              (format nil
                                                      (_ "ADR codes: ~{~a ~}")
                                                      (mapcar #'db:uncode all-adrs))
                                              +page-margin-left+ y
                                              box-w box-h
                                              :horizontal-align  ps:+boxed-text-h-mode-justify+
                                              :maximum-font-size h2)
                (decf y box-h)
                (with-save-restore (doc)
                  (ps:setfont doc font h3)
                  (ps:translate doc +page-margin-left+ y)
                  (ps:show-xy doc (format nil
                                          (_ "Weight: ~akg Physical state: ~a")
                                          weight phys-state)
                              0 0)))))
        (ps:end-page doc)
        (ps:begin-page doc)
        (%draw-pictograms-row doc hp-pictogram (ps:height +a4-landscape-page-sizes+))
        (ps:end-page doc)
        (ps:begin-page doc)
        (%draw-pictograms-row doc adr-pictogram (ps:height +a4-landscape-page-sizes+))))))

(define-lab-route write-waste-letter ("/write-waste-letter/" :method :get)
  (with-authentication
    (multiple-value-bind (results has-errors-p)
        (generate-letter (strip-tags (get-parameter +name-waste-user-name+))
                         (strip-tags (get-parameter +name-waste-lab-id+))
                         (strip-tags (get-parameter +name-waste-building-id+))
                         (strip-tags (get-parameter +name-waste-weight+))
                         (strip-tags (get-parameter +name-waste-cer-id+))
                         (strip-tags (get-parameter +name-waste-phys-id+))
                         (strip-tags (get-parameter +name-waste-description+))
                         (collect-all-adr (get-parameters*))
                         (collect-all-hp  (get-parameters*)))
      (if (not has-errors-p)
          (progn
            (setf (header-out :content-type) +mime-postscript+)
            results)
          (manage-waste-letter nil results)))))
