
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

# ACDS 16.1 203 win32 2017.03.22.10:31:35

# ----------------------------------------
# vcsmx - auto-generated simulation script

# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     LOW_LATENCY_XCVR_1x32
# 
# Altera recommends that you source this Quartus-generated IP simulation
# script from your own customized top-level script, and avoid editing this
# generated script.
# 
# To write a top-level shell script that compiles Altera simulation libraries 
# and the Quartus-generated IP in your project, along with your design and
# testbench files, copy the text from the TOP-LEVEL TEMPLATE section below
# into a new file, e.g. named "vcsmx_sim.sh", and modify text as directed.
# 
# You can also modify the simulation flow to suit your needs. Set the
# following variables to 1 to disable their corresponding processes:
# - SKIP_FILE_COPY: skip copying ROM/RAM initialization files
# - SKIP_DEV_COM: skip compiling the Quartus EDA simulation library
# - SKIP_COM: skip compiling Quartus-generated IP simulation files
# - SKIP_ELAB and SKIP_SIM: skip elaboration and simulation
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
# # the simulator. In this case, you must also copy the generated library
# # setup "synopsys_sim.setup" into the location from which you launch the
# # simulator, or incorporate into any existing library setup.
# #
# # Run Quartus-generated IP simulation script once to compile Quartus EDA
# # simulation libraries and Quartus-generated IP simulation files, and copy
# # any ROM/RAM initialization files to the simulation directory.
# #
# # - If necessary, specify USER_DEFINED_COMPILE_OPTIONS.
# source <script generation output directory>/synopsys/vcsmx/vcsmx_setup.sh \
# SKIP_ELAB=1 \
# SKIP_SIM=1 \
# USER_DEFINED_COMPILE_OPTIONS=<compilation options for your design> \
# QSYS_SIMDIR=<script generation output directory>
# #
# # Compile all design files and testbench files, including the top level.
# # (These are all the files required for simulation other than the files
# # compiled by the IP script)
# #
# vlogan <compilation options> <design and testbench files>
# #
# # TOP_LEVEL_NAME is used in this script to set the top-level simulation or
# # testbench module/entity name.
# #
# # Run the IP script again to elaborate and simulate the top level:
# # - Specify TOP_LEVEL_NAME and USER_DEFINED_ELAB_OPTIONS.
# # - Override the default USER_DEFINED_SIM_OPTIONS. For example, to run
# #   until $finish(), set to an empty string: USER_DEFINED_SIM_OPTIONS="".
# #
# source <script generation output directory>/synopsys/vcsmx/vcsmx_setup.sh \
# SKIP_FILE_COPY=1 \
# SKIP_DEV_COM=1 \
# SKIP_COM=1 \
# TOP_LEVEL_NAME="'-top <simulation top>'" \
# QSYS_SIMDIR=<script generation output directory> \
# USER_DEFINED_ELAB_OPTIONS=<elaboration options for your design> \
# USER_DEFINED_SIM_OPTIONS=<simulation options for your design>
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
# initialize variables
TOP_LEVEL_NAME="LOW_LATENCY_XCVR_1x32"
QSYS_SIMDIR="./../../"
QUARTUS_INSTALL_DIR="D:/intelfpga/16.1/quartus/"
SKIP_FILE_COPY=0
SKIP_DEV_COM=0
SKIP_COM=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

# ----------------------------------------
# initialize simulation properties - DO NOT MODIFY!
ELAB_OPTIONS=""
SIM_OPTIONS=""
if [[ `vcs -platform` != *"amd64"* ]]; then
  :
else
  :
fi

# ----------------------------------------
# create compilation libraries
mkdir -p ./libraries/work/
mkdir -p ./libraries/LOW_LATENCY_XCVR_1x32/
mkdir -p ./libraries/altera_ver/
mkdir -p ./libraries/lpm_ver/
mkdir -p ./libraries/sgate_ver/
mkdir -p ./libraries/altera_mf_ver/
mkdir -p ./libraries/altera_lnsim_ver/
mkdir -p ./libraries/stratixv_ver/
mkdir -p ./libraries/stratixv_hssi_ver/
mkdir -p ./libraries/stratixv_pcie_hip_ver/

