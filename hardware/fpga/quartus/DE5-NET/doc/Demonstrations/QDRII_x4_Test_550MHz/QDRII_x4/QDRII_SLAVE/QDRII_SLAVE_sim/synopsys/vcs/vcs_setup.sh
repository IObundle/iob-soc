
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

# ACDS 16.1 203 win32 2017.03.22.10:11:52

# ----------------------------------------
# vcs - auto-generated simulation script

# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     QDRII_SLAVE
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
# If QDRII_SLAVE is one of several IP cores in your
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
# ACDS 16.1 203 win32 2017.03.22.10:11:52
# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="QDRII_SLAVE"
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
if [ $SKIP_FILE_COPY -eq 0 ]; then
  cp -f $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_AC_ROM.hex ./
  cp -f $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_inst_ROM.hex ./
  cp -f $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_sequencer_mem.hex ./
fi

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
  $QSYS_SIMDIR/QDRII_SLAVE/alt_qdr_controller_hr_bl4.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/alt_qdr_controller_top_hr_bl4.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/alt_qdr_afi_hr_bl4.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/alt_qdr_fsm_no_ifdef_params.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/memctl_parity.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/memctl_reset_sync.v \
  $QSYS_SIMDIR/QDRII_SLAVE/memctl_burst_latency_shifter_ctl_bl_is_one.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/memctl_data_if_ctl_bl_is_one_qdrii.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0.v \
  $QSYS_SIMDIR/QDRII_SLAVE/altera_avalon_sc_fifo.v \
  $QSYS_SIMDIR/QDRII_SLAVE/altera_mem_if_sequencer_cpu_no_ifdef_params_sim_cpu_inst.v \
  $QSYS_SIMDIR/QDRII_SLAVE/altera_mem_if_sequencer_cpu_no_ifdef_params_sim_cpu_inst_test_bench.v \
  $QSYS_SIMDIR/QDRII_SLAVE/altera_mem_if_sequencer_mem_no_ifdef_params.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/altera_mem_if_sequencer_rst.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/altera_merlin_arbitrator.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/altera_merlin_burst_uncompressor.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/altera_merlin_master_agent.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/altera_merlin_master_translator.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/altera_merlin_slave_agent.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/altera_merlin_slave_translator.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_irq_mapper.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_avalon_st_adapter.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_avalon_st_adapter_error_adapter_0.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_cmd_demux.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_cmd_demux_001.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_cmd_mux.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_cmd_mux_003.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_router.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_router_001.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_router_002.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_router_005.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_rsp_demux_003.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_rsp_mux.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_s0_mm_interconnect_0_rsp_mux_001.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_ac_ROM_no_ifdef_params.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_ac_ROM_reg.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_bitcheck.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_core.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_datamux.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_data_broadcast.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_data_decoder.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_di_buffer.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_di_buffer_wrap.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_dm_decoder.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_generic.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_inst_ROM_no_ifdef_params.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_inst_ROM_reg.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_jumplogic.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_lfsr12.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_lfsr36.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_lfsr72.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_pattern_fifo.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_qdrii.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_ram.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_ram_csr.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_read_datapath.v \
  $QSYS_SIMDIR/QDRII_SLAVE/rw_manager_write_decoder.v \
  $QSYS_SIMDIR/QDRII_SLAVE/sequencer_data_mgr.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/sequencer_phy_mgr.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/sequencer_reg_file.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/sequencer_scc_acv_phase_decode.v \
  $QSYS_SIMDIR/QDRII_SLAVE/sequencer_scc_acv_wrapper.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/sequencer_scc_mgr.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/sequencer_scc_reg_file.v \
  $QSYS_SIMDIR/QDRII_SLAVE/sequencer_scc_siii_phase_decode.v \
  $QSYS_SIMDIR/QDRII_SLAVE/sequencer_scc_siii_wrapper.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/sequencer_scc_sv_phase_decode.v \
  $QSYS_SIMDIR/QDRII_SLAVE/sequencer_scc_sv_wrapper.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/afi_mux_qdrii.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_clock_pair_generator.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_read_valid_selector.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_addr_cmd_datapath.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_reset.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_acv_ldc.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_memphy.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_reset_sync.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_new_io_pads.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_flop_mem.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_fr_cycle_shifter.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_read_datapath.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_write_datapath.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_simple_ddio_out.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_addr_cmd_ldc_pads.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_addr_cmd_ldc_pad.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_addr_cmd_non_ldc_pad.v \
  $QSYS_SIMDIR/QDRII_SLAVE/read_fifo_hard_abstract_no_ifdef_params.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_read_fifo_hard.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_altdqdqs.v \
  $QSYS_SIMDIR/QDRII_SLAVE/altdq_dqs2_stratixv.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/altdq_dqs2_abstract.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/altdq_dqs2_cal_delays.sv \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_p0_altdqdqs_in.v \
  $QSYS_SIMDIR/QDRII_SLAVE/QDRII_SLAVE_0002.v \
  $QSYS_SIMDIR/QDRII_SLAVE.v \
  -top $TOP_LEVEL_NAME
# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS
fi
