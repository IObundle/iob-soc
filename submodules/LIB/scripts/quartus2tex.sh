#!/usr/bin/env bash
set -e

RES="quartus.tex" ;\
ALM=`grep ALM $LOG |grep -o '[0-9,]* \/' | sed s/'\/'//g` ;\
FF=`grep registers $LOG |grep -o '[0-9]*' | sed s/'\/'//g` ;\
DSP=`grep DSP $LOG |grep -o '[0-9]* \/' | sed s/'\/'//g` ;\
BRAM=`grep RAM $LOG |grep -o '[0-9]* \/' | sed s/'\/'//g` ;\
#BRAMb=`grep 'block memory' $LOG |grep -o '[0-9,]* \/' | sed s/'\/'//g` ;\
PIN=`grep pin $LOG |grep -o '[0-9]* \/' | sed s/'\/'//g`;\
echo "ALM & $ALM \\\\ \\hline" > $RES ;\
echo "\rowcolor{iob-blue}"  >> $RES ;\
echo "FF & $FF  \\\\  \\hline"  >> $RES ;\
echo "DSP & $DSP \\\\ \\hline"  >> $RES ;\
echo "\rowcolor{iob-blue}"  >> $RES ;\
echo "BRAM blocks & $BRAM \\\\ \\hline"  >> $RES ;\
#echo "BRAM bits & $BRAMb \\\\ \\hline"  >> $RES ;\
echo "\rowcolor{iob-blue}"  >> $RES ;\
#if [ "$PIN" ]; then \
#echo "PIN & $PIN \\\\ \\hline"  >> $RES ;\
#fi \
