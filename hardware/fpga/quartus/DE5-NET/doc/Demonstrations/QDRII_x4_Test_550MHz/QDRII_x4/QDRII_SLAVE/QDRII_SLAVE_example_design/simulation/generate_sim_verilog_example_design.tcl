if {[is_project_open]} {
	set project_name $::quartus(project)
	if {[string compare $project_name "generate_sim_example_design"] != 0} {
		post_message -type error "Invalid project \"$project_name\""
		post_message -type error "In order to generate the simulation example design,"
		post_message -type error "please close the current project \"$project_name\""
		post_message -type error "and open the project \"generate_sim_example_design\""
		post_message -type error "in the directory QDRII_SLAVE_example_design/simulation/"
		return 1
	}
}
set variant_name QDRII_SLAVE_example_sim
set arg_list [list]
puts "Generating Verilog example design"
set hdl_language verilog
set hdl_ext v
lappend arg_list "--file-set=SIM_VERILOG"
lappend arg_list "--system-info=DEVICE_FAMILY=STRATIXV"
lappend arg_list "--output-name=${variant_name}"
lappend arg_list "--output-dir=${hdl_language}"
lappend arg_list "--report-file=spd:[file join ${hdl_language} ${variant_name}.spd]"
lappend arg_list "--component-param=TG_NUM_DRIVER_LOOP=1"
lappend arg_list "--component-param=ABSTRACT_REAL_COMPARE_TEST=false"
lappend arg_list "--component-param=ACV_PHY_CLK_ADD_FR_PHASE=0.0"
lappend arg_list "--component-param=AC_PACKAGE_DESKEW=true"
lappend arg_list "--component-param=AC_ROM_USER_ADD_0=0_0000_0000_0000"
lappend arg_list "--component-param=AC_ROM_USER_ADD_1=0_0000_0000_1000"
lappend arg_list "--component-param=ADD_EFFICIENCY_MONITOR=false"
lappend arg_list "--component-param=ADD_EXTERNAL_SEQ_DEBUG_NIOS=false"
lappend arg_list "--component-param=ADVERTIZE_SEQUENCER_SW_BUILD_FILES=false"
lappend arg_list "--component-param=AFI_DEBUG_INFO_WIDTH=32"
lappend arg_list "--component-param=AVL_MAX_SIZE=1"
lappend arg_list "--component-param=BYTE_ENABLE=false"
lappend arg_list "--component-param=C2P_WRITE_CLOCK_ADD_PHASE=0.0"
lappend arg_list "--component-param=CALIBRATION_MODE=Full"
lappend arg_list "--component-param=CALIB_REG_WIDTH=8"
lappend arg_list "--component-param=COMMAND_PHASE=0"
lappend arg_list "--component-param=CORE_DEBUG_CONNECTION=EXPORT"
lappend arg_list "--component-param=CTL_LATENCY=1"
lappend arg_list "--component-param=CUT_NEW_FAMILY_TIMING=true"
lappend arg_list "--component-param=DEVICE_DEPTH=1"
lappend arg_list "--component-param=DEVICE_FAMILY_PARAM="
lappend arg_list "--component-param=DEVICE_WIDTH=1"
lappend arg_list "--component-param=DISABLE_CHILD_MESSAGING=false"
lappend arg_list "--component-param=DLL_SHARING_MODE=Slave"
lappend arg_list "--component-param=DQS_DQSN_MODE=COMPLEMENTARY"
lappend arg_list "--component-param=DQ_INPUT_REG_USE_CLKN=true"
lappend arg_list "--component-param=DUPLICATE_AC=false"
lappend arg_list "--component-param=ED_EXPORT_SEQ_DEBUG=false"
lappend arg_list "--component-param=EMULATED_MODE=false"
lappend arg_list "--component-param=EMULATED_WRITE_GROUPS=2"
lappend arg_list "--component-param=ENABLE_CTRL_AVALON_INTERFACE=true"
lappend arg_list "--component-param=ENABLE_DELAY_CHAIN_WRITE=false"
lappend arg_list "--component-param=ENABLE_EMIT_BFM_MASTER=false"
lappend arg_list "--component-param=ENABLE_EXPORT_SEQ_DEBUG_BRIDGE=false"
lappend arg_list "--component-param=ENABLE_EXTRA_REPORTING=false"
lappend arg_list "--component-param=ENABLE_ISS_PROBES=false"
lappend arg_list "--component-param=ENABLE_NON_DESTRUCTIVE_CALIB=false"
lappend arg_list "--component-param=ENABLE_NON_DES_CAL=false"
lappend arg_list "--component-param=ENABLE_NON_DES_CAL_TEST=false"
lappend arg_list "--component-param=ENABLE_SEQUENCER_MARGINING_ON_BY_DEFAULT=false"
lappend arg_list "--component-param=EXPORT_AFI_HALF_CLK=false"
lappend arg_list "--component-param=EXTRA_SETTINGS="
lappend arg_list "--component-param=FIX_READ_LATENCY=8"
lappend arg_list "--component-param=FORCE_DQS_TRACKING=AUTO"
lappend arg_list "--component-param=FORCE_MAX_LATENCY_COUNT_WIDTH=0"
lappend arg_list "--component-param=FORCE_SEQUENCER_TCL_DEBUG_MODE=false"
lappend arg_list "--component-param=FORCE_SHADOW_REGS=AUTO"
lappend arg_list "--component-param=FORCE_SYNTHESIS_LANGUAGE="
lappend arg_list "--component-param=HARD_EMIF=false"
lappend arg_list "--component-param=HCX_COMPAT_MODE=false"
lappend arg_list "--component-param=HHP_HPS=false"
lappend arg_list "--component-param=HHP_HPS_SIMULATION=false"
lappend arg_list "--component-param=HHP_HPS_VERIFICATION=false"
lappend arg_list "--component-param=HPS_PROTOCOL=DEFAULT"
lappend arg_list "--component-param=INCLUDE_BOARD_DELAY_MODEL=false"
lappend arg_list "--component-param=INCLUDE_MULTIRANK_BOARD_DELAY_MODEL=false"
lappend arg_list "--component-param=IO_STANDARD=1.8-V HSTL"
lappend arg_list "--component-param=IS_ES_DEVICE=false"
lappend arg_list "--component-param=MARGIN_VARIATION_TEST=false"
lappend arg_list "--component-param=MAX10_RTL_SEQ=false"
lappend arg_list "--component-param=MEM_ADDR_WIDTH=20"
lappend arg_list "--component-param=MEM_BURST_LENGTH=4"
lappend arg_list "--component-param=MEM_CK_PHASE=0.0"
lappend arg_list "--component-param=MEM_CLK_FREQ=550.0"
lappend arg_list "--component-param=MEM_CONTROL_WIDTH=1"
lappend arg_list "--component-param=MEM_CS_WIDTH=1"
lappend arg_list "--component-param=MEM_DENALI_SOMA_FILE=qdrii.soma"
lappend arg_list "--component-param=MEM_DEVICE=MISSING_MODEL"
lappend arg_list "--component-param=MEM_DM_WIDTH=2"
lappend arg_list "--component-param=MEM_DQ_WIDTH=18"
lappend arg_list "--component-param=MEM_IF_BOARD_BASE_DELAY=10"
lappend arg_list "--component-param=MEM_IF_DM_PINS_EN=true"
lappend arg_list "--component-param=MEM_IF_DQSN_EN=true"
lappend arg_list "--component-param=MEM_LEVELING=false"
lappend arg_list "--component-param=MEM_READ_DQS_WIDTH=1"
lappend arg_list "--component-param=MEM_SUPPRESS_CMD_TIMING_ERROR=0"
lappend arg_list "--component-param=MEM_T_RL=2.5"
lappend arg_list "--component-param=MEM_T_WL=1"
lappend arg_list "--component-param=MEM_USE_DENALI_MODEL=false"
lappend arg_list "--component-param=MEM_VERBOSE=true"
lappend arg_list "--component-param=MEM_WRITE_DQS_WIDTH=1"
lappend arg_list "--component-param=MRS_MIRROR_PING_PONG_ATSO=false"
lappend arg_list "--component-param=NIOS_ROM_DATA_WIDTH=32"
lappend arg_list "--component-param=NUM_DLL_SHARING_INTERFACES=1"
lappend arg_list "--component-param=NUM_EXTRA_REPORT_PATH=10"
lappend arg_list "--component-param=NUM_OCT_SHARING_INTERFACES=1"
lappend arg_list "--component-param=NUM_PLL_SHARING_INTERFACES=1"
lappend arg_list "--component-param=OCT_SHARING_MODE=Slave"
lappend arg_list "--component-param=P2C_READ_CLOCK_ADD_PHASE=0.0"
lappend arg_list "--component-param=PACKAGE_DESKEW=true"
lappend arg_list "--component-param=PARSE_FRIENDLY_DEVICE_FAMILY_PARAM="
lappend arg_list "--component-param=PARSE_FRIENDLY_DEVICE_FAMILY_PARAM_VALID=false"
lappend arg_list "--component-param=PHY_CSR_ENABLED=false"
lappend arg_list "--component-param=PHY_ONLY=false"
lappend arg_list "--component-param=PINGPONGPHY_EN=false"
lappend arg_list "--component-param=PLL_ADDR_CMD_CLK_DIV_PARAM=0"
lappend arg_list "--component-param=PLL_ADDR_CMD_CLK_FREQ_PARAM=0.0"
lappend arg_list "--component-param=PLL_ADDR_CMD_CLK_FREQ_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_ADDR_CMD_CLK_MULT_PARAM=0"
lappend arg_list "--component-param=PLL_ADDR_CMD_CLK_PHASE_PS_PARAM=0"
lappend arg_list "--component-param=PLL_ADDR_CMD_CLK_PHASE_PS_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_AFI_CLK_DIV_PARAM=0"
lappend arg_list "--component-param=PLL_AFI_CLK_FREQ_PARAM=0.0"
lappend arg_list "--component-param=PLL_AFI_CLK_FREQ_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_AFI_CLK_MULT_PARAM=0"
lappend arg_list "--component-param=PLL_AFI_CLK_PHASE_PS_PARAM=0"
lappend arg_list "--component-param=PLL_AFI_CLK_PHASE_PS_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_AFI_HALF_CLK_DIV_PARAM=0"
lappend arg_list "--component-param=PLL_AFI_HALF_CLK_FREQ_PARAM=0.0"
lappend arg_list "--component-param=PLL_AFI_HALF_CLK_FREQ_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_AFI_HALF_CLK_MULT_PARAM=0"
lappend arg_list "--component-param=PLL_AFI_HALF_CLK_PHASE_PS_PARAM=0"
lappend arg_list "--component-param=PLL_AFI_HALF_CLK_PHASE_PS_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_AFI_PHY_CLK_DIV_PARAM=0"
lappend arg_list "--component-param=PLL_AFI_PHY_CLK_FREQ_PARAM=0.0"
lappend arg_list "--component-param=PLL_AFI_PHY_CLK_FREQ_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_AFI_PHY_CLK_MULT_PARAM=0"
lappend arg_list "--component-param=PLL_AFI_PHY_CLK_PHASE_PS_PARAM=0"
lappend arg_list "--component-param=PLL_AFI_PHY_CLK_PHASE_PS_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_C2P_WRITE_CLK_DIV_PARAM=0"
lappend arg_list "--component-param=PLL_C2P_WRITE_CLK_FREQ_PARAM=0.0"
lappend arg_list "--component-param=PLL_C2P_WRITE_CLK_FREQ_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_C2P_WRITE_CLK_MULT_PARAM=0"
lappend arg_list "--component-param=PLL_C2P_WRITE_CLK_PHASE_PS_PARAM=0"
lappend arg_list "--component-param=PLL_C2P_WRITE_CLK_PHASE_PS_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_CLK_PARAM_VALID=false"
lappend arg_list "--component-param=PLL_CONFIG_CLK_DIV_PARAM=0"
lappend arg_list "--component-param=PLL_CONFIG_CLK_FREQ_PARAM=0.0"
lappend arg_list "--component-param=PLL_CONFIG_CLK_FREQ_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_CONFIG_CLK_MULT_PARAM=0"
lappend arg_list "--component-param=PLL_CONFIG_CLK_PHASE_PS_PARAM=0"
lappend arg_list "--component-param=PLL_CONFIG_CLK_PHASE_PS_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_DR_CLK_DIV_PARAM=0"
lappend arg_list "--component-param=PLL_DR_CLK_FREQ_PARAM=0.0"
lappend arg_list "--component-param=PLL_DR_CLK_FREQ_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_DR_CLK_MULT_PARAM=0"
lappend arg_list "--component-param=PLL_DR_CLK_PHASE_PS_PARAM=0"
lappend arg_list "--component-param=PLL_DR_CLK_PHASE_PS_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_HR_CLK_DIV_PARAM=0"
lappend arg_list "--component-param=PLL_HR_CLK_FREQ_PARAM=0.0"
lappend arg_list "--component-param=PLL_HR_CLK_FREQ_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_HR_CLK_MULT_PARAM=0"
lappend arg_list "--component-param=PLL_HR_CLK_PHASE_PS_PARAM=0"
lappend arg_list "--component-param=PLL_HR_CLK_PHASE_PS_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_LOCATION=Top_Bottom"
lappend arg_list "--component-param=PLL_MEM_CLK_DIV_PARAM=0"
lappend arg_list "--component-param=PLL_MEM_CLK_FREQ_PARAM=0.0"
lappend arg_list "--component-param=PLL_MEM_CLK_FREQ_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_MEM_CLK_MULT_PARAM=0"
lappend arg_list "--component-param=PLL_MEM_CLK_PHASE_PS_PARAM=0"
lappend arg_list "--component-param=PLL_MEM_CLK_PHASE_PS_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_NIOS_CLK_DIV_PARAM=0"
lappend arg_list "--component-param=PLL_NIOS_CLK_FREQ_PARAM=0.0"
lappend arg_list "--component-param=PLL_NIOS_CLK_FREQ_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_NIOS_CLK_MULT_PARAM=0"
lappend arg_list "--component-param=PLL_NIOS_CLK_PHASE_PS_PARAM=0"
lappend arg_list "--component-param=PLL_NIOS_CLK_PHASE_PS_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_P2C_READ_CLK_DIV_PARAM=0"
lappend arg_list "--component-param=PLL_P2C_READ_CLK_FREQ_PARAM=0.0"
lappend arg_list "--component-param=PLL_P2C_READ_CLK_FREQ_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_P2C_READ_CLK_MULT_PARAM=0"
lappend arg_list "--component-param=PLL_P2C_READ_CLK_PHASE_PS_PARAM=0"
lappend arg_list "--component-param=PLL_P2C_READ_CLK_PHASE_PS_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_SHARING_MODE=Slave"
lappend arg_list "--component-param=PLL_WRITE_CLK_DIV_PARAM=0"
lappend arg_list "--component-param=PLL_WRITE_CLK_FREQ_PARAM=0.0"
lappend arg_list "--component-param=PLL_WRITE_CLK_FREQ_SIM_STR_PARAM="
lappend arg_list "--component-param=PLL_WRITE_CLK_MULT_PARAM=0"
lappend arg_list "--component-param=PLL_WRITE_CLK_PHASE_PS_PARAM=0"
lappend arg_list "--component-param=PLL_WRITE_CLK_PHASE_PS_SIM_STR_PARAM="
lappend arg_list "--component-param=POWER_OF_TWO_BUS=false"
lappend arg_list "--component-param=QDRII_PLUS_MODE=false"
lappend arg_list "--component-param=RATE=Half"
lappend arg_list "--component-param=READ_DQ_DQS_CLOCK_SOURCE=DQS_BUS"
lappend arg_list "--component-param=READ_FIFO_SIZE=8"
lappend arg_list "--component-param=REFRESH_INTERVAL=15000"
lappend arg_list "--component-param=REF_CLK_FREQ=50.0"
lappend arg_list "--component-param=REF_CLK_FREQ_MAX_PARAM=0.0"
lappend arg_list "--component-param=REF_CLK_FREQ_MIN_PARAM=0.0"
lappend arg_list "--component-param=REF_CLK_FREQ_PARAM_VALID=false"
lappend arg_list "--component-param=SEQUENCER_TYPE=NIOS"
lappend arg_list "--component-param=SKIP_MEM_INIT=true"
lappend arg_list "--component-param=SOPC_COMPAT_RESET=false"
lappend arg_list "--component-param=SPEED_GRADE=2"
lappend arg_list "--component-param=SYS_INFO_DEVICE_FAMILY=Stratix V"
lappend arg_list "--component-param=TIMING_ADDR_CTRL_SKEW=36"
lappend arg_list "--component-param=TIMING_BOARD_AC_EYE_REDUCTION_H=0"
lappend arg_list "--component-param=TIMING_BOARD_AC_EYE_REDUCTION_SU=0"
lappend arg_list "--component-param=TIMING_BOARD_AC_TO_CK_SKEW=8"
lappend arg_list "--component-param=TIMING_BOARD_DATA_TO_CQ_SKEW=8"
lappend arg_list "--component-param=TIMING_BOARD_DATA_TO_K_SKEW=10"
lappend arg_list "--component-param=TIMING_BOARD_DELTA_DQS_ARRIVAL_TIME=0"
lappend arg_list "--component-param=TIMING_BOARD_DELTA_READ_DQS_ARRIVAL_TIME=0.0"
lappend arg_list "--component-param=TIMING_BOARD_DQ_EYE_REDUCTION=0"
lappend arg_list "--component-param=TIMING_BOARD_READ_DQ_EYE_REDUCTION=0.0"
lappend arg_list "--component-param=TIMING_BOARD_SKEW=20"
lappend arg_list "--component-param=TIMING_BOARD_SKEW_BETWEEN_DIMMS=0"
lappend arg_list "--component-param=TIMING_BOARD_SKEW_BETWEEN_DQS=20"
lappend arg_list "--component-param=TIMING_BOARD_SKEW_WITHIN_CQ=20"
lappend arg_list "--component-param=TIMING_BOARD_SKEW_WITHIN_K=23"
lappend arg_list "--component-param=TIMING_QDR_INTERNAL_JITTER=250"
lappend arg_list "--component-param=TIMING_TCQD=150"
lappend arg_list "--component-param=TIMING_TCQDOH=-150"
lappend arg_list "--component-param=TIMING_TCQHCQnH=655"
lappend arg_list "--component-param=TIMING_THA=230"
lappend arg_list "--component-param=TIMING_THD=180"
lappend arg_list "--component-param=TIMING_TKH=400"
lappend arg_list "--component-param=TIMING_TKHKnH=770"
lappend arg_list "--component-param=TIMING_TSA=230"
lappend arg_list "--component-param=TIMING_TSD=180"
lappend arg_list "--component-param=TRACKING_ERROR_TEST=false"
lappend arg_list "--component-param=TRACKING_WATCH_TEST=false"
lappend arg_list "--component-param=TREFI=35100"
lappend arg_list "--component-param=TRFC=350"
lappend arg_list "--component-param=USER_DEBUG_LEVEL=0"
lappend arg_list "--component-param=USE_FAKE_PHY=false"
lappend arg_list "--component-param=USE_MEM_CLK_FREQ=false"
lappend arg_list "--component-param=USE_SEQUENCER_BFM=false"
set qdir $::env(QUARTUS_ROOTDIR)
catch {eval [concat [list exec "$qdir/sopc_builder/bin/ip-generate" --component-name=alt_mem_if_qdrii_tg_eds] $arg_list]} temp
puts $temp

