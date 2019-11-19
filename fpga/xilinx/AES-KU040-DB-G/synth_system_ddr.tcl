
read_verilog ../rtl/top_system_MIG_debug.v
read_verilog ../rtl/system.v
read_verilog ../rtl/picorv32.v
read_verilog ../rtl/iob_axi_interconnect.v 
read_verilog ../rtl/iob_axi_simpleuart.v
read_verilog ../rtl/simpleuart.v
read_verilog ../rtl/main_memory.v
read_verilog ../rtl/axi_mem_model.v
read_verilog xalt_1p_mem.v
read_verilog ../rtl/size_def.vh


read_ip -quiet ../rtl/ip/ddr4_0/ddr4_0.xci
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/ddr4_0_board.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/par/ddr4_0.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/ip_0/ddr4_0_microblaze_mcs_board.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/ip_0/ddr4_0_microblaze_mcs_ooc.xdc]
#set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/ip_0/bd_9054_microblaze_I_0.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/bd_0/ip/ip_0/bd_9054_microblaze_I_0_ooc_debug.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/bd_0/ip/ip_1/bd_9054_rst_0_0_board.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/bd_0/ip/ip_1/bd_9054_rst_0_0.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/bd_0/ip/ip_2/bd_9054_ilmb_0.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/bd_0/ip/ip_3/bd_9054_dlmb_0.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/bd_0/ip/ip_6/bd_9054_lmb_bram_I_0_ooc.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/bd_0/ip/ip_9/bd_9054_second_lmb_bram_I_0_ooc.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/bd_0/ip/ip_10/bd_9054_iomodule_0_0_board.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/bd_0/bd_9054_ooc.xdc]
set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/ip_1/par/ddr4_0_phy_ooc.xdc]







read_xdc ../rtl/synth_system_ddr_MIG.xdc

#            -part 'part fpga'         -top 'sistema de top (module)'
synth_design -part xcku040-fbva676-1-c -top top_system_MIG_debug 
# read_xdc synth_system.xdc ##pos-synthesis constraints

opt_design
place_design
route_design

report_utilization
report_timing

write_verilog -force synth_system_ddr.v
write_bitstream -force synth_system_ddr.bit
# write_mem_info -force synth_system.mmi

