#!/usr/bin/bash
source 	/opt/ic_tools/init/init-memaker-20100111-130LL

PYTHON_DIR=../../../../software/python
BOOT_DIR=../../../../software/bootloader

cp $BOOT_DIR/system.h .
$PYTHON_DIR/get_memsize.py MAINRAM_ADDR_W > MAINRAM_ADDR_W
MAINRAM_LEN=`cat MAINRAM_ADDR_W`
memaker -s fsc0l_d -type sh -words $MAINRAM_LEN -bits 8 -bytes 4 -mux 4 -ds -lib -ver
