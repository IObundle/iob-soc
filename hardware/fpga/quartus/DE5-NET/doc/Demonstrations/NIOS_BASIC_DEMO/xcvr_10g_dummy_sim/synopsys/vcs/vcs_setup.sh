
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

# ACDS 16.1 203 win32 2017.03.21.15:09:31

# ----------------------------------------
# vcs - auto-generated simulation script

# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     xcvr_10g_dummy
# 
# Altera recommends that you source this Quartus-generated IP simulation
# script from your own customized top-level script, and avoid editing this
# generated script.
# 
# To write a top-level shell script that compiles Altera simulation libraries
# and the Quartus-generated IP in your project, along with your design and
# testbench files, follow the guidelines below.
# 
# 1) Copy the shell script text from the TOP-LEVEL TEMPLATE section
# below into a new file, e.g. named "vcs_sim.sh".
# 
# 2) Copy the text from the DESIGN FILE LIST & OPTIONS TEMPLATE section into
# a separate file, e.g. named "filelist.f".
# 
# ----------------------------------------
# # TOP-LEVEL TEMPLATE - BEGIN
# #
# # TOP_LEVEL_NAME is used in the Quartus-generated IP simulation script to
# # set the top-level simulation or testbench module/entity name.
# #
# # QSYS_SIMDIR is used in the Quartus-generated IP simulation script to
# # construct paths to the files required to simulate the IP in your Quartus
# # project. By default, the IP script assumes that you are launching the
# # simulator from the IP script location. If launching from another
# # location, set QSYS_SIMDIR to the output directory you specified when you
# # generated the IP script, relative to the directory from which you launch
# # the simulator.
# #
# # Source the Quartus-generated IP simulation script and do the following:
# # - Compile the Quartus EDA simulation library and IP simulation files.
# # - Specify TOP_LEVEL_NAME and QSYS_SIMDIR.
# # - Compile the design and top-level simulation module/entity using
# #   information specified in "filelist.f".
# # - Override the default USER_DEFINED_SIM_OPTIONS. For example, to run
# #   until $finish(), set to an empty string: USER_DEFINED_SIM_OPTIONS="".
# # - Run the simulation.
# #
# source <script generation output directory>/synopsys/vcs/vcs_setup.sh \
# TOP_LEVEL_NAME=<simulation top> \
# QSYS_SIMDIR=<script generation output directory> \
# USER_DEFINED_ELAB_OPTIONS="\"-f filelist.f\"" \
# USER_DEFINED_SIM_OPTIONS=<simulation options for your design>
# #
# # TOP-LEVEL TEMPLATE - END
# ----------------------------------------
# 
# ----------------------------------------
# # DESIGN FILE LIST & OPTIONS TEMPLATE - BEGIN
# #
# # Compile all design files and testbench files, including the top level.
# # (These are all the files required for simulation other than the files
# # compiled by the Quartus-generated IP simulation script)
# #
# +systemverilogext+.sv
# <design and testbench files, compile-time options, elaboration options>
# #
# # DESIGN FILE LIST & OPTIONS TEMPLATE - END
# ----------------------------------------
# 
# IP SIMULATION SCRIPT
# ----------------------------------------
# If xcvr_10g_dummy is one of several IP cores in your
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
# ACDS 16.1 203 win32 2017.03.21.15:09:31
# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="xcvr_10g_dummy"
QSYS_SIMDIR="./../../"
QUARTUS_INSTALL_DIR="D:/intelfpga/16.1/quartus/"
SKIP_FILE_COPY=0
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
# copy RAM/ROM files to simulation directory

vcs -lca -timescale=1ps/1ps -sverilog +verilog2001ext+.v -ntb_opts dtm $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v \
  $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/stratixv_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/stratixv_atoms.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/stratixv_hssi_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/stratixv_hssi_atoms.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/stratixv_pcie_hip_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/stratixv_pcie_hip_atoms.v \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/altera_xcvr_functions.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/altera_xcvr_low_latency_phy.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_pma_controller_tgx.v \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_resync.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_common_h.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_common.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_pcs8g_h.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_pcs8g.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_csr_selector.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_mgmt2dec.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/altera_wait_generate.v \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/altera_xcvr_reset_control.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_reset_counter.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_low_latency_phy_nr.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_10g_custom_native.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_custom_native.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_pcs.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_pcs_ch.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_pma.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_reconfig_bundle_to_xcvr.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_reconfig_bundle_to_ip.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_reconfig_bundle_merger.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_rx_pma.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_tx_pma.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_tx_pma_ch.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_h.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_avmm_csr.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_avmm_dcd.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_avmm.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_data_adapter.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_native.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_xcvr_plls.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_10g_rx_pcs_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_10g_tx_pcs_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_8g_rx_pcs_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_8g_tx_pcs_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_8g_pcs_aggregate_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_common_pcs_pma_interface_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_common_pld_pcs_interface_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_pipe_gen1_2_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_pipe_gen3_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_rx_pcs_pma_interface_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_rx_pld_pcs_interface_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_tx_pcs_pma_interface_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/sv_hssi_tx_pld_pcs_interface_rbc.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_arbiter.sv \
  $QSYS_SIMDIR/altera_xcvr_low_latency_phy/alt_xcvr_m2s.sv \
  $QSYS_SIMDIR/xcvr_10g_dummy.v \
  -top $TOP_LEVEL_NAME
# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS
fi
