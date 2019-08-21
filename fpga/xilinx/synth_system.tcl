#include
read_verilog ../../rtl/include/system.vh
read_verilog ../../submodules/iob-uart/rtl/include/iob-uart.vh

#clock
read_verilog ../../rtl/src/clock/clock_wizard.v

#system
read_verilog ../../rtl/src/top_system.v
read_verilog ../../rtl/src/system.v
read_verilog ../../rtl/src/iob_generic_interconnect.v
read_verilog ../../rtl/src/iob_native_memory_mapped_decoder.v

#picorV 
read_verilog ../../submodules/iob-rv32/picorv32.v

#uart
read_verilog ../../submodules/iob-uart/rtl/src/iob-uart.v

#memory
read_verilog ../../rtl/src/memory/main_memory.v
read_verilog ../../rtl/src/memory/boot_memory.v
read_verilog ../../rtl/src/memory/xalt_1p_mem_no_initialization.v
read_verilog ../../submodules/iob-rv32/rtl/xalt_1p_mem.v

#cache
read_verilog ../../submodules/iob-cache/rtl/src/afifo.v
read_verilog ../../submodules/iob-cache/rtl/src/data_memory.v
read_verilog ../../submodules/iob-cache/rtl/src/memory_cache_v2.v
read_verilog ../../submodules/iob-cache/rtl/src/tag_memory.v
read_verilog ../../submodules/iob-cache/rtl/src/valid_memory.v
read_verilog ../../submodules/iob-cache/rtl/src/write_buffer.v
read_verilog ../../submodules/iob-cache/rtl/src/xalt_1p_mem_no_initialization_with_reset.v

read_xdc ./synth_system.xdc

set_property part xcku040-fbva676-1-c [current_project]

#bram_AXI
#read_ip ../../rtl/ip/bram_axi.xcix
#report_property [get_ips bram_axi]
#synth_ip [get_ips bram_axi]

#ddr
read_ip ../../rtl/ip/ddr4_0/ddr4_0.xci
report_property [get_ips ddr4_0]
synth_ip [get_ips ddr4_0]


#            -part 'part fpga'         -top 'sistema de top (module)'
synth_design -part xcku040-fbva676-1-c -top top_system 
# read_xdc synth_system.xdc ##pos-synthesis constraints

read_xdc ./impl_system.xdc
read_xdc ./ddr_impl.xdc

opt_design
place_design
route_design

report_utilization
report_timing

write_verilog -force synth_system_test_Icarus.v
write_bitstream -force synth_system_test_Icarus.bit
# write_mem_info -force synth_system.mmi

