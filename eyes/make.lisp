(defun make-eyes ()
  (with-temporaries (*imported-labels* nil
                     *tape-loader-start-returning?* t)
    (alet (downcase (symbol-name *tv*))
      (make (+ "obj/eyes." ! ".prg")
            '("bender/vic-20/vic.asm"
              "primary-loader/models.asm"
              "flight/zeropage.asm"
              "eyes/start.asm"
              "secondary-loader/start.asm"
              "eyes/main.asm"
              "game/high-segment.asm"
              "expanded/print.asm")
            (+ "obj/eyes." ! ".prg.vice.txt")))))
;      (exomize (+ "obj/eyes." ! ".prg")
;               (+ "obj/eyes.crunched." ! ".prg")
;               "1002" "20"
;               :path *exomizer*))))
