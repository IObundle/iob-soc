# Connect to the Digilent Cable on localhost:3121

open_hw
connect_hw_server -url localhost:3121
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210251A99906]
open_hw_target

# Program and Refresh the XC7K325T Device

current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE {./synth_system.bit} [lindex [get_hw_devices] 0]
#set_property PROBES.FILE {C:/design.ltx} [lindex [get_hw_devices] 0]
 
program_hw_devices [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices] 0]
