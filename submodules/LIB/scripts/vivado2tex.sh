#!/usr/bin/env bash
set -e

RES="vivado.tex" ;\
LUT=`grep -m1 -o 'LUTs\ *|\ * [0-9]*' $LOG | sed s/'| L'/L/g | sed s/\|/'\&'/g` ;\
FF=`grep -m1 -o 'Registers\ *|\ * [0-9]*' $LOG | sed s/'| L'/L/g | sed s/\|/'\&'/g` ;\
DSP=`grep -m1 -o 'DSPs\ *|\ * [0-9]*' $LOG | sed s/'| L'/L/g | sed s/\|/'\&'/g` ;\
BRAM=`grep -m1 -o 'Block RAM Tile \ *|\ * [0-9.]*' $LOG | sed s/'| L'/L/g | sed s/\|/'\&'/g | sed s/lock\ //g | sed s/Tile//g` ;\
PIN=`grep -m1 -o 'Bonded IOB\ *|\ * [0-9]*' $LOG | sed s/'| L'/L/g | sed s/\|/'\&'/g | sed s/'Bonded IOB'/PIN/g` ;\
echo "$LUT \\\\ \\hline"  > $RES ;\
echo "\rowcolor{iob-blue}"  >> $RES ;\
echo "$FF  \\\\  \\hline" >> $RES ;\
echo "$DSP \\\\ \\hline" >> $RES ;\
echo "\rowcolor{iob-blue}" >> $RES ;\
echo "$BRAM \\\\ \\hline" >> $RES ;\
#if [ "$PIN" ]; then \
#echo "$PIN \\\\ \\hline" >> $RES ;\
#fi \
