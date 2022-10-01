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
# THIS IS AN AUTO-GENERATED FILE!
# -------------------------------
# If you modify this files, all your changes will be lost if you
# regenerate the core!
#
# FILE DESCRIPTION
# ----------------
# This file contains the timing constraints for the UniPHY memory
# interface.
#    * The timing parameters used by this file are assigned
#      in the ddr3_a_p0_timing.tcl script.
#    * The helper routines are defined in ddr3_a_p0_pin_map.tcl
#
# NOTE
# ----

set script_dir [file dirname [info script]]

source "$script_dir/ddr3_a_p0_parameters.tcl"
source "$script_dir/ddr3_a_p0_timing.tcl"
source "$script_dir/ddr3_a_p0_pin_map.tcl"

load_package ddr_timing_model

set synthesis_flow 0
set sta_flow 0
set fit_flow 0
if { $::TimeQuestInfo(nameofexecutable) == "quartus_map" } {
	set synthesis_flow 1
} elseif { $::TimeQuestInfo(nameofexecutable) == "quartus_sta" } {
	set sta_flow 1
} elseif { $::TimeQuestInfo(nameofexecutable) == "quartus_fit" } {
	set fit_flow 1
}

set is_es 0
if { [string match -nocase "*es" $::TimeQuestInfo(part)] } {
	set is_es 1
}

####################
#                  #
# GENERAL SETTINGS #
#                  #
####################

# This is a global setting and will apply to the whole design.
# This setting is required for the memory interface to be
# properly constrained.
derive_clock_uncertainty

# Debug switch. Change to 1 to get more run-time debug information
set debug 0

# All timing requirements will be represented in nanoseconds with up to 3 decimal places of precision
set_time_format -unit ns -decimal_places 3

# Determine if entity names are on
set entity_names_on [ ddr3_a_p0_are_entity_names_on ]

##################
#                #
# QUERIED TIMING #
#                #
##################

set io_standard "DIFFERENTIAL 1.5-V SSTL CLASS I"

# This is the peak-to-peak jitter on the whole read capture path
set DQSpathjitter [expr [get_micro_node_delay -micro DQDQS_JITTER -parameters [list IO] -in_fitter]/1000.0]

# This is the proportion of the DQ-DQS read capture path jitter that applies to setup
set DQSpathjitter_setup_prop [expr [get_micro_node_delay -micro DQDQS_JITTER_DIVISION -parameters [list IO] -in_fitter]/100.0]

# This is the peak-to-peak jitter, of which half is considered to be tJITper
set tJITper [expr [get_micro_node_delay -micro MEM_CK_PERIOD_JITTER -parameters [list IO PHY_SHORT] -in_fitter -period $t(CK)]/2000.0 + $SSN(pullin_o)]

##################
#                #
# DERIVED TIMING #
#                #
##################

# These parameters are used to make constraints more readeable

# Half of memory clock cycle
set half_period [ ddr3_a_p0_round_3dp [ expr $t(CK) / 2.0 ] ]

# Half of reference clock
set ref_half_period [ ddr3_a_p0_round_3dp [ expr $t(refCK) / 2.0 ] ]

# AFI cycle
set tCK_AFI [ expr $t(CK) * 4.0 ]

# Minimum delay on data output pins
set t(wru_output_min_delay_external) [expr $t(DH) + $board(intra_DQS_group_skew) + $ISI(DQ)/2 + $ISI(DQS)/2 - $board(DQ_DQS_skew)]
set t(wru_output_min_delay_internal) [expr $t(WL_DCD) + $t(WL_JITTER)*(1.0-$t(WL_JITTER_DIVISION)) + $SSN(rel_pullin_o)]
set data_output_min_delay [ ddr3_a_p0_round_3dp [ expr - $t(wru_output_min_delay_external) - $t(wru_output_min_delay_internal)]]

# Maximum delay on data output pins
set t(wru_output_max_delay_external) [expr $t(DS) + $board(intra_DQS_group_skew) + $ISI(DQ)/2 + $ISI(DQS)/2 + $board(DQ_DQS_skew)]
set t(wru_output_max_delay_internal) [expr $t(WL_DCD) + $t(WL_JITTER)*$t(WL_JITTER_DIVISION) + $SSN(rel_pushout_o)]
set data_output_max_delay [ ddr3_a_p0_round_3dp [ expr $t(wru_output_max_delay_external) + $t(wru_output_max_delay_internal)]]

# Maximum delay on data input pins
set t(rdu_input_max_delay_external) [expr $t(DQSQ) + $board(intra_DQS_group_skew) + $board(DQ_DQS_skew) + $ISI(READ_DQ)/2 + $ISI(READ_DQS)/2]
set t(rdu_input_max_delay_internal) [expr $DQSpathjitter*$DQSpathjitter_setup_prop + $SSN(rel_pushout_i)]
set data_input_max_delay [ ddr3_a_p0_round_3dp [ expr $t(rdu_input_max_delay_external) + $t(rdu_input_max_delay_internal) ]]

