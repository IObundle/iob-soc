#
# SYNTHESIS AND IMPLEMENTATION SCRIPT
#

#include
read_verilog ../../../rtl/include/system.vh
read_verilog ../../../submodules/interconnect/rtl/include/interconnect.vh
read_verilog ../../../submodules/uart/rtl/include/iob-uart.vh

#clock
if { [lindex $argv 0] != {USE_DDR} } {
    read_verilog verilog/clock_wizard.v
}

#system
read_verilog verilog/top_system.v
read_verilog ../../../rtl/src/system.v
read_verilog ../../../rtl/src/boot_ctr.v

#picorv32
read_verilog ../../../submodules/picorv32/iob_picorv32.v
read_verilog ../../../submodules/picorv32/picorv32.v

#uart
read_verilog ../../../submodules/uart/rtl/src/iob-uart.v

#memory
read_verilog ../../../rtl/src/int_mem.v
read_verilog ../../../rtl/src/ram.v
read_verilog ../../../rtl/src/ext_mem.v
read_verilog ../../../submodules/mem/tdp_ram/iob_tdp_ram.v

set_property part xcku040-fbva676-1-c [current_project]

if { [lindex $argv 0] == {USE_DDR} } {
    
    read_verilog ../../../submodules/mem/fifo/fifo.vh
    read_verilog ../../../submodules/mem/fifo/afifo/afifo.v
    read_verilog ../../../submodules/cache/rtl/header/iob-cache.vh
    read_verilog ../../../submodules/cache/rtl/src/iob-cache.v
    read_verilog ../../../submodules/cache/rtl/src/gen_mem_reg.v

    read_xdc ./ddr.xdc


    if { ![file isdirectory "ip"]} {
        file mkdir ./ip
    }

    #async interconnect MIG<->Cache
    if { [file isdirectory "ip/axi_interconnect_0"] } {
        read_ip ./ip/axi_interconnect_0/axi_interconnect_0.xci
        report_property [get_files ./ip/axi_interconnect_0/axi_interconnect_0.xci]
    } else {
        create_ip -name axi_interconnect -vendor xilinx.com -library ip -version 1.7 -module_name axi_interconnect_0 -dir ./ip -force
        
        report_property [get_ips axi_interconnect_0]
        
        set_property -dict [list CONFIG.NUM_SLAVE_PORTS {1} CONFIG.S00_AXI_IS_ACLK_ASYNC {1} CONFIG.S00_AXI_READ_FIFO_DEPTH {32} CONFIG.S00_AXI_DATA_WIDTH {32}] [get_ips axi_interconnect_0]
        
        generate_target {instantiation_template} [get_files ./ip/axi_interconnect_0/axi_interconnect_0.xci]
        generate_target all [get_files ./ip/axi_interconnect_0/axi_interconnect_0.xci]
        
        
        read_ip ./ip/axi_interconnect_0/axi_interconnect_0.xci
        report_property [get_files ./ip/axi_interconnect_0/axi_interconnect_0.xci]
        
        synth_ip [get_files ./ip/axi_interconnect_0/axi_interconnect_0.xci]
    }
    
    if { [file isdirectory "ip/ddr4_0"] } {
	read_ip ./ip/ddr4_0/ddr4_0.xci
        report_property [get_files ./ip/ddr4_0/ddr4_0.xci]
    } else {
        create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name ddr4_0 -dir ./ip -force
        
        report_property [get_ips ddr4_0]

        set_property -dict [list CONFIG.C0.DDR4_TimePeriod {1250} CONFIG.C0.DDR4_InputClockPeriod {4000} CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5} CONFIG.C0.DDR4_MemoryPart {EDY4016AABG-DR-F} CONFIG.C0.DDR4_DataWidth {32} CONFIG.C0.DDR4_AxiSelection {true} CONFIG.C0.DDR4_CasLatency {11} CONFIG.C0.DDR4_CasWriteLatency {11} CONFIG.C0.DDR4_AxiDataWidth {32} CONFIG.C0.DDR4_AxiAddressWidth {30} CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100} CONFIG.C0.BANK_GROUP_WIDTH {1}] [get_ips ddr4_0]
	
        generate_target {instantiation_template} [get_files ./ip/ddr4_0/ddr4_0.xci]
        generate_target all [get_files ./ip/ddr4_0/ddr4_0.xci]


        read_ip ./ip/ddr4_0/ddr4_0.xci

        report_property [get_files ./ip/ddr4_0/ddr4_0.xci]
        
        synth_ip [get_files ./ip/ddr4_0/ddr4_0.xci]
    }

}

read_xdc ./synth_system.xdc

synth_design -part xcku040-fbva676-1-c -top top_system 

opt_design

place_design

route_design

report_utilization

report_timing

write_bitstream -force synth_system.bit

write_verilog -force synth_system.v
