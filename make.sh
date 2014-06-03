#!/bin/sh

xa -M includes.asm -o pulse.prg -l labels.lst
xa -M includes.asm -DTAPE_RELEASE=1 -o pulse.bin
xa -M includes3k.asm -o pulse3k.prg -l labels3k.lst
