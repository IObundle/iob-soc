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


// Verilog RBC parameter resolution wrapper for stratixv_hssi_pipe_gen3
//

`timescale 1 ns / 1 ps

module sv_hssi_pipe_gen3_rbc #(
	// unconstrained parameters
	parameter sup_mode = "<auto_single>",	// engr_mode, user_mode

	// extra unconstrained parameters found in atom map
	parameter avmm_group_channel_index = 0,	// 0..2
	parameter bypass_rx_preset = "rx_preset_bypass",	// rx_preset_bypass
	parameter bypass_rx_preset_data = 3'b0,	// 3
	parameter bypass_tx_coefficent = "tx_coeff_bypass",	// tx_coeff_bypass
	parameter bypass_tx_coefficent_data = 18'b0,	// 18
	parameter data_mask_count = "data_mask_count",	// data_mask_count
	parameter data_mask_count_val = 10'b0,	// 10
	parameter elecidle_delay_g3 = "elecidle_delay_g3",	// elecidle_delay_g3
	parameter elecidle_delay_g3_data = 3'b0,	// 3
	parameter pc_en_counter = "pc_en_count",	// pc_en_count
	parameter pc_en_counter_data = 7'b110111,	// 7
	parameter pc_rst_counter = "pc_rst_count",	// pc_rst_count
	parameter pc_rst_counter_data = 5'b10111,	// 5
	parameter phfifo_flush_wait = "phfifo_flush_wait",	// phfifo_flush_wait
	parameter phfifo_flush_wait_data = 6'b0,	// 6
	parameter phy_status_delay_g12 = "phy_status_delay_g12",	// phy_status_delay_g12
	parameter phy_status_delay_g12_data = 3'b0,	// 3
	parameter phy_status_delay_g3 = "phy_status_delay_g3",	// phy_status_delay_g3
	parameter phy_status_delay_g3_data = 3'b0,	// 3
	parameter pma_done_counter = "pma_done_count",	// pma_done_count
	parameter pma_done_counter_data = 18'b0,	// 18
	parameter sigdet_wait_counter = "sigdet_wait_counter",	// sigdet_wait_counter
	parameter sigdet_wait_counter_data = 8'b0,	// 8
	parameter use_default_base_address = "true",	// false, true
	parameter user_base_address = 0,	// 0..2047
	parameter wait_clk_on_off_timer = "wait_clk_on_off_timer",	// wait_clk_on_off_timer
	parameter wait_clk_on_off_timer_data = 4'b100,	// 4
	parameter wait_pipe_synchronizing = "wait_pipe_sync",	// wait_pipe_sync
	parameter wait_pipe_synchronizing_data = 5'b10111,	// 5
	parameter wait_send_syncp_fbkp = "wait_send_syncp_fbkp",	// wait_send_syncp_fbkp
	parameter wait_send_syncp_fbkp_data = 11'b11111010,	// 11

	// constrained parameters
	parameter mode = "<auto_single>",	// disable_pcs, par_lpbk, pipe_g1, pipe_g2, pipe_g3, ph_fifo_reg_phfifo_reg_mode_dis, ph_fifo_reg_phfifo_reg_mode_en, sup_engr_mode, sup_user_mode
	parameter pipe_clk_sel = "<auto_single>",	// dig_clk1_8g, disable_clk, func_clk
	parameter rate_match_pad_insertion = "<auto_single>",	// dis_rm_fifo_pad_ins, en_rm_fifo_pad_ins
	parameter ind_error_reporting = "<auto_single>",	// dis_ind_error_reporting, en_ind_error_reporting
	parameter phystatus_rst_toggle_g12 = "<auto_single>",	// dis_phystatus_rst_toggle, en_phystatus_rst_toggle
	parameter phystatus_rst_toggle_g3 = "<auto_single>",	// dis_phystatus_rst_toggle_g3, en_phystatus_rst_toggle_g3
	parameter cdr_control = "<auto_single>",	// dis_cdr_ctrl, en_cdr_ctrl
	parameter cid_enable = "<auto_single>",	// dis_cid_mode, en_cid_mode
	parameter parity_chk_ts1 = "<auto_single>",	// dis_ts1_parity_chk, en_ts1_parity_chk
	parameter test_mode_timers = "<auto_single>",	// dis_test_mode_timers, en_test_mode_timers
	parameter inf_ei_enable = "<auto_single>",	// dis_inf_ei, en_inf_ei
	parameter spd_chnge_g2_sel = "<auto_single>",	// false, true
	parameter ctrl_plane_bonding = "<auto_single>",	// ctrl_master, ctrl_slave_abv, ctrl_slave_blw, individual
	parameter cp_dwn_mstr = "<auto_single>",	// false, true
	parameter cp_cons_sel = "<auto_single>",	// cp_cons_default, cp_cons_master, cp_cons_slave_abv, cp_cons_slave_blw
	parameter cp_up_mstr = "<auto_single>",	// false, true
	parameter ph_fifo_reg_mode = "<auto_single>",	// phfifo_reg_mode_dis, phfifo_reg_mode_en
	parameter rxvalid_mask = "<auto_single>",	// rxvalid_mask_dis, rxvalid_mask_en
	parameter asn_clk_enable = "<auto_single>",	// false, true
	parameter asn_enable = "<auto_single>",	// dis_asn, en_asn
	parameter free_run_clk_enable = "<auto_single>",	// false, true
	parameter bypass_send_syncp_fbkp = "<auto_single>",	// false, true
	parameter test_out_sel = "<auto_single>",	// disable, pipe_ctrl_test_out1, pipe_ctrl_test_out2, pipe_ctrl_test_out3, pipe_test_out1, pipe_test_out2, pipe_test_out3, pipe_test_out4, rx_test_out, tx_test_out
	parameter bypass_pma_sw_done = "<auto_single>",	// false, true
	parameter bypass_tx_coefficent_enable = "false",	// false, true
	parameter bypass_rx_preset_enable = "false",	// false, true
	parameter bypass_rx_detection_enable = "<auto_single>"	// false, true
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
	input  wire         	blkalgndint,
	output wire         	blockselect,
	input  wire   [10:0]	bundlingindown,
	input  wire   [10:0]	bundlinginup,
	output wire   [10:0]	bundlingoutdown,
	output wire   [10:0]	bundlingoutup,
	input  wire         	clkcompdeleteint,
	input  wire         	clkcompinsertint,
	input  wire         	clkcompoverflint,
	input  wire         	clkcompundflint,
	input  wire   [17:0]	currentcoeff,
	input  wire    [2:0]	currentrxpreset,
	output wire         	dispcbyte,
	input  wire         	eidetint,
	input  wire    [2:0]	eidleinfersel,
	input  wire         	eipartialdetint,
	input  wire         	errdecodeint,
	input  wire         	errencodeint,
	output wire         	gen3clksel,
	output wire         	gen3datasel,
	input  wire         	hardresetn,
	input  wire         	idetint,
	output wire         	inferredrxvalidint,
	output wire         	masktxpll,
	output wire         	pcsrst,
	output wire         	phystatus,
	input  wire         	pldltr,
	input  wire         	pllfixedclk,
	output wire   [17:0]	pmacurrentcoeff,
	output wire    [2:0]	pmacurrentrxpreset,
	output wire         	pmaearlyeios,
	output wire         	pmaltr,
	input  wire    [1:0]	pmapcieswdone,
	output wire    [1:0]	pmapcieswitch,
	input  wire         	pmarxdetectvalid,
	output wire         	pmarxdetpd,
	input  wire         	pmarxfound,
	input  wire         	pmasignaldet,
	output wire         	pmatxdeemph,
	output wire         	pmatxdetectrx,
	output wire         	pmatxelecidle,
	output wire    [2:0]	pmatxmargin,
	output wire         	pmatxswing,
	input  wire    [1:0]	powerdown,
	output wire         	ppmcntrst8gpcsout,
	output wire         	ppmeidleexit,
	input  wire    [1:0]	rate,
	input  wire         	rcvdclk,
	input  wire         	rcvlfsrchkint,
	output wire         	resetpcprts,
	output wire         	revlpbk8gpcsout,
	output wire         	revlpbkint,
	input  wire         	rrxdigclksel,
	input  wire         	rrxgen3capen,
	input  wire         	rtxdigclksel,
	input  wire         	rtxgen3capen,
	output wire    [3:0]	rxblkstart,
	input  wire         	rxblkstartint,
	input  wire   [63:0]	rxd8gpcsin,
	output wire   [63:0]	rxd8gpcsout,
	input  wire   [31:0]	rxdataint,
	input  wire    [3:0]	rxdatakint,
	output wire    [3:0]	rxdataskip,
	input  wire         	rxdataskipint,
	output wire         	rxelecidle,
	input  wire         	rxelecidle8gpcsin,
	input  wire         	rxpolarity,
	output wire         	rxpolarity8gpcsout,
	output wire         	rxpolarityint,
	input  wire         	rxrstn,
	output wire    [2:0]	rxstatus,
	output wire    [1:0]	rxsynchdr,
	input  wire    [1:0]	rxsynchdrint,
	input  wire   [19:0]	rxtestout,
	input  wire         	rxupdatefc,
	output wire         	rxvalid,
	input  wire         	scanmoden,
	output wire         	shutdownclk,
	input  wire         	speedchangeg2,
	output wire   [18:0]	testinfei,
	output wire   [19:0]	testout,
	input  wire         	txblkstart,
	output wire         	txblkstartint,
	input  wire         	txcompliance,
	input  wire   [31:0]	txdata,
	output wire   [31:0]	txdataint,
	input  wire    [3:0]	txdatak,
	output wire    [3:0]	txdatakint,
	input  wire         	txdataskip,
	output wire         	txdataskipint,
	input  wire         	txdeemph,
	input  wire         	txdetectrxloopback,
	input  wire         	txelecidle,
	input  wire    [2:0]	txmargin,
	input  wire         	txpmaclk,
	output wire         	txpmasyncp,
	input  wire         	txpmasyncphip,
	input  wire         	txrstn,
	input  wire         	txswing,
	input  wire    [1:0]	txsynchdr,
	output wire    [1:0]	txsynchdrint
);
	import altera_xcvr_functions::*;

	// sup_mode external parameter (no RBC)
	localparam rbc_all_sup_mode = "(engr_mode,user_mode)";
	localparam rbc_any_sup_mode = "user_mode";
	localparam fnl_sup_mode = (sup_mode == "<auto_any>" || sup_mode == "<auto_single>") ? rbc_any_sup_mode : sup_mode;

	// use_default_base_address external parameter (no RBC)
	localparam rbc_all_use_default_base_address = "(false,true)";
	localparam rbc_any_use_default_base_address = "true";
	localparam fnl_use_default_base_address = (use_default_base_address == "<auto_any>" || use_default_base_address == "<auto_single>") ? rbc_any_use_default_base_address : use_default_base_address;

	// mode, RBC-validated
	localparam rbc_all_mode = "(pipe_g1,pipe_g2,pipe_g3,par_lpbk,disable_pcs)";
	localparam rbc_any_mode = "pipe_g1";
	localparam fnl_mode = (mode == "<auto_any>" || mode == "<auto_single>") ? rbc_any_mode : mode;

	// pipe_clk_sel, RBC-validated
	localparam rbc_all_pipe_clk_sel = "(disable_clk,dig_clk1_8g,func_clk)";
	localparam rbc_any_pipe_clk_sel = "func_clk";
	localparam fnl_pipe_clk_sel = (pipe_clk_sel == "<auto_any>" || pipe_clk_sel == "<auto_single>") ? rbc_any_pipe_clk_sel : pipe_clk_sel;

	// rate_match_pad_insertion, RBC-validated
	localparam rbc_all_rate_match_pad_insertion = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("(dis_rm_fifo_pad_ins,en_rm_fifo_pad_ins)")
			 : (fnl_mode == "disable_pcs") ? ("dis_rm_fifo_pad_ins") : "(dis_rm_fifo_pad_ins,en_rm_fifo_pad_ins)"
		) : "(dis_rm_fifo_pad_ins,en_rm_fifo_pad_ins)";
	localparam rbc_any_rate_match_pad_insertion = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("dis_rm_fifo_pad_ins")
			 : (fnl_mode == "disable_pcs") ? ("dis_rm_fifo_pad_ins") : "dis_rm_fifo_pad_ins"
		) : "dis_rm_fifo_pad_ins";
	localparam fnl_rate_match_pad_insertion = (rate_match_pad_insertion == "<auto_any>" || rate_match_pad_insertion == "<auto_single>") ? rbc_any_rate_match_pad_insertion : rate_match_pad_insertion;

	// ind_error_reporting, RBC-validated
	localparam rbc_all_ind_error_reporting = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("(dis_ind_error_reporting,en_ind_error_reporting)")
			 : (fnl_mode == "disable_pcs") ? ("dis_ind_error_reporting") : "(dis_ind_error_reporting,en_ind_error_reporting)"
		) : "(dis_ind_error_reporting,en_ind_error_reporting)";
	localparam rbc_any_ind_error_reporting = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("dis_ind_error_reporting")
			 : (fnl_mode == "disable_pcs") ? ("dis_ind_error_reporting") : "dis_ind_error_reporting"
		) : "dis_ind_error_reporting";
	localparam fnl_ind_error_reporting = (ind_error_reporting == "<auto_any>" || ind_error_reporting == "<auto_single>") ? rbc_any_ind_error_reporting : ind_error_reporting;

	// phystatus_rst_toggle_g12, RBC-validated
	localparam rbc_all_phystatus_rst_toggle_g12 = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" ) ? ("(dis_phystatus_rst_toggle,en_phystatus_rst_toggle)")
			 : (fnl_mode == "pipe_g3" ) ? ("(dis_phystatus_rst_toggle,en_phystatus_rst_toggle)")
				 : (fnl_mode == "disable_pcs") ? ("dis_phystatus_rst_toggle") : "(dis_phystatus_rst_toggle,en_phystatus_rst_toggle)"
		) : "(dis_phystatus_rst_toggle,en_phystatus_rst_toggle)";
	localparam rbc_any_phystatus_rst_toggle_g12 = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" ) ? ("dis_phystatus_rst_toggle")
			 : (fnl_mode == "pipe_g3" ) ? ("dis_phystatus_rst_toggle")
				 : (fnl_mode == "disable_pcs") ? ("dis_phystatus_rst_toggle") : "dis_phystatus_rst_toggle"
		) : "dis_phystatus_rst_toggle";
	localparam fnl_phystatus_rst_toggle_g12 = (phystatus_rst_toggle_g12 == "<auto_any>" || phystatus_rst_toggle_g12 == "<auto_single>") ? rbc_any_phystatus_rst_toggle_g12 : phystatus_rst_toggle_g12;

	// phystatus_rst_toggle_g3, RBC-validated
	localparam rbc_all_phystatus_rst_toggle_g3 = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" ) ? ("dis_phystatus_rst_toggle_g3")
			 : (fnl_mode == "pipe_g3" ) ?
				(
					(fnl_phystatus_rst_toggle_g12 == "dis_phystatus_rst_toggle") ? ("dis_phystatus_rst_toggle_g3") : "en_phystatus_rst_toggle_g3"
				)
				 : (fnl_mode == "disable_pcs") ? ("dis_phystatus_rst_toggle_g3") : "(dis_phystatus_rst_toggle_g3,en_phystatus_rst_toggle_g3)"
		) : "(dis_phystatus_rst_toggle_g3,en_phystatus_rst_toggle_g3)";
	localparam rbc_any_phystatus_rst_toggle_g3 = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" ) ? ("dis_phystatus_rst_toggle_g3")
			 : (fnl_mode == "pipe_g3" ) ?
				(
					(fnl_phystatus_rst_toggle_g12 == "dis_phystatus_rst_toggle") ? ("dis_phystatus_rst_toggle_g3") : "en_phystatus_rst_toggle_g3"
				)
				 : (fnl_mode == "disable_pcs") ? ("dis_phystatus_rst_toggle_g3") : "dis_phystatus_rst_toggle_g3"
		) : "dis_phystatus_rst_toggle_g3";
	localparam fnl_phystatus_rst_toggle_g3 = (phystatus_rst_toggle_g3 == "<auto_any>" || phystatus_rst_toggle_g3 == "<auto_single>") ? rbc_any_phystatus_rst_toggle_g3 : phystatus_rst_toggle_g3;

	// cdr_control, RBC-validated
	localparam rbc_all_cdr_control = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("en_cdr_ctrl")
			 : (fnl_mode == "disable_pcs") ? ("dis_cdr_ctrl") : "(dis_cdr_ctrl,en_cdr_ctrl)"
		) : "(dis_cdr_ctrl,en_cdr_ctrl)";
	localparam rbc_any_cdr_control = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("en_cdr_ctrl")
			 : (fnl_mode == "disable_pcs") ? ("dis_cdr_ctrl") : "en_cdr_ctrl"
		) : "en_cdr_ctrl";
	localparam fnl_cdr_control = (cdr_control == "<auto_any>" || cdr_control == "<auto_single>") ? rbc_any_cdr_control : cdr_control;

	// cid_enable, RBC-validated
	localparam rbc_all_cid_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("en_cid_mode")
			 : (fnl_mode == "disable_pcs") ? ("dis_cid_mode") : "(dis_cid_mode,en_cid_mode)"
		) : "(dis_cid_mode,en_cid_mode)";
	localparam rbc_any_cid_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("en_cid_mode")
			 : (fnl_mode == "disable_pcs") ? ("dis_cid_mode") : "en_cid_mode"
		) : "en_cid_mode";
	localparam fnl_cid_enable = (cid_enable == "<auto_any>" || cid_enable == "<auto_single>") ? rbc_any_cid_enable : cid_enable;

	// parity_chk_ts1, RBC-validated
	localparam rbc_all_parity_chk_ts1 = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("en_ts1_parity_chk")
			 : (fnl_mode == "disable_pcs") ? ("dis_ts1_parity_chk") : "(dis_ts1_parity_chk,en_ts1_parity_chk)"
		) : "(dis_ts1_parity_chk,en_ts1_parity_chk)";
	localparam rbc_any_parity_chk_ts1 = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("en_ts1_parity_chk")
			 : (fnl_mode == "disable_pcs") ? ("dis_ts1_parity_chk") : "en_ts1_parity_chk"
		) : "en_ts1_parity_chk";
	localparam fnl_parity_chk_ts1 = (parity_chk_ts1 == "<auto_any>" || parity_chk_ts1 == "<auto_single>") ? rbc_any_parity_chk_ts1 : parity_chk_ts1;

	// test_mode_timers, RBC-validated
	localparam rbc_all_test_mode_timers = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("dis_test_mode_timers")
			 : (fnl_mode == "disable_pcs") ? ("dis_test_mode_timers") : "(dis_test_mode_timers,en_test_mode_timers)"
		) : "(dis_test_mode_timers,en_test_mode_timers)";
	localparam rbc_any_test_mode_timers = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("dis_test_mode_timers")
			 : (fnl_mode == "disable_pcs") ? ("dis_test_mode_timers") : "dis_test_mode_timers"
		) : "dis_test_mode_timers";
	localparam fnl_test_mode_timers = (test_mode_timers == "<auto_any>" || test_mode_timers == "<auto_single>") ? rbc_any_test_mode_timers : test_mode_timers;

	// inf_ei_enable, RBC-validated
	localparam rbc_all_inf_ei_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("(dis_inf_ei,en_inf_ei)")
			 : (fnl_mode == "disable_pcs") ? ("dis_inf_ei") : "(dis_inf_ei,en_inf_ei)"
		) : "(dis_inf_ei,en_inf_ei)";
	localparam rbc_any_inf_ei_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("dis_inf_ei")
			 : (fnl_mode == "disable_pcs") ? ("dis_inf_ei") : "dis_inf_ei"
		) : "dis_inf_ei";
	localparam fnl_inf_ei_enable = (inf_ei_enable == "<auto_any>" || inf_ei_enable == "<auto_single>") ? rbc_any_inf_ei_enable : inf_ei_enable;

	// spd_chnge_g2_sel, RBC-validated
	localparam rbc_all_spd_chnge_g2_sel = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" ) ? ("true")
			 : (fnl_mode == "pipe_g3" ) ? ("false")
				 : (fnl_mode == "disable_pcs") ? ("false") : "(true,false)"
		) : "(true,false)";
	localparam rbc_any_spd_chnge_g2_sel = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" ) ? ("true")
			 : (fnl_mode == "pipe_g3" ) ? ("false")
				 : (fnl_mode == "disable_pcs") ? ("false") : "false"
		) : "false";
	localparam fnl_spd_chnge_g2_sel = (spd_chnge_g2_sel == "<auto_any>" || spd_chnge_g2_sel == "<auto_single>") ? rbc_any_spd_chnge_g2_sel : spd_chnge_g2_sel;

	// ctrl_plane_bonding, RBC-validated
	localparam rbc_all_ctrl_plane_bonding = (fnl_mode == "disable_pcs") ? ("individual") : "(ctrl_master,ctrl_slave_abv,ctrl_slave_blw,individual)";
	localparam rbc_any_ctrl_plane_bonding = (fnl_mode == "disable_pcs") ? ("individual") : "individual";
	localparam fnl_ctrl_plane_bonding = (ctrl_plane_bonding == "<auto_any>" || ctrl_plane_bonding == "<auto_single>") ? rbc_any_ctrl_plane_bonding : ctrl_plane_bonding;

	// cp_dwn_mstr, RBC-validated
	localparam rbc_all_cp_dwn_mstr = (fnl_ctrl_plane_bonding == "individual") ? ("true")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("true")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("false") : "false";
	localparam rbc_any_cp_dwn_mstr = (fnl_ctrl_plane_bonding == "individual") ? ("true")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("true")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("false") : "false";
	localparam fnl_cp_dwn_mstr = (cp_dwn_mstr == "<auto_any>" || cp_dwn_mstr == "<auto_single>") ? rbc_any_cp_dwn_mstr : cp_dwn_mstr;

	// cp_cons_sel, RBC-validated
	localparam rbc_all_cp_cons_sel = (fnl_ctrl_plane_bonding == "individual") ? ("cp_cons_master")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("cp_cons_master")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("cp_cons_slave_blw") : "cp_cons_slave_abv";
	localparam rbc_any_cp_cons_sel = (fnl_ctrl_plane_bonding == "individual") ? ("cp_cons_master")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("cp_cons_master")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("cp_cons_slave_blw") : "cp_cons_slave_abv";
	localparam fnl_cp_cons_sel = (cp_cons_sel == "<auto_any>" || cp_cons_sel == "<auto_single>") ? rbc_any_cp_cons_sel : cp_cons_sel;

	// cp_up_mstr, RBC-validated
	localparam rbc_all_cp_up_mstr = (fnl_ctrl_plane_bonding == "individual") ? ("true")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("true")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("false") : "false";
	localparam rbc_any_cp_up_mstr = (fnl_ctrl_plane_bonding == "individual") ? ("true")
		 : (fnl_ctrl_plane_bonding == "ctrl_master") ? ("true")
			 : (fnl_ctrl_plane_bonding == "ctrl_slave_blw") ? ("false") : "false";
	localparam fnl_cp_up_mstr = (cp_up_mstr == "<auto_any>" || cp_up_mstr == "<auto_single>") ? rbc_any_cp_up_mstr : cp_up_mstr;

	// ph_fifo_reg_mode, RBC-validated
	localparam rbc_all_ph_fifo_reg_mode = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("(phfifo_reg_mode_dis,phfifo_reg_mode_en)")
			 : (fnl_mode == "disable_pcs") ? ("phfifo_reg_mode_dis") : "(phfifo_reg_mode_dis,phfifo_reg_mode_en)"
		) : "(phfifo_reg_mode_dis,phfifo_reg_mode_en)";
	localparam rbc_any_ph_fifo_reg_mode = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("phfifo_reg_mode_dis")
			 : (fnl_mode == "disable_pcs") ? ("phfifo_reg_mode_dis") : "phfifo_reg_mode_dis"
		) : "phfifo_reg_mode_dis";
	localparam fnl_ph_fifo_reg_mode = (ph_fifo_reg_mode == "<auto_any>" || ph_fifo_reg_mode == "<auto_single>") ? rbc_any_ph_fifo_reg_mode : ph_fifo_reg_mode;

	// rxvalid_mask, RBC-validated
	localparam rbc_all_rxvalid_mask = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("rxvalid_mask_en")
			 : (fnl_mode == "disable_pcs") ? ("rxvalid_mask_dis") : "(rxvalid_mask_dis,rxvalid_mask_en)"
		) : "(rxvalid_mask_dis,rxvalid_mask_en)";
	localparam rbc_any_rxvalid_mask = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("rxvalid_mask_en")
			 : (fnl_mode == "disable_pcs") ? ("rxvalid_mask_dis") : "rxvalid_mask_en"
		) : "rxvalid_mask_en";
	localparam fnl_rxvalid_mask = (rxvalid_mask == "<auto_any>" || rxvalid_mask == "<auto_single>") ? rbc_any_rxvalid_mask : rxvalid_mask;

	// asn_clk_enable, RBC-validated
	localparam rbc_all_asn_clk_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" ) ? ("false")
			 : (fnl_mode == "pipe_g3" ) ? ("true")
				 : (fnl_mode == "disable_pcs") ? ("false") : "(true,false)"
		) : "(true,false)";
	localparam rbc_any_asn_clk_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" ) ? ("false")
			 : (fnl_mode == "pipe_g3" ) ? ("true")
				 : (fnl_mode == "disable_pcs") ? ("false") : "false"
		) : "false";
	localparam fnl_asn_clk_enable = (asn_clk_enable == "<auto_any>" || asn_clk_enable == "<auto_single>") ? rbc_any_asn_clk_enable : asn_clk_enable;

	// asn_enable, RBC-validated
	localparam rbc_all_asn_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" ) ? ("dis_asn")
			 : (fnl_mode == "pipe_g3" ) ? ("en_asn")
				 : (fnl_mode == "disable_pcs") ? ("dis_asn") : "(en_asn,dis_asn)"
		) : "(en_asn,dis_asn)";
	localparam rbc_any_asn_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" ) ? ("dis_asn")
			 : (fnl_mode == "pipe_g3" ) ? ("en_asn")
				 : (fnl_mode == "disable_pcs") ? ("dis_asn") : "dis_asn"
		) : "dis_asn";
	localparam fnl_asn_enable = (asn_enable == "<auto_any>" || asn_enable == "<auto_single>") ? rbc_any_asn_enable : asn_enable;

	// free_run_clk_enable, RBC-validated
	localparam rbc_all_free_run_clk_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("true")
			 : (fnl_mode == "disable_pcs") ? ("false") : "(true,false)"
		) : "(true,false)";
	localparam rbc_any_free_run_clk_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("true")
			 : (fnl_mode == "disable_pcs") ? ("false") : "true"
		) : "true";
	localparam fnl_free_run_clk_enable = (free_run_clk_enable == "<auto_any>" || free_run_clk_enable == "<auto_single>") ? rbc_any_free_run_clk_enable : free_run_clk_enable;

	// bypass_send_syncp_fbkp, RBC-validated
	localparam rbc_all_bypass_send_syncp_fbkp = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" ) ? ("true")
			 : (fnl_mode == "pipe_g3" ) ? ("false")
				 : (fnl_mode == "disable_pcs") ? ("true") : "(true,false)"
		) : "(true,false)";
	localparam rbc_any_bypass_send_syncp_fbkp = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" ) ? ("true")
			 : (fnl_mode == "pipe_g3" ) ? ("false")
				 : (fnl_mode == "disable_pcs") ? ("true") : "false"
		) : "false";
	localparam fnl_bypass_send_syncp_fbkp = (bypass_send_syncp_fbkp == "<auto_any>" || bypass_send_syncp_fbkp == "<auto_single>") ? rbc_any_bypass_send_syncp_fbkp : bypass_send_syncp_fbkp;

	// test_out_sel, RBC-validated
	localparam rbc_all_test_out_sel = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("disable")
			 : (fnl_mode == "disable_pcs") ? ("disable") : "(tx_test_out,rx_test_out,pipe_test_out1,pipe_test_out2,pipe_test_out3,pipe_test_out4,pipe_ctrl_test_out1,pipe_ctrl_test_out2,pipe_ctrl_test_out3,disable)"
		) : "(tx_test_out,rx_test_out,pipe_test_out1,pipe_test_out2,pipe_test_out3,pipe_test_out4,pipe_ctrl_test_out1,pipe_ctrl_test_out2,pipe_ctrl_test_out3,disable)";
	localparam rbc_any_test_out_sel = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("disable")
			 : (fnl_mode == "disable_pcs") ? ("disable") : "disable"
		) : "disable";
	localparam fnl_test_out_sel = (test_out_sel == "<auto_any>" || test_out_sel == "<auto_single>") ? rbc_any_test_out_sel : test_out_sel;

	// bypass_pma_sw_done, RBC-validated
	localparam rbc_all_bypass_pma_sw_done = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("false")
			 : (fnl_mode == "disable_pcs") ? ("false") : "(true,false)"
		) : "(true,false)";
	localparam rbc_any_bypass_pma_sw_done = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("false")
			 : (fnl_mode == "disable_pcs") ? ("false") : "false"
		) : "false";
	localparam fnl_bypass_pma_sw_done = (bypass_pma_sw_done == "<auto_any>" || bypass_pma_sw_done == "<auto_single>") ? rbc_any_bypass_pma_sw_done : bypass_pma_sw_done;

	// bypass_tx_coefficent_enable, RBC-validated
	localparam rbc_all_bypass_tx_coefficent_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("(true,false)")
			 : (fnl_mode == "disable_pcs") ? ("false") : "(true,false)"
		) : "(true,false)";
	localparam rbc_any_bypass_tx_coefficent_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("false")
			 : (fnl_mode == "disable_pcs") ? ("false") : "false"
		) : "false";
	localparam fnl_bypass_tx_coefficent_enable = (bypass_tx_coefficent_enable == "<auto_any>" || bypass_tx_coefficent_enable == "<auto_single>") ? rbc_any_bypass_tx_coefficent_enable : bypass_tx_coefficent_enable;

	// bypass_rx_preset_enable, RBC-validated
	localparam rbc_all_bypass_rx_preset_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("(true,false)")
			 : (fnl_mode == "disable_pcs") ? ("false") : "(true,false)"
		) : "(true,false)";
	localparam rbc_any_bypass_rx_preset_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("false")
			 : (fnl_mode == "disable_pcs") ? ("false") : "false"
		) : "false";
	localparam fnl_bypass_rx_preset_enable = (bypass_rx_preset_enable == "<auto_any>" || bypass_rx_preset_enable == "<auto_single>") ? rbc_any_bypass_rx_preset_enable : bypass_rx_preset_enable;

	// bypass_rx_detection_enable, RBC-validated
	localparam rbc_all_bypass_rx_detection_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("(true,false)")
			 : (fnl_mode == "disable_pcs") ? ("false") : "(true,false)"
		) : "(true,false)";
	localparam rbc_any_bypass_rx_detection_enable = (fnl_sup_mode == "user_mode") ?
		(
			(fnl_mode == "pipe_g1" || fnl_mode == "pipe_g2" || fnl_mode == "pipe_g3" ) ? ("false")
			 : (fnl_mode == "disable_pcs") ? ("false") : "false"
		) : "false";
	localparam fnl_bypass_rx_detection_enable = (bypass_rx_detection_enable == "<auto_any>" || bypass_rx_detection_enable == "<auto_single>") ? rbc_any_bypass_rx_detection_enable : bypass_rx_detection_enable;

	// Validate input parameters against known values or RBC values
	initial begin
		//$display("sup_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", sup_mode, rbc_any_sup_mode, rbc_all_sup_mode, fnl_sup_mode);
		if (!is_in_legal_set(sup_mode, rbc_all_sup_mode)) begin
			$display("Critical Warning: parameter 'sup_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", sup_mode, rbc_all_sup_mode, fnl_sup_mode);
		end
		//$display("use_default_base_address = orig: '%s', any:'%s', all:'%s', final: '%s'", use_default_base_address, rbc_any_use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		if (!is_in_legal_set(use_default_base_address, rbc_all_use_default_base_address)) begin
			$display("Critical Warning: parameter 'use_default_base_address' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", use_default_base_address, rbc_all_use_default_base_address, fnl_use_default_base_address);
		end
		//$display("mode = orig: '%s', any:'%s', all:'%s', final: '%s'", mode, rbc_any_mode, rbc_all_mode, fnl_mode);
		if (!is_in_legal_set(mode, rbc_all_mode)) begin
			$display("Critical Warning: parameter 'mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", mode, rbc_all_mode, fnl_mode);
		end
		//$display("pipe_clk_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", pipe_clk_sel, rbc_any_pipe_clk_sel, rbc_all_pipe_clk_sel, fnl_pipe_clk_sel);
		if (!is_in_legal_set(pipe_clk_sel, rbc_all_pipe_clk_sel)) begin
			$display("Critical Warning: parameter 'pipe_clk_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", pipe_clk_sel, rbc_all_pipe_clk_sel, fnl_pipe_clk_sel);
		end
		//$display("rate_match_pad_insertion = orig: '%s', any:'%s', all:'%s', final: '%s'", rate_match_pad_insertion, rbc_any_rate_match_pad_insertion, rbc_all_rate_match_pad_insertion, fnl_rate_match_pad_insertion);
		if (!is_in_legal_set(rate_match_pad_insertion, rbc_all_rate_match_pad_insertion)) begin
			$display("Critical Warning: parameter 'rate_match_pad_insertion' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rate_match_pad_insertion, rbc_all_rate_match_pad_insertion, fnl_rate_match_pad_insertion);
		end
		//$display("ind_error_reporting = orig: '%s', any:'%s', all:'%s', final: '%s'", ind_error_reporting, rbc_any_ind_error_reporting, rbc_all_ind_error_reporting, fnl_ind_error_reporting);
		if (!is_in_legal_set(ind_error_reporting, rbc_all_ind_error_reporting)) begin
			$display("Critical Warning: parameter 'ind_error_reporting' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ind_error_reporting, rbc_all_ind_error_reporting, fnl_ind_error_reporting);
		end
		//$display("phystatus_rst_toggle_g12 = orig: '%s', any:'%s', all:'%s', final: '%s'", phystatus_rst_toggle_g12, rbc_any_phystatus_rst_toggle_g12, rbc_all_phystatus_rst_toggle_g12, fnl_phystatus_rst_toggle_g12);
		if (!is_in_legal_set(phystatus_rst_toggle_g12, rbc_all_phystatus_rst_toggle_g12)) begin
			$display("Critical Warning: parameter 'phystatus_rst_toggle_g12' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", phystatus_rst_toggle_g12, rbc_all_phystatus_rst_toggle_g12, fnl_phystatus_rst_toggle_g12);
		end
		//$display("phystatus_rst_toggle_g3 = orig: '%s', any:'%s', all:'%s', final: '%s'", phystatus_rst_toggle_g3, rbc_any_phystatus_rst_toggle_g3, rbc_all_phystatus_rst_toggle_g3, fnl_phystatus_rst_toggle_g3);
		if (!is_in_legal_set(phystatus_rst_toggle_g3, rbc_all_phystatus_rst_toggle_g3)) begin
			$display("Critical Warning: parameter 'phystatus_rst_toggle_g3' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", phystatus_rst_toggle_g3, rbc_all_phystatus_rst_toggle_g3, fnl_phystatus_rst_toggle_g3);
		end
		//$display("cdr_control = orig: '%s', any:'%s', all:'%s', final: '%s'", cdr_control, rbc_any_cdr_control, rbc_all_cdr_control, fnl_cdr_control);
		if (!is_in_legal_set(cdr_control, rbc_all_cdr_control)) begin
			$display("Critical Warning: parameter 'cdr_control' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", cdr_control, rbc_all_cdr_control, fnl_cdr_control);
		end
		//$display("cid_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", cid_enable, rbc_any_cid_enable, rbc_all_cid_enable, fnl_cid_enable);
		if (!is_in_legal_set(cid_enable, rbc_all_cid_enable)) begin
			$display("Critical Warning: parameter 'cid_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", cid_enable, rbc_all_cid_enable, fnl_cid_enable);
		end
		//$display("parity_chk_ts1 = orig: '%s', any:'%s', all:'%s', final: '%s'", parity_chk_ts1, rbc_any_parity_chk_ts1, rbc_all_parity_chk_ts1, fnl_parity_chk_ts1);
		if (!is_in_legal_set(parity_chk_ts1, rbc_all_parity_chk_ts1)) begin
			$display("Critical Warning: parameter 'parity_chk_ts1' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", parity_chk_ts1, rbc_all_parity_chk_ts1, fnl_parity_chk_ts1);
		end
		//$display("test_mode_timers = orig: '%s', any:'%s', all:'%s', final: '%s'", test_mode_timers, rbc_any_test_mode_timers, rbc_all_test_mode_timers, fnl_test_mode_timers);
		if (!is_in_legal_set(test_mode_timers, rbc_all_test_mode_timers)) begin
			$display("Critical Warning: parameter 'test_mode_timers' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", test_mode_timers, rbc_all_test_mode_timers, fnl_test_mode_timers);
		end
		//$display("inf_ei_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", inf_ei_enable, rbc_any_inf_ei_enable, rbc_all_inf_ei_enable, fnl_inf_ei_enable);
		if (!is_in_legal_set(inf_ei_enable, rbc_all_inf_ei_enable)) begin
			$display("Critical Warning: parameter 'inf_ei_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", inf_ei_enable, rbc_all_inf_ei_enable, fnl_inf_ei_enable);
		end
		//$display("spd_chnge_g2_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", spd_chnge_g2_sel, rbc_any_spd_chnge_g2_sel, rbc_all_spd_chnge_g2_sel, fnl_spd_chnge_g2_sel);
		if (!is_in_legal_set(spd_chnge_g2_sel, rbc_all_spd_chnge_g2_sel)) begin
			$display("Critical Warning: parameter 'spd_chnge_g2_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", spd_chnge_g2_sel, rbc_all_spd_chnge_g2_sel, fnl_spd_chnge_g2_sel);
		end
		//$display("ctrl_plane_bonding = orig: '%s', any:'%s', all:'%s', final: '%s'", ctrl_plane_bonding, rbc_any_ctrl_plane_bonding, rbc_all_ctrl_plane_bonding, fnl_ctrl_plane_bonding);
		if (!is_in_legal_set(ctrl_plane_bonding, rbc_all_ctrl_plane_bonding)) begin
			$display("Critical Warning: parameter 'ctrl_plane_bonding' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ctrl_plane_bonding, rbc_all_ctrl_plane_bonding, fnl_ctrl_plane_bonding);
		end
		//$display("cp_dwn_mstr = orig: '%s', any:'%s', all:'%s', final: '%s'", cp_dwn_mstr, rbc_any_cp_dwn_mstr, rbc_all_cp_dwn_mstr, fnl_cp_dwn_mstr);
		if (!is_in_legal_set(cp_dwn_mstr, rbc_all_cp_dwn_mstr)) begin
			$display("Critical Warning: parameter 'cp_dwn_mstr' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", cp_dwn_mstr, rbc_all_cp_dwn_mstr, fnl_cp_dwn_mstr);
		end
		//$display("cp_cons_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", cp_cons_sel, rbc_any_cp_cons_sel, rbc_all_cp_cons_sel, fnl_cp_cons_sel);
		if (!is_in_legal_set(cp_cons_sel, rbc_all_cp_cons_sel)) begin
			$display("Critical Warning: parameter 'cp_cons_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", cp_cons_sel, rbc_all_cp_cons_sel, fnl_cp_cons_sel);
		end
		//$display("cp_up_mstr = orig: '%s', any:'%s', all:'%s', final: '%s'", cp_up_mstr, rbc_any_cp_up_mstr, rbc_all_cp_up_mstr, fnl_cp_up_mstr);
		if (!is_in_legal_set(cp_up_mstr, rbc_all_cp_up_mstr)) begin
			$display("Critical Warning: parameter 'cp_up_mstr' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", cp_up_mstr, rbc_all_cp_up_mstr, fnl_cp_up_mstr);
		end
		//$display("ph_fifo_reg_mode = orig: '%s', any:'%s', all:'%s', final: '%s'", ph_fifo_reg_mode, rbc_any_ph_fifo_reg_mode, rbc_all_ph_fifo_reg_mode, fnl_ph_fifo_reg_mode);
		if (!is_in_legal_set(ph_fifo_reg_mode, rbc_all_ph_fifo_reg_mode)) begin
			$display("Critical Warning: parameter 'ph_fifo_reg_mode' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", ph_fifo_reg_mode, rbc_all_ph_fifo_reg_mode, fnl_ph_fifo_reg_mode);
		end
		//$display("rxvalid_mask = orig: '%s', any:'%s', all:'%s', final: '%s'", rxvalid_mask, rbc_any_rxvalid_mask, rbc_all_rxvalid_mask, fnl_rxvalid_mask);
		if (!is_in_legal_set(rxvalid_mask, rbc_all_rxvalid_mask)) begin
			$display("Critical Warning: parameter 'rxvalid_mask' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", rxvalid_mask, rbc_all_rxvalid_mask, fnl_rxvalid_mask);
		end
		//$display("asn_clk_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", asn_clk_enable, rbc_any_asn_clk_enable, rbc_all_asn_clk_enable, fnl_asn_clk_enable);
		if (!is_in_legal_set(asn_clk_enable, rbc_all_asn_clk_enable)) begin
			$display("Critical Warning: parameter 'asn_clk_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", asn_clk_enable, rbc_all_asn_clk_enable, fnl_asn_clk_enable);
		end
		//$display("asn_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", asn_enable, rbc_any_asn_enable, rbc_all_asn_enable, fnl_asn_enable);
		if (!is_in_legal_set(asn_enable, rbc_all_asn_enable)) begin
			$display("Critical Warning: parameter 'asn_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", asn_enable, rbc_all_asn_enable, fnl_asn_enable);
		end
		//$display("free_run_clk_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", free_run_clk_enable, rbc_any_free_run_clk_enable, rbc_all_free_run_clk_enable, fnl_free_run_clk_enable);
		if (!is_in_legal_set(free_run_clk_enable, rbc_all_free_run_clk_enable)) begin
			$display("Critical Warning: parameter 'free_run_clk_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", free_run_clk_enable, rbc_all_free_run_clk_enable, fnl_free_run_clk_enable);
		end
		//$display("bypass_send_syncp_fbkp = orig: '%s', any:'%s', all:'%s', final: '%s'", bypass_send_syncp_fbkp, rbc_any_bypass_send_syncp_fbkp, rbc_all_bypass_send_syncp_fbkp, fnl_bypass_send_syncp_fbkp);
		if (!is_in_legal_set(bypass_send_syncp_fbkp, rbc_all_bypass_send_syncp_fbkp)) begin
			$display("Critical Warning: parameter 'bypass_send_syncp_fbkp' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", bypass_send_syncp_fbkp, rbc_all_bypass_send_syncp_fbkp, fnl_bypass_send_syncp_fbkp);
		end
		//$display("test_out_sel = orig: '%s', any:'%s', all:'%s', final: '%s'", test_out_sel, rbc_any_test_out_sel, rbc_all_test_out_sel, fnl_test_out_sel);
		if (!is_in_legal_set(test_out_sel, rbc_all_test_out_sel)) begin
			$display("Critical Warning: parameter 'test_out_sel' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", test_out_sel, rbc_all_test_out_sel, fnl_test_out_sel);
		end
		//$display("bypass_pma_sw_done = orig: '%s', any:'%s', all:'%s', final: '%s'", bypass_pma_sw_done, rbc_any_bypass_pma_sw_done, rbc_all_bypass_pma_sw_done, fnl_bypass_pma_sw_done);
		if (!is_in_legal_set(bypass_pma_sw_done, rbc_all_bypass_pma_sw_done)) begin
			$display("Critical Warning: parameter 'bypass_pma_sw_done' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", bypass_pma_sw_done, rbc_all_bypass_pma_sw_done, fnl_bypass_pma_sw_done);
		end
		//$display("bypass_tx_coefficent_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", bypass_tx_coefficent_enable, rbc_any_bypass_tx_coefficent_enable, rbc_all_bypass_tx_coefficent_enable, fnl_bypass_tx_coefficent_enable);
		if (!is_in_legal_set(bypass_tx_coefficent_enable, rbc_all_bypass_tx_coefficent_enable)) begin
			$display("Critical Warning: parameter 'bypass_tx_coefficent_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", bypass_tx_coefficent_enable, rbc_all_bypass_tx_coefficent_enable, fnl_bypass_tx_coefficent_enable);
		end
		//$display("bypass_rx_preset_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", bypass_rx_preset_enable, rbc_any_bypass_rx_preset_enable, rbc_all_bypass_rx_preset_enable, fnl_bypass_rx_preset_enable);
		if (!is_in_legal_set(bypass_rx_preset_enable, rbc_all_bypass_rx_preset_enable)) begin
			$display("Critical Warning: parameter 'bypass_rx_preset_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", bypass_rx_preset_enable, rbc_all_bypass_rx_preset_enable, fnl_bypass_rx_preset_enable);
		end
		//$display("bypass_rx_detection_enable = orig: '%s', any:'%s', all:'%s', final: '%s'", bypass_rx_detection_enable, rbc_any_bypass_rx_detection_enable, rbc_all_bypass_rx_detection_enable, fnl_bypass_rx_detection_enable);
		if (!is_in_legal_set(bypass_rx_detection_enable, rbc_all_bypass_rx_detection_enable)) begin
			$display("Critical Warning: parameter 'bypass_rx_detection_enable' of instance '%m' has illegal value '%s' assigned to it.  Valid parameter values are: '%s'.  Using value '%s'", bypass_rx_detection_enable, rbc_all_bypass_rx_detection_enable, fnl_bypass_rx_detection_enable);
		end
	end

	stratixv_hssi_pipe_gen3 #(
		.sup_mode(fnl_sup_mode),
		.avmm_group_channel_index(avmm_group_channel_index),
		.bypass_rx_preset(bypass_rx_preset),
		.bypass_rx_preset_data(bypass_rx_preset_data),
		.bypass_tx_coefficent(bypass_tx_coefficent),
		.bypass_tx_coefficent_data(bypass_tx_coefficent_data),
		.data_mask_count(data_mask_count),
		.data_mask_count_val(data_mask_count_val),
		.elecidle_delay_g3(elecidle_delay_g3),
		.elecidle_delay_g3_data(elecidle_delay_g3_data),
		.pc_en_counter(pc_en_counter),
		.pc_en_counter_data(pc_en_counter_data),
		.pc_rst_counter(pc_rst_counter),
		.pc_rst_counter_data(pc_rst_counter_data),
		.phfifo_flush_wait(phfifo_flush_wait),
		.phfifo_flush_wait_data(phfifo_flush_wait_data),
		.phy_status_delay_g12(phy_status_delay_g12),
		.phy_status_delay_g12_data(phy_status_delay_g12_data),
		.phy_status_delay_g3(phy_status_delay_g3),
		.phy_status_delay_g3_data(phy_status_delay_g3_data),
		.pma_done_counter(pma_done_counter),
		.pma_done_counter_data(pma_done_counter_data),
		.sigdet_wait_counter(sigdet_wait_counter),
		.sigdet_wait_counter_data(sigdet_wait_counter_data),
		.use_default_base_address(fnl_use_default_base_address),
		.user_base_address(user_base_address),
		.wait_clk_on_off_timer(wait_clk_on_off_timer),
		.wait_clk_on_off_timer_data(wait_clk_on_off_timer_data),
		.wait_pipe_synchronizing(wait_pipe_synchronizing),
		.wait_pipe_synchronizing_data(wait_pipe_synchronizing_data),
		.wait_send_syncp_fbkp(wait_send_syncp_fbkp),
		.wait_send_syncp_fbkp_data(wait_send_syncp_fbkp_data),
		.mode(fnl_mode),
		.pipe_clk_sel(fnl_pipe_clk_sel),
		.rate_match_pad_insertion(fnl_rate_match_pad_insertion),
		.ind_error_reporting(fnl_ind_error_reporting),
		.phystatus_rst_toggle_g12(fnl_phystatus_rst_toggle_g12),
		.phystatus_rst_toggle_g3(fnl_phystatus_rst_toggle_g3),
		.cdr_control(fnl_cdr_control),
		.cid_enable(fnl_cid_enable),
		.parity_chk_ts1(fnl_parity_chk_ts1),
		.test_mode_timers(fnl_test_mode_timers),
		.inf_ei_enable(fnl_inf_ei_enable),
		.spd_chnge_g2_sel(fnl_spd_chnge_g2_sel),
		.ctrl_plane_bonding(fnl_ctrl_plane_bonding),
		.cp_dwn_mstr(fnl_cp_dwn_mstr),
		.cp_cons_sel(fnl_cp_cons_sel),
		.cp_up_mstr(fnl_cp_up_mstr),
		.ph_fifo_reg_mode(fnl_ph_fifo_reg_mode),
		.rxvalid_mask(fnl_rxvalid_mask),
		.asn_clk_enable(fnl_asn_clk_enable),
		.asn_enable(fnl_asn_enable),
		.free_run_clk_enable(fnl_free_run_clk_enable),
		.bypass_send_syncp_fbkp(fnl_bypass_send_syncp_fbkp),
		.test_out_sel(fnl_test_out_sel),
		.bypass_pma_sw_done(fnl_bypass_pma_sw_done),
		.bypass_tx_coefficent_enable(fnl_bypass_tx_coefficent_enable),
		.bypass_rx_preset_enable(fnl_bypass_rx_preset_enable),
		.bypass_rx_detection_enable(fnl_bypass_rx_detection_enable)
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
		.blkalgndint(blkalgndint),
		.blockselect(blockselect),
		.bundlingindown(bundlingindown),
		.bundlinginup(bundlinginup),
		.bundlingoutdown(bundlingoutdown),
		.bundlingoutup(bundlingoutup),
		.clkcompdeleteint(clkcompdeleteint),
		.clkcompinsertint(clkcompinsertint),
		.clkcompoverflint(clkcompoverflint),
		.clkcompundflint(clkcompundflint),
		.currentcoeff(currentcoeff),
		.currentrxpreset(currentrxpreset),
		.dispcbyte(dispcbyte),
		.eidetint(eidetint),
		.eidleinfersel(eidleinfersel),
		.eipartialdetint(eipartialdetint),
		.errdecodeint(errdecodeint),
		.errencodeint(errencodeint),
		.gen3clksel(gen3clksel),
		.gen3datasel(gen3datasel),
		.hardresetn(hardresetn),
		.idetint(idetint),
		.inferredrxvalidint(inferredrxvalidint),
		.masktxpll(masktxpll),
		.pcsrst(pcsrst),
		.phystatus(phystatus),
		.pldltr(pldltr),
		.pllfixedclk(pllfixedclk),
		.pmacurrentcoeff(pmacurrentcoeff),
		.pmacurrentrxpreset(pmacurrentrxpreset),
		.pmaearlyeios(pmaearlyeios),
		.pmaltr(pmaltr),
		.pmapcieswdone(pmapcieswdone),
		.pmapcieswitch(pmapcieswitch),
		.pmarxdetectvalid(pmarxdetectvalid),
		.pmarxdetpd(pmarxdetpd),
		.pmarxfound(pmarxfound),
		.pmasignaldet(pmasignaldet),
		.pmatxdeemph(pmatxdeemph),
		.pmatxdetectrx(pmatxdetectrx),
		.pmatxelecidle(pmatxelecidle),
		.pmatxmargin(pmatxmargin),
		.pmatxswing(pmatxswing),
		.powerdown(powerdown),
		.ppmcntrst8gpcsout(ppmcntrst8gpcsout),
		.ppmeidleexit(ppmeidleexit),
		.rate(rate),
		.rcvdclk(rcvdclk),
		.rcvlfsrchkint(rcvlfsrchkint),
		.resetpcprts(resetpcprts),
		.revlpbk8gpcsout(revlpbk8gpcsout),
		.revlpbkint(revlpbkint),
		.rrxdigclksel(rrxdigclksel),
		.rrxgen3capen(rrxgen3capen),
		.rtxdigclksel(rtxdigclksel),
		.rtxgen3capen(rtxgen3capen),
		.rxblkstart(rxblkstart),
		.rxblkstartint(rxblkstartint),
		.rxd8gpcsin(rxd8gpcsin),
		.rxd8gpcsout(rxd8gpcsout),
		.rxdataint(rxdataint),
		.rxdatakint(rxdatakint),
		.rxdataskip(rxdataskip),
		.rxdataskipint(rxdataskipint),
		.rxelecidle(rxelecidle),
		.rxelecidle8gpcsin(rxelecidle8gpcsin),
		.rxpolarity(rxpolarity),
		.rxpolarity8gpcsout(rxpolarity8gpcsout),
		.rxpolarityint(rxpolarityint),
		.rxrstn(rxrstn),
		.rxstatus(rxstatus),
		.rxsynchdr(rxsynchdr),
		.rxsynchdrint(rxsynchdrint),
		.rxtestout(rxtestout),
		.rxupdatefc(rxupdatefc),
		.rxvalid(rxvalid),
		.scanmoden(scanmoden),
		.shutdownclk(shutdownclk),
		.speedchangeg2(speedchangeg2),
		.testinfei(testinfei),
		.testout(testout),
		.txblkstart(txblkstart),
		.txblkstartint(txblkstartint),
		.txcompliance(txcompliance),
		.txdata(txdata),
		.txdataint(txdataint),
		.txdatak(txdatak),
		.txdatakint(txdatakint),
		.txdataskip(txdataskip),
		.txdataskipint(txdataskipint),
		.txdeemph(txdeemph),
		.txdetectrxloopback(txdetectrxloopback),
		.txelecidle(txelecidle),
		.txmargin(txmargin),
		.txpmaclk(txpmaclk),
		.txpmasyncp(txpmasyncp),
		.txpmasyncphip(txpmasyncphip),
		.txrstn(txrstn),
		.txswing(txswing),
		.txsynchdr(txsynchdr),
		.txsynchdrint(txsynchdrint)
	);
endmodule
