
# (C) 2001-2017 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Altera 
# Program License Subscription Agreement, Altera MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by Altera 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ACDS 16.1 203 win32 2017.03.21.09:37:52
# ----------------------------------------
# Auto-generated simulation script rivierapro_setup.tcl
# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     ddr3_b
# 
# Altera recommends that you source this Quartus-generated IP simulation
# script from your own customized top-level script, and avoid editing this
# generated script.
# 
# To write a top-level script that compiles Altera simulation libraries and
# the Quartus-generated IP in your project, along with your design and
# testbench files, copy the text from the TOP-LEVEL TEMPLATE section below
# into a new file, e.g. named "aldec.do", and modify the text as directed.
# 
# ----------------------------------------
# # TOP-LEVEL TEMPLATE - BEGIN
# #
# # QSYS_SIMDIR is used in the Quartus-generated IP simulation script to
# # construct paths to the files required to simulate the IP in your Quartus
# # project. By default, the IP script assumes that you are launching the
# # simulator from the IP script location. If launching from another
# # location, set QSYS_SIMDIR to the output directory you specified when you
# # generated the IP script, relative to the directory from which you launch
# # the simulator.
# #
# set QSYS_SIMDIR <script generation output directory>
# #
# # Source the generated IP simulation script.
# source $QSYS_SIMDIR/aldec/rivierapro_setup.tcl
# #
# # Set any compilation options you require (this is unusual).
# set USER_DEFINED_COMPILE_OPTIONS <compilation options>
# #
# # Call command to compile the Quartus EDA simulation library.
# dev_com
# #
# # Call command to compile the Quartus-generated IP simulation files.
# com
# #
# # Add commands to compile all design files and testbench files, including
# # the top level. (These are all the files required for simulation other
# # than the files compiled by the Quartus-generated IP simulation script)
# #
# vlog -sv2k5 <your compilation options> <design and testbench files>
# #
# # Set the top-level simulation or testbench module/entity name, which is
# # used by the elab command to elaborate the top level.
# #
# set TOP_LEVEL_NAME <simulation top>
# #
# # Set any elaboration options you require.
# set USER_DEFINED_ELAB_OPTIONS <elaboration options>
# #
# # Call command to elaborate your design and testbench.
# elab
# #
# # Run the simulation.
# run
# #
# # Report success to the shell.
# exit -code 0
# #
# # TOP-LEVEL TEMPLATE - END
# ----------------------------------------
# 
# IP SIMULATION SCRIPT
# ----------------------------------------
# If ddr3_b is one of several IP cores in your
# Quartus project, you can generate a simulation script
# suitable for inclusion in your top-level simulation
# script by running the following command line:
# 
# ip-setup-simulation --quartus-project=<quartus project>
# 
# ip-setup-simulation will discover the Altera IP
# within the Quartus project, and generate a unified
# script which supports all the Altera IP within the design.
# ----------------------------------------

# ----------------------------------------
# Initialize variables
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
}

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "ddr3_b"
}

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "./../"
}

if ![info exists QUARTUS_INSTALL_DIR] { 
  set QUARTUS_INSTALL_DIR "D:/intelfpga/16.1/quartus/"
}

if ![info exists USER_DEFINED_COMPILE_OPTIONS] { 
  set USER_DEFINED_COMPILE_OPTIONS ""
}
if ![info exists USER_DEFINED_ELAB_OPTIONS] { 
  set USER_DEFINED_ELAB_OPTIONS ""
}

# ----------------------------------------
# Initialize simulation properties - DO NOT MODIFY!
set ELAB_OPTIONS ""
set SIM_OPTIONS ""
if ![ string match "*-64 vsim*" [ vsim -version ] ] {
} else {
}

set Aldec "Riviera"
if { [ string match "*Active-HDL*" [ vsim -version ] ] } {
  set Aldec "Active"
}

if { [ string match "Active" $Aldec ] } {
  scripterconf -tcl
  createdesign "$TOP_LEVEL_NAME"  "."
  opendesign "$TOP_LEVEL_NAME"
}

# ----------------------------------------
# Copy ROM/RAM files to simulation directory
alias file_copy {
  echo "\[exec\] file_copy"
  file copy -force $QSYS_SIMDIR/ddr3_b/ddr3_b_s0_AC_ROM.hex ./
  file copy -force $QSYS_SIMDIR/ddr3_b/ddr3_b_s0_inst_ROM.hex ./
  file copy -force $QSYS_SIMDIR/ddr3_b/ddr3_b_s0_sequencer_mem.hex ./
}

