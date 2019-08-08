#!/bin/bash
#source /opt/ic_tools/init/init-rc14_25_hf000
source /opt/ic_tools/init/init-incisive1510-hf002
#source /opt/ic_tools/init/init-edi14_26_hf000

ncvlog $CFLAGS -incdir $INCLUDE_DIR $SRC -define ALTERA -define SIM
ncelab $EFLAGS worklib.system_tb:module
ncsim  $SFLAGS worklib.system_tb:module