# Minimum delay on data input pins
set t(rdu_input_min_delay_external) [expr $board(intra_DQS_group_skew) - $board(DQ_DQS_skew) + $ISI(READ_DQ)/2 + $ISI(READ_DQS)/2]
set t(rdu_input_min_delay_internal) [expr $t(DCD) + $DQSpathjitter*(1.0-$DQSpathjitter_setup_prop) + $SSN(rel_pullin_i)]
set data_input_min_delay [ ddr3_a_p0_round_3dp [ expr - $t(rdu_input_min_delay_external) - $t(rdu_input_min_delay_internal) ]]

# Minimum delay on address and command paths
set ac_min_delay [ ddr3_a_p0_round_3dp [ expr - $t(IH) -$fpga(tPLL_JITTER) - $fpga(tPLL_PSERR) - $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) - $ISI(addresscmd_hold) ]]

# Maximum delay on address and command paths
set ac_max_delay [ ddr3_a_p0_round_3dp [ expr $t(IS) +$fpga(tPLL_JITTER) + $fpga(tPLL_PSERR) + $board(intra_addr_ctrl_skew) + $board(addresscmd_CK_skew) + $ISI(addresscmd_setup) ]]

if { $debug } {
	post_message -type info "SDC: Computed Parameters:"
	post_message -type info "SDC: --------------------"
	post_message -type info "SDC: half_period: $half_period"
	post_message -type info "SDC: data_output_min_delay: $data_output_min_delay"
	post_message -type info "SDC: data_output_max_delay: $data_output_max_delay"
	post_message -type info "SDC: data_input_min_delay: $data_input_min_delay"
	post_message -type info "SDC: data_input_max_delay: $data_input_max_delay"
	post_message -type info "SDC: ac_min_delay: $ac_min_delay"
	post_message -type info "SDC: ac_max_delay: $ac_max_delay"
	post_message -type info "SDC: Using Timing Models: Micro"
}

# This is the main call to the netlist traversal routines
# that will automatically find all pins and registers required
# to apply timing constraints.
# During the fitter, the routines will be called only once
# and cached data will be used in all subsequent calls.
if { ! [ info exists ddr3_a_p0_sdc_cache ] } {
	set ddr3_a_p0_sdc_cache 1
	ddr3_a_p0_initialize_ddr_db ddr3_a_p0_ddr_db
} else {
	if { $debug } {
		post_message -type info "SDC: reusing cached DDR DB"
	}
}

