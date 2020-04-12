source /opt/Xilinx/Vivado/settings64.sh
vivado -nojournal -log $@.log -mode batch -source ld-hw.tcl
