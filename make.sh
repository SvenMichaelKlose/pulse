#!/bin/sh

rm -rf obj; mkdir obj
rm -rf compiled; mkdir compiled
sbcl --noinform --core bender/bender make.lisp
