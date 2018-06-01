;; xml-utils
;; Copyright (C) 2016  cage

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package xml-utils)

(define-condition xml-no-matching-tag ()
  ((text
    :initarg :text
    :reader text))
  (:report (lambda (condition stream)
            (format stream "~a" (text condition)))))

(define-condition xml-no-such-attribute ()
  ((text
    :initarg :text
    :reader text))
  (:report (lambda (condition stream)
             (format stream "~a" (text condition)))))

(defmacro with-tagmatch ((tag node) &body body)
  `(if (xmls:xmlrep-tagmatch ,tag ,node)
       (progn ,@body)
       (error 'xml-no-matching-tag
              :text (format nil
                            "Error in parsing scheme database, expecting ~s got ~s instead." ,tag
                            (xmls:xmlrep-tag ,node)))))

(defmacro with-tagmatch-if-else ((tag node else) &body body-then)
  `(if (and ,node
            (xmls:xmlrep-tagmatch ,tag ,node))
       (progn ,@body-then)
       (progn ,@else)))

(defmacro with-attribute ((att node) &body body)
  (alexandria:with-gensyms (value)
    `(let  ((,value (xmls:xmlrep-attrib-value ,att ,node nil)))
       (if (string/= ,value nil)
           (progn
             ,@body
             ,value)
           (error 'xml-no-such-attribute
                  :text (format nil
                                "Error in parsing scheme database, no attribute ~s found in node ~a."
                                ,att
                                (quote ,node)))))))

(defun get-list-tags-value (xmls tag &optional (res-values '()))
  (with-tagmatch-if-else (tag (first xmls) ((list xmls (alexandria:flatten (reverse res-values)))))
    (get-list-tags-value (rest xmls) tag
                         (push (xmls:xmlrep-children (first xmls)) res-values))))


(defmacro get-leaf ((tags path node) &body body)
  (once-only ((the-node node))
    (let ((child-pos (first path))
          (rest-path (append (rest path)
                             (list 0)))) ;; the text node
    (if tags
        `(with-tagmatch (,(first tags) ,the-node)
           (handler-case
               (get-leaf (,(rest tags)
                           ,rest-path
                           (elt (xmlrep-children ,the-node) ,child-pos)))
             (error () nil)))
        `(progn ,@body
                ,the-node)))))
