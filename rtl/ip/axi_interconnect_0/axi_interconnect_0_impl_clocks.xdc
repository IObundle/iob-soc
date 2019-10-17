###############################################################################################################
# Core-Level Implementation-only Timing Constraints for AXI Interconnect Component "axi_interconnect_0"
###############################################################################################################
 
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
set_disable_timing -from CLK -to O [filter [get_cells -hierarchical -filter {NAME =~ *inst_fifo_gen/*gntv_or_sync_fifo.mem/gdm.dm*/RAM_reg*/RAM*}] {REF_NAME =~ RAM*}]
