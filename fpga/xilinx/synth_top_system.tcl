create_project -in_memory -part xcku040-fbva676-1-c


read_verilog ../../rtl/include/system.vh

read_verilog ../../rtl/src/top_system.v
read_verilog ../../rtl/src/system.v
read_verilog ../../rtl/src/iob_generic_interconnect.v 


read_verilog ../../submodules/iob-cache/rtl/src/cache/afifo.v
read_verilog ../../submodules/iob-cache/rtl/src/cache/data_memory.v
read_verilog ../../submodules/iob-cache/rtl/src/cache/memory_cache_v2.v
read_verilog ../../submodules/iob-cache/rtl/src/cache/tag_memory.v
read_verilog ../../submodules/iob-cache/rtl/src/cache/valid_memory.v
read_verilog ../../submodules/iob-cache/rtl/src/cache/write_buffer.v
read_verilog ../../submodules/iob-cache/rtl/src/cache/xalt_1p_mem_no_initialization_with_reset.v

read_verilog ../../rtl/src/memory/boot_memory.v
read_verilog ../../rtl/src/memory/xalt_1p_mem_no_initialization.v
read_verilog ../../rtl/src/memory/xalt_1p_mem.v

read_verilog ../../submodules/iob-rv32/picorv32.v

read_verilog ../../submodules/iob-uart/rtl/src/simpleuart.v
read_verilog ../../submodules/iob-uart/rtl/include/iob-uart.vh


add_files -norecurse boot_0.dat
add_files -norecurse boot_1.dat
add_files -norecurse boot_2.dat
add_files -norecurse boot_3.dat



read_ip -quiet ../../rtl/ip/ddr4_0/ddr4_0.xci
#generate_target all [get_files ../../rtl/ip/ddr4_0/ddr4_0.xci]
#generate_target {instantiation_template} [get_files /home/jroque/sandbox/iob-rv32-mig-native-axi-fork/rtl/ip/ddr4_0/ddr4_0.xci]
#synth_ip [get_files ../../rtl/ip/ddr4_0/ddr4_0.xci]

read_xdc top_system.xdc
#set_property target_constrs_file top_system.xdc [current_fileset -constrset]

#set_property part xcku040-fbva676-1-c [get_runs synth_1]

#create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name ddr4_0
#set_property -dict [list CONFIG.C0.DDR4_TimePeriod {1250} CONFIG.C0.DDR4_InputClockPeriod {4000} CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5} CONFIG.C0.DDR4_MemoryPart {EDY4016AABG-DR-F} CONFIG.C0.DDR4_DataWidth {32} CONFIG.C0.DDR4_AxiSelection {true} CONFIG.C0.DDR4_CasLatency {11} CONFIG.C0.DDR4_CasWriteLatency {11} CONFIG.C0.DDR4_AxiDataWidth {32} CONFIG.C0.DDR4_AxiAddressWidth {30} CONFIG.C0.BANK_GROUP_WIDTH {1}] [get_ips ddr4_0]
#generate_target {instantiation_template} [get_files /ip/ddr4_0/ddr4_0.xci]
#generate_target all [get_files /ip/ddr4_0/ddr4_0.xci]

#            -part 'part fpga'         -top 'sistema de top (module)'
synth_design -part xcku040-fbva676-1-c -top top_system 
# read_xdc synth_system.xdc ##pos-synthesis constraints
#read_xdc top_system.xdc

set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/ddr4_0_board.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/par/ddr4_0.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/ip_0/ddr4_0_microblaze_mcs_board.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/ip_0/ddr4_0_microblaze_mcs_ooc.xdc]
#set_property used_in_implementation false [get_files -all ../rtl/ip/ddr4_0/ip_0/bd_9054_microblaze_I_0.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/bd_0/ip/ip_0/bd_9054_microblaze_I_0_ooc_debug.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/bd_0/ip/ip_1/bd_9054_rst_0_0_board.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/bd_0/ip/ip_1/bd_9054_rst_0_0.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/bd_0/ip/ip_2/bd_9054_ilmb_0.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/bd_0/ip/ip_3/bd_9054_dlmb_0.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/bd_0/ip/ip_6/bd_9054_lmb_bram_I_0_ooc.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/bd_0/ip/ip_9/bd_9054_second_lmb_bram_I_0_ooc.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/bd_0/ip/ip_10/bd_9054_iomodule_0_0_board.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/bd_0/bd_9054_ooc.xdc]
set_property used_in_implementation false [get_files -all ../../rtl/ip/ddr4_0/ip_1/par/ddr4_0_phy_ooc.xdc]

opt_design
place_design
route_design

report_utilization
report_timing

write_verilog -force synth_system_ddr.v
write_bitstream -force synth_system_ddr.bit
# write_mem_info -force synth_system.mmi

