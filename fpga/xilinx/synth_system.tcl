read_verilog ../../rtl/include/system.vh
read_verilog ../../submodules/iob-uart/rtl/include/iob-uart.vh
read_verilog ../../rtl/src/top_system.v
read_verilog ../../rtl/src/system.v
read_verilog ../../submodules/iob-rv32/picorv32.v
read_verilog ../../rtl/src/iob_generic_interconnect.v 
read_verilog ../../submodules/iob-uart/rtl/src/iob-uart.v
read_verilog ../../rtl/src/memory/main_memory.v
read_verilog ../../rtl/src/memory/ddr_memory.v
read_verilog ../../rtl/src/memory/xalt_1p_mem_no_initialization.v
read_verilog ../../submodules/iob-rv32/rtl/xalt_1p_mem.v
read_verilog ../../rtl/src/memory/boot_memory.v
read_verilog ../../rtl/src/clock/clock_wizard.v
read_verilog ../../rtl/src/iob_native_memory_mapped_decoder.v

read_xdc ./synth_system.xdc

#            -part 'part fpga'         -top 'sistema de top (module)'
synth_design -part xcku040-fbva676-1-c -top top_system 
# read_xdc synth_system.xdc ##pos-synthesis constraints

opt_design
place_design
route_design

report_utilization
report_timing

write_verilog -force synth_system_test_Icarus.v
write_bitstream -force synth_system_test_Icarus.bit
# write_mem_info -force synth_system.mmi

