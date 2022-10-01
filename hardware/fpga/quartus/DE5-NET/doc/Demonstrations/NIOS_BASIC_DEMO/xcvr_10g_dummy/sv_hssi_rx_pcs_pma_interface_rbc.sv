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


// Verilog RBC parameter resolution wrapper for stratixv_hssi_rx_pcs_pma_interface
//

`timescale 1 ns / 1 ps

module sv_hssi_rx_pcs_pma_interface_rbc #(
	// unconstrained parameters
	parameter prot_mode = "<auto_single>",	// cpri_8g, other_protocols

	// extra unconstrained parameters found in atom map
	parameter avmm_group_channel_index = 0,	// 0..2
	parameter selectpcs = "eight_g_pcs",	// default, eight_g_pcs, pcie_gen3, ten_g_pcs
	parameter use_default_base_address = "true",	// false, true
	parameter user_base_address = 0,	// 0..2047

	// constrained parameters
	parameter clkslip_sel = "<auto_single>"	// pld, slip_eight_g_pcs
) (
	// ports
	output wire         	asynchdatain,
	input  wire   [10:0]	avmmaddress,
	input  wire    [1:0]	avmmbyteen,
	input  wire         	avmmclk,
	input  wire         	avmmread,
	output wire   [15:0]	avmmreaddata,
	input  wire         	avmmrstn,
	input  wire         	avmmwrite,
	input  wire   [15:0]	avmmwritedata,
	output wire         	blockselect,
	output wire         	clkoutto10gpcs,
	input  wire         	clockinfrompma,
	output wire         	clockoutto8gpcs,
	output wire         	clockouttogen3pcs,
	input  wire   [79:0]	datainfrompma,
	output wire   [79:0]	dataoutto10gpcs,
	output wire   [19:0]	dataoutto8gpcs,
	output wire   [31:0]	dataouttogen3pcs,
	output wire         	pcs10gclkdiv33txorrx,
	input  wire         	pcs10grxclkiqout,
	output wire         	pcs10gsignalok,
	input  wire         	pcs8grxclkiqout,
	input  wire         	pcs8grxclkslip,
	output wire         	pcs8gsigdetni,
	input  wire         	pcsemsiprxclkiqout,
	output wire    [1:0]	pcsgen3eyemonitorin,
	input  wire    [7:0]	pcsgen3eyemonitorout,
	output wire         	pcsgen3pmasignaldet,
	input  wire         	pldrxclkslip,
	input  wire         	pldrxpmarstb,
	input  wire         	pmaclkdiv33txorrxin,
	output wire         	pmaclkdiv33txorrxout,
	input  wire    [1:0]	pmaeyemonitorin,
	output wire    [7:0]	pmaeyemonitorout,
	input  wire    [4:0]	pmareservedin,
	output wire    [4:0]	pmareservedout,
	output wire         	pmarxclkout,
	output wire         	pmarxclkslip,
	input  wire         	pmarxpllphaselockin,
	output wire         	pmarxpllphaselockout,
	output wire         	pmarxpmarstb,
	input  wire         	pmasigdet,
	input  wire         	pmasignalok,
	output wire         	reset
);
	import altera_xcvr_functions::*;

	// prot_mode external parameter (no RBC)
	localparam rbc_all_prot_mode = "(cpri_8g,other_protocols)";
	localparam rbc_any_prot_mode = "other_protocols";
	localparam fnl_prot_mode = (prot_mode == "<auto_any>" || prot_mode == "<auto_single>") ? rbc_any_prot_mode : prot_mode;

	// selectpcs external parameter (no RBC)
	localparam rbc_all_selectpcs = "(default,eight_g_pcs,pcie_gen3,ten_g_pcs)";
	localparam rbc_any_selectpcs = "eight_g_pcs";
	localparam fnl_selectpcs = (selectpcs == "<auto_any>" || selectpcs == "<auto_single>") ? rbc_any_selectpcs : selectpcs;

	// use_default_base_address external parameter (no RBC)
	localparam rbc_all_use_default_base_address = "(false,true)";
	localparam rbc_any_use_default_base_address = "true";
	localparam fnl_use_default_base_address = (use_default_base_address == "<auto_any>" || use_default_base_address == "<auto_single>") ? rbc_any_use_default_base_address : use_default_base_address;

	// clkslip_sel, RBC-validated
	localparam rbc_all_clkslip_sel = (fnl_prot_mode == "cpri_8g") ? ("(slip_eight_g_pcs,pld)") : "pld";
	localparam rbc_any_clkslip_sel = (fnl_prot_mode == "cpri_8g") ? ("pld") : "pld";
	localparam fnl_clkslip_sel = (clkslip_sel == "<auto_any>" || clkslip_sel == "<auto_single>") ? rbc_any_clkslip_sel : clkslip_sel;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("prot_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", prot_mode, rbc_any_prot_mode, rbc_all_prot_mode, fnl_prot_mode);
		if (!is_in_legal_set(prot_mode, rbc_all_prot_mode)) begin
			$display("Critical Warning: parameter 'prot_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", prot_mode, rbc_all_prot_mode, fnl_prot_mode);
		end
		//$display("selectpcs = orig: '%s', any:'%s', all:'%s', final: '%s'", selectpcs, rbc_any_selectpcs, rbc_all_selectpcs, fnl_selectpcs);
		if (!is_in_legal_set(selectpcs, rbc_all_selectpcs)) begin
			$display("Critical Warning: parameter 'selectpcs' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", selectpcs, rbc_all_selectpcs, fnl_selectpcs);
		end
		//$display("use_default_base_address = orig: '%s', any:'%s', all:'%s', final: '%s'", use_default_base_address, rbc_any_use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		if (!is_in_legal_set(use_default_base_address, rbc_all_use_default_base_address)) begin
			$display("Critical Warning: parameter 'use_default_base_address' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		end
		//$display("clkslip_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", clkslip_sel, rbc_any_clkslip_sel, rbc_all_clkslip_sel, fnl_clkslip_sel);
		if (!is_in_legal_set(clkslip_sel, rbc_all_clkslip_sel)) begin
			$display("Critical Warning: parameter 'clkslip_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", clkslip_sel, rbc_all_clkslip_sel, fnl_clkslip_sel);
		end
	end

	stratixv_hssi_rx_pcs_pma_interface #(
		.prot_mode(fnl_prot_mode),
		.avmm_group_channel_index(avmm_group_channel_index),
		.selectpcs(fnl_selectpcs),
		.use_default_base_address(fnl_use_default_base_address),
		.user_base_address(user_base_address),
		.clkslip_sel(fnl_clkslip_sel)
	) wys (
		// ports
		.asynchdatain(asynchdatain),
		.avmmaddress(avmmaddress),
		.avmmbyteen(avmmbyteen),
		.avmmclk(avmmclk),
		.avmmread(avmmread),
		.avmmreaddata(avmmreaddata),
		.avmmrstn(avmmrstn),
		.avmmwrite(avmmwrite),
		.avmmwritedata(avmmwritedata),
		.blockselect(blockselect),
		.clkoutto10gpcs(clkoutto10gpcs),
		.clockinfrompma(clockinfrompma),
		.clockoutto8gpcs(clockoutto8gpcs),
		.clockouttogen3pcs(clockouttogen3pcs),
		.datainfrompma(datainfrompma),
		.dataoutto10gpcs(dataoutto10gpcs),
		.dataoutto8gpcs(dataoutto8gpcs),
		.dataouttogen3pcs(dataouttogen3pcs),
		.pcs10gclkdiv33txorrx(pcs10gclkdiv33txorrx),
		.pcs10grxclkiqout(pcs10grxclkiqout),
		.pcs10gsignalok(pcs10gsignalok),
		.pcs8grxclkiqout(pcs8grxclkiqout),
		.pcs8grxclkslip(pcs8grxclkslip),
		.pcs8gsigdetni(pcs8gsigdetni),
		.pcsemsiprxclkiqout(pcsemsiprxclkiqout),
		.pcsgen3eyemonitorin(pcsgen3eyemonitorin),
		.pcsgen3eyemonitorout(pcsgen3eyemonitorout),
		.pcsgen3pmasignaldet(pcsgen3pmasignaldet),
		.pldrxclkslip(pldrxclkslip),
		.pldrxpmarstb(pldrxpmarstb),
		.pmaclkdiv33txorrxin(pmaclkdiv33txorrxin),
		.pmaclkdiv33txorrxout(pmaclkdiv33txorrxout),
		.pmaeyemonitorin(pmaeyemonitorin),
		.pmaeyemonitorout(pmaeyemonitorout),
		.pmareservedin(pmareservedin),
		.pmareservedout(pmareservedout),
		.pmarxclkout(pmarxclkout),
		.pmarxclkslip(pmarxclkslip),
		.pmarxpllphaselockin(pmarxpllphaselockin),
		.pmarxpllphaselockout(pmarxpllphaselockout),
		.pmarxpmarstb(pmarxpmarstb),
		.pmasigdet(pmasigdet),
		.pmasignalok(pmasignalok),
		.reset(reset)
	);
endmodule
