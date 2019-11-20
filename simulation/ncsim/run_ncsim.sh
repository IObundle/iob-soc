#!/bin/bash
source /opt/ic_tools/init/init-incisive1510-hf002
ncvlog $CFLAGS -incdir $INCLUDE_DIR $SRC -define SIM
ncelab $EFLAGS worklib.system_tb:module
ncsim  $SFLAGS worklib.system_tb:module
