// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// Verilog RBC parameter resolution wrapper for stratixv_hssi_8g_pcs_aggregate
//

`timescale 1 ns / 1 ps

module sv_hssi_8g_pcs_aggregate_rbc #(
	// unconstrained parameters
	parameter data_agg_bonding = "<auto_single>",	// agg_disable, x2_cmu1, x2_lc1, x4_cmu1, x4_cmu2, x4_cmu3, x4_lc1, x4_lc2, x4_lc3

	// extra unconstrained parameters found in atom map
	parameter avmm_group_channel_index = 0,	// 0..2
	parameter dskw_mnumber_data = 4'b100,	// 4
	parameter use_default_base_address = "true",	// false, true
	parameter user_base_address = 0,	// 0..2047

	// constrained parameters
	parameter prot_mode_tx = "<auto_single>",	// basic_tx, cpri_rx_tx_tx, cpri_tx, disabled_prot_mode_tx, gige_tx, pipe_g1_tx, pipe_g2_tx, pipe_g3_tx, srio_2p1_tx, test_tx, xaui_tx
	parameter pcs_dw_datapath = "<auto_single>",	// dw_data_path, sw_data_path
	parameter xaui_sm_operation = "<auto_single>",	// dis_xaui_sm, en_xaui_legacy_sm, en_xaui_sm
	parameter dskw_sm_operation = "<auto_single>",	// dskw_srio_sm, dskw_xaui_sm
	parameter dskw_control = "<auto_single>",	// dskw_read_control, dskw_write_control
	parameter refclkdig_sel = "<auto_single>",	// dis_refclk_dig_sel, en_refclk_dig_sel
	parameter agg_pwdn = "<auto_single>"	// dis_agg_pwdn, en_agg_pwdn
) (
	// ports
	output wire   [15:0]	aggtestbusch0,
	output wire   [15:0]	aggtestbusch1,
	output wire   [15:0]	aggtestbusch2,
	input  wire    [1:0]	aligndetsyncbotch2,
	input  wire    [1:0]	aligndetsyncch0,
	input  wire    [1:0]	aligndetsyncch1,
	input  wire    [1:0]	aligndetsyncch2,
	input  wire    [1:0]	aligndetsynctopch0,
	input  wire    [1:0]	aligndetsynctopch1,
	output wire         	alignstatusbotch2,
	output wire         	alignstatusch0,
	output wire         	alignstatusch1,
	output wire         	alignstatusch2,
	output wire         	alignstatussync0botch2,
	output wire         	alignstatussync0ch0,
	output wire         	alignstatussync0ch1,
	output wire         	alignstatussync0ch2,
	output wire         	alignstatussync0topch0,
	output wire         	alignstatussync0topch1,
	input  wire         	alignstatussyncbotch2,
	input  wire         	alignstatussyncch0,
	input  wire         	alignstatussyncch1,
	input  wire         	alignstatussyncch2,
	input  wire         	alignstatussynctopch0,
	input  wire         	alignstatussynctopch1,
	output wire         	alignstatustopch0,
	output wire         	alignstatustopch1,
	output wire         	cgcomprddallbotch2,
	output wire         	cgcomprddallch0,
	output wire         	cgcomprddallch1,
	output wire         	cgcomprddallch2,
	output wire         	cgcomprddalltopch0,
	output wire         	cgcomprddalltopch1,
	input  wire    [1:0]	cgcomprddinbotch2,
	input  wire    [1:0]	cgcomprddinch0,
	input  wire    [1:0]	cgcomprddinch1,
	input  wire    [1:0]	cgcomprddinch2,
	input  wire    [1:0]	cgcomprddintopch0,
	input  wire    [1:0]	cgcomprddintopch1,
	output wire         	cgcompwrallbotch2,
	output wire         	cgcompwrallch0,
	output wire         	cgcompwrallch1,
	output wire         	cgcompwrallch2,
	output wire         	cgcompwralltopch0,
	output wire         	cgcompwralltopch1,
	input  wire    [1:0]	cgcompwrinbotch2,
	input  wire    [1:0]	cgcompwrinch0,
	input  wire    [1:0]	cgcompwrinch1,
	input  wire    [1:0]	cgcompwrinch2,
	input  wire    [1:0]	cgcompwrintopch0,
	input  wire    [1:0]	cgcompwrintopch1,
	input  wire         	decctlbotch2,
	input  wire         	decctlch0,
	input  wire         	decctlch1,
	input  wire         	decctlch2,
	input  wire         	decctltopch0,
	input  wire         	decctltopch1,
	input  wire    [7:0]	decdatabotch2,
	input  wire    [7:0]	decdatach0,
	input  wire    [7:0]	decdatach1,
	input  wire    [7:0]	decdatach2,
	input  wire    [7:0]	decdatatopch0,
	input  wire    [7:0]	decdatatopch1,
	input  wire         	decdatavalidbotch2,
	input  wire         	decdatavalidch0,
	input  wire         	decdatavalidch1,
	input  wire         	decdatavalidch2,
	input  wire         	decdatavalidtopch0,
	input  wire         	decdatavalidtopch1,
	input  wire         	dedicatedaggscaninch1,
	output wire         	dedicatedaggscanoutch0tieoff,
	output wire         	dedicatedaggscanoutch1,
	output wire         	dedicatedaggscanoutch2tieoff,
	output wire         	delcondmet0botch2,
	output wire         	delcondmet0ch0,
	output wire         	delcondmet0ch1,
	output wire         	delcondmet0ch2,
	output wire         	delcondmet0topch0,
	output wire         	delcondmet0topch1,
	input  wire         	delcondmetinbotch2,
	input  wire         	delcondmetinch0,
	input  wire         	delcondmetinch1,
	input  wire         	delcondmetinch2,
	input  wire         	delcondmetintopch0,
	input  wire         	delcondmetintopch1,
	input  wire   [63:0]	dprioagg,
	output wire         	endskwqdbotch2,
	output wire         	endskwqdch0,
	output wire         	endskwqdch1,
	output wire         	endskwqdch2,
	output wire         	endskwqdtopch0,
	output wire         	endskwqdtopch1,
	output wire         	endskwrdptrsbotch2,
	output wire         	endskwrdptrsch0,
	output wire         	endskwrdptrsch1,
	output wire         	endskwrdptrsch2,
	output wire         	endskwrdptrstopch0,
	output wire         	endskwrdptrstopch1,
	output wire         	fifoovr0botch2,
	output wire         	fifoovr0ch0,
	output wire         	fifoovr0ch1,
	output wire         	fifoovr0ch2,
	output wire         	fifoovr0topch0,
	output wire         	fifoovr0topch1,
	input  wire         	fifoovrinbotch2,
	input  wire         	fifoovrinch0,
	input  wire         	fifoovrinch1,
	input  wire         	fifoovrinch2,
	input  wire         	fifoovrintopch0,
	input  wire         	fifoovrintopch1,
	input  wire         	fifordinbotch2,
	input  wire         	fifordinch0,
	input  wire         	fifordinch1,
	input  wire         	fifordinch2,
	input  wire         	fifordintopch0,
	input  wire         	fifordintopch1,
	output wire         	fifordoutcomp0botch2,
	output wire         	fifordoutcomp0ch0,
	output wire         	fifordoutcomp0ch1,
	output wire         	fifordoutcomp0ch2,
	output wire         	fifordoutcomp0topch0,
	output wire         	fifordoutcomp0topch1,
	output wire         	fiforstrdqdbotch2,
	output wire         	fiforstrdqdch0,
	output wire         	fiforstrdqdch1,
	output wire         	fiforstrdqdch2,
	output wire         	fiforstrdqdtopch0,
	output wire         	fiforstrdqdtopch1,
	output wire         	insertincomplete0botch2,
	output wire         	insertincomplete0ch0,
	output wire         	insertincomplete0ch1,
	output wire         	insertincomplete0ch2,
	output wire         	insertincomplete0topch0,
	output wire         	insertincomplete0topch1,
	input  wire         	insertincompleteinbotch2,
	input  wire         	insertincompleteinch0,
	input  wire         	insertincompleteinch1,
	input  wire         	insertincompleteinch2,
	input  wire         	insertincompleteintopch0,
	input  wire         	insertincompleteintopch1,
	output wire         	latencycomp0botch2,
	output wire         	latencycomp0ch0,
	output wire         	latencycomp0ch1,
	output wire         	latencycomp0ch2,
	output wire         	latencycomp0topch0,
	output wire         	latencycomp0topch1,
	input  wire         	latencycompinbotch2,
	input  wire         	latencycompinch0,
	input  wire         	latencycompinch1,
	input  wire         	latencycompinch2,
	input  wire         	latencycompintopch0,
	input  wire         	latencycompintopch1,
	input  wire         	rcvdclkch0,
	input  wire         	rcvdclkch1,
	output wire         	rcvdclkout,
	output wire         	rcvdclkoutbot,
	output wire         	rcvdclkouttop,
	input  wire    [1:0]	rdalignbotch2,
	input  wire    [1:0]	rdalignch0,
	input  wire    [1:0]	rdalignch1,
	input  wire    [1:0]	rdalignch2,
	input  wire    [1:0]	rdaligntopch0,
	input  wire    [1:0]	rdaligntopch1,
	input  wire         	rdenablesyncbotch2,
	input  wire         	rdenablesyncch0,
	input  wire         	rdenablesyncch1,
	input  wire         	rdenablesyncch2,
	input  wire         	rdenablesynctopch0,
	input  wire         	rdenablesynctopch1,
	input  wire         	refclkdig,
	input  wire    [1:0]	runningdispbotch2,
	input  wire    [1:0]	runningdispch0,
	input  wire    [1:0]	runningdispch1,
	input  wire    [1:0]	runningdispch2,
	input  wire    [1:0]	runningdisptopch0,
	input  wire    [1:0]	runningdisptopch1,
	output wire         	rxctlrsbotch2,
	output wire         	rxctlrsch0,
	output wire         	rxctlrsch1,
	output wire         	rxctlrsch2,
	output wire         	rxctlrstopch0,
	output wire         	rxctlrstopch1,
	output wire    [7:0]	rxdatarsbotch2,
	output wire    [7:0]	rxdatarsch0,
	output wire    [7:0]	rxdatarsch1,
	output wire    [7:0]	rxdatarsch2,
	output wire    [7:0]	rxdatarstopch0,
	output wire    [7:0]	rxdatarstopch1,
	input  wire         	rxpcsrstn,
	input  wire         	scanmoden,
	input  wire         	scanshiftn,
	input  wire         	syncstatusbotch2,
	input  wire         	syncstatusch0,
	input  wire         	syncstatusch1,
	input  wire         	syncstatusch2,
	input  wire         	syncstatustopch0,
	input  wire         	syncstatustopch1,
	input  wire         	txctltcbotch2,
	input  wire         	txctltcch0,
	input  wire         	txctltcch1,
	input  wire         	txctltcch2,
	input  wire         	txctltctopch0,
	input  wire         	txctltctopch1,
	output wire         	txctltsbotch2,
	output wire         	txctltsch0,
	output wire         	txctltsch1,
	output wire         	txctltsch2,
	output wire         	txctltstopch0,
	output wire         	txctltstopch1,
	input  wire    [7:0]	txdatatcbotch2,
	input  wire    [7:0]	txdatatcch0,
	input  wire    [7:0]	txdatatcch1,
	input  wire    [7:0]	txdatatcch2,
	input  wire    [7:0]	txdatatctopch0,
	input  wire    [7:0]	txdatatctopch1,
	output wire    [7:0]	txdatatsbotch2,
	output wire    [7:0]	txdatatsch0,
	output wire    [7:0]	txdatatsch1,
	output wire    [7:0]	txdatatsch2,
	output wire    [7:0]	txdatatstopch0,
	output wire    [7:0]	txdatatstopch1,
	input  wire         	txpcsrstn,
	input  wire         	txpmaclk
);
	import altera_xcvr_functions::*;

	// data_agg_bonding external parameter (no RBC)
	localparam rbc_all_data_agg_bonding = "(agg_disable,x2_cmu1,x2_lc1,x4_cmu1,x4_cmu2,x4_cmu3,x4_lc1,x4_lc2,x4_lc3)";
	localparam rbc_any_data_agg_bonding = "agg_disable";
	localparam fnl_data_agg_bonding = (data_agg_bonding == "<auto_any>" || data_agg_bonding == "<auto_single>") ? rbc_any_data_agg_bonding : data_agg_bonding;

	// use_default_base_address external parameter (no RBC)
	localparam rbc_all_use_default_base_address = "(false,true)";
	localparam rbc_any_use_default_base_address = "true";
	localparam fnl_use_default_base_address = (use_default_base_address == "<auto_any>" || use_default_base_address == "<auto_single>") ? rbc_any_use_default_base_address : use_default_base_address;

	// prot_mode_tx, RBC-validated
	localparam rbc_all_prot_mode_tx = (fnl_data_agg_bonding == "x4_cmu1" ||
       fnl_data_agg_bonding == "x4_cmu2" || 
       fnl_data_agg_bonding == "x4_cmu3" || 
       fnl_data_agg_bonding == "x4_lc1" || 
       fnl_data_agg_bonding == "x4_lc2" ||
       fnl_data_agg_bonding == "x4_lc3") ? ("(xaui_tx,srio_2p1_tx)")
		 : (fnl_data_agg_bonding == "x2_cmu1" || fnl_data_agg_bonding == "x2_lc1") ? ("srio_2p1_tx") : "disabled_prot_mode_tx";
	localparam rbc_any_prot_mode_tx = (fnl_data_agg_bonding == "x4_cmu1" ||
       fnl_data_agg_bonding == "x4_cmu2" || 
       fnl_data_agg_bonding == "x4_cmu3" || 
       fnl_data_agg_bonding == "x4_lc1" || 
       fnl_data_agg_bonding == "x4_lc2" ||
       fnl_data_agg_bonding == "x4_lc3") ? ("xaui_tx")
		 : (fnl_data_agg_bonding == "x2_cmu1" || fnl_data_agg_bonding == "x2_lc1") ? ("srio_2p1_tx") : "disabled_prot_mode_tx";
	localparam fnl_prot_mode_tx = (prot_mode_tx == "<auto_any>" || prot_mode_tx == "<auto_single>") ? rbc_any_prot_mode_tx : prot_mode_tx;

	// pcs_dw_datapath, RBC-validated
	localparam rbc_all_pcs_dw_datapath = (fnl_prot_mode_tx == "srio_2p1_tx") ? ("dw_data_path") : "sw_data_path";
	localparam rbc_any_pcs_dw_datapath = (fnl_prot_mode_tx == "srio_2p1_tx") ? ("dw_data_path") : "sw_data_path";
	localparam fnl_pcs_dw_datapath = (pcs_dw_datapath == "<auto_any>" || pcs_dw_datapath == "<auto_single>") ? rbc_any_pcs_dw_datapath : pcs_dw_datapath;

	// xaui_sm_operation, RBC-validated
	localparam rbc_all_xaui_sm_operation = (fnl_prot_mode_tx == "xaui_tx") ? ("en_xaui_sm") : "dis_xaui_sm";
	localparam rbc_any_xaui_sm_operation = (fnl_prot_mode_tx == "xaui_tx") ? ("en_xaui_sm") : "dis_xaui_sm";
	localparam fnl_xaui_sm_operation = (xaui_sm_operation == "<auto_any>" || xaui_sm_operation == "<auto_single>") ? rbc_any_xaui_sm_operation : xaui_sm_operation;

	// dskw_sm_operation, RBC-validated
	localparam rbc_all_dskw_sm_operation = (fnl_prot_mode_tx == "srio_2p1_tx") ? ("dskw_srio_sm") : "dskw_xaui_sm";
	localparam rbc_any_dskw_sm_operation = (fnl_prot_mode_tx == "srio_2p1_tx") ? ("dskw_srio_sm") : "dskw_xaui_sm";
	localparam fnl_dskw_sm_operation = (dskw_sm_operation == "<auto_any>" || dskw_sm_operation == "<auto_single>") ? rbc_any_dskw_sm_operation : dskw_sm_operation;

	// dskw_control, RBC-validated
	localparam rbc_all_dskw_control = (fnl_prot_mode_tx == "srio_2p1_tx") ? ("dskw_read_control") : "dskw_write_control";
	localparam rbc_any_dskw_control = (fnl_prot_mode_tx == "srio_2p1_tx") ? ("dskw_read_control") : "dskw_write_control";
	localparam fnl_dskw_control = (dskw_control == "<auto_any>" || dskw_control == "<auto_single>") ? rbc_any_dskw_control : dskw_control;

	// refclkdig_sel, RBC-validated
	localparam rbc_all_refclkdig_sel = "dis_refclk_dig_sel";
	localparam rbc_any_refclkdig_sel = "dis_refclk_dig_sel";
	localparam fnl_refclkdig_sel = (refclkdig_sel == "<auto_any>" || refclkdig_sel == "<auto_single>") ? rbc_any_refclkdig_sel : refclkdig_sel;

	// agg_pwdn, RBC-validated
	localparam rbc_all_agg_pwdn = (fnl_data_agg_bonding == "agg_disable") ? ("en_agg_pwdn") : "dis_agg_pwdn";
	localparam rbc_any_agg_pwdn = (fnl_data_agg_bonding == "agg_disable") ? ("en_agg_pwdn") : "dis_agg_pwdn";
	localparam fnl_agg_pwdn = (agg_pwdn == "<auto_any>" || agg_pwdn == "<auto_single>") ? rbc_any_agg_pwdn : agg_pwdn;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("data_agg_bonding = orig: '%s', any:'%s', all:'%s', final: '%s'", data_agg_bonding, rbc_any_data_agg_bonding, rbc_all_data_agg_bonding, fnl_data_agg_bonding);
		if (!is_in_legal_set(data_agg_bonding, rbc_all_data_agg_bonding)) begin
			$display("Critical Warning: parameter 'data_agg_bonding' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", data_agg_bonding, rbc_all_data_agg_bonding, fnl_data_agg_bonding);
		end
		//$display("use_default_base_address = orig: '%s', any:'%s', all:'%s', final: '%s'", use_default_base_address, rbc_any_use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		if (!is_in_legal_set(use_default_base_address, rbc_all_use_default_base_address)) begin
			$display("Critical Warning: parameter 'use_default_base_address' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		end
		//$display("prot_mode_tx = orig: '%s', any:'%s', all:'%s', final: '%s'", prot_mode_tx, rbc_any_prot_mode_tx, rbc_all_prot_mode_tx, fnl_prot_mode_tx);
		if (!is_in_legal_set(prot_mode_tx, rbc_all_prot_mode_tx)) begin
			$display("Critical Warning: parameter 'prot_mode_tx' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", prot_mode_tx, rbc_all_prot_mode_tx, fnl_prot_mode_tx);
		end
		//$display("pcs_dw_datapath = orig: '%s', any:'%s', all:'%s', final: '%s'", pcs_dw_datapath, rbc_any_pcs_dw_datapath, rbc_all_pcs_dw_datapath, fnl_pcs_dw_datapath);
		if (!is_in_legal_set(pcs_dw_datapath, rbc_all_pcs_dw_datapath)) begin
			$display("Critical Warning: parameter 'pcs_dw_datapath' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pcs_dw_datapath, rbc_all_pcs_dw_datapath, fnl_pcs_dw_datapath);
		end
		//$display("xaui_sm_operation = orig: '%s', any:'%s', all:'%s', final: '%s'", xaui_sm_operation, rbc_any_xaui_sm_operation, rbc_all_xaui_sm_operation, fnl_xaui_sm_operation);
		if (!is_in_legal_set(xaui_sm_operation, rbc_all_xaui_sm_operation)) begin
			$display("Critical Warning: parameter 'xaui_sm_operation' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", xaui_sm_operation, rbc_all_xaui_sm_operation, fnl_xaui_sm_operation);
		end
		//$display("dskw_sm_operation = orig: '%s', any:'%s', all:'%s', final: '%s'", dskw_sm_operation, rbc_any_dskw_sm_operation, rbc_all_dskw_sm_operation, fnl_dskw_sm_operation);
		if (!is_in_legal_set(dskw_sm_operation, rbc_all_dskw_sm_operation)) begin
			$display("Critical Warning: parameter 'dskw_sm_operation' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dskw_sm_operation, rbc_all_dskw_sm_operation, fnl_dskw_sm_operation);
		end
		//$display("dskw_control = orig: '%s', any:'%s', all:'%s', final: '%s'", dskw_control, rbc_any_dskw_control, rbc_all_dskw_control, fnl_dskw_control);
		if (!is_in_legal_set(dskw_control, rbc_all_dskw_control)) begin
			$display("Critical Warning: parameter 'dskw_control' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dskw_control, rbc_all_dskw_control, fnl_dskw_control);
		end
		//$display("refclkdig_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", refclkdig_sel, rbc_any_refclkdig_sel, rbc_all_refclkdig_sel, fnl_refclkdig_sel);
		if (!is_in_legal_set(refclkdig_sel, rbc_all_refclkdig_sel)) begin
			$display("Critical Warning: parameter 'refclkdig_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", refclkdig_sel, rbc_all_refclkdig_sel, fnl_refclkdig_sel);
		end
		//$display("agg_pwdn = orig: '%s', any:'%s', all:'%s', final: '%s'", agg_pwdn, rbc_any_agg_pwdn, rbc_all_agg_pwdn, fnl_agg_pwdn);
		if (!is_in_legal_set(agg_pwdn, rbc_all_agg_pwdn)) begin
			$display("Critical Warning: parameter 'agg_pwdn' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", agg_pwdn, rbc_all_agg_pwdn, fnl_agg_pwdn);
		end
	end

	stratixv_hssi_8g_pcs_aggregate #(
		.data_agg_bonding(fnl_data_agg_bonding),
		.avmm_group_channel_index(avmm_group_channel_index),
		.dskw_mnumber_data(dskw_mnumber_data),
		.use_default_base_address(fnl_use_default_base_address),
		.user_base_address(user_base_address),
		.prot_mode_tx(fnl_prot_mode_tx),
		.pcs_dw_datapath(fnl_pcs_dw_datapath),
		.xaui_sm_operation(fnl_xaui_sm_operation),
		.dskw_sm_operation(fnl_dskw_sm_operation),
		.dskw_control(fnl_dskw_control),
		.refclkdig_sel(fnl_refclkdig_sel),
		.agg_pwdn(fnl_agg_pwdn)
	) wys (
		// ports
		.aggtestbusch0(aggtestbusch0),
		.aggtestbusch1(aggtestbusch1),
		.aggtestbusch2(aggtestbusch2),
		.aligndetsyncbotch2(aligndetsyncbotch2),
		.aligndetsyncch0(aligndetsyncch0),
		.aligndetsyncch1(aligndetsyncch1),
		.aligndetsyncch2(aligndetsyncch2),
		.aligndetsynctopch0(aligndetsynctopch0),
		.aligndetsynctopch1(aligndetsynctopch1),
		.alignstatusbotch2(alignstatusbotch2),
		.alignstatusch0(alignstatusch0),
		.alignstatusch1(alignstatusch1),
		.alignstatusch2(alignstatusch2),
		.alignstatussync0botch2(alignstatussync0botch2),
		.alignstatussync0ch0(alignstatussync0ch0),
		.alignstatussync0ch1(alignstatussync0ch1),
		.alignstatussync0ch2(alignstatussync0ch2),
		.alignstatussync0topch0(alignstatussync0topch0),
		.alignstatussync0topch1(alignstatussync0topch1),
		.alignstatussyncbotch2(alignstatussyncbotch2),
		.alignstatussyncch0(alignstatussyncch0),
		.alignstatussyncch1(alignstatussyncch1),
		.alignstatussyncch2(alignstatussyncch2),
		.alignstatussynctopch0(alignstatussynctopch0),
		.alignstatussynctopch1(alignstatussynctopch1),
		.alignstatustopch0(alignstatustopch0),
		.alignstatustopch1(alignstatustopch1),
		.cgcomprddallbotch2(cgcomprddallbotch2),
		.cgcomprddallch0(cgcomprddallch0),
		.cgcomprddallch1(cgcomprddallch1),
		.cgcomprddallch2(cgcomprddallch2),
		.cgcomprddalltopch0(cgcomprddalltopch0),
		.cgcomprddalltopch1(cgcomprddalltopch1),
		.cgcomprddinbotch2(cgcomprddinbotch2),
		.cgcomprddinch0(cgcomprddinch0),
		.cgcomprddinch1(cgcomprddinch1),
		.cgcomprddinch2(cgcomprddinch2),
		.cgcomprddintopch0(cgcomprddintopch0),
		.cgcomprddintopch1(cgcomprddintopch1),
		.cgcompwrallbotch2(cgcompwrallbotch2),
		.cgcompwrallch0(cgcompwrallch0),
		.cgcompwrallch1(cgcompwrallch1),
		.cgcompwrallch2(cgcompwrallch2),
		.cgcompwralltopch0(cgcompwralltopch0),
		.cgcompwralltopch1(cgcompwralltopch1),
		.cgcompwrinbotch2(cgcompwrinbotch2),
		.cgcompwrinch0(cgcompwrinch0),
		.cgcompwrinch1(cgcompwrinch1),
		.cgcompwrinch2(cgcompwrinch2),
		.cgcompwrintopch0(cgcompwrintopch0),
		.cgcompwrintopch1(cgcompwrintopch1),
		.decctlbotch2(decctlbotch2),
		.decctlch0(decctlch0),
		.decctlch1(decctlch1),
		.decctlch2(decctlch2),
		.decctltopch0(decctltopch0),
		.decctltopch1(decctltopch1),
		.decdatabotch2(decdatabotch2),
		.decdatach0(decdatach0),
		.decdatach1(decdatach1),
		.decdatach2(decdatach2),
		.decdatatopch0(decdatatopch0),
		.decdatatopch1(decdatatopch1),
		.decdatavalidbotch2(decdatavalidbotch2),
		.decdatavalidch0(decdatavalidch0),
		.decdatavalidch1(decdatavalidch1),
		.decdatavalidch2(decdatavalidch2),
		.decdatavalidtopch0(decdatavalidtopch0),
		.decdatavalidtopch1(decdatavalidtopch1),
		.dedicatedaggscaninch1(dedicatedaggscaninch1),
		.dedicatedaggscanoutch0tieoff(dedicatedaggscanoutch0tieoff),
		.dedicatedaggscanoutch1(dedicatedaggscanoutch1),
		.dedicatedaggscanoutch2tieoff(dedicatedaggscanoutch2tieoff),
		.delcondmet0botch2(delcondmet0botch2),
		.delcondmet0ch0(delcondmet0ch0),
		.delcondmet0ch1(delcondmet0ch1),
		.delcondmet0ch2(delcondmet0ch2),
		.delcondmet0topch0(delcondmet0topch0),
		.delcondmet0topch1(delcondmet0topch1),
		.delcondmetinbotch2(delcondmetinbotch2),
		.delcondmetinch0(delcondmetinch0),
		.delcondmetinch1(delcondmetinch1),
		.delcondmetinch2(delcondmetinch2),
		.delcondmetintopch0(delcondmetintopch0),
		.delcondmetintopch1(delcondmetintopch1),
		.dprioagg(dprioagg),
		.endskwqdbotch2(endskwqdbotch2),
		.endskwqdch0(endskwqdch0),
		.endskwqdch1(endskwqdch1),
		.endskwqdch2(endskwqdch2),
		.endskwqdtopch0(endskwqdtopch0),
		.endskwqdtopch1(endskwqdtopch1),
		.endskwrdptrsbotch2(endskwrdptrsbotch2),
		.endskwrdptrsch0(endskwrdptrsch0),
		.endskwrdptrsch1(endskwrdptrsch1),
		.endskwrdptrsch2(endskwrdptrsch2),
		.endskwrdptrstopch0(endskwrdptrstopch0),
		.endskwrdptrstopch1(endskwrdptrstopch1),
		.fifoovr0botch2(fifoovr0botch2),
		.fifoovr0ch0(fifoovr0ch0),
		.fifoovr0ch1(fifoovr0ch1),
		.fifoovr0ch2(fifoovr0ch2),
		.fifoovr0topch0(fifoovr0topch0),
		.fifoovr0topch1(fifoovr0topch1),
		.fifoovrinbotch2(fifoovrinbotch2),
		.fifoovrinch0(fifoovrinch0),
		.fifoovrinch1(fifoovrinch1),
		.fifoovrinch2(fifoovrinch2),
		.fifoovrintopch0(fifoovrintopch0),
		.fifoovrintopch1(fifoovrintopch1),
		.fifordinbotch2(fifordinbotch2),
		.fifordinch0(fifordinch0),
		.fifordinch1(fifordinch1),
		.fifordinch2(fifordinch2),
		.fifordintopch0(fifordintopch0),
		.fifordintopch1(fifordintopch1),
		.fifordoutcomp0botch2(fifordoutcomp0botch2),
		.fifordoutcomp0ch0(fifordoutcomp0ch0),
		.fifordoutcomp0ch1(fifordoutcomp0ch1),
		.fifordoutcomp0ch2(fifordoutcomp0ch2),
		.fifordoutcomp0topch0(fifordoutcomp0topch0),
		.fifordoutcomp0topch1(fifordoutcomp0topch1),
		.fiforstrdqdbotch2(fiforstrdqdbotch2),
		.fiforstrdqdch0(fiforstrdqdch0),
		.fiforstrdqdch1(fiforstrdqdch1),
		.fiforstrdqdch2(fiforstrdqdch2),
		.fiforstrdqdtopch0(fiforstrdqdtopch0),
		.fiforstrdqdtopch1(fiforstrdqdtopch1),
		.insertincomplete0botch2(insertincomplete0botch2),
		.insertincomplete0ch0(insertincomplete0ch0),
		.insertincomplete0ch1(insertincomplete0ch1),
		.insertincomplete0ch2(insertincomplete0ch2),
		.insertincomplete0topch0(insertincomplete0topch0),
		.insertincomplete0topch1(insertincomplete0topch1),
		.insertincompleteinbotch2(insertincompleteinbotch2),
		.insertincompleteinch0(insertincompleteinch0),
		.insertincompleteinch1(insertincompleteinch1),
		.insertincompleteinch2(insertincompleteinch2),
		.insertincompleteintopch0(insertincompleteintopch0),
		.insertincompleteintopch1(insertincompleteintopch1),
		.latencycomp0botch2(latencycomp0botch2),
		.latencycomp0ch0(latencycomp0ch0),
		.latencycomp0ch1(latencycomp0ch1),
		.latencycomp0ch2(latencycomp0ch2),
		.latencycomp0topch0(latencycomp0topch0),
		.latencycomp0topch1(latencycomp0topch1),
		.latencycompinbotch2(latencycompinbotch2),
		.latencycompinch0(latencycompinch0),
		.latencycompinch1(latencycompinch1),
		.latencycompinch2(latencycompinch2),
		.latencycompintopch0(latencycompintopch0),
		.latencycompintopch1(latencycompintopch1),
		.rcvdclkch0(rcvdclkch0),
		.rcvdclkch1(rcvdclkch1),
		.rcvdclkout(rcvdclkout),
		.rcvdclkoutbot(rcvdclkoutbot),
		.rcvdclkouttop(rcvdclkouttop),
		.rdalignbotch2(rdalignbotch2),
		.rdalignch0(rdalignch0),
		.rdalignch1(rdalignch1),
		.rdalignch2(rdalignch2),
		.rdaligntopch0(rdaligntopch0),
		.rdaligntopch1(rdaligntopch1),
		.rdenablesyncbotch2(rdenablesyncbotch2),
		.rdenablesyncch0(rdenablesyncch0),
		.rdenablesyncch1(rdenablesyncch1),
		.rdenablesyncch2(rdenablesyncch2),
		.rdenablesynctopch0(rdenablesynctopch0),
		.rdenablesynctopch1(rdenablesynctopch1),
		.refclkdig(refclkdig),
		.runningdispbotch2(runningdispbotch2),
		.runningdispch0(runningdispch0),
		.runningdispch1(runningdispch1),
		.runningdispch2(runningdispch2),
		.runningdisptopch0(runningdisptopch0),
		.runningdisptopch1(runningdisptopch1),
		.rxctlrsbotch2(rxctlrsbotch2),
		.rxctlrsch0(rxctlrsch0),
		.rxctlrsch1(rxctlrsch1),
		.rxctlrsch2(rxctlrsch2),
		.rxctlrstopch0(rxctlrstopch0),
		.rxctlrstopch1(rxctlrstopch1),
		.rxdatarsbotch2(rxdatarsbotch2),
		.rxdatarsch0(rxdatarsch0),
		.rxdatarsch1(rxdatarsch1),
		.rxdatarsch2(rxdatarsch2),
		.rxdatarstopch0(rxdatarstopch0),
		.rxdatarstopch1(rxdatarstopch1),
		.rxpcsrstn(rxpcsrstn),
		.scanmoden(scanmoden),
		.scanshiftn(scanshiftn),
		.syncstatusbotch2(syncstatusbotch2),
		.syncstatusch0(syncstatusch0),
		.syncstatusch1(syncstatusch1),
		.syncstatusch2(syncstatusch2),
		.syncstatustopch0(syncstatustopch0),
		.syncstatustopch1(syncstatustopch1),
		.txctltcbotch2(txctltcbotch2),
		.txctltcch0(txctltcch0),
		.txctltcch1(txctltcch1),
		.txctltcch2(txctltcch2),
		.txctltctopch0(txctltctopch0),
		.txctltctopch1(txctltctopch1),
		.txctltsbotch2(txctltsbotch2),
		.txctltsch0(txctltsch0),
		.txctltsch1(txctltsch1),
		.txctltsch2(txctltsch2),
		.txctltstopch0(txctltstopch0),
		.txctltstopch1(txctltstopch1),
		.txdatatcbotch2(txdatatcbotch2),
		.txdatatcch0(txdatatcch0),
		.txdatatcch1(txdatatcch1),
		.txdatatcch2(txdatatcch2),
		.txdatatctopch0(txdatatctopch0),
		.txdatatctopch1(txdatatctopch1),
		.txdatatsbotch2(txdatatsbotch2),
		.txdatatsch0(txdatatsch0),
		.txdatatsch1(txdatatsch1),
		.txdatatsch2(txdatatsch2),
		.txdatatstopch0(txdatatstopch0),
		.txdatatstopch1(txdatatstopch1),
		.txpcsrstn(txpcsrstn),
		.txpmaclk(txpmaclk)
	);
endmodule
