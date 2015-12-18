(defun make-eyes ()
  (with-temporaries (*imported-labels* nil
                     *tape-loader-start-returning?* t)
    (alet (downcase (symbol-name *tv*))
      (make (+ "obj/intro." ! ".prg")
            '("bender/vic-20/vic.asm"
              "primary-loader/models.asm"
              "radio/zeropage.asm"
              "eyes/start.asm"
              "secondary-loader/start.asm"
              "eyes/main.asm"
              "game/high-segment.asm"
              "expanded/print.asm")
            (+ "obj/intro." ! ".prg.vice.txt"))
      (exomize (+ "obj/intro." ! ".prg")
               (+ "obj/intro.crunched." ! ".prg")
               "1002" "20"))))
