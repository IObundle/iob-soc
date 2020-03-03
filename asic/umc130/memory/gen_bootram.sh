#!/usr/bin/bash
source 	/opt/ic_tools/init/init-memaker-20100111-130LL

PYTHON_DIR=../../../../software/python
BOOT_DIR=../../../../software/bootloader

cp $BOOT_DIR/system.h .
$PYTHON_DIR/get_memsize.py BOOTRAM_ADDR_W > BOOTRAM_ADDR_W
BOOTRAM_LEN=`cat BOOTRAM_ADDR_W`
memaker -s fsc0l_d -type sh -words $BOOTRAM_LEN -bits 8 -bytes 4 -mux 1 -ds -lib -ver -lef
