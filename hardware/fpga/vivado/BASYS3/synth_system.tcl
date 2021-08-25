#
# SYNTHESIS AND IMPLEMENTATION SCRIPT
#

#select top module and FPGA decive
set TOP top_system
set PART xc7a35tcpg236-1

set INCLUDE [lindex $argv 0]
set DEFINE [lindex $argv 1]
set VSRC [lindex $argv 2]

set USE_DDR [string last "USE_DDR" $DEFINE]

#verilog sources
foreach file [split $VSRC \ ] {
    if {$file != ""} {
        read_verilog -sv $file
    }
}

set_property part $PART [current_project]

if { $USE_DDR < 0 } {
    read_verilog verilog/clock_wizard.v
} else {

    read_xdc ./ddr.xdc


    if { ![file isdirectory "./ip"]} {
        file mkdir ./ip
    }

    #async interconnect MIG<->Cache
    if { [file isdirectory "./ip/axi_interconnect_0"] } {
        read_ip ./ip/axi_interconnect_0/axi_interconnect_0.xci
        report_property [get_files ./ip/axi_interconnect_0/axi_interconnect_0.xci]
    } else {

        create_ip -name axi_interconnect -vendor xilinx.com -library ip -version 1.7 -module_name axi_interconnect_0 -dir ./ip -force

        set_property -dict \
            [list \
                 CONFIG.NUM_SLAVE_PORTS {1}\
                 CONFIG.AXI_ADDR_WIDTH {30}\
                 CONFIG.ACLK_PERIOD {5000} \
                 CONFIG.INTERCONNECT_DATA_WIDTH {32}\
                 CONFIG.M00_AXI_IS_ACLK_ASYNC {1}\
                 CONFIG.M00_AXI_WRITE_FIFO_DEPTH {32}\
                 CONFIG.M00_AXI_READ_FIFO_DEPTH {32}\
                 CONFIG.S00_AXI_IS_ACLK_ASYNC {1}\
                 CONFIG.S00_AXI_READ_FIFO_DEPTH {32}\
                 CONFIG.S00_AXI_WRITE_FIFO_DEPTH {32}] [get_ips axi_interconnect_0]

        generate_target all [get_files ./ip/axi_interconnect_0/axi_interconnect_0.xci]

        report_property [get_ips axi_interconnect_0]
        report_property [get_files ./ip/axi_interconnect_0/axi_interconnect_0.xci]
        exec sed -i s/100/5/g ip/axi_interconnect_0/axi_interconnect_0_ooc.xdc
        synth_ip [get_files ./ip/axi_interconnect_0/axi_interconnect_0.xci]

    }

    if { [file isdirectory "./ip/ddr4_0"] } {
	read_ip ./ip/ddr4_0/ddr4_0.xci
        report_property [get_files ./ip/ddr4_0/ddr4_0.xci]
    } else {

        create_ip -name ddr4 -vendor xilinx.com -library ip -version 2.2 -module_name ddr4_0 -dir ./ip -force

        set_property -dict \
        [list \
             CONFIG.C0.DDR4_TimePeriod {1250} \
             CONFIG.C0.DDR4_InputClockPeriod {4000} \
             CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5} \
             CONFIG.C0.DDR4_MemoryPart {EDY4016AABG-DR-F} \
             CONFIG.C0.DDR4_DataWidth {32} \
             CONFIG.C0.DDR4_AxiSelection {true} \
             CONFIG.C0.DDR4_CasLatency {11} \
             CONFIG.C0.DDR4_CasWriteLatency {11} \
             CONFIG.C0.DDR4_AxiDataWidth {32} \
             CONFIG.C0.DDR4_AxiAddressWidth {30} \
             CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100} \
             CONFIG.C0.BANK_GROUP_WIDTH {1}] [get_ips ddr4_0]

        generate_target all [get_files ./ip/ddr4_0/ddr4_0.xci]

        report_property [get_ips ddr4_0]
        report_property [get_files ./ip/ddr4_0/ddr4_0.xci]

        synth_ip [get_files ./ip/ddr4_0/ddr4_0.xci]
    }

}

read_xdc ./synth_system.xdc

synth_design -include_dirs $INCLUDE -verilog_define $DEFINE -part $PART -top $TOP

opt_design

place_design

route_design

report_utilization

report_timing

write_bitstream -force synth_system.bit

write_verilog -force synth_system.v
