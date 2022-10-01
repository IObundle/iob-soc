set arg_list [list]
lappend arg_list "--component-param=HPS_PROTOCOL=QDRII"
lappend arg_list "--component-param=RATE=Half"
lappend arg_list "--component-param=DLL_USE_DR_CLK=false"
lappend arg_list "--component-param=MEM_IF_READ_DQS_WIDTH=1"
lappend arg_list "--component-param=DUAL_WRITE_CLOCK=false"
lappend arg_list "--component-param=MEM_IF_DQ_WIDTH=18"
lappend arg_list "--component-param=MEM_IF_DM_WIDTH=2"
lappend arg_list "--component-param=MEM_BURST_LENGTH=4"
lappend arg_list "--component-param=DLL_DELAY_CHAIN_LENGTH=8"
lappend arg_list "--component-param=DELAY_PER_OPA_TAP=227"
lappend arg_list "--component-param=DELAY_PER_DCHAIN_TAP=11"
lappend arg_list "--component-param=MAX_LATENCY_COUNT_WIDTH=4"
lappend arg_list "--component-param=CALIB_VFIFO_OFFSET=9"
lappend arg_list "--component-param=CALIB_LFIFO_OFFSET=3"
lappend arg_list "--component-param=CALIB_REG_WIDTH=8"
lappend arg_list "--component-param=READ_VALID_FIFO_SIZE=16"
lappend arg_list "--component-param=MEM_T_WL=1"
lappend arg_list "--component-param=MEM_T_RL=2.5"
lappend arg_list "--component-param=AFI_ADDRESS_WIDTH=40"
lappend arg_list "--component-param=AFI_CONTROL_WIDTH=2"
lappend arg_list "--component-param=AFI_DATA_WIDTH=72"
lappend arg_list "--component-param=AFI_DATA_MASK_WIDTH=8"
lappend arg_list "--component-param=AFI_DQS_WIDTH=2"
lappend arg_list "--component-param=MEM_IF_WRITE_DQS_WIDTH=1"
lappend arg_list "--component-param=AFI_BANK_WIDTH=0"
lappend arg_list "--component-param=AFI_CHIP_SELECT_WIDTH=2"
lappend arg_list "--component-param=AFI_MAX_WRITE_LATENCY_COUNT_WIDTH=6"
lappend arg_list "--component-param=AFI_MAX_READ_LATENCY_COUNT_WIDTH=6"
lappend arg_list "--component-param=IO_DQS_EN_DELAY_OFFSET=128"
lappend arg_list "--component-param=MEM_NUMBER_OF_RANKS=1"
lappend arg_list "--component-param=MEM_ODT_WIDTH=1"
lappend arg_list "--component-param=MEM_ADDRESS_WIDTH=20"
lappend arg_list "--component-param=MEM_CONTROL_WIDTH=1"
lappend arg_list "--component-param=MEM_CHIP_SELECT_WIDTH=1"
lappend arg_list "--component-param=USE_DQS_TRACKING=false"
lappend arg_list "--component-param=USE_SHADOW_REGS=false"
lappend arg_list "--component-param=HCX_COMPAT_MODE=false"
lappend arg_list "--component-param=NUM_WRITE_FR_CYCLE_SHIFTS=1"
lappend arg_list "--component-param=SEQUENCER_VERSION=16.1"
lappend arg_list "--component-param=ENABLE_NON_DESTRUCTIVE_CALIB=false"
lappend arg_list "--component-param=ENABLE_NON_DES_CAL=false"
lappend arg_list "--component-param=ENABLE_NON_DES_CAL_TEST=false"
lappend arg_list "--component-param=USE_USER_RDIMM_VALUE==false"
lappend arg_list "--component-param=MRS_MIRROR_PING_PONG_ATSO=false"
lappend arg_list "--component-param=ENABLE_NIOS_OCI=false"
lappend arg_list "--component-param=ENABLE_DEBUG_BRIDGE=false"
lappend arg_list "--component-param=MAKE_INTERNAL_NIOS_VISIBLE=false"
lappend arg_list "--component-param=ENABLE_NIOS_JTAG_UART=false"
lappend arg_list "--component-param=ENABLE_LARGE_RW_MGR_DI_BUFFER=false"
lappend arg_list "--component-param=SEQ_ROM=QDRII_D_s0_sequencer_mem.hex"
lappend arg_list "--component-param=RAM_BLOCK_TYPE=AUTO"
lappend arg_list "--component-param=AC_ROM_INIT_FILE_NAME=QDRII_D_s0_AC_ROM.hex"
lappend arg_list "--component-param=INST_ROM_INIT_FILE_NAME=QDRII_D_s0_inst_ROM.hex"
lappend arg_list "--component-param=HARD_PHY=false"
lappend arg_list "--component-param=USE_SEQUENCER_BFM=false"
lappend arg_list "--component-param=HHP_HPS=false"
lappend arg_list "--component-param=MAX10_RTL_SEQ=false"
lappend arg_list "--component-param=HARD_VFIFO=0"
lappend arg_list "--component-param=SEQUENCER_MEM_SIZE=11264"
lappend arg_list "--component-param=SEQUENCER_MEM_ADDRESS_WIDTH=13"
lappend arg_list "--component-param=TRK_PARALLEL_SCC_LOAD=false"
lappend arg_list "--component-param=SCC_DATA_WIDTH=1"
lappend arg_list "--component-param=AVL_CLK_PS=10909"
lappend arg_list "--component-param=AFI_CLK_PS=3636"
lappend arg_list "--component-param=TREFI=35100"
lappend arg_list "--component-param=TRFC=350"
lappend arg_list "--component-param=REFRESH_INTERVAL=15000"
lappend arg_list "--output-name=QDRII_D_s0"
lappend arg_list "--system-info=DEVICE_FAMILY=STRATIXV"
lappend arg_list "--report-file=sopcinfo:QDRII_D_s0.sopcinfo"
lappend arg_list "--report-file=txt:QDRII_D_s0_seq_ipd_report.txt"
lappend arg_list "--file-set=SIM_VERILOG"
catch { eval [concat [list exec "D:/intelfpga/16.1/quartus//sopc_builder/bin/ip-generate" --component-name=qsys_sequencer_110] $arg_list] } temp
puts $temp
