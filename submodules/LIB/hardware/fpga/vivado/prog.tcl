#extract cli args
set NAME [lindex $argv 0]

#place holder for future remote execution
set HOST localhost

# Connect to the Digilent Cable on localhost:3121

# Open the hardware manager in the IDE.
if { [catch {open_hw_manager} result] } {
   puts "ERROR: Can't connect to hardware manager.\n"
   exit result
}
# Connect to a hardware server running on the local machine
if { [catch {connect_hw_server -url $HOST:3121} result] } {
   puts "ERROR: Can't connect to hardware server.\n"
   exit result
}
# Open the target device on the hardware server
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/*]
if { [catch {open_hw_target} result] } {
   puts "ERROR: Can't open hardware target.\n"
   exit result
}

# Program and refresh the device

# Identify the AMD FPGA on the open hardware target
if { [catch {current_hw_device [lindex [get_hw_devices] 0]} result] } {
   puts "ERROR: Can't identify hardware device.\n"
   exit result
}
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]
# Associate the bitstream data programming file with the appropriate FPGA device
if { [catch {set_property PROGRAM.FILE "./$NAME.bit" [lindex [get_hw_devices] 0]} result] } {
   puts "ERROR: Can't associate bitstream to FPGA.\n"
   exit result
}
#set_property PROBES.FILE {C:/design.ltx} [lindex [get_hw_devices] 0]

# Program or download the programming file into the hardware device
if { [catch {program_hw_devices [lindex [get_hw_devices] 0]} result] } {
   puts "ERROR: Can't program FPGA.\n"
   exit result
}
# Refresh the hardware device to update the hardware probes
if { [catch {refresh_hw_device [lindex [get_hw_devices] 0]} result] } {
   puts "ERROR: Can't refresh hardware device.\n"
   exit result
}

# Close the hardware target
if { [catch {close_hw_target} result] } {
   puts "ERROR: Can't close hardware target.\n"
   exit result
}

# Connect to a hardware server running on the local machine
if { [catch {disconnect_hw_server} result] } {
   puts "ERROR: Can't disconnect to hardware server.\n"
   exit result
}

# Open the hardware manager in the IDE.
if { [catch {close_hw_manager} result] } {
   puts "ERROR: Can't close hardware manager.\n"
   exit result
}
