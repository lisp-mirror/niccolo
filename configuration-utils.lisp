;; Configuration utils
;; Copyright (C) 2016  cage

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(in-package :configuration-utils)

(defmacro define-conffile-reader ((name template-minimal) &rest tags)
  (alexandria:with-gensyms (results xmlslist path stream)
    (let ((funname (alexandria:format-symbol t "READ-~a-CONFIG" name)))
      `(defun ,funname (,path)
	 (handler-bind ((file-error
			 #'(lambda (e)
			     (progn
			       (with-open-file (,stream (file-error-pathname e)
							:direction :output
							:if-does-not-exist :create)
				 (format ,stream (xmls:toxml '(,template-minimal nil)))
				 (finish-output ,stream))
			       (,funname ,path)
			       (return-from ,funname nil)))))
	   (with-open-file (,stream ,path :direction :input :if-does-not-exist :error)
	     (if (> (file-length ,stream) 0)
		 (progn
		   (let ((,results (make-hash-table :test #'equalp))
			 (,xmlslist (xmls:parse ,stream)))
		     (setf ,xmlslist (xmls:xmlrep-children ,xmlslist))
		     ,@(loop for i in tags collect
			    `(progn
			       (setf (gethash ,(string i) ,results)
				     (xml-utils:with-tagmatch (,(string i) (first ,xmlslist))
				       (first (xmls:xmlrep-children (first ,xmlslist)))))
			       (setf ,xmlslist (rest ,xmlslist))))
		     ,results))
		 nil)))))))


(defmacro define-conffile-writer (name root tags)
  (alexandria:with-gensyms (path values stream)
    (let ((funname (alexandria:format-symbol t "WRITE-~a-CONFIG" name)))
      `(defun ,funname (,path ,values)
	 (with-open-file (,stream ,path :direction :output :if-does-not-exist :create
				  :if-exists :supersede)
	   (format ,stream (xmls:toxml
			    (xmls:make-xmlrep ,root :attribs nil
					      :children (loop
							   for tag in (quote ,tags)
							   for value in ,values collect
							     (xmls:make-xmlrep (string-downcase tag) :attribs nil
									       :children (list value))))
			    :indent t)))))))

(defun parse-simple-config (file)
  (with-open-file (stream file)
    (let ((tree (xmls:parse stream)))
      (do* ((i 0 (1+ i))
            (key (get-leaf (("prop" "record" "key")   (i 0) tree))
                 (get-leaf (("prop" "record" "key")   (i 0) tree)))
            (val (get-leaf (("prop" "record" "value") (i 1) tree))
                 (get-leaf (("prop" "record" "value") (i 1) tree)))
            (res (list (cons key val)) (if key
                                           (append res (list (cons key val)))
                                           res)))
           ((not key) res)))))

(defun get-config-val (key config &key (test #'string-equal))
  (cdr (assoc key config :test test)))
