#!usr/bin/env bash
./flow.tcl -interactive 
prep -design system config file /system/config.tcl -tag soc -overwrite
run_yosys -p "read_verilog -I/$(OPENLANE_DESIGNS)/system/inc"
run_sta
init_floorplan
add_macro_placement ram 5.59000 168.23 N
manual_macro_placement f
place_io
tap_decap_or
gen_pdn
write_powered_verilog
set_netlist $::env(lvs_result_file_tag).powered.v
global_placement_or
detailed_placement_or
run_cts
global_routing
detailed_routing
run_magic
run_magic_drc
puts $::env(CURRENT_NETLIST)
run_magic_spice_export
run_lvs
run_antenna_check
calc_total_runtime
generate_final_summary_report
