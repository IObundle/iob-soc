#!/bin/bash
#source /opt/ic_tools/init/init-rc14_25_hf000
#source /opt/ic_tools/init/init-edi14_26_hf000
ncvlog $CFLAGS -incdir $INCLUDE_DIR $SRC -define SIM
ncelab $EFLAGS worklib.system_tb:module
ncsim  $SFLAGS worklib.system_tb:module
