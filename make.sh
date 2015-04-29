#!/bin/sh

rm -rf obj; mkdir obj
rm -rf compiled; mkdir compiled
tre configure.lisp
sh obj/_make.sh
#tre make-video.lisp
sbcl --noinform --core bender/bender make.lisp
zip compiled/ohne_dich_pal.zip compiled/ohne_dich_pal.tap
zip compiled/ohne_dich_ntsc.zip compiled/ohne_dich_ntsc.tap
zip compiled/mario_pal.zip compiled/mario_pal.tap
zip compiled/mario_ntsc.zip compiled/mario_ntsc.tap
zip compiled/ohne_dich_pal.wav.zip compiled/ohne_dich_pal.tape.wav
zip compiled/ohne_dich_ntsc.wav.zip compiled/ohne_dich_ntsc.tape.wav
zip compiled/mario_pal.wav.zip compiled/mario_pal.tape.wav
zip compiled/mario_ntsc.wav.zip compiled/mario_ntsc.tape.wav
