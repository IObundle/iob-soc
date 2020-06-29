#!/usr/bin/bash
export XILINXPATH=/opt/Xilinx
export LM_LICENSE_FILE=$XILINXPATH/Xilinx.lic
source /opt/Xilinx/Vivado/settings64.sh
vivado -nojournal -log $@.log -mode batch -source ld-hw.tcl
