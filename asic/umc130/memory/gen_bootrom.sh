#!/usr/bin/bash
source 	/opt/ic_tools/init/init-memaker-20100111-130LL

PYTHON_DIR=../../../../software/python
BOOT_DIR=../../../../software/bootloader

cp $BOOT_DIR/system.h .
$PYTHON_DIR/get_memsize.py BOOTROM_ADDR_W > BOOTROM_ADDR_W
BOOTROM_LEN=`cat BOOTROM_ADDR_W`
memaker -s fsc0l_d -type sp -words $BOOTROM_LEN -bits 32 -mux 1 -rformat hex -romcode $BOOT_DIR/boot.hex -ds -lib -ver -lef
