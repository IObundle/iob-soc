# library search paths
set_attribute lib_search_path [list /opt/ic_tools/pdk/faraday/umc130/LL/fsc0l_d/2009Q2v3.0/GENERIC_CORE/FrontEnd/synopsys .]

set libs [glob *.lib]
set_attribute library [list fsc0l_d_generic_core_tt1p2v25c.lib $libs]

# hdl search paths
set SRC_FIFO 		"../../../submodules/fifo"
set SRC_MEM 		"../../../src/wrapper"
set SRC_CPU 		"../../../../submodules/iob-picorv32/hardware/src/iob_picorv32.v"
set SRC_UART 		"../../../../submodules/UART/hardware/src"
set SRC_UART_I 		"../../../../submodules/UART/hardware/include"
set SRC_CACHE 		"../../../../submodules/iob-cache/hardware/src"
set SRC_CACHE_I		"../../../../submodules/iob-cache/hardware/include"
set SRC_SYS 		"../../../src"
set SRC_SYS_I 		"../../../include"
set SRC_CONNECT 	"../../../../submodules/iob-cache/submodules/iob-interconnect/hardware/src"
set SRC_CONNECT_I 	"../../../../submodules/iob-cache/submodules/iob-interconnect/hardware/include"		

set_attribute hdl_search_path [list $SRC_MEM $SRC_UART_I $SRC_UART $SRC_FIFO $SRC_CACHE_I $SRC_CACHE $SRC_CONNECT_I $SRC_CONNECT $SRC_SYS_I $SRC_SYS]

#verilog source files
set SRC [glob $SRC_FIFO/*.v $SRC_MEM/*.v $SRC_UART/*.v $SRC_CACHE/*.v $SRC_UART/*.v $SRC_SYS/*.v]
echo "\n\nSource files:" $SRC
echo "\n\n"
set INCLUDE [glob $SRC_UART_I/*.vh $SRC_CACHE_I/*.vh $SRC_SYS_I/*.vh]
echo "\n\nHeader files:" $INCLUDE
echo "\n\n"
echo "DEFINE:" $DEFINE "\n\n"

#verilog defines 
read_hdl -v2001 $DEFINE $SRC_CPU $INCLUDE $SRC
elaborate system
define_clock -name clk -period 31250 [find / -port clk] 
synthesize -to_mapped
#retime -prepare -min_delay
report gates > gates_report.txt
report area > area_report.txt
report timing > timing_report.txt
write_hdl -mapped > system_synth.v 
write_sdc > system_synth.sdc

exit
