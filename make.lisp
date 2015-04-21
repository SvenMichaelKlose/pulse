(load "files.lisp")
(load "story.lisp")

(apply #'assemble-files
       "pulse.prg"
       (+ (@ [+ "bender/vic-20/" _]
             '("basic-loader.asm"
               "vic.asm"))
          (@ [+ "game/" _] +pulse-files+)))
(make-vice-commands "vice.txt")
(quit)
