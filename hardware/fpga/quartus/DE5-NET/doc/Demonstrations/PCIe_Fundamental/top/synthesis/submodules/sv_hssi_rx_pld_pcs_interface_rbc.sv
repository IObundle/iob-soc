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


// Verilog RBC parameter resolution wrapper for stratixv_hssi_rx_pld_pcs_interface
//

`timescale 1 ns / 1 ps

module sv_hssi_rx_pld_pcs_interface_rbc #(
	// unconstrained parameters

	// extra unconstrained parameters found in atom map
	parameter avmm_group_channel_index = 0,	// 0..2
	parameter data_source = "pld",	// emsip, pld
	parameter is_10g_0ppm = "false",	// false, true
	parameter is_8g_0ppm = "false",	// false, true
	parameter selectpcs = "eight_g_pcs",	// default, eight_g_pcs, ten_g_pcs
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
	input  wire   [63:0]	datainfrom10gpcs,
	input  wire   [63:0]	datainfrom8gpcs,
	output wire   [63:0]	dataouttopld,
	input  wire         	emsipenablediocsrrdydly,
	input  wire    [2:0]	emsiprxclkin,
	output wire    [2:0]	emsiprxclkout,
	input  wire   [19:0]	emsiprxin,
	output wire  [128:0]	emsiprxout,
	input  wire   [12:0]	emsiprxspecialin,
	output wire   [15:0]	emsiprxspecialout,
	output wire         	pcs10grxalignclr,
	output wire         	pcs10grxalignen,
	input  wire         	pcs10grxalignval,
	output wire         	pcs10grxbitslip,
	input  wire         	pcs10grxblklock,
	output wire         	pcs10grxclrbercount,
	output wire         	pcs10grxclrerrblkcnt,
	input  wire    [9:0]	pcs10grxcontrol,
	input  wire         	pcs10grxcrc32err,
	input  wire         	pcs10grxdatavalid,
	input  wire         	pcs10grxdiagerr,
	input  wire    [1:0]	pcs10grxdiagstatus,
	output wire         	pcs10grxdispclr,
	input  wire         	pcs10grxempty,
	input  wire         	pcs10grxfifodel,
	input  wire         	pcs10grxfifoinsert,
	input  wire         	pcs10grxframelock,
	input  wire         	pcs10grxhiber,
	input  wire         	pcs10grxmfrmerr,
	input  wire         	pcs10grxoflwerr,
	input  wire         	pcs10grxpempty,
	input  wire         	pcs10grxpfull,
	output wire         	pcs10grxpldclk,
	output wire         	pcs10grxpldrstn,
	input  wire         	pcs10grxprbserr,
	output wire         	pcs10grxprbserrclr,
	input  wire         	pcs10grxpyldins,
	output wire         	pcs10grxrden,
	input  wire         	pcs10grxrdnegsts,
	input  wire         	pcs10grxrdpossts,
	input  wire         	pcs10grxrxframe,
	input  wire         	pcs10grxscrmerr,
	input  wire         	pcs10grxsherr,
	input  wire         	pcs10grxskiperr,
	input  wire         	pcs10grxskipins,
	input  wire         	pcs10grxsyncerr,
	input  wire    [3:0]	pcs8ga1a2k1k2flag,
	output wire         	pcs8ga1a2size,
	input  wire         	pcs8galignstatus,
	input  wire         	pcs8gbistdone,
	input  wire         	pcs8gbisterr,
	output wire         	pcs8gbitlocreven,
	output wire         	pcs8gbitslip,
	input  wire         	pcs8gbyteordflag,
	output wire         	pcs8gbytereven,
	output wire         	pcs8gbytordpld,
	output wire         	pcs8gcmpfifourst,
	input  wire         	pcs8gemptyrmf,
	input  wire         	pcs8gemptyrx,
	output wire         	pcs8gencdt,
	input  wire         	pcs8gfullrmf,
	input  wire         	pcs8gfullrx,
	output wire         	pcs8gphfifourstrx,
	input  wire         	pcs8gphystatus,
	output wire         	pcs8gpldrxclk,
	output wire         	pcs8gpolinvrx,
	output wire         	pcs8grdenablermf,
	output wire         	pcs8grdenablerx,
	input  wire         	pcs8grlvlt,
	input  wire    [3:0]	pcs8grxblkstart,
	input  wire    [3:0]	pcs8grxdatavalid,
	input  wire         	pcs8grxelecidle,
	input  wire    [2:0]	pcs8grxstatus,
	input  wire    [1:0]	pcs8grxsynchdr,
	output wire         	pcs8grxurstpcs,
	input  wire         	pcs8grxvalid,
	input  wire         	pcs8gsignaldetectout,
	output wire         	pcs8gsyncsmenoutput,
	input  wire    [4:0]	pcs8gwaboundary,
	output wire         	pcs8gwrdisablerx,
	output wire         	pcs8gwrenablermf,
	output wire         	pcsgen3rxrst,
	output wire         	pcsgen3rxrstn,
	output wire         	pcsgen3rxupdatefc,
	output wire         	pcsgen3syncsmen,
	input  wire         	pld10grxalignclr,
	input  wire         	pld10grxalignen,
	output wire         	pld10grxalignval,
	input  wire         	pld10grxbitslip,
	output wire         	pld10grxblklock,
	output wire         	pld10grxclkout,
	input  wire         	pld10grxclrbercount,
	input  wire         	pld10grxclrerrblkcnt,
	output wire    [9:0]	pld10grxcontrol,
	output wire         	pld10grxcrc32err,
	output wire         	pld10grxdatavalid,
	output wire         	pld10grxdiagerr,
	output wire    [1:0]	pld10grxdiagstatus,
	input  wire         	pld10grxdispclr,
	output wire         	pld10grxempty,
	output wire         	pld10grxfifodel,
	output wire         	pld10grxfifoinsert,
	output wire         	pld10grxframelock,
	output wire         	pld10grxhiber,
	output wire         	pld10grxmfrmerr,
	output wire         	pld10grxoflwerr,
	output wire         	pld10grxpempty,
	output wire         	pld10grxpfull,
	input  wire         	pld10grxpldclk,
	input  wire         	pld10grxpldrstn,
	output wire         	pld10grxprbserr,
	input  wire         	pld10grxprbserrclr,
	output wire         	pld10grxpyldins,
	input  wire         	pld10grxrden,
	output wire         	pld10grxrdnegsts,
	output wire         	pld10grxrdpossts,
	output wire         	pld10grxrxframe,
	output wire         	pld10grxscrmerr,
	output wire         	pld10grxsherr,
	output wire         	pld10grxskiperr,
	output wire         	pld10grxskipins,
	output wire         	pld10grxsyncerr,
	output wire    [3:0]	pld8ga1a2k1k2flag,
	input  wire         	pld8ga1a2size,
	output wire         	pld8galignstatus,
	output wire         	pld8gbistdone,
	output wire         	pld8gbisterr,
	input  wire         	pld8gbitlocreven,
	input  wire         	pld8gbitslip,
	output wire         	pld8gbyteordflag,
	input  wire         	pld8gbytereven,
	input  wire         	pld8gbytordpld,
	input  wire         	pld8gcmpfifourstn,
	output wire         	pld8gemptyrmf,
	output wire         	pld8gemptyrx,
	input  wire         	pld8gencdt,
	output wire         	pld8gfullrmf,
	output wire         	pld8gfullrx,
	input  wire         	pld8gphfifourstrxn,
	input  wire         	pld8gpldrxclk,
	input  wire         	pld8gpolinvrx,
	input  wire         	pld8grdenablermf,
	input  wire         	pld8grdenablerx,
	output wire         	pld8grlvlt,
	output wire    [3:0]	pld8grxblkstart,
	output wire         	pld8grxclkout,
	output wire    [3:0]	pld8grxdatavalid,
	output wire    [1:0]	pld8grxsynchdr,
	input  wire         	pld8grxurstpcsn,
	output wire         	pld8gsignaldetectout,
	input  wire         	pld8gsyncsmeninput,
	output wire    [4:0]	pld8gwaboundary,
	input  wire         	pld8gwrdisablerx,
	input  wire         	pld8gwrenablermf,
	output wire         	pldclkdiv33txorrx,
	input  wire         	pldgen3rxrstn,
	input  wire         	pldgen3rxupdatefc,
	input  wire         	pldrxclkslipin,
	output wire         	pldrxclkslipout,
	output wire         	pldrxiqclkout,
	input  wire         	pldrxpmarstbin,
	output wire         	pldrxpmarstbout,
	input  wire         	pmaclkdiv33txorrx,
	input  wire         	pmarxplllock,
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

	// selectpcs external parameter (no RBC)
	localparam rbc_all_selectpcs = "(default,eight_g_pcs,ten_g_pcs)";
	localparam rbc_any_selectpcs = "eight_g_pcs";
	localparam fnl_selectpcs = (selectpcs == "<auto_any>" || selectpcs == "<auto_single>") ? rbc_any_selectpcs : selectpcs;

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
		//$display("selectpcs = orig: '%s', any:'%s', all:'%s', final: '%s'", selectpcs, rbc_any_selectpcs, rbc_all_selectpcs, fnl_selectpcs);
		if (!is_in_legal_set(selectpcs, rbc_all_selectpcs)) begin
			$display("Critical Warning: parameter 'selectpcs' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", selectpcs, rbc_all_selectpcs, fnl_selectpcs);
		end
		//$display("use_default_base_address = orig: '%s', any:'%s', all:'%s', final: '%s'", use_default_base_address, rbc_any_use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		if (!is_in_legal_set(use_default_base_address, rbc_all_use_default_base_address)) begin
			$display("Critical Warning: parameter 'use_default_base_address' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		end
	end

	stratixv_hssi_rx_pld_pcs_interface #(
		.avmm_group_channel_index(avmm_group_channel_index),
		.data_source(fnl_data_source),
		.is_10g_0ppm(fnl_is_10g_0ppm),
		.is_8g_0ppm(fnl_is_8g_0ppm),
		.selectpcs(fnl_selectpcs),
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
		.datainfrom10gpcs(datainfrom10gpcs),
		.datainfrom8gpcs(datainfrom8gpcs),
		.dataouttopld(dataouttopld),
		.emsipenablediocsrrdydly(emsipenablediocsrrdydly),
		.emsiprxclkin(emsiprxclkin),
		.emsiprxclkout(emsiprxclkout),
		.emsiprxin(emsiprxin),
		.emsiprxout(emsiprxout),
		.emsiprxspecialin(emsiprxspecialin),
		.emsiprxspecialout(emsiprxspecialout),
		.pcs10grxalignclr(pcs10grxalignclr),
		.pcs10grxalignen(pcs10grxalignen),
		.pcs10grxalignval(pcs10grxalignval),
		.pcs10grxbitslip(pcs10grxbitslip),
		.pcs10grxblklock(pcs10grxblklock),
		.pcs10grxclrbercount(pcs10grxclrbercount),
		.pcs10grxclrerrblkcnt(pcs10grxclrerrblkcnt),
		.pcs10grxcontrol(pcs10grxcontrol),
		.pcs10grxcrc32err(pcs10grxcrc32err),
		.pcs10grxdatavalid(pcs10grxdatavalid),
		.pcs10grxdiagerr(pcs10grxdiagerr),
		.pcs10grxdiagstatus(pcs10grxdiagstatus),
		.pcs10grxdispclr(pcs10grxdispclr),
		.pcs10grxempty(pcs10grxempty),
		.pcs10grxfifodel(pcs10grxfifodel),
		.pcs10grxfifoinsert(pcs10grxfifoinsert),
		.pcs10grxframelock(pcs10grxframelock),
		.pcs10grxhiber(pcs10grxhiber),
		.pcs10grxmfrmerr(pcs10grxmfrmerr),
		.pcs10grxoflwerr(pcs10grxoflwerr),
		.pcs10grxpempty(pcs10grxpempty),
		.pcs10grxpfull(pcs10grxpfull),
		.pcs10grxpldclk(pcs10grxpldclk),
		.pcs10grxpldrstn(pcs10grxpldrstn),
		.pcs10grxprbserr(pcs10grxprbserr),
		.pcs10grxprbserrclr(pcs10grxprbserrclr),
		.pcs10grxpyldins(pcs10grxpyldins),
		.pcs10grxrden(pcs10grxrden),
		.pcs10grxrdnegsts(pcs10grxrdnegsts),
		.pcs10grxrdpossts(pcs10grxrdpossts),
		.pcs10grxrxframe(pcs10grxrxframe),
		.pcs10grxscrmerr(pcs10grxscrmerr),
		.pcs10grxsherr(pcs10grxsherr),
		.pcs10grxskiperr(pcs10grxskiperr),
		.pcs10grxskipins(pcs10grxskipins),
		.pcs10grxsyncerr(pcs10grxsyncerr),
		.pcs8ga1a2k1k2flag(pcs8ga1a2k1k2flag),
		.pcs8ga1a2size(pcs8ga1a2size),
		.pcs8galignstatus(pcs8galignstatus),
		.pcs8gbistdone(pcs8gbistdone),
		.pcs8gbisterr(pcs8gbisterr),
		.pcs8gbitlocreven(pcs8gbitlocreven),
		.pcs8gbitslip(pcs8gbitslip),
		.pcs8gbyteordflag(pcs8gbyteordflag),
		.pcs8gbytereven(pcs8gbytereven),
		.pcs8gbytordpld(pcs8gbytordpld),
		.pcs8gcmpfifourst(pcs8gcmpfifourst),
		.pcs8gemptyrmf(pcs8gemptyrmf),
		.pcs8gemptyrx(pcs8gemptyrx),
		.pcs8gencdt(pcs8gencdt),
		.pcs8gfullrmf(pcs8gfullrmf),
		.pcs8gfullrx(pcs8gfullrx),
		.pcs8gphfifourstrx(pcs8gphfifourstrx),
		.pcs8gphystatus(pcs8gphystatus),
		.pcs8gpldrxclk(pcs8gpldrxclk),
		.pcs8gpolinvrx(pcs8gpolinvrx),
		.pcs8grdenablermf(pcs8grdenablermf),
		.pcs8grdenablerx(pcs8grdenablerx),
		.pcs8grlvlt(pcs8grlvlt),
		.pcs8grxblkstart(pcs8grxblkstart),
		.pcs8grxdatavalid(pcs8grxdatavalid),
		.pcs8grxelecidle(pcs8grxelecidle),
		.pcs8grxstatus(pcs8grxstatus),
		.pcs8grxsynchdr(pcs8grxsynchdr),
		.pcs8grxurstpcs(pcs8grxurstpcs),
		.pcs8grxvalid(pcs8grxvalid),
		.pcs8gsignaldetectout(pcs8gsignaldetectout),
		.pcs8gsyncsmenoutput(pcs8gsyncsmenoutput),
		.pcs8gwaboundary(pcs8gwaboundary),
		.pcs8gwrdisablerx(pcs8gwrdisablerx),
		.pcs8gwrenablermf(pcs8gwrenablermf),
		.pcsgen3rxrst(pcsgen3rxrst),
		.pcsgen3rxrstn(pcsgen3rxrstn),
		.pcsgen3rxupdatefc(pcsgen3rxupdatefc),
		.pcsgen3syncsmen(pcsgen3syncsmen),
		.pld10grxalignclr(pld10grxalignclr),
		.pld10grxalignen(pld10grxalignen),
		.pld10grxalignval(pld10grxalignval),
		.pld10grxbitslip(pld10grxbitslip),
		.pld10grxblklock(pld10grxblklock),
		.pld10grxclkout(pld10grxclkout),
		.pld10grxclrbercount(pld10grxclrbercount),
		.pld10grxclrerrblkcnt(pld10grxclrerrblkcnt),
		.pld10grxcontrol(pld10grxcontrol),
		.pld10grxcrc32err(pld10grxcrc32err),
		.pld10grxdatavalid(pld10grxdatavalid),
		.pld10grxdiagerr(pld10grxdiagerr),
		.pld10grxdiagstatus(pld10grxdiagstatus),
		.pld10grxdispclr(pld10grxdispclr),
		.pld10grxempty(pld10grxempty),
		.pld10grxfifodel(pld10grxfifodel),
		.pld10grxfifoinsert(pld10grxfifoinsert),
		.pld10grxframelock(pld10grxframelock),
		.pld10grxhiber(pld10grxhiber),
		.pld10grxmfrmerr(pld10grxmfrmerr),
		.pld10grxoflwerr(pld10grxoflwerr),
		.pld10grxpempty(pld10grxpempty),
		.pld10grxpfull(pld10grxpfull),
		.pld10grxpldclk(pld10grxpldclk),
		.pld10grxpldrstn(pld10grxpldrstn),
		.pld10grxprbserr(pld10grxprbserr),
		.pld10grxprbserrclr(pld10grxprbserrclr),
		.pld10grxpyldins(pld10grxpyldins),
		.pld10grxrden(pld10grxrden),
		.pld10grxrdnegsts(pld10grxrdnegsts),
		.pld10grxrdpossts(pld10grxrdpossts),
		.pld10grxrxframe(pld10grxrxframe),
		.pld10grxscrmerr(pld10grxscrmerr),
		.pld10grxsherr(pld10grxsherr),
		.pld10grxskiperr(pld10grxskiperr),
		.pld10grxskipins(pld10grxskipins),
		.pld10grxsyncerr(pld10grxsyncerr),
		.pld8ga1a2k1k2flag(pld8ga1a2k1k2flag),
		.pld8ga1a2size(pld8ga1a2size),
		.pld8galignstatus(pld8galignstatus),
		.pld8gbistdone(pld8gbistdone),
		.pld8gbisterr(pld8gbisterr),
		.pld8gbitlocreven(pld8gbitlocreven),
		.pld8gbitslip(pld8gbitslip),
		.pld8gbyteordflag(pld8gbyteordflag),
		.pld8gbytereven(pld8gbytereven),
		.pld8gbytordpld(pld8gbytordpld),
		.pld8gcmpfifourstn(pld8gcmpfifourstn),
		.pld8gemptyrmf(pld8gemptyrmf),
		.pld8gemptyrx(pld8gemptyrx),
		.pld8gencdt(pld8gencdt),
		.pld8gfullrmf(pld8gfullrmf),
		.pld8gfullrx(pld8gfullrx),
		.pld8gphfifourstrxn(pld8gphfifourstrxn),
		.pld8gpldrxclk(pld8gpldrxclk),
		.pld8gpolinvrx(pld8gpolinvrx),
		.pld8grdenablermf(pld8grdenablermf),
		.pld8grdenablerx(pld8grdenablerx),
		.pld8grlvlt(pld8grlvlt),
		.pld8grxblkstart(pld8grxblkstart),
		.pld8grxclkout(pld8grxclkout),
		.pld8grxdatavalid(pld8grxdatavalid),
		.pld8grxsynchdr(pld8grxsynchdr),
		.pld8grxurstpcsn(pld8grxurstpcsn),
		.pld8gsignaldetectout(pld8gsignaldetectout),
		.pld8gsyncsmeninput(pld8gsyncsmeninput),
		.pld8gwaboundary(pld8gwaboundary),
		.pld8gwrdisablerx(pld8gwrdisablerx),
		.pld8gwrenablermf(pld8gwrenablermf),
		.pldclkdiv33txorrx(pldclkdiv33txorrx),
		.pldgen3rxrstn(pldgen3rxrstn),
		.pldgen3rxupdatefc(pldgen3rxupdatefc),
		.pldrxclkslipin(pldrxclkslipin),
		.pldrxclkslipout(pldrxclkslipout),
		.pldrxiqclkout(pldrxiqclkout),
		.pldrxpmarstbin(pldrxpmarstbin),
		.pldrxpmarstbout(pldrxpmarstbout),
		.pmaclkdiv33txorrx(pmaclkdiv33txorrx),
		.pmarxplllock(pmarxplllock),
		.reset(reset),
		.rstsel(rstsel),
		.usrrstsel(usrrstsel)
	);
endmodule
