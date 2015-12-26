(defun make-model-detection ()
  (make "obj/model-detection.bin"
        '("primary-loader/models.asm"
          "primary-loader/model-detection.asm")
        "obj/model-detection.vice.txt"))

(defun make-dummy-loader ()
  (alet (downcase (symbol-name *tv*))
    (make (+ "obj/dummy-loader." ! ".prg")
          '("bender/vic-20/vic.asm"
            "primary-loader/zeropage.asm"
            "secondary-loader/loader.asm")
          (+ "obj/dummy-loader." ! ".prg.vice.txt"))))

(defun make-loader ()
  (alet (downcase (symbol-name *tv*))
    (make (+ "obj/loader." ! ".prg")
          '("bender/vic-20/vic.asm"
            "primary-loader/models.asm"
            "primary-loader/zeropage.asm"
            "bender/vic-20/basic-loader.asm"
            "primary-loader/main.asm"
            "secondary-loader/start.asm"
            "secondary-loader/loader.asm")
          (+ "obj/loader." ! ".prg.vice.txt"))))