# If multiple instances of this core are present in the
# design they will all be constrained through the
# following loop
set instances [ array names ddr3_a_p0_ddr_db ]
foreach { inst } $instances {
	if { [ info exists pins ] } {
		# Clean-up stale content
		unset pins
	}
	array set pins $ddr3_a_p0_ddr_db($inst)

	set prefix $inst
	if { $entity_names_on } {
		set prefix [ string map "| |*:" $inst ]
		set prefix "*:$prefix"
	}

	#####################################################
	#                                                   #
	# Transfer the pin names to more readable variables #
	#                                                   #
	#####################################################

	set dqs_pins $pins(dqs_pins)
	set dqsn_pins $pins(dqsn_pins)
	set q_groups [ list ]
	foreach { q_group } $pins(q_groups) {
		set q_group $q_group
		lappend q_groups $q_group
	}
	set all_dq_pins [ join [ join $q_groups ] ]

	set ck_pins $pins(ck_pins)
	set ckn_pins $pins(ckn_pins)
	set add_pins $pins(add_pins)
	set ba_pins $pins(ba_pins)
	set cmd_pins $pins(cmd_pins)
	set reset_pins $pins(reset_pins)
	set ac_pins [ concat $add_pins $ba_pins $cmd_pins ]
	set dm_pins $pins(dm_pins)
	set all_dq_dm_pins [ concat $all_dq_pins $dm_pins ]

	set pll_ref_clock $pins(pll_ref_clock)
	set pll_afi_clock $pins(pll_afi_clock)
	set pll_dq_write_clock $pins(pll_dq_write_clock)
	set pll_write_clock $pins(pll_write_clock)
	set pll_avl_clock $pins(pll_avl_clock)
	set pll_config_clock $pins(pll_config_clock)
	set pll_hr_clock $pins(pll_hr_clock)
	set pll_p2c_read_clock $pins(pll_p2c_read_clock)
	set pll_c2p_write_clock $pins(pll_c2p_write_clock)

	set dqs_in_clocks $pins(dqs_in_clocks)
	set dqs_out_clocks $pins(dqs_out_clocks)
	set dqsn_out_clocks $pins(dqsn_out_clocks)
	set leveling_pins $pins(leveling_pins)
	set dq_xphase_cps_pins $pins(dq_xphase_cps_pins)
	set dqs_xphase_cps_pins $pins(dqs_xphase_cps_pins)
	set phase_transfer_pins $pins(phase_transfer_pins)
	set alignment_pins $pins(alignment_pins)

	set afi_reset_reg $pins(afi_reset_reg)
	set seq_reset_reg $pins(seq_reset_reg)
	set sync_reg $pins(sync_reg)
	set read_capture_ddio $pins(read_capture_ddio)
	set fifo_wraddress_reg $pins(fifo_wraddress_reg)
	set fifo_rdaddress_reg $pins(fifo_rdaddress_reg)
	set fifo_wrload_reg $pins(fifo_wrload_reg)
	set fifo_rdload_reg $pins(fifo_rdload_reg)
	set fifo_wrdata_reg $pins(fifo_wrdata_reg)
	set fifo_rddata_reg $pins(fifo_rddata_reg)

	##################
	#                #
	# QUERIED TIMING #
	#                #
	##################

	# Phase Jitter on DQS paths. This parameter is queried at run time
	set fpga(tDQS_PHASE_JITTER) [ expr [ get_integer_node_delay -integer $::GLOBAL_ddr3_a_p0_dqs_delay_chain_length -parameters {IO MAX HIGH} -src DQS_PHASE_JITTER -in_fitter ] / 1000.0 ]

	# Phase Error on DQS paths. This parameter is queried at run time
	set fpga(tDQS_PSERR) [ expr [ get_integer_node_delay -integer $::GLOBAL_ddr3_a_p0_dqs_delay_chain_length -parameters {IO MAX HIGH} -src DQS_PSERR -in_fitter ] / 1000.0 ]

	# Correct input min/max delay for queried parameters
	set t(rdu_input_min_delay_external) [expr $t(rdu_input_min_delay_external) + ($t(CK)/2.0 - $t(QH_time))]
	set t(rdu_input_min_delay_internal) [expr $t(rdu_input_min_delay_internal) + $fpga(tDQS_PSERR) + $tJITper]
	set t(rdu_input_max_delay_external) [expr $t(rdu_input_max_delay_external)]
	set t(rdu_input_max_delay_internal) [expr $t(rdu_input_max_delay_internal) + $fpga(tDQS_PSERR)]

	set final_data_input_max_delay [ ddr3_a_p0_round_3dp [ expr $data_input_max_delay + $fpga(tDQS_PSERR) ]]
	set final_data_input_min_delay [ ddr3_a_p0_round_3dp [ expr $data_input_min_delay - $t(CK) / 2.0 + $t(QH_time) - $fpga(tDQS_PSERR) - $tJITper]]

	if { $debug } {
		post_message -type info "SDC: Jitter Parameters"
		post_message -type info "SDC: -----------------"
		post_message -type info "SDC:    DQS Phase: $::GLOBAL_ddr3_a_p0_dqs_delay_chain_length"
		post_message -type info "SDC:    fpga(tDQS_PHASE_JITTER): $fpga(tDQS_PHASE_JITTER)"
		post_message -type info "SDC:    fpga(tDQS_PSERR): $fpga(tDQS_PSERR)"
		post_message -type info "SDC:    t(QH_time): $t(QH_time)"
		post_message -type info "SDC:"
		post_message -type info "SDC: Derived Parameters:"
		post_message -type info "SDC: -----------------"
		post_message -type info "SDC:    Corrected data_input_max_delay: $final_data_input_max_delay"
		post_message -type info "SDC:    Corrected data_input_min_delay: $final_data_input_min_delay"
		post_message -type info "SDC: -----------------"
	}

	# ----------------------- #
	# -                     - #
	# --- REFERENCE CLOCK --- #
	# -                     - #
	# ----------------------- #

	# This is the reference clock used by the PLL to derive any other clock in the core
	if { [get_collection_size [get_clocks -nowarn $pll_ref_clock]] > 0 } { remove_clock $pll_ref_clock }
	create_clock -period $t(refCK) -waveform [ list 0 $ref_half_period ] $pll_ref_clock

	# ------------------ #
	# -                - #
	# --- PLL CLOCKS --- #
	# -                - #
	# ------------------ #
	
	# AFI clock
	set local_pll_afi_clk [ ddr3_a_p0_get_or_add_clock_vseries \
		-target $pll_afi_clock \
		-suffix "afi_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_ddr3_a_p0_pll_mult(PLL_AFI_CLK) \
		-divide_by $::GLOBAL_ddr3_a_p0_pll_div(PLL_AFI_CLK) \
		-phase $::GLOBAL_ddr3_a_p0_pll_phase(PLL_AFI_CLK) ]
	
	# DQ write clock
	set local_pll_dq_write_clk [ ddr3_a_p0_get_or_add_clock_vseries \
		-target $pll_dq_write_clock \
		-suffix "dq_write_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_ddr3_a_p0_pll_mult(PLL_MEM_CLK) \
		-divide_by $::GLOBAL_ddr3_a_p0_pll_div(PLL_MEM_CLK) \
		-phase $::GLOBAL_ddr3_a_p0_pll_phase(PLL_MEM_CLK) ]
	
	# DQS write clock
	set local_pll_write_clk [ ddr3_a_p0_get_or_add_clock_vseries \
		-target $pll_write_clock \
		-suffix "write_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_ddr3_a_p0_pll_mult(PLL_WRITE_CLK) \
		-divide_by $::GLOBAL_ddr3_a_p0_pll_div(PLL_WRITE_CLK) \
		-phase $::GLOBAL_ddr3_a_p0_pll_phase(PLL_WRITE_CLK) ]

	# NIOS clock
	set local_pll_avl_clock [ ddr3_a_p0_get_or_add_clock_vseries \
		-target $pll_avl_clock \
		-suffix "avl_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_ddr3_a_p0_pll_mult(PLL_NIOS_CLK) \
		-divide_by $::GLOBAL_ddr3_a_p0_pll_div(PLL_NIOS_CLK) \
		-phase $::GLOBAL_ddr3_a_p0_pll_phase(PLL_NIOS_CLK) ]
	
	# I/O scan chain clock
	set local_pll_config_clock [ ddr3_a_p0_get_or_add_clock_vseries \
		-target $pll_config_clock \
		-suffix "config_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_ddr3_a_p0_pll_mult(PLL_CONFIG_CLK) \
		-divide_by $::GLOBAL_ddr3_a_p0_pll_div(PLL_CONFIG_CLK) \
		-phase $::GLOBAL_ddr3_a_p0_pll_phase(PLL_CONFIG_CLK) ]	

	# Half-rate DDIO clock
	set local_pll_c2p_write_clock [ ddr3_a_p0_get_or_add_clock_vseries \
		-target $pll_c2p_write_clock \
		-suffix "c2p_write_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_ddr3_a_p0_pll_mult(PLL_C2P_WRITE_CLK) \
		-divide_by $::GLOBAL_ddr3_a_p0_pll_div(PLL_C2P_WRITE_CLK) \
		-phase $::GLOBAL_ddr3_a_p0_pll_phase(PLL_C2P_WRITE_CLK) ]	
		
	# Read FIFO read clock
	set local_pll_p2c_read_clock [ ddr3_a_p0_get_or_add_clock_vseries \
		-target $pll_p2c_read_clock \
		-suffix "p2c_read_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_ddr3_a_p0_pll_mult(PLL_P2C_READ_CLK) \
		-divide_by $::GLOBAL_ddr3_a_p0_pll_div(PLL_P2C_READ_CLK) \
		-phase $::GLOBAL_ddr3_a_p0_pll_phase(PLL_P2C_READ_CLK) ]		

	# Half-rate clock
	set local_pll_hr_clock [ ddr3_a_p0_get_or_add_clock_vseries \
		-target $pll_hr_clock \
		-suffix "hr_clk" \
		-source $pll_ref_clock \
		-multiply_by $::GLOBAL_ddr3_a_p0_pll_mult(PLL_HR_CLK) \
		-divide_by $::GLOBAL_ddr3_a_p0_pll_div(PLL_HR_CLK) \
		-phase $::GLOBAL_ddr3_a_p0_pll_phase(PLL_HR_CLK) ]	


	# Pulse-generator used by DQS tracking and shadow registers
	set local_sampling_clock "${inst}|ddr3_a_p0_sampling_clock"
	
	set sampling_clk_mult [expr $::GLOBAL_ddr3_a_p0_pll_mult(PLL_C2P_WRITE_CLK) * $::GLOBAL_ddr3_a_p0_pll_div(PLL_WRITE_CLK)]
	set sampling_clk_div [expr $::GLOBAL_ddr3_a_p0_pll_div(PLL_C2P_WRITE_CLK) * $::GLOBAL_ddr3_a_p0_pll_mult(PLL_WRITE_CLK)]
	set sampling_clk_mult_div_gcd [ddr3_a_p0_gcd $sampling_clk_mult $sampling_clk_div]
	set sampling_clk_mult [expr $sampling_clk_mult / $sampling_clk_mult_div_gcd]
	set sampling_clk_div [expr $sampling_clk_div / $sampling_clk_mult_div_gcd]
	set sampling_clk_phase [expr $::GLOBAL_ddr3_a_p0_pll_phase(PLL_C2P_WRITE_CLK) - $::GLOBAL_ddr3_a_p0_pll_phase(PLL_WRITE_CLK)/2.0]

	create_generated_clock \
		-add \
		-name $local_sampling_clock \
		-source $pll_write_clock \
		-multiply_by $sampling_clk_mult \
		-divide_by $sampling_clk_div \
		-phase $sampling_clk_phase \
		$pins(dqs_enable_regs_pins)

	set pll_c2p_core_clk $pll_hr_clock
	set local_pll_c2p_core_clk $local_pll_hr_clock


	# -------------------- #
	# -                  - #
	# --- SYSTEM CLOCK --- #
	# -                  - #
	# -------------------- #

	# This is the CK clock
	foreach { ck_pin } $ck_pins {
		create_generated_clock -multiply_by 1 -invert -source $pll_write_clock -master_clock "$local_pll_write_clk" $ck_pin -name $ck_pin
		set_clock_uncertainty -to [get_clocks $ck_pin] 0.025
	}

	# This is the CK#clock
	foreach { ckn_pin } $ckn_pins {
		create_generated_clock -multiply_by 1 -source $pll_write_clock -master_clock "$local_pll_write_clk" $ckn_pin -name $ckn_pin
		set_clock_uncertainty -to [get_clocks $ckn_pin] 0.025
	}
	
	# ------------------- #
	# -                 - #
	# --- READ CLOCKS --- #
	# -                 - #
	# ------------------- #

	foreach dqs_in_clock_struct $dqs_in_clocks {
		array set dqs_in_clock $dqs_in_clock_struct
		# This is the DQS clock for Read Capture analysis (micro model)
		create_clock -period $t(CK) -waveform [ list 0 $half_period ] $dqs_in_clock(dqs_pin) -name $dqs_in_clock(dqs_pin)_IN -add

		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -from [ get_clocks $dqs_in_clock(dqs_pin)_IN ] 0
	}

	# -------------------- #
	# -                  - #
	# --- WRITE CLOCKS --- #
	# -                  - #
	# -------------------- #

	# This is the DQS clock for Data Write analysis (micro model)
	foreach dqs_out_clock_struct $dqs_out_clocks {
		array set dqs_out_clock $dqs_out_clock_struct
		create_generated_clock -multiply_by 1 -master_clock [get_clocks $local_pll_write_clk] -source $pll_write_clock $dqs_out_clock(dst) -name $dqs_out_clock(dst)_OUT -add

		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -to [ get_clocks $dqs_out_clock(dst)_OUT ] 0
	}

	# This is the DQS#clock for Data Write analysis (micro model)
	foreach dqsn_out_clock_struct $dqsn_out_clocks {
		array set dqsn_out_clock $dqsn_out_clock_struct
		create_generated_clock -multiply_by 1 -master_clock [get_clocks $local_pll_write_clk] -source $pll_write_clock $dqsn_out_clock(dst) -name $dqsn_out_clock(dst)_OUT -add

		# Clock Uncertainty is accounted for by the ...pathjitter parameters
		set_clock_uncertainty -to [ get_clocks $dqsn_out_clock(dst)_OUT ] 0
	}

	##################
	#                #
	# READ DATA PATH #
	#                #
	##################

	foreach { dqs_pin } $dqs_pins { dq_pins } $q_groups {
		foreach { dq_pin } $dq_pins {
			set_max_delay -from [get_ports $dq_pin] -to $read_capture_ddio 0
			set_min_delay -from [get_ports $dq_pin] -to $read_capture_ddio [expr 0-$half_period]

			# Specifies the maximum delay difference between the DQ pin and the DQS pin:
			set_input_delay -max $final_data_input_max_delay -clock [get_clocks ${dqs_pin}_IN ] [get_ports $dq_pin] -add_delay

			# Specifies the minimum delay difference between the DQ pin and the DQS pin:
			set_input_delay -min $final_data_input_min_delay -clock [get_clocks ${dqs_pin}_IN ] [get_ports $dq_pin] -add_delay
		}
	}

	###################
	#                 #
	# WRITE DATA PATH #
	#                 #
	###################

	foreach { dqs_pin } $dqs_pins { dq_pins } $q_groups {
		foreach { dq_pin } $dq_pins {
			# Specifies the minimum delay difference between the DQS pin and the DQ pins:
			set_output_delay -min $data_output_min_delay -clock [get_clocks ${dqs_pin}_OUT ] [get_ports $dq_pin] -add_delay

			# Specifies the maximum delay difference between the DQS pin and the DQ pins:
			set_output_delay -max $data_output_max_delay -clock [get_clocks ${dqs_pin}_OUT ] [get_ports $dq_pin] -add_delay
		}
	}

	foreach { dqsn_pin } $dqsn_pins { dq_pins } $q_groups {
		foreach { dq_pin } $dq_pins {
			# Specifies the minimum delay difference between the DQS#pin and the DQ pins:
			set_output_delay -min $data_output_min_delay -clock [get_clocks ${dqsn_pin}_OUT ] [get_ports $dq_pin] -add_delay

			# Specifies the maximum delay difference between the DQS#pin and the DQ pins:
			set_output_delay -max $data_output_max_delay -clock [get_clocks ${dqsn_pin}_OUT ] [get_ports $dq_pin] -add_delay
		}
	}

	foreach dqs_out_clock_struct $dqs_out_clocks {
		array set dqs_out_clock $dqs_out_clock_struct

		if { [string length $dqs_out_clock(dm_pin)] > 0 } {
			# Specifies the minimum delay difference between the DQS and the DM pins:
			set_output_delay -min $data_output_min_delay -clock [get_clocks $dqs_out_clock(dst)_OUT ] [get_ports $dqs_out_clock(dm_pin)] -add_delay

			# Specifies the maximum delay difference between the DQS and the DM pins:
			set_output_delay -max $data_output_max_delay -clock [get_clocks $dqs_out_clock(dst)_OUT ] [get_ports $dqs_out_clock(dm_pin)] -add_delay
		}
	}

	foreach dqsn_out_clock_struct $dqsn_out_clocks {
		array set dqsn_out_clock $dqsn_out_clock_struct

		if { [string length $dqsn_out_clock(dm_pin)] > 0 } {
			# Specifies the minimum delay difference between the DQS and the DM pins:
			set_output_delay -min $data_output_min_delay -clock [get_clocks $dqsn_out_clock(dst)_OUT ] [get_ports $dqsn_out_clock(dm_pin)] -add_delay

			# Specifies the maximum delay difference between the DQS and the DM pins:
			set_output_delay -max $data_output_max_delay -clock [get_clocks $dqsn_out_clock(dst)_OUT ] [get_ports $dqsn_out_clock(dm_pin)] -add_delay
		}
	}

	############
	#          #
	# A/C PATH #
	#          #
	############

	foreach { ck_pin } $ck_pins {
		# ac_pins can contain input ports such as mem_err_out_n
		# Loop through each ac pin to make sure we only apply set_output_delay to output ports
		foreach { ac_pin } $ac_pins {
			set ac_port [ get_ports $ac_pin ]
			if {[get_collection_size $ac_port] > 0} {
				if [ get_port_info -is_output_port $ac_port ] {
					# Specifies the minimum delay difference between the DQS pin and the address/control pins:
					set_output_delay -min $ac_min_delay -clock [get_clocks $ck_pin] $ac_port -add_delay

					# Specifies the maximum delay difference between the DQS pin and the address/control pins:
					set_output_delay -max $ac_max_delay -clock [get_clocks $ck_pin] $ac_port -add_delay
				}
			}
		}
	}

	##########################
	#                        #
	# MULTICYCLE CONSTRAINTS #
	#                        #
	##########################
	
	# If the Avalon clock is shifted to help timing, multicycle is needed
	if {$::GLOBAL_ddr3_a_p0_pll_phase(PLL_NIOS_CLK) != 0} {
		set_multicycle_path -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_avl_clock] -end -setup 2
		set_multicycle_path -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_avl_clock] -end -hold 0
		set_multicycle_path -from [get_clocks $local_pll_config_clock] -to [get_clocks $local_pll_avl_clock] -end -setup 2
		set_multicycle_path -from [get_clocks $local_pll_config_clock] -to [get_clocks $local_pll_avl_clock] -end -hold 0
	}

	# If the C2P clock is phase-delayed to help setup for
	# the C2P transfer, we must tell STA to analyze setup
	# using one clock edge later than the default latch edge,
	# via a multicycle value of 2. 
	# For hold, STA automatically picks the right edge in this
	# case, which is one clock edge before the one used for setup.
	if {$::GLOBAL_ddr3_a_p0_pll_phase(PLL_C2P_WRITE_CLK) > 0} {
		set_multicycle_path -to [get_clocks $local_pll_c2p_write_clock] -setup 2
	}

	# If the write clock is phase-adjusted to be earlier than
	# the C2P write clock to help hold, we must tell STA to
	# analyze setup using one clock edge earlier later than
	# the default latch edge, via a multicycle value of 0.
	# For hold, STA automatically picks the right edge in this
	# case, which is one clock edge before the one used for setup.
	# The multiplication factor of 2 below is due to the write clock
	# running twice faster than the c2p write clock.
	set write_clock_phase_offset [ expr round($::GLOBAL_ddr3_a_p0_pll_phase(PLL_WRITE_CLK) - $::GLOBAL_ddr3_a_p0_pll_phase(PLL_C2P_WRITE_CLK) * 2) % 360 ]
	if {$write_clock_phase_offset == 0 || $write_clock_phase_offset > 270} {
		set_multicycle_path -from [get_clocks $local_pll_c2p_write_clock] -to [get_clocks $local_pll_write_clk] -setup 0
	}
	
	set dq_write_clock_phase_offset [ expr round($::GLOBAL_ddr3_a_p0_pll_phase(PLL_MEM_CLK) - $::GLOBAL_ddr3_a_p0_pll_phase(PLL_C2P_WRITE_CLK) * 2) % 360 ]
	if {$dq_write_clock_phase_offset == 0 || $dq_write_clock_phase_offset > 180} {
		set_multicycle_path -from [get_clocks $local_pll_c2p_write_clock] -to [get_clocks $local_pll_dq_write_clk] -setup 0
	}
	

	# Relax timing for the reset signal going into the hard read fifo
	set_multicycle_path -from [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|reset_n_fifo_wraddress[*]] -to [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|*read_buffering[*].uread_read_fifo_hard|*] -setup 2
	set_multicycle_path -from [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|reset_n_fifo_wraddress[*]] -to [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|*read_buffering[*].uread_read_fifo_hard|*] -hold 2

	# Relax timing for the AFI mux select signal. 
	# We don't assert the cal_done signal many cycles after we switch the AFI mux.
	set_multicycle_path -from [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel] -to [remove_from_collection [get_keepers *] [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel]] -setup 3
	set_multicycle_path -from [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel] -to [remove_from_collection [get_keepers *] [get_registers ${prefix}|*s0|*sequencer_phy_mgr_inst|phy_mux_sel]] -hold 2

	# If powerdown feature is enabled, multicycle path from core logic to the CK generator. 
	# The PHY must be idle several cycles before entering and after exiting powerdown mode.
	if { [get_collection_size [get_registers -nowarn ${prefix}|*p0|*umemphy|*uio_pads|*uaddr_cmd_pads|*clock_gen[*].umem_ck_pad|*]] > 0 } {
		set_multicycle_path -to [get_registers ${prefix}|*p0|*umemphy|*uio_pads|*uaddr_cmd_pads|*clock_gen[*].umem_ck_pad|*] -end -setup 4
		set_multicycle_path -to [get_registers ${prefix}|*p0|*umemphy|*uio_pads|*uaddr_cmd_pads|*clock_gen[*].umem_ck_pad|*] -end -hold 4
	}

	#  Sampling register to AVL clock is multicycled because of topology of the PHY
	set_multicycle_path -from [get_clocks $local_sampling_clock] -setup 2
	set_multicycle_path -from [get_clocks $local_sampling_clock] -hold 2


	##########################
	#                        #
	# FALSE PATH CONSTRAINTS #
	#                        #
	##########################

	# Cut calibrated paths between HR reg domain and everything clocked by the x-phase CPS
	set_false_path -from [get_clocks $local_pll_c2p_write_clock] -to [get_fanouts $dq_xphase_cps_pins]
	set_false_path -from [get_clocks $local_pll_c2p_write_clock] -to [get_fanouts $dqs_xphase_cps_pins]
	set_false_path -from [get_keepers $alignment_pins] -to [get_fanouts $dq_xphase_cps_pins]
	set_false_path -from [get_keepers $alignment_pins] -to [get_fanouts $dqs_xphase_cps_pins]
	if { [get_collection_size [get_clocks -nowarn "$local_pll_c2p_write_clock"]] > 0 } {
		set_false_path -from [get_clocks $local_pll_c2p_write_clock] -to [get_keepers $phase_transfer_pins]
	}

	# Cut paths for memory clocks / async resets to avoid unconstrained warnings
	foreach { pin } [concat $dqs_pins $dqsn_pins $ck_pins $ckn_pins $reset_pins] {
		set_false_path -to [get_ports $pin]
	}

	if { ! $synthesis_flow } {
		foreach dqs_in_clock_struct $dqs_in_clocks dqsn_out_clock_struct $dqsn_out_clocks {
			array set dqs_in_clock $dqs_in_clock_struct
			array set dqsn_out_clock $dqsn_out_clock_struct
			
			set_clock_groups -physically_exclusive	-group "$dqs_in_clock(dqs_pin)_IN" -group "$dqs_in_clock(dqs_pin)_OUT $dqsn_out_clock(dst)_OUT"
			
			# Cut paths between fifo reset reg to DQS_IN/DQS_OUT (i.e. write-side of fifo)
			set_false_path -from [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|reset_n_fifo_wraddress[*]] -to [get_clocks $dqs_in_clock(dqs_pin)_OUT]
			set_false_path -from [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|reset_n_fifo_wraddress[*]] -to [get_clocks $dqs_in_clock(dqs_pin)_IN]
			set_false_path -from [get_registers ${prefix}|*p0|*umemphy|*uread_datapath|reset_n_fifo_wraddress[*]] -to [get_clocks $dqsn_out_clock(dst)_OUT]	

			# Cut paths between DQS_OUT and Read Capture Registers
			set_false_path -from [get_clocks $dqs_in_clock(dqs_pin)_OUT] -to [get_registers $fifo_wrdata_reg]
			set_false_path -from [get_clocks $dqs_in_clock(dqs_pin)_OUT] -to [get_registers $fifo_wrload_reg]
			set_false_path -from [get_clocks $dqs_in_clock(dqs_pin)_OUT] -to [get_registers $fifo_wraddress_reg]

			# Cut paths between DQS_OUT and Read Capture Registers
			set_false_path -from [get_clocks $dqsn_out_clock(dst)_OUT] -to [get_registers $fifo_wrdata_reg]
			set_false_path -from [get_clocks $dqsn_out_clock(dst)_OUT] -to [get_registers $fifo_wrload_reg]
			set_false_path -from [get_clocks $dqsn_out_clock(dst)_OUT] -to [get_registers $fifo_wraddress_reg]
			
			set_false_path -from [get_clocks $local_pll_write_clk] -to [get_clocks $dqs_in_clock(dqs_pin)_IN]
		}

		# Cut paths between AFI Clock and Read Capture Registers
		set_false_path -from [get_clocks $local_pll_afi_clk] -to [get_registers $fifo_wrdata_reg]
		set_false_path -from [get_clocks $local_pll_afi_clk] -to [get_registers $fifo_wrload_reg]
		set_false_path -from [get_clocks $local_pll_afi_clk] -to [get_registers $fifo_wraddress_reg]
		
		# Cut paths between read and write side of read fifo
		set_false_path -from [get_registers $fifo_wrload_reg] -to [get_registers $fifo_rdload_reg]
	}



	# The following registers serve as anchors for the pin_map.tcl
	# script and are not used by the IP during memory operation

	# Cut internal calibrated paths
	set_false_path -to $pins(dqs_enable_regs_pins)

	# Add clock (DQS) uncertainty applied from the DDIO registers to Read FIFO
	set capture_reg ${prefix}*capture_reg*
	set_max_delay -from [get_registers $capture_reg] -to $fifo_wrdata_reg -0.05
	set_min_delay -from [get_registers $capture_reg] -to $fifo_wrdata_reg [ ddr3_a_p0_round_3dp [expr -$t(CK) + 0.2 ]]

	#  Cut path to sampling register, calibrated by the PHY
	set_false_path -to [get_clocks $local_sampling_clock]

	# Relax paths to asynchronous reset inputs of M20K RAM blocks
	set controller_rpath_m20k_rst_pins [get_pins -nowarn -compatibility *${inst}|*c0|ng0|alt_mem_ddrx_controller_top_inst|controller_inst|rdata_path_inst|gen_rdata_return_inorder.in_order_buffer_inst|altsyncram_component|auto_generated|ram_block*|clr0]
	set controller_wpath_m20k_rst_pins [get_pins -nowarn -compatibility *${inst}|*c0|ng0|alt_mem_ddrx_controller_top_inst|controller_inst|wdata_path_inst|wdata_buffer_per_dwidth_ratio[*].wdata_buffer_per_dqs_group[*].wdatap_buffer_*_inst|altsyncram_component|auto_generated|ram_block*|clr0]
    if {[get_collection_size $controller_rpath_m20k_rst_pins] > 0 &&
        [get_collection_size $controller_wpath_m20k_rst_pins] > 0} {
 	set_multicycle_path -end -setup -to $controller_rpath_m20k_rst_pins 3
	set_multicycle_path -end -setup -to $controller_wpath_m20k_rst_pins 3
	set_multicycle_path -end -hold  -to $controller_rpath_m20k_rst_pins 2
	set_multicycle_path -end -hold  -to $controller_wpath_m20k_rst_pins 2
    }

    set reset_source [get_registers -nowarn *${inst}|*ureset|ureset_ctl_reset_clk|reset_reg[*]]
    set encoder_decoder_registers [get_registers -nowarn *${inst}|c0|ng0|alt_mem_ddrx_controller_top_inst|controller_inst|ecc_encoder_decoder_wrapper_inst|*]
    if {[get_collection_size $reset_source] > 0 &&
        [get_collection_size $encoder_decoder_registers] > 0} {
        set_multicycle_path 3 -from $reset_source -to $encoder_decoder_registers -end -setup 
        set_multicycle_path 2 -from $reset_source -to $encoder_decoder_registers -end -hold
    }
    
    # ------------------------------ #
	# -                            - #
	# --- FITTER OVERCONSTRAINTS --- #
	# -                            - #
	# ------------------------------ #
	if {$fit_flow} {
		
		

		if {[string compare -nocase $pll_avl_clock $pll_afi_clock] != 0} {
			set_clock_uncertainty -from [get_clocks $local_pll_avl_clock] -to [get_clocks $local_pll_afi_clk] -add -hold 0.150
			set_clock_uncertainty -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_avl_clock] -add -hold 0.150
		}
		set_clock_uncertainty -from [get_clocks $local_pll_avl_clock] -to [get_clocks $local_pll_config_clock] -add -hold 0.150

		set_clock_uncertainty -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_p2c_read_clock] -add -hold 0.150
		set_clock_uncertainty -from [get_clocks $local_pll_p2c_read_clock] -to [get_clocks $local_pll_afi_clk] -add -hold 0.150
		set_clock_uncertainty -from [get_clocks $local_pll_afi_clk] -to [get_clocks $local_pll_hr_clock] -add -hold 0.150
	}
	
	# -------------------------------- #
	# -                              - #
	# --- TIMING MODEL ADJUSTMENTS --- #
	# -                              - #
	# -------------------------------- #
	set_clock_uncertainty -add -hold -from [get_clocks $local_pll_c2p_write_clock] -to [get_clocks $local_pll_write_clk] -0.200
	set_clock_uncertainty -add -setup -from [get_clocks $local_pll_c2p_write_clock] -to [get_clocks $local_pll_write_clk] -0.225
	
	set_clock_uncertainty -add -hold -from [get_clocks $local_pll_c2p_write_clock] -to [get_clocks $local_pll_dq_write_clk] -0.200
	set_clock_uncertainty -add -setup -from [get_clocks $local_pll_c2p_write_clock] -to [get_clocks $local_pll_dq_write_clk] -0.225
}

if {(($::quartus(nameofexecutable) ne "quartus_fit") && ($::quartus(nameofexecutable) ne "quartus_map"))} {
	set dqs_clocks [ddr3_a_p0_get_all_instances_dqs_pins ddr3_a_p0_ddr_db]
	# Leave clocks active when in debug mode
	if {[llength $dqs_clocks] > 0 && !$debug} {
		post_sdc_message info "Setting DQS clocks as inactive; use Report DDR to timing analyze DQS clocks"
		set_active_clocks [remove_from_collection [get_active_clocks] [get_clocks $dqs_clocks]]
	}
}

######################
#                    #
# REPORT DDR COMMAND #
#                    #
######################

add_ddr_report_command "source [list [file join [file dirname [info script]] ${::GLOBAL_ddr3_a_p0_corename}_report_timing.tcl]]"

