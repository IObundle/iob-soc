# library search paths
set_attribute lib_search_path [list /opt/ic_tools/pdk/faraday/umc130/LL/fsc0l_d/2009Q2v3.0/GENERIC_CORE/FrontEnd/synopsys ../memory/bootrom ../memory/bootram]

# hdl search paths
set SRC_FIFO "../../submodules/fifo"
set SRC_MEM "../../../rtl/src/memory/wrapper"
set SRC_CPU "../../submodules/iob-rv32/picorv32.v"
set SRC_UART "../../submodules/iob-uart/rtl/src"
set SRC_CACHE "../../submodules/iob-cache/rtl/src"
set SRC_SYS "../../../rtl/src"

set_attribute hdl_search_path [list $SRC_SYS $SRC_MEM $SRC_UART $SRC_FIFO $SRC_CACHE]

#libraries
set bootrom_lib [glob ../memory/bootrom/*.lib]
set bootram_lib [glob ../memory/bootrom/*.lib]
set_attribute library [list fsc0l_d_generic_core_tt1p2v25c.lib $bootrom_lib $bootram_lib]

#verilog source files
set SRC [glob $SRC_FIFO/*.v $SRC_MEM/*.v $SRC_UART/*.v $SRC_CACHE/*.v $SRC_SYS]

#verilog defines

read_hdl -v2001 $SRC_CPU $SRC 
elaborate system
define_clock -name clk -period 5000 [find / -port clk] 
synthesize -to_mapped
#retime -prepare -min_delay
report gates > gates_report.txt
report timing > timing_report.txt
write_hdl -mapped > system_synth.v 
write_sdc > system_synth.sdc

exit
