(defun make-message ()
  (alet (downcase (symbol-name *tv*))
    (with-temporary *imported-labels* nil
      (make (+ "obj/message." ! ".prg")
            '("bender/vic-20/vic.asm"
              "primary-loader/zeropage.asm"
              "message/main.asm"
              "game/random.asm"
              "game/high-segment.asm"
              "secondary-loader/start.asm")
            (+ "obj/message." ! ".prg.vice.txt")))))
