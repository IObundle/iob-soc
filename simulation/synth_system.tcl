
read_verilog ../rtl/top_system_test_Icarus_diff_clk.v
read_verilog ../rtl/system.v
read_verilog ../rtl/picorv32.v
read_verilog ../rtl/iob_native_interconnect.v 
read_verilog ../rtl/simpleuart.v
read_verilog ../rtl/main_memory.v
read_verilog ../rtl/ddr_memory.v
read_verilog ../rtl/xalt_1p_mem_no_initialization.v
read_verilog xalt_1p_mem.v
read_verilog ../rtl/boot_memory.v
read_verilog ../rtl/clock_wizard.v

read_xdc ../rtl/synth_system_test_Icarus.xdc

#            -part 'part fpga'         -top 'sistema de top (module)'
synth_design -part xcku040-fbva676-1-c -top top_system_test_Icarus_diff_clk 
# read_xdc synth_system.xdc ##pos-synthesis constraints

opt_design
place_design
route_design

report_utilization
report_timing

write_verilog -force synth_system_test_Icarus.v
write_bitstream -force synth_system_test_Icarus.bit
# write_mem_info -force synth_system.mmi

