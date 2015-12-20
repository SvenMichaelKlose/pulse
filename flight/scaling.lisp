(defun make-scaling-tables (num original-size)
  (maptimes [alet (- num _)
              (+ (maptimes [integer (* _ (/ original-size !))] !)
                 (list 255))]
            num))

(defun make-scaling-tables-and-addrs (label num original-size)
  (with (tabs  (make-scaling-tables num original-size)
         addr  (get-label label :required? nil))
    (mapcar #'((a b)
                (let dist-to-page-boundary (- 256 (low addr))
                  (aprog1 (? (> b dist-to-page-boundary)
                             (. (+ (maptimes [identity 0] dist-to-page-boundary)
                                   a)
                                (+ addr dist-to-page-boundary))
                             (. a addr))
                    (+! addr (length !.)))))
            tabs (@ #'length tabs))))

(defun make-scaling-offsets (label num original-size)
  (apply #'+ (carlist (make-scaling-tables-and-addrs label num original-size))))

(defun make-scaling-addresses-low (label num original-size)
  (@ #'low (cdrlist (make-scaling-tables-and-addrs label num original-size))))

(defun make-scaling-addresses-high (label num original-size)
  (@ #'high (cdrlist (make-scaling-tables-and-addrs label num original-size))))