set spd_filename [file join $hdl_language ${variant_name}.spd]
catch {eval [list exec "$qdir/sopc_builder/bin/ip-make-simscript" --spd=${spd_filename} --compile-to-work --output-directory=${hdl_language}]} temp
puts $temp

set scripts [list [file join $hdl_language synopsys vcs vcs_setup.sh] [file join $hdl_language synopsys vcsmx vcsmx_setup.sh] [file join $hdl_language cadence ncsim_setup.sh]]
foreach scriptname $scripts {
	if {[catch {set fh [open $scriptname r]} temp]} {
	} else {
		set lines [split [read $fh] "\n"]
		close $fh
		if {[catch {set fh [open $scriptname w]} temp]} {
			post_message -type warning "$temp"
		} else {
			foreach line $lines {
				if {[regexp -- {USER_DEFINED_SIM_OPTIONS\s*=.*\+vcs\+finish\+100} $line]} {
					regsub -- {\+vcs\+finish\+100} $line {} line
				} elseif {[regexp -- {USER_DEFINED_SIM_OPTIONS\s*=.*-input \\\"@run 100; exit\\\"} $line]} {
					regsub -- {-input \\\"@run 100; exit\\\"} $line {} line
				}
				puts $fh $line
			}
			close $fh
		}
	}
}
