#!/bin/bash

COMPILE_USER=$1
COMPILE_SERVER=$2
HW_DIR=$3
INTEL=$4
XILINX=$5


#altera
if [ $INTEL = 1 ]; then \
LOG="top_system.fit.summary";\
RES="alt_results.tex";\
scp $COMPILE_USER@$COMPILE_SERVER:$HW_DIR/fpga/CYCLONEV-GT-DK/output_files/$LOG . ;\
ALM=`grep ALM $LOG |grep -o '[0-9]*,\?[0-9]* \/' | sed s/'\/'//g`;\
FF=`grep registers $LOG |grep -o '[0-9]*' | sed s/'\/'//g`;\
DSP=`grep DSP $LOG |grep -o '[0-9]* \/' | sed s/'\/'//g`;\
BRAM=`grep RAM $LOG |grep -o '[0-9]* \/' | sed s/'\/'//g`;\
BRAMb=`grep 'block memory' $LOG |grep -o '[0-9]*,[0-9]* \/' | sed s/'\/'//g`;\
PIN=`grep pin $LOG |grep -o '[0-9]* \/' | sed s/'\/'//g`;\
echo "ALM & $ALM \\\\ \\hline" > $RES;\
echo "\rowcolor{iob-blue}"  >> $RES;\
echo "FF & $FF  \\\\  \\hline"  >> $RES;\
echo "DSP & $DSP \\\\ \\hline"  >> $RES;\
echo "\rowcolor{iob-blue}"  >> $RES;\
echo "BRAM blocks & $BRAM \\\\ \\hline"  >> $RES;\
echo "BRAM bits & $BRAMb \\\\ \\hline"  >> $RES;\
echo "\rowcolor{iob-blue}"  >> $RES;\
echo "PIN & $PIN \\\\ \\hline"  >> $RES;\
fi


#xilinx
if [ $XILINX = 1 ]; then \
LOG="vivado.log" ;\
RES="xil_results.tex" ;\
scp $COMPILE_USER@$COMPILE_SERVER:$HW_DIR/fpga/AES-KU040-DB-G/$LOG . ;\
LUT=`grep -o 'LUTs\ *|\ * [0-9]*' vivado.log | sed s/'| L'/L/g | sed s/\|/'\&'/g` ;\
FF=`grep -o 'Registers\ *|\ * [0-9]*' vivado.log | sed s/'| L'/L/g | sed s/\|/'\&'/g` ;\
DSP=`grep -o 'DSPs\ *|\ * [0-9]*' vivado.log | sed s/'| L'/L/g | sed s/\|/'\&'/g` ;\
BRAM=`grep -o 'Block RAM Tile \ *|\ * [0-9]*' vivado.log | sed s/'| L'/L/g | sed s/\|/'\&'/g | sed s/lock\ //g | sed s/Tile//g` ;\
PIN=`grep -o 'Bonded IOB\ *|\ * [0-9]*' vivado.log | sed s/'| L'/L/g | sed s/\|/'\&'/g | sed s/'Bonded IOB'/PIN/g` ;\
echo "$LUT \\\\ \\hline"  > $RES ;\
echo "\rowcolor{iob-blue}"  >> $RES ;\
echo "$FF  \\\\  \\hline" >> $RES ;\
echo "$DSP \\\\ \\hline" >> $RES ;\
echo "\rowcolor{iob-blue}" >> $RES ;\
echo "$BRAM \\\\ \\hline" >> $RES ;\
echo "$PIN \\\\ \\hline" >> $RES ; fi
