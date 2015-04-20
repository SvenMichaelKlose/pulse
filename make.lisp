(load "files.lisp")
(load "story.lisp")

(defvar *loader-start* nil)

(apply #'assemble-files "pulse.prg" (. "basic-loader.asm" +pulse-files+))
(make-vice-commands "vice.txt")
(quit)
