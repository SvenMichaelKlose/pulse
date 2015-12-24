(defvar *message-start* nil)

(defun make-message ()
  (alet (downcase (symbol-name *tv*))
    (with-temporaries (*imported-labels* nil
                       *tape-loader-start-returning?* t)
      (make (+ "obj/message." ! ".prg")
            '("bender/vic-20/vic.asm"
              "primary-loader/zeropage.asm"
              "primary-loader/models.asm"
              "message/main.asm"
              "game/random.asm"
              "game/high-segment.asm"
              "secondary-loader/start.asm")
            (+ "obj/message." ! ".prg.vice.txt"))
      (= *message-start* (get-label 'intro_message)))))