# ----------------------------------------
# Create compilation libraries
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib      ./libraries     
ensure_lib      ./libraries/work
vmap       work ./libraries/work
ensure_lib                       ./libraries/altera_ver           
vmap       altera_ver            ./libraries/altera_ver           
ensure_lib                       ./libraries/lpm_ver              
vmap       lpm_ver               ./libraries/lpm_ver              
ensure_lib                       ./libraries/sgate_ver            
vmap       sgate_ver             ./libraries/sgate_ver            
ensure_lib                       ./libraries/altera_mf_ver        
vmap       altera_mf_ver         ./libraries/altera_mf_ver        
ensure_lib                       ./libraries/altera_lnsim_ver     
vmap       altera_lnsim_ver      ./libraries/altera_lnsim_ver     
ensure_lib                       ./libraries/stratixv_ver         
vmap       stratixv_ver          ./libraries/stratixv_ver         
ensure_lib                       ./libraries/stratixv_hssi_ver    
vmap       stratixv_hssi_ver     ./libraries/stratixv_hssi_ver    
ensure_lib                       ./libraries/stratixv_pcie_hip_ver
vmap       stratixv_pcie_hip_ver ./libraries/stratixv_pcie_hip_ver
ensure_lib        ./libraries/a0    
vmap       a0     ./libraries/a0    
ensure_lib        ./libraries/ng0   
vmap       ng0    ./libraries/ng0   
ensure_lib        ./libraries/dll0  
vmap       dll0   ./libraries/dll0  
ensure_lib        ./libraries/oct0  
vmap       oct0   ./libraries/oct0  
ensure_lib        ./libraries/c0    
vmap       c0     ./libraries/c0    
ensure_lib        ./libraries/s0    
vmap       s0     ./libraries/s0    
ensure_lib        ./libraries/m0    
vmap       m0     ./libraries/m0    
ensure_lib        ./libraries/p0    
vmap       p0     ./libraries/p0    
ensure_lib        ./libraries/pll0  
vmap       pll0   ./libraries/pll0  
ensure_lib        ./libraries/ddr3_b
vmap       ddr3_b ./libraries/ddr3_b

# ----------------------------------------
# Compile device library files
alias dev_com {
  echo "\[exec\] dev_com"
  eval vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                    -work altera_ver           
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                             -work lpm_ver              
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                                -work sgate_ver            
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                            -work altera_mf_ver        
  vlog  $USER_DEFINED_COMPILE_OPTIONS      "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                        -work altera_lnsim_ver     
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/stratixv_atoms_ncrypt.v"          -work stratixv_ver         
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/stratixv_atoms.v"                       -work stratixv_ver         
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/stratixv_hssi_atoms_ncrypt.v"     -work stratixv_hssi_ver    
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/stratixv_hssi_atoms.v"                  -work stratixv_hssi_ver    
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/aldec/stratixv_pcie_hip_atoms_ncrypt.v" -work stratixv_pcie_hip_ver
  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/stratixv_pcie_hip_atoms.v"              -work stratixv_pcie_hip_ver
}

