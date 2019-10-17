###############################################################################################################
# Core-Level Timing Constraints for AXI Interconnect Component "axi_interconnect_0"
###############################################################################################################
#
# Global timing constraints:
#
set_false_path -through [get_ports INTERCONNECT_ARESETN]
 
# This component is configured to perform asynchronous clock-domain-crossing.
# In order for these core-level constraints to work properly, 
# the following rules apply to your system-level timing constraints:
#   1. Each of the nets connected to the INTERCONNECT_ACLK, Snn_AXI_ACLK and Mnn_AXI_ACLK ports of
#      this component must have exactly one clock defined on it, using either
#      a) a create_clock command on a top-level clock pin specified in your system XDC file, or
#      b) a create_generated_clock command, typically generated automatically by a core 
#          producing a derived clock signal.
#   2. Any Snn_AXI_ACLK or Mnn_AXI_ACLK ports of this component that are associated with an asynchronous
#      clock conversion should not be connected to the same clock source as INTERCONNECT_ACLK.
#
set INTERCONNECT_ACLK [get_clocks -of_objects [get_ports INTERCONNECT_ACLK]]
set_max_delay -from [get_cells -hierarchical -filter {NAME =~ *_async_conv_reset_reg}] -datapath_only [get_property -min PERIOD $INTERCONNECT_ACLK]
set_max_delay -from [get_cells -hierarchical -filter {NAME =~ *asyncfifo*rd_pntr_gc_reg[*]}] -to [get_cells -hierarchical -filter {NAME =~ *asyncfifo*wr_stg_inst/Q_reg*}] -datapath_only [get_property -min PERIOD $INTERCONNECT_ACLK]
set_max_delay -from [get_cells -hierarchical -filter {NAME =~ *asyncfifo*wr_pntr_gc_reg[*]}] -to [get_cells -hierarchical -filter {NAME =~ *asyncfifo*rd_stg_inst/Q_reg*}] -datapath_only [get_property -min PERIOD $INTERCONNECT_ACLK]
