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


// Verilog RBC parameter resolution wrapper for stratixv_hssi_10g_tx_pcs
//

`timescale 1 ns / 1 ps

module sv_hssi_10g_tx_pcs_rbc #(
	// unconstrained parameters
	parameter prot_mode = "<auto_single>",	// basic_mode, disable_mode, interlaken_mode, sfis_mode, teng_1588_mode, teng_baser_mode, teng_sdi_mode, test_prbs_mode, test_prp_mode, test_rpg_mode
	parameter sup_mode = "<auto_single>",	// engineering_mode, engr_mode, stretch_mode, user_mode

	// extra unconstrained parameters found in atom map
	parameter avmm_group_channel_index = 0,	// 0..2
	parameter channel_number = 0,	// 0..65
        parameter crcgen_init = "<auto_single>",	// crcgen_init_user_setting, crcgen_int
	parameter crcgen_init_user = 32'b11111111111111111111111111111111,
	parameter del_sel_frame_gen = "del_sel_frame_gen_del0",	// del_sel_frame_gen_del0
	parameter frmgen_diag_word = 64'h6400000000000000,
	parameter frmgen_mfrm_length_user = 5,
	parameter frmgen_scrm_word = 64'h2800000000000000,
	parameter frmgen_skip_word = 64'h1e1e1e1e1e1e1e1e,
	parameter frmgen_sync_word = 64'h78f678f678f678f6,
	parameter pseudo_seed_a = "pseudo_seed_a_user_setting",	// pseudo_seed_a_user_setting
	parameter pseudo_seed_a_user = 58'b1111111111111111111111111111111111111111111111111111111111,
	parameter pseudo_seed_b = "pseudo_seed_b_user_setting",	// pseudo_seed_b_user_setting
	parameter pseudo_seed_b_user = 58'b1111111111111111111111111111111111111111111111111111111111,
	parameter scrm_seed_user = 58'b1111111111111111111111111111111111111111111111111111111111,	// 58
	parameter skip_ctrl = "skip_ctrl_default",	// skip_ctrl_default
	parameter test_bus_mode = "tx",	// rx, tx
	parameter txfifo_empty = 0,
	parameter txfifo_full = 31,
	parameter use_default_base_address = "true",	// false, true
	parameter user_base_address = 0,	// 0..2047

	// constrained parameters
	parameter gb_tx_odwidth = "<auto_single>",	// gb_tx_idwidth, width_32, width_32_default, width_40, width_64
	parameter gb_tx_idwidth = "<auto_single>",	// width_32, width_40, width_50, width_64, width_66, width_67
	parameter ctrl_plane_bonding = "<auto_single>",	// ctrl_master, ctrl_slave_abv, ctrl_slave_blw, individual
	parameter data_agg_bonding = "<auto_single>",	// agg_individual, agg_master, agg_slave_abv, agg_slave_blw
	parameter master_clk_sel = "<auto_single>",	// master_refclk_dig, master_tx_pma_clk
	parameter txfifo_mode = "<auto_single>",	// basic_generic, clk_comp, generic, interlaken_generic, phase_comp, register_mode
	parameter wr_clk_sel = "<auto_single>",	// wr_refclk_dig, wr_tx_pld_clk, wr_tx_pma_clk
	parameter sqwgen_clken = "<auto_single>",	// sqwgen_clk_dis, sqwgen_clk_en
	parameter wrfifo_clken = "<auto_single>",	// wrfifo_clk_dis, wrfifo_clk_en
	parameter dispgen_clken = "<auto_single>",	// dispgen_clk_dis, dispgen_clk_en
	parameter scrm_clken = "<auto_single>",	// scrm_clk_dis, scrm_clk_en
	parameter enc_64b66b_txsm_bypass = "<auto_single>",	// enc_64b66b_txsm_bypass_dis, enc_64b66b_txsm_bypass_en
	parameter dispgen_bypass = "<auto_single>",	// dispgen_bypass_dis, dispgen_bypass_en
	parameter gbred_clken = "<auto_single>",	// gbred_clk_dis, gbred_clk_en
	parameter tx_sm_bypass = "<auto_single>",	// tx_sm_bypass_dis, tx_sm_bypass_en
	parameter enc64b66b_txsm_clken = "<auto_single>",	// enc64b66b_txsm_clk_dis, enc64b66b_txsm_clk_en
	parameter frmgen_bypass = "<auto_single>",	// frmgen_bypass_dis, frmgen_bypass_en
	parameter crcgen_clken = "<auto_single>",	// crcgen_clk_dis, crcgen_clk_en
	parameter scrm_bypass = "<auto_single>",	// scrm_bypass_dis, scrm_bypass_en
	parameter frmgen_clken = "<auto_single>",	// frmgen_clk_dis, frmgen_clk_en
	parameter prbs_clken = "<auto_single>",	// prbs_clk_dis, prbs_clk_en
	parameter crcgen_bypass = "<auto_single>",	// crcgen_bypass_dis, crcgen_bypass_en
	parameter rdfifo_clken = "<auto_single>",	// rdfifo_clk_dis, rdfifo_clk_en
	parameter fastpath = "<auto_single>",	// fastpath_dis, fastpath_en
	parameter bit_reverse = "<auto_single>",	// bit_reverse_dis, bit_reverse_en
	parameter data_bit_reverse = "<auto_single>",	// data_bit_reverse_dis, data_bit_reverse_en
	parameter ctrl_bit_reverse = "<auto_single>",	// ctrl_bit_reverse_dis, ctrl_bit_reverse_en
	parameter tx_sh_location = "<auto_single>",	// lsb, msb
	parameter empty_flag_type = "<auto_single>",	// empty_rd_side, empty_wr_side, ppempty_rd_side, ppempty_wr_side
	parameter pfull_flag_type = "<auto_single>",	// pfull_rd_side, pfull_wr_side
	parameter full_flag_type = "<auto_single>",	// full_rd_side, full_wr_side, ppfull_rd_side, ppfull_wr_side
	parameter pempty_flag_type = "<auto_single>",	// pempty_rd_side, pempty_wr_side
	parameter fifo_stop_rd = "<auto_single>",	// n_rd_empty, rd_empty
	parameter fifo_stop_wr = "<auto_single>",	// n_wr_full, wr_full
	parameter phcomp_rd_del = "<auto_single>",	// phcomp_rd_del1, phcomp_rd_del2, phcomp_rd_del3, phcomp_rd_del4, phcomp_rd_del5
	parameter txfifo_pempty = 7,	// pempty1, pempty10, pempty2, pempty3, pempty4, pempty5, pempty6, pempty7, pempty8, pempty9
	parameter txfifo_pfull = 23,	// pfull23, pfull24, pfull25, pfull26, pfull27, pfull28
	parameter tx_true_b2b = "<auto_single>",	// b2b, single
	parameter frmgen_pyld_ins = "<auto_single>",	// frmgen_pyld_ins_dis, frmgen_pyld_ins_en
	parameter frmgen_wordslip = "<auto_single>",	// frmgen_wordslip_dis, frmgen_wordslip_en
	parameter frmgen_burst = "<auto_single>",	// frmgen_burst_dis, frmgen_burst_en
	parameter frmgen_mfrm_length = "<auto_single>",	// frmgen_mfrm_length_max, frmgen_mfrm_length_min, frmgen_mfrm_length_user_setting
	parameter frmgen_pipeln = "<auto_single>",	// frmgen_pipeln_dis, frmgen_pipeln_en
	parameter crcgen_inv = "<auto_single>",	// crcgen_inv_dis, crcgen_inv_en
	parameter crcgen_err = "<auto_single>",	// crcgen_err_dis, crcgen_err_en
	parameter tx_sm_pipeln = "<auto_single>",	// tx_sm_pipeln_dis, tx_sm_pipeln_en
	parameter sh_err = "<auto_single>",	// sh_err_dis, sh_err_en
	parameter dispgen_err = "<auto_single>",	// dispgen_err_dis, dispgen_err_en
	parameter dispgen_pipeln = "<auto_single>",	// dispgen_pipeln_dis, dispgen_pipeln_en
	parameter scrm_mode = "<auto_single>",	// async, sync
	parameter scrm_seed = "<auto_single>",	// scram_seed_max, scram_seed_min, scram_seed_user_setting
	parameter tx_scrm_err = "<auto_single>",	// scrm_err_dis, scrm_err_en
	parameter tx_scrm_width = "<auto_single>",	// bit64, bit66, bit67
	parameter gb_sel_mode = "<auto_single>",	// external, internal
	parameter test_mode = "<auto_single>",	// prbs_23, prbs_31, prbs_7, prbs_9, pseudo_random, sq_wave, test_off
	parameter pseudo_random = "<auto_single>",	// all_0, two_lf
	parameter sq_wave = "<auto_single>",	// sq_wave_1, sq_wave_10, sq_wave_4, sq_wave_5, sq_wave_6, sq_wave_8
	parameter bitslip_en = "<auto_single>",	// bitslip_dis, bitslip_en
	parameter distdwn_bypass_pipeln = "<auto_single>",	// distdwn_bypass_pipeln_dis, distdwn_bypass_pipeln_en
	parameter distup_bypass_pipeln = "<auto_single>",	// distup_bypass_pipeln_dis, distup_bypass_pipeln_en
	parameter distdwn_master = "<auto_single>",	// distdwn_master_dis, distdwn_master_en
	parameter comp_cnt = "<auto_single>",	// comp_cnt_00, comp_cnt_02, comp_cnt_04, comp_cnt_06, comp_cnt_08, comp_cnt_0a, comp_cnt_0c, comp_cnt_0e, comp_cnt_10, comp_cnt_12, comp_cnt_14, comp_cnt_16, comp_cnt_18, comp_cnt_1a, comp_cnt_1c, comp_cnt_1e, comp_cnt_20, comp_cnt_22, comp_cnt_24, comp_cnt_26
	parameter indv = "<auto_single>",	// indv_dis, indv_en
	parameter compin_sel = "<auto_single>",	// compin_default, compin_master, compin_slave_bot, compin_slave_top
	parameter distup_master = "<auto_single>",	// distup_master_dis, distup_master_en
	parameter distdwn_master_agg = "<auto_single>",	// distdwn_master_agg_dis, distdwn_master_agg_en
	parameter distup_master_agg = "<auto_single>",	// distup_master_agg_dis, distup_master_agg_en
	parameter distup_bypass_pipeln_agg = "<auto_single>",	// distup_bypass_pipeln_agg_dis, distup_bypass_pipeln_agg_en
	parameter data_agg_comp = "<auto_single>",	// data_agg_del0, data_agg_del1, data_agg_del2, data_agg_del3, data_agg_del4, data_agg_del5, data_agg_del6, data_agg_del7, data_agg_del8
	parameter compin_sel_agg = "<auto_single>",	// compin_agg_default, compin_agg_master, compin_agg_slave_bot, compin_agg_slave_top
	parameter comp_del_sel_agg = "<auto_single>",	// data_agg_del0, data_agg_del1, data_agg_del2, data_agg_del3, data_agg_del4, data_agg_del5, data_agg_del6, data_agg_del7, data_agg_del8
	parameter distdwn_bypass_pipeln_agg = "<auto_single>",	// distdwn_bypass_pipeln_agg_dis, distdwn_bypass_pipeln_agg_en
	parameter stretch_type = "<auto_single>",	// stretch_auto, stretch_custom
	parameter stretch_en = "<auto_single>",	// stretch_dis, stretch_en
	parameter stretch_num_stages = "<auto_single>",	// one_stage, three_stage, two_stage, zero_stage
	parameter iqtxrx_clkout_sel = "<auto_single>",	// iq_tx_pma_clk, iq_tx_pma_clk_div33
	parameter tx_testbus_sel = "<auto_single>",	// blank_testbus, crc32_gen_testbus1, crc32_gen_testbus2, disp_gen_testbus1, disp_gen_testbus2, enc64b66b_testbus, frame_gen_testbus1, frame_gen_testbus2, gearbox_red_testbus, gearbox_red_testbus1, gearbox_red_testbus2, prbs_gen_xg_testbus, scramble_testbus, scramble_testbus1, scramble_testbus2, tx_cp_bond_testbus, tx_da_bond_testbus, tx_fifo_testbus1, tx_fifo_testbus2, txsm_testbus
	parameter tx_polarity_inv = "<auto_single>",	// invert_disable, invert_enable
	parameter pmagate_en = "<auto_single>"	// pmagate_dis, pmagate_en
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
	output wire    [8:0]	dfxlpbkcontrolout,
	output wire   [63:0]	dfxlpbkdataout,
	output wire         	dfxlpbkdatavalidout,
	input  wire         	distdwnindv,
	input  wire         	distdwninintlknrden,
	input  wire         	distdwninrden,
	input  wire         	distdwninrdpfull,
	input  wire         	distdwninwren,
	output wire         	distdwnoutdv,
	output wire         	distdwnoutintlknrden,
	output wire         	distdwnoutrden,
	output wire         	distdwnoutrdpfull,
	output wire         	distdwnoutwren,
	input  wire         	distupindv,
	input  wire         	distupinintlknrden,
	input  wire         	distupinrden,
	input  wire         	distupinrdpfull,
	input  wire         	distupinwren,
	output wire         	distupoutdv,
	output wire         	distupoutintlknrden,
	output wire         	distupoutrden,
	output wire         	distupoutrdpfull,
	output wire         	distupoutwren,
	input  wire         	hardresetn,
	output wire   [79:0]	lpbkdataout,
	input  wire         	pmaclkdiv33lc,
	input  wire         	refclkdig,
	output wire         	syncdatain,
	input  wire    [6:0]	txbitslip,
	input  wire         	txbursten,
	output wire         	txburstenexe,
	output wire         	txclkiqout,
	output wire         	txclkout,
	input  wire    [8:0]	txcontrol,
	input  wire   [63:0]	txdata,
	input  wire         	txdatavalid,
	input  wire    [1:0]	txdiagnosticstatus,
	input  wire         	txdisparityclr,
	output wire         	txfifodel,
	output wire         	txfifoempty,
	output wire         	txfifofull,
	output wire         	txfifoinsert,
	output wire         	txfifopartialempty,
	output wire         	txfifopartialfull,
	output wire         	txframe,
	input  wire         	txpldclk,
	input  wire         	txpldrstn,
	input  wire         	txpmaclk,
	output wire   [79:0]	txpmadata,
	input  wire         	txwordslip,
	output wire         	txwordslipexe
);
	import altera_xcvr_functions::*;


`ifdef ALTERA_RESERVED_QIS_ES
   
   
   //========================ES RULES START==============================================================================
   localparam silicon_rev_local = "es";


   
	// prot_mode external parameter (no RBC) >> ES <<
	localparam rbc_all_prot_mode = "(basic_mode,disable_mode,interlaken_mode,sfis_mode,teng_1588_mode,teng_baser_mode,teng_sdi_mode,test_prbs_mode,test_prp_mode,test_rpg_mode)";
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

	// gb_tx_odwidth, RBC-validated >> ES <<
	localparam rbc_all_gb_tx_odwidth = ((fnl_prot_mode == "teng_baser_mode") || fnl_prot_mode == "teng_1588_mode" || (fnl_prot_mode == "test_prp_mode")) ? ("(width_32,width_40)")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("(width_32,width_40)")
			 : ((fnl_prot_mode == "sfis_mode")) ? ("(width_32,width_40)")
				 : ((fnl_prot_mode == "teng_sdi_mode")) ? ("width_40")
					 : ((fnl_prot_mode == "basic_mode")) ?
						(
							(fnl_sup_mode == "engineering_mode") ? ("(width_32,width_40,width_64)") : "(width_32,width_40,width_64)"
						)
						 : ((fnl_prot_mode == "test_prbs_mode") ||
            (fnl_prot_mode == "test_rpg_mode")) ? ("(width_32,width_40,width_64)") : "width_32";
	localparam rbc_any_gb_tx_odwidth = ((fnl_prot_mode == "teng_baser_mode") || fnl_prot_mode == "teng_1588_mode" || (fnl_prot_mode == "test_prp_mode")) ? ("width_32")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("width_32")
			 : ((fnl_prot_mode == "sfis_mode")) ? ("width_32")
				 : ((fnl_prot_mode == "teng_sdi_mode")) ? ("width_40")
					 : ((fnl_prot_mode == "basic_mode")) ?
						(
							(fnl_sup_mode == "engineering_mode") ? ("width_32") : "width_32"
						)
						 : ((fnl_prot_mode == "test_prbs_mode") ||
            (fnl_prot_mode == "test_rpg_mode")) ? ("width_32") : "width_32";
	localparam fnl_gb_tx_odwidth = (gb_tx_odwidth == "<auto_any>" || gb_tx_odwidth == "<auto_single>") ? rbc_any_gb_tx_odwidth : gb_tx_odwidth;

	// gb_tx_idwidth, RBC-validated >> ES <<
	localparam rbc_all_gb_tx_idwidth = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode")) ? ("width_66")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("width_67")
			 : ((fnl_prot_mode == "sfis_mode")) ?
				(
					(fnl_gb_tx_odwidth == "width_32") ? ("(width_32,width_64)") : "(width_40,width_64)"
				)
				 : ((fnl_prot_mode == "teng_sdi_mode")) ?
					(
						((fnl_sup_mode == "engineering_mode")) ? ("(width_40,width_50)") : "width_50"
					)
					 : ((fnl_prot_mode == "basic_mode")) ?
						(
							(fnl_gb_tx_odwidth == "width_32") ? ("(width_32,width_64,width_66,width_67)")
							 : (fnl_gb_tx_odwidth == "width_40") ? ("(width_40,width_64,width_66,width_67)")
								 : (fnl_gb_tx_odwidth == "width_64") ? ("width_64") : "width_64"
						)
						 : (fnl_gb_tx_odwidth == "width_32") ? ("width_32")
							 : (fnl_gb_tx_odwidth == "width_40") ? ("width_40") : "width_64";
	localparam rbc_any_gb_tx_idwidth = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode")) ? ("width_66")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("width_67")
			 : ((fnl_prot_mode == "sfis_mode")) ?
				(
					(fnl_gb_tx_odwidth == "width_32") ? ("width_32") : "width_40"
				)
				 : ((fnl_prot_mode == "teng_sdi_mode")) ?
					(
						((fnl_sup_mode == "engineering_mode")) ? ("width_40") : "width_50"
					)
					 : ((fnl_prot_mode == "basic_mode")) ?
						(
							(fnl_gb_tx_odwidth == "width_32") ? ("width_32")
							 : (fnl_gb_tx_odwidth == "width_40") ? ("width_40")
								 : (fnl_gb_tx_odwidth == "width_64") ? ("width_64") : "width_64"
						)
						 : (fnl_gb_tx_odwidth == "width_32") ? ("width_32")
							 : (fnl_gb_tx_odwidth == "width_40") ? ("width_40") : "width_64";
	localparam fnl_gb_tx_idwidth = (gb_tx_idwidth == "<auto_any>" || gb_tx_idwidth == "<auto_single>") ? rbc_any_gb_tx_idwidth : gb_tx_idwidth;

	// ctrl_plane_bonding, RBC-validated >> ES <<
	localparam rbc_all_ctrl_plane_bonding = (fnl_prot_mode != "sfis_mode" && fnl_prot_mode != "basic_mode" && fnl_prot_mode != "interlaken_mode") ? ("individual")
		 : "(individual,ctrl_master,ctrl_slave_blw,ctrl_slave_abv)";
	localparam rbc_any_ctrl_plane_bonding = (fnl_prot_mode != "sfis_mode" && fnl_prot_mode != "basic_mode" && fnl_prot_mode != "interlaken_mode") ? ("individual")
		 : "individual";
	localparam fnl_ctrl_plane_bonding = (ctrl_plane_bonding == "<auto_any>" || ctrl_plane_bonding == "<auto_single>") ? rbc_any_ctrl_plane_bonding : ctrl_plane_bonding;

	// master_clk_sel, RBC-validated >> ES <<
	localparam rbc_all_master_clk_sel = (fnl_sup_mode == "engineering_mode") ? ("(master_tx_pma_clk,master_refclk_dig)") : "master_tx_pma_clk";
	localparam rbc_any_master_clk_sel = (fnl_sup_mode == "engineering_mode") ? ("master_tx_pma_clk") : "master_tx_pma_clk";
	localparam fnl_master_clk_sel = (master_clk_sel == "<auto_any>" || master_clk_sel == "<auto_single>") ? rbc_any_master_clk_sel : master_clk_sel;

	// txfifo_mode, RBC-validated >> ES <<
	localparam rbc_all_txfifo_mode = (fnl_prot_mode == "interlaken_mode") ? ("interlaken_generic")
		 : (fnl_prot_mode == "teng_baser_mode") ?
			(
				(fnl_sup_mode == "engineering_mode") ? ("(clk_comp,phase_comp)") : "phase_comp"
			)
			 : (fnl_prot_mode == "teng_sdi_mode") ?
				(
					(fnl_sup_mode == "engineering_mode") ? ("(register_mode,phase_comp)") : "phase_comp"
				)
				 : ((fnl_prot_mode == "basic_mode")) ?
					(
						(fnl_sup_mode == "engineering_mode" && fnl_ctrl_plane_bonding == "individual") ? ("(basic_generic,register_mode,phase_comp)") : "(register_mode,phase_comp)"
					)
					 : ((fnl_prot_mode == "teng_1588_mode")) ? ("register_mode") : "phase_comp";

	localparam rbc_any_txfifo_mode = (fnl_prot_mode == "interlaken_mode") ? ("interlaken_generic")
		 : (fnl_prot_mode == "teng_baser_mode") ?
			(
				(fnl_sup_mode == "engineering_mode") ? ("phase_comp") : "phase_comp"
			)
			 : (fnl_prot_mode == "teng_sdi_mode") ?
				(
					(fnl_sup_mode == "engineering_mode") ? ("phase_comp") : "phase_comp"
				)
				 : ((fnl_prot_mode == "basic_mode")) ?
					(
						(fnl_sup_mode == "engineering_mode" && fnl_ctrl_plane_bonding == "individual") ? ("phase_comp") : "phase_comp"
					)
					 : ((fnl_prot_mode == "teng_1588_mode")) ? ("register_mode") : "phase_comp";
	localparam fnl_txfifo_mode = (txfifo_mode == "<auto_any>" || txfifo_mode == "<auto_single>") ? rbc_any_txfifo_mode : txfifo_mode;

	// wr_clk_sel, RBC-validated >> ES <<
	localparam rbc_all_wr_clk_sel = (fnl_txfifo_mode == "register_mode") ?
		(
			(fnl_master_clk_sel == "master_refclk_dig") ? ("wr_refclk_dig") : "wr_tx_pma_clk"
		) : "wr_tx_pld_clk";
	localparam rbc_any_wr_clk_sel = (fnl_txfifo_mode == "register_mode") ?
		(
			(fnl_master_clk_sel == "master_refclk_dig") ? ("wr_refclk_dig") : "wr_tx_pma_clk"
		) : "wr_tx_pld_clk";
	localparam fnl_wr_clk_sel = (wr_clk_sel == "<auto_any>" || wr_clk_sel == "<auto_single>") ? rbc_any_wr_clk_sel : wr_clk_sel;

	// sqwgen_clken, RBC-validated >> ES <<
	localparam rbc_all_sqwgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("sqwgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("sqwgen_clk_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("sqwgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("sqwgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("sqwgen_clk_en") : "sqwgen_clk_dis";
	localparam rbc_any_sqwgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("sqwgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("sqwgen_clk_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("sqwgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("sqwgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("sqwgen_clk_en") : "sqwgen_clk_dis";
	localparam fnl_sqwgen_clken = (sqwgen_clken == "<auto_any>" || sqwgen_clken == "<auto_single>") ? rbc_any_sqwgen_clken : sqwgen_clken;

	// wrfifo_clken, RBC-validated >> ES <<
	localparam rbc_all_wrfifo_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("wrfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("wrfifo_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("wrfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("wrfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("wrfifo_clk_en") : "wrfifo_clk_dis";
	localparam rbc_any_wrfifo_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("wrfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("wrfifo_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("wrfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("wrfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("wrfifo_clk_en") : "wrfifo_clk_dis";
	localparam fnl_wrfifo_clken = (wrfifo_clken == "<auto_any>" || wrfifo_clken == "<auto_single>") ? rbc_any_wrfifo_clken : wrfifo_clken;

	// dispgen_clken, RBC-validated >> ES <<
	localparam rbc_all_dispgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("dispgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispgen_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("dispgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("dispgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("dispgen_clk_en") : "dispgen_clk_dis";
	localparam rbc_any_dispgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("dispgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispgen_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("dispgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("dispgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("dispgen_clk_en") : "dispgen_clk_dis";
	localparam fnl_dispgen_clken = (dispgen_clken == "<auto_any>" || dispgen_clken == "<auto_single>") ? rbc_any_dispgen_clken : dispgen_clken;

	// scrm_clken, RBC-validated >> ES <<
	localparam rbc_all_scrm_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("scrm_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("scrm_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("scrm_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_sup_mode == "engineering_mode" && (fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("scrm_clk_en") : "scrm_clk_dis"
					)
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("scrm_clk_en") : "scrm_clk_dis";
	localparam rbc_any_scrm_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("scrm_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("scrm_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("scrm_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_sup_mode == "engineering_mode" && (fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("scrm_clk_en") : "scrm_clk_dis"
					)
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("scrm_clk_en") : "scrm_clk_dis";
	localparam fnl_scrm_clken = (scrm_clken == "<auto_any>" || scrm_clken == "<auto_single>") ? rbc_any_scrm_clken : scrm_clken;

	// enc_64b66b_txsm_bypass, RBC-validated >> ES <<
	localparam rbc_all_enc_64b66b_txsm_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("enc_64b66b_txsm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("enc_64b66b_txsm_bypass_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("enc_64b66b_txsm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("enc_64b66b_txsm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("enc_64b66b_txsm_bypass_en") : "enc_64b66b_txsm_bypass_en";
	localparam rbc_any_enc_64b66b_txsm_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("enc_64b66b_txsm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("enc_64b66b_txsm_bypass_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("enc_64b66b_txsm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("enc_64b66b_txsm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("enc_64b66b_txsm_bypass_en") : "enc_64b66b_txsm_bypass_en";
	localparam fnl_enc_64b66b_txsm_bypass = (enc_64b66b_txsm_bypass == "<auto_any>" || enc_64b66b_txsm_bypass == "<auto_single>") ? rbc_any_enc_64b66b_txsm_bypass : enc_64b66b_txsm_bypass;

	// dispgen_bypass, RBC-validated >> ES <<
	localparam rbc_all_dispgen_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("dispgen_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispgen_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("dispgen_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("dispgen_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("dispgen_bypass_en") : "dispgen_bypass_en";
	localparam rbc_any_dispgen_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("dispgen_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispgen_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("dispgen_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("dispgen_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("dispgen_bypass_en") : "dispgen_bypass_en";
	localparam fnl_dispgen_bypass = (dispgen_bypass == "<auto_any>" || dispgen_bypass == "<auto_single>") ? rbc_any_dispgen_bypass : dispgen_bypass;

	// gbred_clken, RBC-validated >> ES <<
	localparam rbc_all_gbred_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("gbred_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("gbred_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("gbred_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("gbred_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("gbred_clk_en") : "gbred_clk_dis";
	localparam rbc_any_gbred_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("gbred_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("gbred_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("gbred_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("gbred_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("gbred_clk_en") : "gbred_clk_dis";
	localparam fnl_gbred_clken = (gbred_clken == "<auto_any>" || gbred_clken == "<auto_single>") ? rbc_any_gbred_clken : gbred_clken;

	// tx_sm_bypass, RBC-validated >> ES <<
	localparam rbc_all_tx_sm_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("tx_sm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("tx_sm_bypass_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("tx_sm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("tx_sm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("tx_sm_bypass_en") : "tx_sm_bypass_en";
	localparam rbc_any_tx_sm_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("tx_sm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("tx_sm_bypass_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("tx_sm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("tx_sm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("tx_sm_bypass_en") : "tx_sm_bypass_en";
	localparam fnl_tx_sm_bypass = (tx_sm_bypass == "<auto_any>" || tx_sm_bypass == "<auto_single>") ? rbc_any_tx_sm_bypass : tx_sm_bypass;

	// enc64b66b_txsm_clken, RBC-validated >> ES <<
	localparam rbc_all_enc64b66b_txsm_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("enc64b66b_txsm_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("enc64b66b_txsm_clk_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("enc64b66b_txsm_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("enc64b66b_txsm_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("enc64b66b_txsm_clk_en") : "enc64b66b_txsm_clk_dis";
	localparam rbc_any_enc64b66b_txsm_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("enc64b66b_txsm_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("enc64b66b_txsm_clk_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("enc64b66b_txsm_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("enc64b66b_txsm_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("enc64b66b_txsm_clk_en") : "enc64b66b_txsm_clk_dis";
	localparam fnl_enc64b66b_txsm_clken = (enc64b66b_txsm_clken == "<auto_any>" || enc64b66b_txsm_clken == "<auto_single>") ? rbc_any_enc64b66b_txsm_clken : enc64b66b_txsm_clken;

	// frmgen_bypass, RBC-validated >> ES <<
	localparam rbc_all_frmgen_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("frmgen_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmgen_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("frmgen_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("frmgen_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("frmgen_bypass_en") : "frmgen_bypass_en";
	localparam rbc_any_frmgen_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("frmgen_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmgen_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("frmgen_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("frmgen_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("frmgen_bypass_en") : "frmgen_bypass_en";
	localparam fnl_frmgen_bypass = (frmgen_bypass == "<auto_any>" || frmgen_bypass == "<auto_single>") ? rbc_any_frmgen_bypass : frmgen_bypass;

	// crcgen_clken, RBC-validated >> ES <<
	localparam rbc_all_crcgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("crcgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcgen_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("crcgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("crcgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("crcgen_clk_en") : "crcgen_clk_dis";
	localparam rbc_any_crcgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("crcgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcgen_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("crcgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("crcgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("crcgen_clk_en") : "crcgen_clk_dis";
	localparam fnl_crcgen_clken = (crcgen_clken == "<auto_any>" || crcgen_clken == "<auto_single>") ? rbc_any_crcgen_clken : crcgen_clken;

	// scrm_bypass, RBC-validated >> ES <<
	localparam rbc_all_scrm_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("scrm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("scrm_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("scrm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_sup_mode == "engineering_mode" && (fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("(scrm_bypass_dis,scrm_bypass_en)") : "scrm_bypass_en"
					)
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("scrm_bypass_en") : "scrm_bypass_en";
	localparam rbc_any_scrm_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("scrm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("scrm_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("scrm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_sup_mode == "engineering_mode" && (fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("scrm_bypass_dis") : "scrm_bypass_en"
					)
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("scrm_bypass_en") : "scrm_bypass_en";
	localparam fnl_scrm_bypass = (scrm_bypass == "<auto_any>" || scrm_bypass == "<auto_single>") ? rbc_any_scrm_bypass : scrm_bypass;

	// frmgen_clken, RBC-validated >> ES <<
	localparam rbc_all_frmgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("frmgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmgen_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("frmgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("frmgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("frmgen_clk_en") : "frmgen_clk_dis";
	localparam rbc_any_frmgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("frmgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmgen_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("frmgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("frmgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("frmgen_clk_en") : "frmgen_clk_dis";
	localparam fnl_frmgen_clken = (frmgen_clken == "<auto_any>" || frmgen_clken == "<auto_single>") ? rbc_any_frmgen_clken : frmgen_clken;

	// prbs_clken, RBC-validated >> ES <<
	localparam rbc_all_prbs_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("prbs_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("prbs_clk_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("prbs_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("prbs_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("prbs_clk_en") : "prbs_clk_dis";
	localparam rbc_any_prbs_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("prbs_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("prbs_clk_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("prbs_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("prbs_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("prbs_clk_en") : "prbs_clk_dis";
	localparam fnl_prbs_clken = (prbs_clken == "<auto_any>" || prbs_clken == "<auto_single>") ? rbc_any_prbs_clken : prbs_clken;

	// crcgen_bypass, RBC-validated >> ES <<
	localparam rbc_all_crcgen_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("crcgen_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcgen_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("crcgen_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("crcgen_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("crcgen_bypass_en") : "crcgen_bypass_en";
	localparam rbc_any_crcgen_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("crcgen_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcgen_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("crcgen_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("crcgen_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("crcgen_bypass_en") : "crcgen_bypass_en";
	localparam fnl_crcgen_bypass = (crcgen_bypass == "<auto_any>" || crcgen_bypass == "<auto_single>") ? rbc_any_crcgen_bypass : crcgen_bypass;

	// rdfifo_clken, RBC-validated >> ES <<
	localparam rbc_all_rdfifo_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("rdfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rdfifo_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("rdfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("rdfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("rdfifo_clk_en") : "rdfifo_clk_dis";
	localparam rbc_any_rdfifo_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("rdfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rdfifo_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("rdfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("rdfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("rdfifo_clk_en") : "rdfifo_clk_dis";
	localparam fnl_rdfifo_clken = (rdfifo_clken == "<auto_any>" || rdfifo_clken == "<auto_single>") ? rbc_any_rdfifo_clken : rdfifo_clken;

	// fastpath, RBC-validated >> ES <<
	localparam rbc_all_fastpath = (fnl_frmgen_bypass == "frmgen_bypass_en" && fnl_crcgen_bypass == "crcgen_bypass_en" && fnl_enc_64b66b_txsm_bypass == "enc_64b66b_txsm_bypass_en" && fnl_scrm_bypass == "scrm_bypass_en" && fnl_dispgen_bypass == "dispgen_bypass_en") ? ("fastpath_en") : "fastpath_dis";
	localparam rbc_any_fastpath = (fnl_frmgen_bypass == "frmgen_bypass_en" && fnl_crcgen_bypass == "crcgen_bypass_en" && fnl_enc_64b66b_txsm_bypass == "enc_64b66b_txsm_bypass_en" && fnl_scrm_bypass == "scrm_bypass_en" && fnl_dispgen_bypass == "dispgen_bypass_en") ? ("fastpath_en") : "fastpath_dis";
	localparam fnl_fastpath = (fastpath == "<auto_any>" || fastpath == "<auto_single>") ? rbc_any_fastpath : fastpath;

	// bit_reverse, RBC-validated >> ES <<
	localparam rbc_all_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode")) ? ("bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("bit_reverse_en")
			 : (fnl_prot_mode == "basic_mode" && (fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("(bit_reverse_en,bit_reverse_dis)") : "bit_reverse_dis";
	localparam rbc_any_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode")) ? ("bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("bit_reverse_en")
			 : (fnl_prot_mode == "basic_mode" && (fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("bit_reverse_dis") : "bit_reverse_dis";
	localparam fnl_bit_reverse = (bit_reverse == "<auto_any>" || bit_reverse == "<auto_single>") ? rbc_any_bit_reverse : bit_reverse;

	// tx_sh_location, RBC-validated >> ES <<
	localparam rbc_all_tx_sh_location = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode")) ? ("lsb")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("msb")
			 : (fnl_prot_mode == "basic_mode" && (fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("(msb,lsb)") : "msb";
	localparam rbc_any_tx_sh_location = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode")) ? ("lsb")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("msb")
			 : (fnl_prot_mode == "basic_mode" && (fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("lsb") : "msb";
	localparam fnl_tx_sh_location = (tx_sh_location == "<auto_any>" || tx_sh_location == "<auto_single>") ? rbc_any_tx_sh_location : tx_sh_location;

	// phcomp_rd_del, RBC-validated >> ES <<
	localparam rbc_all_phcomp_rd_del = (fnl_txfifo_mode == "phase_comp") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(phcomp_rd_del5,phcomp_rd_del4,phcomp_rd_del3,phcomp_rd_del2,phcomp_rd_del1)")
			 : (fnl_gb_tx_odwidth == fnl_gb_tx_idwidth) ? ("phcomp_rd_del2") : "phcomp_rd_del3"
		) : "phcomp_rd_del3";
	localparam rbc_any_phcomp_rd_del = (fnl_txfifo_mode == "phase_comp") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("phcomp_rd_del1")
			 : (fnl_gb_tx_odwidth == fnl_gb_tx_idwidth) ? ("phcomp_rd_del2") : "phcomp_rd_del3"
		) : "phcomp_rd_del3";
	localparam fnl_phcomp_rd_del = (phcomp_rd_del == "<auto_any>" || phcomp_rd_del == "<auto_single>") ? rbc_any_phcomp_rd_del : phcomp_rd_del;

	// tx_true_b2b, RBC-validated >> ES <<
	localparam rbc_all_tx_true_b2b = (fnl_txfifo_mode == "clk_comp") ? ("(b2b,single)") : "b2b";
	localparam rbc_any_tx_true_b2b = (fnl_txfifo_mode == "clk_comp") ? ("b2b") : "b2b";
	localparam fnl_tx_true_b2b = (tx_true_b2b == "<auto_any>" || tx_true_b2b == "<auto_single>") ? rbc_any_tx_true_b2b : tx_true_b2b;

	// frmgen_pyld_ins, RBC-validated >> ES <<
	localparam rbc_all_frmgen_pyld_ins = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(frmgen_pyld_ins_en,frmgen_pyld_ins_dis)") : "frmgen_pyld_ins_dis"
		) : "frmgen_pyld_ins_dis";
	localparam rbc_any_frmgen_pyld_ins = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("frmgen_pyld_ins_dis") : "frmgen_pyld_ins_dis"
		) : "frmgen_pyld_ins_dis";
	localparam fnl_frmgen_pyld_ins = (frmgen_pyld_ins == "<auto_any>" || frmgen_pyld_ins == "<auto_single>") ? rbc_any_frmgen_pyld_ins : frmgen_pyld_ins;

	// frmgen_wordslip, RBC-validated >> ES <<
	localparam rbc_all_frmgen_wordslip = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(frmgen_wordslip_en,frmgen_wordslip_dis)") : "frmgen_wordslip_dis"
		) : "frmgen_wordslip_dis";
	localparam rbc_any_frmgen_wordslip = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("frmgen_wordslip_dis") : "frmgen_wordslip_dis"
		) : "frmgen_wordslip_dis";
	localparam fnl_frmgen_wordslip = (frmgen_wordslip == "<auto_any>" || frmgen_wordslip == "<auto_single>") ? rbc_any_frmgen_wordslip : frmgen_wordslip;

	// frmgen_burst, RBC-validated >> ES <<
	localparam rbc_all_frmgen_burst = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(frmgen_burst_en,frmgen_burst_dis)") : "frmgen_burst_dis"
		) : "frmgen_burst_dis";
	localparam rbc_any_frmgen_burst = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("frmgen_burst_dis") : "frmgen_burst_dis"
		) : "frmgen_burst_dis";
	localparam fnl_frmgen_burst = (frmgen_burst == "<auto_any>" || frmgen_burst == "<auto_single>") ? rbc_any_frmgen_burst : frmgen_burst;

	// frmgen_mfrm_length, RBC-validated >> ES <<
	localparam rbc_all_frmgen_mfrm_length = (fnl_prot_mode == "interlaken_mode") ? ("(frmgen_mfrm_length_min,frmgen_mfrm_length_max,frmgen_mfrm_length_user_setting)") : "frmgen_mfrm_length_max";
	localparam rbc_any_frmgen_mfrm_length = (fnl_prot_mode == "interlaken_mode") ? ("frmgen_mfrm_length_min") : "frmgen_mfrm_length_max";
	localparam fnl_frmgen_mfrm_length = (frmgen_mfrm_length == "<auto_any>" || frmgen_mfrm_length == "<auto_single>") ? rbc_any_frmgen_mfrm_length : frmgen_mfrm_length;

	// frmgen_pipeln, RBC-validated >> ES <<
	localparam rbc_all_frmgen_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(frmgen_pipeln_en,frmgen_pipeln_dis)") : "frmgen_pipeln_en"
		) : "frmgen_pipeln_en";
	localparam rbc_any_frmgen_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("frmgen_pipeln_dis") : "frmgen_pipeln_en"
		) : "frmgen_pipeln_en";
	localparam fnl_frmgen_pipeln = (frmgen_pipeln == "<auto_any>" || frmgen_pipeln == "<auto_single>") ? rbc_any_frmgen_pipeln : frmgen_pipeln;

	// crcgen_inv, RBC-validated >> ES <<
	localparam rbc_all_crcgen_inv = (fnl_prot_mode == "interlaken_mode") ? ("crcgen_inv_en") : "crcgen_inv_en";
	localparam rbc_any_crcgen_inv = (fnl_prot_mode == "interlaken_mode") ? ("crcgen_inv_en") : "crcgen_inv_en";
	localparam fnl_crcgen_inv = (crcgen_inv == "<auto_any>" || crcgen_inv == "<auto_single>") ? rbc_any_crcgen_inv : crcgen_inv;

	// crcgen_err, RBC-validated >> ES <<
	localparam rbc_all_crcgen_err = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(crcgen_err_dis,crcgen_err_en)") : "crcgen_err_dis"
		) : "crcgen_err_dis";
	localparam rbc_any_crcgen_err = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("crcgen_err_dis") : "crcgen_err_dis"
		) : "crcgen_err_dis";
	localparam fnl_crcgen_err = (crcgen_err == "<auto_any>" || crcgen_err == "<auto_single>") ? rbc_any_crcgen_err : crcgen_err;

	// tx_sm_pipeln, RBC-validated >> ES <<
	localparam rbc_all_tx_sm_pipeln = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(tx_sm_pipeln_en,tx_sm_pipeln_dis)") : "tx_sm_pipeln_en"
		) : "tx_sm_pipeln_en";
	localparam rbc_any_tx_sm_pipeln = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("tx_sm_pipeln_dis") : "tx_sm_pipeln_en"
		) : "tx_sm_pipeln_en";
	localparam fnl_tx_sm_pipeln = (tx_sm_pipeln == "<auto_any>" || tx_sm_pipeln == "<auto_single>") ? rbc_any_tx_sm_pipeln : tx_sm_pipeln;

	// sh_err, RBC-validated >> ES <<
	localparam rbc_all_sh_err = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("(sh_err_en,sh_err_dis)") : "sh_err_dis";
	localparam rbc_any_sh_err = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("sh_err_dis") : "sh_err_dis";
	localparam fnl_sh_err = (sh_err == "<auto_any>" || sh_err == "<auto_single>") ? rbc_any_sh_err : sh_err;

	// dispgen_err, RBC-validated >> ES <<
	localparam rbc_all_dispgen_err = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(dispgen_err_dis,dispgen_err_en)") : "dispgen_err_dis"
		) : "dispgen_err_dis";
	localparam rbc_any_dispgen_err = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("dispgen_err_dis") : "dispgen_err_dis"
		) : "dispgen_err_dis";
	localparam fnl_dispgen_err = (dispgen_err == "<auto_any>" || dispgen_err == "<auto_single>") ? rbc_any_dispgen_err : dispgen_err;

	// dispgen_pipeln, RBC-validated >> ES <<
	localparam rbc_all_dispgen_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(dispgen_pipeln_en,dispgen_pipeln_dis)") : "dispgen_pipeln_dis"
		) : "dispgen_pipeln_dis";
	localparam rbc_any_dispgen_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("dispgen_pipeln_dis") : "dispgen_pipeln_dis"
		) : "dispgen_pipeln_dis";
	localparam fnl_dispgen_pipeln = (dispgen_pipeln == "<auto_any>" || dispgen_pipeln == "<auto_single>") ? rbc_any_dispgen_pipeln : dispgen_pipeln;

	// scrm_mode, RBC-validated >> ES <<
	localparam rbc_all_scrm_mode = (fnl_prot_mode == "interlaken_mode") ? ("sync") : "async";
	localparam rbc_any_scrm_mode = (fnl_prot_mode == "interlaken_mode") ? ("sync") : "async";
	localparam fnl_scrm_mode = (scrm_mode == "<auto_any>" || scrm_mode == "<auto_single>") ? rbc_any_scrm_mode : scrm_mode;

	// scrm_seed, RBC-validated >> ES <<
	localparam rbc_all_scrm_seed = (fnl_prot_mode == "interlaken_mode") ? ("(scram_seed_min,scram_seed_max,scram_seed_user_setting)") : "scram_seed_max";
	localparam rbc_any_scrm_seed = (fnl_prot_mode == "interlaken_mode") ? ("scram_seed_user_setting") : "scram_seed_max";
	localparam fnl_scrm_seed = (scrm_seed == "<auto_any>" || scrm_seed == "<auto_single>") ? rbc_any_scrm_seed : scrm_seed;

	// tx_scrm_err, RBC-validated >> ES <<
	localparam rbc_all_tx_scrm_err = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode" || (fnl_prot_mode == "basic_mode" && fnl_scrm_bypass == "scrm_bypass_dis")) ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(scrm_err_en,scrm_err_dis)") : "scrm_err_dis"
		) : "scrm_err_dis";
	localparam rbc_any_tx_scrm_err = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode" || (fnl_prot_mode == "basic_mode" && fnl_scrm_bypass == "scrm_bypass_dis")) ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("scrm_err_dis") : "scrm_err_dis"
		) : "scrm_err_dis";
	localparam fnl_tx_scrm_err = (tx_scrm_err == "<auto_any>" || tx_scrm_err == "<auto_single>") ? rbc_any_tx_scrm_err : tx_scrm_err;

	// tx_scrm_width, RBC-validated >> ES <<
	localparam rbc_all_tx_scrm_width = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("bit64")
		 : (fnl_prot_mode == "basic_mode" && fnl_scrm_bypass == "scrm_bypass_dis") ?
			(
				(fnl_gb_tx_idwidth == "width_67") ? ("(bit67,bit64)")
				 : (fnl_gb_tx_idwidth == "width_66") ? ("(bit66,bit64)") : "(bit64,bit66,bit67)"
			) : "bit64";
	localparam rbc_any_tx_scrm_width = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("bit64")
		 : (fnl_prot_mode == "basic_mode" && fnl_scrm_bypass == "scrm_bypass_dis") ?
			(
				(fnl_gb_tx_idwidth == "width_67") ? ("bit64")
				 : (fnl_gb_tx_idwidth == "width_66") ? ("bit64") : "bit64"
			) : "bit64";
	localparam fnl_tx_scrm_width = (tx_scrm_width == "<auto_any>" || tx_scrm_width == "<auto_single>") ? rbc_any_tx_scrm_width : tx_scrm_width;

	// gb_sel_mode, RBC-validated >> ES <<
	localparam rbc_all_gb_sel_mode = ((fnl_prot_mode == "teng_sdi_mode") && (fnl_sup_mode == "engineering_mode")) ? ("(internal,external)") : "internal";
	localparam rbc_any_gb_sel_mode = ((fnl_prot_mode == "teng_sdi_mode") && (fnl_sup_mode == "engineering_mode")) ? ("internal") : "internal";
	localparam fnl_gb_sel_mode = (gb_sel_mode == "<auto_any>" || gb_sel_mode == "<auto_single>") ? rbc_any_gb_sel_mode : gb_sel_mode;

	// test_mode, RBC-validated >> ES <<
	localparam rbc_all_test_mode = (fnl_prot_mode == "test_prbs_mode") ? ("(prbs_31,prbs_23,prbs_9,prbs_7)")
		 : (fnl_prot_mode == "test_prp_mode") ? ("pseudo_random")
			 : (fnl_prot_mode == "test_rpg_mode") ? ("sq_wave") : "test_off";
	localparam rbc_any_test_mode = (fnl_prot_mode == "test_prbs_mode") ? ("prbs_31")
		 : (fnl_prot_mode == "test_prp_mode") ? ("pseudo_random")
			 : (fnl_prot_mode == "test_rpg_mode") ? ("sq_wave") : "test_off";
	localparam fnl_test_mode = (test_mode == "<auto_any>" || test_mode == "<auto_single>") ? rbc_any_test_mode : test_mode;

	// pseudo_random, RBC-validated >> ES <<
	localparam rbc_all_pseudo_random = (fnl_test_mode == "pseudo_random") ? ("(all_0,two_lf)") : "all_0";
	localparam rbc_any_pseudo_random = (fnl_test_mode == "pseudo_random") ? ("all_0") : "all_0";
	localparam fnl_pseudo_random = (pseudo_random == "<auto_any>" || pseudo_random == "<auto_single>") ? rbc_any_pseudo_random : pseudo_random;

	// sq_wave, RBC-validated >> ES <<
	localparam rbc_all_sq_wave = (fnl_test_mode == "sq_wave") ?
		(
			((fnl_gb_tx_odwidth == "width_32")) ? ("(sq_wave_1,sq_wave_4,sq_wave_6,sq_wave_8)")
			 : ((fnl_gb_tx_odwidth == "width_40")) ? ("(sq_wave_1,sq_wave_4,sq_wave_5,sq_wave_6,sq_wave_8,sq_wave_10)")
				 : ((fnl_gb_tx_odwidth == "width_64")) ? ("(sq_wave_1,sq_wave_4,sq_wave_6,sq_wave_8)") : "sq_wave_4"
		) : "sq_wave_4";
	localparam rbc_any_sq_wave = (fnl_test_mode == "sq_wave") ?
		(
			((fnl_gb_tx_odwidth == "width_32")) ? ("sq_wave_4")
			 : ((fnl_gb_tx_odwidth == "width_40")) ? ("sq_wave_4")
				 : ((fnl_gb_tx_odwidth == "width_64")) ? ("sq_wave_4") : "sq_wave_4"
		) : "sq_wave_4";
	localparam fnl_sq_wave = (sq_wave == "<auto_any>" || sq_wave == "<auto_single>") ? rbc_any_sq_wave : sq_wave;

	// bitslip_en, RBC-validated >> ES <<
	localparam rbc_all_bitslip_en = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "basic_mode") ? ("(bitslip_dis,bitslip_en)") : "bitslip_dis";
	localparam rbc_any_bitslip_en = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "basic_mode") ? ("bitslip_dis") : "bitslip_dis";
	localparam fnl_bitslip_en = (bitslip_en == "<auto_any>" || bitslip_en == "<auto_single>") ? rbc_any_bitslip_en : bitslip_en;

	// distdwn_bypass_pipeln, RBC-validated >> ES <<
	localparam rbc_all_distdwn_bypass_pipeln = "distdwn_bypass_pipeln_dis";
	localparam rbc_any_distdwn_bypass_pipeln = "distdwn_bypass_pipeln_dis";
	localparam fnl_distdwn_bypass_pipeln = (distdwn_bypass_pipeln == "<auto_any>" || distdwn_bypass_pipeln == "<auto_single>") ? rbc_any_distdwn_bypass_pipeln : distdwn_bypass_pipeln;

	// distup_bypass_pipeln, RBC-validated >> ES <<
	localparam rbc_all_distup_bypass_pipeln = "distup_bypass_pipeln_dis";
	localparam rbc_any_distup_bypass_pipeln = "distup_bypass_pipeln_dis";
	localparam fnl_distup_bypass_pipeln = (distup_bypass_pipeln == "<auto_any>" || distup_bypass_pipeln == "<auto_single>") ? rbc_any_distup_bypass_pipeln : distup_bypass_pipeln;

	// distdwn_master, RBC-validated >> ES <<
	localparam rbc_all_distdwn_master = (fnl_ctrl_plane_bonding == "individual") ? ("distdwn_master_en")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distdwn_master_en")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distdwn_master_dis") : "distdwn_master_dis";
	localparam rbc_any_distdwn_master = (fnl_ctrl_plane_bonding == "individual") ? ("distdwn_master_en")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distdwn_master_en")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distdwn_master_dis") : "distdwn_master_dis";
	localparam fnl_distdwn_master = (distdwn_master == "<auto_any>" || distdwn_master == "<auto_single>") ? rbc_any_distdwn_master : distdwn_master;

	// comp_cnt, RBC-validated >> ES <<
	localparam rbc_all_comp_cnt = (fnl_ctrl_plane_bonding == "individual") ? ("comp_cnt_00")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("(comp_cnt_02,comp_cnt_04,comp_cnt_06,comp_cnt_08,comp_cnt_0a,comp_cnt_0c,comp_cnt_0e,comp_cnt_10,comp_cnt_12,comp_cnt_14,comp_cnt_16,comp_cnt_18,comp_cnt_1a)")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("(comp_cnt_00,comp_cnt_02,comp_cnt_04,comp_cnt_06,comp_cnt_08,comp_cnt_0a,comp_cnt_0c,comp_cnt_0e,comp_cnt_10,comp_cnt_12,comp_cnt_14,comp_cnt_16,comp_cnt_18)") : "(comp_cnt_00,comp_cnt_02,comp_cnt_04,comp_cnt_06,comp_cnt_08,comp_cnt_0a,comp_cnt_0c,comp_cnt_0e,comp_cnt_10,comp_cnt_12,comp_cnt_14,comp_cnt_16,comp_cnt_18)";
	localparam rbc_any_comp_cnt = (fnl_ctrl_plane_bonding == "individual") ? ("comp_cnt_00")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("comp_cnt_02")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("comp_cnt_00") : "comp_cnt_00";
	localparam fnl_comp_cnt = (comp_cnt == "<auto_any>" || comp_cnt == "<auto_single>") ? rbc_any_comp_cnt : comp_cnt;

	// indv, RBC-validated >> ES <<
	localparam rbc_all_indv = (fnl_ctrl_plane_bonding == "individual") ? ("indv_en")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("indv_dis")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("indv_dis") : "indv_dis";
	localparam rbc_any_indv = (fnl_ctrl_plane_bonding == "individual") ? ("indv_en")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("indv_dis")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("indv_dis") : "indv_dis";
	localparam fnl_indv = (indv == "<auto_any>" || indv == "<auto_single>") ? rbc_any_indv : indv;

	// compin_sel, RBC-validated >> ES <<
	localparam rbc_all_compin_sel = (fnl_ctrl_plane_bonding == "individual") ? ("compin_master")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("compin_master")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("compin_slave_bot") : "compin_slave_top";
	localparam rbc_any_compin_sel = (fnl_ctrl_plane_bonding == "individual") ? ("compin_master")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("compin_master")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("compin_slave_bot") : "compin_slave_top";
	localparam fnl_compin_sel = (compin_sel == "<auto_any>" || compin_sel == "<auto_single>") ? rbc_any_compin_sel : compin_sel;

	// distup_master, RBC-validated >> ES <<
	localparam rbc_all_distup_master = (fnl_ctrl_plane_bonding == "individual") ? ("distup_master_en")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distup_master_en")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distup_master_dis") : "distup_master_dis";
	localparam rbc_any_distup_master = (fnl_ctrl_plane_bonding == "individual") ? ("distup_master_en")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distup_master_en")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distup_master_dis") : "distup_master_dis";
	localparam fnl_distup_master = (distup_master == "<auto_any>" || distup_master == "<auto_single>") ? rbc_any_distup_master : distup_master;

	// distup_bypass_pipeln_agg, RBC-validated >> ES <<
	localparam rbc_all_distup_bypass_pipeln_agg = (fnl_ctrl_plane_bonding == "individual" || fnl_prot_mode != "interlaken_mode") ? ("distup_bypass_pipeln_agg_dis")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distup_bypass_pipeln_agg_dis")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distup_bypass_pipeln_agg_dis") : "(distup_bypass_pipeln_agg_dis,distup_bypass_pipeln_agg_en)";
	localparam rbc_any_distup_bypass_pipeln_agg = (fnl_ctrl_plane_bonding == "individual" || fnl_prot_mode != "interlaken_mode") ? ("distup_bypass_pipeln_agg_dis")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distup_bypass_pipeln_agg_dis")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distup_bypass_pipeln_agg_dis") : "distup_bypass_pipeln_agg_dis";
	localparam fnl_distup_bypass_pipeln_agg = (distup_bypass_pipeln_agg == "<auto_any>" || distup_bypass_pipeln_agg == "<auto_single>") ? rbc_any_distup_bypass_pipeln_agg : distup_bypass_pipeln_agg;

	// comp_del_sel_agg, RBC-validated >> ES <<
	localparam rbc_all_comp_del_sel_agg = (fnl_ctrl_plane_bonding == "individual" || fnl_prot_mode != "interlaken_mode") ? ("data_agg_del0")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("(data_agg_del0,data_agg_del1,data_agg_del2,data_agg_del3,data_agg_del4,data_agg_del5,data_agg_del6,data_agg_del7,data_agg_del8)")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("(data_agg_del0,data_agg_del1,data_agg_del2,data_agg_del3,data_agg_del4,data_agg_del5,data_agg_del6,data_agg_del7,data_agg_del8)") : "(data_agg_del0,data_agg_del1,data_agg_del2,data_agg_del3,data_agg_del4,data_agg_del5,data_agg_del6,data_agg_del7,data_agg_del8)";
	localparam rbc_any_comp_del_sel_agg = (fnl_ctrl_plane_bonding == "individual" || fnl_prot_mode != "interlaken_mode") ? ("data_agg_del0")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("data_agg_del0")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("data_agg_del0") : "data_agg_del0";
	localparam fnl_comp_del_sel_agg = (comp_del_sel_agg == "<auto_any>" || comp_del_sel_agg == "<auto_single>") ? rbc_any_comp_del_sel_agg : comp_del_sel_agg;

	// distdwn_bypass_pipeln_agg, RBC-validated >> ES <<
	localparam rbc_all_distdwn_bypass_pipeln_agg = (fnl_ctrl_plane_bonding == "individual" || fnl_prot_mode != "interlaken_mode") ? ("distdwn_bypass_pipeln_agg_dis")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distdwn_bypass_pipeln_agg_dis")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("(distdwn_bypass_pipeln_agg_dis,distdwn_bypass_pipeln_agg_en)") : "distdwn_bypass_pipeln_agg_dis";
	localparam rbc_any_distdwn_bypass_pipeln_agg = (fnl_ctrl_plane_bonding == "individual" || fnl_prot_mode != "interlaken_mode") ? ("distdwn_bypass_pipeln_agg_dis")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distdwn_bypass_pipeln_agg_dis")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distdwn_bypass_pipeln_agg_dis") : "distdwn_bypass_pipeln_agg_dis";
	localparam fnl_distdwn_bypass_pipeln_agg = (distdwn_bypass_pipeln_agg == "<auto_any>" || distdwn_bypass_pipeln_agg == "<auto_single>") ? rbc_any_distdwn_bypass_pipeln_agg : distdwn_bypass_pipeln_agg;

	// stretch_en, RBC-validated >> ES <<
	localparam rbc_all_stretch_en = (fnl_sup_mode == "engineering_mode") ? ("(stretch_en,stretch_dis)") : "stretch_en";
	localparam rbc_any_stretch_en = (fnl_sup_mode == "engineering_mode") ? ("stretch_en") : "stretch_en";
	localparam fnl_stretch_en = (stretch_en == "<auto_any>" || stretch_en == "<auto_single>") ? rbc_any_stretch_en : stretch_en;

	// stretch_num_stages, RBC-validated >> ES <<
	localparam rbc_all_stretch_num_stages = (fnl_sup_mode == "engineering_mode") ? ("(zero_stage,one_stage,two_stage,three_stage)") : "zero_stage";
	localparam rbc_any_stretch_num_stages = (fnl_sup_mode == "engineering_mode") ? ("zero_stage") : "zero_stage";
	localparam fnl_stretch_num_stages = (stretch_num_stages == "<auto_any>" || stretch_num_stages == "<auto_single>") ? rbc_any_stretch_num_stages : stretch_num_stages;

	// iqtxrx_clkout_sel, RBC-validated >> ES <<
	localparam rbc_all_iqtxrx_clkout_sel = (fnl_sup_mode == "engineering_mode") ? ("(iq_tx_pma_clk,iq_tx_pma_clk_div33)") : "iq_tx_pma_clk";
	localparam rbc_any_iqtxrx_clkout_sel = (fnl_sup_mode == "engineering_mode") ? ("iq_tx_pma_clk") : "iq_tx_pma_clk";
	localparam fnl_iqtxrx_clkout_sel = (iqtxrx_clkout_sel == "<auto_any>" || iqtxrx_clkout_sel == "<auto_single>") ? rbc_any_iqtxrx_clkout_sel : iqtxrx_clkout_sel;

	// tx_testbus_sel, RBC-validated >> ES <<
	localparam rbc_all_tx_testbus_sel = (fnl_prot_mode == "disable_mode") ? ("tx_fifo_testbus1") : "(crc32_gen_testbus1,crc32_gen_testbus2,disp_gen_testbus1,disp_gen_testbus2,frame_gen_testbus1,frame_gen_testbus2,enc64b66b_testbus,txsm_testbus,tx_cp_bond_testbus,prbs_gen_xg_testbus,gearbox_red_testbus1,gearbox_red_testbus2,scramble_testbus1,scramble_testbus2,tx_fifo_testbus1,tx_fifo_testbus2)";
	localparam rbc_any_tx_testbus_sel = (fnl_prot_mode == "disable_mode") ? ("tx_fifo_testbus1") : "crc32_gen_testbus1";
	localparam fnl_tx_testbus_sel = (tx_testbus_sel == "<auto_any>" || tx_testbus_sel == "<auto_single>") ? rbc_any_tx_testbus_sel : tx_testbus_sel;

	// tx_polarity_inv, RBC-validated >> ES <<
	localparam rbc_all_tx_polarity_inv = (fnl_prot_mode == "disable_mode") ? ("invert_disable") : "(invert_disable,invert_enable)";
	localparam rbc_any_tx_polarity_inv = (fnl_prot_mode == "disable_mode") ? ("invert_disable") : "invert_disable";
	localparam fnl_tx_polarity_inv = (tx_polarity_inv == "<auto_any>" || tx_polarity_inv == "<auto_single>") ? rbc_any_tx_polarity_inv : tx_polarity_inv;

	// pmagate_en, RBC-validated >> ES <<
	localparam rbc_all_pmagate_en = (fnl_prot_mode == "interlaken_mode") ? ("pmagate_dis") : "(pmagate_en,pmagate_dis)";
	localparam rbc_any_pmagate_en = (fnl_prot_mode == "interlaken_mode") ? ("pmagate_dis") : "pmagate_dis";
	localparam fnl_pmagate_en = (pmagate_en == "<auto_any>" || pmagate_en == "<auto_single>") ? rbc_any_pmagate_en : pmagate_en;


   // REVE parameters
   localparam skip_check_distup_master_agg = 1;
   localparam skip_check_empty_flag_type = 1;
   localparam skip_check_data_agg_bonding = 1;
   localparam skip_check_distdwn_master_agg = 1;
   localparam skip_check_stretch_type = 1;
   localparam skip_check_compin_sel_agg = 1;
   localparam skip_check_pempty_flag_type = 1; 
   localparam skip_check_del_sel_frame_gen = 1;// not checked
   localparam skip_check_pfull_flag_type = 1;
   localparam skip_check_ctrl_bit_reverse = 1;
   localparam skip_check_data_bit_reverse = 1;
   localparam skip_check_data_agg_comp = 1;
   localparam skip_check_fifo_stop_wr = 1;
   localparam skip_check_fifo_stop_rd = 1;
   localparam skip_check_full_flag_type = 1;

   
   
   localparam fnl_distup_master_agg = "distup_master_agg_en";
   localparam fnl_empty_flag_type = "empty_rd_side";
   localparam fnl_data_agg_bonding = "agg_individual";
   localparam fnl_distdwn_master_agg = "distdwn_master_agg_en";
   localparam fnl_stretch_type = "stretch_auto";
   localparam fnl_compin_sel_agg = "compin_agg_master";
   localparam fnl_pempty_flag_type = "pempty_rd_side";
   localparam fnl_del_sel_frame_gen = "del_sel_frame_gen_del0";
   localparam fnl_pfull_flag_type = "pfull_wr_side";
   localparam fnl_ctrl_bit_reverse = "ctrl_bit_reverse_dis";
   localparam fnl_data_bit_reverse = "data_bit_reverse_dis";
   localparam fnl_data_agg_comp = "data_agg_del0";
   localparam fnl_fifo_stop_wr = "n_wr_full";
   localparam fnl_fifo_stop_rd = "n_rd_empty";
   localparam fnl_full_flag_type = "full_wr_side";


   localparam rbc_all_distup_master_agg = "";
   localparam rbc_all_empty_flag_type = "";
   localparam rbc_all_data_agg_bonding = "";
   localparam rbc_all_distdwn_master_agg = "";
   localparam rbc_all_stretch_type = "";
   localparam rbc_all_compin_sel_agg = "";
   localparam rbc_all_pempty_flag_type = "";
   localparam rbc_all_del_sel_frame_gen = "";
   localparam rbc_all_pfull_flag_type = "";
   localparam rbc_all_ctrl_bit_reverse = "";
   localparam rbc_all_data_bit_reverse = "";
   localparam rbc_all_data_agg_comp = "";
   localparam rbc_all_fifo_stop_wr = "";
   localparam rbc_all_fifo_stop_rd = "";
   localparam rbc_all_full_flag_type = "";

   
   // crcgen_init external parameter (no RBC) >> common rule <<
   localparam rbc_all_crcgen_init = "crcgen_init_user_setting";
   localparam rbc_any_crcgen_init = "crcgen_init_user_setting";
   localparam fnl_crcgen_init = (crcgen_init == "<auto_any>" || crcgen_init == "<auto_single>") ? rbc_any_crcgen_init : crcgen_init;
   
   
      //========================ES RULES END ==============================================================================


`else
      //========================REVE RULES START ==============================================================================


   
   
   localparam skip_check_distup_master_agg = 0;
   localparam skip_check_empty_flag_type = 0;
   localparam skip_check_data_agg_bonding = 0;
   localparam skip_check_distdwn_master_agg = 0;
   localparam skip_check_stretch_type = 0;
   localparam skip_check_compin_sel_agg = 0;
   localparam skip_check_pempty_flag_type = 0;
   localparam skip_check_del_sel_frame_gen = 0;
   localparam skip_check_pfull_flag_type = 0;
   localparam skip_check_ctrl_bit_reverse = 0;
   localparam skip_check_data_bit_reverse = 0;
   localparam skip_check_data_agg_comp = 0;
   localparam skip_check_fifo_stop_wr = 0;
   localparam skip_check_fifo_stop_rd = 0;
   localparam skip_check_full_flag_type = 0;

   
   
   
   localparam silicon_rev_local = "reve";


	// prot_mode external parameter (no RBC) >> REVE <<
	localparam rbc_all_prot_mode = "(basic_mode,disable_mode,interlaken_mode,sfis_mode,teng_1588_mode,teng_baser_mode,teng_sdi_mode,test_prbs_mode,test_prp_mode,test_rpg_mode)";
	localparam rbc_any_prot_mode = "disable_mode";
	localparam fnl_prot_mode = (prot_mode == "<auto_any>" || prot_mode == "<auto_single>") ? rbc_any_prot_mode : prot_mode;

	// sup_mode external parameter (no RBC) >> REVE <<
	localparam rbc_all_sup_mode = "(engineering_mode,engr_mode,stretch_mode,user_mode)";
	localparam rbc_any_sup_mode = "user_mode";
	localparam fnl_sup_mode = (sup_mode == "<auto_any>" || sup_mode == "<auto_single>") ? rbc_any_sup_mode : sup_mode;

	// crcgen_init external parameter (no RBC) >> REVE <<
	localparam rbc_all_crcgen_init = "crcgen_int";
	localparam rbc_any_crcgen_init = "crcgen_int";
	localparam fnl_crcgen_init = (crcgen_init == "<auto_any>" || crcgen_init == "<auto_single>") ? rbc_any_crcgen_init : crcgen_init;

	// test_bus_mode external parameter (no RBC) >> REVE <<
	localparam rbc_all_test_bus_mode = "(rx,tx)";
	localparam rbc_any_test_bus_mode = "tx";
	localparam fnl_test_bus_mode = (test_bus_mode == "<auto_any>" || test_bus_mode == "<auto_single>") ? rbc_any_test_bus_mode : test_bus_mode;

	// use_default_base_address external parameter (no RBC) >> REVE <<
	localparam rbc_all_use_default_base_address = "(false,true)";
	localparam rbc_any_use_default_base_address = "true";
	localparam fnl_use_default_base_address = (use_default_base_address == "<auto_any>" || use_default_base_address == "<auto_single>") ? rbc_any_use_default_base_address : use_default_base_address;

	// gb_tx_odwidth, RBC-validated >> REVE <<
	localparam rbc_all_gb_tx_odwidth = ((fnl_prot_mode == "teng_baser_mode") || fnl_prot_mode == "teng_1588_mode" || (fnl_prot_mode == "test_prp_mode")) ? ("(width_32,width_40)")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("(width_32,width_40)")
			 : ((fnl_prot_mode == "sfis_mode")) ? ("(width_32,width_40,width_64)")
				 : ((fnl_prot_mode == "teng_sdi_mode")) ? ("width_40")
					 : ((fnl_prot_mode == "basic_mode")) ? ("(width_32,width_40,width_64)")
						 : (fnl_prot_mode == "test_prbs_mode") ? ("(width_32,width_40,width_64)") : "width_32";
	localparam rbc_any_gb_tx_odwidth = ((fnl_prot_mode == "teng_baser_mode") || fnl_prot_mode == "teng_1588_mode" || (fnl_prot_mode == "test_prp_mode")) ? ("width_32")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("width_32")
			 : ((fnl_prot_mode == "sfis_mode")) ? ("width_32")
				 : ((fnl_prot_mode == "teng_sdi_mode")) ? ("width_40")
					 : ((fnl_prot_mode == "basic_mode")) ? ("width_32")
						 : (fnl_prot_mode == "test_prbs_mode") ? ("width_32") : "width_32";
	localparam fnl_gb_tx_odwidth = (gb_tx_odwidth == "<auto_any>" || gb_tx_odwidth == "<auto_single>") ? rbc_any_gb_tx_odwidth : gb_tx_odwidth;

	// gb_tx_idwidth, RBC-validated >> REVE <<
	localparam rbc_all_gb_tx_idwidth = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode")) ? ("width_66")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("width_67")
			 : ((fnl_prot_mode == "sfis_mode")) ?
				(
					(fnl_gb_tx_odwidth == "width_32") ? ("(width_32,width_64)")
					 : (fnl_gb_tx_odwidth == "width_40") ?
						(
							((fnl_sup_mode == "engineering_mode")) ? ("(width_40,width_64)") : "width_40"
						) : "width_64"
				)
				 : ((fnl_prot_mode == "teng_sdi_mode")) ?
					(
						((fnl_sup_mode == "engineering_mode")) ? ("(width_40,width_50)") : "width_50"
					)
					 : ((fnl_prot_mode == "basic_mode")) ?
						(
							(fnl_gb_tx_odwidth == "width_32") ?
							(
								((fnl_sup_mode == "engineering_mode")) ? ("(width_32,width_64,width_66,width_67)") : "(width_32,width_64)"
							)
							 : (fnl_gb_tx_odwidth == "width_40") ?
								(
									((fnl_sup_mode == "engineering_mode")) ? ("(width_40,width_64,width_66,width_67)") : "(width_40,width_66)"
								) : "width_64"
						)
						 : (fnl_gb_tx_odwidth == "width_32") ? ("width_32")
							 : (fnl_gb_tx_odwidth == "width_40") ? ("width_40") : "width_64";
	localparam rbc_any_gb_tx_idwidth = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode")) ? ("width_66")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("width_67")
			 : ((fnl_prot_mode == "sfis_mode")) ?
				(
					(fnl_gb_tx_odwidth == "width_32") ? ("width_32")
					 : (fnl_gb_tx_odwidth == "width_40") ?
						(
							((fnl_sup_mode == "engineering_mode")) ? ("width_40") : "width_40"
						) : "width_64"
				)
				 : ((fnl_prot_mode == "teng_sdi_mode")) ?
					(
						((fnl_sup_mode == "engineering_mode")) ? ("width_50") : "width_50"
					)
					 : ((fnl_prot_mode == "basic_mode")) ?
						(
							(fnl_gb_tx_odwidth == "width_32") ?
							(
								((fnl_sup_mode == "engineering_mode")) ? ("width_32") : "width_32"
							)
							 : (fnl_gb_tx_odwidth == "width_40") ?
								(
									((fnl_sup_mode == "engineering_mode")) ? ("width_40") : "width_40"
								) : "width_64"
						)
						 : (fnl_gb_tx_odwidth == "width_32") ? ("width_32")
							 : (fnl_gb_tx_odwidth == "width_40") ? ("width_40") : "width_64";
	localparam fnl_gb_tx_idwidth = (gb_tx_idwidth == "<auto_any>" || gb_tx_idwidth == "<auto_single>") ? rbc_any_gb_tx_idwidth : gb_tx_idwidth;

	// ctrl_plane_bonding, RBC-validated >> REVE <<
	localparam rbc_all_ctrl_plane_bonding = (fnl_prot_mode != "sfis_mode" && fnl_prot_mode != "basic_mode" && fnl_prot_mode != "interlaken_mode") ? ("individual")
		 : ((fnl_gb_tx_odwidth == "width_32" && fnl_gb_tx_idwidth == "width_32") ||
         (fnl_gb_tx_odwidth == "width_40" && fnl_gb_tx_idwidth == "width_40") ||
         (fnl_gb_tx_odwidth == "width_64" && fnl_gb_tx_idwidth == "width_64")) ? ("individual") : "(individual,ctrl_master,ctrl_slave_blw,ctrl_slave_abv)";
	localparam rbc_any_ctrl_plane_bonding = (fnl_prot_mode != "sfis_mode" && fnl_prot_mode != "basic_mode" && fnl_prot_mode != "interlaken_mode") ? ("individual")
		 : ((fnl_gb_tx_odwidth == "width_32" && fnl_gb_tx_idwidth == "width_32") ||
         (fnl_gb_tx_odwidth == "width_40" && fnl_gb_tx_idwidth == "width_40") ||
         (fnl_gb_tx_odwidth == "width_64" && fnl_gb_tx_idwidth == "width_64")) ? ("individual") : "individual";
	localparam fnl_ctrl_plane_bonding = (ctrl_plane_bonding == "<auto_any>" || ctrl_plane_bonding == "<auto_single>") ? rbc_any_ctrl_plane_bonding : ctrl_plane_bonding;

	// data_agg_bonding, RBC-validated >> REVE <<
	localparam rbc_all_data_agg_bonding = (fnl_prot_mode != "interlaken_mode" || fnl_ctrl_plane_bonding == "individual") ? ("agg_individual") : "(agg_master,agg_slave_blw,agg_slave_abv)";
	localparam rbc_any_data_agg_bonding = (fnl_prot_mode != "interlaken_mode" || fnl_ctrl_plane_bonding == "individual") ? ("agg_individual") : "agg_master";
	localparam fnl_data_agg_bonding = (data_agg_bonding == "<auto_any>" || data_agg_bonding == "<auto_single>") ? rbc_any_data_agg_bonding : data_agg_bonding;

	// master_clk_sel, RBC-validated >> REVE <<
	localparam rbc_all_master_clk_sel = (fnl_sup_mode == "engineering_mode") ? ("(master_tx_pma_clk,master_refclk_dig)") : "master_tx_pma_clk";
	localparam rbc_any_master_clk_sel = (fnl_sup_mode == "engineering_mode") ? ("master_tx_pma_clk") : "master_tx_pma_clk";
	localparam fnl_master_clk_sel = (master_clk_sel == "<auto_any>" || master_clk_sel == "<auto_single>") ? rbc_any_master_clk_sel : master_clk_sel;

	// txfifo_mode, RBC-validated >> REVE <<
	localparam rbc_all_txfifo_mode = (fnl_prot_mode == "interlaken_mode") ? ("interlaken_generic")
		 : (fnl_prot_mode == "teng_baser_mode") ?
			(
				(fnl_sup_mode == "engineering_mode") ? ("(clk_comp,phase_comp)") : "phase_comp"
			)
			 : (fnl_prot_mode == "teng_sdi_mode") ?
				(
					(fnl_sup_mode == "engineering_mode") ? ("(register_mode,phase_comp)") : "phase_comp"
				)
				 : ((fnl_prot_mode == "basic_mode")) ?
					(
						(fnl_sup_mode == "engineering_mode" && fnl_ctrl_plane_bonding == "individual") ? ("(basic_generic,register_mode,phase_comp)")
						 : (((fnl_gb_tx_odwidth == "width_32" && fnl_gb_tx_idwidth == "width_32") ||
              (fnl_gb_tx_odwidth == "width_40" && fnl_gb_tx_idwidth == "width_40") ||
              (fnl_gb_tx_odwidth == "width_64" && fnl_gb_tx_idwidth == "width_64")) && fnl_ctrl_plane_bonding == "individual") ? ("(basic_generic,register_mode,phase_comp)") : "(basic_generic,phase_comp)"
					)
					 : ((fnl_prot_mode == "teng_1588_mode")) ? ("register_mode") : "phase_comp";
	localparam rbc_any_txfifo_mode = (fnl_prot_mode == "interlaken_mode") ? ("interlaken_generic")
		 : (fnl_prot_mode == "teng_baser_mode") ?
			(
				(fnl_sup_mode == "engineering_mode") ? ("phase_comp") : "phase_comp"
			)
			 : (fnl_prot_mode == "teng_sdi_mode") ?
				(
					(fnl_sup_mode == "engineering_mode") ? ("phase_comp") : "phase_comp"
				)
				 : ((fnl_prot_mode == "basic_mode")) ?
					(
						(fnl_sup_mode == "engineering_mode" && fnl_ctrl_plane_bonding == "individual") ? ("phase_comp")
						 : (((fnl_gb_tx_odwidth == "width_32" && fnl_gb_tx_idwidth == "width_32") ||
              (fnl_gb_tx_odwidth == "width_40" && fnl_gb_tx_idwidth == "width_40") ||
              (fnl_gb_tx_odwidth == "width_64" && fnl_gb_tx_idwidth == "width_64")) && fnl_ctrl_plane_bonding == "individual") ? ("phase_comp") : "phase_comp"
					)
					 : ((fnl_prot_mode == "teng_1588_mode")) ? ("register_mode") : "phase_comp";
	localparam fnl_txfifo_mode = (txfifo_mode == "<auto_any>" || txfifo_mode == "<auto_single>") ? rbc_any_txfifo_mode : txfifo_mode;

	// wr_clk_sel, RBC-validated >> REVE <<
	localparam rbc_all_wr_clk_sel = (fnl_txfifo_mode == "register_mode") ?
		(
			(fnl_master_clk_sel == "master_refclk_dig") ? ("wr_refclk_dig") : "wr_tx_pma_clk"
		) : "wr_tx_pld_clk";
	localparam rbc_any_wr_clk_sel = (fnl_txfifo_mode == "register_mode") ?
		(
			(fnl_master_clk_sel == "master_refclk_dig") ? ("wr_refclk_dig") : "wr_tx_pma_clk"
		) : "wr_tx_pld_clk";
	localparam fnl_wr_clk_sel = (wr_clk_sel == "<auto_any>" || wr_clk_sel == "<auto_single>") ? rbc_any_wr_clk_sel : wr_clk_sel;

	// sqwgen_clken, RBC-validated >> REVE <<
	localparam rbc_all_sqwgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("sqwgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("sqwgen_clk_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("sqwgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("sqwgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("sqwgen_clk_en") : "sqwgen_clk_dis";
	localparam rbc_any_sqwgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("sqwgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("sqwgen_clk_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("sqwgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("sqwgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("sqwgen_clk_en") : "sqwgen_clk_dis";
	localparam fnl_sqwgen_clken = (sqwgen_clken == "<auto_any>" || sqwgen_clken == "<auto_single>") ? rbc_any_sqwgen_clken : sqwgen_clken;

	// wrfifo_clken, RBC-validated >> REVE <<
	localparam rbc_all_wrfifo_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("wrfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("wrfifo_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("wrfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("wrfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("wrfifo_clk_en") : "wrfifo_clk_dis";
	localparam rbc_any_wrfifo_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("wrfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("wrfifo_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("wrfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("wrfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("wrfifo_clk_en") : "wrfifo_clk_dis";
	localparam fnl_wrfifo_clken = (wrfifo_clken == "<auto_any>" || wrfifo_clken == "<auto_single>") ? rbc_any_wrfifo_clken : wrfifo_clken;

	// dispgen_clken, RBC-validated >> REVE <<
	localparam rbc_all_dispgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("dispgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispgen_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("dispgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("dispgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("dispgen_clk_en") : "dispgen_clk_dis";
	localparam rbc_any_dispgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("dispgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispgen_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("dispgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("dispgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("dispgen_clk_en") : "dispgen_clk_dis";
	localparam fnl_dispgen_clken = (dispgen_clken == "<auto_any>" || dispgen_clken == "<auto_single>") ? rbc_any_dispgen_clken : dispgen_clken;

	// scrm_clken, RBC-validated >> REVE <<
	localparam rbc_all_scrm_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("scrm_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("scrm_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("scrm_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_sup_mode == "engineering_mode" && (fnl_gb_tx_idwidth == "width_64" || fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("scrm_clk_en") : "scrm_clk_dis"
					)
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("scrm_clk_en") : "scrm_clk_dis";
	localparam rbc_any_scrm_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("scrm_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("scrm_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("scrm_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_sup_mode == "engineering_mode" && (fnl_gb_tx_idwidth == "width_64" || fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("scrm_clk_en") : "scrm_clk_dis"
					)
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("scrm_clk_en") : "scrm_clk_dis";
	localparam fnl_scrm_clken = (scrm_clken == "<auto_any>" || scrm_clken == "<auto_single>") ? rbc_any_scrm_clken : scrm_clken;

	// enc_64b66b_txsm_bypass, RBC-validated >> REVE <<
	localparam rbc_all_enc_64b66b_txsm_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("enc_64b66b_txsm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("enc_64b66b_txsm_bypass_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("enc_64b66b_txsm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("enc_64b66b_txsm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("enc_64b66b_txsm_bypass_en") : "enc_64b66b_txsm_bypass_en";
	localparam rbc_any_enc_64b66b_txsm_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("enc_64b66b_txsm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("enc_64b66b_txsm_bypass_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("enc_64b66b_txsm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("enc_64b66b_txsm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("enc_64b66b_txsm_bypass_en") : "enc_64b66b_txsm_bypass_en";
	localparam fnl_enc_64b66b_txsm_bypass = (enc_64b66b_txsm_bypass == "<auto_any>" || enc_64b66b_txsm_bypass == "<auto_single>") ? rbc_any_enc_64b66b_txsm_bypass : enc_64b66b_txsm_bypass;

	// dispgen_bypass, RBC-validated >> REVE <<
	localparam rbc_all_dispgen_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("dispgen_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispgen_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("dispgen_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("dispgen_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("dispgen_bypass_en") : "dispgen_bypass_en";
	localparam rbc_any_dispgen_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("dispgen_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("dispgen_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("dispgen_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("dispgen_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("dispgen_bypass_en") : "dispgen_bypass_en";
	localparam fnl_dispgen_bypass = (dispgen_bypass == "<auto_any>" || dispgen_bypass == "<auto_single>") ? rbc_any_dispgen_bypass : dispgen_bypass;

	// gbred_clken, RBC-validated >> REVE <<
	localparam rbc_all_gbred_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("gbred_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("gbred_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("gbred_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("gbred_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("gbred_clk_en") : "gbred_clk_dis";
	localparam rbc_any_gbred_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("gbred_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("gbred_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("gbred_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("gbred_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("gbred_clk_en") : "gbred_clk_dis";
	localparam fnl_gbred_clken = (gbred_clken == "<auto_any>" || gbred_clken == "<auto_single>") ? rbc_any_gbred_clken : gbred_clken;

	// tx_sm_bypass, RBC-validated >> REVE <<
	localparam rbc_all_tx_sm_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("tx_sm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("tx_sm_bypass_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("tx_sm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("tx_sm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("tx_sm_bypass_en") : "tx_sm_bypass_en";
	localparam rbc_any_tx_sm_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("tx_sm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("tx_sm_bypass_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("tx_sm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("tx_sm_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("tx_sm_bypass_en") : "tx_sm_bypass_en";
	localparam fnl_tx_sm_bypass = (tx_sm_bypass == "<auto_any>" || tx_sm_bypass == "<auto_single>") ? rbc_any_tx_sm_bypass : tx_sm_bypass;

	// enc64b66b_txsm_clken, RBC-validated >> REVE <<
	localparam rbc_all_enc64b66b_txsm_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("enc64b66b_txsm_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("enc64b66b_txsm_clk_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("enc64b66b_txsm_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("enc64b66b_txsm_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("enc64b66b_txsm_clk_en") : "enc64b66b_txsm_clk_dis";
	localparam rbc_any_enc64b66b_txsm_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("enc64b66b_txsm_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("enc64b66b_txsm_clk_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("enc64b66b_txsm_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("enc64b66b_txsm_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("enc64b66b_txsm_clk_en") : "enc64b66b_txsm_clk_dis";
	localparam fnl_enc64b66b_txsm_clken = (enc64b66b_txsm_clken == "<auto_any>" || enc64b66b_txsm_clken == "<auto_single>") ? rbc_any_enc64b66b_txsm_clken : enc64b66b_txsm_clken;

	// frmgen_bypass, RBC-validated >> REVE <<
	localparam rbc_all_frmgen_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("frmgen_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmgen_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("frmgen_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("frmgen_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("frmgen_bypass_en") : "frmgen_bypass_en";
	localparam rbc_any_frmgen_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("frmgen_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmgen_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("frmgen_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("frmgen_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("frmgen_bypass_en") : "frmgen_bypass_en";
	localparam fnl_frmgen_bypass = (frmgen_bypass == "<auto_any>" || frmgen_bypass == "<auto_single>") ? rbc_any_frmgen_bypass : frmgen_bypass;

	// crcgen_clken, RBC-validated >> REVE <<
	localparam rbc_all_crcgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("crcgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcgen_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("crcgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("crcgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("crcgen_clk_en") : "crcgen_clk_dis";
	localparam rbc_any_crcgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("crcgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcgen_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("crcgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("crcgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("crcgen_clk_en") : "crcgen_clk_dis";
	localparam fnl_crcgen_clken = (crcgen_clken == "<auto_any>" || crcgen_clken == "<auto_single>") ? rbc_any_crcgen_clken : crcgen_clken;

	// scrm_bypass, RBC-validated >> REVE <<
	localparam rbc_all_scrm_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("scrm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("scrm_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("scrm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_sup_mode == "engineering_mode" && (fnl_gb_tx_idwidth == "width_64" || fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("(scrm_bypass_dis,scrm_bypass_en)") : "scrm_bypass_en"
					)
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("scrm_bypass_en") : "scrm_bypass_en";
	localparam rbc_any_scrm_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("scrm_bypass_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("scrm_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("scrm_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ?
					(
						(fnl_sup_mode == "engineering_mode" && (fnl_gb_tx_idwidth == "width_64" || fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("scrm_bypass_dis") : "scrm_bypass_en"
					)
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("scrm_bypass_en") : "scrm_bypass_en";
	localparam fnl_scrm_bypass = (scrm_bypass == "<auto_any>" || scrm_bypass == "<auto_single>") ? rbc_any_scrm_bypass : scrm_bypass;

	// frmgen_clken, RBC-validated >> REVE <<
	localparam rbc_all_frmgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("frmgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmgen_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("frmgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("frmgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("frmgen_clk_en") : "frmgen_clk_dis";
	localparam rbc_any_frmgen_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("frmgen_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("frmgen_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("frmgen_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("frmgen_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("frmgen_clk_en") : "frmgen_clk_dis";
	localparam fnl_frmgen_clken = (frmgen_clken == "<auto_any>" || frmgen_clken == "<auto_single>") ? rbc_any_frmgen_clken : frmgen_clken;

	// prbs_clken, RBC-validated >> REVE <<
	localparam rbc_all_prbs_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("prbs_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("prbs_clk_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("prbs_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("prbs_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("prbs_clk_en") : "prbs_clk_dis";
	localparam rbc_any_prbs_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("prbs_clk_dis")
		 : (fnl_prot_mode == "interlaken_mode") ? ("prbs_clk_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("prbs_clk_dis")
				 : (fnl_prot_mode == "basic_mode") ? ("prbs_clk_dis")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("prbs_clk_en") : "prbs_clk_dis";
	localparam fnl_prbs_clken = (prbs_clken == "<auto_any>" || prbs_clken == "<auto_single>") ? rbc_any_prbs_clken : prbs_clken;

	// crcgen_bypass, RBC-validated >> REVE <<
	localparam rbc_all_crcgen_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("crcgen_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcgen_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("crcgen_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("crcgen_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("crcgen_bypass_en") : "crcgen_bypass_en";
	localparam rbc_any_crcgen_bypass = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("crcgen_bypass_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("crcgen_bypass_dis")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("crcgen_bypass_en")
				 : (fnl_prot_mode == "basic_mode") ? ("crcgen_bypass_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("crcgen_bypass_en") : "crcgen_bypass_en";
	localparam fnl_crcgen_bypass = (crcgen_bypass == "<auto_any>" || crcgen_bypass == "<auto_single>") ? rbc_any_crcgen_bypass : crcgen_bypass;

	// rdfifo_clken, RBC-validated >> REVE <<
	localparam rbc_all_rdfifo_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("rdfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rdfifo_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("rdfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("rdfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("rdfifo_clk_en") : "rdfifo_clk_dis";
	localparam rbc_any_rdfifo_clken = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "test_prp_mode" || fnl_prot_mode == "teng_1588_mode") ? ("rdfifo_clk_en")
		 : (fnl_prot_mode == "interlaken_mode") ? ("rdfifo_clk_en")
			 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "teng_sdi_mode") ? ("rdfifo_clk_en")
				 : (fnl_prot_mode == "basic_mode") ? ("rdfifo_clk_en")
					 : (fnl_prot_mode == "test_prbs_mode" || fnl_prot_mode == "test_rpg_mode") ? ("rdfifo_clk_en") : "rdfifo_clk_dis";
	localparam fnl_rdfifo_clken = (rdfifo_clken == "<auto_any>" || rdfifo_clken == "<auto_single>") ? rbc_any_rdfifo_clken : rdfifo_clken;

	// fastpath, RBC-validated >> REVE <<
	localparam rbc_all_fastpath = (fnl_frmgen_bypass == "frmgen_bypass_en" && fnl_crcgen_bypass == "crcgen_bypass_en" && fnl_enc_64b66b_txsm_bypass == "enc_64b66b_txsm_bypass_en" && fnl_scrm_bypass == "scrm_bypass_en" && fnl_dispgen_bypass == "dispgen_bypass_en") ? ("fastpath_en") : "fastpath_dis";
	localparam rbc_any_fastpath = (fnl_frmgen_bypass == "frmgen_bypass_en" && fnl_crcgen_bypass == "crcgen_bypass_en" && fnl_enc_64b66b_txsm_bypass == "enc_64b66b_txsm_bypass_en" && fnl_scrm_bypass == "scrm_bypass_en" && fnl_dispgen_bypass == "dispgen_bypass_en") ? ("fastpath_en") : "fastpath_dis";
	localparam fnl_fastpath = (fastpath == "<auto_any>" || fastpath == "<auto_single>") ? rbc_any_fastpath : fastpath;

	// bit_reverse, RBC-validated >> REVE <<
	localparam rbc_all_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode")) ? ("bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("bit_reverse_en")
			 : (fnl_prot_mode == "basic_mode" && (fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("(bit_reverse_en,bit_reverse_dis)") : "bit_reverse_dis";
	localparam rbc_any_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode")) ? ("bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode")) ? ("bit_reverse_en")
			 : (fnl_prot_mode == "basic_mode" && (fnl_gb_tx_idwidth == "width_66" || fnl_gb_tx_idwidth == "width_67")) ? ("bit_reverse_dis") : "bit_reverse_dis";
	localparam fnl_bit_reverse = (bit_reverse == "<auto_any>" || bit_reverse == "<auto_single>") ? rbc_any_bit_reverse : bit_reverse;

	// data_bit_reverse, RBC-validated >> REVE <<
	localparam rbc_all_data_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_tx_idwidth == "width_66")) ? ("data_bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_tx_idwidth == "width_67")) ? ("data_bit_reverse_en") : "data_bit_reverse_dis";
	localparam rbc_any_data_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_tx_idwidth == "width_66")) ? ("data_bit_reverse_dis")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_tx_idwidth == "width_67")) ? ("data_bit_reverse_en") : "data_bit_reverse_dis";
	localparam fnl_data_bit_reverse = (data_bit_reverse == "<auto_any>" || data_bit_reverse == "<auto_single>") ? rbc_any_data_bit_reverse : data_bit_reverse;

	// ctrl_bit_reverse, RBC-validated >> REVE <<
	localparam rbc_all_ctrl_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_tx_idwidth == "width_66")) ? ("ctrl_bit_reverse_en")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_tx_idwidth == "width_67")) ? ("ctrl_bit_reverse_en") : "ctrl_bit_reverse_dis";
	localparam rbc_any_ctrl_bit_reverse = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_tx_idwidth == "width_66")) ? ("ctrl_bit_reverse_en")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_tx_idwidth == "width_67")) ? ("ctrl_bit_reverse_en") : "ctrl_bit_reverse_dis";
	localparam fnl_ctrl_bit_reverse = (ctrl_bit_reverse == "<auto_any>" || ctrl_bit_reverse == "<auto_single>") ? rbc_any_ctrl_bit_reverse : ctrl_bit_reverse;

	// tx_sh_location, RBC-validated >> REVE <<
	localparam rbc_all_tx_sh_location = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_tx_idwidth == "width_66")) ? ("lsb")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_tx_idwidth == "width_67")) ? ("lsb") : "msb";
	localparam rbc_any_tx_sh_location = ((fnl_prot_mode == "teng_baser_mode") || (fnl_prot_mode == "teng_1588_mode") || (fnl_prot_mode == "test_prp_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_tx_idwidth == "width_66")) ? ("lsb")
		 : ((fnl_prot_mode == "interlaken_mode") || (fnl_prot_mode == "basic_mode" && fnl_gb_tx_idwidth == "width_67")) ? ("lsb") : "msb";
	localparam fnl_tx_sh_location = (tx_sh_location == "<auto_any>" || tx_sh_location == "<auto_single>") ? rbc_any_tx_sh_location : tx_sh_location;

	// empty_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_empty_flag_type = "empty_rd_side";
	localparam rbc_any_empty_flag_type = "empty_rd_side";
	localparam fnl_empty_flag_type = (empty_flag_type == "<auto_any>" || empty_flag_type == "<auto_single>") ? rbc_any_empty_flag_type : empty_flag_type;

	// pfull_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_pfull_flag_type = "pfull_wr_side";
	localparam rbc_any_pfull_flag_type = "pfull_wr_side";
	localparam fnl_pfull_flag_type = (pfull_flag_type == "<auto_any>" || pfull_flag_type == "<auto_single>") ? rbc_any_pfull_flag_type : pfull_flag_type;

	// full_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_full_flag_type = "full_wr_side";
	localparam rbc_any_full_flag_type = "full_wr_side";
	localparam fnl_full_flag_type = (full_flag_type == "<auto_any>" || full_flag_type == "<auto_single>") ? rbc_any_full_flag_type : full_flag_type;

	// pempty_flag_type, RBC-validated >> REVE <<
	localparam rbc_all_pempty_flag_type = "pempty_rd_side";
	localparam rbc_any_pempty_flag_type = "pempty_rd_side";
	localparam fnl_pempty_flag_type = (pempty_flag_type == "<auto_any>" || pempty_flag_type == "<auto_single>") ? rbc_any_pempty_flag_type : pempty_flag_type;

	// fifo_stop_rd, RBC-validated >> REVE <<
	localparam rbc_all_fifo_stop_rd = (fnl_prot_mode == "interlaken_mode" && fnl_ctrl_plane_bonding != "individual") ? ("rd_empty") : "n_rd_empty";
	localparam rbc_any_fifo_stop_rd = (fnl_prot_mode == "interlaken_mode" && fnl_ctrl_plane_bonding != "individual") ? ("rd_empty") : "n_rd_empty";
	localparam fnl_fifo_stop_rd = (fifo_stop_rd == "<auto_any>" || fifo_stop_rd == "<auto_single>") ? rbc_any_fifo_stop_rd : fifo_stop_rd;

	// fifo_stop_wr, RBC-validated >> REVE <<
	localparam rbc_all_fifo_stop_wr = "n_wr_full";
	localparam rbc_any_fifo_stop_wr = "n_wr_full";
	localparam fnl_fifo_stop_wr = (fifo_stop_wr == "<auto_any>" || fifo_stop_wr == "<auto_single>") ? rbc_any_fifo_stop_wr : fifo_stop_wr;

	// phcomp_rd_del, RBC-validated >> REVE <<
	localparam rbc_all_phcomp_rd_del = (fnl_txfifo_mode == "phase_comp") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(phcomp_rd_del5,phcomp_rd_del4,phcomp_rd_del3,phcomp_rd_del2,phcomp_rd_del1)")
			 : (fnl_gb_tx_odwidth == fnl_gb_tx_idwidth) ? ("phcomp_rd_del2") : "phcomp_rd_del3"
		) : "phcomp_rd_del3";
	localparam rbc_any_phcomp_rd_del = (fnl_txfifo_mode == "phase_comp") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("phcomp_rd_del1")
			 : (fnl_gb_tx_odwidth == fnl_gb_tx_idwidth) ? ("phcomp_rd_del2") : "phcomp_rd_del3"
		) : "phcomp_rd_del3";
	localparam fnl_phcomp_rd_del = (phcomp_rd_del == "<auto_any>" || phcomp_rd_del == "<auto_single>") ? rbc_any_phcomp_rd_del : phcomp_rd_del;

	// tx_true_b2b, RBC-validated >> REVE <<
	localparam rbc_all_tx_true_b2b = (fnl_txfifo_mode == "clk_comp") ? ("(b2b,single)") : "b2b";
	localparam rbc_any_tx_true_b2b = (fnl_txfifo_mode == "clk_comp") ? ("b2b") : "b2b";
	localparam fnl_tx_true_b2b = (tx_true_b2b == "<auto_any>" || tx_true_b2b == "<auto_single>") ? rbc_any_tx_true_b2b : tx_true_b2b;

	// frmgen_pyld_ins, RBC-validated >> REVE <<
	localparam rbc_all_frmgen_pyld_ins = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(frmgen_pyld_ins_en,frmgen_pyld_ins_dis)") : "frmgen_pyld_ins_dis"
		) : "frmgen_pyld_ins_dis";
	localparam rbc_any_frmgen_pyld_ins = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("frmgen_pyld_ins_dis") : "frmgen_pyld_ins_dis"
		) : "frmgen_pyld_ins_dis";
	localparam fnl_frmgen_pyld_ins = (frmgen_pyld_ins == "<auto_any>" || frmgen_pyld_ins == "<auto_single>") ? rbc_any_frmgen_pyld_ins : frmgen_pyld_ins;

	// frmgen_wordslip, RBC-validated >> REVE <<
	localparam rbc_all_frmgen_wordslip = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(frmgen_wordslip_en,frmgen_wordslip_dis)") : "frmgen_wordslip_dis"
		) : "frmgen_wordslip_dis";
	localparam rbc_any_frmgen_wordslip = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("frmgen_wordslip_dis") : "frmgen_wordslip_dis"
		) : "frmgen_wordslip_dis";
	localparam fnl_frmgen_wordslip = (frmgen_wordslip == "<auto_any>" || frmgen_wordslip == "<auto_single>") ? rbc_any_frmgen_wordslip : frmgen_wordslip;

	// frmgen_burst, RBC-validated >> REVE <<
	localparam rbc_all_frmgen_burst = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(frmgen_burst_en,frmgen_burst_dis)") : "(frmgen_burst_en,frmgen_burst_dis)"
		) : "frmgen_burst_dis";
	localparam rbc_any_frmgen_burst = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("frmgen_burst_dis") : "frmgen_burst_dis"
		) : "frmgen_burst_dis";
	localparam fnl_frmgen_burst = (frmgen_burst == "<auto_any>" || frmgen_burst == "<auto_single>") ? rbc_any_frmgen_burst : frmgen_burst;

	// frmgen_mfrm_length, RBC-validated >> REVE <<
	// Akrzesin: Rule removed for production.
   localparam rbc_all_frmgen_mfrm_length = "mfrm_user_length";
   localparam rbc_any_frmgen_mfrm_length = "mfrm_user_length";
   localparam fnl_frmgen_mfrm_length = (frmgen_mfrm_length == "<auto_any>" || frmgen_mfrm_length == "<auto_single>") ? rbc_any_frmgen_mfrm_length : frmgen_mfrm_length;
   

	// frmgen_pipeln, RBC-validated >> REVE <<
	localparam rbc_all_frmgen_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(frmgen_pipeln_en,frmgen_pipeln_dis)") : "frmgen_pipeln_en"
		) : "frmgen_pipeln_en";
	localparam rbc_any_frmgen_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("frmgen_pipeln_dis") : "frmgen_pipeln_en"
		) : "frmgen_pipeln_en";
	localparam fnl_frmgen_pipeln = (frmgen_pipeln == "<auto_any>" || frmgen_pipeln == "<auto_single>") ? rbc_any_frmgen_pipeln : frmgen_pipeln;

	// crcgen_inv, RBC-validated >> REVE <<
	localparam rbc_all_crcgen_inv = (fnl_prot_mode == "interlaken_mode") ? ("crcgen_inv_en") : "crcgen_inv_en";
	localparam rbc_any_crcgen_inv = (fnl_prot_mode == "interlaken_mode") ? ("crcgen_inv_en") : "crcgen_inv_en";
	localparam fnl_crcgen_inv = (crcgen_inv == "<auto_any>" || crcgen_inv == "<auto_single>") ? rbc_any_crcgen_inv : crcgen_inv;

	// crcgen_err, RBC-validated >> REVE <<
	localparam rbc_all_crcgen_err = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(crcgen_err_dis,crcgen_err_en)") : "crcgen_err_dis"
		) : "crcgen_err_dis";
	localparam rbc_any_crcgen_err = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("crcgen_err_dis") : "crcgen_err_dis"
		) : "crcgen_err_dis";
	localparam fnl_crcgen_err = (crcgen_err == "<auto_any>" || crcgen_err == "<auto_single>") ? rbc_any_crcgen_err : crcgen_err;

	// tx_sm_pipeln, RBC-validated >> REVE <<
	localparam rbc_all_tx_sm_pipeln = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(tx_sm_pipeln_en,tx_sm_pipeln_dis)") : "tx_sm_pipeln_en"
		) : "tx_sm_pipeln_en";
	localparam rbc_any_tx_sm_pipeln = (fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("tx_sm_pipeln_dis") : "tx_sm_pipeln_en"
		) : "tx_sm_pipeln_en";
	localparam fnl_tx_sm_pipeln = (tx_sm_pipeln == "<auto_any>" || tx_sm_pipeln == "<auto_single>") ? rbc_any_tx_sm_pipeln : tx_sm_pipeln;

	// sh_err, RBC-validated >> REVE <<
	localparam rbc_all_sh_err = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("(sh_err_en,sh_err_dis)") : "sh_err_dis";
	localparam rbc_any_sh_err = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("sh_err_dis") : "sh_err_dis";
	localparam fnl_sh_err = (sh_err == "<auto_any>" || sh_err == "<auto_single>") ? rbc_any_sh_err : sh_err;

	// dispgen_err, RBC-validated >> REVE <<
	localparam rbc_all_dispgen_err = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(dispgen_err_dis,dispgen_err_en)") : "dispgen_err_dis"
		) : "dispgen_err_dis";
	localparam rbc_any_dispgen_err = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("dispgen_err_dis") : "dispgen_err_dis"
		) : "dispgen_err_dis";
	localparam fnl_dispgen_err = (dispgen_err == "<auto_any>" || dispgen_err == "<auto_single>") ? rbc_any_dispgen_err : dispgen_err;

	// dispgen_pipeln, RBC-validated >> REVE <<
	localparam rbc_all_dispgen_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(dispgen_pipeln_en,dispgen_pipeln_dis)") : "dispgen_pipeln_dis"
		) : "dispgen_pipeln_dis";
	localparam rbc_any_dispgen_pipeln = (fnl_prot_mode == "interlaken_mode") ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("dispgen_pipeln_dis") : "dispgen_pipeln_dis"
		) : "dispgen_pipeln_dis";
	localparam fnl_dispgen_pipeln = (dispgen_pipeln == "<auto_any>" || dispgen_pipeln == "<auto_single>") ? rbc_any_dispgen_pipeln : dispgen_pipeln;

	// scrm_mode, RBC-validated >> REVE <<
	localparam rbc_all_scrm_mode = (fnl_prot_mode == "interlaken_mode") ? ("sync") : "async";
	localparam rbc_any_scrm_mode = (fnl_prot_mode == "interlaken_mode") ? ("sync") : "async";
	localparam fnl_scrm_mode = (scrm_mode == "<auto_any>" || scrm_mode == "<auto_single>") ? rbc_any_scrm_mode : scrm_mode;

	// scrm_seed, RBC-validated >> REVE <<
	// Akrzesin: Rule removed for production
   localparam rbc_all_scrm_seed = "scram_seed_user_setting";
   localparam rbc_any_scrm_seed = "scram_seed_user_setting";
   localparam fnl_scrm_seed = (scrm_seed == "<auto_any>" || scrm_seed == "<auto_single>") ? rbc_any_scrm_seed : scrm_seed;

	// tx_scrm_err, RBC-validated >> REVE <<
	localparam rbc_all_tx_scrm_err = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode" || (fnl_prot_mode == "basic_mode" && fnl_scrm_bypass == "scrm_bypass_dis")) ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("(scrm_err_en,scrm_err_dis)") : "scrm_err_dis"
		) : "scrm_err_dis";
	localparam rbc_any_tx_scrm_err = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode" || (fnl_prot_mode == "basic_mode" && fnl_scrm_bypass == "scrm_bypass_dis")) ?
		(
			(fnl_sup_mode == "engineering_mode") ? ("scrm_err_dis") : "scrm_err_dis"
		) : "scrm_err_dis";
	localparam fnl_tx_scrm_err = (tx_scrm_err == "<auto_any>" || tx_scrm_err == "<auto_single>") ? rbc_any_tx_scrm_err : tx_scrm_err;

	// tx_scrm_width, RBC-validated >> REVE <<
	localparam rbc_all_tx_scrm_width = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("bit64")
		 : (fnl_prot_mode == "basic_mode" && fnl_scrm_bypass == "scrm_bypass_dis") ?
			(
				(fnl_gb_tx_idwidth == "width_67") ? ("(bit67,bit64)")
				 : (fnl_gb_tx_idwidth == "width_66") ? ("(bit66,bit64)") : "(bit64,bit66,bit67)"
			) : "bit64";
	localparam rbc_any_tx_scrm_width = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "teng_baser_mode" || fnl_prot_mode == "teng_1588_mode") ? ("bit64")
		 : (fnl_prot_mode == "basic_mode" && fnl_scrm_bypass == "scrm_bypass_dis") ?
			(
				(fnl_gb_tx_idwidth == "width_67") ? ("bit64")
				 : (fnl_gb_tx_idwidth == "width_66") ? ("bit64") : "bit64"
			) : "bit64";
	localparam fnl_tx_scrm_width = (tx_scrm_width == "<auto_any>" || tx_scrm_width == "<auto_single>") ? rbc_any_tx_scrm_width : tx_scrm_width;

	// gb_sel_mode, RBC-validated >> REVE <<
	localparam rbc_all_gb_sel_mode = ((fnl_prot_mode == "teng_sdi_mode") && (fnl_sup_mode == "engineering_mode")) ? ("(internal,external)") : "internal";
	localparam rbc_any_gb_sel_mode = ((fnl_prot_mode == "teng_sdi_mode") && (fnl_sup_mode == "engineering_mode")) ? ("internal") : "internal";
	localparam fnl_gb_sel_mode = (gb_sel_mode == "<auto_any>" || gb_sel_mode == "<auto_single>") ? rbc_any_gb_sel_mode : gb_sel_mode;

	// test_mode, RBC-validated >> REVE <<
	localparam rbc_all_test_mode = (fnl_prot_mode == "test_prbs_mode") ? ("(prbs_31,prbs_23,prbs_9,prbs_7)")
		 : (fnl_prot_mode == "test_prp_mode") ? ("pseudo_random")
			 : (fnl_prot_mode == "test_rpg_mode") ? ("sq_wave") : "test_off";
	localparam rbc_any_test_mode = (fnl_prot_mode == "test_prbs_mode") ? ("prbs_31")
		 : (fnl_prot_mode == "test_prp_mode") ? ("pseudo_random")
			 : (fnl_prot_mode == "test_rpg_mode") ? ("sq_wave") : "test_off";
	localparam fnl_test_mode = (test_mode == "<auto_any>" || test_mode == "<auto_single>") ? rbc_any_test_mode : test_mode;

	// pseudo_random, RBC-validated >> REVE <<
	localparam rbc_all_pseudo_random = (fnl_test_mode == "pseudo_random") ? ("(all_0,two_lf)") : "all_0";
	localparam rbc_any_pseudo_random = (fnl_test_mode == "pseudo_random") ? ("all_0") : "all_0";
	localparam fnl_pseudo_random = (pseudo_random == "<auto_any>" || pseudo_random == "<auto_single>") ? rbc_any_pseudo_random : pseudo_random;

	// sq_wave, RBC-validated >> REVE <<
	localparam rbc_all_sq_wave = (fnl_test_mode == "sq_wave") ?
		(
			((fnl_gb_tx_odwidth == "width_32")) ? ("(sq_wave_1,sq_wave_4,sq_wave_6,sq_wave_8)")
			 : ((fnl_gb_tx_odwidth == "width_40")) ? ("(sq_wave_1,sq_wave_4,sq_wave_5,sq_wave_6,sq_wave_8,sq_wave_10)")
				 : ((fnl_gb_tx_odwidth == "width_64")) ? ("(sq_wave_1,sq_wave_4,sq_wave_6,sq_wave_8)") : "sq_wave_4"
		) : "sq_wave_4";
	localparam rbc_any_sq_wave = (fnl_test_mode == "sq_wave") ?
		(
			((fnl_gb_tx_odwidth == "width_32")) ? ("sq_wave_4")
			 : ((fnl_gb_tx_odwidth == "width_40")) ? ("sq_wave_4")
				 : ((fnl_gb_tx_odwidth == "width_64")) ? ("sq_wave_4") : "sq_wave_4"
		) : "sq_wave_4";
	localparam fnl_sq_wave = (sq_wave == "<auto_any>" || sq_wave == "<auto_single>") ? rbc_any_sq_wave : sq_wave;

	// bitslip_en, RBC-validated >> REVE <<
	localparam rbc_all_bitslip_en = (fnl_prot_mode == "interlaken_mode") ?
		(
			((fnl_sup_mode == "engineering_mode")) ? ("(bitslip_dis,bitslip_en)") : "bitslip_dis"
		)
		 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "basic_mode") ? ("(bitslip_dis,bitslip_en)") : "bitslip_dis";
	localparam rbc_any_bitslip_en = (fnl_prot_mode == "interlaken_mode") ?
		(
			((fnl_sup_mode == "engineering_mode")) ? ("bitslip_dis") : "bitslip_dis"
		)
		 : (fnl_prot_mode == "sfis_mode" || fnl_prot_mode == "basic_mode") ? ("bitslip_dis") : "bitslip_dis";
	localparam fnl_bitslip_en = (bitslip_en == "<auto_any>" || bitslip_en == "<auto_single>") ? rbc_any_bitslip_en : bitslip_en;

	// distdwn_bypass_pipeln, RBC-validated >> REVE <<
	localparam rbc_all_distdwn_bypass_pipeln = "distdwn_bypass_pipeln_dis";
	localparam rbc_any_distdwn_bypass_pipeln = "distdwn_bypass_pipeln_dis";
	localparam fnl_distdwn_bypass_pipeln = (distdwn_bypass_pipeln == "<auto_any>" || distdwn_bypass_pipeln == "<auto_single>") ? rbc_any_distdwn_bypass_pipeln : distdwn_bypass_pipeln;

	// distup_bypass_pipeln, RBC-validated >> REVE <<
	localparam rbc_all_distup_bypass_pipeln = "distup_bypass_pipeln_dis";
	localparam rbc_any_distup_bypass_pipeln = "distup_bypass_pipeln_dis";
	localparam fnl_distup_bypass_pipeln = (distup_bypass_pipeln == "<auto_any>" || distup_bypass_pipeln == "<auto_single>") ? rbc_any_distup_bypass_pipeln : distup_bypass_pipeln;

	// distdwn_master, RBC-validated >> REVE <<
	localparam rbc_all_distdwn_master = (fnl_ctrl_plane_bonding == "individual") ? ("distdwn_master_en")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distdwn_master_en")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distdwn_master_dis") : "distdwn_master_dis";
	localparam rbc_any_distdwn_master = (fnl_ctrl_plane_bonding == "individual") ? ("distdwn_master_en")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distdwn_master_en")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distdwn_master_dis") : "distdwn_master_dis";
	localparam fnl_distdwn_master = (distdwn_master == "<auto_any>" || distdwn_master == "<auto_single>") ? rbc_any_distdwn_master : distdwn_master;

	// comp_cnt, RBC-validated >> REVE <<
	localparam rbc_all_comp_cnt = (fnl_ctrl_plane_bonding == "individual") ? ("comp_cnt_00")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("(comp_cnt_02,comp_cnt_04,comp_cnt_06,comp_cnt_08,comp_cnt_0a,comp_cnt_0c,comp_cnt_0e,comp_cnt_10,comp_cnt_12,comp_cnt_14,comp_cnt_16,comp_cnt_18,comp_cnt_1a,comp_cnt_1c,comp_cnt_1e,comp_cnt_20,comp_cnt_22,comp_cnt_24,comp_cnt_26)")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("(comp_cnt_00,comp_cnt_02,comp_cnt_04,comp_cnt_06,comp_cnt_08,comp_cnt_0a,comp_cnt_0c,comp_cnt_0e,comp_cnt_10,comp_cnt_12,comp_cnt_14,comp_cnt_16,comp_cnt_18,comp_cnt_1a,comp_cnt_1c,comp_cnt_1e,comp_cnt_20,comp_cnt_22,comp_cnt_24,comp_cnt_26)") : "(comp_cnt_00,comp_cnt_02,comp_cnt_04,comp_cnt_06,comp_cnt_08,comp_cnt_0a,comp_cnt_0c,comp_cnt_0e,comp_cnt_10,comp_cnt_12,comp_cnt_14,comp_cnt_16,comp_cnt_18,comp_cnt_1a,comp_cnt_1c,comp_cnt_1e,comp_cnt_20,comp_cnt_22,comp_cnt_24,comp_cnt_26)";
	localparam rbc_any_comp_cnt = (fnl_ctrl_plane_bonding == "individual") ? ("comp_cnt_00")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("comp_cnt_02")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("comp_cnt_00") : "comp_cnt_00";
	localparam fnl_comp_cnt = (comp_cnt == "<auto_any>" || comp_cnt == "<auto_single>") ? rbc_any_comp_cnt : comp_cnt;

	// indv, RBC-validated >> REVE <<
	localparam rbc_all_indv = (fnl_ctrl_plane_bonding == "individual") ? ("indv_en")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("indv_dis")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("indv_dis") : "indv_dis";
	localparam rbc_any_indv = (fnl_ctrl_plane_bonding == "individual") ? ("indv_en")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("indv_dis")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("indv_dis") : "indv_dis";
	localparam fnl_indv = (indv == "<auto_any>" || indv == "<auto_single>") ? rbc_any_indv : indv;

	// compin_sel, RBC-validated >> REVE <<
	localparam rbc_all_compin_sel = (fnl_ctrl_plane_bonding == "individual") ? ("compin_master")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("compin_master")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("compin_slave_bot") : "compin_slave_top";
	localparam rbc_any_compin_sel = (fnl_ctrl_plane_bonding == "individual") ? ("compin_master")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("compin_master")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("compin_slave_bot") : "compin_slave_top";
	localparam fnl_compin_sel = (compin_sel == "<auto_any>" || compin_sel == "<auto_single>") ? rbc_any_compin_sel : compin_sel;

	// distup_master, RBC-validated >> REVE <<
	localparam rbc_all_distup_master = (fnl_ctrl_plane_bonding == "individual") ? ("distup_master_en")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distup_master_en")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distup_master_dis") : "distup_master_dis";
	localparam rbc_any_distup_master = (fnl_ctrl_plane_bonding == "individual") ? ("distup_master_en")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distup_master_en")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distup_master_dis") : "distup_master_dis";
	localparam fnl_distup_master = (distup_master == "<auto_any>" || distup_master == "<auto_single>") ? rbc_any_distup_master : distup_master;

	// distdwn_master_agg, RBC-validated >> REVE <<
	localparam rbc_all_distdwn_master_agg = (fnl_data_agg_bonding == "agg_individual") ? ("distdwn_master_agg_en")
		 : (fnl_data_agg_bonding == "agg_master") ? ("distdwn_master_agg_en")
			 : (fnl_data_agg_bonding == "agg_slave_blw") ? ("distdwn_master_agg_dis") : "distdwn_master_agg_dis";
	localparam rbc_any_distdwn_master_agg = (fnl_data_agg_bonding == "agg_individual") ? ("distdwn_master_agg_en")
		 : (fnl_data_agg_bonding == "agg_master") ? ("distdwn_master_agg_en")
			 : (fnl_data_agg_bonding == "agg_slave_blw") ? ("distdwn_master_agg_dis") : "distdwn_master_agg_dis";
	localparam fnl_distdwn_master_agg = (distdwn_master_agg == "<auto_any>" || distdwn_master_agg == "<auto_single>") ? rbc_any_distdwn_master_agg : distdwn_master_agg;

	// distup_master_agg, RBC-validated >> REVE <<
	localparam rbc_all_distup_master_agg = (fnl_data_agg_bonding == "agg_individual") ? ("distup_master_agg_en")
		 : (fnl_data_agg_bonding == "agg_master") ? ("distup_master_agg_en")
			 : (fnl_data_agg_bonding == "agg_slave_blw") ? ("distup_master_agg_dis") : "distup_master_agg_dis";
	localparam rbc_any_distup_master_agg = (fnl_data_agg_bonding == "agg_individual") ? ("distup_master_agg_en")
		 : (fnl_data_agg_bonding == "agg_master") ? ("distup_master_agg_en")
			 : (fnl_data_agg_bonding == "agg_slave_blw") ? ("distup_master_agg_dis") : "distup_master_agg_dis";
	localparam fnl_distup_master_agg = (distup_master_agg == "<auto_any>" || distup_master_agg == "<auto_single>") ? rbc_any_distup_master_agg : distup_master_agg;

	// distup_bypass_pipeln_agg, RBC-validated >> REVE <<
	localparam rbc_all_distup_bypass_pipeln_agg = (fnl_ctrl_plane_bonding == "individual" || fnl_prot_mode != "interlaken_mode") ? ("distup_bypass_pipeln_agg_dis")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distup_bypass_pipeln_agg_dis")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distup_bypass_pipeln_agg_dis") : "(distup_bypass_pipeln_agg_dis,distup_bypass_pipeln_agg_en)";
	localparam rbc_any_distup_bypass_pipeln_agg = (fnl_ctrl_plane_bonding == "individual" || fnl_prot_mode != "interlaken_mode") ? ("distup_bypass_pipeln_agg_dis")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distup_bypass_pipeln_agg_dis")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distup_bypass_pipeln_agg_dis") : "distup_bypass_pipeln_agg_dis";
	localparam fnl_distup_bypass_pipeln_agg = (distup_bypass_pipeln_agg == "<auto_any>" || distup_bypass_pipeln_agg == "<auto_single>") ? rbc_any_distup_bypass_pipeln_agg : distup_bypass_pipeln_agg;

	// data_agg_comp, RBC-validated >> REVE <<
	localparam rbc_all_data_agg_comp = (fnl_data_agg_bonding == "agg_individual") ? ("data_agg_del0")
		 : (fnl_data_agg_bonding == "agg_master") ? ("(data_agg_del0,data_agg_del1,data_agg_del2,data_agg_del3,data_agg_del4,data_agg_del5,data_agg_del6,data_agg_del7,data_agg_del8)")
			 : (fnl_data_agg_bonding == "agg_slave_blw") ? ("(data_agg_del0,data_agg_del1,data_agg_del2,data_agg_del3,data_agg_del4,data_agg_del5,data_agg_del6,data_agg_del7,data_agg_del8)") : "(data_agg_del0,data_agg_del1,data_agg_del2,data_agg_del3,data_agg_del4,data_agg_del5,data_agg_del6,data_agg_del7,data_agg_del8)";
	localparam rbc_any_data_agg_comp = (fnl_data_agg_bonding == "agg_individual") ? ("data_agg_del0")
		 : (fnl_data_agg_bonding == "agg_master") ? ("data_agg_del0")
			 : (fnl_data_agg_bonding == "agg_slave_blw") ? ("data_agg_del0") : "data_agg_del0";
	localparam fnl_data_agg_comp = (data_agg_comp == "<auto_any>" || data_agg_comp == "<auto_single>") ? rbc_any_data_agg_comp : data_agg_comp;

	// compin_sel_agg, RBC-validated >> REVE <<
	localparam rbc_all_compin_sel_agg = (fnl_data_agg_bonding == "agg_individual") ? ("compin_agg_master")
		 : (fnl_data_agg_bonding == "agg_master") ? ("compin_agg_master")
			 : (fnl_data_agg_bonding == "agg_slave_blw") ? ("compin_agg_slave_bot") : "compin_agg_slave_top";
	localparam rbc_any_compin_sel_agg = (fnl_data_agg_bonding == "agg_individual") ? ("compin_agg_master")
		 : (fnl_data_agg_bonding == "agg_master") ? ("compin_agg_master")
			 : (fnl_data_agg_bonding == "agg_slave_blw") ? ("compin_agg_slave_bot") : "compin_agg_slave_top";
	localparam fnl_compin_sel_agg = (compin_sel_agg == "<auto_any>" || compin_sel_agg == "<auto_single>") ? rbc_any_compin_sel_agg : compin_sel_agg;

	// comp_del_sel_agg, RBC-validated >> REVE <<
	localparam rbc_all_comp_del_sel_agg = (fnl_ctrl_plane_bonding == "individual" || fnl_prot_mode != "interlaken_mode") ? ("data_agg_del0")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("(data_agg_del0,data_agg_del1,data_agg_del2,data_agg_del3,data_agg_del4,data_agg_del5,data_agg_del6,data_agg_del7,data_agg_del8)")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("(data_agg_del0,data_agg_del1,data_agg_del2,data_agg_del3,data_agg_del4,data_agg_del5,data_agg_del6,data_agg_del7,data_agg_del8)") : "(data_agg_del0,data_agg_del1,data_agg_del2,data_agg_del3,data_agg_del4,data_agg_del5,data_agg_del6,data_agg_del7,data_agg_del8)";
	localparam rbc_any_comp_del_sel_agg = (fnl_ctrl_plane_bonding == "individual" || fnl_prot_mode != "interlaken_mode") ? ("data_agg_del0")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("data_agg_del0")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("data_agg_del0") : "data_agg_del0";
	localparam fnl_comp_del_sel_agg = (comp_del_sel_agg == "<auto_any>" || comp_del_sel_agg == "<auto_single>") ? rbc_any_comp_del_sel_agg : comp_del_sel_agg;

	// distdwn_bypass_pipeln_agg, RBC-validated >> REVE <<
	localparam rbc_all_distdwn_bypass_pipeln_agg = (fnl_ctrl_plane_bonding == "individual" || fnl_prot_mode != "interlaken_mode") ? ("distdwn_bypass_pipeln_agg_dis")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distdwn_bypass_pipeln_agg_dis")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("(distdwn_bypass_pipeln_agg_dis,distdwn_bypass_pipeln_agg_en)") : "distdwn_bypass_pipeln_agg_dis";
	localparam rbc_any_distdwn_bypass_pipeln_agg = (fnl_ctrl_plane_bonding == "individual" || fnl_prot_mode != "interlaken_mode") ? ("distdwn_bypass_pipeln_agg_dis")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("distdwn_bypass_pipeln_agg_dis")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("distdwn_bypass_pipeln_agg_dis") : "distdwn_bypass_pipeln_agg_dis";
	localparam fnl_distdwn_bypass_pipeln_agg = (distdwn_bypass_pipeln_agg == "<auto_any>" || distdwn_bypass_pipeln_agg == "<auto_single>") ? rbc_any_distdwn_bypass_pipeln_agg : distdwn_bypass_pipeln_agg;

	// stretch_en, RBC-validated >> REVE <<
	localparam rbc_all_stretch_en = (fnl_sup_mode == "engineering_mode") ? ("(stretch_en,stretch_dis)") : "stretch_en";
	localparam rbc_any_stretch_en = (fnl_sup_mode == "engineering_mode") ? ("stretch_en") : "stretch_en";
	localparam fnl_stretch_en = (stretch_en == "<auto_any>" || stretch_en == "<auto_single>") ? rbc_any_stretch_en : stretch_en;

	// stretch_type, RBC-validated >> REVE <<
	localparam rbc_all_stretch_type = (fnl_sup_mode == "engineering_mode") ? ("(stretch_custom,stretch_auto)") : "stretch_auto";
	localparam rbc_any_stretch_type = (fnl_sup_mode == "engineering_mode") ? ("stretch_auto") : "stretch_auto";
	localparam fnl_stretch_type = (stretch_type == "<auto_any>" || stretch_type == "<auto_single>") ? rbc_any_stretch_type : stretch_type;

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
	localparam rbc_all_iqtxrx_clkout_sel = (fnl_sup_mode == "engineering_mode") ? ("(iq_tx_pma_clk,iq_tx_pma_clk_div33)") : "iq_tx_pma_clk";
	localparam rbc_any_iqtxrx_clkout_sel = (fnl_sup_mode == "engineering_mode") ? ("iq_tx_pma_clk") : "iq_tx_pma_clk";
	localparam fnl_iqtxrx_clkout_sel = (iqtxrx_clkout_sel == "<auto_any>" || iqtxrx_clkout_sel == "<auto_single>") ? rbc_any_iqtxrx_clkout_sel : iqtxrx_clkout_sel;

	// tx_testbus_sel, RBC-validated >> REVE <<
	localparam rbc_all_tx_testbus_sel = (fnl_prot_mode == "disable_mode") ? ("tx_fifo_testbus1") : "(crc32_gen_testbus1,crc32_gen_testbus2,disp_gen_testbus1,disp_gen_testbus2,frame_gen_testbus1,frame_gen_testbus2,enc64b66b_testbus,txsm_testbus,tx_cp_bond_testbus,prbs_gen_xg_testbus,gearbox_red_testbus,tx_da_bond_testbus,scramble_testbus,blank_testbus,tx_fifo_testbus1,tx_fifo_testbus2)";
	localparam rbc_any_tx_testbus_sel = (fnl_prot_mode == "disable_mode") ? ("tx_fifo_testbus1") : "crc32_gen_testbus1";
	localparam fnl_tx_testbus_sel = (tx_testbus_sel == "<auto_any>" || tx_testbus_sel == "<auto_single>") ? rbc_any_tx_testbus_sel : tx_testbus_sel;

	// tx_polarity_inv, RBC-validated >> REVE <<
	localparam rbc_all_tx_polarity_inv = (fnl_prot_mode == "disable_mode") ? ("invert_disable") : "(invert_disable,invert_enable)";
	localparam rbc_any_tx_polarity_inv = (fnl_prot_mode == "disable_mode") ? ("invert_disable") : "invert_disable";
	localparam fnl_tx_polarity_inv = (tx_polarity_inv == "<auto_any>" || tx_polarity_inv == "<auto_single>") ? rbc_any_tx_polarity_inv : tx_polarity_inv;

	// pmagate_en, RBC-validated >> REVE <<
	localparam rbc_all_pmagate_en = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "disable_mode") ? ("pmagate_dis") : "(pmagate_en,pmagate_dis)";
	localparam rbc_any_pmagate_en = (fnl_prot_mode == "interlaken_mode" || fnl_prot_mode == "disable_mode") ? ("pmagate_dis") : "pmagate_dis";
	localparam fnl_pmagate_en = (pmagate_en == "<auto_any>" || pmagate_en == "<auto_single>") ? rbc_any_pmagate_en : pmagate_en;

         //========================REVE RULES END ==============================================================================

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
		//$display("comp_del_sel_agg = orig: '%s', any:'%s', all:'%s', final: '%s'", comp_del_sel_agg, rbc_any_comp_del_sel_agg, rbc_all_comp_del_sel_agg, fnl_comp_del_sel_agg);
		if (!is_in_legal_set(comp_del_sel_agg, rbc_all_comp_del_sel_agg)) begin
			$display("Critical Warning: parameter 'comp_del_sel_agg' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", comp_del_sel_agg, rbc_all_comp_del_sel_agg, fnl_comp_del_sel_agg);
		end
		//$display("crcgen_init = orig: '%s', any:'%s', all:'%s', final: '%s'", crcgen_init, rbc_any_crcgen_init, rbc_all_crcgen_init, fnl_crcgen_init);
		if (!is_in_legal_set(crcgen_init, rbc_all_crcgen_init)) begin
			$display("Critical Warning: parameter 'crcgen_init' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", crcgen_init, rbc_all_crcgen_init, fnl_crcgen_init);
		end
		//$display("frmgen_mfrm_length = orig: '%s', any:'%s', all:'%s', final: '%s'", frmgen_mfrm_length, rbc_any_frmgen_mfrm_length, rbc_all_frmgen_mfrm_length, fnl_frmgen_mfrm_length);
		//if (!is_in_legal_set(frmgen_mfrm_length, rbc_all_frmgen_mfrm_length)) begin
		//	$display("Critical Warning: parameter 'frmgen_mfrm_length' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", frmgen_mfrm_length, rbc_all_frmgen_mfrm_length, fnl_frmgen_mfrm_length);
		//end
		//$display("scrm_seed = orig: '%s', any:'%s', all:'%s', final: '%s'", scrm_seed, rbc_any_scrm_seed, rbc_all_scrm_seed, fnl_scrm_seed);
		//if (!is_in_legal_set(scrm_seed, rbc_all_scrm_seed)) begin
		//	$display("Critical Warning: parameter 'scrm_seed' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", scrm_seed, rbc_all_scrm_seed, fnl_scrm_seed);
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
		//$display("gb_tx_odwidth = orig: '%s', any:'%s', all:'%s', final: '%s'", gb_tx_odwidth, rbc_any_gb_tx_odwidth, rbc_all_gb_tx_odwidth, fnl_gb_tx_odwidth);
		if (!is_in_legal_set(gb_tx_odwidth, rbc_all_gb_tx_odwidth)) begin
			$display("Critical Warning: parameter 'gb_tx_odwidth' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", gb_tx_odwidth, rbc_all_gb_tx_odwidth, fnl_gb_tx_odwidth);
		end
		//$display("gb_tx_idwidth = orig: '%s', any:'%s', all:'%s', final: '%s'", gb_tx_idwidth, rbc_any_gb_tx_idwidth, rbc_all_gb_tx_idwidth, fnl_gb_tx_idwidth);
		if (!is_in_legal_set(gb_tx_idwidth, rbc_all_gb_tx_idwidth)) begin
			$display("Critical Warning: parameter 'gb_tx_idwidth' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", gb_tx_idwidth, rbc_all_gb_tx_idwidth, fnl_gb_tx_idwidth);
		end
		//$display("ctrl_plane_bonding = orig: '%s', any:'%s', all:'%s', final: '%s'", ctrl_plane_bonding, rbc_any_ctrl_plane_bonding, rbc_all_ctrl_plane_bonding, fnl_ctrl_plane_bonding);
		if (!is_in_legal_set(ctrl_plane_bonding, rbc_all_ctrl_plane_bonding)) begin
			$display("Critical Warning: parameter 'ctrl_plane_bonding' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ctrl_plane_bonding, rbc_all_ctrl_plane_bonding, fnl_ctrl_plane_bonding);
		end
		//$display("data_agg_bonding = orig: '%s', any:'%s', all:'%s', final: '%s'", data_agg_bonding, rbc_any_data_agg_bonding, rbc_all_data_agg_bonding, fnl_data_agg_bonding);
		if (!skip_check_data_agg_bonding && !is_in_legal_set(data_agg_bonding, rbc_all_data_agg_bonding)) begin
			$display("Critical Warning: parameter 'data_agg_bonding' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", data_agg_bonding, rbc_all_data_agg_bonding, fnl_data_agg_bonding);
		end
		//$display("master_clk_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", master_clk_sel, rbc_any_master_clk_sel, rbc_all_master_clk_sel, fnl_master_clk_sel);
		if (!is_in_legal_set(master_clk_sel, rbc_all_master_clk_sel)) begin
			$display("Critical Warning: parameter 'master_clk_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", master_clk_sel, rbc_all_master_clk_sel, fnl_master_clk_sel);
		end
		//$display("txfifo_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", txfifo_mode, rbc_any_txfifo_mode, rbc_all_txfifo_mode, fnl_txfifo_mode);
		if (!is_in_legal_set(txfifo_mode, rbc_all_txfifo_mode)) begin
			$display("Critical Warning: parameter 'txfifo_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", txfifo_mode, rbc_all_txfifo_mode, fnl_txfifo_mode);
		end
		//$display("wr_clk_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", wr_clk_sel, rbc_any_wr_clk_sel, rbc_all_wr_clk_sel, fnl_wr_clk_sel);
		if (!is_in_legal_set(wr_clk_sel, rbc_all_wr_clk_sel)) begin
			$display("Critical Warning: parameter 'wr_clk_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", wr_clk_sel, rbc_all_wr_clk_sel, fnl_wr_clk_sel);
		end
		//$display("sqwgen_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", sqwgen_clken, rbc_any_sqwgen_clken, rbc_all_sqwgen_clken, fnl_sqwgen_clken);
		if (!is_in_legal_set(sqwgen_clken, rbc_all_sqwgen_clken)) begin
			$display("Critical Warning: parameter 'sqwgen_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", sqwgen_clken, rbc_all_sqwgen_clken, fnl_sqwgen_clken);
		end
		//$display("wrfifo_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", wrfifo_clken, rbc_any_wrfifo_clken, rbc_all_wrfifo_clken, fnl_wrfifo_clken);
		if (!is_in_legal_set(wrfifo_clken, rbc_all_wrfifo_clken)) begin
			$display("Critical Warning: parameter 'wrfifo_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", wrfifo_clken, rbc_all_wrfifo_clken, fnl_wrfifo_clken);
		end
		//$display("dispgen_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", dispgen_clken, rbc_any_dispgen_clken, rbc_all_dispgen_clken, fnl_dispgen_clken);
		if (!is_in_legal_set(dispgen_clken, rbc_all_dispgen_clken)) begin
			$display("Critical Warning: parameter 'dispgen_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dispgen_clken, rbc_all_dispgen_clken, fnl_dispgen_clken);
		end
		//$display("scrm_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", scrm_clken, rbc_any_scrm_clken, rbc_all_scrm_clken, fnl_scrm_clken);
		if (!is_in_legal_set(scrm_clken, rbc_all_scrm_clken)) begin
			$display("Critical Warning: parameter 'scrm_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", scrm_clken, rbc_all_scrm_clken, fnl_scrm_clken);
		end
		//$display("enc_64b66b_txsm_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", enc_64b66b_txsm_bypass, rbc_any_enc_64b66b_txsm_bypass, rbc_all_enc_64b66b_txsm_bypass, fnl_enc_64b66b_txsm_bypass);
		if (!is_in_legal_set(enc_64b66b_txsm_bypass, rbc_all_enc_64b66b_txsm_bypass)) begin
			$display("Critical Warning: parameter 'enc_64b66b_txsm_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", enc_64b66b_txsm_bypass, rbc_all_enc_64b66b_txsm_bypass, fnl_enc_64b66b_txsm_bypass);
		end
		//$display("dispgen_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", dispgen_bypass, rbc_any_dispgen_bypass, rbc_all_dispgen_bypass, fnl_dispgen_bypass);
		if (!is_in_legal_set(dispgen_bypass, rbc_all_dispgen_bypass)) begin
			$display("Critical Warning: parameter 'dispgen_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dispgen_bypass, rbc_all_dispgen_bypass, fnl_dispgen_bypass);
		end
		//$display("gbred_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", gbred_clken, rbc_any_gbred_clken, rbc_all_gbred_clken, fnl_gbred_clken);
		if (!is_in_legal_set(gbred_clken, rbc_all_gbred_clken)) begin
			$display("Critical Warning: parameter 'gbred_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", gbred_clken, rbc_all_gbred_clken, fnl_gbred_clken);
		end
		//$display("tx_sm_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_sm_bypass, rbc_any_tx_sm_bypass, rbc_all_tx_sm_bypass, fnl_tx_sm_bypass);
		if (!is_in_legal_set(tx_sm_bypass, rbc_all_tx_sm_bypass)) begin
			$display("Critical Warning: parameter 'tx_sm_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_sm_bypass, rbc_all_tx_sm_bypass, fnl_tx_sm_bypass);
		end
		//$display("enc64b66b_txsm_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", enc64b66b_txsm_clken, rbc_any_enc64b66b_txsm_clken, rbc_all_enc64b66b_txsm_clken, fnl_enc64b66b_txsm_clken);
		if (!is_in_legal_set(enc64b66b_txsm_clken, rbc_all_enc64b66b_txsm_clken)) begin
			$display("Critical Warning: parameter 'enc64b66b_txsm_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", enc64b66b_txsm_clken, rbc_all_enc64b66b_txsm_clken, fnl_enc64b66b_txsm_clken);
		end
		//$display("frmgen_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", frmgen_bypass, rbc_any_frmgen_bypass, rbc_all_frmgen_bypass, fnl_frmgen_bypass);
		if (!is_in_legal_set(frmgen_bypass, rbc_all_frmgen_bypass)) begin
			$display("Critical Warning: parameter 'frmgen_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", frmgen_bypass, rbc_all_frmgen_bypass, fnl_frmgen_bypass);
		end
		//$display("crcgen_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", crcgen_clken, rbc_any_crcgen_clken, rbc_all_crcgen_clken, fnl_crcgen_clken);
		if (!is_in_legal_set(crcgen_clken, rbc_all_crcgen_clken)) begin
			$display("Critical Warning: parameter 'crcgen_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", crcgen_clken, rbc_all_crcgen_clken, fnl_crcgen_clken);
		end
		//$display("scrm_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", scrm_bypass, rbc_any_scrm_bypass, rbc_all_scrm_bypass, fnl_scrm_bypass);
		if (!is_in_legal_set(scrm_bypass, rbc_all_scrm_bypass)) begin
			$display("Critical Warning: parameter 'scrm_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", scrm_bypass, rbc_all_scrm_bypass, fnl_scrm_bypass);
		end
		//$display("frmgen_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", frmgen_clken, rbc_any_frmgen_clken, rbc_all_frmgen_clken, fnl_frmgen_clken);
		if (!is_in_legal_set(frmgen_clken, rbc_all_frmgen_clken)) begin
			$display("Critical Warning: parameter 'frmgen_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", frmgen_clken, rbc_all_frmgen_clken, fnl_frmgen_clken);
		end
		//$display("prbs_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", prbs_clken, rbc_any_prbs_clken, rbc_all_prbs_clken, fnl_prbs_clken);
		if (!is_in_legal_set(prbs_clken, rbc_all_prbs_clken)) begin
			$display("Critical Warning: parameter 'prbs_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", prbs_clken, rbc_all_prbs_clken, fnl_prbs_clken);
		end
		//$display("crcgen_bypass = orig: '%s', any:'%s', all:'%s', final: '%s'", crcgen_bypass, rbc_any_crcgen_bypass, rbc_all_crcgen_bypass, fnl_crcgen_bypass);
		if (!is_in_legal_set(crcgen_bypass, rbc_all_crcgen_bypass)) begin
			$display("Critical Warning: parameter 'crcgen_bypass' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", crcgen_bypass, rbc_all_crcgen_bypass, fnl_crcgen_bypass);
		end
		//$display("rdfifo_clken = orig: '%s', any:'%s', all:'%s', final: '%s'", rdfifo_clken, rbc_any_rdfifo_clken, rbc_all_rdfifo_clken, fnl_rdfifo_clken);
		if (!is_in_legal_set(rdfifo_clken, rbc_all_rdfifo_clken)) begin
			$display("Critical Warning: parameter 'rdfifo_clken' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rdfifo_clken, rbc_all_rdfifo_clken, fnl_rdfifo_clken);
		end
		//$display("fastpath = orig: '%s', any:'%s', all:'%s', final: '%s'", fastpath, rbc_any_fastpath, rbc_all_fastpath, fnl_fastpath);
		if (!is_in_legal_set(fastpath, rbc_all_fastpath)) begin
			$display("Critical Warning: parameter 'fastpath' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", fastpath, rbc_all_fastpath, fnl_fastpath);
		end
		//$display("data_bit_reverse = orig: '%s', any:'%s', all:'%s', final: '%s'", data_bit_reverse, rbc_any_data_bit_reverse, rbc_all_data_bit_reverse, fnl_data_bit_reverse);
		if (!skip_check_data_bit_reverse && !is_in_legal_set(data_bit_reverse, rbc_all_data_bit_reverse)) begin
			$display("Critical Warning: parameter 'data_bit_reverse' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", data_bit_reverse, rbc_all_data_bit_reverse, fnl_data_bit_reverse);
		end
		//$display("ctrl_bit_reverse = orig: '%s', any:'%s', all:'%s', final: '%s'", ctrl_bit_reverse, rbc_any_ctrl_bit_reverse, rbc_all_ctrl_bit_reverse, fnl_ctrl_bit_reverse);
		if (!skip_check_ctrl_bit_reverse && !is_in_legal_set(ctrl_bit_reverse, rbc_all_ctrl_bit_reverse)) begin
			$display("Critical Warning: parameter 'ctrl_bit_reverse' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ctrl_bit_reverse, rbc_all_ctrl_bit_reverse, fnl_ctrl_bit_reverse);
		end
		//$display("tx_sh_location = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_sh_location, rbc_any_tx_sh_location, rbc_all_tx_sh_location, fnl_tx_sh_location);
		if (!is_in_legal_set(tx_sh_location, rbc_all_tx_sh_location)) begin
			$display("Critical Warning: parameter 'tx_sh_location' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_sh_location, rbc_all_tx_sh_location, fnl_tx_sh_location);
		end
		//$display("empty_flag_type = orig: '%s', any:'%s', all:'%s', final: '%s'", empty_flag_type, rbc_any_empty_flag_type, rbc_all_empty_flag_type, fnl_empty_flag_type);
		if (!skip_check_empty_flag_type && !is_in_legal_set(empty_flag_type, rbc_all_empty_flag_type)) begin
			$display("Critical Warning: parameter 'empty_flag_type' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", empty_flag_type, rbc_all_empty_flag_type, fnl_empty_flag_type);
		end
		//$display("pfull_flag_type = orig: '%s', any:'%s', all:'%s', final: '%s'", pfull_flag_type, rbc_any_pfull_flag_type, rbc_all_pfull_flag_type, fnl_pfull_flag_type);
		if (!skip_check_pfull_flag_type && !is_in_legal_set(pfull_flag_type, rbc_all_pfull_flag_type)) begin
			$display("Critical Warning: parameter 'pfull_flag_type' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pfull_flag_type, rbc_all_pfull_flag_type, fnl_pfull_flag_type);
		end
		//$display("full_flag_type = orig: '%s', any:'%s', all:'%s', final: '%s'", full_flag_type, rbc_any_full_flag_type, rbc_all_full_flag_type, fnl_full_flag_type);
		if (!skip_check_full_flag_type && !is_in_legal_set(full_flag_type, rbc_all_full_flag_type)) begin
			$display("Critical Warning: parameter 'full_flag_type' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", full_flag_type, rbc_all_full_flag_type, fnl_full_flag_type);
		end
		//$display("pempty_flag_type = orig: '%s', any:'%s', all:'%s', final: '%s'", pempty_flag_type, rbc_any_pempty_flag_type, rbc_all_pempty_flag_type, fnl_pempty_flag_type);
		if (!skip_check_pempty_flag_type && !is_in_legal_set(pempty_flag_type, rbc_all_pempty_flag_type)) begin
			$display("Critical Warning: parameter 'pempty_flag_type' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pempty_flag_type, rbc_all_pempty_flag_type, fnl_pempty_flag_type);
		end
		//$display("fifo_stop_rd = orig: '%s', any:'%s', all:'%s', final: '%s'", fifo_stop_rd, rbc_any_fifo_stop_rd, rbc_all_fifo_stop_rd, fnl_fifo_stop_rd);
		if (!skip_check_fifo_stop_rd && !is_in_legal_set(fifo_stop_rd, rbc_all_fifo_stop_rd)) begin
			$display("Critical Warning: parameter 'fifo_stop_rd' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", fifo_stop_rd, rbc_all_fifo_stop_rd, fnl_fifo_stop_rd);
		end
		//$display("fifo_stop_wr = orig: '%s', any:'%s', all:'%s', final: '%s'", fifo_stop_wr, rbc_any_fifo_stop_wr, rbc_all_fifo_stop_wr, fnl_fifo_stop_wr);
		if (!skip_check_fifo_stop_wr && !is_in_legal_set(fifo_stop_wr, rbc_all_fifo_stop_wr)) begin
			$display("Critical Warning: parameter 'fifo_stop_wr' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", fifo_stop_wr, rbc_all_fifo_stop_wr, fnl_fifo_stop_wr);
		end
		//$display("phcomp_rd_del = orig: '%s', any:'%s', all:'%s', final: '%s'", phcomp_rd_del, rbc_any_phcomp_rd_del, rbc_all_phcomp_rd_del, fnl_phcomp_rd_del);
		if (!is_in_legal_set(phcomp_rd_del, rbc_all_phcomp_rd_del)) begin
			$display("Critical Warning: parameter 'phcomp_rd_del' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", phcomp_rd_del, rbc_all_phcomp_rd_del, fnl_phcomp_rd_del);
		end
		//$display("tx_true_b2b = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_true_b2b, rbc_any_tx_true_b2b, rbc_all_tx_true_b2b, fnl_tx_true_b2b);
		if (!is_in_legal_set(tx_true_b2b, rbc_all_tx_true_b2b)) begin
			$display("Critical Warning: parameter 'tx_true_b2b' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_true_b2b, rbc_all_tx_true_b2b, fnl_tx_true_b2b);
		end
		//$display("frmgen_pyld_ins = orig: '%s', any:'%s', all:'%s', final: '%s'", frmgen_pyld_ins, rbc_any_frmgen_pyld_ins, rbc_all_frmgen_pyld_ins, fnl_frmgen_pyld_ins);
		if (!is_in_legal_set(frmgen_pyld_ins, rbc_all_frmgen_pyld_ins)) begin
			$display("Critical Warning: parameter 'frmgen_pyld_ins' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", frmgen_pyld_ins, rbc_all_frmgen_pyld_ins, fnl_frmgen_pyld_ins);
		end
		//$display("frmgen_wordslip = orig: '%s', any:'%s', all:'%s', final: '%s'", frmgen_wordslip, rbc_any_frmgen_wordslip, rbc_all_frmgen_wordslip, fnl_frmgen_wordslip);
		if (!is_in_legal_set(frmgen_wordslip, rbc_all_frmgen_wordslip)) begin
			$display("Critical Warning: parameter 'frmgen_wordslip' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", frmgen_wordslip, rbc_all_frmgen_wordslip, fnl_frmgen_wordslip);
		end
		//$display("frmgen_burst = orig: '%s', any:'%s', all:'%s', final: '%s'", frmgen_burst, rbc_any_frmgen_burst, rbc_all_frmgen_burst, fnl_frmgen_burst);
		if (!is_in_legal_set(frmgen_burst, rbc_all_frmgen_burst)) begin
			$display("Critical Warning: parameter 'frmgen_burst' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", frmgen_burst, rbc_all_frmgen_burst, fnl_frmgen_burst);
		end
		//$display("frmgen_pipeln = orig: '%s', any:'%s', all:'%s', final: '%s'", frmgen_pipeln, rbc_any_frmgen_pipeln, rbc_all_frmgen_pipeln, fnl_frmgen_pipeln);
		if (!is_in_legal_set(frmgen_pipeln, rbc_all_frmgen_pipeln)) begin
			$display("Critical Warning: parameter 'frmgen_pipeln' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", frmgen_pipeln, rbc_all_frmgen_pipeln, fnl_frmgen_pipeln);
		end
		//$display("crcgen_inv = orig: '%s', any:'%s', all:'%s', final: '%s'", crcgen_inv, rbc_any_crcgen_inv, rbc_all_crcgen_inv, fnl_crcgen_inv);
		if (!is_in_legal_set(crcgen_inv, rbc_all_crcgen_inv)) begin
			$display("Critical Warning: parameter 'crcgen_inv' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", crcgen_inv, rbc_all_crcgen_inv, fnl_crcgen_inv);
		end
		//$display("crcgen_err = orig: '%s', any:'%s', all:'%s', final: '%s'", crcgen_err, rbc_any_crcgen_err, rbc_all_crcgen_err, fnl_crcgen_err);
		if (!is_in_legal_set(crcgen_err, rbc_all_crcgen_err)) begin
			$display("Critical Warning: parameter 'crcgen_err' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", crcgen_err, rbc_all_crcgen_err, fnl_crcgen_err);
		end
		//$display("tx_sm_pipeln = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_sm_pipeln, rbc_any_tx_sm_pipeln, rbc_all_tx_sm_pipeln, fnl_tx_sm_pipeln);
		if (!is_in_legal_set(tx_sm_pipeln, rbc_all_tx_sm_pipeln)) begin
			$display("Critical Warning: parameter 'tx_sm_pipeln' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_sm_pipeln, rbc_all_tx_sm_pipeln, fnl_tx_sm_pipeln);
		end
		//$display("sh_err = orig: '%s', any:'%s', all:'%s', final: '%s'", sh_err, rbc_any_sh_err, rbc_all_sh_err, fnl_sh_err);
		if (!is_in_legal_set(sh_err, rbc_all_sh_err)) begin
			$display("Critical Warning: parameter 'sh_err' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", sh_err, rbc_all_sh_err, fnl_sh_err);
		end
		//$display("dispgen_err = orig: '%s', any:'%s', all:'%s', final: '%s'", dispgen_err, rbc_any_dispgen_err, rbc_all_dispgen_err, fnl_dispgen_err);
		if (!is_in_legal_set(dispgen_err, rbc_all_dispgen_err)) begin
			$display("Critical Warning: parameter 'dispgen_err' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dispgen_err, rbc_all_dispgen_err, fnl_dispgen_err);
		end
		//$display("dispgen_pipeln = orig: '%s', any:'%s', all:'%s', final: '%s'", dispgen_pipeln, rbc_any_dispgen_pipeln, rbc_all_dispgen_pipeln, fnl_dispgen_pipeln);
		if (!is_in_legal_set(dispgen_pipeln, rbc_all_dispgen_pipeln)) begin
			$display("Critical Warning: parameter 'dispgen_pipeln' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", dispgen_pipeln, rbc_all_dispgen_pipeln, fnl_dispgen_pipeln);
		end
		//$display("scrm_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", scrm_mode, rbc_any_scrm_mode, rbc_all_scrm_mode, fnl_scrm_mode);
		if (!is_in_legal_set(scrm_mode, rbc_all_scrm_mode)) begin
			$display("Critical Warning: parameter 'scrm_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", scrm_mode, rbc_all_scrm_mode, fnl_scrm_mode);
		end
		//$display("tx_scrm_err = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_scrm_err, rbc_any_tx_scrm_err, rbc_all_tx_scrm_err, fnl_tx_scrm_err);
		if (!is_in_legal_set(tx_scrm_err, rbc_all_tx_scrm_err)) begin
			$display("Critical Warning: parameter 'tx_scrm_err' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_scrm_err, rbc_all_tx_scrm_err, fnl_tx_scrm_err);
		end
		//$display("tx_scrm_width = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_scrm_width, rbc_any_tx_scrm_width, rbc_all_tx_scrm_width, fnl_tx_scrm_width);
		if (!is_in_legal_set(tx_scrm_width, rbc_all_tx_scrm_width)) begin
			$display("Critical Warning: parameter 'tx_scrm_width' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_scrm_width, rbc_all_tx_scrm_width, fnl_tx_scrm_width);
		end
		//$display("gb_sel_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", gb_sel_mode, rbc_any_gb_sel_mode, rbc_all_gb_sel_mode, fnl_gb_sel_mode);
		if (!is_in_legal_set(gb_sel_mode, rbc_all_gb_sel_mode)) begin
			$display("Critical Warning: parameter 'gb_sel_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", gb_sel_mode, rbc_all_gb_sel_mode, fnl_gb_sel_mode);
		end
		//$display("test_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", test_mode, rbc_any_test_mode, rbc_all_test_mode, fnl_test_mode);
		if (!is_in_legal_set(test_mode, rbc_all_test_mode)) begin
			$display("Critical Warning: parameter 'test_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", test_mode, rbc_all_test_mode, fnl_test_mode);
		end
		//$display("pseudo_random = orig: '%s', any:'%s', all:'%s', final: '%s'", pseudo_random, rbc_any_pseudo_random, rbc_all_pseudo_random, fnl_pseudo_random);
		if (!is_in_legal_set(pseudo_random, rbc_all_pseudo_random)) begin
			$display("Critical Warning: parameter 'pseudo_random' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pseudo_random, rbc_all_pseudo_random, fnl_pseudo_random);
		end
		//$display("sq_wave = orig: '%s', any:'%s', all:'%s', final: '%s'", sq_wave, rbc_any_sq_wave, rbc_all_sq_wave, fnl_sq_wave);
		if (!is_in_legal_set(sq_wave, rbc_all_sq_wave)) begin
			$display("Critical Warning: parameter 'sq_wave' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", sq_wave, rbc_all_sq_wave, fnl_sq_wave);
		end
		//$display("bitslip_en = orig: '%s', any:'%s', all:'%s', final: '%s'", bitslip_en, rbc_any_bitslip_en, rbc_all_bitslip_en, fnl_bitslip_en);
		if (!is_in_legal_set(bitslip_en, rbc_all_bitslip_en)) begin
			$display("Critical Warning: parameter 'bitslip_en' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", bitslip_en, rbc_all_bitslip_en, fnl_bitslip_en);
		end
		//$display("distdwn_bypass_pipeln = orig: '%s', any:'%s', all:'%s', final: '%s'", distdwn_bypass_pipeln, rbc_any_distdwn_bypass_pipeln, rbc_all_distdwn_bypass_pipeln, fnl_distdwn_bypass_pipeln);
		if (!is_in_legal_set(distdwn_bypass_pipeln, rbc_all_distdwn_bypass_pipeln)) begin
			$display("Critical Warning: parameter 'distdwn_bypass_pipeln' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", distdwn_bypass_pipeln, rbc_all_distdwn_bypass_pipeln, fnl_distdwn_bypass_pipeln);
		end
		//$display("distup_bypass_pipeln = orig: '%s', any:'%s', all:'%s', final: '%s'", distup_bypass_pipeln, rbc_any_distup_bypass_pipeln, rbc_all_distup_bypass_pipeln, fnl_distup_bypass_pipeln);
		if (!is_in_legal_set(distup_bypass_pipeln, rbc_all_distup_bypass_pipeln)) begin
			$display("Critical Warning: parameter 'distup_bypass_pipeln' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", distup_bypass_pipeln, rbc_all_distup_bypass_pipeln, fnl_distup_bypass_pipeln);
		end
		//$display("distdwn_master = orig: '%s', any:'%s', all:'%s', final: '%s'", distdwn_master, rbc_any_distdwn_master, rbc_all_distdwn_master, fnl_distdwn_master);
		if (!is_in_legal_set(distdwn_master, rbc_all_distdwn_master)) begin
			$display("Critical Warning: parameter 'distdwn_master' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", distdwn_master, rbc_all_distdwn_master, fnl_distdwn_master);
		end
		//$display("comp_cnt = orig: '%s', any:'%s', all:'%s', final: '%s'", comp_cnt, rbc_any_comp_cnt, rbc_all_comp_cnt, fnl_comp_cnt);
		if (!is_in_legal_set(comp_cnt, rbc_all_comp_cnt)) begin
			$display("Critical Warning: parameter 'comp_cnt' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", comp_cnt, rbc_all_comp_cnt, fnl_comp_cnt);
		end
		//$display("indv = orig: '%s', any:'%s', all:'%s', final: '%s'", indv, rbc_any_indv, rbc_all_indv, fnl_indv);
		if (!is_in_legal_set(indv, rbc_all_indv)) begin
			$display("Critical Warning: parameter 'indv' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", indv, rbc_all_indv, fnl_indv);
		end
		//$display("compin_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", compin_sel, rbc_any_compin_sel, rbc_all_compin_sel, fnl_compin_sel);
		if (!is_in_legal_set(compin_sel, rbc_all_compin_sel)) begin
			$display("Critical Warning: parameter 'compin_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", compin_sel, rbc_all_compin_sel, fnl_compin_sel);
		end
		//$display("distup_master = orig: '%s', any:'%s', all:'%s', final: '%s'", distup_master, rbc_any_distup_master, rbc_all_distup_master, fnl_distup_master);
		if (!is_in_legal_set(distup_master, rbc_all_distup_master)) begin
			$display("Critical Warning: parameter 'distup_master' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", distup_master, rbc_all_distup_master, fnl_distup_master);
		end
		//$display("distdwn_master_agg = orig: '%s', any:'%s', all:'%s', final: '%s'", distdwn_master_agg, rbc_any_distdwn_master_agg, rbc_all_distdwn_master_agg, fnl_distdwn_master_agg);
		if (!skip_check_distdwn_master_agg && !is_in_legal_set(distdwn_master_agg, rbc_all_distdwn_master_agg)) begin
			$display("Critical Warning: parameter 'distdwn_master_agg' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", distdwn_master_agg, rbc_all_distdwn_master_agg, fnl_distdwn_master_agg);
		end
		//$display("distup_master_agg = orig: '%s', any:'%s', all:'%s', final: '%s'", distup_master_agg, rbc_any_distup_master_agg, rbc_all_distup_master_agg, fnl_distup_master_agg);
		if (!skip_check_distup_master_agg && !is_in_legal_set(distup_master_agg, rbc_all_distup_master_agg)) begin
			$display("Critical Warning: parameter 'distup_master_agg' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", distup_master_agg, rbc_all_distup_master_agg, fnl_distup_master_agg);
		end
		//$display("distup_bypass_pipeln_agg = orig: '%s', any:'%s', all:'%s', final: '%s'", distup_bypass_pipeln_agg, rbc_any_distup_bypass_pipeln_agg, rbc_all_distup_bypass_pipeln_agg, fnl_distup_bypass_pipeln_agg);
		if (!is_in_legal_set(distup_bypass_pipeln_agg, rbc_all_distup_bypass_pipeln_agg)) begin
			$display("Critical Warning: parameter 'distup_bypass_pipeln_agg' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", distup_bypass_pipeln_agg, rbc_all_distup_bypass_pipeln_agg, fnl_distup_bypass_pipeln_agg);
		end
		//$display("data_agg_comp = orig: '%s', any:'%s', all:'%s', final: '%s'", data_agg_comp, rbc_any_data_agg_comp, rbc_all_data_agg_comp, fnl_data_agg_comp);
		if (!skip_check_data_agg_comp && !is_in_legal_set(data_agg_comp, rbc_all_data_agg_comp)) begin
			$display("Critical Warning: parameter 'data_agg_comp' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", data_agg_comp, rbc_all_data_agg_comp, fnl_data_agg_comp);
		end
		//$display("compin_sel_agg = orig: '%s', any:'%s', all:'%s', final: '%s'", compin_sel_agg, rbc_any_compin_sel_agg, rbc_all_compin_sel_agg, fnl_compin_sel_agg);
		if (!skip_check_compin_sel_agg && !is_in_legal_set(compin_sel_agg, rbc_all_compin_sel_agg)) begin
			$display("Critical Warning: parameter 'compin_sel_agg' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", compin_sel_agg, rbc_all_compin_sel_agg, fnl_compin_sel_agg);
		end
		//$display("distdwn_bypass_pipeln_agg = orig: '%s', any:'%s', all:'%s', final: '%s'", distdwn_bypass_pipeln_agg, rbc_any_distdwn_bypass_pipeln_agg, rbc_all_distdwn_bypass_pipeln_agg, fnl_distdwn_bypass_pipeln_agg);
		if (!is_in_legal_set(distdwn_bypass_pipeln_agg, rbc_all_distdwn_bypass_pipeln_agg)) begin
			$display("Critical Warning: parameter 'distdwn_bypass_pipeln_agg' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", distdwn_bypass_pipeln_agg, rbc_all_distdwn_bypass_pipeln_agg, fnl_distdwn_bypass_pipeln_agg);
		end
		//$display("stretch_type = orig: '%s', any:'%s', all:'%s', final: '%s'", stretch_type, rbc_any_stretch_type, rbc_all_stretch_type, fnl_stretch_type);
		if (!skip_check_stretch_type && !is_in_legal_set(stretch_type, rbc_all_stretch_type)) begin
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
		//$display("tx_testbus_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_testbus_sel, rbc_any_tx_testbus_sel, rbc_all_tx_testbus_sel, fnl_tx_testbus_sel);
		if (!is_in_legal_set(tx_testbus_sel, rbc_all_tx_testbus_sel)) begin
			$display("Critical Warning: parameter 'tx_testbus_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_testbus_sel, rbc_all_tx_testbus_sel, fnl_tx_testbus_sel);
		end
		//$display("tx_polarity_inv = orig: '%s', any:'%s', all:'%s', final: '%s'", tx_polarity_inv, rbc_any_tx_polarity_inv, rbc_all_tx_polarity_inv, fnl_tx_polarity_inv);
		if (!is_in_legal_set(tx_polarity_inv, rbc_all_tx_polarity_inv)) begin
			$display("Critical Warning: parameter 'tx_polarity_inv' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", tx_polarity_inv, rbc_all_tx_polarity_inv, fnl_tx_polarity_inv);
		end
		//$display("pmagate_en = orig: '%s', any:'%s', all:'%s', final: '%s'", pmagate_en, rbc_any_pmagate_en, rbc_all_pmagate_en, fnl_pmagate_en);
		if (!is_in_legal_set(pmagate_en, rbc_all_pmagate_en)) begin
			$display("Critical Warning: parameter 'pmagate_en' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pmagate_en, rbc_all_pmagate_en, fnl_pmagate_en);
		end
	end

	stratixv_hssi_10g_tx_pcs #(
				   .silicon_rev(silicon_rev_local),
		.enable_debug_info("true"),
		.prot_mode(fnl_prot_mode),
		.sup_mode(fnl_sup_mode),
		.avmm_group_channel_index(avmm_group_channel_index),
		.bit_reverse(fnl_bit_reverse),
		.channel_number(channel_number),
		.comp_del_sel_agg(fnl_comp_del_sel_agg),
		.crcgen_init(fnl_crcgen_init),
		.crcgen_init_user(crcgen_init_user),
		.del_sel_frame_gen(del_sel_frame_gen),
		.frmgen_diag_word(frmgen_diag_word),
		.frmgen_mfrm_length(fnl_frmgen_mfrm_length),
		.frmgen_mfrm_length_user(frmgen_mfrm_length_user),
		.frmgen_scrm_word(frmgen_scrm_word),
		.frmgen_skip_word(frmgen_skip_word),
		.frmgen_sync_word(frmgen_sync_word),
		.pseudo_seed_a(pseudo_seed_a),
		.pseudo_seed_a_user(pseudo_seed_a_user),
		.pseudo_seed_b(pseudo_seed_b),
		.pseudo_seed_b_user(pseudo_seed_b_user),
		.scrm_seed(fnl_scrm_seed),
		.scrm_seed_user(scrm_seed_user),
		.skip_ctrl(skip_ctrl),
		.stretch_en(fnl_stretch_en),
		.test_bus_mode(fnl_test_bus_mode),
		.txfifo_empty(txfifo_empty),
		.txfifo_full(txfifo_full),
		.use_default_base_address(fnl_use_default_base_address),
		.user_base_address(user_base_address),
		.gb_tx_odwidth(fnl_gb_tx_odwidth),
		.gb_tx_idwidth(fnl_gb_tx_idwidth),
		.ctrl_plane_bonding(fnl_ctrl_plane_bonding),
		.data_agg_bonding(fnl_data_agg_bonding),
		.master_clk_sel(fnl_master_clk_sel),
		.txfifo_mode(fnl_txfifo_mode),
		.wr_clk_sel(fnl_wr_clk_sel),
		.sqwgen_clken(fnl_sqwgen_clken),
		.wrfifo_clken(fnl_wrfifo_clken),
		.dispgen_clken(fnl_dispgen_clken),
		.scrm_clken(fnl_scrm_clken),
		.enc_64b66b_txsm_bypass(fnl_enc_64b66b_txsm_bypass),
		.dispgen_bypass(fnl_dispgen_bypass),
		.gbred_clken(fnl_gbred_clken),
		.tx_sm_bypass(fnl_tx_sm_bypass),
		.enc64b66b_txsm_clken(fnl_enc64b66b_txsm_clken),
		.frmgen_bypass(fnl_frmgen_bypass),
		.crcgen_clken(fnl_crcgen_clken),
		.scrm_bypass(fnl_scrm_bypass),
		.frmgen_clken(fnl_frmgen_clken),
		.prbs_clken(fnl_prbs_clken),
		.crcgen_bypass(fnl_crcgen_bypass),
		.rdfifo_clken(fnl_rdfifo_clken),
		.fastpath(fnl_fastpath),
		.data_bit_reverse(fnl_data_bit_reverse),
		.ctrl_bit_reverse(fnl_ctrl_bit_reverse),
		.tx_sh_location(fnl_tx_sh_location),
		.empty_flag_type(fnl_empty_flag_type),
		.pfull_flag_type(fnl_pfull_flag_type),
		.full_flag_type(fnl_full_flag_type),
		.pempty_flag_type(fnl_pempty_flag_type),
		.fifo_stop_rd(fnl_fifo_stop_rd),
		.fifo_stop_wr(fnl_fifo_stop_wr),
		.phcomp_rd_del(fnl_phcomp_rd_del),
		.txfifo_pempty(txfifo_pempty),
		.txfifo_pfull(txfifo_pfull),
		.tx_true_b2b(fnl_tx_true_b2b),
		.frmgen_pyld_ins(fnl_frmgen_pyld_ins),
		.frmgen_wordslip(fnl_frmgen_wordslip),
		.frmgen_burst(fnl_frmgen_burst),
		.frmgen_pipeln(fnl_frmgen_pipeln),
		.crcgen_inv(fnl_crcgen_inv),
		.crcgen_err(fnl_crcgen_err),
		.tx_sm_pipeln(fnl_tx_sm_pipeln),
		.sh_err(fnl_sh_err),
		.dispgen_err(fnl_dispgen_err),
		.dispgen_pipeln(fnl_dispgen_pipeln),
		.scrm_mode(fnl_scrm_mode),
		.tx_scrm_err(fnl_tx_scrm_err),
		.tx_scrm_width(fnl_tx_scrm_width),
		.gb_sel_mode(fnl_gb_sel_mode),
		.test_mode(fnl_test_mode),
		.pseudo_random(fnl_pseudo_random),
		.sq_wave(fnl_sq_wave),
		.bitslip_en(fnl_bitslip_en),
		.distdwn_bypass_pipeln(fnl_distdwn_bypass_pipeln),
		.distup_bypass_pipeln(fnl_distup_bypass_pipeln),
		.distdwn_master(fnl_distdwn_master),
		.comp_cnt(fnl_comp_cnt),
		.indv(fnl_indv),
		.compin_sel(fnl_compin_sel),
		.distup_master(fnl_distup_master),
		.distdwn_master_agg(fnl_distdwn_master_agg),
		.distup_master_agg(fnl_distup_master_agg),
		.distup_bypass_pipeln_agg(fnl_distup_bypass_pipeln_agg),
		.data_agg_comp(fnl_data_agg_comp),
		.compin_sel_agg(fnl_compin_sel_agg),
		.distdwn_bypass_pipeln_agg(fnl_distdwn_bypass_pipeln_agg),
		.stretch_type(fnl_stretch_type),
		.stretch_num_stages(fnl_stretch_num_stages),
		.iqtxrx_clkout_sel(fnl_iqtxrx_clkout_sel),
		.tx_testbus_sel(fnl_tx_testbus_sel),
		.tx_polarity_inv(fnl_tx_polarity_inv),
		.pmagate_en(fnl_pmagate_en)
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
		.dfxlpbkcontrolout(dfxlpbkcontrolout),
		.dfxlpbkdataout(dfxlpbkdataout),
		.dfxlpbkdatavalidout(dfxlpbkdatavalidout),
		.distdwnindv(distdwnindv),
		.distdwninintlknrden(distdwninintlknrden),
		.distdwninrden(distdwninrden),
		.distdwninrdpfull(distdwninrdpfull),
		.distdwninwren(distdwninwren),
		.distdwnoutdv(distdwnoutdv),
		.distdwnoutintlknrden(distdwnoutintlknrden),
		.distdwnoutrden(distdwnoutrden),
		.distdwnoutrdpfull(distdwnoutrdpfull),
		.distdwnoutwren(distdwnoutwren),
		.distupindv(distupindv),
		.distupinintlknrden(distupinintlknrden),
		.distupinrden(distupinrden),
		.distupinrdpfull(distupinrdpfull),
		.distupinwren(distupinwren),
		.distupoutdv(distupoutdv),
		.distupoutintlknrden(distupoutintlknrden),
		.distupoutrden(distupoutrden),
		.distupoutrdpfull(distupoutrdpfull),
		.distupoutwren(distupoutwren),
		.hardresetn(hardresetn),
		.lpbkdataout(lpbkdataout),
		.pmaclkdiv33lc(pmaclkdiv33lc),
		.refclkdig(refclkdig),
		.syncdatain(syncdatain),
		.txbitslip(txbitslip),
		.txbursten(txbursten),
		.txburstenexe(txburstenexe),
		.txclkiqout(txclkiqout),
		.txclkout(txclkout),
		.txcontrol(txcontrol),
		.txdata(txdata),
		.txdatavalid(txdatavalid),
		.txdiagnosticstatus(txdiagnosticstatus),
		.txdisparityclr(txdisparityclr),
		.txfifodel(txfifodel),
		.txfifoempty(txfifoempty),
		.txfifofull(txfifofull),
		.txfifoinsert(txfifoinsert),
		.txfifopartialempty(txfifopartialempty),
		.txfifopartialfull(txfifopartialfull),
		.txframe(txframe),
		.txpldclk(txpldclk),
		.txpldrstn(txpldrstn),
		.txpmaclk(txpmaclk),
		.txpmadata(txpmadata),
		.txwordslip(txwordslip),
		.txwordslipexe(txwordslipexe)
	);
endmodule
