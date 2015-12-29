(let v nil
  (defun reupdate-dithering ()
    (= v 0))
  (defun dithered-sample (x)
    (= v (+ v x)))
  (defun update-dithering-error (x)
    (= v (- v x))))
