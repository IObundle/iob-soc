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


# SDC file for alt_xcvr_reconfig
# You will need to adjust the constraints based on your design
#**************************************************************
# Create Clock
#  -enable and edit these two constraints to fit your design
#**************************************************************

# Note - the source for the mgmt_clk_clk should be set to whatever parent port drives the alt_xcvr_reconfig's mgmt_clk_clk port
#create_clock -period 10ns  -name {mgmt_clk_clk} [get_ports {mgmt_clk_clk}]

# Note that the source clock should be the mgmt_clk_clk, or whichever parent clock is driving it
#create_generated_clock -name sv_reconfig_pma_testbus_clk -source [get_ports {mgmt_clk_clk}] -divide_by 1  [get_registers *sv_xcvr_reconfig_basic:s5|*alt_xcvr_arbiter:pif*|*grant*]

# The following constraint is a TCL loop used to generate clocks for the basic block in 
# the reconfiguration controller.  However, if the constraints are already in place
# then comment out this loop, as timequest will report warnings for overwriting 
# clocks.  An alternative is to use the commented constraint above.  It needs to be 
# modified to fit the design.
#
# Procedure: 
# First, Report a collection of clocks to reg_init[0], which is the reconfig clk.  
# Next, for each item in the collection, we report the upper hierarchy up to reg_init[0], 
# and concatenate pif[0]*|*grant* to create the destination.  We use the value of
# count to create unique names of the clock instince.  Then increment count.

# Set constraint variables
# Determines if the BER is enabled in the design.
set ber_exists [get_registers -nowarn *alt_xcvr_reconfig*alt_xcvr_reconfig_eyemon_ctrl*xreconfig_ctrl*ber_fifo*]

set count 0

# If the generated clocks for the pmatestbus (grant[0]) already exist, then do not regenerate them.
if { [get_collection_size [get_clocks -nowarn sv_reconfig_pma_testbus_clk_?]] eq 0 } {
  set grant_clk [get_pins -compatibility_mode -no_duplicates *\|basic\|s5\|reg_init\[0\]\|clk]
  foreach_in_collection reconfig_clk $grant_clk {
    set reconfig_clk [get_object_info -name $reconfig_clk]
    if [regexp {^(.*.)(?=reg_init)} $reconfig_clk grant_clk] {
      create_generated_clock -add -name sv_reconfig_pma_testbus_clk_$count -source [get_pins -compatibility_mode -no_duplicates $reconfig_clk] -divide_by 1  [get_registers $grant_clk*pif[0]*\|*grant*]
      set_clock_groups -exclusive -group [get_clocks sv_reconfig_pma_testbus_clk_$count]

      # If the BER Counter exists, then set a false path to it from the generated clock to avoid timing registers to multiple clocks
      if { [get_collection_size $ber_exists] > 0 } {
        # If there is a custom sv_reconfig_pma_testbus_clk in place, then tailor this constraint to match the clock
        set_false_path -from [get_clocks sv_reconfig_pma_testbus_clk_$count] -to [get_registers -nowarn *alt_xcvr_reconfig*alt_xcvr_reconfig_eyemon_ctrl*xreconfig_ctrl*ber_fifo*]
      }
      incr count
    }
  }
}

#**************************************************************
# False paths
#**************************************************************
# testbus not an actual clock - set asynchronous to all other clocks
# Comment this back in if you are using the commented constraints above
# for creating generated clocks.
#set_clock_groups -exclusive -group [get_clocks {sv_reconfig_pma_testbus_clk}]



# The derive_pll_clocks constraint needs to be run before the following constraints are read, or certain constraints may be ignored.
# Generally, derive_pll_clocks is run as a part of a top-level sdc file, which should be ordered to be read before
# the reconfig *.qip file in the *.qsf.

# Sets constraints to only be run during timequest to suppress timing violations.  Sets the PMATESTBUSSEL[0] as Asynchronous
if { [string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)] } {
  # If the BER is enabled in the reconfiguration controller, the following 
  # false paths will be set.  It sets false paths to the write Side of the BER Fifo
  if { [get_collection_size $ber_exists] > 0 } {
    set_false_path  -from [get_registers -nowarn *alt_xcvr_reconfig*sv_xcvr_reconfig_basic*alt_xcvr_arbiter*pif_arb*grant[0]] \
                    -to   [get_registers -nowarn *alt_xcvr_reconfig*alt_xcvr_reconfig_eyemon_ctrl*xreconfig_ctrl*ber_fifo*]
    set_false_path  -from [get_registers -nowarn *avmm*pmatestbus*] \
                    -to   [get_registers -nowarn *alt_xcvr_reconfig*alt_xcvr_reconfig_eyemon_ctrl_sv*xreconfig_ctrl*ber_fifo*]
  }

  # Sets a False path for hold time violations on the pif_interface_sel
  set_false_path -from {*|alt_xcvr_reconfig_basic:basic|sv_xcvr_reconfig_basic:s5|pif_interface_sel} -hold

# If we are not in TimeQuest, then run the constraints to maintain a max 
# skew on the pmatestbus to the write side of the BER Fifo
} else {
  if { [get_collection_size $ber_exists] > 0 } {
    set_max_skew  -from [get_registers -nowarn *xcvr_native*avmm*pmatestbus[?]] \
                  -to   [get_registers -nowarn *alt_xcvr_reconfig*alt_xcvr_reconfig_eyemon_ctrl_sv*xreconfig_ctrl*ber_fifo*porta_datain_reg?*] 2ns
  }
}

# Sets the pmatestbussel[0] clock asynchronous to all other clocks including other pmatestbussel[0] clocks sourced from other channels
foreach_in_collection pmatestbussel_clocks [get_clocks {*hssi_avmm_interface_inst|pmatestbussel[0]}] {
  set_clock_groups -asynchronous -group [get_clock_info -name $pmatestbussel_clocks]
}
