(load "files.lisp")
(load "story.lisp")

(apply #'assemble-files
       "pulse.prg"
       (@ [+ "game/" _] (. "basic-loader.asm" +pulse-files+)))
(make-vice-commands "vice.txt")
(quit)