# ----------------------------------------
# Compile the design files in correct order
alias com {
  echo "\[exec\] com"
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_mm_st_converter.v"                                        -work a0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_addr_cmd.v"                                               -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_addr_cmd_wrap.v"                                          -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_ddr2_odt_gen.v"                                           -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_ddr3_odt_gen.v"                                           -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_lpddr2_addr_cmd.v"                                        -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_odt_gen.v"                                                -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_rdwr_data_tmg.v"                                          -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_arbiter.v"                                                -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_burst_gen.v"                                              -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_cmd_gen.v"                                                -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_csr.v"                                                    -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_buffer.v"                                                 -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_buffer_manager.v"                                         -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_burst_tracking.v"                                         -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_dataid_manager.v"                                         -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_fifo.v"                                                   -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_list.v"                                                   -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_rdata_path.v"                                             -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_wdata_path.v"                                             -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_ecc_decoder.v"                                            -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_ecc_decoder_32_syn.v"                                     -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_ecc_decoder_64_syn.v"                                     -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_ecc_encoder.v"                                            -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_ecc_encoder_32_syn.v"                                     -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_ecc_encoder_64_syn.v"                                     -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_ecc_encoder_decoder_wrapper.v"                            -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_axi_st_converter.v"                                       -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_input_if.v"                                               -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_rank_timer.v"                                             -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_sideband.v"                                               -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_tbp.v"                                                    -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_timing_param.v"                                           -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_controller.v"                                             -work ng0   
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_ddrx_controller_st_top.v"                                      -work ng0   
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS      {\"+incdir+$QSYS_SIMDIR/ddr3_b/\"} "$QSYS_SIMDIR/ddr3_b/alt_mem_if_nextgen_ddr3_controller_core.sv"                            -work ng0   
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altera_mem_if_dll_stratixv.sv"                                         -work dll0  
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altera_mem_if_oct_stratixv.sv"                                         -work oct0  
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_c0.v"                                                           -work c0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0.v"                                                           -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/altera_avalon_mm_bridge.v"                                             -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/altera_avalon_sc_fifo.v"                                               -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/altera_avalon_st_pipeline_base.v"                                      -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/altera_mem_if_sequencer_cpu_no_ifdef_params_sim_cpu_inst.v"            -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/altera_mem_if_sequencer_cpu_no_ifdef_params_sim_cpu_inst_test_bench.v" -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altera_mem_if_sequencer_mem_no_ifdef_params.sv"                        -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altera_mem_if_sequencer_rst.sv"                                        -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altera_merlin_arbitrator.sv"                                           -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altera_merlin_burst_uncompressor.sv"                                   -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altera_merlin_master_agent.sv"                                         -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altera_merlin_master_translator.sv"                                    -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altera_merlin_reorder_memory.sv"                                       -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altera_merlin_slave_agent.sv"                                          -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altera_merlin_slave_translator.sv"                                     -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altera_merlin_traffic_limiter.sv"                                      -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_irq_mapper.sv"                                               -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0.v"                                         -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_avalon_st_adapter.v"                       -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_avalon_st_adapter_error_adapter_0.sv"      -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_cmd_demux.sv"                              -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_cmd_demux_001.sv"                          -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_cmd_mux.sv"                                -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_cmd_mux_002.sv"                            -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_router.sv"                                 -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_router_001.sv"                             -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_router_002.sv"                             -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_router_003.sv"                             -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_router_004.sv"                             -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_router_005.sv"                             -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_rsp_demux.sv"                              -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_rsp_mux.sv"                                -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_0_rsp_mux_001.sv"                            -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_1.v"                                         -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_1_cmd_demux.sv"                              -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_1_cmd_mux.sv"                                -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_1_router.sv"                                 -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_1_router_001.sv"                             -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_1_rsp_demux.sv"                              -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_s0_mm_interconnect_1_rsp_mux.sv"                                -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_ac_ROM_no_ifdef_params.v"                                   -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_ac_ROM_reg.v"                                               -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_bitcheck.v"                                                 -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/rw_manager_core.sv"                                                    -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_datamux.v"                                                  -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_data_broadcast.v"                                           -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_data_decoder.v"                                             -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_ddr3.v"                                                     -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_di_buffer.v"                                                -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_di_buffer_wrap.v"                                           -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_dm_decoder.v"                                               -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/rw_manager_generic.sv"                                                 -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_inst_ROM_no_ifdef_params.v"                                 -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_inst_ROM_reg.v"                                             -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_jumplogic.v"                                                -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_lfsr12.v"                                                   -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_lfsr36.v"                                                   -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_lfsr72.v"                                                   -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_pattern_fifo.v"                                             -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_ram.v"                                                      -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_ram_csr.v"                                                  -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_read_datapath.v"                                            -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/rw_manager_write_decoder.v"                                            -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/sequencer_data_mgr.sv"                                                 -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/sequencer_phy_mgr.sv"                                                  -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/sequencer_reg_file.sv"                                                 -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/sequencer_scc_acv_phase_decode.v"                                      -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/sequencer_scc_acv_wrapper.sv"                                          -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/sequencer_scc_mgr.sv"                                                  -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/sequencer_scc_reg_file.v"                                              -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/sequencer_scc_siii_phase_decode.v"                                     -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/sequencer_scc_siii_wrapper.sv"                                         -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/sequencer_scc_sv_phase_decode.v"                                       -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/sequencer_scc_sv_wrapper.sv"                                           -work s0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/sequencer_trk_mgr.sv"                                                  -work s0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/afi_mux_ddr3_ddrx.v"                                                   -work m0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_clock_pair_generator.v"                                      -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_read_valid_selector.v"                                       -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_addr_cmd_datapath.v"                                         -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_reset.v"                                                     -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_acv_ldc.v"                                                   -work p0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_memphy.sv"                                                   -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_reset_sync.v"                                                -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_new_io_pads.v"                                               -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_fr_cycle_shifter.v"                                          -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_fr_cycle_extender.v"                                         -work p0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_read_datapath.sv"                                            -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_write_datapath.v"                                            -work p0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_core_shadow_registers.sv"                                    -work p0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_simple_ddio_out.sv"                                          -work p0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_phy_csr.sv"                                                  -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_iss_probe.v"                                                 -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_addr_cmd_ldc_pads.v"                                         -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_addr_cmd_ldc_pad.v"                                          -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_addr_cmd_non_ldc_pad.v"                                      -work p0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/read_fifo_hard_abstract_ddrx_lpddrx.sv"                                -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_read_fifo_hard.v"                                            -work p0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0.sv"                                                          -work p0    
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_p0_altdqdqs.v"                                                  -work p0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altdq_dqs2_stratixv.sv"                                                -work p0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altdq_dqs2_abstract.sv"                                                -work p0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/altdq_dqs2_cal_delays.sv"                                              -work p0    
  eval  vlog  $USER_DEFINED_COMPILE_OPTIONS                                         "$QSYS_SIMDIR/ddr3_b/ddr3_b_pll0.sv"                                                        -work pll0  
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b/ddr3_b_0002.v"                                                         -work ddr3_b
  eval  vlog -v2k5 $USER_DEFINED_COMPILE_OPTIONS                                    "$QSYS_SIMDIR/ddr3_b.v"                                                                                 
}

# ----------------------------------------
# Elaborate top level design
alias elab {
  echo "\[exec\] elab"
  eval vsim +access +r -t ps $ELAB_OPTIONS -L work -L a0 -L ng0 -L dll0 -L oct0 -L c0 -L s0 -L m0 -L p0 -L pll0 -L ddr3_b -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L stratixv_ver -L stratixv_hssi_ver -L stratixv_pcie_hip_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Elaborate the top level design with -dbg -O2 option
alias elab_debug {
  echo "\[exec\] elab_debug"
  eval vsim -dbg -O2 +access +r -t ps $ELAB_OPTIONS -L work -L a0 -L ng0 -L dll0 -L oct0 -L c0 -L s0 -L m0 -L p0 -L pll0 -L ddr3_b -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L stratixv_ver -L stratixv_hssi_ver -L stratixv_pcie_hip_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with -dbg -O2
alias ld_debug "
  dev_com
  com
  elab_debug
"

# ----------------------------------------
# Print out user commmand line aliases
alias h {
  echo "List Of Command Line Aliases"
  echo
  echo "file_copy                     -- Copy ROM/RAM files to simulation directory"
  echo
  echo "dev_com                       -- Compile device library files"
  echo
  echo "com                           -- Compile the design files in correct order"
  echo
  echo "elab                          -- Elaborate top level design"
  echo
  echo "elab_debug                    -- Elaborate the top level design with -dbg -O2 option"
  echo
  echo "ld                            -- Compile all the design files and elaborate the top level design"
  echo
  echo "ld_debug                      -- Compile all the design files and elaborate the top level design with -dbg -O2"
  echo
  echo 
  echo
  echo "List Of Variables"
  echo
  echo "TOP_LEVEL_NAME                -- Top level module name."
  echo "                                 For most designs, this should be overridden"
  echo "                                 to enable the elab/elab_debug aliases."
  echo
  echo "SYSTEM_INSTANCE_NAME          -- Instantiated system module name inside top level module."
  echo
  echo "QSYS_SIMDIR                   -- Qsys base simulation directory."
  echo
  echo "QUARTUS_INSTALL_DIR           -- Quartus installation directory."
  echo
  echo "USER_DEFINED_COMPILE_OPTIONS  -- User-defined compile options, added to com/dev_com aliases."
  echo
  echo "USER_DEFINED_ELAB_OPTIONS     -- User-defined elaboration options, added to elab/elab_debug aliases."
}
file_copy
h
