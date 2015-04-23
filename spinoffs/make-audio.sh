#!/bin/sh

mplayer -vo null -vc null -ao pcm:fast:file=../obj/ohne_dich.wav ohne_dich.mp3
sox ../obj/ohne_dich.wav ../obj/ohne_dich_filtered.wav bass -72 lowpass 2k compand 0.3,1 6:-70,-60,-20 -3 -90 0.2 gain 4
sox ../obj/ohne_dich_filtered.wav -c 1 -b 8 -r 4777 -u -D ../obj/ohne_dich_4bit.wav
