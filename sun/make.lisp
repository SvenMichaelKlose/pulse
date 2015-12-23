(defvar *sun-start* nil)

(defun max-screen-columns ()
  (integer (+ 22 (elt (vic-defaults *tv*) 0))))

(defun max-screen-rows ()
  (alet (integer (+ 23 (/ (elt (vic-defaults *tv*) 1) 4)))
    (let s (* (max-screen-columns) !)
      (? (< 1024 s)
         (- ! (integer (/ (- s 1024) (max-screen-columns))))
         !))))

(defun large-sine ()
  (let steps 256
    (with-queue q
      (do ((i 0 (+ i (/ 360 steps))))
          ((<= (/ 360 4) i) (queue-list q))
        (enqueue q (integer (* 128 (degree-sin i))))))))

(defun make-sun ()
  (alet (downcase (symbol-name *tv*))
    (with-temporary *imported-labels* nil
      (make (+ "obj/sun." ! ".prg")
            '("bender/vic-20/vic.asm"
              "primary-loader/zeropage.asm"
              "sun/main.asm"
              "sun/screen.asm"
              "sun/char.asm"
              "sun/blitter.asm"
              "sun/math.asm"
              "sun/multiply.asm"
              "sun/sine.asm"
              "sun/pixel.asm"
              "sun/draw-circle.asm"
              "game/random.asm"
              "game/high-segment.asm"
              "secondary-loader/start.asm")
            (+ "obj/sun." ! ".prg.vice.txt"))
      (= *sun-start* (get-label 'sun)))))
