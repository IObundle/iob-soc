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


// Verilog RBC parameter resolution wrapper for stratixv_hssi_10g_rx_pcs
//

`timescale 1 ns / 1 ps

//`undef ALTERA_RESERVED_QIS_ES

module sv_hssi_10g_rx_pcs_rbc #(
	// unconstrained parameters
	parameter prot_mode = "<auto_single>",	// basic_mode, disable_mode, interlaken_mode, sfis_mode, teng_1588_mode, teng_baser_mode, teng_sdi_mode, test_prbs_mode, test_prp_mode
	parameter sup_mode = "<auto_single>",	// engineering_mode, engr_mode, stretch_mode, user_mode

	// extra unconstrained parameters found in atom map
	parameter avmm_group_channel_index = 0,	// 0..2
	parameter ber_bit_err_total_cnt = "bit_err_total_cnt_10g",	// bit_err_total_cnt_10g
	parameter ber_xus_timer_window_user = 21'b100110001001010,	// 21
	parameter bitslip_wait_cnt_user = 1,	// 0..7, blksync_3
	parameter blksync_bitslip_wait_cnt_user = 3'b1,	// 3
	parameter channel_number = 0,	// 0..65
	parameter crcchk_init = "<auto_single>",	// crcchk_init_user_setting, crcchk_int
	parameter crcchk_init_user = 32'b11111111111111111111111111111111,
	parameter dispchk_rd_level_user = 8'b1100000,	// 8
	parameter frmgen_diag_word = 64'h6400000000000000,
	parameter frmgen_scrm_word = 64'h2800000000000000,
	parameter frmgen_skip_word = 64'h1e1e1e1e1e1e1e1e,
	parameter frmgen_sync_word = 64'h78f678f678f678f6,
	parameter frmsync_enum_scrm = "enum_scrm_default",	// enum_scrm_default
	parameter frmsync_enum_sync = "enum_sync_default",	// enum_sync_default
	parameter frmsync_knum_sync = "knum_sync_default",	// knum_sync_default
	parameter frmsync_mfrm_length_user = 2048,	// 0..8191
	parameter rxfifo_empty = 0,
	parameter rxfifo_full = 31,
	parameter skip_ctrl = "skip_ctrl_default",	// skip_ctrl_default
	parameter test_bus_mode = "tx",	// rx, tx
	parameter use_default_base_address = "true",	// false, true
	parameter user_base_address = 0,	// 0..2047

	// constrained parameters
	parameter gb_rx_idwidth = "<auto_single>",	// width_32, width_32_default, width_40, width_64
	parameter gb_rx_odwidth = "<auto_single>",	// width_32, width_40, width_50, width_64, width_66, width_67
	parameter lpbk_mode = "<auto_single>",	// lpbk_dis, lpbk_en
	parameter rx_dfx_lpbk = "<auto_single>",	// dfx_lpbk_dis, dfx_lpbk_en
	parameter master_clk_sel = "<auto_single>",	// master_refclk_dig, master_rx_pma_clk, master_tx_pma_clk
	parameter blksync_bypass = "<auto_single>",	// blksync_bypass_dis, blksync_bypass_en
	parameter rxfifo_mode = "<auto_single>",	// clk_comp, clk_comp_10g, clk_comp_basic, generic, generic_basic, generic_interlaken, phase_comp, phase_comp_dv, register_mode
	parameter rd_clk_sel = "<auto_single>",	// rd_refclk_dig, rd_rx_pld_clk, rd_rx_pma_clk
	parameter gbexp_clken = "<auto_single>",	// gbexp_clk_dis, gbexp_clk_en
	parameter dispchk_clken = "<auto_single>",	// dispchk_clk_dis, dispchk_clk_en
	parameter frmsync_bypass = "<auto_single>",	// frmsync_bypass_dis, frmsync_bypass_en
	parameter dec64b66b_clken = "<auto_single>",	// dec64b66b_clk_dis, dec64b66b_clk_en
	parameter dec_64b66b_rxsm_bypass = "<auto_single>",	// dec_64b66b_rxsm_bypass_dis, dec_64b66b_rxsm_bypass_en
	parameter wrfifo_clken = "<auto_single>",	// wrfifo_clk_dis, wrfifo_clk_en
	parameter descrm_clken = "<auto_single>",	// descrm_clk_dis, descrm_clk_en
	parameter frmsync_clken = "<auto_single>",	// frmsync_clk_dis, frmsync_clk_en
	parameter descrm_bypass = "<auto_single>",	// descrm_bypass_dis, descrm_bypass_en
	parameter blksync_clken = "<auto_single>",	// blksync_clk_dis, blksync_clk_en
	parameter crcchk_bypass = "<auto_single>",	// crcchk_bypass_dis, crcchk_bypass_en
	parameter rx_sm_bypass = "<auto_single>",	// rx_sm_bypass_dis, rx_sm_bypass_en
	parameter prbs_clken = "<auto_single>",	// prbs_clk_dis, prbs_clk_en
	parameter ber_clken = "<auto_single>",	// ber_clk_dis, ber_clk_en
	parameter dispchk_bypass = "<auto_single>",	// dispchk_bypass_dis, dispchk_bypass_en
	parameter rand_clken = "<auto_single>",	// rand_clk_dis, rand_clk_en
	parameter rdfifo_clken = "<auto_single>",	// rdfifo_clk_dis, rdfifo_clk_en
	parameter crcchk_clken = "<auto_single>",	// crcchk_clk_dis, crcchk_clk_en
	parameter fast_path = "<auto_single>",	// fast_path_dis, fast_path_en
	parameter bit_reverse = "<auto_single>",	// bit_reverse_dis, bit_reverse_en
	parameter data_bit_reverse = "<auto_single>",	// data_bit_reverse_dis, data_bit_reverse_en
	parameter ctrl_bit_reverse = "<auto_single>",	// ctrl_bit_reverse_dis, ctrl_bit_reverse_en
	parameter rx_sh_location = "<auto_single>",	// lsb, msb
	parameter full_flag_type = "<auto_single>",	// full_rd_side, full_wr_side, ppfull_rd_side, ppfull_wr_side
	parameter empty_flag_type = "<auto_single>",	// empty_rd_side, empty_wr_side, ppempty_rd_side, ppempty_wr_side
	parameter pfull_flag_type = "<auto_single>",	// pfull_rd_side, pfull_wr_side
	parameter pempty_flag_type = "<auto_single>",	// pempty_rd_side, pempty_wr_side
	parameter fifo_stop_rd = "<auto_single>",	// n_rd_empty, rd_empty
	parameter fifo_stop_wr = "<auto_single>",	// n_wr_full, wr_full
	parameter force_align = "<auto_single>",	// force_align_dis, force_align_en
	parameter control_del = "<auto_single>",	// control_del_all, control_del_none
	parameter align_del = "<auto_single>",	// align_del_dis, align_del_en
	parameter rxfifo_pempty = 7,	// pempty1, pempty10, pempty2, pempty3, pempty4, pempty5, pempty6, pempty7, pempty8, pempty9
	parameter rxfifo_pfull = 23,	// 23, 24, 25, 26, 27, 28
	parameter rx_fifo_write_ctrl = "<auto_single>",	// blklock_ignore, blklock_stops
	parameter rx_true_b2b = "<auto_single>",	// b2b, single
	parameter blksync_knum_sh_cnt_postlock = "<auto_single>",	// knum_sh_cnt_postlock_10g, knum_sh_cnt_postlock_40g100g
	parameter blksync_bitslip_type = "<auto_single>",	// bitslip_comb, bitslip_reg
	parameter blksync_bitslip_wait_type = "<auto_single>",	// bitslip_cnt, bitslip_match
	parameter blksync_enum_invalid_sh_cnt = "<auto_single>",	// enum_invalid_sh_cnt_10g, enum_invalid_sh_cnt_40g100g
	parameter blksync_pipeln = "<auto_single>",	// blksync_pipeln_dis, blksync_pipeln_en
	parameter blksync_bitslip_wait_cnt = "<auto_single>",	// bitslip_wait_cnt_max, bitslip_wait_cnt_min, bitslip_wait_cnt_user_setting
	parameter blksync_knum_sh_cnt_prelock = "<auto_single>",	// knum_sh_cnt_prelock_10g, knum_sh_cnt_prelock_40g100g
	parameter rx_signal_ok_sel = "<auto_single>",	// nonsync_ver, synchronized_ver
	parameter dis_signal_ok = "<auto_single>",	// dis_signal_ok_dis, dis_signal_ok_en
	parameter dispchk_pipeln = "<auto_single>",	// dispchk_pipeln_dis, dispchk_pipeln_en
	parameter dispchk_rd_level = "<auto_single>",	// dispchk_rd_level_max, dispchk_rd_level_min, dispchk_rd_level_user_setting
	parameter rx_sm_pipeln = "<auto_single>",	// rx_sm_pipeln_dis, rx_sm_pipeln_en
	parameter rx_sm_hiber = "<auto_single>",	// rx_sm_hiber_dis, rx_sm_hiber_en
	parameter ber_xus_timer_window = "<auto_single>",	// xus_timer_window_10g, xus_timer_window_user_setting
	parameter frmsync_flag_type = "<auto_single>",	// all_framing_words, location_only
	parameter frmsync_pipeln = "<auto_single>",	// frmsync_pipeln_dis, frmsync_pipeln_en
	parameter frmsync_mfrm_length = "<auto_single>",	// frmsync_mfrm_length_max, frmsync_mfrm_length_min, frmsync_mfrm_length_user_setting
	parameter crcflag_pipeln = "<auto_single>",	// crcflag_pipeln_dis, crcflag_pipeln_en
	parameter crcchk_pipeln = "<auto_single>",	// crcchk_pipeln_dis, crcchk_pipeln_en
	parameter crcchk_inv = "<auto_single>",	// crcchk_inv_dis, crcchk_inv_en
	parameter descrm_mode = "<auto_single>",	// async, sync
	parameter rx_scrm_width = "<auto_single>",	// bit64, bit66, bit67
	parameter gb_sel_mode = "<auto_single>",	// external, internal
	parameter test_mode = "<auto_single>",	// prbs_23, prbs_31, prbs_7, prbs_9, pseudo_random, test_off
	parameter rx_prbs_mask = "<auto_single>",	// prbsmask1024, prbsmask128, prbsmask256, prbsmask512
	parameter stretch_en = "<auto_single>",	// stretch_dis, stretch_en
	parameter stretch_type = "<auto_single>",	// stretch_auto, stretch_custom
	parameter stretch_num_stages = "<auto_single>",	// one_stage, three_stage, two_stage, zero_stage
	parameter iqtxrx_clkout_sel = "<auto_single>",	// iq_rx_clk_out, iq_rx_pma_clk_div33
	parameter bitslip_mode = "<auto_single>",	// bitslip_dis, bitslip_en
	parameter rx_testbus_sel = "<auto_single>",	// ber_testbus, blank_testbus, blksync_testbus1, blksync_testbus2, crc32_chk_testbus1, crc32_chk_testbus2, dec64b66b_testbus, descramble_testbus, descramble_testbus1, descramble_testbus2, disp_chk_testbus1, disp_chk_testbus2, frame_sync_testbus1, frame_sync_testbus2, gearbox_exp_testbus, gearbox_exp_testbus1, gearbox_exp_testbus2, prbs_ver_xg_testbus, random_ver_testbus, rx_fifo_testbus1, rx_fifo_testbus2, rxsm_testbus
	parameter rx_polarity_inv = "<auto_single>"	// invert_disable, invert_enable
) (
	// ports
	input  wire   [10:0]	avmmaddress,
	input  wire    [1:0]	avmmbyteen,
	input  wire         	avmmclk,
	input  wire         	avmmread,
	output wire   [15:0]	avmmreaddata,
	input  wire         	avmmrstn,
	input  wire         	avmmwrite,
	input  wire   [15:0]	avmmwritedata,
	output wire         	blockselect,
	input  wire    [9:0]	dfxlpbkcontrolin,
	input  wire   [63:0]	dfxlpbkdatain,
	input  wire         	dfxlpbkdatavalidin,
	input  wire         	hardresetn,
	input  wire   [79:0]	lpbkdatain,
	input  wire         	pmaclkdiv33txorrx,
	input  wire         	refclkdig,
	input  wire         	rxalignclr,
	input  wire         	rxalignen,
	output wire         	rxalignval,
	input  wire         	rxbitslip,
	output wire         	rxblocklock,
	output wire         	rxclkiqout,
	output wire         	rxclkout,
	input  wire         	rxclrbercount,
	input  wire         	rxclrerrorblockcount,
	output wire    [9:0]	rxcontrol,
	output wire         	rxcrc32error,
	output wire   [63:0]	rxdata,
	output wire         	rxdatavalid,
	output wire         	rxdiagnosticerror,
	output wire    [1:0]	rxdiagnosticstatus,
	input  wire         	rxdisparityclr,
	output wire         	rxfifodel,
	output wire         	rxfifoempty,
	output wire         	rxfifofull,
	output wire         	rxfifoinsert,
	output wire         	rxfifopartialempty,
	output wire         	rxfifopartialfull,
	output wire         	rxframelock,
	output wire         	rxhighber,
	output wire         	rxmetaframeerror,
	output wire         	rxpayloadinserted,
	input  wire         	rxpldclk,
	input  wire         	rxpldrstn,
	input  wire         	rxpmaclk,
	input  wire   [79:0]	rxpmadata,
	input  wire         	rxpmadatavalid,
	output wire         	rxprbsdone,
	output wire         	rxprbserr,
	input  wire         	rxprbserrorclr,
	input  wire         	rxrden,
	output wire         	rxrdnegsts,
	output wire         	rxrdpossts,
	output wire         	rxrxframe,
	output wire         	rxscramblererror,
	output wire         	rxskipinserted,
	output wire         	rxskipworderror,
	output wire         	rxsyncheadererror,
	output wire         	rxsyncworderror,
	output wire   [19:0]	rxtestdata,
	output wire         	syncdatain,
	input  wire         	txpmaclk
);
	import altera_xcvr_functions::*;

/*
initial begin
`ifdef ALTERA_RESERVED_QIS_ES
   $display("Critical Warning: ------------ ES DEVICE --------");
`else
   $display("Critical Warning: ------------ PROD DEVICE --------");
`endif
end
*/

