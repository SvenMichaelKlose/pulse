#!/bin/sh

rm -rf obj
mkdir obj
tre configure.lisp
sh obj/_make.sh
sbcl --noinform --core bender/bender make.lisp
