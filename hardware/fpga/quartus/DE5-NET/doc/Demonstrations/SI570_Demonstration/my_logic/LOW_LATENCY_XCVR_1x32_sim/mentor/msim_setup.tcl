
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

# ----------------------------------------
# Auto-generated simulation script msim_setup.tcl
# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     LOW_LATENCY_XCVR_1x32
# 
# Altera recommends that you source this Quartus-generated IP simulation
# script from your own customized top-level script, and avoid editing this
# generated script.
# 
# To write a top-level script that compiles Altera simulation libraries and
# the Quartus-generated IP in your project, along with your design and
# testbench files, copy the text from the TOP-LEVEL TEMPLATE section below
# into a new file, e.g. named "mentor.do", and modify the text as directed.
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
# source $QSYS_SIMDIR/mentor/msim_setup.tcl
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
# vlog <compilation options> <design and testbench files>
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
# run -a
# #
# # Report success to the shell.
# exit -code 0
# #
# # TOP-LEVEL TEMPLATE - END
# ----------------------------------------
# 
# IP SIMULATION SCRIPT
# ----------------------------------------
# If LOW_LATENCY_XCVR_1x32 is one of several IP cores in your
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
# ACDS 16.1 203 win32 2017.03.22.10:31:35

# ----------------------------------------
# Initialize variables
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
}

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "LOW_LATENCY_XCVR_1x32"
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

# ----------------------------------------
# Copy ROM/RAM files to simulation directory
alias file_copy {
  echo "\[exec\] file_copy"
}

# ----------------------------------------
# Create compilation libraries
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib          ./libraries/     
ensure_lib          ./libraries/work/
vmap       work     ./libraries/work/
vmap       work_lib ./libraries/work/
if ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] {
  ensure_lib                       ./libraries/altera_ver/           
  vmap       altera_ver            ./libraries/altera_ver/           
  ensure_lib                       ./libraries/lpm_ver/              
  vmap       lpm_ver               ./libraries/lpm_ver/              
  ensure_lib                       ./libraries/sgate_ver/            
  vmap       sgate_ver             ./libraries/sgate_ver/            
  ensure_lib                       ./libraries/altera_mf_ver/        
  vmap       altera_mf_ver         ./libraries/altera_mf_ver/        
  ensure_lib                       ./libraries/altera_lnsim_ver/     
  vmap       altera_lnsim_ver      ./libraries/altera_lnsim_ver/     
  ensure_lib                       ./libraries/stratixv_ver/         
  vmap       stratixv_ver          ./libraries/stratixv_ver/         
  ensure_lib                       ./libraries/stratixv_hssi_ver/    
  vmap       stratixv_hssi_ver     ./libraries/stratixv_hssi_ver/    
  ensure_lib                       ./libraries/stratixv_pcie_hip_ver/
  vmap       stratixv_pcie_hip_ver ./libraries/stratixv_pcie_hip_ver/
}
ensure_lib                       ./libraries/LOW_LATENCY_XCVR_1x32/
vmap       LOW_LATENCY_XCVR_1x32 ./libraries/LOW_LATENCY_XCVR_1x32/

# ----------------------------------------
# Compile device library files
alias dev_com {
  echo "\[exec\] dev_com"
  if ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] {
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                     -work altera_ver           
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                              -work lpm_ver              
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                                 -work sgate_ver            
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                             -work altera_mf_ver        
    eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                         -work altera_lnsim_ver     
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/stratixv_atoms_ncrypt.v"          -work stratixv_ver         
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/stratixv_atoms.v"                        -work stratixv_ver         
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/stratixv_hssi_atoms_ncrypt.v"     -work stratixv_hssi_ver    
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/stratixv_hssi_atoms.v"                   -work stratixv_hssi_ver    
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/mentor/stratixv_pcie_hip_atoms_ncrypt.v" -work stratixv_pcie_hip_ver
    eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QUARTUS_INSTALL_DIR/eda/sim_lib/stratixv_pcie_hip_atoms.v"               -work stratixv_pcie_hip_ver
  }
}

