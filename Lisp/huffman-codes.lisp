; ************************
; ************************
; ************************

; GOLUB OLEKSANDRA 856706
; ARESTA SIMONE 875192

; ************************
; ************************
; ************************


; ************************ HE-DECODE ************************

(defun he-decode (bits huffman-tree)
 (labels ((decode-1 (bits current-branch)
		  (unless (null bits)
		   (let ((next-branch (choose-branch (first bits) current-branch)))
				(if (leaf-p next-branch)
					(cons (leaf-symbol next-branch)
						  (decode-1 (rest bits) huffman-tree))
					(decode-1 (rest bits) next-branch))
			)
		   )
	      ))(decode-1 bits huffman-tree))
)

(defun choose-branch (bit branch)
 (cond ((= 0 bit) (node-left branch))
	   ((= 1 bit) (node-right branch))
       (t (error "Bad bit ~D." bit))))

(defun node-left (branch)
 (if (not (atom branch))
	 (car (cdr (cdr branch)))))

(defun node-right (branch)
 (if (not (atom branch))
     (car (cdr (cdr (cdr branch)))))) 
	  
(defun leaf-p (branch)
 (cond ((null (cdr (cdr branch))) t) 
	   (t nil)))

(defun leaf-symbol (branch)
 (car branch))


; ************************ HE-ENCODE ************************

(defun he-encode (message huffman-tree)
 (labels ((encode-1 (message current-branch)
    (unless (null message)
     (let ((next-branch (choose-next-branch (first message) current-branch)))
          (if (leaf-p next-branch)
			  (if (equal (node-left current-branch) next-branch)
                  (cons 0 (encode-1 (rest message) huffman-tree))
                  (cons 1 (encode-1 (rest message) huffman-tree)))
              (if (equal (node-left current-branch) next-branch)
                  (cons 0 (encode-1  message (if (control (first message) 
						  (car next-branch)) next-branch huffman-tree)))
                  (cons 1 (encode-1  message (if (control (first message) 
						 ( car next-branch)) next-branch huffman-tree)))
			  )
		  )
	 )
	)
		 ))(encode-1 message huffman-tree)
 )
)

(defun choose-next-branch (my-symbol branch)
 (cond ((control my-symbol (car (node-left branch))) (node-left branch))
       ((control my-symbol (car (node-right branch))) (node-right branch))
       (t (error "Bad symbol ~D." my-symbol))))  
  
(defun control (my-symbol branch)
 (if (null branch) nil
     (or (equal (if (atom branch) branch (car branch)) my-symbol) 
	 (if (not (atom branch)) (control my-symbol (rest branch))))
 )
)  


; ************************ HE-ENCODE-FILE ************************

(defun he-encode-file (filename huffman-tree)
 (he-encode (control-input (flatten 
            (mapcar #'line-as-list (read-file-as-lines filename)))) 
			 huffman-tree) 
)

(defun flatten (lista)
 (let ((r nil))
      (mapcar #'(lambda (x)
                 (cond ((atom x) (push x r))
                       (t (setq r (append (reverse (flatten x)) r))))) lista) 
		 (reverse r)
 )
) 
		
(defun read-file-as-lines (filename)
 (with-open-file (in filename)
    (loop for line = (read-line in nil nil)
     while line
     collect line)
 )
)

(defun line-as-list (line)
 (read-from-string (concatenate 'string "(" line ")"))
)

(defun explode (atomo)
 (coerce (string atomo) 'list)
)

(defun control-input-start (lista)
 (cond ((null lista) nil)
 (t (cons (explode (car lista)) (control-input-start (cdr lista)))))
)

(defun control-input-end (lista)
 (flatten (mapcar (lambda (c) (intern (string c))) lista))
)
 
(defun control-input (lista)
 (control-input-end (flatten (control-input-start lista)))
)

; ************************ HE-GENERATE-HUFFMAN-TREE ************************

(defun he-generate-huffman-tree (symbols-n-weights)
 (if (< (length symbols-n-weights) 2)
     (error "Bad symbols-n-weights ~D." symbols-n-weights)
     (generate-tree symbols-n-weights)))

(defun generate-tree (symbols-n-weights)
 (if (null (cdr symbols-n-weights))
     (car symbols-n-weights)
	 (let ((lista (stable-sort symbols-n-weights 'funz)))
          (generate-tree  
           (append (list (cons (flatten-tree (list (car (car lista)) 
					                               (car (car (cdr lista)))))
							   (cons (+ (car (cdr (car lista)))
									    (car (cdr (car (cdr lista))))) 
									 (cons (car lista) 
										   (list (car (cdr lista))))
							   )
						 )
					)(cdr (cdr lista))
		    )
		   )
	 )
 )
)
  				 		
(defun funz (lista1 lista2)
 (if (<  (car (cdr lista1)) (car (cdr lista2))) 
	 t nil))
	   
(defun flatten-tree (lista)
 (cond ((null lista) lista)
       ((atom lista) (list lista))
       (t (append (flatten-tree (first lista)) (flatten-tree (rest lista))))
 )
)  

; ********************** HE-GENERATE-SYMBOL-BITS-TABLE **********************

(defun he-generate-symbol-bits-table (huffman-tree)
 (labels ((generate-symbol-bits-table-1 (list)
          (if (not (null list))
             (cons (list (car list) (he-encode (list (car list)) huffman-tree)) 
				   (generate-symbol-bits-table-1 (rest list)))
                    nil)
	     ))
       (generate-symbol-bits-table-1 (car huffman-tree))
 )
) 

; ********************** HE-PRINT-HUFFMAN-TREE **********************

(defun he-print-huffman-tree (huffman-tree &optional (indent-level 0))
 (cond ((null huffman-tree) nil)
	   (t (princ huffman-tree))) 
)