# ----------------------------------------
# copy RAM/ROM files to simulation directory

# ----------------------------------------
# compile device library files
if [ $SKIP_DEV_COM -eq 0 ]; then
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v"                       -work altera_ver           
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"                                -work lpm_ver              
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"                                   -work sgate_ver            
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"                               -work altera_mf_ver        
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"                           -work altera_lnsim_ver     
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/stratixv_atoms_ncrypt.v"          -work stratixv_ver         
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/stratixv_atoms.v"                          -work stratixv_ver         
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/stratixv_hssi_atoms_ncrypt.v"     -work stratixv_hssi_ver    
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/stratixv_hssi_atoms.v"                     -work stratixv_hssi_ver    
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/stratixv_pcie_hip_atoms_ncrypt.v" -work stratixv_pcie_hip_ver
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QUARTUS_INSTALL_DIR/eda/sim_lib/stratixv_pcie_hip_atoms.v"                 -work stratixv_pcie_hip_ver
fi

# ----------------------------------------
# compile design files in correct order
if [ $SKIP_COM -eq 0 ]; then
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/altera_xcvr_functions.sv"                -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/altera_xcvr_low_latency_phy.sv"          -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_pma_controller_tgx.v"                -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_resync.sv"                      -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_common_h.sv"                -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_common.sv"                  -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_pcs8g_h.sv"                 -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_pcs8g.sv"                   -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_selector.sv"                -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_mgmt2dec.sv"                    -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/altera_wait_generate.v"                  -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/altera_xcvr_reset_control.sv"            -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_reset_counter.sv"               -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_low_latency_phy_nr.sv"           -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_10g_custom_native.sv"            -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_custom_native.sv"                -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_pcs.sv"                               -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_pcs_ch.sv"                            -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_pma.sv"                               -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_reconfig_bundle_to_xcvr.sv"           -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_reconfig_bundle_to_ip.sv"             -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_reconfig_bundle_merger.sv"            -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_rx_pma.sv"                            -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_tx_pma.sv"                            -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_tx_pma_ch.sv"                         -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_h.sv"                            -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_avmm_csr.sv"                     -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_avmm_dcd.sv"                     -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_avmm.sv"                         -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_data_adapter.sv"                 -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_native.sv"                       -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_plls.sv"                         -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_10g_rx_pcs_rbc.sv"               -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_10g_tx_pcs_rbc.sv"               -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_8g_rx_pcs_rbc.sv"                -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_8g_tx_pcs_rbc.sv"                -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_8g_pcs_aggregate_rbc.sv"         -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_common_pcs_pma_interface_rbc.sv" -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_common_pld_pcs_interface_rbc.sv" -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_pipe_gen1_2_rbc.sv"              -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_pipe_gen3_rbc.sv"                -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_rx_pcs_pma_interface_rbc.sv"     -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_rx_pld_pcs_interface_rbc.sv"     -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_tx_pcs_pma_interface_rbc.sv"     -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_tx_pld_pcs_interface_rbc.sv"     -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_arbiter.sv"                     -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k -sverilog $USER_DEFINED_COMPILE_OPTIONS "$QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_m2s.sv"                         -work LOW_LATENCY_XCVR_1x32
  vlogan +v2k $USER_DEFINED_COMPILE_OPTIONS           "$QSYS_SIMDIR/LOW_LATENCY_XCVR_1x32.v"                                                                        
fi

# ----------------------------------------
# elaborate top level design
if [ $SKIP_ELAB -eq 0 ]; then
  vcs -lca -t ps $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS $TOP_LEVEL_NAME
fi

# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS
fi
