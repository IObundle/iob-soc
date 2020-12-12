#!/bin/bash
source /opt/ic_tools/init/init-xcelium1903-hf013
xmvlog $CFLAGS $VSRC
xmelab $EFLAGS worklib.system_tb:module
xmsim  $SFLAGS worklib.system_tb:module 
