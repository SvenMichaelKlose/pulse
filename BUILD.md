# How to build Pulse

You will need sbcl, the tré programming language and the 6502-CPU
development suite Bender.  Preferably on Linux.

tré: https://github.com/svenmichaelklose/tre
Bender: https://github.com/svenmichaelklose/bender

They are all pretty easy to install on Linux Mint.  Symbolically link
the tré environment into the Bender directory after installing it.  Then
make Bender and link its directory into pulse's one.  It then should be ready
to be built with the shell script 'make.sh', giving you the desired program
file 'pulse.prg'.
