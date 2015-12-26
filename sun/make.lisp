(defvar *sun-start* nil)

(defun max-screen-columns ()
  (? (eq *tv* :pal)
     31
     (integer (+ 22 (elt (vic-defaults *tv*) 0)))))

(defun max-screen-rows (cols)
  (alet (integer (+ 23 (/ (elt (vic-defaults *tv*) 1) 4)))
    (let s (* cols !)
      (? (< 1024 s)
         (- ! (integer (/ (- s 1024) cols)))
         !))))

(defun large-sine ()
  (let steps 256
    (with-queue q
      (do ((i 0 (+ i (/ 360 steps))))
          ((<= (/ 360 4) i) (queue-list q))
        (enqueue q (integer (* 128 (degree-sin i))))))))

(defun make-sun ()
  (format t "Screen dimensions: ~Ax~A chars.~%"
            (max-screen-columns)
            (max-screen-rows (max-screen-columns)))
  (alet (downcase (symbol-name *tv*))
    (with-temporary *imported-labels* nil
      (make (+ "obj/sun." ! ".prg")
            '("bender/vic-20/vic.asm"
              "primary-loader/zeropage.asm"
              "sun/zeropage.asm"
              "sun/charset.asm"
              "sun/main.asm"
              "sun/screen.asm"
              "sun/math.asm"
              "sun/multiply.asm"
              "sun/sine.asm"
              "sun/draw-pixel.asm"
              "sun/draw-circle.asm"
              "game/random.asm"
              "game/high-segment.asm"
              "secondary-loader/start.asm")
            (+ "obj/sun." ! ".prg.vice.txt"))
      (= *sun-start* (get-label 'sun)))))
