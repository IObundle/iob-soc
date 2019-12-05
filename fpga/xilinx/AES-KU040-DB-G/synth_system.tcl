#include
read_verilog ../../../rtl/include/system.vh
read_verilog ../../../submodules/iob-uart/rtl/include/iob-uart.vh

#clock
read_verilog verilog/clock_wizard.v

#system
read_verilog verilog/top_system.v
read_verilog ../../../rtl/src/system.v
read_verilog ../../../rtl/src/iob_generic_interconnect.v

#picorv32
read_verilog ../../../submodules/iob-rv32/picorv32.v

#uart
read_verilog ../../../submodules/iob-uart/rtl/src/iob-uart.v

#memory
read_verilog ../../../rtl/src/ram.v
read_verilog ../../../rtl/src/iob_1p_mem.v

if { [lindex $argv 1] == {USE_DDR_1} } {

    read_verilog ../../../submodules/fifo/afifo.v
    read_verilog ../../../submodules/iob-cache/rtl/src/data_memory.v
    read_verilog ../../../submodules/iob-cache/rtl/src/iob-cache.v
    read_verilog ../../../submodules/iob-cache/rtl/src/tag_memory.v
    read_verilog ../../../submodules/iob-cache/rtl/src/valid_memory.v
    read_verilog ../../../submodules/iob-cache/rtl/src/write_buffer.v

    read_xdc ./ddr.xdc


    if { ![file isdirectory ../../"rtl/ip"]} {
        file mkdir ../../rtl/ip
    }

    #async interconnect MIG<->Cache
    if { [file isdirectory ../../"rtl/ip/axi_interconnect_0"] } {
        read_ip ../../rtl/ip/axi_interconnect_0/axi_interconnect_0.xci
        report_property [get_files ../../rtl/ip/axi_interconnect_0/axi_interconnect_0.xci]
    } else {
        create_ip -name axi_interconnect -vendor xilinx.com -library ip -version 1.7 -module_name axi_interconnect_0 -dir ../../rtl/ip -force
        
        report_property [get_ips axi_interconnect_0]
        
        set_property -dict [list \
                                CONFIG.NUM_SLAVE_PORTS {1}\
                                CONFIG.S00_AXI_IS_ACLK_ASYNC {1}\
                                CONFIG.M00_AXI_IS_ACLK_ASYNC {1}\
                                CONFIG.S00_AXI_READ_FIFO_DEPTH {32}\
                                CONFIG.M00_AXI_READ_FIFO_DEPTH {32}\
                                CONFIG.S00_AXI_READ_FIFO_DELAY {0}\
                                CONFIG.M00_AXI_READ_FIFO_DELAY {0}\
                                CONFIG.S00_AXI_DATA_WIDTH {32}\   
                               ] [get_ips axi_interconnect_0]
        
        generate_target {instantiation_template} [get_files ../../rtl/ip/axi_interconnect_0/axi_interconnect_0.xci]
        generate_target all [get_files ../../rtl/ip/axi_interconnect_0/axi_interconnect_0.xci]
        
        
        read_ip ../../rtl/ip/axi_interconnect_0/axi_interconnect_0.xci
        report_property [get_files ../../rtl/ip/axi_interconnect_0/axi_interconnect_0.xci]
        
        synth_ip [get_files ../../rtl/ip/axi_interconnect_0/axi_interconnect_0.xci]
    }
    
    if { [file isdirectory ../../"rtl/ip/ddr4_0"] } {
    read_ip ../../rtl/ip/ddr4_0/ddr4_0.xci
        report_property [get_files ../../rtl/ip/ddr4_0/ddr4_0.xci]
    } else {
        create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name ddr4_0 -dir ../../rtl/ip -force
        
        report_property [get_ips ddr4_0]
        
        set_property -dict [list \
                                CONFIG.C0.DDR4_TimePeriod {1250} \
                                CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5} \
                                CONFIG.C0.DDR4_InputClockPeriod {4000} \
                                CONFIG.C0.DDR4_MemoryPart {EDY4016AABG-DR-F} \
                                CONFIG.C0.DDR4_DataWidth {32} \
                                CONFIG.C0.DDR4_AxiSelection {true} \
                                CONFIG.C0.DDR4_CasLatency {11} \
                                CONFIG.C0.DDR4_CasWriteLatency {11} \
                                CONFIG.C0.DDR4_AxiDataWidth {32} \
                                CONFIG.C0.DDR4_AxiAddressWidth {30} \
                                CONFIG.C0.BANK_GROUP_WIDTH {1} \
                                CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100} \
                               ] [get_ips ddr4_0]
        
        generate_target {instantiation_template} [get_files ../../rtl/ip/ddr4_0/ddr4_0.xci]
        generate_target all [get_files ../../rtl/ip/ddr4_0/ddr4_0.xci]


        read_ip ../../rtl/ip/ddr4_0/ddr4_0.xci
        report_property [get_files ../../rtl/ip/ddr4_0/ddr4_0.xci]
        
        synth_ip [get_files ../../rtl/ip/ddr4_0/ddr4_0.xci]
    }

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
    
    #interconnect MIG<->cache
    set_property used_in_implementation false [get_files -all ../../rtl/ip/axi_interconnect_0/axi_interconnect_0_ooc.xdc]
    set_property used_in_implementation false [get_files -all ../../rtl/ip/axi_interconnect_0/axi_interconnect_0_clocks.xdc]
    set_property used_in_implementation false [get_files -all ../../rtl/ip/axi_interconnect_0/axi_interconnect_0_impl_clocks.xdc]

    read_xdc ./ddr.xdc
}

read_xdc ./synth_system.xdc

set_property part xcku040-fbva676-1-c [current_project]

set DEFINE {synth_design -part xcku040-fbva676-1-c -top top_system }
if {[lindex $argv 0] == {USE_RAM_1}} {
    append DEFINE {-verilog_define USE_RAM}
}
if {[lindex $argv 1] == {USE_DDR_1}} {
    append DEFINE {-verilog_define USE_DDR}
}

set DEFINE {synth_design -part xcku040-fbva676-1-c -top top_system -verilog_define USE_RAM}

eval $DEFINE
opt_design
place_design
route_design

report_utilization
report_timing

write_bitstream -force synth_system.bit

#write_verilog -force synth_system_test_Icarus.v
# write_mem_info -force synth_system.mmi

