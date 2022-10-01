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
# This file specifies the timing properties of the memory device and
# of the memory interface


package require ::quartus::ddr_timing_model

###################
#                 #
# TIMING SETTINGS #
#                 #
###################

# Interface Clock Period
set t(CYC) 1.818

# Reference Clock Period
set t(refCK) 20.0

###########################################################
# Memory timing parameters. 

# A/C Setup/Hold
# NOTE:
#    t(SC) = t(SA)
#    t(HC) = t(HA)
set t(SA) [expr { 230 / 1000.0 }]
set t(HA) [expr { 230 / 1000.0 }]

# Data Setup/Hold
set t(SD) [expr { 180 / 1000.0 }]
set t(HD) [expr { 180 / 1000.0 }]

# K/Kn clock rise to Data Valid
set t(CQD) [expr { 150 / 1000.0 }]
# Data Output Hold after Output K/Kn Clock
set t(CQDOH) [expr { -150 / 1000.0 }]
# CQ High to CQn High (rising edge to rising edge)
set t(CQHCQnH) [expr { 655 / 1000.0 }]
# K High to Kn High (rising edge to rising edge)
set t(KHKnH) [expr { 770 / 1000.0 }]

# QDRII/II+ internal jitter
set t(INTERNAL_JITTER) [expr { 250 / 1000.0 }]

# FPGA Duty Cycle Distortion
set t(DCD) [expr { 0.0 / 1000.0 }]

#####################
# FPGA specifications
#####################

# Sequencer VCALIB width. Determins multicycle length
set vcalib_count_width 2

set fpga(tPLL_PSERR) [expr { 0.0 / 1000.0 }]
set fpga(tPLL_JITTER) [expr { 0.0 / 1000.0 }]

# Systematic DCD in the Write Levelling delay chains
set t(WL_DCD) [expr [get_micro_node_delay -micro WL_DCD -parameters {IO VPAD} -in_fitter]/1000.0]
# Non-systematic DC jitter in the Write Levelling delay chains
set t(WL_DCJ) [expr [get_micro_node_delay -micro WL_DC_JITTER -parameters {IO VPAD} -in_fitter]/1000.0]
# Phase shift error in the Write Levelling delay chains between DQ and DQS
set t(WL_PSE) [expr [get_micro_node_delay -micro WL_PSERR -parameters {IO VPAD} -in_fitter]/1000.0]
# Jitter in the Write Levelling delay chains
set t(WL_JITTER) [expr [get_micro_node_delay -micro WL_JITTER -parameters {IO PHY_SHORT} -in_fitter]/1000.0]
set t(WL_JITTER_DIVISION) [expr [get_micro_node_delay -micro WL_JITTER_DIVISION -parameters {IO PHY_SHORT} -in_fitter]/100.0]

###############
# SSN Info
###############

set SSN(pushout_o) [expr {[get_micro_node_delay -micro SSO -parameters [list IO DQDQSABSOLUTE NONLEVELED MAX] -in_fitter]/1000.0}]
set SSN(pullin_o)  [expr {[get_micro_node_delay -micro SSO -parameters [list IO DQDQSABSOLUTE NONLEVELED MIN] -in_fitter]/-1000.0}]
set SSN(pushout_i) [expr {[get_micro_node_delay -micro SSI -parameters [list IO DQDQSABSOLUTE NONLEVELED MAX] -in_fitter]/1000.0}]
set SSN(pullin_i)  [expr {[get_micro_node_delay -micro SSI -parameters [list IO DQDQSABSOLUTE NONLEVELED MIN] -in_fitter]/-1000.0}]
set SSN(rel_pushout_o) [expr {[get_micro_node_delay -micro SSO -parameters [list IO DQDQSRELATIVE NONLEVELED MAX] -in_fitter]/1000.0}]
set SSN(rel_pullin_o)  [expr {[get_micro_node_delay -micro SSO -parameters [list IO DQDQSRELATIVE NONLEVELED MIN] -in_fitter]/-1000.0}]
set SSN(rel_pushout_i) [expr {[get_micro_node_delay -micro SSI -parameters [list IO DQDQSRELATIVE NONLEVELED MAX] -in_fitter]/1000.0}]
set SSN(rel_pullin_i)  [expr {[get_micro_node_delay -micro SSI -parameters [list IO DQDQSRELATIVE NONLEVELED MIN] -in_fitter]/-1000.0}]

###############
# Board Effects
###############

# Intersymbol Interference
set ISI(addresscmd_setup) [expr { 0 / 1000.0 }]
set ISI(addresscmd_hold) [expr { 0 / 1000.0 }]
set ISI(DQ) [expr { 0 / 1000.0 }]
set ISI(DQS) [expr { 0 / 1000.0 }]
set ISI(READ_DQ) [expr { 0.0 / 1000.0 }]
set ISI(READ_DQS) [expr { 0.0 / 1000.0 }]


# Board skews
set board(tpd_inter_DIMM) [expr { 0 / 1000.0 }]
set board(intra_K_group_skew) [expr { 23 / 1000.0 }]
set board(intra_CQ_group_skew) [expr { 20 / 1000.0 }]
set board(inter_DQS_group_skew) [expr { 20 / 1000.0 }]
set board(addresscmd_CK_skew) [expr { 8 / 1000.0 }]
set board(data_K_skew)   [expr { 10 / 1000.0 }]
set board(data_CQ_skew)  [expr { 8 / 1000.0 }]
set board(intra_addr_ctrl_skew) [expr { 36 / 1000.0 }]

