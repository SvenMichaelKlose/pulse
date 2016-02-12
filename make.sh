#!/bin/sh

rm -rf obj
mkdir -p obj
mkdir -p compiled
sbcl --noinform --core bender/bender make.lisp
