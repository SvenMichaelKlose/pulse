#!/bin/sh

rm -rf obj; mkdir obj
rm -rf compiled; mkdir compiled
tre configure.lisp
sh obj/_make.sh
sbcl --noinform --core bender/bender make.lisp
zip compiled/ohne_dich_pal.zip compiled/ohne_dich_pal.tap
zip compiled/ohne_dich_ntsc.zip compiled/ohne_dich_ntsc.tap
zip compiled/mario_pal.zip compiled/mario_pal.tap
zip compiled/mario_ntsc.zip compiled/mario_ntsc.tap
