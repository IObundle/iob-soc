#Interactive commands

package require openlane
prep -design system config file /system/config.tcl -tag soc -overwrite
run_yosys #read_verilog '-Idesigns/system/inc'
run_sta
#testing to this point right now. Will uncomment and test these step wise -please do not remove -
#init_floorplan
#add_macro_placement ram 5.59000 168.23 N
#manual_macro_placement f
#place_io
#tap_decap_or
#gen_pdn
#write_powered_verilog
#set_netlist $::env(lvs_result_file_tag).powered.v
#global_placement_or
#detailed_placement_or
#run_cts
#global_routing
#detailed_routing
#run_magic
#run_magic_drc
#these commands are valid and will be used once above cmds are verified -please do not remove-
#puts $::env(CURRENT_NETLIST)
#run_magic_spice_export
#run_lvs
#run_antenna_check
#calc_total_runtime
#generate_final_summary_report