`ifdef ALTERA_RESERVED_QIS_ES


   //========================ES RULES START==============================================================================

   localparam silicon_rev_local = "es";
   

	// prot_mode external parameter (no RBC) >> ES <<
	localparam rbc_all_prot_mode = "(basic_mode,disable_mode,interlaken_mode,sfis_mode,teng_1588_mode,teng_baser_mode,teng_sdi_mode,test_prbs_mode,test_prp_mode)";
	localparam rbc_any_prot_mode = "disable_mode";
	localparam fnl_prot_mode = (prot_mode == "<auto_any>" || prot_mode == "<auto_single>") ? rbc_any_prot_mode : prot_mode;

	// sup_mode external parameter (no RBC) >> ES <<
	localparam rbc_all_sup_mode = "(engineering_mode,engr_mode,stretch_mode,user_mode)";
	localparam rbc_any_sup_mode = "user_mode";
	localparam fnl_sup_mode = (sup_mode == "<auto_any>" || sup_mode == "<auto_single>") ? rbc_any_sup_mode : sup_mode;

	// test_bus_mode external parameter (no RBC) >> ES <<
	localparam rbc_all_test_bus_mode = "(rx,tx)";
	localparam rbc_any_test_bus_mode = "tx";
	localparam fnl_test_bus_mode = (test_bus_mode == "<auto_any>" || test_bus_mode == "<auto_single>") ? rbc_any_test_bus_mode : test_bus_mode;

	// use_default_base_address external parameter (no RBC) >> ES <<
	localparam rbc_all_use_default_base_address = "(false,true)";
	localparam rbc_any_use_default_base_address = "true";
	localparam fnl_use_default_base_address = (use_default_base_address == "<auto_any>" || use_default_base_address == "<auto_single>") ? rbc_any_use_default_base_address : use_default_base_address;

	// gb_rx_idwidth, RBC-validated >> ES <<
	localparam rbc_all_gb_rx_idwidth = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("(width_32,width_40)")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("(width_32,width_40)")
			 : ((fnl_prot_mode == "sfis_mode")) ? ("(width_32,width_40)")
				 : ((fnl_prot_mode == "teng_sdi_mode")) ? ("width_40")
					 : ((fnl_prot_mode == "basic_mode")) ?
						(
							(fnl_sup_mode == "engineering_mode") ? ("(width_32,width_40,width_64)") : "(width_32,width_40,width_64)"
						)
						 : (fnl_prot_mode == "test_prbs_mode") ? ("(width_32,width_40)") : "width_32";
	localparam rbc_any_gb_rx_idwidth = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("width_32")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("width_32")
			 : ((fnl_prot_mode == "sfis_mode")) ? ("width_32")
				 : ((fnl_prot_mode == "teng_sdi_mode")) ? ("width_40")
					 : ((fnl_prot_mode == "basic_mode")) ?
						(
							(fnl_sup_mode == "engineering_mode") ? ("width_32") : "width_32"
						)
						 : (fnl_prot_mode == "test_prbs_mode") ? ("width_32") : "width_32";
	localparam fnl_gb_rx_idwidth = (gb_rx_idwidth == "<auto_any>" || gb_rx_idwidth == "<auto_single>") ? rbc_any_gb_rx_idwidth : gb_rx_idwidth;

	// gb_rx_odwidth, RBC-validated >> ES <<
	localparam rbc_all_gb_rx_odwidth = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("width_66")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("width_67")
			 : ((fnl_prot_mode == "sfis_mode")) ?
				(
					(fnl_gb_rx_idwidth == "width_32") ? ("(width_64,width_32)") : "(width_64,width_40)"
				)
				 : ((fnl_prot_mode == "teng_sdi_mode")) ?
					(
						((fnl_sup_mode == "engineering_mode")) ? ("(width_40,width_50)") : "width_50"
					)
					 : ((fnl_prot_mode == "basic_mode")) ?
						(
							(fnl_gb_rx_idwidth == "width_32") ? ("(width_32,width_64,width_66,width_67)")
							 : (fnl_gb_rx_idwidth == "width_40") ? ("(width_40,width_64,width_66,width_67)")
								 : (fnl_gb_rx_idwidth == "width_64") ? ("width_64") : "width_64"
						)
						 : (fnl_gb_rx_idwidth == "width_32") ? ("width_32")
							 : (fnl_gb_rx_idwidth == "width_40") ? ("width_40") : "width_64";
	localparam rbc_any_gb_rx_odwidth = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("width_66")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("width_67")
			 : ((fnl_prot_mode == "sfis_mode")) ?
				(
					(fnl_gb_rx_idwidth == "width_32") ? ("width_64") : "width_64"
				)
				 : ((fnl_prot_mode == "teng_sdi_mode")) ?
					(
						((fnl_sup_mode == "engineering_mode")) ? ("width_40") : "width_50"
					)
					 : ((fnl_prot_mode == "basic_mode")) ?
						(
							(fnl_gb_rx_idwidth == "width_32") ? ("width_32")
							 : (fnl_gb_rx_idwidth == "width_40") ? ("width_40")
								 : (fnl_gb_rx_idwidth == "width_64") ? ("width_64") : "width_64"
						)
						 : (fnl_gb_rx_idwidth == "width_32") ? ("width_32")
							 : (fnl_gb_rx_idwidth == "width_40") ? ("width_40") : "width_64";
	localparam fnl_gb_rx_odwidth = (gb_rx_odwidth == "<auto_any>" || gb_rx_odwidth == "<auto_single>") ? rbc_any_gb_rx_odwidth : gb_rx_odwidth;

	// lpbk_mode, RBC-validated >> ES <<
	localparam rbc_all_lpbk_mode = ((fnl_prot_mode == "test_prp_mode")) ? ("(lpbk_en,lpbk_dis)")
		 : ((fnl_sup_mode == "engineering_mode")) ? ("(lpbk_en,lpbk_dis)") : "lpbk_dis";
	localparam rbc_any_lpbk_mode = ((fnl_prot_mode == "test_prp_mode")) ? ("lpbk_dis")
		 : ((fnl_sup_mode == "engineering_mode")) ? ("lpbk_dis") : "lpbk_dis";
	localparam fnl_lpbk_mode = (lpbk_mode == "<auto_any>" || lpbk_mode == "<auto_single>") ? rbc_any_lpbk_mode : lpbk_mode;

	// rx_dfx_lpbk, RBC-validated >> ES <<
	localparam rbc_all_rx_dfx_lpbk = ((fnl_prot_mode == "test_prp_mode")) ? ("dfx_lpbk_dis")
		 : ((fnl_sup_mode == "engineering_mode")) ? ("(dfx_lpbk_en,dfx_lpbk_dis)") : "dfx_lpbk_dis";
	localparam rbc_any_rx_dfx_lpbk = ((fnl_prot_mode == "test_prp_mode")) ? ("dfx_lpbk_dis")
		 : ((fnl_sup_mode == "engineering_mode")) ? ("dfx_lpbk_dis") : "dfx_lpbk_dis";
	localparam fnl_rx_dfx_lpbk = (rx_dfx_lpbk == "<auto_any>" || rx_dfx_lpbk == "<auto_single>") ? rbc_any_rx_dfx_lpbk : rx_dfx_lpbk;

	// master_clk_sel, RBC-validated >> ES <<
	localparam rbc_all_master_clk_sel = (fnl_sup_mode == "engineering_mode") ?
		(
			(fnl_lpbk_mode == "lpbk_en" || fnl_rx_dfx_lpbk == "dfx_lpbk_en") ? ("(master_tx_pma_clk,master_refclk_dig)") : "(master_rx_pma_clk,master_refclk_dig)"
		)
		 : (fnl_lpbk_mode == "lpbk_en") ? ("master_tx_pma_clk") : "master_rx_pma_clk";
	localparam rbc_any_master_clk_sel = (fnl_sup_mode == "engineering_mode") ?
		(
			(fnl_lpbk_mode == "lpbk_en" || fnl_rx_dfx_lpbk == "dfx_lpbk_en") ? ("master_tx_pma_clk") : "master_rx_pma_clk"
		)
		 : (fnl_lpbk_mode == "lpbk_en") ? ("master_tx_pma_clk") : "master_rx_pma_clk";
	localparam fnl_master_clk_sel = (master_clk_sel == "<auto_any>" || master_clk_sel == "<auto_single>") ? rbc_any_master_clk_sel : master_clk_sel;

	// blksync_bypass, RBC-validated >> ES <<
	localparam rbc_all_blksync_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("blksync_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("blksync_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("blksync_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") ? ("(blksync_bypass_dis,blksync_bypass_en)") : "blksync_bypass_en"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("blksync_bypass_en") : "blksync_bypass_en";
	localparam rbc_any_blksync_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("blksync_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("blksync_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("blksync_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") ? ("blksync_bypass_dis") : "blksync_bypass_en"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("blksync_bypass_en") : "blksync_bypass_en";
	localparam fnl_blksync_bypass = (blksync_bypass == "<auto_any>" || blksync_bypass == "<auto_single>") ? rbc_any_blksync_bypass : blksync_bypass;

	// rxfifo_mode, RBC-validated >> ES <<
	localparam rbc_all_rxfifo_mode = ((fnl_prot_mode == "interlaken_mode")) ? ("generic_interlaken")
		 : ((fnl_prot_mode == "teng_baser_mode")) ?
			(
				((fnl_sup_mode == "engineering_mode")) ? ("(clk_comp_10g,phase_comp)") : "clk_comp_10g"
			)
			 : (fnl_prot_mode == "teng_sdi_mode") ?
				(
					(fnl_sup_mode == "engineering_mode") ? ("(register_mode,phase_comp,phase_comp_dv)") : "phase_comp"
				)
				 : ((fnl_prot_mode == "basic_mode")) ?
					(
						(fnl_sup_mode == "engineering_mode") ?
						(
							(fnl_blksync_bypass == "blksync_bypass_dis") ? ("(generic_basic,register_mode,phase_comp,phase_comp_dv,clk_comp_basic)")
							 : ((fnl_gb_rx_odwidth == "width_32" && fnl_gb_rx_idwidth == "width_32") ||
          (fnl_gb_rx_odwidth == "width_40" && fnl_gb_rx_idwidth == "width_40") ||
          (fnl_gb_rx_odwidth == "width_64" && fnl_gb_rx_idwidth == "width_64")) ? ("(generic_basic,register_mode,phase_comp)") : "(generic_basic,register_mode,phase_comp,phase_comp_dv)"
						) : "(register_mode,phase_comp)"
					)
					 : ((fnl_prot_mode == "teng_1588_mode")) ? ("register_mode") : "phase_comp";
	localparam rbc_any_rxfifo_mode = ((fnl_prot_mode == "interlaken_mode")) ? ("generic_interlaken")
		 : ((fnl_prot_mode == "teng_baser_mode")) ?
			(
				((fnl_sup_mode == "engineering_mode")) ? ("phase_comp") : "clk_comp_10g"
			)
			 : (fnl_prot_mode == "teng_sdi_mode") ?
				(
					(fnl_sup_mode == "engineering_mode") ? ("phase_comp") : "phase_comp"
				)
				 : ((fnl_prot_mode == "basic_mode")) ?
					(
						(fnl_sup_mode == "engineering_mode") ?
						(
							(fnl_blksync_bypass == "blksync_bypass_dis") ? ("phase_comp")
							 : ((fnl_gb_rx_odwidth == "width_32" && fnl_gb_rx_idwidth == "width_32") ||
          (fnl_gb_rx_odwidth == "width_40" && fnl_gb_rx_idwidth == "width_40") ||
          (fnl_gb_rx_odwidth == "width_64" && fnl_gb_rx_idwidth == "width_64")) ? ("phase_comp") : "phase_comp"
						) : "phase_comp"
					)
					 : ((fnl_prot_mode == "teng_1588_mode")) ? ("register_mode") : "phase_comp";
	localparam fnl_rxfifo_mode = (rxfifo_mode == "<auto_any>" || rxfifo_mode == "<auto_single>") ? rbc_any_rxfifo_mode : rxfifo_mode;

	// rd_clk_sel, RBC-validated >> ES <<
	localparam rbc_all_rd_clk_sel = (fnl_rxfifo_mode == "register_mode") ?
		(
			(fnl_master_clk_sel == "master_refclk_dig") ? ("rd_refclk_dig") : "rd_rx_pma_clk"
		) : "rd_rx_pld_clk";
	localparam rbc_any_rd_clk_sel = (fnl_rxfifo_mode == "register_mode") ?
		(
			(fnl_master_clk_sel == "master_refclk_dig") ? ("rd_refclk_dig") : "rd_rx_pma_clk"
		) : "rd_rx_pld_clk";
	localparam fnl_rd_clk_sel = (rd_clk_sel == "<auto_any>" || rd_clk_sel == "<auto_single>") ? rbc_any_rd_clk_sel : rd_clk_sel;

	// gbexp_clken, RBC-validated >> ES <<
	localparam rbc_all_gbexp_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("gbexp_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("gbexp_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("gbexp_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("gbexp_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("gbexp_clk_en") : "gbexp_clk_dis";
	localparam rbc_any_gbexp_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("gbexp_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("gbexp_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("gbexp_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("gbexp_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("gbexp_clk_en") : "gbexp_clk_dis";
	localparam fnl_gbexp_clken = (gbexp_clken == "<auto_any>" || gbexp_clken == "<auto_single>") ? rbc_any_gbexp_clken : gbexp_clken;

	// dispchk_clken, RBC-validated >> ES <<
	localparam rbc_all_dispchk_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dispchk_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispchk_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dispchk_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("dispchk_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dispchk_clk_en") : "dispchk_clk_dis";
	localparam rbc_any_dispchk_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dispchk_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispchk_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dispchk_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("dispchk_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dispchk_clk_en") : "dispchk_clk_dis";
	localparam fnl_dispchk_clken = (dispchk_clken == "<auto_any>" || dispchk_clken == "<auto_single>") ? rbc_any_dispchk_clken : dispchk_clken;

	// frmsync_bypass, RBC-validated >> ES <<
	localparam rbc_all_frmsync_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("frmsync_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmsync_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("frmsync_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("frmsync_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("frmsync_bypass_en") : "frmsync_bypass_en";
	localparam rbc_any_frmsync_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("frmsync_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmsync_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("frmsync_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("frmsync_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("frmsync_bypass_en") : "frmsync_bypass_en";
	localparam fnl_frmsync_bypass = (frmsync_bypass == "<auto_any>" || frmsync_bypass == "<auto_single>") ? rbc_any_frmsync_bypass : frmsync_bypass;

	// dec64b66b_clken, RBC-validated >> ES <<
	localparam rbc_all_dec64b66b_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dec64b66b_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dec64b66b_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dec64b66b_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("dec64b66b_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dec64b66b_clk_en") : "dec64b66b_clk_dis";
	localparam rbc_any_dec64b66b_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dec64b66b_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dec64b66b_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dec64b66b_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("dec64b66b_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dec64b66b_clk_en") : "dec64b66b_clk_dis";
	localparam fnl_dec64b66b_clken = (dec64b66b_clken == "<auto_any>" || dec64b66b_clken == "<auto_single>") ? rbc_any_dec64b66b_clken : dec64b66b_clken;

	// dec_64b66b_rxsm_bypass, RBC-validated >> ES <<
	localparam rbc_all_dec_64b66b_rxsm_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dec_64b66b_rxsm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dec_64b66b_rxsm_bypass_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dec_64b66b_rxsm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("dec_64b66b_rxsm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dec_64b66b_rxsm_bypass_en") : "dec_64b66b_rxsm_bypass_en";
	localparam rbc_any_dec_64b66b_rxsm_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dec_64b66b_rxsm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dec_64b66b_rxsm_bypass_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dec_64b66b_rxsm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("dec_64b66b_rxsm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dec_64b66b_rxsm_bypass_en") : "dec_64b66b_rxsm_bypass_en";
	localparam fnl_dec_64b66b_rxsm_bypass = (dec_64b66b_rxsm_bypass == "<auto_any>" || dec_64b66b_rxsm_bypass == "<auto_single>") ? rbc_any_dec_64b66b_rxsm_bypass : dec_64b66b_rxsm_bypass;

	// wrfifo_clken, RBC-validated >> ES <<
	localparam rbc_all_wrfifo_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("wrfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("wrfifo_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("wrfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("wrfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("wrfifo_clk_en") : "wrfifo_clk_dis";
	localparam rbc_any_wrfifo_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("wrfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("wrfifo_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("wrfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("wrfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("wrfifo_clk_en") : "wrfifo_clk_dis";
	localparam fnl_wrfifo_clken = (wrfifo_clken == "<auto_any>" || wrfifo_clken == "<auto_single>") ? rbc_any_wrfifo_clken : wrfifo_clken;

	// descrm_clken, RBC-validated >> ES <<
	localparam rbc_all_descrm_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("descrm_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("descrm_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("descrm_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") ?
						(
							(fnl_sup_mode == "engineering_mode") ? ("descrm_clk_en") : "descrm_clk_dis"
						) : "descrm_clk_dis"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("descrm_clk_en") : "descrm_clk_dis";
	localparam rbc_any_descrm_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("descrm_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("descrm_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("descrm_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") ?
						(
							(fnl_sup_mode == "engineering_mode") ? ("descrm_clk_en") : "descrm_clk_dis"
						) : "descrm_clk_dis"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("descrm_clk_en") : "descrm_clk_dis";
	localparam fnl_descrm_clken = (descrm_clken == "<auto_any>" || descrm_clken == "<auto_single>") ? rbc_any_descrm_clken : descrm_clken;

	// frmsync_clken, RBC-validated >> ES <<
	localparam rbc_all_frmsync_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("frmsync_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmsync_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("frmsync_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("frmsync_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("frmsync_clk_en") : "frmsync_clk_dis";
	localparam rbc_any_frmsync_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("frmsync_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmsync_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("frmsync_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("frmsync_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("frmsync_clk_en") : "frmsync_clk_dis";
	localparam fnl_frmsync_clken = (frmsync_clken == "<auto_any>" || frmsync_clken == "<auto_single>") ? rbc_any_frmsync_clken : frmsync_clken;

	// descrm_bypass, RBC-validated >> ES <<
	localparam rbc_all_descrm_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("descrm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("descrm_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("descrm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") ?
						(
							(fnl_sup_mode == "engineering_mode") ? ("(descrm_bypass_en,descrm_bypass_dis)") : "descrm_bypass_en"
						) : "descrm_bypass_en"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("descrm_bypass_en") : "descrm_bypass_en";
	localparam rbc_any_descrm_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("descrm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("descrm_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("descrm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") ?
						(
							(fnl_sup_mode == "engineering_mode") ? ("descrm_bypass_en") : "descrm_bypass_en"
						) : "descrm_bypass_en"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("descrm_bypass_en") : "descrm_bypass_en";
	localparam fnl_descrm_bypass = (descrm_bypass == "<auto_any>" || descrm_bypass == "<auto_single>") ? rbc_any_descrm_bypass : descrm_bypass;

	// blksync_clken, RBC-validated >> ES <<
	localparam rbc_all_blksync_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("blksync_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("blksync_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("blksync_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") ? ("blksync_clk_en") : "blksync_clk_dis"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("blksync_clk_en") : "blksync_clk_dis";
	localparam rbc_any_blksync_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("blksync_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("blksync_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("blksync_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") ? ("blksync_clk_en") : "blksync_clk_dis"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("blksync_clk_en") : "blksync_clk_dis";
	localparam fnl_blksync_clken = (blksync_clken == "<auto_any>" || blksync_clken == "<auto_single>") ? rbc_any_blksync_clken : blksync_clken;

	// crcchk_bypass, RBC-validated >> ES <<
	localparam rbc_all_crcchk_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("crcchk_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcchk_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("crcchk_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("crcchk_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("crcchk_bypass_en") : "crcchk_bypass_en";
	localparam rbc_any_crcchk_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("crcchk_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcchk_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("crcchk_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("crcchk_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("crcchk_bypass_en") : "crcchk_bypass_en";
	localparam fnl_crcchk_bypass = (crcchk_bypass == "<auto_any>" || crcchk_bypass == "<auto_single>") ? rbc_any_crcchk_bypass : crcchk_bypass;

	// rx_sm_bypass, RBC-validated >> ES <<
	localparam rbc_all_rx_sm_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("rx_sm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rx_sm_bypass_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("rx_sm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("rx_sm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("rx_sm_bypass_en") : "rx_sm_bypass_en";
	localparam rbc_any_rx_sm_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("rx_sm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rx_sm_bypass_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("rx_sm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("rx_sm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("rx_sm_bypass_en") : "rx_sm_bypass_en";
	localparam fnl_rx_sm_bypass = (rx_sm_bypass == "<auto_any>" || rx_sm_bypass == "<auto_single>") ? rbc_any_rx_sm_bypass : rx_sm_bypass;

	// prbs_clken, RBC-validated >> ES <<
	localparam rbc_all_prbs_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("prbs_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("prbs_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("prbs_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("prbs_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("prbs_clk_en") : "prbs_clk_dis";
	localparam rbc_any_prbs_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("prbs_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("prbs_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("prbs_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("prbs_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("prbs_clk_en") : "prbs_clk_dis";
	localparam fnl_prbs_clken = (prbs_clken == "<auto_any>" || prbs_clken == "<auto_single>") ? rbc_any_prbs_clken : prbs_clken;

	// ber_clken, RBC-validated >> ES <<
	localparam rbc_all_ber_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("ber_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("ber_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("ber_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("ber_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("ber_clk_en") : "ber_clk_dis";
	localparam rbc_any_ber_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("ber_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("ber_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("ber_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("ber_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("ber_clk_en") : "ber_clk_dis";
	localparam fnl_ber_clken = (ber_clken == "<auto_any>" || ber_clken == "<auto_single>") ? rbc_any_ber_clken : ber_clken;

	// dispchk_bypass, RBC-validated >> ES <<
	localparam rbc_all_dispchk_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dispchk_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispchk_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dispchk_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("dispchk_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dispchk_bypass_en") : "dispchk_bypass_en";
	localparam rbc_any_dispchk_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dispchk_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispchk_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dispchk_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("dispchk_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dispchk_bypass_en") : "dispchk_bypass_en";
	localparam fnl_dispchk_bypass = (dispchk_bypass == "<auto_any>" || dispchk_bypass == "<auto_single>") ? rbc_any_dispchk_bypass : dispchk_bypass;

	// rand_clken, RBC-validated >> ES <<
	localparam rbc_all_rand_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("rand_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rand_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("rand_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("rand_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("rand_clk_en") : "rand_clk_dis";
	localparam rbc_any_rand_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("rand_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rand_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("rand_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("rand_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("rand_clk_en") : "rand_clk_dis";
	localparam fnl_rand_clken = (rand_clken == "<auto_any>" || rand_clken == "<auto_single>") ? rbc_any_rand_clken : rand_clken;

	// rdfifo_clken, RBC-validated >> ES <<
	localparam rbc_all_rdfifo_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("rdfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rdfifo_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("rdfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("rdfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("rdfifo_clk_en") : "rdfifo_clk_dis";
	localparam rbc_any_rdfifo_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("rdfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rdfifo_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("rdfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("rdfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("rdfifo_clk_en") : "rdfifo_clk_dis";
	localparam fnl_rdfifo_clken = (rdfifo_clken == "<auto_any>" || rdfifo_clken == "<auto_single>") ? rbc_any_rdfifo_clken : rdfifo_clken;

	// crcchk_clken, RBC-validated >> ES <<
	localparam rbc_all_crcchk_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("crcchk_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcchk_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("crcchk_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("crcchk_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("crcchk_clk_en") : "crcchk_clk_dis";
	localparam rbc_any_crcchk_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("crcchk_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcchk_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("crcchk_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("crcchk_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("crcchk_clk_en") : "crcchk_clk_dis";
	localparam fnl_crcchk_clken = (crcchk_clken == "<auto_any>" || crcchk_clken == "<auto_single>") ? rbc_any_crcchk_clken : crcchk_clken;

	// fast_path, RBC-validated >> ES <<
	localparam rbc_all_fast_path = (fnl_descrm_bypass == "descrm_bypass_en" && fnl_frmsync_bypass == "frmsync_bypass_en" && fnl_crcchk_bypass == "crcchk_bypass_en" && fnl_dec_64b66b_rxsm_bypass == "dec_64b66b_rxsm_bypass_en" && fnl_dispchk_bypass == "dispchk_bypass_en" && fnl_blksync_bypass == "blksync_bypass_en") ? ("fast_path_en") : "fast_path_dis";
	localparam rbc_any_fast_path = (fnl_descrm_bypass == "descrm_bypass_en" && fnl_frmsync_bypass == "frmsync_bypass_en" && fnl_crcchk_bypass == "crcchk_bypass_en" && fnl_dec_64b66b_rxsm_bypass == "dec_64b66b_rxsm_bypass_en" && fnl_dispchk_bypass == "dispchk_bypass_en" && fnl_blksync_bypass == "blksync_bypass_en") ? ("fast_path_en") : "fast_path_dis";
	localparam fnl_fast_path = (fast_path == "<auto_any>" || fast_path == "<auto_single>") ? rbc_any_fast_path : fast_path;

	// bit_reverse, RBC-validated >> ES <<
	localparam rbc_all_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("bit_reverse_en")
			 : (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) ? ("(bit_reverse_en,bit_reverse_dis)") : "bit_reverse_dis";
	localparam rbc_any_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("bit_reverse_en")
			 : (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) ? ("bit_reverse_dis") : "bit_reverse_dis";
	localparam fnl_bit_reverse = (bit_reverse == "<auto_any>" || bit_reverse == "<auto_single>") ? rbc_any_bit_reverse : bit_reverse;

	// rx_sh_location, RBC-validated >> ES <<
	localparam rbc_all_rx_sh_location = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("lsb")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("msb")
			 : (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) ? ("(msb,lsb)") : "msb";
	localparam rbc_any_rx_sh_location = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("lsb")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("msb")
			 : (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) ? ("lsb") : "msb";
	localparam fnl_rx_sh_location = (rx_sh_location == "<auto_any>" || rx_sh_location == "<auto_single>") ? rbc_any_rx_sh_location : rx_sh_location;

	// force_align, RBC-validated >> ES <<
	localparam rbc_all_force_align = ((fnl_prot_mode == "interlaken_mode") &&
	   (fnl_sup_mode == "engineering_mode")) ? ("(force_align_en,force_align_dis)") : "force_align_dis";
	localparam rbc_any_force_align = ((fnl_prot_mode == "interlaken_mode") &&
	   (fnl_sup_mode == "engineering_mode")) ? ("force_align_dis") : "force_align_dis";
	localparam fnl_force_align = (force_align == "<auto_any>" || force_align == "<auto_single>") ? rbc_any_force_align : force_align;

	// control_del, RBC-validated >> ES <<
	localparam rbc_all_control_del = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(control_del_all,control_del_none)") : "control_del_all"
		) : "control_del_none";
	localparam rbc_any_control_del = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("control_del_all") : "control_del_all"
		) : "control_del_none";
	localparam fnl_control_del = (control_del == "<auto_any>" || control_del == "<auto_single>") ? rbc_any_control_del : control_del;

	// align_del, RBC-validated >> ES <<
	localparam rbc_all_align_del = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(align_del_dis,align_del_en)") : "align_del_en"
		) : "align_del_dis";
	localparam rbc_any_align_del = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("align_del_en") : "align_del_en"
		) : "align_del_dis";
	localparam fnl_align_del = (align_del == "<auto_any>" || align_del == "<auto_single>") ? rbc_any_align_del : align_del;

	// rx_fifo_write_ctrl, RBC-validated >> ES <<
	localparam rbc_all_rx_fifo_write_ctrl = (fnl_rxfifo_mode == "clk_comp_basic") ? ("(blklock_ignore,blklock_stops)") : "blklock_stops";
	localparam rbc_any_rx_fifo_write_ctrl = (fnl_rxfifo_mode == "clk_comp_basic") ? ("blklock_stops") : "blklock_stops";
	localparam fnl_rx_fifo_write_ctrl = (rx_fifo_write_ctrl == "<auto_any>" || rx_fifo_write_ctrl == "<auto_single>") ? rbc_any_rx_fifo_write_ctrl : rx_fifo_write_ctrl;

	// rx_true_b2b, RBC-validated >> ES <<
	localparam rbc_all_rx_true_b2b = (fnl_rxfifo_mode == "clk_comp_basic" || fnl_rxfifo_mode == "clk_comp_10g") ? ("(b2b,single)") : "b2b";
	localparam rbc_any_rx_true_b2b = (fnl_rxfifo_mode == "clk_comp_basic" || fnl_rxfifo_mode == "clk_comp_10g") ? ("b2b") : "b2b";
	localparam fnl_rx_true_b2b = (rx_true_b2b == "<auto_any>" || rx_true_b2b == "<auto_single>") ? rbc_any_rx_true_b2b : rx_true_b2b;

	// blksync_knum_sh_cnt_postlock, RBC-validated >> ES <<
	localparam rbc_all_blksync_knum_sh_cnt_postlock = "knum_sh_cnt_postlock_10g";
	localparam rbc_any_blksync_knum_sh_cnt_postlock = "knum_sh_cnt_postlock_10g";
	localparam fnl_blksync_knum_sh_cnt_postlock = (blksync_knum_sh_cnt_postlock == "<auto_any>" || blksync_knum_sh_cnt_postlock == "<auto_single>") ? rbc_any_blksync_knum_sh_cnt_postlock : blksync_knum_sh_cnt_postlock;

	// blksync_bitslip_type, RBC-validated >> ES <<
	localparam rbc_all_blksync_bitslip_type = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(bitslip_comb,bitslip_reg)") : "bitslip_comb"
		) : "bitslip_comb";
	localparam rbc_any_blksync_bitslip_type = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("bitslip_comb") : "bitslip_comb"
		) : "bitslip_comb";
	localparam fnl_blksync_bitslip_type = (blksync_bitslip_type == "<auto_any>" || blksync_bitslip_type == "<auto_single>") ? rbc_any_blksync_bitslip_type : blksync_bitslip_type;

	// blksync_bitslip_wait_type, RBC-validated >> ES <<
	localparam rbc_all_blksync_bitslip_wait_type = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(bitslip_match,bitslip_cnt)") : "bitslip_match"
		) : "bitslip_match";
	localparam rbc_any_blksync_bitslip_wait_type = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("bitslip_match") : "bitslip_match"
		) : "bitslip_match";
	localparam fnl_blksync_bitslip_wait_type = (blksync_bitslip_wait_type == "<auto_any>" || blksync_bitslip_wait_type == "<auto_single>") ? rbc_any_blksync_bitslip_wait_type : blksync_bitslip_wait_type;

	// blksync_enum_invalid_sh_cnt, RBC-validated >> ES <<
	localparam rbc_all_blksync_enum_invalid_sh_cnt = "enum_invalid_sh_cnt_10g";
	localparam rbc_any_blksync_enum_invalid_sh_cnt = "enum_invalid_sh_cnt_10g";
	localparam fnl_blksync_enum_invalid_sh_cnt = (blksync_enum_invalid_sh_cnt == "<auto_any>" || blksync_enum_invalid_sh_cnt == "<auto_single>") ? rbc_any_blksync_enum_invalid_sh_cnt : blksync_enum_invalid_sh_cnt;

	// blksync_pipeln, RBC-validated >> ES <<
	localparam rbc_all_blksync_pipeln = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(blksync_pipeln_en,blksync_pipeln_dis)") : "blksync_pipeln_dis"
		) : "blksync_pipeln_dis";
	localparam rbc_any_blksync_pipeln = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("blksync_pipeln_dis") : "blksync_pipeln_dis"
		) : "blksync_pipeln_dis";
	localparam fnl_blksync_pipeln = (blksync_pipeln == "<auto_any>" || blksync_pipeln == "<auto_single>") ? rbc_any_blksync_pipeln : blksync_pipeln;

	// blksync_bitslip_wait_cnt, RBC-validated >> ES <<
	localparam rbc_all_blksync_bitslip_wait_cnt = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode"  || fnl_prot_mode == "teng_1588_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67"))) ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(bitslip_wait_cnt_min,bitslip_wait_cnt_max,bitslip_wait_cnt_user_setting)") : "bitslip_wait_cnt_min"
		) : "bitslip_wait_cnt_min";
	localparam rbc_any_blksync_bitslip_wait_cnt = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode"  || fnl_prot_mode == "teng_1588_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67"))) ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("bitslip_wait_cnt_min") : "bitslip_wait_cnt_min"
		) : "bitslip_wait_cnt_min";
	localparam fnl_blksync_bitslip_wait_cnt = (blksync_bitslip_wait_cnt == "<auto_any>" || blksync_bitslip_wait_cnt == "<auto_single>") ? rbc_any_blksync_bitslip_wait_cnt : blksync_bitslip_wait_cnt;

	// blksync_knum_sh_cnt_prelock, RBC-validated >> ES <<
	localparam rbc_all_blksync_knum_sh_cnt_prelock = "knum_sh_cnt_prelock_10g";
	localparam rbc_any_blksync_knum_sh_cnt_prelock = "knum_sh_cnt_prelock_10g";
	localparam fnl_blksync_knum_sh_cnt_prelock = (blksync_knum_sh_cnt_prelock == "<auto_any>" || blksync_knum_sh_cnt_prelock == "<auto_single>") ? rbc_any_blksync_knum_sh_cnt_prelock : blksync_knum_sh_cnt_prelock;

	// rx_signal_ok_sel, RBC-validated >> ES <<
	localparam rbc_all_rx_signal_ok_sel = (fnl_prot_mode == "disable_mode" || fnl_lpbk_mode == "lpbk_en") ? ("synchronized_ver")
		 : (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("synchronized_ver") : "synchronized_ver";
	localparam rbc_any_rx_signal_ok_sel = (fnl_prot_mode == "disable_mode" || fnl_lpbk_mode == "lpbk_en") ? ("synchronized_ver")
		 : (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("synchronized_ver") : "synchronized_ver";
	localparam fnl_rx_signal_ok_sel = (rx_signal_ok_sel == "<auto_any>" || rx_signal_ok_sel == "<auto_single>") ? rbc_any_rx_signal_ok_sel : rx_signal_ok_sel;

	// dis_signal_ok, RBC-validated >> ES <<
	localparam rbc_all_dis_signal_ok = (fnl_prot_mode == "disable_mode" || fnl_lpbk_mode == "lpbk_en") ? ("dis_signal_ok_dis")
		 : (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("dis_signal_ok_en") : "(dis_signal_ok_dis,dis_signal_ok_en)";
	localparam rbc_any_dis_signal_ok = (fnl_prot_mode == "disable_mode" || fnl_lpbk_mode == "lpbk_en") ? ("dis_signal_ok_dis")
		 : (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("dis_signal_ok_en") : "dis_signal_ok_dis";
	localparam fnl_dis_signal_ok = (dis_signal_ok == "<auto_any>" || dis_signal_ok == "<auto_single>") ? rbc_any_dis_signal_ok : dis_signal_ok;

	// dispchk_pipeln, RBC-validated >> ES <<
	localparam rbc_all_dispchk_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(dispchk_pipeln_en,dispchk_pipeln_dis)") : "dispchk_pipeln_en"
		) : "dispchk_pipeln_en";
	localparam rbc_any_dispchk_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("dispchk_pipeln_dis") : "dispchk_pipeln_en"
		) : "dispchk_pipeln_en";
	localparam fnl_dispchk_pipeln = (dispchk_pipeln == "<auto_any>" || dispchk_pipeln == "<auto_single>") ? rbc_any_dispchk_pipeln : dispchk_pipeln;

	// dispchk_rd_level, RBC-validated >> ES <<
	localparam rbc_all_dispchk_rd_level = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(dispchk_rd_level_min,dispchk_rd_level_max,dispchk_rd_level_user_setting)") : "dispchk_rd_level_min"
		) : "dispchk_rd_level_min";
	localparam rbc_any_dispchk_rd_level = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("dispchk_rd_level_min") : "dispchk_rd_level_min"
		) : "dispchk_rd_level_min";
	localparam fnl_dispchk_rd_level = (dispchk_rd_level == "<auto_any>" || dispchk_rd_level == "<auto_single>") ? rbc_any_dispchk_rd_level : dispchk_rd_level;

	// rx_sm_pipeln, RBC-validated >> ES <<
	localparam rbc_all_rx_sm_pipeln = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(rx_sm_pipeln_en,rx_sm_pipeln_dis)") : "rx_sm_pipeln_en"
		) : "rx_sm_pipeln_en";
	localparam rbc_any_rx_sm_pipeln = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("rx_sm_pipeln_dis") : "rx_sm_pipeln_en"
		) : "rx_sm_pipeln_en";
	localparam fnl_rx_sm_pipeln = (rx_sm_pipeln == "<auto_any>" || rx_sm_pipeln == "<auto_single>") ? rbc_any_rx_sm_pipeln : rx_sm_pipeln;

	// rx_sm_hiber, RBC-validated >> ES <<
	localparam rbc_all_rx_sm_hiber = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(rx_sm_hiber_en,rx_sm_hiber_dis)") : "rx_sm_hiber_en"
		) : "rx_sm_hiber_en";
	localparam rbc_any_rx_sm_hiber = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("rx_sm_hiber_en") : "rx_sm_hiber_en"
		) : "rx_sm_hiber_en";
	localparam fnl_rx_sm_hiber = (rx_sm_hiber == "<auto_any>" || rx_sm_hiber == "<auto_single>") ? rbc_any_rx_sm_hiber : rx_sm_hiber;

	// ber_xus_timer_window, RBC-validated >> ES <<
	localparam rbc_all_ber_xus_timer_window = (fnl_sup_mode == "engineering_mode" && (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("(xus_timer_window_10g,xus_timer_window_user_setting)") : "xus_timer_window_10g";
	localparam rbc_any_ber_xus_timer_window = (fnl_sup_mode == "engineering_mode" && (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("xus_timer_window_10g") : "xus_timer_window_10g";
	localparam fnl_ber_xus_timer_window = (ber_xus_timer_window == "<auto_any>" || ber_xus_timer_window == "<auto_single>") ? rbc_any_ber_xus_timer_window : ber_xus_timer_window;

	// frmsync_flag_type, RBC-validated >> ES <<
	localparam rbc_all_frmsync_flag_type = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(all_framing_words,location_only)") : "all_framing_words"
		) : "all_framing_words";
	localparam rbc_any_frmsync_flag_type = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("all_framing_words") : "all_framing_words"
		) : "all_framing_words";
	localparam fnl_frmsync_flag_type = (frmsync_flag_type == "<auto_any>" || frmsync_flag_type == "<auto_single>") ? rbc_any_frmsync_flag_type : frmsync_flag_type;

	// frmsync_pipeln, RBC-validated >> ES <<
	localparam rbc_all_frmsync_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(frmsync_pipeln_en,frmsync_pipeln_dis)") : "frmsync_pipeln_en"
		) : "frmsync_pipeln_en";
	localparam rbc_any_frmsync_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("frmsync_pipeln_dis") : "frmsync_pipeln_en"
		) : "frmsync_pipeln_en";
	localparam fnl_frmsync_pipeln = (frmsync_pipeln == "<auto_any>" || frmsync_pipeln == "<auto_single>") ? rbc_any_frmsync_pipeln : frmsync_pipeln;

	// frmsync_mfrm_length, RBC-validated >> ES <<
	localparam rbc_all_frmsync_mfrm_length = (fnl_prot_mode == "interlaken_mode") ? ("(frmsync_mfrm_length_min,frmsync_mfrm_length_max,frmsync_mfrm_length_user_setting)") : "frmsync_mfrm_length_max";
	localparam rbc_any_frmsync_mfrm_length = (fnl_prot_mode == "interlaken_mode") ? ("frmsync_mfrm_length_min") : "frmsync_mfrm_length_max";
	localparam fnl_frmsync_mfrm_length = (frmsync_mfrm_length == "<auto_any>" || frmsync_mfrm_length == "<auto_single>") ? rbc_any_frmsync_mfrm_length : frmsync_mfrm_length;

	// crcflag_pipeln, RBC-validated >> ES <<
	localparam rbc_all_crcflag_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(crcflag_pipeln_dis,crcflag_pipeln_en)") : "crcflag_pipeln_en"
		) : "crcflag_pipeln_en";
	localparam rbc_any_crcflag_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("crcflag_pipeln_dis") : "crcflag_pipeln_en"
		) : "crcflag_pipeln_en";
	localparam fnl_crcflag_pipeln = (crcflag_pipeln == "<auto_any>" || crcflag_pipeln == "<auto_single>") ? rbc_any_crcflag_pipeln : crcflag_pipeln;

	// crcchk_pipeln, RBC-validated >> ES <<
	localparam rbc_all_crcchk_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(crcchk_pipeln_dis,crcchk_pipeln_en)") : "crcchk_pipeln_dis"
		) : "crcchk_pipeln_en";
	localparam rbc_any_crcchk_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("crcchk_pipeln_dis") : "crcchk_pipeln_dis"
		) : "crcchk_pipeln_en";
	localparam fnl_crcchk_pipeln = (crcchk_pipeln == "<auto_any>" || crcchk_pipeln == "<auto_single>") ? rbc_any_crcchk_pipeln : crcchk_pipeln;

	// crcchk_inv, RBC-validated >> ES <<
	localparam rbc_all_crcchk_inv = (fnl_prot_mode == "interlaken_mode") ? ("crcchk_inv_en") : "crcchk_inv_en";
	localparam rbc_any_crcchk_inv = (fnl_prot_mode == "interlaken_mode") ? ("crcchk_inv_en") : "crcchk_inv_en";
	localparam fnl_crcchk_inv = (crcchk_inv == "<auto_any>" || crcchk_inv == "<auto_single>") ? rbc_any_crcchk_inv : crcchk_inv;

	// descrm_mode, RBC-validated >> ES <<
	localparam rbc_all_descrm_mode = (fnl_prot_mode == "interlaken_mode") ? ("sync") : "async";
	localparam rbc_any_descrm_mode = (fnl_prot_mode == "interlaken_mode") ? ("sync") : "async";
	localparam fnl_descrm_mode = (descrm_mode == "<auto_any>" || descrm_mode == "<auto_single>") ? rbc_any_descrm_mode : descrm_mode;

	// rx_scrm_width, RBC-validated >> ES <<
	localparam rbc_all_rx_scrm_width = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("bit64")
		 : (fnl_prot_mode == "basic_mode" && fnl_descrm_bypass == "descrm_bypass_dis") ?
			(
				(fnl_gb_rx_odwidth == "width_67") ? ("(bit67,bit64)")
				 : (fnl_gb_rx_odwidth == "width_66") ? ("(bit66,bit64)") : "(bit64,bit66,bit67)"
			) : "bit64";
	localparam rbc_any_rx_scrm_width = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("bit64")
		 : (fnl_prot_mode == "basic_mode" && fnl_descrm_bypass == "descrm_bypass_dis") ?
			(
				(fnl_gb_rx_odwidth == "width_67") ? ("bit64")
				 : (fnl_gb_rx_odwidth == "width_66") ? ("bit64") : "bit64"
			) : "bit64";
	localparam fnl_rx_scrm_width = (rx_scrm_width == "<auto_any>" || rx_scrm_width == "<auto_single>") ? rbc_any_rx_scrm_width : rx_scrm_width;

	// gb_sel_mode, RBC-validated >> ES <<
	localparam rbc_all_gb_sel_mode = ((fnl_prot_mode == "teng_sdi_mode") && (fnl_sup_mode == "engineering_mode")) ? ("(internal,external)") : "internal";
	localparam rbc_any_gb_sel_mode = ((fnl_prot_mode == "teng_sdi_mode") && (fnl_sup_mode == "engineering_mode")) ? ("internal") : "internal";
	localparam fnl_gb_sel_mode = (gb_sel_mode == "<auto_any>" || gb_sel_mode == "<auto_single>") ? rbc_any_gb_sel_mode : gb_sel_mode;

	// test_mode, RBC-validated >> ES <<
	localparam rbc_all_test_mode = (fnl_prot_mode == "test_prbs_mode") ? ("(prbs_31,prbs_23,prbs_9,prbs_7)")
		 : (fnl_prot_mode == "test_prp_mode") ? ("pseudo_random") : "test_off";
	localparam rbc_any_test_mode = (fnl_prot_mode == "test_prbs_mode") ? ("prbs_31")
		 : (fnl_prot_mode == "test_prp_mode") ? ("pseudo_random") : "test_off";
	localparam fnl_test_mode = (test_mode == "<auto_any>" || test_mode == "<auto_single>") ? rbc_any_test_mode : test_mode;

	// rx_prbs_mask, RBC-validated >> ES <<
	localparam rbc_all_rx_prbs_mask = (fnl_prot_mode == "test_prbs_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(prbsmask128,prbsmask256,prbsmask512,prbsmask1024)") : "prbsmask1024"
		)
		 : (fnl_prot_mode == "test_prp_mode") ? ("prbsmask128") : "prbsmask128";
	localparam rbc_any_rx_prbs_mask = (fnl_prot_mode == "test_prbs_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("prbsmask128") : "prbsmask1024"
		)
		 : (fnl_prot_mode == "test_prp_mode") ? ("prbsmask128") : "prbsmask128";
	localparam fnl_rx_prbs_mask = (rx_prbs_mask == "<auto_any>" || rx_prbs_mask == "<auto_single>") ? rbc_any_rx_prbs_mask : rx_prbs_mask;

	// stretch_en, RBC-validated >> ES <<
	localparam rbc_all_stretch_en = (fnl_sup_mode == "engineering_mode") ? ("(stretch_en,stretch_dis)") : "stretch_en";
	localparam rbc_any_stretch_en = (fnl_sup_mode == "engineering_mode") ? ("stretch_en") : "stretch_en";
	localparam fnl_stretch_en = (stretch_en == "<auto_any>" || stretch_en == "<auto_single>") ? rbc_any_stretch_en : stretch_en;

	// stretch_num_stages, RBC-validated >> ES <<
	localparam rbc_all_stretch_num_stages = (fnl_sup_mode == "engineering_mode") ? ("(zero_stage,one_stage,two_stage,three_stage)") : "zero_stage";
	localparam rbc_any_stretch_num_stages = (fnl_sup_mode == "engineering_mode") ? ("zero_stage") : "zero_stage";
	localparam fnl_stretch_num_stages = (stretch_num_stages == "<auto_any>" || stretch_num_stages == "<auto_single>") ? rbc_any_stretch_num_stages : stretch_num_stages;

	// iqtxrx_clkout_sel, RBC-validated >> ES <<
	localparam rbc_all_iqtxrx_clkout_sel = (fnl_sup_mode == "engineering_mode") ? ("(iq_rx_clk_out,iq_rx_pma_clk_div33)") : "iq_rx_clk_out";
	localparam rbc_any_iqtxrx_clkout_sel = (fnl_sup_mode == "engineering_mode") ? ("iq_rx_clk_out") : "iq_rx_clk_out";
	localparam fnl_iqtxrx_clkout_sel = (iqtxrx_clkout_sel == "<auto_any>" || iqtxrx_clkout_sel == "<auto_single>") ? rbc_any_iqtxrx_clkout_sel : iqtxrx_clkout_sel;

	// bitslip_mode, RBC-validated >> ES <<
	localparam rbc_all_bitslip_mode = (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode" || (fnl_prot_mode == "basic_mode" && fnl_blksync_bypass == "blksync_bypass_en")) ? ("(bitslip_dis,bitslip_en)") : "bitslip_dis";
	localparam rbc_any_bitslip_mode = (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode" || (fnl_prot_mode == "basic_mode" && fnl_blksync_bypass == "blksync_bypass_en")) ? ("bitslip_dis") : "bitslip_dis";
	localparam fnl_bitslip_mode = (bitslip_mode == "<auto_any>" || bitslip_mode == "<auto_single>") ? rbc_any_bitslip_mode : bitslip_mode;

	// rx_testbus_sel, RBC-validated >> ES <<
	localparam rbc_all_rx_testbus_sel = (fnl_prot_mode == "disable_mode") ? ("rx_fifo_testbus1") : "(ber_testbus,blksync_testbus1,blksync_testbus2,crc32_chk_testbus1,crc32_chk_testbus2,dec64b66b_testbus,descramble_testbus1,descramble_testbus2,disp_chk_testbus1,disp_chk_testbus2,frame_sync_testbus1,frame_sync_testbus2,gearbox_exp_testbus1,gearbox_exp_testbus2,prbs_ver_xg_testbus,rx_fifo_testbus1,rx_fifo_testbus2,rxsm_testbus)";
	localparam rbc_any_rx_testbus_sel = (fnl_prot_mode == "disable_mode") ? ("rx_fifo_testbus1") : "crc32_chk_testbus1";
	localparam fnl_rx_testbus_sel = (rx_testbus_sel == "<auto_any>" || rx_testbus_sel == "<auto_single>") ? rbc_any_rx_testbus_sel : rx_testbus_sel;

	// rx_polarity_inv, RBC-validated >> ES <<
	localparam rbc_all_rx_polarity_inv = (fnl_prot_mode == "disable_mode") ? ("invert_disable") : "(invert_disable,invert_enable)";
	localparam rbc_any_rx_polarity_inv = (fnl_prot_mode == "disable_mode") ? ("invert_disable") : "invert_disable";
	localparam fnl_rx_polarity_inv = (rx_polarity_inv == "<auto_any>" || rx_polarity_inv == "<auto_single>") ? rbc_any_rx_polarity_inv : rx_polarity_inv;



   // added production rules for new parameters
	// data_bit_reverse, RBC-validated >> REVE <<
	localparam rbc_all_data_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_66")) ? ("data_bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_67")) ? ("data_bit_reverse_en") : "data_bit_reverse_dis";
	localparam rbc_any_data_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_66")) ? ("data_bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_67")) ? ("data_bit_reverse_en") : "data_bit_reverse_dis";
	localparam fnl_data_bit_reverse = (data_bit_reverse == "<auto_any>" || data_bit_reverse == "<auto_single>") ? rbc_any_data_bit_reverse : data_bit_reverse;

	// ctrl_bit_reverse, RBC-validated >> REVE <<
	localparam rbc_all_ctrl_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_66")) ? ("ctrl_bit_reverse_en")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_67")) ? ("ctrl_bit_reverse_en") : "ctrl_bit_reverse_dis";
	localparam rbc_any_ctrl_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_66")) ? ("ctrl_bit_reverse_en")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_67")) ? ("ctrl_bit_reverse_en") : "ctrl_bit_reverse_dis";
	localparam fnl_ctrl_bit_reverse = (ctrl_bit_reverse == "<auto_any>" || ctrl_bit_reverse == "<auto_single>") ? rbc_any_ctrl_bit_reverse : ctrl_bit_reverse;

		 
	 
	// stretch_type, RBC-validated >> REVE <<
	localparam rbc_all_stretch_type = (fnl_sup_mode == "engineering_mode") ? ("(stretch_custom,stretch_auto)") : "stretch_auto";
	localparam rbc_any_stretch_type = (fnl_sup_mode == "engineering_mode") ? ("stretch_auto") : "stretch_auto";
	localparam fnl_stretch_type = (stretch_type == "<auto_any>" || stretch_type == "<auto_single>") ? rbc_any_stretch_type : stretch_type;

   // full_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_full_flag_type = "full_wr_side";
	localparam rbc_any_full_flag_type = "full_wr_side";
	localparam fnl_full_flag_type = (full_flag_type == "<auto_any>" || full_flag_type == "<auto_single>") ? rbc_any_full_flag_type : full_flag_type;

	// empty_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_empty_flag_type = "empty_rd_side";
	localparam rbc_any_empty_flag_type = "empty_rd_side";
	localparam fnl_empty_flag_type = (empty_flag_type == "<auto_any>" || empty_flag_type == "<auto_single>") ? rbc_any_empty_flag_type : empty_flag_type;

	// pfull_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_pfull_flag_type = "pfull_wr_side";
	localparam rbc_any_pfull_flag_type = "pfull_wr_side";
	localparam fnl_pfull_flag_type = (pfull_flag_type == "<auto_any>" || pfull_flag_type == "<auto_single>") ? rbc_any_pfull_flag_type : pfull_flag_type;

	// pempty_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_pempty_flag_type = "pempty_rd_side";
	localparam rbc_any_pempty_flag_type = "pempty_rd_side";
	localparam fnl_pempty_flag_type = (pempty_flag_type == "<auto_any>" || pempty_flag_type == "<auto_single>") ? rbc_any_pempty_flag_type : pempty_flag_type;

	// fifo_stop_rd, RBC-validated >> REVE <<
	localparam rbc_all_fifo_stop_rd = "n_rd_empty";
	localparam rbc_any_fifo_stop_rd = "n_rd_empty";
	localparam fnl_fifo_stop_rd = (fifo_stop_rd == "<auto_any>" || fifo_stop_rd == "<auto_single>") ? rbc_any_fifo_stop_rd : fifo_stop_rd;

	// fifo_stop_wr, RBC-validated >> REVE <<
	localparam rbc_all_fifo_stop_wr = "n_wr_full";
	localparam rbc_any_fifo_stop_wr = "n_wr_full";
	localparam fnl_fifo_stop_wr = (fifo_stop_wr == "<auto_any>" || fifo_stop_wr == "<auto_single>") ? rbc_any_fifo_stop_wr : fifo_stop_wr;


	// crcchk_init external parameter (no RBC) >> ES <<
	localparam rbc_all_crcchk_init = "crcchk_init_user_setting";
	localparam rbc_any_crcchk_init = "crcchk_init_user_setting";
	localparam fnl_crcchk_init = (crcchk_init == "<auto_any>" || crcchk_init == "<auto_single>") ? rbc_any_crcchk_init : crcchk_init;
   


   //========================ES RULES END  ==============================================================================

`else

   //========================REVE RULES START==============================================================================

      localparam silicon_rev_local = "reve";

	// prot_mode external parameter (no RBC) >> REVE <<
	localparam rbc_all_prot_mode = "(basic_mode,disable_mode,interlaken_mode,sfis_mode,teng_1588_mode,teng_baser_mode,teng_sdi_mode,test_prbs_mode,test_prp_mode)";
	localparam rbc_any_prot_mode = "disable_mode";
	localparam fnl_prot_mode = (prot_mode == "<auto_any>" || prot_mode == "<auto_single>") ? rbc_any_prot_mode : prot_mode;

	// sup_mode external parameter (no RBC) >> REVE <<
	localparam rbc_all_sup_mode = "(engineering_mode,engr_mode,stretch_mode,user_mode)";
	localparam rbc_any_sup_mode = "user_mode";
	localparam fnl_sup_mode = (sup_mode == "<auto_any>" || sup_mode == "<auto_single>") ? rbc_any_sup_mode : sup_mode;

	// crcchk_init external parameter (no RBC) >> REVE <<
	localparam rbc_all_crcchk_init = "crcchk_int";
	localparam rbc_any_crcchk_init = "crcchk_int";
	localparam fnl_crcchk_init = (crcchk_init == "<auto_any>" || crcchk_init == "<auto_single>") ? rbc_any_crcchk_init : crcchk_init;

	// test_bus_mode external parameter (no RBC) >> REVE <<
	localparam rbc_all_test_bus_mode = "(rx,tx)";
	localparam rbc_any_test_bus_mode = "tx";
	localparam fnl_test_bus_mode = (test_bus_mode == "<auto_any>" || test_bus_mode == "<auto_single>") ? rbc_any_test_bus_mode : test_bus_mode;

	// use_default_base_address external parameter (no RBC) >> REVE <<
	localparam rbc_all_use_default_base_address = "(false,true)";
	localparam rbc_any_use_default_base_address = "true";
	localparam fnl_use_default_base_address = (use_default_base_address == "<auto_any>" || use_default_base_address == "<auto_single>") ? rbc_any_use_default_base_address : use_default_base_address;

	// gb_rx_idwidth, RBC-validated >> REVE <<
	localparam rbc_all_gb_rx_idwidth = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("(width_32,width_40)")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("(width_32,width_40)")
			 : ((fnl_prot_mode == "sfis_mode")) ? ("(width_32,width_40,width_64)")
				 : ((fnl_prot_mode == "teng_sdi_mode")) ? ("width_40")
					 : ((fnl_prot_mode == "basic_mode")) ? ("(width_32,width_40,width_64)")
						 : (fnl_prot_mode == "test_prbs_mode") ? ("(width_32,width_40,width_64)") : "width_32";
	localparam rbc_any_gb_rx_idwidth = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("width_32")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("width_32")
			 : ((fnl_prot_mode == "sfis_mode")) ? ("width_32")
				 : ((fnl_prot_mode == "teng_sdi_mode")) ? ("width_40")
					 : ((fnl_prot_mode == "basic_mode")) ? ("width_32")
						 : (fnl_prot_mode == "test_prbs_mode") ? ("width_32") : "width_32";
	localparam fnl_gb_rx_idwidth = (gb_rx_idwidth == "<auto_any>" || gb_rx_idwidth == "<auto_single>") ? rbc_any_gb_rx_idwidth : gb_rx_idwidth;

	// gb_rx_odwidth, RBC-validated >> REVE <<
	localparam rbc_all_gb_rx_odwidth = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("width_66")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("width_67")
			 : ((fnl_prot_mode == "sfis_mode")) ?
				(
					(fnl_gb_rx_idwidth == "width_32") ? ("(width_64,width_32)")
					 : (fnl_gb_rx_idwidth == "width_40") ?
						(
							((fnl_sup_mode == "engineering_mode")) ? ("(width_64,width_40)") : "width_40"
						) : "width_64"
				)
				 : ((fnl_prot_mode == "teng_sdi_mode")) ?
					(
						((fnl_sup_mode == "engineering_mode")) ? ("(width_40,width_50)") : "width_50"
					)
					 : ((fnl_prot_mode == "basic_mode")) ?
						(
							(fnl_gb_rx_idwidth == "width_32") ?
							(
								((fnl_sup_mode == "engineering_mode")) ? ("(width_32,width_64,width_66,width_67)") : "(width_32,width_64)"
							)
							 : (fnl_gb_rx_idwidth == "width_40") ?
								(
									((fnl_sup_mode == "engineering_mode")) ? ("(width_40,width_64,width_66,width_67)") : "(width_40,width_66)"
								) : "width_64"
						)
						 : (fnl_gb_rx_idwidth == "width_32") ? ("width_32")
							 : (fnl_gb_rx_idwidth == "width_40") ? ("width_40") : "width_64";
	localparam rbc_any_gb_rx_odwidth = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("width_66")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("width_67")
			 : ((fnl_prot_mode == "sfis_mode")) ?
				(
					(fnl_gb_rx_idwidth == "width_32") ? ("width_64")
					 : (fnl_gb_rx_idwidth == "width_40") ?
						(
							((fnl_sup_mode == "engineering_mode")) ? ("width_64") : "width_40"
						) : "width_64"
				)
				 : ((fnl_prot_mode == "teng_sdi_mode")) ?
					(
						((fnl_sup_mode == "engineering_mode")) ? ("width_40") : "width_50"
					)
					 : ((fnl_prot_mode == "basic_mode")) ?
						(
							(fnl_gb_rx_idwidth == "width_32") ?
							(
								((fnl_sup_mode == "engineering_mode")) ? ("width_66") : "width_32"
							)
							 : (fnl_gb_rx_idwidth == "width_40") ?
								(
									((fnl_sup_mode == "engineering_mode")) ? ("width_66") : "width_66"
								) : "width_64"
						)
						 : (fnl_gb_rx_idwidth == "width_32") ? ("width_32")
							 : (fnl_gb_rx_idwidth == "width_40") ? ("width_40") : "width_64";
	localparam fnl_gb_rx_odwidth = (gb_rx_odwidth == "<auto_any>" || gb_rx_odwidth == "<auto_single>") ? rbc_any_gb_rx_odwidth : gb_rx_odwidth;

	// lpbk_mode, RBC-validated >> REVE <<
	localparam rbc_all_lpbk_mode = ((fnl_prot_mode == "test_prp_mode")) ? ("(lpbk_en,lpbk_dis)")
		 : ((fnl_sup_mode == "engineering_mode")) ? ("(lpbk_en,lpbk_dis)") : "lpbk_dis";
	localparam rbc_any_lpbk_mode = ((fnl_prot_mode == "test_prp_mode")) ? ("lpbk_dis")
		 : ((fnl_sup_mode == "engineering_mode")) ? ("lpbk_dis") : "lpbk_dis";
	localparam fnl_lpbk_mode = (lpbk_mode == "<auto_any>" || lpbk_mode == "<auto_single>") ? rbc_any_lpbk_mode : lpbk_mode;

	// rx_dfx_lpbk, RBC-validated >> REVE <<
	localparam rbc_all_rx_dfx_lpbk = ((fnl_prot_mode == "test_prp_mode")) ? ("dfx_lpbk_dis")
		 : ((fnl_sup_mode == "engineering_mode")) ? ("(dfx_lpbk_en,dfx_lpbk_dis)") : "dfx_lpbk_dis";
	localparam rbc_any_rx_dfx_lpbk = ((fnl_prot_mode == "test_prp_mode")) ? ("dfx_lpbk_dis")
		 : ((fnl_sup_mode == "engineering_mode")) ? ("dfx_lpbk_dis") : "dfx_lpbk_dis";
	localparam fnl_rx_dfx_lpbk = (rx_dfx_lpbk == "<auto_any>" || rx_dfx_lpbk == "<auto_single>") ? rbc_any_rx_dfx_lpbk : rx_dfx_lpbk;

	// master_clk_sel, RBC-validated >> REVE <<
	localparam rbc_all_master_clk_sel = (fnl_sup_mode == "engineering_mode") ?
		(
			(fnl_lpbk_mode == "lpbk_en" || fnl_rx_dfx_lpbk == "dfx_lpbk_en") ? ("(master_tx_pma_clk,master_refclk_dig)") : "(master_rx_pma_clk,master_refclk_dig)"
		)
		 : (fnl_lpbk_mode == "lpbk_en") ? ("master_tx_pma_clk") : "master_rx_pma_clk";
	localparam rbc_any_master_clk_sel = (fnl_sup_mode == "engineering_mode") ?
		(
			(fnl_lpbk_mode == "lpbk_en" || fnl_rx_dfx_lpbk == "dfx_lpbk_en") ? ("master_tx_pma_clk") : "master_rx_pma_clk"
		)
		 : (fnl_lpbk_mode == "lpbk_en") ? ("master_tx_pma_clk") : "master_rx_pma_clk";
	localparam fnl_master_clk_sel = (master_clk_sel == "<auto_any>" || master_clk_sel == "<auto_single>") ? rbc_any_master_clk_sel : master_clk_sel;

	// blksync_bypass, RBC-validated >> REVE <<
	localparam rbc_all_blksync_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("blksync_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("blksync_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("blksync_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						((fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") && (fnl_sup_mode == "engineering_mode")) ? ("(blksync_bypass_dis,blksync_bypass_en)") : "blksync_bypass_en"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("blksync_bypass_en") : "blksync_bypass_en";
	localparam rbc_any_blksync_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("blksync_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("blksync_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("blksync_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						((fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") && (fnl_sup_mode == "engineering_mode")) ? ("(blksync_bypass_dis,blksync_bypass_en)") : "blksync_bypass_en"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("blksync_bypass_en") : "blksync_bypass_en";
	localparam fnl_blksync_bypass = (blksync_bypass == "<auto_any>" || blksync_bypass == "<auto_single>") ? rbc_any_blksync_bypass : blksync_bypass;

	// rxfifo_mode, RBC-validated >> REVE <<
	localparam rbc_all_rxfifo_mode = ((fnl_prot_mode == "interlaken_mode")) ? ("generic_interlaken")
		 : ((fnl_prot_mode == "teng_baser_mode")) ?
			(
				((fnl_sup_mode == "engineering_mode")) ? ("(clk_comp_10g,phase_comp)") : "clk_comp_10g"
			)
			 : (fnl_prot_mode == "teng_sdi_mode") ?
				(
					(fnl_sup_mode == "engineering_mode") ? ("(register_mode,phase_comp,phase_comp_dv)") : "phase_comp"
				)
				 : ((fnl_prot_mode == "basic_mode")) ?
					(
						(fnl_sup_mode == "engineering_mode") ?
						(
							(fnl_blksync_bypass == "blksync_bypass_dis") ? ("(generic_basic,register_mode,phase_comp,phase_comp_dv,clk_comp_basic)")
							 : ((fnl_gb_rx_odwidth == "width_32" && fnl_gb_rx_idwidth == "width_32") ||
          (fnl_gb_rx_odwidth == "width_40" && fnl_gb_rx_idwidth == "width_40") ||
          (fnl_gb_rx_odwidth == "width_64" && fnl_gb_rx_idwidth == "width_64")) ? ("(generic_basic,register_mode,phase_comp)") : "(generic_basic,register_mode,phase_comp,phase_comp_dv)"
						)
						 : ((fnl_gb_rx_odwidth == "width_32" && fnl_gb_rx_idwidth == "width_32") ||
         (fnl_gb_rx_odwidth == "width_40" && fnl_gb_rx_idwidth == "width_40") ||
         (fnl_gb_rx_odwidth == "width_64" && fnl_gb_rx_idwidth == "width_64")) ? ("(generic_basic,register_mode,phase_comp)") : "(generic_basic,phase_comp)"
					)
					 : ((fnl_prot_mode == "teng_1588_mode")) ? ("register_mode") : "phase_comp";
	localparam rbc_any_rxfifo_mode = ((fnl_prot_mode == "interlaken_mode")) ? ("generic_interlaken")
		 : ((fnl_prot_mode == "teng_baser_mode")) ?
			(
				((fnl_sup_mode == "engineering_mode")) ? ("phase_comp") : "clk_comp_10g"
			)
			 : (fnl_prot_mode == "teng_sdi_mode") ?
				(
					(fnl_sup_mode == "engineering_mode") ? ("phase_comp") : "phase_comp"
				)
				 : ((fnl_prot_mode == "basic_mode")) ?
					(
						(fnl_sup_mode == "engineering_mode") ?
						(
							(fnl_blksync_bypass == "blksync_bypass_dis") ? ("phase_comp")
							 : ((fnl_gb_rx_odwidth == "width_32" && fnl_gb_rx_idwidth == "width_32") ||
          (fnl_gb_rx_odwidth == "width_40" && fnl_gb_rx_idwidth == "width_40") ||
          (fnl_gb_rx_odwidth == "width_64" && fnl_gb_rx_idwidth == "width_64")) ? ("phase_comp") : "phase_comp"
						)
						 : ((fnl_gb_rx_odwidth == "width_32" && fnl_gb_rx_idwidth == "width_32") ||
         (fnl_gb_rx_odwidth == "width_40" && fnl_gb_rx_idwidth == "width_40") ||
         (fnl_gb_rx_odwidth == "width_64" && fnl_gb_rx_idwidth == "width_64")) ? ("phase_comp") : "phase_comp"
					)
					 : ((fnl_prot_mode == "teng_1588_mode")) ? ("register_mode") : "phase_comp";
	localparam fnl_rxfifo_mode = (rxfifo_mode == "<auto_any>" || rxfifo_mode == "<auto_single>") ? rbc_any_rxfifo_mode : rxfifo_mode;

	// rd_clk_sel, RBC-validated >> REVE <<
	localparam rbc_all_rd_clk_sel = (fnl_rxfifo_mode == "register_mode") ?
		(
			(fnl_master_clk_sel == "master_refclk_dig") ? ("rd_refclk_dig") : "rd_rx_pma_clk"
		) : "rd_rx_pld_clk";
	localparam rbc_any_rd_clk_sel = (fnl_rxfifo_mode == "register_mode") ?
		(
			(fnl_master_clk_sel == "master_refclk_dig") ? ("rd_refclk_dig") : "rd_rx_pma_clk"
		) : "rd_rx_pld_clk";
	localparam fnl_rd_clk_sel = (rd_clk_sel == "<auto_any>" || rd_clk_sel == "<auto_single>") ? rbc_any_rd_clk_sel : rd_clk_sel;

	// gbexp_clken, RBC-validated >> REVE <<
	localparam rbc_all_gbexp_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("gbexp_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("gbexp_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("gbexp_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("gbexp_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("gbexp_clk_en") : "gbexp_clk_dis";
	localparam rbc_any_gbexp_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("gbexp_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("gbexp_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("gbexp_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("gbexp_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("gbexp_clk_en") : "gbexp_clk_dis";
	localparam fnl_gbexp_clken = (gbexp_clken == "<auto_any>" || gbexp_clken == "<auto_single>") ? rbc_any_gbexp_clken : gbexp_clken;

	// dispchk_clken, RBC-validated >> REVE <<
	localparam rbc_all_dispchk_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dispchk_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispchk_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dispchk_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("dispchk_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dispchk_clk_en") : "dispchk_clk_dis";
	localparam rbc_any_dispchk_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dispchk_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispchk_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dispchk_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("dispchk_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dispchk_clk_en") : "dispchk_clk_dis";
	localparam fnl_dispchk_clken = (dispchk_clken == "<auto_any>" || dispchk_clken == "<auto_single>") ? rbc_any_dispchk_clken : dispchk_clken;

	// frmsync_bypass, RBC-validated >> REVE <<
	localparam rbc_all_frmsync_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("frmsync_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmsync_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("frmsync_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("frmsync_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("frmsync_bypass_en") : "frmsync_bypass_en";
	localparam rbc_any_frmsync_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("frmsync_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmsync_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("frmsync_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("frmsync_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("frmsync_bypass_en") : "frmsync_bypass_en";
	localparam fnl_frmsync_bypass = (frmsync_bypass == "<auto_any>" || frmsync_bypass == "<auto_single>") ? rbc_any_frmsync_bypass : frmsync_bypass;

	// dec64b66b_clken, RBC-validated >> REVE <<
	localparam rbc_all_dec64b66b_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dec64b66b_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dec64b66b_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dec64b66b_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("dec64b66b_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dec64b66b_clk_en") : "dec64b66b_clk_dis";
	localparam rbc_any_dec64b66b_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dec64b66b_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dec64b66b_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dec64b66b_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("dec64b66b_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dec64b66b_clk_en") : "dec64b66b_clk_dis";
	localparam fnl_dec64b66b_clken = (dec64b66b_clken == "<auto_any>" || dec64b66b_clken == "<auto_single>") ? rbc_any_dec64b66b_clken : dec64b66b_clken;

	// dec_64b66b_rxsm_bypass, RBC-validated >> REVE <<
	localparam rbc_all_dec_64b66b_rxsm_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dec_64b66b_rxsm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dec_64b66b_rxsm_bypass_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dec_64b66b_rxsm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("dec_64b66b_rxsm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dec_64b66b_rxsm_bypass_en") : "dec_64b66b_rxsm_bypass_en";
	localparam rbc_any_dec_64b66b_rxsm_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dec_64b66b_rxsm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dec_64b66b_rxsm_bypass_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dec_64b66b_rxsm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("dec_64b66b_rxsm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dec_64b66b_rxsm_bypass_en") : "dec_64b66b_rxsm_bypass_en";
	localparam fnl_dec_64b66b_rxsm_bypass = (dec_64b66b_rxsm_bypass == "<auto_any>" || dec_64b66b_rxsm_bypass == "<auto_single>") ? rbc_any_dec_64b66b_rxsm_bypass : dec_64b66b_rxsm_bypass;

	// wrfifo_clken, RBC-validated >> REVE <<
	localparam rbc_all_wrfifo_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("wrfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("wrfifo_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("wrfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("wrfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("wrfifo_clk_en") : "wrfifo_clk_dis";
	localparam rbc_any_wrfifo_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("wrfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("wrfifo_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("wrfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("wrfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("wrfifo_clk_en") : "wrfifo_clk_dis";
	localparam fnl_wrfifo_clken = (wrfifo_clken == "<auto_any>" || wrfifo_clken == "<auto_single>") ? rbc_any_wrfifo_clken : wrfifo_clken;

	// descrm_clken, RBC-validated >> REVE <<
	localparam rbc_all_descrm_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("descrm_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("descrm_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("descrm_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") ?
						(
							(fnl_sup_mode == "engineering_mode") ? ("descrm_clk_en") : "descrm_clk_dis"
						) : "descrm_clk_dis"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("descrm_clk_en") : "descrm_clk_dis";
	localparam rbc_any_descrm_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("descrm_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("descrm_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("descrm_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") ?
						(
							(fnl_sup_mode == "engineering_mode") ? ("descrm_clk_en") : "descrm_clk_dis"
						) : "descrm_clk_dis"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("descrm_clk_en") : "descrm_clk_dis";
	localparam fnl_descrm_clken = (descrm_clken == "<auto_any>" || descrm_clken == "<auto_single>") ? rbc_any_descrm_clken : descrm_clken;

	// frmsync_clken, RBC-validated >> REVE <<
	localparam rbc_all_frmsync_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("frmsync_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmsync_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("frmsync_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("frmsync_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("frmsync_clk_en") : "frmsync_clk_dis";
	localparam rbc_any_frmsync_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("frmsync_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmsync_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("frmsync_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("frmsync_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("frmsync_clk_en") : "frmsync_clk_dis";
	localparam fnl_frmsync_clken = (frmsync_clken == "<auto_any>" || frmsync_clken == "<auto_single>") ? rbc_any_frmsync_clken : frmsync_clken;

	// descrm_bypass, RBC-validated >> REVE <<
	localparam rbc_all_descrm_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("descrm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("descrm_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("descrm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") ?
						(
							(fnl_sup_mode == "engineering_mode") ? ("(descrm_bypass_en,descrm_bypass_dis)") : "descrm_bypass_en"
						) : "descrm_bypass_en"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("descrm_bypass_en") : "descrm_bypass_en";
	localparam rbc_any_descrm_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("descrm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("descrm_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("descrm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") ?
						(
							(fnl_sup_mode == "engineering_mode") ? ("descrm_bypass_en") : "descrm_bypass_en"
						) : "descrm_bypass_en"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("descrm_bypass_en") : "descrm_bypass_en";
	localparam fnl_descrm_bypass = (descrm_bypass == "<auto_any>" || descrm_bypass == "<auto_single>") ? rbc_any_descrm_bypass : descrm_bypass;

	// blksync_clken, RBC-validated >> REVE <<
	localparam rbc_all_blksync_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("blksync_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("blksync_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("blksync_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						((fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") && (fnl_sup_mode == "engineering_mode")) ? ("blksync_clk_en") : "blksync_clk_dis"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("blksync_clk_en") : "blksync_clk_dis";
	localparam rbc_any_blksync_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("blksync_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("blksync_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("blksync_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						((fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67") && (fnl_sup_mode == "engineering_mode")) ? ("blksync_clk_en") : "blksync_clk_dis"
					)
					 : (fnl_prot_mode == "test_prbs_mode") ? ("blksync_clk_en") : "blksync_clk_dis";
	localparam fnl_blksync_clken = (blksync_clken == "<auto_any>" || blksync_clken == "<auto_single>") ? rbc_any_blksync_clken : blksync_clken;

	// crcchk_bypass, RBC-validated >> REVE <<
	localparam rbc_all_crcchk_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("crcchk_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcchk_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("crcchk_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("crcchk_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("crcchk_bypass_en") : "crcchk_bypass_en";
	localparam rbc_any_crcchk_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("crcchk_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcchk_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("crcchk_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("crcchk_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("crcchk_bypass_en") : "crcchk_bypass_en";
	localparam fnl_crcchk_bypass = (crcchk_bypass == "<auto_any>" || crcchk_bypass == "<auto_single>") ? rbc_any_crcchk_bypass : crcchk_bypass;

	// rx_sm_bypass, RBC-validated >> REVE <<
	localparam rbc_all_rx_sm_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("rx_sm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rx_sm_bypass_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("rx_sm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("rx_sm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("rx_sm_bypass_en") : "rx_sm_bypass_en";
	localparam rbc_any_rx_sm_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("rx_sm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rx_sm_bypass_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("rx_sm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("rx_sm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("rx_sm_bypass_en") : "rx_sm_bypass_en";
	localparam fnl_rx_sm_bypass = (rx_sm_bypass == "<auto_any>" || rx_sm_bypass == "<auto_single>") ? rbc_any_rx_sm_bypass : rx_sm_bypass;

	// prbs_clken, RBC-validated >> REVE <<
	localparam rbc_all_prbs_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("prbs_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("prbs_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("prbs_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("prbs_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("prbs_clk_en") : "prbs_clk_dis";
	localparam rbc_any_prbs_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("prbs_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("prbs_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("prbs_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("prbs_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("prbs_clk_en") : "prbs_clk_dis";
	localparam fnl_prbs_clken = (prbs_clken == "<auto_any>" || prbs_clken == "<auto_single>") ? rbc_any_prbs_clken : prbs_clken;

	// ber_clken, RBC-validated >> REVE <<
	localparam rbc_all_ber_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("ber_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("ber_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("ber_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("ber_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("ber_clk_en") : "ber_clk_dis";
	localparam rbc_any_ber_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("ber_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("ber_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("ber_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("ber_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("ber_clk_en") : "ber_clk_dis";
	localparam fnl_ber_clken = (ber_clken == "<auto_any>" || ber_clken == "<auto_single>") ? rbc_any_ber_clken : ber_clken;

	// dispchk_bypass, RBC-validated >> REVE <<
	localparam rbc_all_dispchk_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dispchk_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispchk_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dispchk_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("dispchk_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dispchk_bypass_en") : "dispchk_bypass_en";
	localparam rbc_any_dispchk_bypass = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("dispchk_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispchk_bypass_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("dispchk_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("dispchk_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("dispchk_bypass_en") : "dispchk_bypass_en";
	localparam fnl_dispchk_bypass = (dispchk_bypass == "<auto_any>" || dispchk_bypass == "<auto_single>") ? rbc_any_dispchk_bypass : dispchk_bypass;

	// rand_clken, RBC-validated >> REVE <<
	localparam rbc_all_rand_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("rand_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rand_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("rand_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("rand_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("rand_clk_en") : "rand_clk_dis";
	localparam rbc_any_rand_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("rand_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rand_clk_dis")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("rand_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("rand_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("rand_clk_en") : "rand_clk_dis";
	localparam fnl_rand_clken = (rand_clken == "<auto_any>" || rand_clken == "<auto_single>") ? rbc_any_rand_clken : rand_clken;

	// rdfifo_clken, RBC-validated >> REVE <<
	localparam rbc_all_rdfifo_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("rdfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rdfifo_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("rdfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("rdfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("rdfifo_clk_en") : "rdfifo_clk_dis";
	localparam rbc_any_rdfifo_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("rdfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rdfifo_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("rdfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("rdfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("rdfifo_clk_en") : "rdfifo_clk_dis";
	localparam fnl_rdfifo_clken = (rdfifo_clken == "<auto_any>" || rdfifo_clken == "<auto_single>") ? rbc_any_rdfifo_clken : rdfifo_clken;

	// crcchk_clken, RBC-validated >> REVE <<
	localparam rbc_all_crcchk_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("crcchk_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcchk_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("crcchk_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("crcchk_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("crcchk_clk_en") : "crcchk_clk_dis";
	localparam rbc_any_crcchk_clken = ((fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("crcchk_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcchk_clk_en")
			 : ((fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode")) ? ("crcchk_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("crcchk_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode") ? ("crcchk_clk_en") : "crcchk_clk_dis";
	localparam fnl_crcchk_clken = (crcchk_clken == "<auto_any>" || crcchk_clken == "<auto_single>") ? rbc_any_crcchk_clken : crcchk_clken;

	// fast_path, RBC-validated >> REVE <<
	localparam rbc_all_fast_path = (fnl_descrm_bypass == "descrm_bypass_en" && fnl_frmsync_bypass == "frmsync_bypass_en" && fnl_crcchk_bypass == "crcchk_bypass_en" && fnl_dec_64b66b_rxsm_bypass == "dec_64b66b_rxsm_bypass_en" && fnl_dispchk_bypass == "dispchk_bypass_en" && fnl_blksync_bypass == "blksync_bypass_en") ? ("fast_path_en") : "fast_path_dis";
	localparam rbc_any_fast_path = (fnl_descrm_bypass == "descrm_bypass_en" && fnl_frmsync_bypass == "frmsync_bypass_en" && fnl_crcchk_bypass == "crcchk_bypass_en" && fnl_dec_64b66b_rxsm_bypass == "dec_64b66b_rxsm_bypass_en" && fnl_dispchk_bypass == "dispchk_bypass_en" && fnl_blksync_bypass == "blksync_bypass_en") ? ("fast_path_en") : "fast_path_dis";
	localparam fnl_fast_path = (fast_path == "<auto_any>" || fast_path == "<auto_single>") ? rbc_any_fast_path : fast_path;

	// bit_reverse, RBC-validated >> REVE <<
	localparam rbc_all_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("bit_reverse_en")
			 : (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) ? ("(bit_reverse_en,bit_reverse_dis)") : "bit_reverse_dis";
	localparam rbc_any_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "teng_1588_mode")) ? ("bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("bit_reverse_en")
			 : (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) ? ("bit_reverse_dis") : "bit_reverse_dis";
	localparam fnl_bit_reverse = (bit_reverse == "<auto_any>" || bit_reverse == "<auto_single>") ? rbc_any_bit_reverse : bit_reverse;

	// data_bit_reverse, RBC-validated >> REVE <<
	localparam rbc_all_data_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_66") || (fnl_prot_mode == "teng_1588_mode")) ? ("data_bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_67")) ? ("data_bit_reverse_en") : "data_bit_reverse_dis";
	localparam rbc_any_data_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_66") || (fnl_prot_mode == "teng_1588_mode")) ? ("data_bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_67")) ? ("data_bit_reverse_en") : "data_bit_reverse_dis";
	localparam fnl_data_bit_reverse = (data_bit_reverse == "<auto_any>" || data_bit_reverse == "<auto_single>") ? rbc_any_data_bit_reverse : data_bit_reverse;

	// ctrl_bit_reverse, RBC-validated >> REVE <<
	localparam rbc_all_ctrl_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_66") || (fnl_prot_mode == "teng_1588_mode")) ? ("ctrl_bit_reverse_en")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_67")) ? ("ctrl_bit_reverse_en") : "ctrl_bit_reverse_dis";
	localparam rbc_any_ctrl_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_66") || (fnl_prot_mode == "teng_1588_mode")) ? ("ctrl_bit_reverse_en")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_67")) ? ("ctrl_bit_reverse_en") : "ctrl_bit_reverse_dis";
	localparam fnl_ctrl_bit_reverse = (ctrl_bit_reverse == "<auto_any>" || ctrl_bit_reverse == "<auto_single>") ? rbc_any_ctrl_bit_reverse : ctrl_bit_reverse;

	// rx_sh_location, RBC-validated >> REVE <<
	localparam rbc_all_rx_sh_location = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_66") || (fnl_prot_mode == "teng_1588_mode")) ? ("lsb")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_67")) ? ("lsb") : "msb";
	localparam rbc_any_rx_sh_location = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_66") || (fnl_prot_mode == "teng_1588_mode")) ? ("lsb")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_rx_odwidth == "width_67")) ? ("lsb") : "msb";
	localparam fnl_rx_sh_location = (rx_sh_location == "<auto_any>" || rx_sh_location == "<auto_single>") ? rbc_any_rx_sh_location : rx_sh_location;

	// full_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_full_flag_type = "full_wr_side";
	localparam rbc_any_full_flag_type = "full_wr_side";
	localparam fnl_full_flag_type = (full_flag_type == "<auto_any>" || full_flag_type == "<auto_single>") ? rbc_any_full_flag_type : full_flag_type;

	// empty_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_empty_flag_type = "empty_rd_side";
	localparam rbc_any_empty_flag_type = "empty_rd_side";
	localparam fnl_empty_flag_type = (empty_flag_type == "<auto_any>" || empty_flag_type == "<auto_single>") ? rbc_any_empty_flag_type : empty_flag_type;

	// pfull_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_pfull_flag_type = "pfull_wr_side";
	localparam rbc_any_pfull_flag_type = "pfull_wr_side";
	localparam fnl_pfull_flag_type = (pfull_flag_type == "<auto_any>" || pfull_flag_type == "<auto_single>") ? rbc_any_pfull_flag_type : pfull_flag_type;

	// pempty_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_pempty_flag_type = "pempty_rd_side";
	localparam rbc_any_pempty_flag_type = "pempty_rd_side";
	localparam fnl_pempty_flag_type = (pempty_flag_type == "<auto_any>" || pempty_flag_type == "<auto_single>") ? rbc_any_pempty_flag_type : pempty_flag_type;

	// fifo_stop_rd, RBC-validated >> REVE <<
	localparam rbc_all_fifo_stop_rd = "n_rd_empty";
	localparam rbc_any_fifo_stop_rd = "n_rd_empty";
	localparam fnl_fifo_stop_rd = (fifo_stop_rd == "<auto_any>" || fifo_stop_rd == "<auto_single>") ? rbc_any_fifo_stop_rd : fifo_stop_rd;

	// fifo_stop_wr, RBC-validated >> REVE <<
	localparam rbc_all_fifo_stop_wr = "n_wr_full";
	localparam rbc_any_fifo_stop_wr = "n_wr_full";
	localparam fnl_fifo_stop_wr = (fifo_stop_wr == "<auto_any>" || fifo_stop_wr == "<auto_single>") ? rbc_any_fifo_stop_wr : fifo_stop_wr;

	// force_align, RBC-validated >> REVE <<
	localparam rbc_all_force_align = ((fnl_prot_mode == "interlaken_mode") &&
	   (fnl_sup_mode == "engineering_mode")) ? ("(force_align_en,force_align_dis)") : "force_align_dis";
	localparam rbc_any_force_align = ((fnl_prot_mode == "interlaken_mode") &&
	   (fnl_sup_mode == "engineering_mode")) ? ("force_align_dis") : "force_align_dis";
	localparam fnl_force_align = (force_align == "<auto_any>" || force_align == "<auto_single>") ? rbc_any_force_align : force_align;

	// control_del, RBC-validated >> REVE <<
	localparam rbc_all_control_del = (fnl_prot_mode == "interlaken_mode") ? ("(control_del_all,control_del_none)") : "control_del_none";
	localparam rbc_any_control_del = (fnl_prot_mode == "interlaken_mode") ? ("control_del_all") : "control_del_none";
	localparam fnl_control_del = (control_del == "<auto_any>" || control_del == "<auto_single>") ? rbc_any_control_del : control_del;

	// align_del, RBC-validated >> REVE <<
	localparam rbc_all_align_del = (fnl_prot_mode == "interlaken_mode") ? ("(align_del_dis,align_del_en)") : "align_del_dis";
	localparam rbc_any_align_del = (fnl_prot_mode == "interlaken_mode") ? ("align_del_en") : "align_del_dis";
	localparam fnl_align_del = (align_del == "<auto_any>" || align_del == "<auto_single>") ? rbc_any_align_del : align_del;

	// rx_fifo_write_ctrl, RBC-validated >> REVE <<
	localparam rbc_all_rx_fifo_write_ctrl = (fnl_rxfifo_mode == "clk_comp_basic") ? ("(blklock_ignore,blklock_stops)") : "blklock_stops";
	localparam rbc_any_rx_fifo_write_ctrl = (fnl_rxfifo_mode == "clk_comp_basic") ? ("blklock_stops") : "blklock_stops";
	localparam fnl_rx_fifo_write_ctrl = (rx_fifo_write_ctrl == "<auto_any>" || rx_fifo_write_ctrl == "<auto_single>") ? rbc_any_rx_fifo_write_ctrl : rx_fifo_write_ctrl;

	// rx_true_b2b, RBC-validated >> REVE <<
	localparam rbc_all_rx_true_b2b = (fnl_rxfifo_mode == "clk_comp_basic" || fnl_rxfifo_mode == "clk_comp_10g") ? ("(b2b,single)") : "b2b";
	localparam rbc_any_rx_true_b2b = (fnl_rxfifo_mode == "clk_comp_basic" || fnl_rxfifo_mode == "clk_comp_10g") ? ("b2b") : "b2b";
	localparam fnl_rx_true_b2b = (rx_true_b2b == "<auto_any>" || rx_true_b2b == "<auto_single>") ? rbc_any_rx_true_b2b : rx_true_b2b;

	// blksync_knum_sh_cnt_postlock, RBC-validated >> REVE <<
	localparam rbc_all_blksync_knum_sh_cnt_postlock = "knum_sh_cnt_postlock_10g";
	localparam rbc_any_blksync_knum_sh_cnt_postlock = "knum_sh_cnt_postlock_10g";
	localparam fnl_blksync_knum_sh_cnt_postlock = (blksync_knum_sh_cnt_postlock == "<auto_any>" || blksync_knum_sh_cnt_postlock == "<auto_single>") ? rbc_any_blksync_knum_sh_cnt_postlock : blksync_knum_sh_cnt_postlock;

	// blksync_bitslip_type, RBC-validated >> REVE <<
	localparam rbc_all_blksync_bitslip_type = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(bitslip_comb,bitslip_reg)") : "bitslip_comb"
		) : "bitslip_comb";
	localparam rbc_any_blksync_bitslip_type = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("bitslip_comb") : "bitslip_comb"
		) : "bitslip_comb";
	localparam fnl_blksync_bitslip_type = (blksync_bitslip_type == "<auto_any>" || blksync_bitslip_type == "<auto_single>") ? rbc_any_blksync_bitslip_type : blksync_bitslip_type;

	// blksync_bitslip_wait_type, RBC-validated >> REVE <<
	localparam rbc_all_blksync_bitslip_wait_type = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(bitslip_match,bitslip_cnt)") : "bitslip_cnt"
		) : "bitslip_cnt";
	localparam rbc_any_blksync_bitslip_wait_type = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("bitslip_match") : "bitslip_cnt"
		) : "bitslip_cnt";
	localparam fnl_blksync_bitslip_wait_type = (blksync_bitslip_wait_type == "<auto_any>" || blksync_bitslip_wait_type == "<auto_single>") ? rbc_any_blksync_bitslip_wait_type : blksync_bitslip_wait_type;

	// blksync_enum_invalid_sh_cnt, RBC-validated >> REVE <<
	localparam rbc_all_blksync_enum_invalid_sh_cnt = "enum_invalid_sh_cnt_10g";
	localparam rbc_any_blksync_enum_invalid_sh_cnt = "enum_invalid_sh_cnt_10g";
	localparam fnl_blksync_enum_invalid_sh_cnt = (blksync_enum_invalid_sh_cnt == "<auto_any>" || blksync_enum_invalid_sh_cnt == "<auto_single>") ? rbc_any_blksync_enum_invalid_sh_cnt : blksync_enum_invalid_sh_cnt;

	// blksync_pipeln, RBC-validated >> REVE <<
	localparam rbc_all_blksync_pipeln = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(blksync_pipeln_en,blksync_pipeln_dis)") : "blksync_pipeln_dis"
		) : "blksync_pipeln_dis";
	localparam rbc_any_blksync_pipeln = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "interlaken_mode" || (fnl_prot_mode == "basic_mode" && (fnl_gb_rx_odwidth == "width_66" || fnl_gb_rx_odwidth == "width_67")) || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("blksync_pipeln_dis") : "blksync_pipeln_dis"
		) : "blksync_pipeln_dis";
	localparam fnl_blksync_pipeln = (blksync_pipeln == "<auto_any>" || blksync_pipeln == "<auto_single>") ? rbc_any_blksync_pipeln : blksync_pipeln;

	// blksync_bitslip_wait_cnt, RBC-validated >> REVE <<
   localparam rbc_all_blksync_bitslip_wait_cnt = "wait_cnt_user";
   localparam rbc_any_blksync_bitslip_wait_cnt = "wait_cnt_user";
   localparam fnl_blksync_bitslip_wait_cnt = (blksync_bitslip_wait_cnt == "<auto_any>" || blksync_bitslip_wait_cnt == "<auto_single>") ? rbc_any_blksync_bitslip_wait_cnt : blksync_bitslip_wait_cnt;

	// blksync_knum_sh_cnt_prelock, RBC-validated >> REVE <<
	localparam rbc_all_blksync_knum_sh_cnt_prelock = "knum_sh_cnt_prelock_10g";
	localparam rbc_any_blksync_knum_sh_cnt_prelock = "knum_sh_cnt_prelock_10g";
	localparam fnl_blksync_knum_sh_cnt_prelock = (blksync_knum_sh_cnt_prelock == "<auto_any>" || blksync_knum_sh_cnt_prelock == "<auto_single>") ? rbc_any_blksync_knum_sh_cnt_prelock : blksync_knum_sh_cnt_prelock;

	// rx_signal_ok_sel, RBC-validated >> REVE <<
	localparam rbc_all_rx_signal_ok_sel = (fnl_prot_mode == "disable_mode" || fnl_lpbk_mode == "lpbk_en") ? ("synchronized_ver")
		 : (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("synchronized_ver") : "synchronized_ver";
	localparam rbc_any_rx_signal_ok_sel = (fnl_prot_mode == "disable_mode" || fnl_lpbk_mode == "lpbk_en") ? ("synchronized_ver")
		 : (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("synchronized_ver") : "synchronized_ver";
	localparam fnl_rx_signal_ok_sel = (rx_signal_ok_sel == "<auto_any>" || rx_signal_ok_sel == "<auto_single>") ? rbc_any_rx_signal_ok_sel : rx_signal_ok_sel;

	// dis_signal_ok, RBC-validated >> REVE <<
	localparam rbc_all_dis_signal_ok = (fnl_prot_mode == "disable_mode" || fnl_lpbk_mode == "lpbk_en") ? ("dis_signal_ok_dis")
		 : (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("dis_signal_ok_en") : "(dis_signal_ok_dis,dis_signal_ok_en)";
	localparam rbc_any_dis_signal_ok = (fnl_prot_mode == "disable_mode" || fnl_lpbk_mode == "lpbk_en") ? ("dis_signal_ok_dis")
		 : (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("dis_signal_ok_en") : "dis_signal_ok_dis";
	localparam fnl_dis_signal_ok = (dis_signal_ok == "<auto_any>" || dis_signal_ok == "<auto_single>") ? rbc_any_dis_signal_ok : dis_signal_ok;

	// dispchk_pipeln, RBC-validated >> REVE <<
	localparam rbc_all_dispchk_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(dispchk_pipeln_en,dispchk_pipeln_dis)") : "dispchk_pipeln_en"
		) : "dispchk_pipeln_en";
	localparam rbc_any_dispchk_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("dispchk_pipeln_dis") : "dispchk_pipeln_en"
		) : "dispchk_pipeln_en";
	localparam fnl_dispchk_pipeln = (dispchk_pipeln == "<auto_any>" || dispchk_pipeln == "<auto_single>") ? rbc_any_dispchk_pipeln : dispchk_pipeln;

	// dispchk_rd_level, RBC-validated >> REVE <<
	localparam rbc_all_dispchk_rd_level = "dispchk_rd_level_int";
	localparam rbc_any_dispchk_rd_level = "dispchk_rd_level_int";
	localparam fnl_dispchk_rd_level = (dispchk_rd_level == "<auto_any>" || dispchk_rd_level == "<auto_single>") ? rbc_any_dispchk_rd_level : dispchk_rd_level;

	// rx_sm_pipeln, RBC-validated >> REVE <<
	localparam rbc_all_rx_sm_pipeln = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(rx_sm_pipeln_en,rx_sm_pipeln_dis)") : "rx_sm_pipeln_en"
		) : "rx_sm_pipeln_en";
	localparam rbc_any_rx_sm_pipeln = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("rx_sm_pipeln_dis") : "rx_sm_pipeln_en"
		) : "rx_sm_pipeln_en";
	localparam fnl_rx_sm_pipeln = (rx_sm_pipeln == "<auto_any>" || rx_sm_pipeln == "<auto_single>") ? rbc_any_rx_sm_pipeln : rx_sm_pipeln;

	// rx_sm_hiber, RBC-validated >> REVE <<
	localparam rbc_all_rx_sm_hiber = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(rx_sm_hiber_en,rx_sm_hiber_dis)") : "rx_sm_hiber_en"
		) : "rx_sm_hiber_en";
	localparam rbc_any_rx_sm_hiber = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("rx_sm_hiber_en") : "rx_sm_hiber_en"
		) : "rx_sm_hiber_en";
	localparam fnl_rx_sm_hiber = (rx_sm_hiber == "<auto_any>" || rx_sm_hiber == "<auto_single>") ? rbc_any_rx_sm_hiber : rx_sm_hiber;

	// ber_xus_timer_window, RBC-validated >> REVE <<
	localparam rbc_all_ber_xus_timer_window = (fnl_sup_mode == "engineering_mode" && (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("(xus_timer_window_10g,xus_timer_window_user_setting)") : "xus_timer_window_10g";
	localparam rbc_any_ber_xus_timer_window = (fnl_sup_mode == "engineering_mode" && (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode")) ? ("xus_timer_window_10g") : "xus_timer_window_10g";
	localparam fnl_ber_xus_timer_window = (ber_xus_timer_window == "<auto_any>" || ber_xus_timer_window == "<auto_single>") ? rbc_any_ber_xus_timer_window : ber_xus_timer_window;

	// frmsync_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_frmsync_flag_type = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(all_framing_words,location_only)") : "all_framing_words"
		) : "all_framing_words";
	localparam rbc_any_frmsync_flag_type = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("all_framing_words") : "all_framing_words"
		) : "all_framing_words";
	localparam fnl_frmsync_flag_type = (frmsync_flag_type == "<auto_any>" || frmsync_flag_type == "<auto_single>") ? rbc_any_frmsync_flag_type : frmsync_flag_type;

	// frmsync_pipeln, RBC-validated >> REVE <<
	localparam rbc_all_frmsync_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(frmsync_pipeln_en,frmsync_pipeln_dis)") : "frmsync_pipeln_en"
		) : "frmsync_pipeln_en";
	localparam rbc_any_frmsync_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("frmsync_pipeln_dis") : "frmsync_pipeln_en"
		) : "frmsync_pipeln_en";
	localparam fnl_frmsync_pipeln = (frmsync_pipeln == "<auto_any>" || frmsync_pipeln == "<auto_single>") ? rbc_any_frmsync_pipeln : frmsync_pipeln;

	// frmsync_mfrm_length, RBC-validated >> REVE <<

   localparam rbc_all_frmsync_mfrm_length = "mfrm_user_length";
   localparam rbc_any_frmsync_mfrm_length = "mfrm_user_length";
   localparam fnl_frmsync_mfrm_length = (frmsync_mfrm_length == "<auto_any>" || frmsync_mfrm_length == "<auto_single>") ? rbc_any_frmsync_mfrm_length : frmsync_mfrm_length;


	// crcflag_pipeln, RBC-validated >> REVE <<
	localparam rbc_all_crcflag_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(crcflag_pipeln_dis,crcflag_pipeln_en)") : "crcflag_pipeln_en"
		) : "crcflag_pipeln_en";
	localparam rbc_any_crcflag_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("crcflag_pipeln_dis") : "crcflag_pipeln_en"
		) : "crcflag_pipeln_en";
	localparam fnl_crcflag_pipeln = (crcflag_pipeln == "<auto_any>" || crcflag_pipeln == "<auto_single>") ? rbc_any_crcflag_pipeln : crcflag_pipeln;

	// crcchk_pipeln, RBC-validated >> REVE <<
	localparam rbc_all_crcchk_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(crcchk_pipeln_dis,crcchk_pipeln_en)") : "crcchk_pipeln_dis"
		) : "crcchk_pipeln_en";
	localparam rbc_any_crcchk_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("crcchk_pipeln_dis") : "crcchk_pipeln_dis"
		) : "crcchk_pipeln_en";
	localparam fnl_crcchk_pipeln = (crcchk_pipeln == "<auto_any>" || crcchk_pipeln == "<auto_single>") ? rbc_any_crcchk_pipeln : crcchk_pipeln;

	// crcchk_inv, RBC-validated >> REVE <<
	localparam rbc_all_crcchk_inv = (fnl_prot_mode == "interlaken_mode") ? ("crcchk_inv_en") : "crcchk_inv_en";
	localparam rbc_any_crcchk_inv = (fnl_prot_mode == "interlaken_mode") ? ("crcchk_inv_en") : "crcchk_inv_en";
	localparam fnl_crcchk_inv = (crcchk_inv == "<auto_any>" || crcchk_inv == "<auto_single>") ? rbc_any_crcchk_inv : crcchk_inv;

	// descrm_mode, RBC-validated >> REVE <<
	localparam rbc_all_descrm_mode = (fnl_prot_mode == "interlaken_mode") ? ("sync") : "async";
	localparam rbc_any_descrm_mode = (fnl_prot_mode == "interlaken_mode") ? ("sync") : "async";
	localparam fnl_descrm_mode = (descrm_mode == "<auto_any>" || descrm_mode == "<auto_single>") ? rbc_any_descrm_mode : descrm_mode;

	// rx_scrm_width, RBC-validated >> REVE <<
	localparam rbc_all_rx_scrm_width = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("bit64")
		 : (fnl_prot_mode == "basic_mode" && fnl_descrm_bypass == "descrm_bypass_dis") ?
			(
				(fnl_gb_rx_odwidth == "width_67") ? ("(bit67,bit64)")
				 : (fnl_gb_rx_odwidth == "width_66") ? ("(bit66,bit64)") : "(bit64,bit66,bit67)"
			) : "bit64";
	localparam rbc_any_rx_scrm_width = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("bit64")
		 : (fnl_prot_mode == "basic_mode" && fnl_descrm_bypass == "descrm_bypass_dis") ?
			(
				(fnl_gb_rx_odwidth == "width_67") ? ("bit64")
				 : (fnl_gb_rx_odwidth == "width_66") ? ("bit64") : "bit64"
			) : "bit64";
	localparam fnl_rx_scrm_width = (rx_scrm_width == "<auto_any>" || rx_scrm_width == "<auto_single>") ? rbc_any_rx_scrm_width : rx_scrm_width;

	// gb_sel_mode, RBC-validated >> REVE <<
	localparam rbc_all_gb_sel_mode = ((fnl_prot_mode == "teng_sdi_mode") && (fnl_sup_mode == "engineering_mode")) ? ("(internal,external)") : "internal";
	localparam rbc_any_gb_sel_mode = ((fnl_prot_mode == "teng_sdi_mode") && (fnl_sup_mode == "engineering_mode")) ? ("internal") : "internal";
	localparam fnl_gb_sel_mode = (gb_sel_mode == "<auto_any>" || gb_sel_mode == "<auto_single>") ? rbc_any_gb_sel_mode : gb_sel_mode;

	// test_mode, RBC-validated >> REVE <<
	localparam rbc_all_test_mode = (fnl_prot_mode == "test_prbs_mode") ? ("(prbs_31,prbs_23,prbs_9,prbs_7)")
		 : (fnl_prot_mode == "test_prp_mode") ? ("pseudo_random") : "test_off";
	localparam rbc_any_test_mode = (fnl_prot_mode == "test_prbs_mode") ? ("prbs_31")
		 : (fnl_prot_mode == "test_prp_mode") ? ("pseudo_random") : "test_off";
	localparam fnl_test_mode = (test_mode == "<auto_any>" || test_mode == "<auto_single>") ? rbc_any_test_mode : test_mode;

	// rx_prbs_mask, RBC-validated >> REVE <<
	localparam rbc_all_rx_prbs_mask = (fnl_prot_mode == "test_prbs_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(prbsmask128,prbsmask256,prbsmask512,prbsmask1024)") : "prbsmask1024"
		)
		 : (fnl_prot_mode == "test_prp_mode") ? ("prbsmask128") : "prbsmask128";
	localparam rbc_any_rx_prbs_mask = (fnl_prot_mode == "test_prbs_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("prbsmask128") : "prbsmask1024"
		)
		 : (fnl_prot_mode == "test_prp_mode") ? ("prbsmask128") : "prbsmask128";
	localparam fnl_rx_prbs_mask = (rx_prbs_mask == "<auto_any>" || rx_prbs_mask == "<auto_single>") ? rbc_any_rx_prbs_mask : rx_prbs_mask;

	// stretch_type, RBC-validated >> REVE <<
	localparam rbc_all_stretch_type = (fnl_sup_mode == "engineering_mode") ? ("(stretch_custom,stretch_auto)") : "stretch_auto";
	localparam rbc_any_stretch_type = (fnl_sup_mode == "engineering_mode") ? ("stretch_auto") : "stretch_auto";
	localparam fnl_stretch_type = (stretch_type == "<auto_any>" || stretch_type == "<auto_single>") ? rbc_any_stretch_type : stretch_type;

	// stretch_en, RBC-validated >> REVE <<
	localparam rbc_all_stretch_en = (fnl_sup_mode == "engineering_mode") ? ("(stretch_en,stretch_dis)") : "stretch_en";
	localparam rbc_any_stretch_en = (fnl_sup_mode == "engineering_mode") ? ("stretch_en") : "stretch_en";
	localparam fnl_stretch_en = (stretch_en == "<auto_any>" || stretch_en == "<auto_single>") ? rbc_any_stretch_en : stretch_en;

	// stretch_num_stages, RBC-validated >> REVE <<
	localparam rbc_all_stretch_num_stages = (fnl_sup_mode == "engineering_mode") ?
		(
			(fnl_stretch_type == "stretch_custom") ? ("(zero_stage,one_stage,two_stage,three_stage)") : "(zero_stage,one_stage,two_stage,three_stage)"
		) : "zero_stage";
	localparam rbc_any_stretch_num_stages = (fnl_sup_mode == "engineering_mode") ?
		(
			(fnl_stretch_type == "stretch_custom") ? ("zero_stage") : "zero_stage"
		) : "zero_stage";
	localparam fnl_stretch_num_stages = (stretch_num_stages == "<auto_any>" || stretch_num_stages == "<auto_single>") ? rbc_any_stretch_num_stages : stretch_num_stages;

	// iqtxrx_clkout_sel, RBC-validated >> REVE <<
	localparam rbc_all_iqtxrx_clkout_sel = (fnl_sup_mode == "engineering_mode") ? ("(iq_rx_clk_out,iq_rx_pma_clk_div33)") : "iq_rx_clk_out";
	localparam rbc_any_iqtxrx_clkout_sel = (fnl_sup_mode == "engineering_mode") ? ("iq_rx_clk_out") : "iq_rx_clk_out";
	localparam fnl_iqtxrx_clkout_sel = (iqtxrx_clkout_sel == "<auto_any>" || iqtxrx_clkout_sel == "<auto_single>") ? rbc_any_iqtxrx_clkout_sel : iqtxrx_clkout_sel;

	// bitslip_mode, RBC-validated >> REVE <<
	localparam rbc_all_bitslip_mode = (fnl_prot_mode == "teng_sdi_mode") ?
		(
			((fnl_sup_mode == "engineering_mode")) ? ("(bitslip_dis,bitslip_en)") : "bitslip_dis"
		)
		 : (fnl_prot_mode == "sfis_mode") ?
			(
				((fnl_sup_mode == "engineering_mode")) ? ("(bitslip_dis,bitslip_en)")
				 : ((fnl_gb_rx_odwidth == "width_32" && fnl_gb_rx_idwidth == "width_32") ||
             (fnl_gb_rx_odwidth == "width_40" && fnl_gb_rx_idwidth == "width_40") ||
             (fnl_gb_rx_odwidth == "width_64" && fnl_gb_rx_idwidth == "width_64")) ? ("(bitslip_dis,bitslip_en)") : "bitslip_dis"
			)
			 : ((fnl_prot_mode == "basic_mode" && fnl_blksync_bypass == "blksync_bypass_en")) ?
				(
					((fnl_sup_mode == "engineering_mode")) ? ("(bitslip_dis,bitslip_en)")
					 : ((fnl_gb_rx_odwidth == "width_32" && fnl_gb_rx_idwidth == "width_32") ||
             (fnl_gb_rx_odwidth == "width_40" && fnl_gb_rx_idwidth == "width_40") ||
             (fnl_gb_rx_odwidth == "width_66" && fnl_gb_rx_idwidth == "width_40") ||
             (fnl_gb_rx_odwidth == "width_64" && fnl_gb_rx_idwidth == "width_64")) ? ("(bitslip_dis,bitslip_en)") : "bitslip_dis"
				) : "bitslip_dis";
	localparam rbc_any_bitslip_mode = (fnl_prot_mode == "teng_sdi_mode") ?
		(
			((fnl_sup_mode == "engineering_mode")) ? ("bitslip_dis") : "bitslip_dis"
		)
		 : (fnl_prot_mode == "sfis_mode") ?
			(
				((fnl_sup_mode == "engineering_mode")) ? ("bitslip_dis")
				 : ((fnl_gb_rx_odwidth == "width_32" && fnl_gb_rx_idwidth == "width_32") ||
             (fnl_gb_rx_odwidth == "width_40" && fnl_gb_rx_idwidth == "width_40") ||
             (fnl_gb_rx_odwidth == "width_64" && fnl_gb_rx_idwidth == "width_64")) ? ("bitslip_dis") : "bitslip_dis"
			)
			 : ((fnl_prot_mode == "basic_mode" && fnl_blksync_bypass == "blksync_bypass_en")) ?
				(
					((fnl_sup_mode == "engineering_mode")) ? ("bitslip_dis")
					 : ((fnl_gb_rx_odwidth == "width_32" && fnl_gb_rx_idwidth == "width_32") ||
             (fnl_gb_rx_odwidth == "width_40" && fnl_gb_rx_idwidth == "width_40") ||
             (fnl_gb_rx_odwidth == "width_66" && fnl_gb_rx_idwidth == "width_40") ||
             (fnl_gb_rx_odwidth == "width_64" && fnl_gb_rx_idwidth == "width_64")) ? ("bitslip_dis") : "bitslip_dis"
				) : "bitslip_dis";
	localparam fnl_bitslip_mode = (bitslip_mode == "<auto_any>" || bitslip_mode == "<auto_single>") ? rbc_any_bitslip_mode : bitslip_mode;

	// rx_testbus_sel, RBC-validated >> REVE <<
	localparam rbc_all_rx_testbus_sel = (fnl_prot_mode == "disable_mode") ? ("rx_fifo_testbus1") : "(ber_testbus,blksync_testbus1,blksync_testbus2,crc32_chk_testbus1,crc32_chk_testbus2,dec64b66b_testbus,descramble_testbus,blank_testbus,disp_chk_testbus1,disp_chk_testbus2,frame_sync_testbus1,frame_sync_testbus2,gearbox_exp_testbus,random_ver_testbus,prbs_ver_xg_testbus,rx_fifo_testbus1,rx_fifo_testbus2,rxsm_testbus)";
	localparam rbc_any_rx_testbus_sel = (fnl_prot_mode == "disable_mode") ? ("rx_fifo_testbus1") : "crc32_chk_testbus1";
	localparam fnl_rx_testbus_sel = (rx_testbus_sel == "<auto_any>" || rx_testbus_sel == "<auto_single>") ? rbc_any_rx_testbus_sel : rx_testbus_sel;

	// rx_polarity_inv, RBC-validated >> REVE <<
	localparam rbc_all_rx_polarity_inv = (fnl_prot_mode == "disable_mode") ? ("invert_disable") : "(invert_disable,invert_enable)";
	localparam rbc_any_rx_polarity_inv = (fnl_prot_mode == "disable_mode") ? ("invert_disable") : "invert_disable";
	localparam fnl_rx_polarity_inv = (rx_polarity_inv == "<auto_any>" || rx_polarity_inv == "<auto_single>") ? rbc_any_rx_polarity_inv : rx_polarity_inv;




   //========================REVE RULES END  ==============================================================================
 
`endif



	// Validate input parameters against known values or RBC values
	initial begin
		//$display("prot_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", prot_mode, rbc_any_prot_mode, rbc_all_prot_mode, fnl_prot_mode);
		if (!is_in_legal_set(prot_mode, rbc_all_prot_mode)) begin
			$display("Critical Warning: parameter 'prot_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", prot_mode, rbc_all_prot_mode, fnl_prot_mode);
		end
		//$display("sup_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", sup_mode, rbc_any_sup_mode, rbc_all_sup_mode, fnl_sup_mode);
		if (!is_in_legal_set(sup_mode, rbc_all_sup_mode)) begin
			$display("Critical Warning: parameter 'sup_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", sup_mode, rbc_all_sup_mode, fnl_sup_mode);
		end
		//$display("bit_reverse = orig: '%s', any:'%s', all:'%s', final: '%s'", bit_reverse, rbc_any_bit_reverse, rbc_all_bit_reverse, fnl_bit_reverse);
		if (!is_in_legal_set(bit_reverse, rbc_all_bit_reverse)) begin
			$display("Critical Warning: parameter 'bit_reverse' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", bit_reverse, rbc_all_bit_reverse, fnl_bit_reverse);
		end
		//$display("blksync_bitslip_wait_cnt = orig: '%s', any:'%s', all:'%s', final: '%s'", blksync_bitslip_wait_cnt, rbc_any_blksync_bitslip_wait_cnt, rbc_all_blksync_bitslip_wait_cnt, fnl_blksync_bitslip_wait_cnt);
		//if (!is_in_legal_set(blksync_bitslip_wait_cnt, rbc_all_blksync_bitslip_wait_cnt)) begin
		//	$display("Critical Warning: parameter 'blksync_bitslip_wait_cnt' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", blksync_bitslip_wait_cnt, rbc_all_blksync_bitslip_wait_cnt, fnl_blksync_bitslip_wait_cnt);
		//end
		//$display("crcchk_init = orig: '%s', any:'%s', all:'%s', final: '%s'", crcchk_init, rbc_any_crcchk_init, rbc_all_crcchk_init, fnl_crcchk_init);
		if (!is_in_legal_set(crcchk_init, rbc_all_crcchk_init)) begin
			$display("Critical Warning: parameter 'crcchk_init' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", crcchk_init, rbc_all_crcchk_init, fnl_crcchk_init);
		end
		//$display("dispchk_rd_level = orig: '%s', any:'%s', all:'%s', final: '%s'", dispchk_rd_level, rbc_any_dispchk_rd_level, rbc_all_dispchk_rd_level, fnl_dispchk_rd_level);
		if (!is_in_legal_set(dispchk_rd_level, rbc_all_dispchk_rd_level)) begin
			$display("Critical Warning: parameter 'dispchk_rd_level' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dispchk_rd_level, rbc_all_dispchk_rd_level, fnl_dispchk_rd_level);
		end
		//$display("frmsync_mfrm_length = orig: '%s', any:'%s', all:'%s', final: '%s'", frmsync_mfrm_length, rbc_any_frmsync_mfrm_length, rbc_all_frmsync_mfrm_length, fnl_frmsync_mfrm_length);
		//if (!is_in_legal_set(frmsync_mfrm_length, rbc_all_frmsync_mfrm_length)) begin
		//	$display("Critical Warning: parameter 'frmsync_mfrm_length' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", frmsync_mfrm_length, rbc_all_frmsync_mfrm_length, fnl_frmsync_mfrm_length);
		//end
		//$display("stretch_en = orig: '%s', any:'%s', all:'%s', final: '%s'", stretch_en, rbc_any_stretch_en, rbc_all_stretch_en, fnl_stretch_en);
		if (!is_in_legal_set(stretch_en, rbc_all_stretch_en)) begin
			$display("Critical Warning: parameter 'stretch_en' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", stretch_en, rbc_all_stretch_en, fnl_stretch_en);
		end
		//$display("test_bus_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", test_bus_mode, rbc_any_test_bus_mode, rbc_all_test_bus_mode, fnl_test_bus_mode);
		if (!is_in_legal_set(test_bus_mode, rbc_all_test_bus_mode)) begin
			$display("Critical Warning: parameter 'test_bus_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", test_bus_mode, rbc_all_test_bus_mode, fnl_test_bus_mode);
		end
		//$display("use_default_base_address = orig: '%s', any:'%s', all:'%s', final: '%s'", use_default_base_address, rbc_any_use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		if (!is_in_legal_set(use_default_base_address, rbc_all_use_default_base_address)) begin
			$display("Critical Warning: parameter 'use_default_base_address' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		end
		//$display("gb_rx_idwidth = orig: '%s', any:'%s', all:'%s', final: '%s'", gb_rx_idwidth, rbc_any_gb_rx_idwidth, rbc_all_gb_rx_idwidth, fnl_gb_rx_idwidth);
		if (!is_in_legal_set(gb_rx_idwidth, rbc_all_gb_rx_idwidth)) begin
			$display("Critical Warning: parameter 'gb_rx_idwidth' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", gb_rx_idwidth, rbc_all_gb_rx_idwidth, fnl_gb_rx_idwidth);
		end
		//$display("gb_rx_odwidth = orig: '%s', any:'%s', all:'%s', final: '%s'", gb_rx_odwidth, rbc_any_gb_rx_odwidth, rbc_all_gb_rx_odwidth, fnl_gb_rx_odwidth);
		if (!is_in_legal_set(gb_rx_odwidth, rbc_all_gb_rx_odwidth)) begin
			$display("Critical Warning: parameter 'gb_rx_odwidth' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", gb_rx_odwidth, rbc_all_gb_rx_odwidth, fnl_gb_rx_odwidth);
		end
		//$display("lpbk_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", lpbk_mode, rbc_any_lpbk_mode, rbc_all_lpbk_mode, fnl_lpbk_mode);
		if (!is_in_legal_set(lpbk_mode, rbc_all_lpbk_mode)) begin
			$display("Critical Warning: parameter 'lpbk_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", lpbk_mode, rbc_all_lpbk_mode, fnl_lpbk_mode);
		end
		//$display("rx_dfx_lpbk = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_dfx_lpbk, rbc_any_rx_dfx_lpbk, rbc_all_rx_dfx_lpbk, fnl_rx_dfx_lpbk);
		if (!is_in_legal_set(rx_dfx_lpbk, rbc_all_rx_dfx_lpbk)) begin
			$display("Critical Warning: parameter 'rx_dfx_lpbk' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_dfx_lpbk, rbc_all_rx_dfx_lpbk, fnl_rx_dfx_lpbk);
		end
		//$display("master_clk_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", master_clk_sel, rbc_any_master_clk_sel, rbc_all_master_clk_sel, fnl_master_clk_sel);
		if (!is_in_legal_set(master_clk_sel, rbc_all_master_clk_sel)) begin
			$display("Critical Warning: parameter 'master_clk_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", master_clk_sel, rbc_all_master_clk_sel, fnl_master_clk_sel);
		end
		//$display("blksync_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", blksync_bypass, rbc_any_blksync_bypass, rbc_all_blksync_bypass, fnl_blksync_bypass);
		if (!is_in_legal_set(blksync_bypass, rbc_all_blksync_bypass)) begin
			$display("Critical Warning: parameter 'blksync_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", blksync_bypass, rbc_all_blksync_bypass, fnl_blksync_bypass);
		end
		//$display("rxfifo_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", rxfifo_mode, rbc_any_rxfifo_mode, rbc_all_rxfifo_mode, fnl_rxfifo_mode);
		if (!is_in_legal_set(rxfifo_mode, rbc_all_rxfifo_mode)) begin
			$display("Critical Warning: parameter 'rxfifo_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rxfifo_mode, rbc_all_rxfifo_mode, fnl_rxfifo_mode);
		end
		//$display("rd_clk_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", rd_clk_sel, rbc_any_rd_clk_sel, rbc_all_rd_clk_sel, fnl_rd_clk_sel);
		if (!is_in_legal_set(rd_clk_sel, rbc_all_rd_clk_sel)) begin
			$display("Critical Warning: parameter 'rd_clk_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rd_clk_sel, rbc_all_rd_clk_sel, fnl_rd_clk_sel);
		end
		//$display("gbexp_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", gbexp_clken, rbc_any_gbexp_clken, rbc_all_gbexp_clken, fnl_gbexp_clken);
		if (!is_in_legal_set(gbexp_clken, rbc_all_gbexp_clken)) begin
			$display("Critical Warning: parameter 'gbexp_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", gbexp_clken, rbc_all_gbexp_clken, fnl_gbexp_clken);
		end
		//$display("dispchk_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", dispchk_clken, rbc_any_dispchk_clken, rbc_all_dispchk_clken, fnl_dispchk_clken);
		if (!is_in_legal_set(dispchk_clken, rbc_all_dispchk_clken)) begin
			$display("Critical Warning: parameter 'dispchk_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dispchk_clken, rbc_all_dispchk_clken, fnl_dispchk_clken);
		end
		//$display("frmsync_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", frmsync_bypass, rbc_any_frmsync_bypass, rbc_all_frmsync_bypass, fnl_frmsync_bypass);
		if (!is_in_legal_set(frmsync_bypass, rbc_all_frmsync_bypass)) begin
			$display("Critical Warning: parameter 'frmsync_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", frmsync_bypass, rbc_all_frmsync_bypass, fnl_frmsync_bypass);
		end
		//$display("dec64b66b_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", dec64b66b_clken, rbc_any_dec64b66b_clken, rbc_all_dec64b66b_clken, fnl_dec64b66b_clken);
		if (!is_in_legal_set(dec64b66b_clken, rbc_all_dec64b66b_clken)) begin
			$display("Critical Warning: parameter 'dec64b66b_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dec64b66b_clken, rbc_all_dec64b66b_clken, fnl_dec64b66b_clken);
		end
		//$display("dec_64b66b_rxsm_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", dec_64b66b_rxsm_bypass, rbc_any_dec_64b66b_rxsm_bypass, rbc_all_dec_64b66b_rxsm_bypass, fnl_dec_64b66b_rxsm_bypass);
		if (!is_in_legal_set(dec_64b66b_rxsm_bypass, rbc_all_dec_64b66b_rxsm_bypass)) begin
			$display("Critical Warning: parameter 'dec_64b66b_rxsm_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dec_64b66b_rxsm_bypass, rbc_all_dec_64b66b_rxsm_bypass, fnl_dec_64b66b_rxsm_bypass);
		end
		//$display("wrfifo_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", wrfifo_clken, rbc_any_wrfifo_clken, rbc_all_wrfifo_clken, fnl_wrfifo_clken);
		if (!is_in_legal_set(wrfifo_clken, rbc_all_wrfifo_clken)) begin
			$display("Critical Warning: parameter 'wrfifo_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", wrfifo_clken, rbc_all_wrfifo_clken, fnl_wrfifo_clken);
		end
		//$display("descrm_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", descrm_clken, rbc_any_descrm_clken, rbc_all_descrm_clken, fnl_descrm_clken);
		if (!is_in_legal_set(descrm_clken, rbc_all_descrm_clken)) begin
			$display("Critical Warning: parameter 'descrm_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", descrm_clken, rbc_all_descrm_clken, fnl_descrm_clken);
		end
		//$display("frmsync_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", frmsync_clken, rbc_any_frmsync_clken, rbc_all_frmsync_clken, fnl_frmsync_clken);
		if (!is_in_legal_set(frmsync_clken, rbc_all_frmsync_clken)) begin
			$display("Critical Warning: parameter 'frmsync_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", frmsync_clken, rbc_all_frmsync_clken, fnl_frmsync_clken);
		end
		//$display("descrm_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", descrm_bypass, rbc_any_descrm_bypass, rbc_all_descrm_bypass, fnl_descrm_bypass);
		if (!is_in_legal_set(descrm_bypass, rbc_all_descrm_bypass)) begin
			$display("Critical Warning: parameter 'descrm_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", descrm_bypass, rbc_all_descrm_bypass, fnl_descrm_bypass);
		end
		//$display("blksync_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", blksync_clken, rbc_any_blksync_clken, rbc_all_blksync_clken, fnl_blksync_clken);
		if (!is_in_legal_set(blksync_clken, rbc_all_blksync_clken)) begin
			$display("Critical Warning: parameter 'blksync_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", blksync_clken, rbc_all_blksync_clken, fnl_blksync_clken);
		end
		//$display("crcchk_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", crcchk_bypass, rbc_any_crcchk_bypass, rbc_all_crcchk_bypass, fnl_crcchk_bypass);
		if (!is_in_legal_set(crcchk_bypass, rbc_all_crcchk_bypass)) begin
			$display("Critical Warning: parameter 'crcchk_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", crcchk_bypass, rbc_all_crcchk_bypass, fnl_crcchk_bypass);
		end
		//$display("rx_sm_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_sm_bypass, rbc_any_rx_sm_bypass, rbc_all_rx_sm_bypass, fnl_rx_sm_bypass);
		if (!is_in_legal_set(rx_sm_bypass, rbc_all_rx_sm_bypass)) begin
			$display("Critical Warning: parameter 'rx_sm_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_sm_bypass, rbc_all_rx_sm_bypass, fnl_rx_sm_bypass);
		end
		//$display("prbs_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", prbs_clken, rbc_any_prbs_clken, rbc_all_prbs_clken, fnl_prbs_clken);
		if (!is_in_legal_set(prbs_clken, rbc_all_prbs_clken)) begin
			$display("Critical Warning: parameter 'prbs_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", prbs_clken, rbc_all_prbs_clken, fnl_prbs_clken);
		end
		//$display("ber_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", ber_clken, rbc_any_ber_clken, rbc_all_ber_clken, fnl_ber_clken);
		if (!is_in_legal_set(ber_clken, rbc_all_ber_clken)) begin
			$display("Critical Warning: parameter 'ber_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ber_clken, rbc_all_ber_clken, fnl_ber_clken);
		end
		//$display("dispchk_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", dispchk_bypass, rbc_any_dispchk_bypass, rbc_all_dispchk_bypass, fnl_dispchk_bypass);
		if (!is_in_legal_set(dispchk_bypass, rbc_all_dispchk_bypass)) begin
			$display("Critical Warning: parameter 'dispchk_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dispchk_bypass, rbc_all_dispchk_bypass, fnl_dispchk_bypass);
		end
		//$display("rand_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", rand_clken, rbc_any_rand_clken, rbc_all_rand_clken, fnl_rand_clken);
		if (!is_in_legal_set(rand_clken, rbc_all_rand_clken)) begin
			$display("Critical Warning: parameter 'rand_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rand_clken, rbc_all_rand_clken, fnl_rand_clken);
		end
		//$display("rdfifo_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", rdfifo_clken, rbc_any_rdfifo_clken, rbc_all_rdfifo_clken, fnl_rdfifo_clken);
		if (!is_in_legal_set(rdfifo_clken, rbc_all_rdfifo_clken)) begin
			$display("Critical Warning: parameter 'rdfifo_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rdfifo_clken, rbc_all_rdfifo_clken, fnl_rdfifo_clken);
		end
		//$display("crcchk_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", crcchk_clken, rbc_any_crcchk_clken, rbc_all_crcchk_clken, fnl_crcchk_clken);
		if (!is_in_legal_set(crcchk_clken, rbc_all_crcchk_clken)) begin
			$display("Critical Warning: parameter 'crcchk_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", crcchk_clken, rbc_all_crcchk_clken, fnl_crcchk_clken);
		end
		//$display("fast_path = orig: '%s', any:'%s', all:'%s', final: '%s'", fast_path, rbc_any_fast_path, rbc_all_fast_path, fnl_fast_path);
		if (!is_in_legal_set(fast_path, rbc_all_fast_path)) begin
			$display("Critical Warning: parameter 'fast_path' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", fast_path, rbc_all_fast_path, fnl_fast_path);
		end
		//$display("data_bit_reverse = orig: '%s', any:'%s', all:'%s', final: '%s'", data_bit_reverse, rbc_any_data_bit_reverse, rbc_all_data_bit_reverse, fnl_data_bit_reverse);
		if (!is_in_legal_set(data_bit_reverse, rbc_all_data_bit_reverse)) begin
			$display("Critical Warning: parameter 'data_bit_reverse' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", data_bit_reverse, rbc_all_data_bit_reverse, fnl_data_bit_reverse);
		end
		//$display("ctrl_bit_reverse = orig: '%s', any:'%s', all:'%s', final: '%s'", ctrl_bit_reverse, rbc_any_ctrl_bit_reverse, rbc_all_ctrl_bit_reverse, fnl_ctrl_bit_reverse);
		if (!is_in_legal_set(ctrl_bit_reverse, rbc_all_ctrl_bit_reverse)) begin
			$display("Critical Warning: parameter 'ctrl_bit_reverse' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ctrl_bit_reverse, rbc_all_ctrl_bit_reverse, fnl_ctrl_bit_reverse);
		end
		//$display("rx_sh_location = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_sh_location, rbc_any_rx_sh_location, rbc_all_rx_sh_location, fnl_rx_sh_location);
		if (!is_in_legal_set(rx_sh_location, rbc_all_rx_sh_location)) begin
			$display("Critical Warning: parameter 'rx_sh_location' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_sh_location, rbc_all_rx_sh_location, fnl_rx_sh_location);
		end
		//$display("full_flag_type = orig: '%s', any:'%s', all:'%s', final: '%s'", full_flag_type, rbc_any_full_flag_type, rbc_all_full_flag_type, fnl_full_flag_type);
		if (!is_in_legal_set(full_flag_type, rbc_all_full_flag_type)) begin
			$display("Critical Warning: parameter 'full_flag_type' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", full_flag_type, rbc_all_full_flag_type, fnl_full_flag_type);
		end
		//$display("empty_flag_type = orig: '%s', any:'%s', all:'%s', final: '%s'", empty_flag_type, rbc_any_empty_flag_type, rbc_all_empty_flag_type, fnl_empty_flag_type);
		if (!is_in_legal_set(empty_flag_type, rbc_all_empty_flag_type)) begin
			$display("Critical Warning: parameter 'empty_flag_type' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", empty_flag_type, rbc_all_empty_flag_type, fnl_empty_flag_type);
		end
		//$display("pfull_flag_type = orig: '%s', any:'%s', all:'%s', final: '%s'", pfull_flag_type, rbc_any_pfull_flag_type, rbc_all_pfull_flag_type, fnl_pfull_flag_type);
		if (!is_in_legal_set(pfull_flag_type, rbc_all_pfull_flag_type)) begin
			$display("Critical Warning: parameter 'pfull_flag_type' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pfull_flag_type, rbc_all_pfull_flag_type, fnl_pfull_flag_type);
		end
		//$display("pempty_flag_type = orig: '%s', any:'%s', all:'%s', final: '%s'", pempty_flag_type, rbc_any_pempty_flag_type, rbc_all_pempty_flag_type, fnl_pempty_flag_type);
		if (!is_in_legal_set(pempty_flag_type, rbc_all_pempty_flag_type)) begin
			$display("Critical Warning: parameter 'pempty_flag_type' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pempty_flag_type, rbc_all_pempty_flag_type, fnl_pempty_flag_type);
		end
		//$display("fifo_stop_rd = orig: '%s', any:'%s', all:'%s', final: '%s'", fifo_stop_rd, rbc_any_fifo_stop_rd, rbc_all_fifo_stop_rd, fnl_fifo_stop_rd);
		if (!is_in_legal_set(fifo_stop_rd, rbc_all_fifo_stop_rd)) begin
			$display("Critical Warning: parameter 'fifo_stop_rd' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", fifo_stop_rd, rbc_all_fifo_stop_rd, fnl_fifo_stop_rd);
		end
		//$display("fifo_stop_wr = orig: '%s', any:'%s', all:'%s', final: '%s'", fifo_stop_wr, rbc_any_fifo_stop_wr, rbc_all_fifo_stop_wr, fnl_fifo_stop_wr);
		if (!is_in_legal_set(fifo_stop_wr, rbc_all_fifo_stop_wr)) begin
			$display("Critical Warning: parameter 'fifo_stop_wr' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", fifo_stop_wr, rbc_all_fifo_stop_wr, fnl_fifo_stop_wr);
		end
		//$display("force_align = orig: '%s', any:'%s', all:'%s', final: '%s'", force_align, rbc_any_force_align, rbc_all_force_align, fnl_force_align);
		if (!is_in_legal_set(force_align, rbc_all_force_align)) begin
			$display("Critical Warning: parameter 'force_align' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", force_align, rbc_all_force_align, fnl_force_align);
		end
		//$display("control_del = orig: '%s', any:'%s', all:'%s', final: '%s'", control_del, rbc_any_control_del, rbc_all_control_del, fnl_control_del);
		if (!is_in_legal_set(control_del, rbc_all_control_del)) begin
			$display("Critical Warning: parameter 'control_del' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", control_del, rbc_all_control_del, fnl_control_del);
		end
		//$display("align_del = orig: '%s', any:'%s', all:'%s', final: '%s'", align_del, rbc_any_align_del, rbc_all_align_del, fnl_align_del);
		if (!is_in_legal_set(align_del, rbc_all_align_del)) begin
			$display("Critical Warning: parameter 'align_del' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", align_del, rbc_all_align_del, fnl_align_del);
		end
		//$display("rx_fifo_write_ctrl = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_fifo_write_ctrl, rbc_any_rx_fifo_write_ctrl, rbc_all_rx_fifo_write_ctrl, fnl_rx_fifo_write_ctrl);
		if (!is_in_legal_set(rx_fifo_write_ctrl, rbc_all_rx_fifo_write_ctrl)) begin
			$display("Critical Warning: parameter 'rx_fifo_write_ctrl' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_fifo_write_ctrl, rbc_all_rx_fifo_write_ctrl, fnl_rx_fifo_write_ctrl);
		end
		//$display("rx_true_b2b = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_true_b2b, rbc_any_rx_true_b2b, rbc_all_rx_true_b2b, fnl_rx_true_b2b);
		if (!is_in_legal_set(rx_true_b2b, rbc_all_rx_true_b2b)) begin
			$display("Critical Warning: parameter 'rx_true_b2b' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_true_b2b, rbc_all_rx_true_b2b, fnl_rx_true_b2b);
		end
		//$display("blksync_knum_sh_cnt_postlock = orig: '%s', any:'%s', all:'%s', final: '%s'", blksync_knum_sh_cnt_postlock, rbc_any_blksync_knum_sh_cnt_postlock, rbc_all_blksync_knum_sh_cnt_postlock, fnl_blksync_knum_sh_cnt_postlock);
		if (!is_in_legal_set(blksync_knum_sh_cnt_postlock, rbc_all_blksync_knum_sh_cnt_postlock)) begin
			$display("Critical Warning: parameter 'blksync_knum_sh_cnt_postlock' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", blksync_knum_sh_cnt_postlock, rbc_all_blksync_knum_sh_cnt_postlock, fnl_blksync_knum_sh_cnt_postlock);
		end
		//$display("blksync_bitslip_type = orig: '%s', any:'%s', all:'%s', final: '%s'", blksync_bitslip_type, rbc_any_blksync_bitslip_type, rbc_all_blksync_bitslip_type, fnl_blksync_bitslip_type);
		if (!is_in_legal_set(blksync_bitslip_type, rbc_all_blksync_bitslip_type)) begin
			$display("Critical Warning: parameter 'blksync_bitslip_type' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", blksync_bitslip_type, rbc_all_blksync_bitslip_type, fnl_blksync_bitslip_type);
		end
		//$display("blksync_bitslip_wait_type = orig: '%s', any:'%s', all:'%s', final: '%s'", blksync_bitslip_wait_type, rbc_any_blksync_bitslip_wait_type, rbc_all_blksync_bitslip_wait_type, fnl_blksync_bitslip_wait_type);
		if (!is_in_legal_set(blksync_bitslip_wait_type, rbc_all_blksync_bitslip_wait_type)) begin
			$display("Critical Warning: parameter 'blksync_bitslip_wait_type' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", blksync_bitslip_wait_type, rbc_all_blksync_bitslip_wait_type, fnl_blksync_bitslip_wait_type);
		end
		//$display("blksync_enum_invalid_sh_cnt = orig: '%s', any:'%s', all:'%s', final: '%s'", blksync_enum_invalid_sh_cnt, rbc_any_blksync_enum_invalid_sh_cnt, rbc_all_blksync_enum_invalid_sh_cnt, fnl_blksync_enum_invalid_sh_cnt);
		if (!is_in_legal_set(blksync_enum_invalid_sh_cnt, rbc_all_blksync_enum_invalid_sh_cnt)) begin
			$display("Critical Warning: parameter 'blksync_enum_invalid_sh_cnt' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", blksync_enum_invalid_sh_cnt, rbc_all_blksync_enum_invalid_sh_cnt, fnl_blksync_enum_invalid_sh_cnt);
		end
		//$display("blksync_pipeln = orig: '%s', any:'%s', all:'%s', final: '%s'", blksync_pipeln, rbc_any_blksync_pipeln, rbc_all_blksync_pipeln, fnl_blksync_pipeln);
		if (!is_in_legal_set(blksync_pipeln, rbc_all_blksync_pipeln)) begin
			$display("Critical Warning: parameter 'blksync_pipeln' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", blksync_pipeln, rbc_all_blksync_pipeln, fnl_blksync_pipeln);
		end
		//$display("blksync_knum_sh_cnt_prelock = orig: '%s', any:'%s', all:'%s', final: '%s'", blksync_knum_sh_cnt_prelock, rbc_any_blksync_knum_sh_cnt_prelock, rbc_all_blksync_knum_sh_cnt_prelock, fnl_blksync_knum_sh_cnt_prelock);
		if (!is_in_legal_set(blksync_knum_sh_cnt_prelock, rbc_all_blksync_knum_sh_cnt_prelock)) begin
			$display("Critical Warning: parameter 'blksync_knum_sh_cnt_prelock' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", blksync_knum_sh_cnt_prelock, rbc_all_blksync_knum_sh_cnt_prelock, fnl_blksync_knum_sh_cnt_prelock);
		end
		//$display("rx_signal_ok_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_signal_ok_sel, rbc_any_rx_signal_ok_sel, rbc_all_rx_signal_ok_sel, fnl_rx_signal_ok_sel);
		if (!is_in_legal_set(rx_signal_ok_sel, rbc_all_rx_signal_ok_sel)) begin
			$display("Critical Warning: parameter 'rx_signal_ok_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_signal_ok_sel, rbc_all_rx_signal_ok_sel, fnl_rx_signal_ok_sel);
		end
		//$display("dis_signal_ok = orig: '%s', any:'%s', all:'%s', final: '%s'", dis_signal_ok, rbc_any_dis_signal_ok, rbc_all_dis_signal_ok, fnl_dis_signal_ok);
		if (!is_in_legal_set(dis_signal_ok, rbc_all_dis_signal_ok)) begin
			$display("Critical Warning: parameter 'dis_signal_ok' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dis_signal_ok, rbc_all_dis_signal_ok, fnl_dis_signal_ok);
		end
		//$display("dispchk_pipeln = orig: '%s', any:'%s', all:'%s', final: '%s'", dispchk_pipeln, rbc_any_dispchk_pipeln, rbc_all_dispchk_pipeln, fnl_dispchk_pipeln);
		if (!is_in_legal_set(dispchk_pipeln, rbc_all_dispchk_pipeln)) begin
			$display("Critical Warning: parameter 'dispchk_pipeln' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dispchk_pipeln, rbc_all_dispchk_pipeln, fnl_dispchk_pipeln);
		end
		//$display("rx_sm_pipeln = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_sm_pipeln, rbc_any_rx_sm_pipeln, rbc_all_rx_sm_pipeln, fnl_rx_sm_pipeln);
		if (!is_in_legal_set(rx_sm_pipeln, rbc_all_rx_sm_pipeln)) begin
			$display("Critical Warning: parameter 'rx_sm_pipeln' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_sm_pipeln, rbc_all_rx_sm_pipeln, fnl_rx_sm_pipeln);
		end
		//$display("rx_sm_hiber = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_sm_hiber, rbc_any_rx_sm_hiber, rbc_all_rx_sm_hiber, fnl_rx_sm_hiber);
		if (!is_in_legal_set(rx_sm_hiber, rbc_all_rx_sm_hiber)) begin
			$display("Critical Warning: parameter 'rx_sm_hiber' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_sm_hiber, rbc_all_rx_sm_hiber, fnl_rx_sm_hiber);
		end
		//$display("ber_xus_timer_window = orig: '%s', any:'%s', all:'%s', final: '%s'", ber_xus_timer_window, rbc_any_ber_xus_timer_window, rbc_all_ber_xus_timer_window, fnl_ber_xus_timer_window);
		if (!is_in_legal_set(ber_xus_timer_window, rbc_all_ber_xus_timer_window)) begin
			$display("Critical Warning: parameter 'ber_xus_timer_window' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ber_xus_timer_window, rbc_all_ber_xus_timer_window, fnl_ber_xus_timer_window);
		end
		//$display("frmsync_flag_type = orig: '%s', any:'%s', all:'%s', final: '%s'", frmsync_flag_type, rbc_any_frmsync_flag_type, rbc_all_frmsync_flag_type, fnl_frmsync_flag_type);
		if (!is_in_legal_set(frmsync_flag_type, rbc_all_frmsync_flag_type)) begin
			$display("Critical Warning: parameter 'frmsync_flag_type' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", frmsync_flag_type, rbc_all_frmsync_flag_type, fnl_frmsync_flag_type);
		end
		//$display("frmsync_pipeln = orig: '%s', any:'%s', all:'%s', final: '%s'", frmsync_pipeln, rbc_any_frmsync_pipeln, rbc_all_frmsync_pipeln, fnl_frmsync_pipeln);
		if (!is_in_legal_set(frmsync_pipeln, rbc_all_frmsync_pipeln)) begin
			$display("Critical Warning: parameter 'frmsync_pipeln' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", frmsync_pipeln, rbc_all_frmsync_pipeln, fnl_frmsync_pipeln);
		end
		//$display("crcflag_pipeln = orig: '%s', any:'%s', all:'%s', final: '%s'", crcflag_pipeln, rbc_any_crcflag_pipeln, rbc_all_crcflag_pipeln, fnl_crcflag_pipeln);
		if (!is_in_legal_set(crcflag_pipeln, rbc_all_crcflag_pipeln)) begin
			$display("Critical Warning: parameter 'crcflag_pipeln' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", crcflag_pipeln, rbc_all_crcflag_pipeln, fnl_crcflag_pipeln);
		end
		//$display("crcchk_pipeln = orig: '%s', any:'%s', all:'%s', final: '%s'", crcchk_pipeln, rbc_any_crcchk_pipeln, rbc_all_crcchk_pipeln, fnl_crcchk_pipeln);
		if (!is_in_legal_set(crcchk_pipeln, rbc_all_crcchk_pipeln)) begin
			$display("Critical Warning: parameter 'crcchk_pipeln' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", crcchk_pipeln, rbc_all_crcchk_pipeln, fnl_crcchk_pipeln);
		end
		//$display("crcchk_inv = orig: '%s', any:'%s', all:'%s', final: '%s'", crcchk_inv, rbc_any_crcchk_inv, rbc_all_crcchk_inv, fnl_crcchk_inv);
		if (!is_in_legal_set(crcchk_inv, rbc_all_crcchk_inv)) begin
			$display("Critical Warning: parameter 'crcchk_inv' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", crcchk_inv, rbc_all_crcchk_inv, fnl_crcchk_inv);
		end
		//$display("descrm_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", descrm_mode, rbc_any_descrm_mode, rbc_all_descrm_mode, fnl_descrm_mode);
		if (!is_in_legal_set(descrm_mode, rbc_all_descrm_mode)) begin
			$display("Critical Warning: parameter 'descrm_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", descrm_mode, rbc_all_descrm_mode, fnl_descrm_mode);
		end
		//$display("rx_scrm_width = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_scrm_width, rbc_any_rx_scrm_width, rbc_all_rx_scrm_width, fnl_rx_scrm_width);
		if (!is_in_legal_set(rx_scrm_width, rbc_all_rx_scrm_width)) begin
			$display("Critical Warning: parameter 'rx_scrm_width' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_scrm_width, rbc_all_rx_scrm_width, fnl_rx_scrm_width);
		end
		//$display("gb_sel_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", gb_sel_mode, rbc_any_gb_sel_mode, rbc_all_gb_sel_mode, fnl_gb_sel_mode);
		if (!is_in_legal_set(gb_sel_mode, rbc_all_gb_sel_mode)) begin
			$display("Critical Warning: parameter 'gb_sel_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", gb_sel_mode, rbc_all_gb_sel_mode, fnl_gb_sel_mode);
		end
		//$display("test_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", test_mode, rbc_any_test_mode, rbc_all_test_mode, fnl_test_mode);
		if (!is_in_legal_set(test_mode, rbc_all_test_mode)) begin
			$display("Critical Warning: parameter 'test_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", test_mode, rbc_all_test_mode, fnl_test_mode);
		end
		//$display("rx_prbs_mask = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_prbs_mask, rbc_any_rx_prbs_mask, rbc_all_rx_prbs_mask, fnl_rx_prbs_mask);
		if (!is_in_legal_set(rx_prbs_mask, rbc_all_rx_prbs_mask)) begin
			$display("Critical Warning: parameter 'rx_prbs_mask' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_prbs_mask, rbc_all_rx_prbs_mask, fnl_rx_prbs_mask);
		end
		//$display("stretch_type = orig: '%s', any:'%s', all:'%s', final: '%s'", stretch_type, rbc_any_stretch_type, rbc_all_stretch_type, fnl_stretch_type);
		if (!is_in_legal_set(stretch_type, rbc_all_stretch_type)) begin
			$display("Critical Warning: parameter 'stretch_type' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", stretch_type, rbc_all_stretch_type, fnl_stretch_type);
		end
		//$display("stretch_num_stages = orig: '%s', any:'%s', all:'%s', final: '%s'", stretch_num_stages, rbc_any_stretch_num_stages, rbc_all_stretch_num_stages, fnl_stretch_num_stages);
		if (!is_in_legal_set(stretch_num_stages, rbc_all_stretch_num_stages)) begin
			$display("Critical Warning: parameter 'stretch_num_stages' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", stretch_num_stages, rbc_all_stretch_num_stages, fnl_stretch_num_stages);
		end
		//$display("iqtxrx_clkout_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", iqtxrx_clkout_sel, rbc_any_iqtxrx_clkout_sel, rbc_all_iqtxrx_clkout_sel, fnl_iqtxrx_clkout_sel);
		if (!is_in_legal_set(iqtxrx_clkout_sel, rbc_all_iqtxrx_clkout_sel)) begin
			$display("Critical Warning: parameter 'iqtxrx_clkout_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", iqtxrx_clkout_sel, rbc_all_iqtxrx_clkout_sel, fnl_iqtxrx_clkout_sel);
		end
		//$display("bitslip_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", bitslip_mode, rbc_any_bitslip_mode, rbc_all_bitslip_mode, fnl_bitslip_mode);
		if (!is_in_legal_set(bitslip_mode, rbc_all_bitslip_mode)) begin
			$display("Critical Warning: parameter 'bitslip_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", bitslip_mode, rbc_all_bitslip_mode, fnl_bitslip_mode);
		end
		//$display("rx_testbus_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_testbus_sel, rbc_any_rx_testbus_sel, rbc_all_rx_testbus_sel, fnl_rx_testbus_sel);
		if (!is_in_legal_set(rx_testbus_sel, rbc_all_rx_testbus_sel)) begin
			$display("Critical Warning: parameter 'rx_testbus_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_testbus_sel, rbc_all_rx_testbus_sel, fnl_rx_testbus_sel);
		end
		//$display("rx_polarity_inv = orig: '%s', any:'%s', all:'%s', final: '%s'", rx_polarity_inv, rbc_any_rx_polarity_inv, rbc_all_rx_polarity_inv, fnl_rx_polarity_inv);
		if (!is_in_legal_set(rx_polarity_inv, rbc_all_rx_polarity_inv)) begin
			$display("Critical Warning: parameter 'rx_polarity_inv' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rx_polarity_inv, rbc_all_rx_polarity_inv, fnl_rx_polarity_inv);
		end
	end

	stratixv_hssi_10g_rx_pcs #(
				   .silicon_rev(silicon_rev_local),
		.enable_debug_info("true"),
		.prot_mode(fnl_prot_mode),
		.sup_mode(fnl_sup_mode),
		.avmm_group_channel_index(avmm_group_channel_index),
		.ber_bit_err_total_cnt(ber_bit_err_total_cnt),
		.ber_xus_timer_window_user(ber_xus_timer_window_user),
		.bit_reverse(fnl_bit_reverse),
		.bitslip_wait_cnt_user(bitslip_wait_cnt_user),
		.blksync_bitslip_wait_cnt(fnl_blksync_bitslip_wait_cnt),
		.blksync_bitslip_wait_cnt_user(blksync_bitslip_wait_cnt_user),
		.channel_number(channel_number),
		.crcchk_init(fnl_crcchk_init),
		.crcchk_init_user(crcchk_init_user),
		.dispchk_rd_level(fnl_dispchk_rd_level),
		.dispchk_rd_level_user(dispchk_rd_level_user),
		.frmgen_diag_word(frmgen_diag_word),
		.frmgen_scrm_word(frmgen_scrm_word),
		.frmgen_skip_word(frmgen_skip_word),
		.frmgen_sync_word(frmgen_sync_word),
		.frmsync_enum_scrm(frmsync_enum_scrm),
		.frmsync_enum_sync(frmsync_enum_sync),
		.frmsync_knum_sync(frmsync_knum_sync),
		.frmsync_mfrm_length(fnl_frmsync_mfrm_length),
		.frmsync_mfrm_length_user(frmsync_mfrm_length_user),
		.rxfifo_empty(rxfifo_empty),
		.rxfifo_full(rxfifo_full),
		.skip_ctrl(skip_ctrl),
		.stretch_en(fnl_stretch_en),
		.test_bus_mode(fnl_test_bus_mode),
		.use_default_base_address(fnl_use_default_base_address),
		.user_base_address(user_base_address),
		.gb_rx_idwidth(fnl_gb_rx_idwidth),
		.gb_rx_odwidth(fnl_gb_rx_odwidth),
		.lpbk_mode(fnl_lpbk_mode),
		.rx_dfx_lpbk(fnl_rx_dfx_lpbk),
		.master_clk_sel(fnl_master_clk_sel),
		.blksync_bypass(fnl_blksync_bypass),
		.rxfifo_mode(fnl_rxfifo_mode),
		.rd_clk_sel(fnl_rd_clk_sel),
		.gbexp_clken(fnl_gbexp_clken),
		.dispchk_clken(fnl_dispchk_clken),
		.frmsync_bypass(fnl_frmsync_bypass),
		.dec64b66b_clken(fnl_dec64b66b_clken),
		.dec_64b66b_rxsm_bypass(fnl_dec_64b66b_rxsm_bypass),
		.wrfifo_clken(fnl_wrfifo_clken),
		.descrm_clken(fnl_descrm_clken),
		.frmsync_clken(fnl_frmsync_clken),
		.descrm_bypass(fnl_descrm_bypass),
		.blksync_clken(fnl_blksync_clken),
		.crcchk_bypass(fnl_crcchk_bypass),
		.rx_sm_bypass(fnl_rx_sm_bypass),
		.prbs_clken(fnl_prbs_clken),
		.ber_clken(fnl_ber_clken),
		.dispchk_bypass(fnl_dispchk_bypass),
		.rand_clken(fnl_rand_clken),
		.rdfifo_clken(fnl_rdfifo_clken),
		.crcchk_clken(fnl_crcchk_clken),
		.fast_path(fnl_fast_path),
		.data_bit_reverse(fnl_data_bit_reverse),
		.ctrl_bit_reverse(fnl_ctrl_bit_reverse),
		.rx_sh_location(fnl_rx_sh_location),
		.full_flag_type(fnl_full_flag_type),
		.empty_flag_type(fnl_empty_flag_type),
		.pfull_flag_type(fnl_pfull_flag_type),
		.pempty_flag_type(fnl_pempty_flag_type),
		.fifo_stop_rd(fnl_fifo_stop_rd),
		.fifo_stop_wr(fnl_fifo_stop_wr),
		.force_align(fnl_force_align),
		.control_del(fnl_control_del),
		.align_del(fnl_align_del),
		.rxfifo_pempty(rxfifo_pempty),
		.rxfifo_pfull(rxfifo_pfull),
		.rx_fifo_write_ctrl(fnl_rx_fifo_write_ctrl),
		.rx_true_b2b(fnl_rx_true_b2b),
		.blksync_knum_sh_cnt_postlock(fnl_blksync_knum_sh_cnt_postlock),
		.blksync_bitslip_type(fnl_blksync_bitslip_type),
		.blksync_bitslip_wait_type(fnl_blksync_bitslip_wait_type),
		.blksync_enum_invalid_sh_cnt(fnl_blksync_enum_invalid_sh_cnt),
		.blksync_pipeln(fnl_blksync_pipeln),
		.blksync_knum_sh_cnt_prelock(fnl_blksync_knum_sh_cnt_prelock),
		.rx_signal_ok_sel(fnl_rx_signal_ok_sel),
		.dis_signal_ok(fnl_dis_signal_ok),
		.dispchk_pipeln(fnl_dispchk_pipeln),
		.rx_sm_pipeln(fnl_rx_sm_pipeln),
		.rx_sm_hiber(fnl_rx_sm_hiber),
		.ber_xus_timer_window(fnl_ber_xus_timer_window),
		.frmsync_flag_type(fnl_frmsync_flag_type),
		.frmsync_pipeln(fnl_frmsync_pipeln),
		.crcflag_pipeln(fnl_crcflag_pipeln),
		.crcchk_pipeln(fnl_crcchk_pipeln),
		.crcchk_inv(fnl_crcchk_inv),
		.descrm_mode(fnl_descrm_mode),
		.rx_scrm_width(fnl_rx_scrm_width),
		.gb_sel_mode(fnl_gb_sel_mode),
		.test_mode(fnl_test_mode),
		.rx_prbs_mask(fnl_rx_prbs_mask),
		.stretch_type(fnl_stretch_type),
		.stretch_num_stages(fnl_stretch_num_stages),
		.iqtxrx_clkout_sel(fnl_iqtxrx_clkout_sel),
		.bitslip_mode(fnl_bitslip_mode),
		.rx_testbus_sel(fnl_rx_testbus_sel),
		.rx_polarity_inv(fnl_rx_polarity_inv)
	) wys (
		// ports
		.avmmaddress(avmmaddress),
		.avmmbyteen(avmmbyteen),
		.avmmclk(avmmclk),
		.avmmread(avmmread),
		.avmmreaddata(avmmreaddata),
		.avmmrstn(avmmrstn),
		.avmmwrite(avmmwrite),
		.avmmwritedata(avmmwritedata),
		.blockselect(blockselect),
		.dfxlpbkcontrolin(dfxlpbkcontrolin),
		.dfxlpbkdatain(dfxlpbkdatain),
		.dfxlpbkdatavalidin(dfxlpbkdatavalidin),
		.hardresetn(hardresetn),
		.lpbkdatain(lpbkdatain),
		.pmaclkdiv33txorrx(pmaclkdiv33txorrx),
		.refclkdig(refclkdig),
		.rxalignclr(rxalignclr),
		.rxalignen(rxalignen),
		.rxalignval(rxalignval),
		.rxbitslip(rxbitslip),
		.rxblocklock(rxblocklock),
		.rxclkiqout(rxclkiqout),
		.rxclkout(rxclkout),
		.rxclrbercount(rxclrbercount),
		.rxclrerrorblockcount(rxclrerrorblockcount),
		.rxcontrol(rxcontrol),
		.rxcrc32error(rxcrc32error),
		.rxdata(rxdata),
		.rxdatavalid(rxdatavalid),
		.rxdiagnosticerror(rxdiagnosticerror),
		.rxdiagnosticstatus(rxdiagnosticstatus),
		.rxdisparityclr(rxdisparityclr),
		.rxfifodel(rxfifodel),
		.rxfifoempty(rxfifoempty),
		.rxfifofull(rxfifofull),
		.rxfifoinsert(rxfifoinsert),
		.rxfifopartialempty(rxfifopartialempty),
		.rxfifopartialfull(rxfifopartialfull),
		.rxframelock(rxframelock),
		.rxhighber(rxhighber),
		.rxmetaframeerror(rxmetaframeerror),
		.rxpayloadinserted(rxpayloadinserted),
		.rxpldclk(rxpldclk),
		.rxpldrstn(rxpldrstn),
		.rxpmaclk(rxpmaclk),
		.rxpmadata(rxpmadata),
		.rxpmadatavalid(rxpmadatavalid),
		.rxprbsdone(rxprbsdone),
		.rxprbserr(rxprbserr),
		.rxprbserrorclr(rxprbserrorclr),
		.rxrden(rxrden),
		.rxrdnegsts(rxrdnegsts),
		.rxrdpossts(rxrdpossts),
		.rxrxframe(rxrxframe),
		.rxscramblererror(rxscramblererror),
		.rxskipinserted(rxskipinserted),
		.rxskipworderror(rxskipworderror),
		.rxsyncheadererror(rxsyncheadererror),
		.rxsyncworderror(rxsyncworderror),
		.rxtestdata(rxtestdata),
		.syncdatain(syncdatain),
		.txpmaclk(txpmaclk)
	);
endmodule
