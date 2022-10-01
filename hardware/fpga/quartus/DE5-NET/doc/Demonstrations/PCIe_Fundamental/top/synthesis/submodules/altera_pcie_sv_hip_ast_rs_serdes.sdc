# (C) 2001-2017 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


#####################################################################
#
# altera_pcie_sv_hip_ast SDC Contraint used for soft reset controller
#
######################################################################
#
# Constraints for asynchronous logic
#
set_false_path -from [get_registers *sv_xcvr_pipe_native*] -to [get_registers *altpcie_rs_serdes|*]

#set_false_path -to [get_registers *altpcie_rs_serdes|fifo_err_sync_r[0] ]
set_false_path -to [get_registers *altpcie_rs_serdes|tx_cal_busy_r[0]]
set_false_path -to [get_registers *altpcie_rs_serdes|rx_cal_busy_r[0]]
set_false_path -to [get_registers *altpcie_rs_serdes|pll_locked_r[0]]
set_false_path -to [get_registers *altpcie_rs_serdes|rx_signaldetect_r[*]]
set_false_path -to [get_registers *altpcie_rs_serdes|rx_pll_locked_r[*]]
set_false_path -to [get_registers *altpcie_rs_serdes|rx_pll_freq_locked_r[0]]
