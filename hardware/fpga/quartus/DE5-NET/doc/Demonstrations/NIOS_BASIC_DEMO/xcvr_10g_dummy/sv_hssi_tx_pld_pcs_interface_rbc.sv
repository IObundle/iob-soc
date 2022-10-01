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


// Verilog RBC parameter resolution wrapper for stratixv_hssi_tx_pld_pcs_interface
//

`timescale 1 ns / 1 ps

module sv_hssi_tx_pld_pcs_interface_rbc #(
	// unconstrained parameters

	// extra unconstrained parameters found in atom map
	parameter avmm_group_channel_index = 0,	// 0..2
	parameter data_source = "pld",	// emsip, pld
	parameter is_10g_0ppm = "false",	// false, true
	parameter is_8g_0ppm = "false",	// false, true
	parameter use_default_base_address = "true",	// false, true
	parameter user_base_address = 0	// 0..2047

	// constrained parameters
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
	input  wire         	clockinfrom10gpcs,
	input  wire         	clockinfrom8gpcs,
	input  wire   [63:0]	datainfrompld,
	output wire   [63:0]	dataoutto10gpcs,
	output wire   [43:0]	dataoutto8gpcs,
	input  wire         	emsipenablediocsrrdydly,
	input  wire    [2:0]	emsippcstxclkin,
	output wire    [2:0]	emsippcstxclkout,
	input  wire  [103:0]	emsiptxin,
	output wire   [11:0]	emsiptxout,
	input  wire   [12:0]	emsiptxspecialin,
	output wire   [15:0]	emsiptxspecialout,
	output wire    [6:0]	pcs10gtxbitslip,
	output wire         	pcs10gtxbursten,
	input  wire         	pcs10gtxburstenexe,
	output wire    [8:0]	pcs10gtxcontrol,
	output wire         	pcs10gtxdatavalid,
	output wire    [1:0]	pcs10gtxdiagstatus,
	input  wire         	pcs10gtxempty,
	input  wire         	pcs10gtxfifodel,
	input  wire         	pcs10gtxfifoinsert,
	input  wire         	pcs10gtxframe,
	input  wire         	pcs10gtxfull,
	input  wire         	pcs10gtxpempty,
	input  wire         	pcs10gtxpfull,
	output wire         	pcs10gtxpldclk,
	output wire         	pcs10gtxpldrstn,
	output wire         	pcs10gtxwordslip,
	input  wire         	pcs10gtxwordslipexe,
	input  wire         	pcs8gemptytx,
	input  wire         	pcs8gfulltx,
	output wire         	pcs8gphfifoursttx,
	output wire         	pcs8gpldtxclk,
	output wire         	pcs8gpolinvtx,
	output wire         	pcs8grddisabletx,
	output wire         	pcs8grevloopbk,
	output wire    [3:0]	pcs8gtxblkstart,
	output wire    [4:0]	pcs8gtxboundarysel,
	output wire    [3:0]	pcs8gtxdatavalid,
	output wire    [1:0]	pcs8gtxsynchdr,
	output wire         	pcs8gtxurstpcs,
	output wire         	pcs8gwrenabletx,
	output wire         	pcsgen3txrst,
	output wire         	pcsgen3txrstn,
	input  wire    [6:0]	pld10gtxbitslip,
	input  wire         	pld10gtxbursten,
	output wire         	pld10gtxburstenexe,
	output wire         	pld10gtxclkout,
	input  wire    [8:0]	pld10gtxcontrol,
	input  wire         	pld10gtxdatavalid,
	input  wire    [1:0]	pld10gtxdiagstatus,
	output wire         	pld10gtxempty,
	output wire         	pld10gtxfifodel,
	output wire         	pld10gtxfifoinsert,
	output wire         	pld10gtxframe,
	output wire         	pld10gtxfull,
	output wire         	pld10gtxpempty,
	output wire         	pld10gtxpfull,
	input  wire         	pld10gtxpldclk,
	input  wire         	pld10gtxpldrstn,
	input  wire         	pld10gtxwordslip,
	output wire         	pld10gtxwordslipexe,
	output wire         	pld8gemptytx,
	output wire         	pld8gfulltx,
	input  wire         	pld8gphfifoursttxn,
	input  wire         	pld8gpldtxclk,
	input  wire         	pld8gpolinvtx,
	input  wire         	pld8grddisabletx,
	input  wire         	pld8grevloopbk,
	input  wire    [3:0]	pld8gtxblkstart,
	input  wire    [4:0]	pld8gtxboundarysel,
	output wire         	pld8gtxclkout,
	input  wire    [3:0]	pld8gtxdatavalid,
	input  wire    [1:0]	pld8gtxsynchdr,
	input  wire         	pld8gtxurstpcsn,
	input  wire         	pld8gwrenabletx,
	output wire         	pldclkdiv33lc,
	input  wire         	pldgen3txrstn,
	output wire         	pldlccmurstbout,
	output wire         	pldtxiqclkout,
	output wire         	pldtxpmasyncpfbkpout,
	input  wire         	pmaclkdiv33lc,
	input  wire         	pmatxcmuplllock,
	input  wire         	pmatxlcplllock,
	output wire         	reset,
	input  wire         	rstsel,
	input  wire         	usrrstsel
);
	import altera_xcvr_functions::*;

	// data_source external parameter (no RBC)
	localparam rbc_all_data_source = "(emsip,pld)";
	localparam rbc_any_data_source = "pld";
	localparam fnl_data_source = (data_source == "<auto_any>" || data_source == "<auto_single>") ? rbc_any_data_source : data_source;

	// is_10g_0ppm external parameter (no RBC)
	localparam rbc_all_is_10g_0ppm = "(false,true)";
	localparam rbc_any_is_10g_0ppm = "false";
	localparam fnl_is_10g_0ppm = (is_10g_0ppm == "<auto_any>" || is_10g_0ppm == "<auto_single>") ? rbc_any_is_10g_0ppm : is_10g_0ppm;

	// is_8g_0ppm external parameter (no RBC)
	localparam rbc_all_is_8g_0ppm = "(false,true)";
	localparam rbc_any_is_8g_0ppm = "false";
	localparam fnl_is_8g_0ppm = (is_8g_0ppm == "<auto_any>" || is_8g_0ppm == "<auto_single>") ? rbc_any_is_8g_0ppm : is_8g_0ppm;

	// use_default_base_address external parameter (no RBC)
	localparam rbc_all_use_default_base_address = "(false,true)";
	localparam rbc_any_use_default_base_address = "true";
	localparam fnl_use_default_base_address = (use_default_base_address == "<auto_any>" || use_default_base_address == "<auto_single>") ? rbc_any_use_default_base_address : use_default_base_address;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("data_source = orig: '%s', any:'%s', all:'%s', final: '%s'", data_source, rbc_any_data_source, rbc_all_data_source, fnl_data_source);
		if (!is_in_legal_set(data_source, rbc_all_data_source)) begin
			$display("Critical Warning: parameter 'data_source' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", data_source, rbc_all_data_source, fnl_data_source);
		end
		//$display("is_10g_0ppm = orig: '%s', any:'%s', all:'%s', final: '%s'", is_10g_0ppm, rbc_any_is_10g_0ppm, rbc_all_is_10g_0ppm, fnl_is_10g_0ppm);
		if (!is_in_legal_set(is_10g_0ppm, rbc_all_is_10g_0ppm)) begin
			$display("Critical Warning: parameter 'is_10g_0ppm' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", is_10g_0ppm, rbc_all_is_10g_0ppm, fnl_is_10g_0ppm);
		end
		//$display("is_8g_0ppm = orig: '%s', any:'%s', all:'%s', final: '%s'", is_8g_0ppm, rbc_any_is_8g_0ppm, rbc_all_is_8g_0ppm, fnl_is_8g_0ppm);
		if (!is_in_legal_set(is_8g_0ppm, rbc_all_is_8g_0ppm)) begin
			$display("Critical Warning: parameter 'is_8g_0ppm' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", is_8g_0ppm, rbc_all_is_8g_0ppm, fnl_is_8g_0ppm);
		end
		//$display("use_default_base_address = orig: '%s', any:'%s', all:'%s', final: '%s'", use_default_base_address, rbc_any_use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		if (!is_in_legal_set(use_default_base_address, rbc_all_use_default_base_address)) begin
			$display("Critical Warning: parameter 'use_default_base_address' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		end
	end

	stratixv_hssi_tx_pld_pcs_interface #(
		.avmm_group_channel_index(avmm_group_channel_index),
		.data_source(fnl_data_source),
		.is_10g_0ppm(fnl_is_10g_0ppm),
		.is_8g_0ppm(fnl_is_8g_0ppm),
		.use_default_base_address(fnl_use_default_base_address),
		.user_base_address(user_base_address)
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
		.clockinfrom10gpcs(clockinfrom10gpcs),
		.clockinfrom8gpcs(clockinfrom8gpcs),
		.datainfrompld(datainfrompld),
		.dataoutto10gpcs(dataoutto10gpcs),
		.dataoutto8gpcs(dataoutto8gpcs),
		.emsipenablediocsrrdydly(emsipenablediocsrrdydly),
		.emsippcstxclkin(emsippcstxclkin),
		.emsippcstxclkout(emsippcstxclkout),
		.emsiptxin(emsiptxin),
		.emsiptxout(emsiptxout),
		.emsiptxspecialin(emsiptxspecialin),
		.emsiptxspecialout(emsiptxspecialout),
		.pcs10gtxbitslip(pcs10gtxbitslip),
		.pcs10gtxbursten(pcs10gtxbursten),
		.pcs10gtxburstenexe(pcs10gtxburstenexe),
		.pcs10gtxcontrol(pcs10gtxcontrol),
		.pcs10gtxdatavalid(pcs10gtxdatavalid),
		.pcs10gtxdiagstatus(pcs10gtxdiagstatus),
		.pcs10gtxempty(pcs10gtxempty),
		.pcs10gtxfifodel(pcs10gtxfifodel),
		.pcs10gtxfifoinsert(pcs10gtxfifoinsert),
		.pcs10gtxframe(pcs10gtxframe),
		.pcs10gtxfull(pcs10gtxfull),
		.pcs10gtxpempty(pcs10gtxpempty),
		.pcs10gtxpfull(pcs10gtxpfull),
		.pcs10gtxpldclk(pcs10gtxpldclk),
		.pcs10gtxpldrstn(pcs10gtxpldrstn),
		.pcs10gtxwordslip(pcs10gtxwordslip),
		.pcs10gtxwordslipexe(pcs10gtxwordslipexe),
		.pcs8gemptytx(pcs8gemptytx),
		.pcs8gfulltx(pcs8gfulltx),
		.pcs8gphfifoursttx(pcs8gphfifoursttx),
		.pcs8gpldtxclk(pcs8gpldtxclk),
		.pcs8gpolinvtx(pcs8gpolinvtx),
		.pcs8grddisabletx(pcs8grddisabletx),
		.pcs8grevloopbk(pcs8grevloopbk),
		.pcs8gtxblkstart(pcs8gtxblkstart),
		.pcs8gtxboundarysel(pcs8gtxboundarysel),
		.pcs8gtxdatavalid(pcs8gtxdatavalid),
		.pcs8gtxsynchdr(pcs8gtxsynchdr),
		.pcs8gtxurstpcs(pcs8gtxurstpcs),
		.pcs8gwrenabletx(pcs8gwrenabletx),
		.pcsgen3txrst(pcsgen3txrst),
		.pcsgen3txrstn(pcsgen3txrstn),
		.pld10gtxbitslip(pld10gtxbitslip),
		.pld10gtxbursten(pld10gtxbursten),
		.pld10gtxburstenexe(pld10gtxburstenexe),
		.pld10gtxclkout(pld10gtxclkout),
		.pld10gtxcontrol(pld10gtxcontrol),
		.pld10gtxdatavalid(pld10gtxdatavalid),
		.pld10gtxdiagstatus(pld10gtxdiagstatus),
		.pld10gtxempty(pld10gtxempty),
		.pld10gtxfifodel(pld10gtxfifodel),
		.pld10gtxfifoinsert(pld10gtxfifoinsert),
		.pld10gtxframe(pld10gtxframe),
		.pld10gtxfull(pld10gtxfull),
		.pld10gtxpempty(pld10gtxpempty),
		.pld10gtxpfull(pld10gtxpfull),
		.pld10gtxpldclk(pld10gtxpldclk),
		.pld10gtxpldrstn(pld10gtxpldrstn),
		.pld10gtxwordslip(pld10gtxwordslip),
		.pld10gtxwordslipexe(pld10gtxwordslipexe),
		.pld8gemptytx(pld8gemptytx),
		.pld8gfulltx(pld8gfulltx),
		.pld8gphfifoursttxn(pld8gphfifoursttxn),
		.pld8gpldtxclk(pld8gpldtxclk),
		.pld8gpolinvtx(pld8gpolinvtx),
		.pld8grddisabletx(pld8grddisabletx),
		.pld8grevloopbk(pld8grevloopbk),
		.pld8gtxblkstart(pld8gtxblkstart),
		.pld8gtxboundarysel(pld8gtxboundarysel),
		.pld8gtxclkout(pld8gtxclkout),
		.pld8gtxdatavalid(pld8gtxdatavalid),
		.pld8gtxsynchdr(pld8gtxsynchdr),
		.pld8gtxurstpcsn(pld8gtxurstpcsn),
		.pld8gwrenabletx(pld8gwrenabletx),
		.pldclkdiv33lc(pldclkdiv33lc),
		.pldgen3txrstn(pldgen3txrstn),
		.pldlccmurstbout(pldlccmurstbout),
		.pldtxiqclkout(pldtxiqclkout),
		.pldtxpmasyncpfbkpout(pldtxpmasyncpfbkpout),
		.pmaclkdiv33lc(pmaclkdiv33lc),
		.pmatxcmuplllock(pmatxcmuplllock),
		.pmatxlcplllock(pmatxlcplllock),
		.reset(reset),
		.rstsel(rstsel),
		.usrrstsel(usrrstsel)
	);
endmodule