# ----------------------------------------
# Compile the design files in correct order
alias com {
  echo "\[exec\] com"
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/altera_xcvr_functions.sv"                       -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/altera_xcvr_functions.sv"                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/altera_xcvr_low_latency_phy.sv"                 -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/altera_xcvr_low_latency_phy.sv"          -work LOW_LATENCY_XCVR_1x32
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_pma_controller_tgx.v"                       -work LOW_LATENCY_XCVR_1x32
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/alt_pma_controller_tgx.v"                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_resync.sv"                             -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/alt_xcvr_resync.sv"                      -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_common_h.sv"                       -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_common.sv"                         -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_pcs8g_h.sv"                        -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_pcs8g.sv"                          -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_selector.sv"                       -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_mgmt2dec.sv"                           -work LOW_LATENCY_XCVR_1x32
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/altera_wait_generate.v"                         -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/alt_xcvr_csr_common_h.sv"                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/alt_xcvr_csr_common.sv"                  -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/alt_xcvr_csr_pcs8g_h.sv"                 -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/alt_xcvr_csr_pcs8g.sv"                   -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/alt_xcvr_csr_selector.sv"                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/alt_xcvr_mgmt2dec.sv"                    -work LOW_LATENCY_XCVR_1x32
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/altera_wait_generate.v"                  -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/altera_xcvr_reset_control.sv"                   -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_reset_counter.sv"                      -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/altera_xcvr_reset_control.sv"            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/alt_xcvr_reset_counter.sv"               -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_low_latency_phy_nr.sv"                  -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_xcvr_low_latency_phy_nr.sv"           -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_10g_custom_native.sv"                   -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_xcvr_10g_custom_native.sv"            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_custom_native.sv"                       -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_xcvr_custom_native.sv"                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_pcs.sv"                                      -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_pcs_ch.sv"                                   -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_pma.sv"                                      -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_reconfig_bundle_to_xcvr.sv"                  -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_reconfig_bundle_to_ip.sv"                    -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_reconfig_bundle_merger.sv"                   -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_rx_pma.sv"                                   -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_tx_pma.sv"                                   -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_tx_pma_ch.sv"                                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_h.sv"                                   -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_avmm_csr.sv"                            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_avmm_dcd.sv"                            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_avmm.sv"                                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_data_adapter.sv"                        -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_native.sv"                              -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_plls.sv"                                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_pcs.sv"                               -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_pcs_ch.sv"                            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_pma.sv"                               -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_reconfig_bundle_to_xcvr.sv"           -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_reconfig_bundle_to_ip.sv"             -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_reconfig_bundle_merger.sv"            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_rx_pma.sv"                            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_tx_pma.sv"                            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_tx_pma_ch.sv"                         -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_xcvr_h.sv"                            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_xcvr_avmm_csr.sv"                     -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_xcvr_avmm_dcd.sv"                     -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_xcvr_avmm.sv"                         -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_xcvr_data_adapter.sv"                 -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_xcvr_native.sv"                       -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_xcvr_plls.sv"                         -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_10g_rx_pcs_rbc.sv"                      -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_10g_tx_pcs_rbc.sv"                      -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_8g_rx_pcs_rbc.sv"                       -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_8g_tx_pcs_rbc.sv"                       -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_8g_pcs_aggregate_rbc.sv"                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_common_pcs_pma_interface_rbc.sv"        -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_common_pld_pcs_interface_rbc.sv"        -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_pipe_gen1_2_rbc.sv"                     -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_pipe_gen3_rbc.sv"                       -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_rx_pcs_pma_interface_rbc.sv"            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_rx_pld_pcs_interface_rbc.sv"            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_tx_pcs_pma_interface_rbc.sv"            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_tx_pld_pcs_interface_rbc.sv"            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_10g_rx_pcs_rbc.sv"               -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_10g_tx_pcs_rbc.sv"               -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_8g_rx_pcs_rbc.sv"                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_8g_tx_pcs_rbc.sv"                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_8g_pcs_aggregate_rbc.sv"         -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_common_pcs_pma_interface_rbc.sv" -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_common_pld_pcs_interface_rbc.sv" -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_pipe_gen1_2_rbc.sv"              -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_pipe_gen3_rbc.sv"                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_rx_pcs_pma_interface_rbc.sv"     -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_rx_pld_pcs_interface_rbc.sv"     -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_tx_pcs_pma_interface_rbc.sv"     -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/sv_hssi_tx_pld_pcs_interface_rbc.sv"     -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_arbiter.sv"                            -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_m2s.sv"                                -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/alt_xcvr_arbiter.sv"                     -work LOW_LATENCY_XCVR_1x32
  eval  vlog -sv $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/mentor/alt_xcvr_m2s.sv"                         -work LOW_LATENCY_XCVR_1x32
  eval  vlog $USER_DEFINED_COMPILE_OPTIONS     "$QSYS_SIMDIR/LOW_LATENCY_XCVR_1x32.v"                                                                               
}

# ----------------------------------------
# Elaborate top level design
alias elab {
  echo "\[exec\] elab"
  eval vsim -t ps $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS -L work -L work_lib -L LOW_LATENCY_XCVR_1x32 -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L stratixv_ver -L stratixv_hssi_ver -L stratixv_pcie_hip_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Elaborate the top level design with novopt option
alias elab_debug {
  echo "\[exec\] elab_debug"
  eval vsim -novopt -t ps $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS -L work -L work_lib -L LOW_LATENCY_XCVR_1x32 -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L stratixv_ver -L stratixv_hssi_ver -L stratixv_pcie_hip_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with -novopt
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
  echo "elab_debug                    -- Elaborate the top level design with novopt option"
  echo
  echo "ld                            -- Compile all the design files and elaborate the top level design"
  echo
  echo "ld_debug                      -- Compile all the design files and elaborate the top level design with -novopt"
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
