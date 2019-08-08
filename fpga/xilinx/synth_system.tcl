read_verilog ../../rtl/src/top_system_test_Icarus_diff_clk.v
read_verilog ../../rtl/src/system.v
read_verilog ../../submodules/iob-rv32/picorv32.v
read_verilog ../../rtl/src/iob_native_interconnect.v 
read_verilog ../../submodules/iob-uart/rtl/src/simpleuart.v
read_verilog ../../rtl/src/memory/main_memory.v
read_verilog ../../rtl/src/memory/ddr_memory.v
read_verilog ../../rtl/src/memory/xalt_1p_mem_no_initialization.v
read_verilog ../../submodules/iob-rv32/rtl/xalt_1p_mem.v
read_verilog ../../rtl/src/memory/boot_memory.v
read_verilog ../../rtl/src/clock/clock_wizard.v

read_xdc ./synth_system.xdc

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

