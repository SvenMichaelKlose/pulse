(defun make-scaling-tables (num)
  (maptimes [alet (- num _)
              (+ (maptimes [integer (* _ (/ num !))] !)
                 (list 255))]
            num))

(defun make-scaling-tables-and-addrs (num)
  (with (tabs  (make-scaling-tables num)
         addr  0)
    (mapcar #'((a b)
                (let dist-to-page-boundary (- 256 (low addr))
                  (aprog1 (? (> b dist-to-page-boundary)
                             (. (+ (maptimes [identity 0] dist-to-page-boundary)
                                   a)
                                (+ addr dist-to-page-boundary))
                             (. a addr))
                    (+! addr (length !.)))))
            tabs (@ #'length tabs))))

(defun make-scaling-offsets (num)
  (apply #'+ (carlist (make-scaling-tables-and-addrs num))))

(defun make-scaling-addresses-low (num)
  (@ #'low (cdrlist (make-scaling-tables-and-addrs num))))

(defun make-scaling-addresses-high (num)
  (@ #'high (cdrlist (make-scaling-tables-and-addrs num))))
