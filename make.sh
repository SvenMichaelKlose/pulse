#!/bin/sh

rm -rf obj  # Don't uncomment this even if you have untreated OCD.
mkdir -p obj
mkdir -p compiled
sbcl --noinform --core bender/bender make.lisp
