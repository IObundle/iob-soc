# library search paths
set_attribute lib_search_path [list /opt/ic_tools/pdk/faraday/umc130/LL/fsc0l_d/2009Q2v3.0/GENERIC_CORE/FrontEnd/synopsys ../memory/bootrom ../memory/bootram]

#libraries
set bootrom_lib [glob ../memory/bootrom/*.lib]
set bootram_lib [glob ../memory/bootrom/*.lib]
set_attribute library [list fsc0l_d_generic_core_tt1p2v25c.lib $bootrom_lib $bootram_lib]

# hdl search paths
set SRC_FIFO "../../../submodules/fifo"
set SRC_MEM "../../../rtl/src/memory/wrapper"
set SRC_CPU "../../../submodules/iob-rv32/picorv32.v"
set SRC_UART "../../../submodules/iob-uart/rtl/src"
set SRC_UART_I "../../../submodules/iob-uart/rtl/include"
set SRC_CACHE "../../../submodules/iob-cache/rtl/src"
set SRC_CACHE_I "../../../submodules/iob-cache/rtl/header"
set SRC_SYS "../../../rtl/src"
set SRC_SYS_I "../../../rtl/include"

set_attribute hdl_search_path [list $SRC_MEM $SRC_UART_I $SRC_UART $SRC_FIFO $SRC_CACHE_I $SRC_CACHE $SRC_SYS_I $SRC_SYS]

#verilog source files
set SRC [glob $SRC_FIFO/*.v $SRC_MEM/*.v $SRC_UART/*.v $SRC_CACHE/*.v $SRC_SYS/*.v]
echo $SRC

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
