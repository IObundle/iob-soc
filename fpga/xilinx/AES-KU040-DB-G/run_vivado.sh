source /opt/Xilinx/Vivado/settings64.sh
echo $1
vivado -nojournal -log vivado.log -mode batch -source synth_system.tcl -tclargs $1
