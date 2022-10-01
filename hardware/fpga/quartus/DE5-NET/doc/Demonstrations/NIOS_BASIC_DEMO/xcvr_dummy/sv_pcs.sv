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


//
//              ALTERA CORPORATION
//
// ./core_phy_ip_hdl//sv_pcs.sv
// automatically generated at 12:51:13, Thu Jan 26, 2012
//
//

`timescale 1ps/1ps

import altera_xcvr_functions::*;

module sv_pcs
	#(
	//PARAM_LIST_START
		parameter bonded_lanes = 1,
		parameter bonding_master_ch = 0,
		parameter enable_10g_rx = "true",
		parameter enable_10g_tx = "true",
		parameter enable_8g_rx = "true",
		parameter enable_8g_tx = "true",
		parameter enable_dyn_reconfig = "true",
		parameter enable_gen12_pipe = "true",
		parameter enable_gen3_pipe = "true",
		parameter enable_gen3_rx = "true",
		parameter enable_gen3_tx = "true",
	  // Adding new parameter for PMA Direct
	        parameter enable_pma_direct_tx = "false",                    // (true,false) Enable, disable the PMA Direct path
	        parameter enable_pma_direct_rx = "false",                    // (true,false) Enable, disable the PMA Direct path			

		parameter channel_number = 0,
		
		// parameters for stratixv_hssi_10g_rx_pcs
		parameter pcs10g_rx_align_del = "<auto_single>", // align_del_dis|align_del_en
		parameter pcs10g_rx_ber_bit_err_total_cnt = "bit_err_total_cnt_10g", // bit_err_total_cnt_10g
		parameter pcs10g_rx_ber_clken = "<auto_single>", // ber_clk_dis|ber_clk_en
		parameter pcs10g_rx_ber_xus_timer_window = "<auto_single>", // xus_timer_window_10g|xus_timer_window_user_setting
		parameter pcs10g_rx_ber_xus_timer_window_user = 21'b100110001001010,
		parameter pcs10g_rx_bit_reverse = "<auto_single>", // bit_reverse_dis|bit_reverse_en
		parameter pcs10g_rx_bitslip_mode = "<auto_single>", // bitslip_dis|bitslip_en
		// parameter pcs10g_rx_bitslip_wait_cnt_user = 1, // 0..7
		parameter pcs10g_rx_blksync_bitslip_type = "<auto_single>", // bitslip_comb|bitslip_reg
		parameter pcs10g_rx_blksync_bitslip_wait_cnt = "<auto_single>", // wait_cnt_user|bitslip_wait_cnt_min|bitslip_wait_cnt_max|bitslip_wait_cnt_user_setting
		parameter pcs10g_rx_blksync_bitslip_wait_cnt_user = 3'b1,
		parameter pcs10g_rx_blksync_bitslip_wait_type = "<auto_single>", // bitslip_match|bitslip_cnt
		parameter pcs10g_rx_blksync_bypass = "<auto_single>", // blksync_bypass_dis|blksync_bypass_en
		parameter pcs10g_rx_blksync_clken = "<auto_single>", // blksync_clk_dis|blksync_clk_en
		parameter pcs10g_rx_blksync_enum_invalid_sh_cnt = "<auto_single>", // enum_invalid_sh_cnt_10g|enum_invalid_sh_cnt_40g100g
		parameter pcs10g_rx_blksync_knum_sh_cnt_postlock = "<auto_single>", // knum_sh_cnt_postlock_10g|knum_sh_cnt_postlock_40g100g
		parameter pcs10g_rx_blksync_knum_sh_cnt_prelock = "<auto_single>", // knum_sh_cnt_prelock_10g|knum_sh_cnt_prelock_40g100g
		parameter pcs10g_rx_blksync_pipeln = "<auto_single>", // blksync_pipeln_dis|blksync_pipeln_en
		parameter pcs10g_rx_control_del = "<auto_single>", // control_del_all|control_del_none
		parameter pcs10g_rx_crcchk_bypass = "<auto_single>", // crcchk_bypass_dis|crcchk_bypass_en
		parameter pcs10g_rx_crcchk_clken = "<auto_single>", // crcchk_clk_dis|crcchk_clk_en
		parameter pcs10g_rx_crcchk_init = "crcchk_int", // crcchk_int|crcchk_init_user_setting
		//parameter pcs10g_rx_crcchk_init_user = 32'b11111111111111111111111111111111,
		parameter pcs10g_rx_crcchk_inv = "<auto_single>", // crcchk_inv_dis|crcchk_inv_en
		parameter pcs10g_rx_crcchk_pipeln = "<auto_single>", // crcchk_pipeln_dis|crcchk_pipeln_en
		parameter pcs10g_rx_crcflag_pipeln = "<auto_single>", // crcflag_pipeln_dis|crcflag_pipeln_en
		parameter pcs10g_rx_ctrl_bit_reverse = "<auto_single>", // ctrl_bit_reverse_dis|ctrl_bit_reverse_en
		parameter pcs10g_rx_data_bit_reverse = "<auto_single>", // data_bit_reverse_dis|data_bit_reverse_en
		parameter pcs10g_rx_dec64b66b_clken = "<auto_single>", // dec64b66b_clk_dis|dec64b66b_clk_en
		parameter pcs10g_rx_dec_64b66b_rxsm_bypass = "<auto_single>", // dec_64b66b_rxsm_bypass_dis|dec_64b66b_rxsm_bypass_en
		parameter pcs10g_rx_descrm_bypass = "<auto_single>", // descrm_bypass_dis|descrm_bypass_en
		parameter pcs10g_rx_descrm_clken = "<auto_single>", // descrm_clk_dis|descrm_clk_en
		parameter pcs10g_rx_descrm_mode = "<auto_single>", // async|sync
		parameter pcs10g_rx_dis_signal_ok = "<auto_single>", // dis_signal_ok_dis|dis_signal_ok_en
		parameter pcs10g_rx_dispchk_bypass = "<auto_single>", // dispchk_bypass_dis|dispchk_bypass_en
		parameter pcs10g_rx_dispchk_clken = "<auto_single>", // dispchk_clk_dis|dispchk_clk_en
		parameter pcs10g_rx_dispchk_pipeln = "<auto_single>", // dispchk_pipeln_dis|dispchk_pipeln_en
		parameter pcs10g_rx_dispchk_rd_level = "<auto_single>", // dispchk_rd_level_int|dispchk_rd_level_min|dispchk_rd_level_max|dispchk_rd_level_user_setting
		//parameter pcs10g_rx_dispchk_rd_level_user = 8'b1100000,
		parameter pcs10g_rx_empty_flag_type = "<auto_single>", // empty_rd_side|empty_wr_side
		parameter pcs10g_rx_fast_path = "<auto_single>", // fast_path_dis|fast_path_en
		parameter pcs10g_rx_fifo_stop_rd = "<auto_single>", // rd_empty|n_rd_empty
		parameter pcs10g_rx_fifo_stop_wr = "<auto_single>", // wr_full|n_wr_full
		parameter pcs10g_rx_force_align = "<auto_single>", // force_align_dis|force_align_en
		parameter pcs10g_rx_frmgen_diag_word = 64'h6400000000000000,
		parameter pcs10g_rx_frmgen_scrm_word = 64'h2800000000000000,
		parameter pcs10g_rx_frmgen_skip_word = 64'h1e1e1e1e1e1e1e1e,
		parameter pcs10g_rx_frmgen_sync_word = 64'h78f678f678f678f6,
		parameter pcs10g_rx_frmsync_bypass = "<auto_single>", // frmsync_bypass_dis|frmsync_bypass_en
		parameter pcs10g_rx_frmsync_clken = "<auto_single>", // frmsync_clk_dis|frmsync_clk_en
		parameter pcs10g_rx_frmsync_enum_scrm = "enum_scrm_default", // enum_scrm_default
		parameter pcs10g_rx_frmsync_enum_sync = "enum_sync_default", // enum_sync_default
		parameter pcs10g_rx_frmsync_flag_type = "<auto_single>", // all_framing_words|location_only
		parameter pcs10g_rx_frmsync_knum_sync = "knum_sync_default", // knum_sync_default
		parameter pcs10g_rx_frmsync_mfrm_length = "<auto_single>", // mfrm_user_length|frmsync_mfrm_length_min|frmsync_mfrm_length_max|frmsync_mfrm_length_user_setting
		parameter pcs10g_rx_frmsync_mfrm_length_user = 2048, // 0..8191
		parameter pcs10g_rx_frmsync_pipeln = "<auto_single>", // frmsync_pipeln_dis|frmsync_pipeln_en
		parameter pcs10g_rx_full_flag_type = "<auto_single>", // full_rd_side|full_wr_side
		parameter pcs10g_rx_gb_rx_idwidth = "<auto_single>", // width_40|width_32|width_64|width_32_default
		parameter pcs10g_rx_gb_rx_odwidth = "<auto_single>", // width_32|width_40|width_50|width_67|width_64|width_66
		parameter pcs10g_rx_gb_sel_mode = "<auto_single>", // internal|external
		parameter pcs10g_rx_gbexp_clken = "<auto_single>", // gbexp_clk_dis|gbexp_clk_en
		parameter pcs10g_rx_iqtxrx_clkout_sel = "<auto_single>", // iq_rx_clk_out|iq_rx_pma_clk_div33
		parameter pcs10g_rx_lpbk_mode = "<auto_single>", // lpbk_dis|lpbk_en
		parameter pcs10g_rx_master_clk_sel = "<auto_single>", // master_rx_pma_clk|master_tx_pma_clk|master_refclk_dig
		parameter pcs10g_rx_pempty_flag_type = "<auto_single>", // pempty_rd_side|pempty_wr_side
		parameter pcs10g_rx_pfull_flag_type = "<auto_single>", // pfull_rd_side|pfull_wr_side
		parameter pcs10g_rx_prbs_clken = "<auto_single>", // prbs_clk_dis|prbs_clk_en
		parameter pcs10g_rx_prot_mode = "<auto_single>", // disable_mode|teng_baser_mode|interlaken_mode|sfis_mode|teng_sdi_mode|basic_mode|test_prbs_mode|test_prp_mode
		parameter pcs10g_rx_rand_clken = "<auto_single>", // rand_clk_dis|rand_clk_en
		parameter pcs10g_rx_rd_clk_sel = "<auto_single>", // rd_rx_pld_clk|rd_rx_pma_clk|rd_refclk_dig
		parameter pcs10g_rx_rdfifo_clken = "<auto_single>", // rdfifo_clk_dis|rdfifo_clk_en
		parameter pcs10g_rx_rx_dfx_lpbk = "<auto_single>", // dfx_lpbk_dis|dfx_lpbk_en
		parameter pcs10g_rx_rx_fifo_write_ctrl = "<auto_single>", // blklock_stops|blklock_ignore
		parameter pcs10g_rx_rx_polarity_inv = "<auto_single>", // invert_disable|invert_enable
		parameter pcs10g_rx_rx_prbs_mask = "<auto_single>", // prbsmask128|prbsmask256|prbsmask512|prbsmask1024
		parameter pcs10g_rx_rx_scrm_width = "<auto_single>", // bit64|bit66|bit67
		parameter pcs10g_rx_rx_sh_location = "<auto_single>", // lsb|msb
		parameter pcs10g_rx_rx_signal_ok_sel = "<auto_single>", // synchronized_ver|nonsync_ver
		parameter pcs10g_rx_rx_sm_bypass = "<auto_single>", // rx_sm_bypass_dis|rx_sm_bypass_en
		parameter pcs10g_rx_rx_sm_hiber = "<auto_single>", // rx_sm_hiber_en|rx_sm_hiber_dis
		parameter pcs10g_rx_rx_sm_pipeln = "<auto_single>", // rx_sm_pipeln_dis|rx_sm_pipeln_en
		parameter pcs10g_rx_rx_testbus_sel = "<auto_single>", // crc32_chk_testbus1|crc32_chk_testbus2|disp_chk_testbus1|disp_chk_testbus2|frame_sync_testbus1|frame_sync_testbus2|dec64b66b_testbus|rxsm_testbus|ber_testbus|blksync_testbus1|blksync_testbus2|gearbox_exp_testbus1|gearbox_exp_testbus2|prbs_ver_xg_testbus|descramble_testbus1|descramble_testbus2|rx_fifo_testbus1|rx_fifo_testbus2|gearbox_exp_testbus|random_ver_testbus|descramble_testbus|blank_testbus
		parameter pcs10g_rx_rx_true_b2b = "<auto_single>", // single|b2b
		parameter pcs10g_rx_rxfifo_empty = 0, // 
		parameter pcs10g_rx_rxfifo_full = 31, // 
		parameter pcs10g_rx_rxfifo_mode = "<auto_single>", // register_mode|clk_comp_10g|clk_comp_basic|generic_interlaken|generic_basic|phase_comp|phase_comp_dv|clk_comp|generic
		parameter pcs10g_rx_rxfifo_pempty = 7, // 
		parameter pcs10g_rx_rxfifo_pfull = 23, // 
		parameter pcs10g_rx_skip_ctrl = "skip_ctrl_default", // skip_ctrl_default
		//parameter pcs10g_rx_stretch_en = "stretch_en", // stretch_en|stretch_dis
		parameter pcs10g_rx_stretch_num_stages = "<auto_single>", // zero_stage|one_stage|two_stage|three_stage
		parameter pcs10g_rx_stretch_type = "<auto_single>", // stretch_auto|stretch_custom
		parameter pcs10g_rx_sup_mode = "<auto_single>", // user_mode|engineering_mode|stretch_mode|engr_mode
		parameter pcs10g_rx_test_bus_mode = "tx", // tx|rx
		parameter pcs10g_rx_test_mode = "<auto_single>", // test_off|pseudo_random|prbs_31|prbs_23|prbs_9|prbs_7
		parameter pcs10g_rx_use_default_base_address = "true", // false|true
		parameter pcs10g_rx_user_base_address = 0, // 0..2047
		parameter pcs10g_rx_wrfifo_clken = "<auto_single>", // wrfifo_clk_dis|wrfifo_clk_en
		
		// parameters for stratixv_hssi_10g_tx_pcs
		parameter pcs10g_tx_bit_reverse = "<auto_single>", // bit_reverse_dis|bit_reverse_en
		parameter pcs10g_tx_bitslip_en = "<auto_single>", // bitslip_dis|bitslip_en
		parameter pcs10g_tx_comp_cnt = "<auto_single>", // comp_cnt_00|comp_cnt_02|comp_cnt_04|comp_cnt_06|comp_cnt_08|comp_cnt_0a|comp_cnt_0c|comp_cnt_0e|comp_cnt_10|comp_cnt_12|comp_cnt_14|comp_cnt_16|comp_cnt_18|comp_cnt_1a
		//parameter pcs10g_tx_comp_del_sel_agg = "data_agg_del0", // data_agg_del0|data_agg_del1|data_agg_del2|data_agg_del3|data_agg_del4|data_agg_del5|data_agg_del6|data_agg_del7|data_agg_del8
		parameter pcs10g_tx_compin_sel = "<auto_single>", // compin_master|compin_slave_top|compin_slave_bot|compin_default
		parameter pcs10g_tx_compin_sel_agg = "<auto_single>", // compin_agg_master|compin_agg_slave_top|compin_agg_slave_bot|compin_agg_default
		parameter pcs10g_tx_crcgen_bypass = "<auto_single>", // crcgen_bypass_dis|crcgen_bypass_en
		parameter pcs10g_tx_crcgen_clken = "<auto_single>", // crcgen_clk_dis|crcgen_clk_en
		parameter pcs10g_tx_crcgen_err = "<auto_single>", // crcgen_err_dis|crcgen_err_en
		parameter pcs10g_tx_crcgen_init = "<auto_single>", // crcgen_int|crcgen_init_user_setting
		//parameter pcs10g_tx_crcgen_init_user = 32'b11111111111111111111111111111111,
		parameter pcs10g_tx_crcgen_inv = "<auto_single>", // crcgen_inv_dis|crcgen_inv_en
		parameter pcs10g_tx_ctrl_bit_reverse = "<auto_single>", // ctrl_bit_reverse_dis|ctrl_bit_reverse_en
		// BONDING_PARAM: parameter pcs10g_tx_ctrl_plane_bonding = "<auto_single>", // individual|ctrl_master|ctrl_slave_abv|ctrl_slave_blw
		parameter pcs10g_tx_data_agg_bonding = "<auto_single>", // agg_individual|agg_master|agg_slave_abv|agg_slave_blw
		parameter pcs10g_tx_data_agg_comp = "<auto_single>", // data_agg_del0|data_agg_del1|data_agg_del2|data_agg_del3|data_agg_del4|data_agg_del5|data_agg_del6|data_agg_del7|data_agg_del8
		parameter pcs10g_tx_data_bit_reverse = "<auto_single>", // data_bit_reverse_dis|data_bit_reverse_en
		parameter pcs10g_tx_del_sel_frame_gen = "del_sel_frame_gen_del0", // del_sel_frame_gen_del0
		parameter pcs10g_tx_dispgen_bypass = "<auto_single>", // dispgen_bypass_dis|dispgen_bypass_en
		parameter pcs10g_tx_dispgen_clken = "<auto_single>", // dispgen_clk_dis|dispgen_clk_en
		parameter pcs10g_tx_dispgen_err = "<auto_single>", // dispgen_err_dis|dispgen_err_en
		parameter pcs10g_tx_dispgen_pipeln = "<auto_single>", // dispgen_pipeln_dis|dispgen_pipeln_en
		parameter pcs10g_tx_distdwn_bypass_pipeln = "<auto_single>", // distdwn_bypass_pipeln_dis|distdwn_bypass_pipeln_en
		parameter pcs10g_tx_distdwn_bypass_pipeln_agg = "<auto_single>", // distdwn_bypass_pipeln_agg_dis|distdwn_bypass_pipeln_agg_en
		parameter pcs10g_tx_distdwn_master = "<auto_single>", // distdwn_master_en|distdwn_master_dis
		parameter pcs10g_tx_distdwn_master_agg = "<auto_single>", // distdwn_master_agg_en|distdwn_master_agg_dis
		parameter pcs10g_tx_distup_bypass_pipeln = "<auto_single>", // distup_bypass_pipeln_dis|distup_bypass_pipeln_en
		parameter pcs10g_tx_distup_bypass_pipeln_agg = "<auto_single>", // distup_bypass_pipeln_agg_dis|distup_bypass_pipeln_agg_en
		parameter pcs10g_tx_distup_master = "<auto_single>", // distup_master_en|distup_master_dis
		parameter pcs10g_tx_distup_master_agg = "<auto_single>", // distup_master_agg_en|distup_master_agg_dis
		parameter pcs10g_tx_empty_flag_type = "<auto_single>", // empty_rd_side|empty_wr_side
		parameter pcs10g_tx_enc64b66b_txsm_clken = "<auto_single>", // enc64b66b_txsm_clk_dis|enc64b66b_txsm_clk_en
		parameter pcs10g_tx_enc_64b66b_txsm_bypass = "<auto_single>", // enc_64b66b_txsm_bypass_dis|enc_64b66b_txsm_bypass_en
		parameter pcs10g_tx_fastpath = "<auto_single>", // fastpath_dis|fastpath_en
		parameter pcs10g_tx_fifo_stop_rd = "<auto_single>", // rd_empty|n_rd_empty
		parameter pcs10g_tx_fifo_stop_wr = "<auto_single>", // wr_full|n_wr_full
		parameter pcs10g_tx_frmgen_burst = "<auto_single>", // frmgen_burst_dis|frmgen_burst_en
		parameter pcs10g_tx_frmgen_bypass = "<auto_single>", // frmgen_bypass_dis|frmgen_bypass_en
		parameter pcs10g_tx_frmgen_clken = "<auto_single>", // frmgen_clk_dis|frmgen_clk_en
		parameter pcs10g_tx_frmgen_diag_word = 64'h6400000000000000,
		parameter pcs10g_tx_frmgen_mfrm_length = "<auto_single>", // mfrm_user_length|frmgen_mfrm_length_min|frmgen_mfrm_length_max|frmgen_mfrm_length_user_setting
		parameter pcs10g_tx_frmgen_mfrm_length_user = 5, // 
		parameter pcs10g_tx_frmgen_pipeln = "<auto_single>", // frmgen_pipeln_dis|frmgen_pipeln_en
		parameter pcs10g_tx_frmgen_pyld_ins = "<auto_single>", // frmgen_pyld_ins_dis|frmgen_pyld_ins_en
		parameter pcs10g_tx_frmgen_scrm_word = 64'h2800000000000000,
		parameter pcs10g_tx_frmgen_skip_word = 64'h1e1e1e1e1e1e1e1e,
		parameter pcs10g_tx_frmgen_sync_word = 64'h78f678f678f678f6,
		parameter pcs10g_tx_frmgen_wordslip = "<auto_single>", // frmgen_wordslip_dis|frmgen_wordslip_en
		parameter pcs10g_tx_full_flag_type = "<auto_single>", // full_rd_side|full_wr_side
		parameter pcs10g_tx_gb_sel_mode = "<auto_single>", // internal|external
		parameter pcs10g_tx_gb_tx_idwidth = "<auto_single>", // width_32|width_40|width_50|width_67|width_64|width_66
		parameter pcs10g_tx_gb_tx_odwidth = "<auto_single>", // width_32|width_40|width_64|width_32_default
		parameter pcs10g_tx_gbred_clken = "<auto_single>", // gbred_clk_dis|gbred_clk_en
		parameter pcs10g_tx_indv = "<auto_single>", // indv_en|indv_dis
		parameter pcs10g_tx_iqtxrx_clkout_sel = "<auto_single>", // iq_tx_pma_clk|iq_tx_pma_clk_div33
		parameter pcs10g_tx_master_clk_sel = "<auto_single>", // master_tx_pma_clk|master_refclk_dig
		parameter pcs10g_tx_pempty_flag_type = "<auto_single>", // pempty_rd_side|pempty_wr_side
		parameter pcs10g_tx_pfull_flag_type = "<auto_single>", // pfull_rd_side|pfull_wr_side
		parameter pcs10g_tx_phcomp_rd_del = "<auto_single>", // phcomp_rd_del5|phcomp_rd_del4|phcomp_rd_del3|phcomp_rd_del2|phcomp_rd_del1
		parameter pcs10g_tx_pmagate_en = "<auto_single>", // pmagate_dis|pmagate_en
		parameter pcs10g_tx_prbs_clken = "<auto_single>", // prbs_clk_dis|prbs_clk_en
		parameter pcs10g_tx_prot_mode = "<auto_single>", // disable_mode|teng_baser_mode|interlaken_mode|sfis_mode|teng_sdi_mode|basic_mode|test_prbs_mode|test_prp_mode|test_rpg_mode
		parameter pcs10g_tx_pseudo_random = "<auto_single>", // all_0|two_lf
		parameter pcs10g_tx_pseudo_seed_a = "pseudo_seed_a_user_setting", // pseudo_seed_a_user_setting
		parameter pcs10g_tx_pseudo_seed_a_user = 58'b1111111111111111111111111111111111111111111111111111111111,
		parameter pcs10g_tx_pseudo_seed_b = "pseudo_seed_b_user_setting", // pseudo_seed_b_user_setting
		parameter pcs10g_tx_pseudo_seed_b_user = 58'b1111111111111111111111111111111111111111111111111111111111,
		parameter pcs10g_tx_rdfifo_clken = "<auto_single>", // rdfifo_clk_dis|rdfifo_clk_en
		parameter pcs10g_tx_scrm_bypass = "<auto_single>", // scrm_bypass_dis|scrm_bypass_en
		parameter pcs10g_tx_scrm_clken = "<auto_single>", // scrm_clk_dis|scrm_clk_en
		parameter pcs10g_tx_scrm_mode = "<auto_single>", // async|sync
		parameter pcs10g_tx_scrm_seed = "<auto_single>", // scram_seed_user_setting|scram_seed_min|scram_seed_max
		parameter pcs10g_tx_scrm_seed_user = 58'b1111111111111111111111111111111111111111111111111111111111,
		parameter pcs10g_tx_sh_err = "<auto_single>", // sh_err_dis|sh_err_en
		parameter pcs10g_tx_skip_ctrl = "skip_ctrl_default", // skip_ctrl_default
		parameter pcs10g_tx_sq_wave = "<auto_single>", // sq_wave_1|sq_wave_4|sq_wave_5|sq_wave_6|sq_wave_8|sq_wave_10
		parameter pcs10g_tx_sqwgen_clken = "<auto_single>", // sqwgen_clk_dis|sqwgen_clk_en
		//parameter pcs10g_tx_stretch_en = "stretch_en", // stretch_en|stretch_dis
		parameter pcs10g_tx_stretch_num_stages = "<auto_single>", // zero_stage|one_stage|two_stage|three_stage
		parameter pcs10g_tx_stretch_type = "<auto_single>", // stretch_auto|stretch_custom
		parameter pcs10g_tx_sup_mode = "<auto_single>", // user_mode|engineering_mode|stretch_mode|engr_mode
		parameter pcs10g_tx_test_bus_mode = "tx", // tx|rx
		parameter pcs10g_tx_test_mode = "<auto_single>", // test_off|pseudo_random|sq_wave|prbs_31|prbs_23|prbs_9|prbs_7
		parameter pcs10g_tx_tx_polarity_inv = "<auto_single>", // invert_disable|invert_enable
		parameter pcs10g_tx_tx_scrm_err = "<auto_single>", // scrm_err_dis|scrm_err_en
		parameter pcs10g_tx_tx_scrm_width = "<auto_single>", // bit64|bit66|bit67
		parameter pcs10g_tx_tx_sh_location = "<auto_single>", // lsb|msb
		parameter pcs10g_tx_tx_sm_bypass = "<auto_single>", // tx_sm_bypass_dis|tx_sm_bypass_en
		parameter pcs10g_tx_tx_sm_pipeln = "<auto_single>", // tx_sm_pipeln_dis|tx_sm_pipeln_en
		parameter pcs10g_tx_tx_testbus_sel = "<auto_single>", // crc32_gen_testbus1|crc32_gen_testbus2|disp_gen_testbus1|disp_gen_testbus2|frame_gen_testbus1|frame_gen_testbus2|enc64b66b_testbus|txsm_testbus|tx_cp_bond_testbus|prbs_gen_xg_testbus|gearbox_red_testbus1|gearbox_red_testbus2|scramble_testbus1|scramble_testbus2|tx_fifo_testbus1|tx_fifo_testbus2|gearbox_red_testbus|tx_da_bond_testbus|scramble_testbus|blank_testbus
		parameter pcs10g_tx_tx_true_b2b = "<auto_single>", // single|b2b
		parameter pcs10g_tx_txfifo_empty = 0, // 
		parameter pcs10g_tx_txfifo_full = 31, // 
		parameter pcs10g_tx_txfifo_mode = "<auto_single>", // register_mode|clk_comp|interlaken_generic|basic_generic|phase_comp|generic
		parameter pcs10g_tx_txfifo_pempty = 7, // 
		parameter pcs10g_tx_txfifo_pfull = 23, // 
		parameter pcs10g_tx_use_default_base_address = "true", // false|true
		parameter pcs10g_tx_user_base_address = 0, // 0..2047
		parameter pcs10g_tx_wr_clk_sel = "<auto_single>", // wr_tx_pld_clk|wr_tx_pma_clk|wr_refclk_dig
		parameter pcs10g_tx_wrfifo_clken = "<auto_single>", // wrfifo_clk_dis|wrfifo_clk_en
		
		// parameters for stratixv_hssi_8g_rx_pcs
		parameter pcs8g_rx_agg_block_sel = "<auto_single>", // same_smrt_pack|other_smrt_pack
		//parameter pcs8g_rx_auto_deassert_pc_rst_cnt_data = 5'b0,
		parameter pcs8g_rx_auto_error_replacement = "<auto_single>", // dis_err_replace|en_err_replace
		//parameter pcs8g_rx_auto_pc_en_cnt_data = 7'b0,
		parameter pcs8g_rx_auto_speed_nego = "<auto_single>", // dis_asn|en_asn_g2_freq_scal|en_asn_g3
		parameter pcs8g_rx_bist_ver = "<auto_single>", // dis_bist|incremental|cjpat|crpat
		parameter pcs8g_rx_bist_ver_clr_flag = "<auto_single>", // dis_bist_clr_flag|en_bist_clr_flag
		parameter pcs8g_rx_bit_reversal = "<auto_single>", // dis_bit_reversal|en_bit_reversal
		parameter pcs8g_rx_bo_pad = 10'b0,
		parameter pcs8g_rx_bo_pattern = 20'b0,
		parameter pcs8g_rx_bypass_pipeline_reg = "<auto_single>", // dis_bypass_pipeline|en_bypass_pipeline
		parameter pcs8g_rx_byte_deserializer = "<auto_single>", // dis_bds|en_bds_by_2|en_bds_by_4|en_bds_by_2_det
		parameter pcs8g_rx_byte_order = "<auto_single>", // dis_bo|en_pcs_ctrl_eight_bit_bo|en_pcs_ctrl_nine_bit_bo|en_pcs_ctrl_ten_bit_bo|en_pld_ctrl_eight_bit_bo|en_pld_ctrl_nine_bit_bo|en_pld_ctrl_ten_bit_bo
		parameter pcs8g_rx_cdr_ctrl = "<auto_single>", // dis_cdr_ctrl|en_cdr_ctrl|en_cdr_ctrl_w_cid
		parameter pcs8g_rx_cdr_ctrl_rxvalid_mask = "<auto_single>", // dis_rxvalid_mask|en_rxvalid_mask
		parameter pcs8g_rx_cid_pattern = "<auto_single>", // cid_pattern_0|cid_pattern_1
		parameter pcs8g_rx_cid_pattern_len = 8'b0,
		parameter pcs8g_rx_clkcmp_pattern_n = 20'b0,
		parameter pcs8g_rx_clkcmp_pattern_p = 20'b0,
		parameter pcs8g_rx_clock_gate_bds_dec_asn = "<auto_single>", // dis_bds_dec_asn_clk_gating|en_bds_dec_asn_clk_gating
		parameter pcs8g_rx_clock_gate_bist = "<auto_single>", // dis_bist_clk_gating|en_bist_clk_gating
		parameter pcs8g_rx_clock_gate_byteorder = "<auto_single>", // dis_byteorder_clk_gating|en_byteorder_clk_gating
		parameter pcs8g_rx_clock_gate_cdr_eidle = "<auto_single>", // dis_cdr_eidle_clk_gating|en_cdr_eidle_clk_gating
		parameter pcs8g_rx_clock_gate_dskw_rd = "<auto_single>", // dis_dskw_rdclk_gating|en_dskw_rdclk_gating
		parameter pcs8g_rx_clock_gate_dw_dskw_wr = "<auto_single>", // dis_dw_dskw_wrclk_gating|en_dw_dskw_wrclk_gating
		parameter pcs8g_rx_clock_gate_dw_pc_wrclk = "<auto_single>", // dis_dw_pc_wrclk_gating|en_dw_pc_wrclk_gating
		parameter pcs8g_rx_clock_gate_dw_rm_rd = "<auto_single>", // dis_dw_rm_rdclk_gating|en_dw_rm_rdclk_gating
		parameter pcs8g_rx_clock_gate_dw_rm_wr = "<auto_single>", // dis_dw_rm_wrclk_gating|en_dw_rm_wrclk_gating
		parameter pcs8g_rx_clock_gate_dw_wa = "<auto_single>", // dis_dw_wa_clk_gating|en_dw_wa_clk_gating
		parameter pcs8g_rx_clock_gate_pc_rdclk = "<auto_single>", // dis_pc_rdclk_gating|en_pc_rdclk_gating
		parameter pcs8g_rx_clock_gate_prbs = "<auto_single>", // dis_prbs_clk_gating|en_prbs_clk_gating
		parameter pcs8g_rx_clock_gate_sw_dskw_wr = "<auto_single>", // dis_sw_dskw_wrclk_gating|en_sw_dskw_wrclk_gating
		parameter pcs8g_rx_clock_gate_sw_pc_wrclk = "<auto_single>", // dis_sw_pc_wrclk_gating|en_sw_pc_wrclk_gating
		parameter pcs8g_rx_clock_gate_sw_rm_rd = "<auto_single>", // dis_sw_rm_rdclk_gating|en_sw_rm_rdclk_gating
		parameter pcs8g_rx_clock_gate_sw_rm_wr = "<auto_single>", // dis_sw_rm_wrclk_gating|en_sw_rm_wrclk_gating
		parameter pcs8g_rx_clock_gate_sw_wa = "<auto_single>", // dis_sw_wa_clk_gating|en_sw_wa_clk_gating
		parameter pcs8g_rx_comp_fifo_rst_pld_ctrl = "<auto_single>", // dis_comp_fifo_rst_pld_ctrl|en_comp_fifo_rst_pld_ctrl
		// BONDING_PARAM: parameter pcs8g_rx_ctrl_plane_bonding_compensation = "<auto_single>", // dis_compensation|en_compensation
		// BONDING_PARAM: parameter pcs8g_rx_ctrl_plane_bonding_consumption = "<auto_single>", // individual|bundled_master|bundled_slave_below|bundled_slave_above
		// BONDING_PARAM: parameter pcs8g_rx_ctrl_plane_bonding_distribution = "<auto_single>", // master_chnl_distr|not_master_chnl_distr
		parameter pcs8g_rx_deskew = "<auto_single>", // dis_deskew|en_srio_v2p1|en_xaui
		parameter pcs8g_rx_deskew_pattern = 10'b1101101000,
		parameter pcs8g_rx_deskew_prog_pattern_only = "<auto_single>", // dis_deskew_prog_pat_only|en_deskew_prog_pat_only
		parameter pcs8g_rx_dw_one_or_two_symbol_bo = "<auto_single>", // donot_care_one_two_bo|one_symbol_bo|two_symbol_bo_eight_bit|two_symbol_bo_nine_bit|two_symbol_bo_ten_bit
		parameter pcs8g_rx_eidle_entry_eios = "<auto_single>", // dis_eidle_eios|en_eidle_eios
		parameter pcs8g_rx_eidle_entry_iei = "<auto_single>", // dis_eidle_iei|en_eidle_iei
		parameter pcs8g_rx_eidle_entry_sd = "<auto_single>", // dis_eidle_sd|en_eidle_sd
		parameter pcs8g_rx_eightb_tenb_decoder = "<auto_single>", // dis_8b10b|en_8b10b_ibm|en_8b10b_sgx
		parameter pcs8g_rx_eightbtenb_decoder_output_sel = "<auto_single>", // data_8b10b_decoder|data_xaui_sm
		parameter pcs8g_rx_err_flags_sel = "<auto_single>", // err_flags_wa|err_flags_8b10b
		parameter pcs8g_rx_fixed_pat_det = "<auto_single>", // dis_fixed_patdet|en_fixed_patdet
		parameter pcs8g_rx_fixed_pat_num = 4'b1111,
		parameter pcs8g_rx_force_signal_detect = "<auto_single>", // en_force_signal_detect|dis_force_signal_detect
		parameter pcs8g_rx_hip_mode = "<auto_single>", // dis_hip|en_hip
		parameter pcs8g_rx_ibm_invalid_code = "<auto_single>", // dis_ibm_invalid_code|en_ibm_invalid_code
		parameter pcs8g_rx_invalid_code_flag_only = "<auto_single>", // dis_invalid_code_only|en_invalid_code_only
		parameter pcs8g_rx_mask_cnt = 10'h3ff,
		parameter pcs8g_rx_pad_or_edb_error_replace = "<auto_single>", // replace_edb|replace_pad|replace_edb_dynamic
		parameter pcs8g_rx_pc_fifo_rst_pld_ctrl = "<auto_single>", // dis_pc_fifo_rst_pld_ctrl|en_pc_fifo_rst_pld_ctrl
		parameter pcs8g_rx_pcs_bypass = "<auto_single>", // dis_pcs_bypass|en_pcs_bypass
		parameter pcs8g_rx_phase_compensation_fifo = "<auto_single>", // low_latency|normal_latency|register_fifo|pld_ctrl_low_latency|pld_ctrl_normal_latency
		parameter pcs8g_rx_pipe_if_enable = "<auto_single>", // dis_pipe_rx|en_pipe_rx|en_pipe3_rx
		parameter pcs8g_rx_pma_done_count = 18'b0,
		parameter pcs8g_rx_pma_dw = "<auto_single>", // eight_bit|ten_bit|sixteen_bit|twenty_bit
		parameter pcs8g_rx_polarity_inversion = "<auto_single>", // dis_pol_inv|en_pol_inv
		parameter pcs8g_rx_polinv_8b10b_dec = "<auto_single>", // dis_polinv_8b10b_dec|en_polinv_8b10b_dec
		parameter pcs8g_rx_prbs_ver = "<auto_single>", // dis_prbs|prbs_7_sw|prbs_7_dw|prbs_8|prbs_10|prbs_23_sw|prbs_23_dw|prbs_15|prbs_31|prbs_hf_sw|prbs_hf_dw|prbs_lf_sw|prbs_lf_dw|prbs_mf_sw|prbs_mf_dw
		parameter pcs8g_rx_prbs_ver_clr_flag = "<auto_single>", // dis_prbs_clr_flag|en_prbs_clr_flag
		parameter pcs8g_rx_prot_mode = "<auto_single>", // pipe_g1|pipe_g2|pipe_g3|cpri|cpri_rx_tx|gige|xaui|srio_2p1|test|basic|disabled_prot_mode
		parameter pcs8g_rx_rate_match = "<auto_single>", // dis_rm|xaui_rm|gige_rm|pipe_rm|pipe_rm_0ppm|sw_basic_rm|srio_v2p1_rm|srio_v2p1_rm_0ppm|dw_basic_rm
		parameter pcs8g_rx_re_bo_on_wa = "<auto_single>", // dis_re_bo_on_wa|en_re_bo_on_wa
		parameter pcs8g_rx_runlength_check = "<auto_single>", // dis_runlength|en_runlength_sw|en_runlength_dw
		parameter pcs8g_rx_runlength_val = 6'b0,
		parameter pcs8g_rx_rx_clk1 = "<auto_single>", // rcvd_clk_clk1|tx_pma_clock_clk1|rcvd_clk_agg_clk1|rcvd_clk_agg_top_or_bottom_clk1
		parameter pcs8g_rx_rx_clk2 = "<auto_single>", // rcvd_clk_clk2|tx_pma_clock_clk2|refclk_dig2_clk2
		parameter pcs8g_rx_rx_clk_free_running = "<auto_single>", // dis_rx_clk_free_run|en_rx_clk_free_run
		parameter pcs8g_rx_rx_pcs_urst = "<auto_single>", // dis_rx_pcs_urst|en_rx_pcs_urst
		parameter pcs8g_rx_rx_rcvd_clk = "<auto_single>", // rcvd_clk_rcvd_clk|tx_pma_clock_rcvd_clk
		parameter pcs8g_rx_rx_rd_clk = "<auto_single>", // pld_rx_clk|rx_clk
		parameter pcs8g_rx_rx_refclk = "<auto_single>", // dis_refclk_sel|en_refclk_sel
		parameter pcs8g_rx_rx_wr_clk = "<auto_single>", // rx_clk2_div_1_2_4|txfifo_rd_clk
		parameter pcs8g_rx_sup_mode = "<auto_single>", // user_mode|engineering_mode
		parameter pcs8g_rx_symbol_swap = "<auto_single>", // dis_symbol_swap|en_symbol_swap
		parameter pcs8g_rx_test_bus_sel = "<auto_single>", // prbs_bist_testbus|tx_testbus|tx_ctrl_plane_testbus|wa_testbus|deskew_testbus|rm_testbus|rx_ctrl_testbus|pcie_ctrl_testbus|rx_ctrl_plane_testbus|agg_testbus
		parameter pcs8g_rx_test_mode = "<auto_single>", // dont_care_test|prbs|bist
		parameter pcs8g_rx_tx_rx_parallel_loopback = "<auto_single>", // dis_plpbk|en_plpbk
		parameter pcs8g_rx_use_default_base_address = "true", // false|true
		parameter pcs8g_rx_user_base_address = 0, // 0..2047
		parameter pcs8g_rx_wa_boundary_lock_ctrl = "<auto_single>", // bit_slip|sync_sm|deterministic_latency|auto_align_pld_ctrl
		parameter pcs8g_rx_wa_clk_slip_spacing = "<auto_single>", // min_clk_slip_spacing|user_programmable_clk_slip_spacing
		parameter pcs8g_rx_wa_clk_slip_spacing_data = 10'b10000,
		parameter pcs8g_rx_wa_det_latency_sync_status_beh = "<auto_single>", // assert_sync_status_imm|assert_sync_status_non_imm|dont_care_assert_sync
		parameter pcs8g_rx_wa_disp_err_flag = "<auto_single>", // dis_disp_err_flag|en_disp_err_flag
		parameter pcs8g_rx_wa_kchar = "<auto_single>", // dis_kchar|en_kchar
		parameter pcs8g_rx_wa_pd = "<auto_single>", // dont_care_wa_pd_0|dont_care_wa_pd_1|wa_pd_7|wa_pd_10|wa_pd_20|wa_pd_40|wa_pd_8_sw|wa_pd_8_dw|wa_pd_16_sw|wa_pd_16_dw|wa_pd_32|wa_pd_fixed_7_k28p5|wa_pd_fixed_10_k28p5|wa_pd_fixed_16_a1a2_sw|wa_pd_fixed_16_a1a2_dw|wa_pd_fixed_32_a1a1a2a2|prbs15_fixed_wa_pd_16_sw|prbs15_fixed_wa_pd_16_dw|prbs15_fixed_wa_pd_20_dw|prbs31_fixed_wa_pd_16_sw|prbs31_fixed_wa_pd_16_dw|prbs31_fixed_wa_pd_10_sw|prbs31_fixed_wa_pd_40_dw|prbs8_fixed_wa|prbs10_fixed_wa|prbs7_fixed_wa_pd_16_sw|prbs7_fixed_wa_pd_16_dw|prbs7_fixed_wa_pd_20_dw|prbs23_fixed_wa_pd_16_sw|prbs23_fixed_wa_pd_32_dw|prbs23_fixed_wa_pd_40_dw
		parameter pcs8g_rx_wa_pd_data = 40'b0,
		parameter pcs8g_rx_wa_pd_polarity = "<auto_single>", // dis_pd_both_pol|en_pd_both_pol|dont_care_both_pol
		parameter pcs8g_rx_wa_pld_controlled = "<auto_single>", // dis_pld_ctrl|pld_ctrl_sw|rising_edge_sensitive_dw|level_sensitive_dw
		parameter pcs8g_rx_wa_renumber_data = 6'b0,
		parameter pcs8g_rx_wa_rgnumber_data = 8'b0,
		parameter pcs8g_rx_wa_rknumber_data = 8'b0,
		parameter pcs8g_rx_wa_rosnumber_data = 2'b0,
		parameter pcs8g_rx_wa_rvnumber_data = 13'b0,
		parameter pcs8g_rx_wa_sync_sm_ctrl = "<auto_single>", // gige_sync_sm|pipe_sync_sm|xaui_sync_sm|srio1p3_sync_sm|srio2p1_sync_sm|sw_basic_sync_sm|dw_basic_sync_sm|fibre_channel_sync_sm
		parameter pcs8g_rx_wait_cnt = 8'b0,
		//parameter pcs8g_rx_wait_for_phfifo_cnt_data = 6'b0,
		
		// parameters for stratixv_hssi_8g_tx_pcs
		parameter pcs8g_tx_agg_block_sel = "<auto_single>", // same_smrt_pack|other_smrt_pack
		parameter pcs8g_tx_auto_speed_nego_gen2 = "<auto_single>", // dis_asn_g2|en_asn_g2_freq_scal
		parameter pcs8g_tx_bist_gen = "<auto_single>", // dis_bist|incremental|cjpat|crpat
		parameter pcs8g_tx_bit_reversal = "<auto_single>", // dis_bit_reversal|en_bit_reversal
		parameter pcs8g_tx_bypass_pipeline_reg = "<auto_single>", // dis_bypass_pipeline|en_bypass_pipeline
		parameter pcs8g_tx_byte_serializer = "<auto_single>", // dis_bs|en_bs_by_2|en_bs_by_4
		parameter pcs8g_tx_cid_pattern = "<auto_single>", // cid_pattern_0|cid_pattern_1
		parameter pcs8g_tx_cid_pattern_len = 8'b0,
		parameter pcs8g_tx_clock_gate_bist = "<auto_single>", // dis_bist_clk_gating|en_bist_clk_gating
		parameter pcs8g_tx_clock_gate_bs_enc = "<auto_single>", // dis_bs_enc_clk_gating|en_bs_enc_clk_gating
		parameter pcs8g_tx_clock_gate_dw_fifowr = "<auto_single>", // dis_dw_fifowr_clk_gating|en_dw_fifowr_clk_gating
		parameter pcs8g_tx_clock_gate_fiford = "<auto_single>", // dis_fiford_clk_gating|en_fiford_clk_gating
		parameter pcs8g_tx_clock_gate_prbs = "<auto_single>", // dis_prbs_clk_gating|en_prbs_clk_gating
		parameter pcs8g_tx_clock_gate_sw_fifowr = "<auto_single>", // dis_sw_fifowr_clk_gating|en_sw_fifowr_clk_gating
		// BONDING_PARAM: parameter pcs8g_tx_ctrl_plane_bonding_compensation = "<auto_single>", // dis_compensation|en_compensation
		// BONDING_PARAM: parameter pcs8g_tx_ctrl_plane_bonding_consumption = "<auto_single>", // individual|bundled_master|bundled_slave_below|bundled_slave_above
		// BONDING_PARAM: parameter pcs8g_tx_ctrl_plane_bonding_distribution = "<auto_single>", // master_chnl_distr|not_master_chnl_distr
		parameter pcs8g_tx_data_selection_8b10b_encoder_input = "<auto_single>", // normal_data_path|xaui_sm|gige_idle_conversion
		parameter pcs8g_tx_dynamic_clk_switch = "<auto_single>", // dis_dyn_clk_switch|en_dyn_clk_switch
		parameter pcs8g_tx_eightb_tenb_disp_ctrl = "<auto_single>", // dis_disp_ctrl|en_disp_ctrl|en_ib_disp_ctrl
		parameter pcs8g_tx_eightb_tenb_encoder = "<auto_single>", // dis_8b10b|en_8b10b_ibm|en_8b10b_sgx
		parameter pcs8g_tx_force_echar = "<auto_single>", // dis_force_echar|en_force_echar
		parameter pcs8g_tx_force_kchar = "<auto_single>", // dis_force_kchar|en_force_kchar
		parameter pcs8g_tx_hip_mode = "<auto_single>", // dis_hip|en_hip
		parameter pcs8g_tx_pcfifo_urst = "<auto_single>", // dis_pcfifourst|en_pcfifourst
		parameter pcs8g_tx_pcs_bypass = "<auto_single>", // dis_pcs_bypass|en_pcs_bypass
		parameter pcs8g_tx_phase_compensation_fifo = "<auto_single>", // low_latency|normal_latency|register_fifo|pld_ctrl_low_latency|pld_ctrl_normal_latency
		parameter pcs8g_tx_phfifo_write_clk_sel = "<auto_single>", // pld_tx_clk|tx_clk
		parameter pcs8g_tx_pma_dw = "<auto_single>", // eight_bit|ten_bit|sixteen_bit|twenty_bit
		parameter pcs8g_tx_polarity_inversion = "<auto_single>", // dis_polinv|enable_polinv
		parameter pcs8g_tx_prbs_gen = "<auto_single>", // dis_prbs|prbs_7_sw|prbs_7_dw|prbs_8|prbs_10|prbs_23_sw|prbs_23_dw|prbs_15|prbs_31|prbs_hf_sw|prbs_hf_dw|prbs_lf_sw|prbs_lf_dw|prbs_mf_sw|prbs_mf_dw
		parameter pcs8g_tx_prot_mode = "<auto_single>", // pipe_g1|pipe_g2|pipe_g3|cpri|cpri_rx_tx|gige|xaui|srio_2p1|test|basic|disabled_prot_mode
		parameter pcs8g_tx_refclk_b_clk_sel = "<auto_single>", // tx_pma_clock|refclk_dig
		parameter pcs8g_tx_revloop_back_rm = "<auto_single>", // dis_rev_loopback_rx_rm|en_rev_loopback_rx_rm
		parameter pcs8g_tx_sup_mode = "<auto_single>", // user_mode|engineering_mode
		parameter pcs8g_tx_symbol_swap = "<auto_single>", // dis_symbol_swap|en_symbol_swap
		parameter pcs8g_tx_test_mode = "<auto_single>", // dont_care_test|prbs|bist
		parameter pcs8g_tx_tx_bitslip = "<auto_single>", // dis_tx_bitslip|en_tx_bitslip
		parameter pcs8g_tx_tx_compliance_controlled_disparity = "<auto_single>", // dis_txcompliance|en_txcompliance_pipe2p0|en_txcompliance_pipe3p0
		parameter pcs8g_tx_txclk_freerun = "<auto_single>", // dis_freerun_tx|en_freerun_tx
		parameter pcs8g_tx_txpcs_urst = "<auto_single>", // dis_txpcs_urst|en_txpcs_urst
		parameter pcs8g_tx_use_default_base_address = "true", // false|true
		parameter pcs8g_tx_user_base_address = 0, // 0..2047
		
		// parameters for stratixv_hssi_common_pcs_pma_interface
		parameter com_pcs_pma_if_auto_speed_ena = "<auto_single>", // dis_auto_speed_ena|en_auto_speed_ena
		parameter com_pcs_pma_if_force_freqdet = "<auto_single>", // force_freqdet_dis|force1_freqdet_en|force0_freqdet_en
		parameter com_pcs_pma_if_func_mode = "<auto_single>", // disable|pma_direct|hrdrstctrl_cmu|eightg_only_pld|eightg_and_g3|eightg_only_emsip|teng_only|eightgtx_and_tengrx|eightgrx_and_tengtx
		parameter com_pcs_pma_if_pcie_gen3_cap = "non_pcie_gen3_cap", // pcie_gen3_cap|non_pcie_gen3_cap
		parameter com_pcs_pma_if_pipe_if_g3pcs = "<auto_single>", // pipe_if_g3pcs|pipe_if_8gpcs
		parameter com_pcs_pma_if_pma_if_dft_en = "dft_dis", // dft_dis
		parameter com_pcs_pma_if_pma_if_dft_val = "dft_0", // dft_0
		parameter com_pcs_pma_if_ppm_cnt_rst = "<auto_single>", // ppm_cnt_rst_dis|ppm_cnt_rst_en
		parameter com_pcs_pma_if_ppm_deassert_early = "<auto_single>", // deassert_early_dis|deassert_early_en
		parameter com_pcs_pma_if_ppm_gen1_2_cnt = "<auto_single>", // cnt_32k|cnt_64k
		parameter com_pcs_pma_if_ppm_post_eidle_delay = "<auto_single>", // cnt_200_cycles|cnt_400_cycles
		parameter com_pcs_pma_if_ppmsel = "<auto_single>", // ppmsel_default|ppmsel_1000|ppmsel_500|ppmsel_300|ppmsel_250|ppmsel_200|ppmsel_125|ppmsel_100|ppmsel_62p5|ppm_other
		parameter com_pcs_pma_if_prot_mode = "<auto_single>", // disabled_prot_mode|pipe_g1|pipe_g2|pipe_g3|other_protocols
		parameter com_pcs_pma_if_refclk_dig_sel = "refclk_dig_dis", // refclk_dig_dis|refclk_dig_en
		parameter com_pcs_pma_if_selectpcs = "<auto_single>", // eight_g_pcs|pcie_gen3
		parameter com_pcs_pma_if_sup_mode = "<auto_single>", // user_mode|engineering_mode|stretch_mode
		parameter com_pcs_pma_if_use_default_base_address = "true", // false|true
		parameter com_pcs_pma_if_user_base_address = 0, // 0..2047
		
		// parameters for stratixv_hssi_common_pld_pcs_interface
		parameter com_pld_pcs_if_data_source = "pld", // emsip|pld
		parameter com_pld_pcs_if_emsip_enable = "emsip_disable", // emsip_enable|emsip_disable
		parameter com_pld_pcs_if_hrdrstctrl_en_cfg = "hrst_dis_cfg", // hrst_dis_cfg|hrst_en_cfg
		parameter com_pld_pcs_if_hrdrstctrl_en_cfgusr = "hrst_dis_cfgusr", // hrst_dis_cfgusr|hrst_en_cfgusr
		parameter com_pld_pcs_if_pld_side_reserved_source0 = "pld_res0", // pld_res0|emsip_res0
		parameter com_pld_pcs_if_pld_side_reserved_source1 = "pld_res1", // pld_res1|emsip_res1
		parameter com_pld_pcs_if_pld_side_reserved_source10 = "pld_res10", // pld_res10|emsip_res10
		parameter com_pld_pcs_if_pld_side_reserved_source11 = "pld_res11", // pld_res11|emsip_res11
		parameter com_pld_pcs_if_pld_side_reserved_source2 = "pld_res2", // pld_res2|emsip_res2
		parameter com_pld_pcs_if_pld_side_reserved_source3 = "pld_res3", // pld_res3|emsip_res3
		parameter com_pld_pcs_if_pld_side_reserved_source4 = "pld_res4", // pld_res4|emsip_res4
		parameter com_pld_pcs_if_pld_side_reserved_source5 = "pld_res5", // pld_res5|emsip_res5
		parameter com_pld_pcs_if_pld_side_reserved_source6 = "pld_res6", // pld_res6|emsip_res6
		parameter com_pld_pcs_if_pld_side_reserved_source7 = "pld_res7", // pld_res7|emsip_res7
		parameter com_pld_pcs_if_pld_side_reserved_source8 = "pld_res8", // pld_res8|emsip_res8
		parameter com_pld_pcs_if_pld_side_reserved_source9 = "pld_res9", // pld_res9|emsip_res9
		parameter com_pld_pcs_if_testbus_sel = "eight_g_pcs", // eight_g_pcs|g3_pcs|ten_g_pcs|pma_if
		parameter com_pld_pcs_if_use_default_base_address = "true", // false|true
		parameter com_pld_pcs_if_user_base_address = 0, // 0..2047
		parameter com_pld_pcs_if_usrmode_sel4rst = "usermode", // usermode|last_frz
		
		// parameters for stratixv_hssi_gen3_rx_pcs
		parameter pcs_g3_rx_block_sync = "enable_block_sync", // bypass_block_sync|enable_block_sync
		parameter pcs_g3_rx_block_sync_sm = "enable_blk_sync_sm", // disable_blk_sync_sm|enable_blk_sync_sm
		parameter pcs_g3_rx_decoder = "enable_decoder", // bypass_decoder|enable_decoder
		parameter pcs_g3_rx_descrambler = "enable_descrambler", // bypass_descrambler|enable_descrambler
		parameter pcs_g3_rx_descrambler_lfsr_check = "lfsr_chk_dis", // lfsr_chk_dis|lfsr_chk_en
		parameter pcs_g3_rx_lpbk_force = "lpbk_frce_dis", // lpbk_frce_dis|lpbk_frce_en
		parameter pcs_g3_rx_mode = "gen3_func", // gen3_func|par_lpbk|disable_pcs
		parameter pcs_g3_rx_parallel_lpbk = "par_lpbk_dis", // par_lpbk_dis|par_lpbk_en
		parameter pcs_g3_rx_rate_match_fifo = "enable_rm_fifo", // bypass_rm_fifo|enable_rm_fifo
		parameter pcs_g3_rx_rate_match_fifo_latency = "regular_latency", // regular_latency|low_latency
		parameter pcs_g3_rx_reverse_lpbk = "rev_lpbk_en", // rev_lpbk_dis|rev_lpbk_en
		parameter pcs_g3_rx_rmfifo_empty = "rmfifo_empty", // rmfifo_empty
		parameter pcs_g3_rx_rmfifo_empty_data = 5'b1,
		parameter pcs_g3_rx_rmfifo_full = "rmfifo_full", // rmfifo_full
		parameter pcs_g3_rx_rmfifo_full_data = 5'b11111,
		parameter pcs_g3_rx_rmfifo_pempty = "rmfifo_pempty", // rmfifo_pempty
		parameter pcs_g3_rx_rmfifo_pempty_data = 5'b1000,
		parameter pcs_g3_rx_rmfifo_pfull = "rmfifo_pfull", // rmfifo_pfull
		parameter pcs_g3_rx_rmfifo_pfull_data = 5'b10111,
		parameter pcs_g3_rx_rx_b4gb_par_lpbk = "b4gb_par_lpbk_dis", // b4gb_par_lpbk_dis|b4gb_par_lpbk_en
		parameter pcs_g3_rx_rx_clk_sel = "rcvd_clk", // disable_clk|dig_clk1_8g|rcvd_clk
		parameter pcs_g3_rx_rx_force_balign = "en_force_balign", // en_force_balign|dis_force_balign
		parameter pcs_g3_rx_rx_g3_dcbal = "g3_dcbal_en", // g3_dcbal_dis|g3_dcbal_en
		parameter pcs_g3_rx_rx_ins_del_one_skip = "ins_del_one_skip_en", // ins_del_one_skip_dis|ins_del_one_skip_en
		parameter pcs_g3_rx_rx_lane_num = "lane_0", // lane_0|lane_1|lane_2|lane_3|lane_4|lane_5|lane_6|lane_7|not_used
		parameter pcs_g3_rx_rx_num_fixed_pat = "num_fixed_pat", // num_fixed_pat
		parameter pcs_g3_rx_rx_num_fixed_pat_data = 4'b100,
		parameter pcs_g3_rx_rx_pol_compl = "rx_pol_compl_dis", // rx_pol_compl_dis|rx_pol_compl_en
		parameter pcs_g3_rx_rx_test_out_sel = "rx_test_out0", // rx_test_out0|rx_test_out1
		parameter pcs_g3_rx_sup_mode = "user_mode", // user_mode|engr_mode
		parameter pcs_g3_rx_tx_clk_sel = "tx_pma_clk", // disable_clk|dig_clk2_8g|tx_pma_clk
		parameter pcs_g3_rx_use_default_base_address = "true", // false|true
		parameter pcs_g3_rx_user_base_address = 0, // 0..2047
		
		// parameters for stratixv_hssi_gen3_tx_pcs
		parameter pcs_g3_tx_encoder = "enable_encoder", // bypass_encoder|enable_encoder
		parameter pcs_g3_tx_mode = "gen3_func", // gen3_func|prbs|par_lpbk|disable_pcs
		parameter pcs_g3_tx_prbs_generator = "prbs_gen_dis", // prbs_gen_dis|prbs_gen_en
		parameter pcs_g3_tx_reverse_lpbk = "rev_lpbk_en", // rev_lpbk_dis|rev_lpbk_en
		parameter pcs_g3_tx_scrambler = "enable_scrambler", // bypass_scrambler|enable_scrambler
		parameter pcs_g3_tx_sup_mode = "user_mode", // user_mode|engr_mode
		parameter pcs_g3_tx_tx_bitslip = "tx_bitslip_val", // tx_bitslip_val
		parameter pcs_g3_tx_tx_bitslip_data = 5'b0,
		parameter pcs_g3_tx_tx_clk_sel = "tx_pma_clk", // disable_clk|dig_clk1_8g|tx_pma_clk
		parameter pcs_g3_tx_tx_g3_dcbal = "tx_g3_dcbal_en", // tx_g3_dcbal_dis|tx_g3_dcbal_en
		parameter pcs_g3_tx_tx_gbox_byp = "bypass_gbox", // bypass_gbox|enable_gbox
		parameter pcs_g3_tx_tx_lane_num = "lane_0", // lane_0|lane_1|lane_2|lane_3|lane_4|lane_5|lane_6|lane_7|not_used
		parameter pcs_g3_tx_tx_pol_compl = "tx_pol_compl_dis", // tx_pol_compl_dis|tx_pol_compl_en
		parameter pcs_g3_tx_use_default_base_address = "true", // false|true
		parameter pcs_g3_tx_user_base_address = 0, // 0..2047
		
		// parameters for stratixv_hssi_pipe_gen1_2
		// BONDING_PARAM: parameter pipe12_ctrl_plane_bonding_consumption = "individual", // individual|bundled_master|bundled_slave_below|bundled_slave_above
		parameter pipe12_elec_idle_delay_val = 3'b0,
		parameter pipe12_elecidle_delay = "elec_idle_delay", // elec_idle_delay
		parameter pipe12_error_replace_pad = "<auto_single>", // replace_edb|replace_pad
		parameter pipe12_hip_mode = "<auto_single>", // dis_hip|en_hip
		parameter pipe12_ind_error_reporting = "<auto_single>", // dis_ind_error_reporting|en_ind_error_reporting
		parameter pipe12_phy_status_delay = "phystatus_delay", // phystatus_delay
		parameter pipe12_phystatus_delay_val = 3'b0,
		parameter pipe12_phystatus_rst_toggle = "<auto_single>", // dis_phystatus_rst_toggle|en_phystatus_rst_toggle
		parameter pipe12_pipe_byte_de_serializer_en = "<auto_single>", // dis_bds|en_bds_by_2|dont_care_bds
		parameter pipe12_prot_mode = "<auto_single>", // pipe_g1|pipe_g2|pipe_g3|cpri|cpri_rx_tx|gige|xaui|srio_2p1|test|basic|disabled_prot_mode
		parameter pipe12_rpre_emph_a_val = 6'b0,
		parameter pipe12_rpre_emph_b_val = 6'b0,
		parameter pipe12_rpre_emph_c_val = 6'b0,
		parameter pipe12_rpre_emph_d_val = 6'b0,
		parameter pipe12_rpre_emph_e_val = 6'b0,
		parameter pipe12_rpre_emph_settings = 6'b0,
		parameter pipe12_rvod_sel_a_val = 6'b0,
		parameter pipe12_rvod_sel_b_val = 6'b0,
		parameter pipe12_rvod_sel_c_val = 6'b0,
		parameter pipe12_rvod_sel_d_val = 6'b0,
		parameter pipe12_rvod_sel_e_val = 6'b0,
		parameter pipe12_rvod_sel_settings = 6'b0,
		parameter pipe12_rx_pipe_enable = "<auto_single>", // dis_pipe_rx|en_pipe_rx|en_pipe3_rx
		parameter pipe12_rxdetect_bypass = "<auto_single>", // dis_rxdetect_bypass|en_rxdetect_bypass
		parameter pipe12_sup_mode = "user_mode", // user_mode|engineering_mode
		parameter pipe12_tx_pipe_enable = "<auto_single>", // dis_pipe_tx|en_pipe_tx|en_pipe3_tx
		parameter pipe12_txswing = "<auto_single>", // dis_txswing|en_txswing
		parameter pipe12_use_default_base_address = "true", // false|true
		parameter pipe12_user_base_address = 0, // 0..2047
		
		// parameters for stratixv_hssi_pipe_gen3
		parameter pipe3_asn_clk_enable = "<auto_single>", // false|true
		parameter pipe3_asn_enable = "<auto_single>", // dis_asn|en_asn
		parameter pipe3_bypass_pma_sw_done = "<auto_single>", // false|true
		parameter pipe3_bypass_rx_detection_enable = "<auto_single>", // false|true
		parameter pipe3_bypass_rx_preset = "rx_preset_bypass", // rx_preset_bypass
		parameter pipe3_bypass_rx_preset_data = 3'b0,
		parameter pipe3_bypass_rx_preset_enable = "<auto_single>", // false|true
		parameter pipe3_bypass_send_syncp_fbkp = "<auto_single>", // false|true
		parameter pipe3_bypass_tx_coefficent = "tx_coeff_bypass", // tx_coeff_bypass
		parameter pipe3_bypass_tx_coefficent_data = 18'b0,
		parameter pipe3_bypass_tx_coefficent_enable = "<auto_single>", // false|true
		parameter pipe3_cdr_control = "<auto_single>", // dis_cdr_ctrl|en_cdr_ctrl
		parameter pipe3_cid_enable = "<auto_single>", // dis_cid_mode|en_cid_mode
		// BONDING_PARAM: parameter pipe3_cp_cons_sel = "<auto_single>", // cp_cons_master|cp_cons_slave_abv|cp_cons_slave_blw|cp_cons_default
		// BONDING_PARAM: parameter pipe3_cp_dwn_mstr = "<auto_single>", // false|true
		// BONDING_PARAM: parameter pipe3_cp_up_mstr = "<auto_single>", // false|true
		// BONDING_PARAM: parameter pipe3_ctrl_plane_bonding = "<auto_single>", // individual|ctrl_master|ctrl_slave_blw|ctrl_slave_abv
		parameter pipe3_data_mask_count = "data_mask_count", // data_mask_count
		parameter pipe3_data_mask_count_val = 10'b0,
		parameter pipe3_elecidle_delay_g3 = "elecidle_delay_g3", // elecidle_delay_g3
		parameter pipe3_elecidle_delay_g3_data = 3'b0,
		parameter pipe3_free_run_clk_enable = "<auto_single>", // false|true
		parameter pipe3_ind_error_reporting = "<auto_single>", // dis_ind_error_reporting|en_ind_error_reporting
		parameter pipe3_inf_ei_enable = "<auto_single>", // dis_inf_ei|en_inf_ei
		parameter pipe3_mode = "<auto_single>", // pipe_g1|pipe_g2|pipe_g3|par_lpbk|disable_pcs
		parameter pipe3_parity_chk_ts1 = "<auto_single>", // en_ts1_parity_chk|dis_ts1_parity_chk
		parameter pipe3_pc_en_counter = "pc_en_count", // pc_en_count
		parameter pipe3_pc_en_counter_data = 7'b110111,
		parameter pipe3_pc_rst_counter = "pc_rst_count", // pc_rst_count
		parameter pipe3_pc_rst_counter_data = 5'b10111,
		parameter pipe3_ph_fifo_reg_mode = "<auto_single>", // phfifo_reg_mode_dis|phfifo_reg_mode_en
		parameter pipe3_phfifo_flush_wait = "phfifo_flush_wait", // phfifo_flush_wait
		parameter pipe3_phfifo_flush_wait_data = 6'b0,
		parameter pipe3_phy_status_delay_g12 = "phy_status_delay_g12", // phy_status_delay_g12
		parameter pipe3_phy_status_delay_g12_data = 3'b0,
		parameter pipe3_phy_status_delay_g3 = "phy_status_delay_g3", // phy_status_delay_g3
		parameter pipe3_phy_status_delay_g3_data = 3'b0,
		parameter pipe3_phystatus_rst_toggle_g12 = "<auto_single>", // dis_phystatus_rst_toggle|en_phystatus_rst_toggle
		parameter pipe3_phystatus_rst_toggle_g3 = "<auto_single>", // dis_phystatus_rst_toggle_g3|en_phystatus_rst_toggle_g3
		parameter pipe3_pipe_clk_sel = "<auto_single>", // disable_clk|dig_clk1_8g|func_clk
		parameter pipe3_pma_done_counter = "pma_done_count", // pma_done_count
		parameter pipe3_pma_done_counter_data = 18'b0,
		parameter pipe3_rate_match_pad_insertion = "<auto_single>", // dis_rm_fifo_pad_ins|en_rm_fifo_pad_ins
		parameter pipe3_rxvalid_mask = "<auto_single>", // rxvalid_mask_dis|rxvalid_mask_en
		parameter pipe3_sigdet_wait_counter = "sigdet_wait_counter", // sigdet_wait_counter
		parameter pipe3_sigdet_wait_counter_data = 8'b0,
		parameter pipe3_spd_chnge_g2_sel = "<auto_single>", // false|true
		parameter pipe3_sup_mode = "<auto_single>", // user_mode|engr_mode
		parameter pipe3_test_mode_timers = "<auto_single>", // dis_test_mode_timers|en_test_mode_timers
		parameter pipe3_test_out_sel = "<auto_single>", // tx_test_out|rx_test_out|pipe_test_out1|pipe_test_out2|pipe_test_out3|pipe_test_out4|pipe_ctrl_test_out1|pipe_ctrl_test_out2|pipe_ctrl_test_out3|disable
		parameter pipe3_use_default_base_address = "true", // false|true
		parameter pipe3_user_base_address = 0, // 0..2047
		parameter pipe3_wait_clk_on_off_timer = "wait_clk_on_off_timer", // wait_clk_on_off_timer
		parameter pipe3_wait_clk_on_off_timer_data = 4'b100,
		parameter pipe3_wait_pipe_synchronizing = "wait_pipe_sync", // wait_pipe_sync
		parameter pipe3_wait_pipe_synchronizing_data = 5'b10111,
		parameter pipe3_wait_send_syncp_fbkp = "wait_send_syncp_fbkp", // wait_send_syncp_fbkp
		parameter pipe3_wait_send_syncp_fbkp_data = 11'b11111010,
		
		// parameters for stratixv_hssi_rx_pcs_pma_interface
		parameter rx_pcs_pma_if_clkslip_sel = "<auto_single>", // pld|slip_eight_g_pcs
		parameter rx_pcs_pma_if_prot_mode = "<auto_single>", // other_protocols|cpri_8g
		parameter rx_pcs_pma_if_selectpcs = "eight_g_pcs", // eight_g_pcs|ten_g_pcs|pcie_gen3|default
		parameter rx_pcs_pma_if_use_default_base_address = "true", // false|true
		parameter rx_pcs_pma_if_user_base_address = 0, // 0..2047
		
		// parameters for stratixv_hssi_rx_pld_pcs_interface
		parameter rx_pld_pcs_if_data_source = "pld", // emsip|pld
		parameter rx_pld_pcs_if_is_10g_0ppm = "false", // false|true
		parameter rx_pld_pcs_if_is_8g_0ppm = "false", // false|true
		parameter rx_pld_pcs_if_selectpcs = "eight_g_pcs", // eight_g_pcs|ten_g_pcs|default
		parameter rx_pld_pcs_if_use_default_base_address = "true", // false|true
		parameter rx_pld_pcs_if_user_base_address = 0, // 0..2047
		
		// parameters for stratixv_hssi_tx_pcs_pma_interface
		parameter tx_pcs_pma_if_selectpcs = "eight_g_pcs", // eight_g_pcs|ten_g_pcs|pcie_gen3|default
		parameter tx_pcs_pma_if_use_default_base_address = "true", // false|true
		parameter tx_pcs_pma_if_user_base_address = 0, // 0..2047
		
		// parameters for stratixv_hssi_tx_pld_pcs_interface
		parameter tx_pld_pcs_if_data_source = "pld", // emsip|pld
		parameter tx_pld_pcs_if_is_10g_0ppm = "false", // false|true
		parameter tx_pld_pcs_if_is_8g_0ppm = "false", // false|true
		parameter tx_pld_pcs_if_use_default_base_address = "true", // false|true
		parameter tx_pld_pcs_if_user_base_address = 0 // 0..2047
	//PARAM_LIST_END
	)
	(
	//PORT_LIST_START
		input wire	[bonded_lanes - 1:0]	in_agg_align_status,
		input wire	[bonded_lanes - 1:0]	in_agg_align_status_sync_0,
		input wire	[bonded_lanes - 1:0]	in_agg_align_status_sync_0_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_align_status_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_cg_comp_rd_d_all,
		input wire	[bonded_lanes - 1:0]	in_agg_cg_comp_rd_d_all_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_cg_comp_wr_all,
		input wire	[bonded_lanes - 1:0]	in_agg_cg_comp_wr_all_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_del_cond_met_0,
		input wire	[bonded_lanes - 1:0]	in_agg_del_cond_met_0_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_en_dskw_qd,
		input wire	[bonded_lanes - 1:0]	in_agg_en_dskw_qd_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_en_dskw_rd_ptrs,
		input wire	[bonded_lanes - 1:0]	in_agg_en_dskw_rd_ptrs_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_fifo_ovr_0,
		input wire	[bonded_lanes - 1:0]	in_agg_fifo_ovr_0_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_fifo_rd_in_comp_0,
		input wire	[bonded_lanes - 1:0]	in_agg_fifo_rd_in_comp_0_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_fifo_rst_rd_qd,
		input wire	[bonded_lanes - 1:0]	in_agg_fifo_rst_rd_qd_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_insert_incomplete_0,
		input wire	[bonded_lanes - 1:0]	in_agg_insert_incomplete_0_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_latency_comp_0,
		input wire	[bonded_lanes - 1:0]	in_agg_latency_comp_0_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_rcvd_clk_agg,
		input wire	[bonded_lanes - 1:0]	in_agg_rcvd_clk_agg_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_rx_control_rs,
		input wire	[bonded_lanes - 1:0]	in_agg_rx_control_rs_top_or_bot,
		input wire	[bonded_lanes * 8 - 1 : 0]	in_agg_rx_data_rs,
		input wire	[bonded_lanes * 8 - 1 : 0]	in_agg_rx_data_rs_top_or_bot,
		input wire	[bonded_lanes - 1:0]	in_agg_test_so_to_pld_in,
		input wire	[bonded_lanes * 16 - 1 : 0]	in_agg_testbus,
		input wire	[bonded_lanes - 1:0]	in_agg_tx_ctl_ts,
		input wire	[bonded_lanes - 1:0]	in_agg_tx_ctl_ts_top_or_bot,
		input wire	[bonded_lanes * 8 - 1 : 0]	in_agg_tx_data_ts,
		input wire	[bonded_lanes * 8 - 1 : 0]	in_agg_tx_data_ts_top_or_bot,
		input wire	[bonded_lanes * 11 - 1 : 0]	in_avmmaddress,
		input wire	[bonded_lanes * 2 - 1 : 0]	in_avmmbyteen,
		input wire	[bonded_lanes - 1:0]	in_avmmclk,
		input wire	[bonded_lanes - 1:0]	in_avmmread,
		input wire	[bonded_lanes - 1:0]	in_avmmrstn,
		input wire	[bonded_lanes - 1:0]	in_avmmwrite,
		input wire	[bonded_lanes * 16 - 1 : 0]	in_avmmwritedata,
		input wire	[bonded_lanes * 38 - 1 : 0]	in_emsip_com_in,
		input wire	[bonded_lanes * 20 - 1 : 0]	in_emsip_com_special_in,
		input wire	[bonded_lanes * 3 - 1 : 0]	in_emsip_rx_clk_in,
		input wire	[bonded_lanes * 20 - 1 : 0]	in_emsip_rx_in,
		input wire	[bonded_lanes * 13 - 1 : 0]	in_emsip_rx_special_in,
		input wire	[bonded_lanes * 3 - 1 : 0]	in_emsip_tx_clk_in,
		input wire	[bonded_lanes * 104 - 1 : 0]	in_emsip_tx_in,
		input wire	[bonded_lanes * 13 - 1 : 0]	in_emsip_tx_special_in,
		input wire	[bonded_lanes - 1:0]	in_entest,
		input wire	[bonded_lanes - 1:0]	in_frzreg,
		input wire	[bonded_lanes - 1:0]	in_iocsr_rdy_dly,
		input wire	[bonded_lanes - 1:0]	in_nfrzdrv,
		input wire	[bonded_lanes - 1:0]	in_npor,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_refclk_dig,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_rx_align_clr,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_rx_align_en,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_rx_bitslip,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_rx_clr_ber_count,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_rx_clr_errblk_cnt,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_rx_disp_clr,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_rx_pld_clk,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_rx_prbs_err_clr,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_rx_rd_en,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_rx_rst_n,
		input wire	[bonded_lanes * 7 - 1 : 0]	in_pld_10g_tx_bitslip,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_tx_burst_en,
		input wire	[bonded_lanes * 9 - 1 : 0]	in_pld_10g_tx_control,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_tx_data_valid,
		input wire	[bonded_lanes * 2 - 1 : 0]	in_pld_10g_tx_diag_status,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_tx_pld_clk,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_tx_rst_n,
		input wire	[bonded_lanes - 1:0]	in_pld_10g_tx_wordslip,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_a1a2_size,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_bitloc_rev_en,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_bitslip,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_byte_rev_en,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_bytordpld,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_cmpfifourst_n,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_encdt,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_phfifourst_rx_n,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_phfifourst_tx_n,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_pld_rx_clk,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_pld_tx_clk,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_polinv_rx,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_polinv_tx,
		input wire	[bonded_lanes * 2 - 1 : 0]	in_pld_8g_powerdown,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_prbs_cid_en,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_rddisable_tx,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_rdenable_rmf,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_rdenable_rx,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_refclk_dig,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_refclk_dig2,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_rev_loopbk,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_rxpolarity,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_rxurstpcs_n,
		input wire	[bonded_lanes * 4 - 1 : 0]	in_pld_8g_tx_blk_start,
		input wire	[bonded_lanes * 5 - 1 : 0]	in_pld_8g_tx_boundary_sel,
		input wire	[bonded_lanes * 4 - 1 : 0]	in_pld_8g_tx_data_valid,
		input wire	[bonded_lanes * 2 - 1 : 0]	in_pld_8g_tx_sync_hdr,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_txdeemph,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_txdetectrxloopback,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_txelecidle,
		input wire	[bonded_lanes * 3 - 1 : 0]	in_pld_8g_txmargin,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_txswing,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_txurstpcs_n,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_wrdisable_rx,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_wrenable_rmf,
		input wire	[bonded_lanes - 1:0]	in_pld_8g_wrenable_tx,
		input wire	[bonded_lanes - 1:0]	in_pld_agg_refclk_dig,
		input wire	[bonded_lanes * 3 - 1 : 0]	in_pld_eidleinfersel,
		input wire	[bonded_lanes * 18 - 1 : 0]	in_pld_gen3_current_coeff,
		input wire	[bonded_lanes * 3 - 1 : 0]	in_pld_gen3_current_rxpreset,
		input wire	[bonded_lanes - 1:0]	in_pld_gen3_rx_rstn,
		input wire	[bonded_lanes - 1:0]	in_pld_gen3_tx_rstn,
		input wire	[bonded_lanes - 1:0]	in_pld_ltr,
		input wire	[bonded_lanes - 1:0]	in_pld_partial_reconfig_in,
		input wire	[bonded_lanes - 1:0]	in_pld_pcs_pma_if_refclk_dig,
		input wire	[bonded_lanes * 2 - 1 : 0]	in_pld_rate,
		input wire	[bonded_lanes * 12 - 1 : 0]	in_pld_reserved_in,
		input wire	[bonded_lanes - 1:0]	in_pld_rx_clk_slip_in,
		input wire	[bonded_lanes - 1:0]	in_pld_rxpma_rstb_in,
		input wire	[bonded_lanes - 1:0]	in_pld_scan_mode_n,
		input wire	[bonded_lanes - 1:0]	in_pld_scan_shift_n,
		input wire	[bonded_lanes - 1:0]	in_pld_sync_sm_en,
		input wire	[bonded_lanes * 64 - 1 : 0]	in_pld_tx_data,
		input wire	[bonded_lanes - 1:0]	in_plniotri,
		input wire	[bonded_lanes - 1:0]	in_pma_clkdiv33_lc_in,
		input wire	[bonded_lanes - 1:0]	in_pma_clkdiv33_txorrx_in,
		input wire	[bonded_lanes - 1:0]	in_pma_clklow_in,
		input wire	[bonded_lanes * 2 - 1 : 0]	in_pma_eye_monitor_in,
		input wire	[bonded_lanes - 1:0]	in_pma_fref_in,
		input wire	[bonded_lanes - 1:0]	in_pma_hclk,
		input wire	[bonded_lanes * 2 - 1 : 0]	in_pma_pcie_sw_done,
		input wire	[bonded_lanes * 5 - 1 : 0]	in_pma_reserved_in,
		input wire	[bonded_lanes * 80 - 1 : 0]	in_pma_rx_data,
		input wire	[bonded_lanes - 1:0]	in_pma_rx_detect_valid,
		input wire	[bonded_lanes - 1:0]	in_pma_rx_found,
		input wire	[bonded_lanes - 1:0]	in_pma_rx_freq_tx_cmu_pll_lock_in,
		input wire	[bonded_lanes - 1:0]	in_pma_rx_pll_phase_lock_in,
		input wire	[bonded_lanes - 1:0]	in_pma_rx_pma_clk,
		input wire	[bonded_lanes - 1:0]	in_pma_sigdet,
		input wire	[bonded_lanes - 1:0]	in_pma_signal_ok,
		input wire	[bonded_lanes - 1:0]	in_pma_tx_lc_pll_lock_in,
		input wire	[bonded_lanes - 1:0]	in_pma_tx_pma_clk,
		input wire	[bonded_lanes - 1:0]	in_usermode,
		output wire	[bonded_lanes * 2 - 1 : 0]	out_agg_align_det_sync,
		output wire	[bonded_lanes - 1:0]	out_agg_align_status_sync,
		output wire	[bonded_lanes * 2 - 1 : 0]	out_agg_cg_comp_rd_d_out,
		output wire	[bonded_lanes * 2 - 1 : 0]	out_agg_cg_comp_wr_out,
		output wire	[bonded_lanes - 1:0]	out_agg_dec_ctl,
		output wire	[bonded_lanes * 8 - 1 : 0]	out_agg_dec_data,
		output wire	[bonded_lanes - 1:0]	out_agg_dec_data_valid,
		output wire	[bonded_lanes - 1:0]	out_agg_del_cond_met_out,
		output wire	[bonded_lanes - 1:0]	out_agg_fifo_ovr_out,
		output wire	[bonded_lanes - 1:0]	out_agg_fifo_rd_out_comp,
		output wire	[bonded_lanes - 1:0]	out_agg_insert_incomplete_out,
		output wire	[bonded_lanes - 1:0]	out_agg_latency_comp_out,
		output wire	[bonded_lanes * 2 - 1 : 0]	out_agg_rd_align,
		output wire	[bonded_lanes - 1:0]	out_agg_rd_enable_sync,
		output wire	[bonded_lanes - 1:0]	out_agg_refclk_dig,
		output wire	[bonded_lanes * 2 - 1 : 0]	out_agg_running_disp,
		output wire	[bonded_lanes - 1:0]	out_agg_rxpcs_rst,
		output wire	[bonded_lanes - 1:0]	out_agg_scan_mode_n,
		output wire	[bonded_lanes - 1:0]	out_agg_scan_shift_n,
		output wire	[bonded_lanes - 1:0]	out_agg_sync_status,
		output wire	[bonded_lanes - 1:0]	out_agg_tx_ctl_tc,
		output wire	[bonded_lanes * 8 - 1 : 0]	out_agg_tx_data_tc,
		output wire	[bonded_lanes - 1:0]	out_agg_txpcs_rst,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_com_pcs_pma_if,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_com_pld_pcs_if,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_pcs10g_rx,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_pcs10g_tx,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_pcs8g_rx,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_pcs8g_tx,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_pcs_g3_rx,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_pcs_g3_tx,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_pipe12,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_pipe3,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_rx_pcs_pma_if,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_rx_pld_pcs_if,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_tx_pcs_pma_if,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_avmmreaddata_tx_pld_pcs_if,
		output wire	[bonded_lanes - 1:0]	out_blockselect_com_pcs_pma_if,
		output wire	[bonded_lanes - 1:0]	out_blockselect_com_pld_pcs_if,
		output wire	[bonded_lanes - 1:0]	out_blockselect_pcs10g_rx,
		output wire	[bonded_lanes - 1:0]	out_blockselect_pcs10g_tx,
		output wire	[bonded_lanes - 1:0]	out_blockselect_pcs8g_rx,
		output wire	[bonded_lanes - 1:0]	out_blockselect_pcs8g_tx,
		output wire	[bonded_lanes - 1:0]	out_blockselect_pcs_g3_rx,
		output wire	[bonded_lanes - 1:0]	out_blockselect_pcs_g3_tx,
		output wire	[bonded_lanes - 1:0]	out_blockselect_pipe12,
		output wire	[bonded_lanes - 1:0]	out_blockselect_pipe3,
		output wire	[bonded_lanes - 1:0]	out_blockselect_rx_pcs_pma_if,
		output wire	[bonded_lanes - 1:0]	out_blockselect_rx_pld_pcs_if,
		output wire	[bonded_lanes - 1:0]	out_blockselect_tx_pcs_pma_if,
		output wire	[bonded_lanes - 1:0]	out_blockselect_tx_pld_pcs_if,
		output wire	[bonded_lanes * 3 - 1 : 0]	out_emsip_com_clk_out,
		output wire	[bonded_lanes * 27 - 1 : 0]	out_emsip_com_out,
		output wire	[bonded_lanes * 20 - 1 : 0]	out_emsip_com_special_out,
		output wire	[bonded_lanes * 3 - 1 : 0]	out_emsip_rx_clk_out,
		output wire	[bonded_lanes * 129 - 1 : 0]	out_emsip_rx_out,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_emsip_rx_special_out,
		output wire	[bonded_lanes * 3 - 1 : 0]	out_emsip_tx_clk_out,
		output wire	[bonded_lanes * 12 - 1 : 0]	out_emsip_tx_out,
		output wire	[bonded_lanes * 16 - 1 : 0]	out_emsip_tx_special_out,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_align_val,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_blk_lock,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_clk_out,
		output wire	[bonded_lanes * 10 - 1 : 0]	out_pld_10g_rx_control,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_crc32_err,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_data_valid,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_diag_err,
		output wire	[bonded_lanes * 2 - 1 : 0]	out_pld_10g_rx_diag_status,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_empty,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_fifo_del,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_fifo_insert,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_frame_lock,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_hi_ber,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_mfrm_err,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_oflw_err,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_pempty,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_pfull,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_prbs_err,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_pyld_ins,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_rdneg_sts,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_rdpos_sts,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_rx_frame,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_scrm_err,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_sh_err,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_skip_err,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_skip_ins,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_rx_sync_err,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_tx_burst_en_exe,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_tx_clk_out,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_tx_empty,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_tx_fifo_del,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_tx_fifo_insert,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_tx_frame,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_tx_full,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_tx_pempty,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_tx_pfull,
		output wire	[bonded_lanes - 1:0]	out_pld_10g_tx_wordslip_exe,
		output wire	[bonded_lanes * 4 - 1 : 0]	out_pld_8g_a1a2_k1k2_flag,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_align_status,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_bistdone,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_bisterr,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_byteord_flag,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_empty_rmf,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_empty_rx,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_empty_tx,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_full_rmf,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_full_rx,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_full_tx,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_phystatus,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_rlv_lt,
		output wire	[bonded_lanes * 4 - 1 : 0]	out_pld_8g_rx_blk_start,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_rx_clk_out,
		output wire	[bonded_lanes * 4 - 1 : 0]	out_pld_8g_rx_data_valid,
		output wire	[bonded_lanes * 2 - 1 : 0]	out_pld_8g_rx_sync_hdr,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_rxelecidle,
		output wire	[bonded_lanes * 3 - 1 : 0]	out_pld_8g_rxstatus,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_rxvalid,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_signal_detect_out,
		output wire	[bonded_lanes - 1:0]	out_pld_8g_tx_clk_out,
		output wire	[bonded_lanes * 5 - 1 : 0]	out_pld_8g_wa_boundary,
		output wire	[bonded_lanes - 1:0]	out_pld_clkdiv33_lc,
		output wire	[bonded_lanes - 1:0]	out_pld_clkdiv33_txorrx,
		output wire	[bonded_lanes - 1:0]	out_pld_clklow,
		output wire	[bonded_lanes - 1:0]	out_pld_fref,
		output wire	[bonded_lanes - 1:0]	out_pld_gen3_mask_tx_pll,
		output wire	[bonded_lanes * 2 - 1 : 0]	out_pld_gen3_rx_eq_ctrl,
		output wire	[bonded_lanes * 18 - 1 : 0]	out_pld_gen3_rxdeemph,
		output wire	[bonded_lanes * 11 - 1 : 0]	out_pld_reserved_out,
		output wire	[bonded_lanes * 64 - 1 : 0]	out_pld_rx_data,
		output wire	[bonded_lanes * 20 - 1 : 0]	out_pld_test_data,
		output wire	[bonded_lanes - 1:0]	out_pld_test_si_to_agg_out,
		output wire	[bonded_lanes * 18 - 1 : 0]	out_pma_current_coeff,
		output wire	[bonded_lanes * 3 - 1 : 0]	out_pma_current_rxpreset,
		output wire	[bonded_lanes - 1:0]	out_pma_early_eios,
		output wire	[bonded_lanes * 8 - 1 : 0]	out_pma_eye_monitor_out,
		output wire	[bonded_lanes - 1:0]	out_pma_lc_cmu_rstb,
		output wire	[bonded_lanes - 1:0]	out_pma_ltr,
		output wire	[bonded_lanes - 1:0]	out_pma_nfrzdrv,
		output wire	[bonded_lanes - 1:0]	out_pma_partial_reconfig,
		output wire	[bonded_lanes * 2 - 1 : 0]	out_pma_pcie_switch,
		output wire	[bonded_lanes - 1:0]	out_pma_ppm_lock,
		output wire	[bonded_lanes * 5 - 1 : 0]	out_pma_reserved_out,
		output wire	[bonded_lanes - 1:0]	out_pma_rx_clk_out,
		output wire	[bonded_lanes - 1:0]	out_pma_rxclkslip,
		output wire	[bonded_lanes - 1:0]	out_pma_rxpma_rstb,
		output wire	[bonded_lanes - 1:0]	out_pma_tx_clk_out,
		output wire	[bonded_lanes * 80 - 1 : 0]	out_pma_tx_data,
		output wire	[bonded_lanes - 1:0]	out_pma_tx_elec_idle,
		output wire	[bonded_lanes - 1:0]	out_pma_tx_pma_syncp_fbkp,
		output wire	[bonded_lanes - 1:0]	out_pma_txdetectrx
	//PORT_LIST_END
	);
	//wire declarations for bonded connections
	
	// module stratixv_hssi_8g_rx_pcs
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_rx_rdenableoutchnlup;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_rx_configseloutchnlup;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_rx_resetppmcntrsoutchnlup;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_rx_wrenableoutchnlup;
	wire [(bonded_lanes + 2) * 2 - 1 : 0] w_pcs8g_rx_rxdivsyncoutchnlup;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_rx_speedchangeoutchnlup;
	wire [(bonded_lanes + 2) * 2 - 1 : 0] w_pcs8g_rx_rxweoutchnlup;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_rx_resetpcptrsoutchnlup;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_rx_wrenableoutchnldown;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_rx_resetpcptrsoutchnldown;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_rx_speedchangeoutchnldown;
	wire [(bonded_lanes + 2) * 2 - 1 : 0] w_pcs8g_rx_rxweoutchnldown;
	wire [(bonded_lanes + 2) * 2 - 1 : 0] w_pcs8g_rx_rxdivsyncoutchnldown;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_rx_resetppmcntrsoutchnldown;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_rx_rdenableoutchnldown;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_rx_configseloutchnldown;
	
	// module stratixv_hssi_8g_tx_pcs
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_tx_wrenableoutchnlup;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_tx_rdenableoutchnlup;
	wire [(bonded_lanes + 2) * 2 - 1 : 0] w_pcs8g_tx_fifoselectoutchnlup;
	wire [(bonded_lanes + 2) * 2 - 1 : 0] w_pcs8g_tx_txdivsyncoutchnlup;
	wire [(bonded_lanes + 2) * 2 - 1 : 0] w_pcs8g_tx_fifoselectoutchnldown;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_tx_wrenableoutchnldown;
	wire [(bonded_lanes + 2) * 2 - 1 : 0] w_pcs8g_tx_txdivsyncoutchnldown;
	wire [(bonded_lanes + 2)- 1:0] w_pcs8g_tx_rdenableoutchnldown;
	
	// module stratixv_hssi_pipe_gen3
	wire [(bonded_lanes + 2) * 11 - 1 : 0] w_pipe3_bundlingoutup;
	wire [(bonded_lanes + 2) * 11 - 1 : 0] w_pipe3_bundlingoutdown;
	
	// module stratixv_hssi_10g_tx_pcs
	wire [(bonded_lanes + 2)- 1:0] w_pcs10g_tx_distupoutdv;
	wire [(bonded_lanes + 2)- 1:0] w_pcs10g_tx_distupoutintlknrden;
	wire [(bonded_lanes + 2)- 1:0] w_pcs10g_tx_distupoutrden;
	wire [(bonded_lanes + 2)- 1:0] w_pcs10g_tx_distupoutrdpfull;
	wire [(bonded_lanes + 2)- 1:0] w_pcs10g_tx_distupoutwren;
	wire [(bonded_lanes + 2)- 1:0] w_pcs10g_tx_distdwnoutrden;
	wire [(bonded_lanes + 2)- 1:0] w_pcs10g_tx_distdwnoutdv;
	wire [(bonded_lanes + 2)- 1:0] w_pcs10g_tx_distdwnoutwren;
	wire [(bonded_lanes + 2)- 1:0] w_pcs10g_tx_distdwnoutrdpfull;
	wire [(bonded_lanes + 2)- 1:0] w_pcs10g_tx_distdwnoutintlknrden;
	
	
	// instantiation of sv_pcs_ch
	genvar i;
	generate
	for (i=0; i < bonded_lanes; i = i + 1)
	begin:ch
 
  // to pass lane number as scrambler seed  
  localparam [MAX_CHARS*8-1 :0] RX_LANE_NUM = altera_xcvr_functions::get_value_at_index(i,pcs_g3_rx_rx_lane_num);
  localparam [MAX_CHARS*8-1 :0] TX_LANE_NUM = altera_xcvr_functions::get_value_at_index(i,pcs_g3_tx_tx_lane_num);

		sv_pcs_ch #(
			// parameters
			.enable_10g_rx (enable_10g_rx),
			.enable_10g_tx (enable_10g_tx),
			.enable_8g_rx (enable_8g_rx),
			.enable_8g_tx (enable_8g_tx),
			.enable_dyn_reconfig (enable_dyn_reconfig),
			.enable_gen12_pipe (enable_gen12_pipe),
			.enable_gen3_pipe (enable_gen3_pipe),
			.enable_gen3_rx (enable_gen3_rx),
			.enable_gen3_tx (enable_gen3_tx),
			.enable_pma_direct_tx (enable_pma_direct_tx),
			.enable_pma_direct_rx (enable_pma_direct_rx),	   	   			    
			.channel_number (i),
			
			// parameters for stratixv_hssi_10g_rx_pcs
			.pcs10g_rx_align_del(pcs10g_rx_align_del),
			.pcs10g_rx_ber_bit_err_total_cnt(pcs10g_rx_ber_bit_err_total_cnt),
			.pcs10g_rx_ber_clken(pcs10g_rx_ber_clken),
			.pcs10g_rx_ber_xus_timer_window(pcs10g_rx_ber_xus_timer_window),
			.pcs10g_rx_ber_xus_timer_window_user(pcs10g_rx_ber_xus_timer_window_user),
			.pcs10g_rx_bit_reverse(pcs10g_rx_bit_reverse),
			.pcs10g_rx_bitslip_mode(pcs10g_rx_bitslip_mode),
			//.pcs10g_rx_bitslip_wait_cnt_user(pcs10g_rx_bitslip_wait_cnt_user),
			.pcs10g_rx_blksync_bitslip_type(pcs10g_rx_blksync_bitslip_type),
			.pcs10g_rx_blksync_bitslip_wait_cnt(pcs10g_rx_blksync_bitslip_wait_cnt),
			.pcs10g_rx_blksync_bitslip_wait_cnt_user(pcs10g_rx_blksync_bitslip_wait_cnt_user),
			.pcs10g_rx_blksync_bitslip_wait_type(pcs10g_rx_blksync_bitslip_wait_type),
			.pcs10g_rx_blksync_bypass(pcs10g_rx_blksync_bypass),
			.pcs10g_rx_blksync_clken(pcs10g_rx_blksync_clken),
			.pcs10g_rx_blksync_enum_invalid_sh_cnt(pcs10g_rx_blksync_enum_invalid_sh_cnt),
			.pcs10g_rx_blksync_knum_sh_cnt_postlock(pcs10g_rx_blksync_knum_sh_cnt_postlock),
			.pcs10g_rx_blksync_knum_sh_cnt_prelock(pcs10g_rx_blksync_knum_sh_cnt_prelock),
			.pcs10g_rx_blksync_pipeln(pcs10g_rx_blksync_pipeln),
			.pcs10g_rx_control_del(pcs10g_rx_control_del),
			.pcs10g_rx_crcchk_bypass(pcs10g_rx_crcchk_bypass),
			.pcs10g_rx_crcchk_clken(pcs10g_rx_crcchk_clken),
			.pcs10g_rx_crcchk_init(pcs10g_rx_crcchk_init),
			//.pcs10g_rx_crcchk_init_user(pcs10g_rx_crcchk_init_user),
			.pcs10g_rx_crcchk_inv(pcs10g_rx_crcchk_inv),
			.pcs10g_rx_crcchk_pipeln(pcs10g_rx_crcchk_pipeln),
			.pcs10g_rx_crcflag_pipeln(pcs10g_rx_crcflag_pipeln),
			.pcs10g_rx_ctrl_bit_reverse(pcs10g_rx_ctrl_bit_reverse),
			.pcs10g_rx_data_bit_reverse(pcs10g_rx_data_bit_reverse),
			.pcs10g_rx_dec64b66b_clken(pcs10g_rx_dec64b66b_clken),
			.pcs10g_rx_dec_64b66b_rxsm_bypass(pcs10g_rx_dec_64b66b_rxsm_bypass),
			.pcs10g_rx_descrm_bypass(pcs10g_rx_descrm_bypass),
			.pcs10g_rx_descrm_clken(pcs10g_rx_descrm_clken),
			.pcs10g_rx_descrm_mode(pcs10g_rx_descrm_mode),
			.pcs10g_rx_dis_signal_ok(pcs10g_rx_dis_signal_ok),
			.pcs10g_rx_dispchk_bypass(pcs10g_rx_dispchk_bypass),
			.pcs10g_rx_dispchk_clken(pcs10g_rx_dispchk_clken),
			.pcs10g_rx_dispchk_pipeln(pcs10g_rx_dispchk_pipeln),
			.pcs10g_rx_dispchk_rd_level(pcs10g_rx_dispchk_rd_level),
			//.pcs10g_rx_dispchk_rd_level_user(pcs10g_rx_dispchk_rd_level_user),
			.pcs10g_rx_empty_flag_type(pcs10g_rx_empty_flag_type),
			.pcs10g_rx_fast_path(pcs10g_rx_fast_path),
			.pcs10g_rx_fifo_stop_rd(pcs10g_rx_fifo_stop_rd),
			.pcs10g_rx_fifo_stop_wr(pcs10g_rx_fifo_stop_wr),
			.pcs10g_rx_force_align(pcs10g_rx_force_align),
			.pcs10g_rx_frmgen_diag_word(pcs10g_rx_frmgen_diag_word),
			.pcs10g_rx_frmgen_scrm_word(pcs10g_rx_frmgen_scrm_word),
			.pcs10g_rx_frmgen_skip_word(pcs10g_rx_frmgen_skip_word),
			.pcs10g_rx_frmgen_sync_word(pcs10g_rx_frmgen_sync_word),
			.pcs10g_rx_frmsync_bypass(pcs10g_rx_frmsync_bypass),
			.pcs10g_rx_frmsync_clken(pcs10g_rx_frmsync_clken),
			.pcs10g_rx_frmsync_enum_scrm(pcs10g_rx_frmsync_enum_scrm),
			.pcs10g_rx_frmsync_enum_sync(pcs10g_rx_frmsync_enum_sync),
			.pcs10g_rx_frmsync_flag_type(pcs10g_rx_frmsync_flag_type),
			.pcs10g_rx_frmsync_knum_sync(pcs10g_rx_frmsync_knum_sync),
			.pcs10g_rx_frmsync_mfrm_length(pcs10g_rx_frmsync_mfrm_length),
			.pcs10g_rx_frmsync_mfrm_length_user(pcs10g_rx_frmsync_mfrm_length_user),
			.pcs10g_rx_frmsync_pipeln(pcs10g_rx_frmsync_pipeln),
			.pcs10g_rx_full_flag_type(pcs10g_rx_full_flag_type),
			.pcs10g_rx_gb_rx_idwidth(pcs10g_rx_gb_rx_idwidth),
			.pcs10g_rx_gb_rx_odwidth(pcs10g_rx_gb_rx_odwidth),
			.pcs10g_rx_gb_sel_mode(pcs10g_rx_gb_sel_mode),
			.pcs10g_rx_gbexp_clken(pcs10g_rx_gbexp_clken),
			.pcs10g_rx_iqtxrx_clkout_sel(pcs10g_rx_iqtxrx_clkout_sel),
			.pcs10g_rx_lpbk_mode(pcs10g_rx_lpbk_mode),
			.pcs10g_rx_master_clk_sel(pcs10g_rx_master_clk_sel),
			.pcs10g_rx_pempty_flag_type(pcs10g_rx_pempty_flag_type),
			.pcs10g_rx_pfull_flag_type(pcs10g_rx_pfull_flag_type),
			.pcs10g_rx_prbs_clken(pcs10g_rx_prbs_clken),
			.pcs10g_rx_prot_mode(pcs10g_rx_prot_mode),
			.pcs10g_rx_rand_clken(pcs10g_rx_rand_clken),
			.pcs10g_rx_rd_clk_sel(pcs10g_rx_rd_clk_sel),
			.pcs10g_rx_rdfifo_clken(pcs10g_rx_rdfifo_clken),
			.pcs10g_rx_rx_dfx_lpbk(pcs10g_rx_rx_dfx_lpbk),
			.pcs10g_rx_rx_fifo_write_ctrl(pcs10g_rx_rx_fifo_write_ctrl),
			.pcs10g_rx_rx_polarity_inv(pcs10g_rx_rx_polarity_inv),
			.pcs10g_rx_rx_prbs_mask(pcs10g_rx_rx_prbs_mask),
			.pcs10g_rx_rx_scrm_width(pcs10g_rx_rx_scrm_width),
			.pcs10g_rx_rx_sh_location(pcs10g_rx_rx_sh_location),
			.pcs10g_rx_rx_signal_ok_sel(pcs10g_rx_rx_signal_ok_sel),
			.pcs10g_rx_rx_sm_bypass(pcs10g_rx_rx_sm_bypass),
			.pcs10g_rx_rx_sm_hiber(pcs10g_rx_rx_sm_hiber),
			.pcs10g_rx_rx_sm_pipeln(pcs10g_rx_rx_sm_pipeln),
			.pcs10g_rx_rx_testbus_sel(pcs10g_rx_rx_testbus_sel),
			.pcs10g_rx_rx_true_b2b(pcs10g_rx_rx_true_b2b),
			.pcs10g_rx_rxfifo_empty(pcs10g_rx_rxfifo_empty),
			.pcs10g_rx_rxfifo_full(pcs10g_rx_rxfifo_full),
			.pcs10g_rx_rxfifo_mode(pcs10g_rx_rxfifo_mode),
			.pcs10g_rx_rxfifo_pempty(pcs10g_rx_rxfifo_pempty),
			.pcs10g_rx_rxfifo_pfull(pcs10g_rx_rxfifo_pfull),
			.pcs10g_rx_skip_ctrl(pcs10g_rx_skip_ctrl),
			//.pcs10g_rx_stretch_en(pcs10g_rx_stretch_en),
			.pcs10g_rx_stretch_num_stages(pcs10g_rx_stretch_num_stages),
			.pcs10g_rx_stretch_type(pcs10g_rx_stretch_type),
			.pcs10g_rx_sup_mode(pcs10g_rx_sup_mode),
			.pcs10g_rx_test_bus_mode(pcs10g_rx_test_bus_mode),
			.pcs10g_rx_test_mode(pcs10g_rx_test_mode),
			.pcs10g_rx_use_default_base_address(pcs10g_rx_use_default_base_address),
			.pcs10g_rx_user_base_address(pcs10g_rx_user_base_address),
			.pcs10g_rx_wrfifo_clken(pcs10g_rx_wrfifo_clken),
			
			// parameters for stratixv_hssi_10g_tx_pcs
			.pcs10g_tx_bit_reverse(pcs10g_tx_bit_reverse),
			.pcs10g_tx_bitslip_en(pcs10g_tx_bitslip_en),
			.pcs10g_tx_comp_cnt(pcs10g_tx_comp_cnt),
			//.pcs10g_tx_comp_del_sel_agg(pcs10g_tx_comp_del_sel_agg),
			.pcs10g_tx_compin_sel(pcs10g_tx_compin_sel),
			.pcs10g_tx_compin_sel_agg(pcs10g_tx_compin_sel_agg),
			.pcs10g_tx_crcgen_bypass(pcs10g_tx_crcgen_bypass),
			.pcs10g_tx_crcgen_clken(pcs10g_tx_crcgen_clken),
			.pcs10g_tx_crcgen_err(pcs10g_tx_crcgen_err),
			.pcs10g_tx_crcgen_init(pcs10g_tx_crcgen_init),
			//.pcs10g_tx_crcgen_init_user(pcs10g_tx_crcgen_init_user),
			.pcs10g_tx_crcgen_inv(pcs10g_tx_crcgen_inv),
			.pcs10g_tx_ctrl_bit_reverse(pcs10g_tx_ctrl_bit_reverse),
			.pcs10g_tx_ctrl_plane_bonding(
(pcs10g_tx_prot_mode == "interlaken_mode" || pcs10g_tx_prot_mode == "basic_mode") ? 
    ((bonded_lanes==1) ? "individual" : 
         (i==bonding_master_ch) ? "ctrl_master" : 
              (i < bonding_master_ch) ? "ctrl_slave_blw" : 
                                           "ctrl_slave_abv") : 
   "individual"
),
			.pcs10g_tx_data_agg_bonding(pcs10g_tx_data_agg_bonding),
			.pcs10g_tx_data_agg_comp(pcs10g_tx_data_agg_comp),
			.pcs10g_tx_data_bit_reverse(pcs10g_tx_data_bit_reverse),
			.pcs10g_tx_del_sel_frame_gen(pcs10g_tx_del_sel_frame_gen),
			.pcs10g_tx_dispgen_bypass(pcs10g_tx_dispgen_bypass),
			.pcs10g_tx_dispgen_clken(pcs10g_tx_dispgen_clken),
			.pcs10g_tx_dispgen_err(pcs10g_tx_dispgen_err),
			.pcs10g_tx_dispgen_pipeln(pcs10g_tx_dispgen_pipeln),
			.pcs10g_tx_distdwn_bypass_pipeln(pcs10g_tx_distdwn_bypass_pipeln),
			.pcs10g_tx_distdwn_bypass_pipeln_agg(pcs10g_tx_distdwn_bypass_pipeln_agg),
			.pcs10g_tx_distdwn_master(pcs10g_tx_distdwn_master),
			.pcs10g_tx_distdwn_master_agg(pcs10g_tx_distdwn_master_agg),
			.pcs10g_tx_distup_bypass_pipeln(pcs10g_tx_distup_bypass_pipeln),
			.pcs10g_tx_distup_bypass_pipeln_agg(pcs10g_tx_distup_bypass_pipeln_agg),
			.pcs10g_tx_distup_master(pcs10g_tx_distup_master),
			.pcs10g_tx_distup_master_agg(pcs10g_tx_distup_master_agg),
			.pcs10g_tx_empty_flag_type(pcs10g_tx_empty_flag_type),
			.pcs10g_tx_enc64b66b_txsm_clken(pcs10g_tx_enc64b66b_txsm_clken),
			.pcs10g_tx_enc_64b66b_txsm_bypass(pcs10g_tx_enc_64b66b_txsm_bypass),
			.pcs10g_tx_fastpath(pcs10g_tx_fastpath),
			.pcs10g_tx_fifo_stop_rd(pcs10g_tx_fifo_stop_rd),
			.pcs10g_tx_fifo_stop_wr(pcs10g_tx_fifo_stop_wr),
			.pcs10g_tx_frmgen_burst(pcs10g_tx_frmgen_burst),
			.pcs10g_tx_frmgen_bypass(pcs10g_tx_frmgen_bypass),
			.pcs10g_tx_frmgen_clken(pcs10g_tx_frmgen_clken),
			.pcs10g_tx_frmgen_diag_word(pcs10g_tx_frmgen_diag_word),
			.pcs10g_tx_frmgen_mfrm_length(pcs10g_tx_frmgen_mfrm_length),
			.pcs10g_tx_frmgen_mfrm_length_user(pcs10g_tx_frmgen_mfrm_length_user),
			.pcs10g_tx_frmgen_pipeln(pcs10g_tx_frmgen_pipeln),
			.pcs10g_tx_frmgen_pyld_ins(pcs10g_tx_frmgen_pyld_ins),
			.pcs10g_tx_frmgen_scrm_word(pcs10g_tx_frmgen_scrm_word),
			.pcs10g_tx_frmgen_skip_word(pcs10g_tx_frmgen_skip_word),
			.pcs10g_tx_frmgen_sync_word(pcs10g_tx_frmgen_sync_word),
			.pcs10g_tx_frmgen_wordslip(pcs10g_tx_frmgen_wordslip),
			.pcs10g_tx_full_flag_type(pcs10g_tx_full_flag_type),
			.pcs10g_tx_gb_sel_mode(pcs10g_tx_gb_sel_mode),
			.pcs10g_tx_gb_tx_idwidth(pcs10g_tx_gb_tx_idwidth),
			.pcs10g_tx_gb_tx_odwidth(pcs10g_tx_gb_tx_odwidth),
			.pcs10g_tx_gbred_clken(pcs10g_tx_gbred_clken),
			.pcs10g_tx_indv(pcs10g_tx_indv),
			.pcs10g_tx_iqtxrx_clkout_sel(pcs10g_tx_iqtxrx_clkout_sel),
			.pcs10g_tx_master_clk_sel(pcs10g_tx_master_clk_sel),
			.pcs10g_tx_pempty_flag_type(pcs10g_tx_pempty_flag_type),
			.pcs10g_tx_pfull_flag_type(pcs10g_tx_pfull_flag_type),
			.pcs10g_tx_phcomp_rd_del(pcs10g_tx_phcomp_rd_del),
			.pcs10g_tx_pmagate_en(pcs10g_tx_pmagate_en),
			.pcs10g_tx_prbs_clken(pcs10g_tx_prbs_clken),
			.pcs10g_tx_prot_mode(pcs10g_tx_prot_mode),
			.pcs10g_tx_pseudo_random(pcs10g_tx_pseudo_random),
			.pcs10g_tx_pseudo_seed_a(pcs10g_tx_pseudo_seed_a),
			.pcs10g_tx_pseudo_seed_a_user(pcs10g_tx_pseudo_seed_a_user),
			.pcs10g_tx_pseudo_seed_b(pcs10g_tx_pseudo_seed_b),
			.pcs10g_tx_pseudo_seed_b_user(pcs10g_tx_pseudo_seed_b_user),
			.pcs10g_tx_rdfifo_clken(pcs10g_tx_rdfifo_clken),
			.pcs10g_tx_scrm_bypass(pcs10g_tx_scrm_bypass),
			.pcs10g_tx_scrm_clken(pcs10g_tx_scrm_clken),
			.pcs10g_tx_scrm_mode(pcs10g_tx_scrm_mode),
			.pcs10g_tx_scrm_seed(pcs10g_tx_scrm_seed),
			.pcs10g_tx_scrm_seed_user(pcs10g_tx_scrm_seed_user),
			.pcs10g_tx_sh_err(pcs10g_tx_sh_err),
			.pcs10g_tx_skip_ctrl(pcs10g_tx_skip_ctrl),
			.pcs10g_tx_sq_wave(pcs10g_tx_sq_wave),
			.pcs10g_tx_sqwgen_clken(pcs10g_tx_sqwgen_clken),
			//.pcs10g_tx_stretch_en(pcs10g_tx_stretch_en),
			.pcs10g_tx_stretch_num_stages(pcs10g_tx_stretch_num_stages),
			.pcs10g_tx_stretch_type(pcs10g_tx_stretch_type),
			.pcs10g_tx_sup_mode(pcs10g_tx_sup_mode),
			.pcs10g_tx_test_bus_mode(pcs10g_tx_test_bus_mode),
			.pcs10g_tx_test_mode(pcs10g_tx_test_mode),
			.pcs10g_tx_tx_polarity_inv(pcs10g_tx_tx_polarity_inv),
			.pcs10g_tx_tx_scrm_err(pcs10g_tx_tx_scrm_err),
			.pcs10g_tx_tx_scrm_width(pcs10g_tx_tx_scrm_width),
			.pcs10g_tx_tx_sh_location(pcs10g_tx_tx_sh_location),
			.pcs10g_tx_tx_sm_bypass(pcs10g_tx_tx_sm_bypass),
			.pcs10g_tx_tx_sm_pipeln(pcs10g_tx_tx_sm_pipeln),
			.pcs10g_tx_tx_testbus_sel(pcs10g_tx_tx_testbus_sel),
			.pcs10g_tx_tx_true_b2b(pcs10g_tx_tx_true_b2b),
			.pcs10g_tx_txfifo_empty(pcs10g_tx_txfifo_empty),
			.pcs10g_tx_txfifo_full(pcs10g_tx_txfifo_full),
			.pcs10g_tx_txfifo_mode(pcs10g_tx_txfifo_mode),
			.pcs10g_tx_txfifo_pempty(pcs10g_tx_txfifo_pempty),
			.pcs10g_tx_txfifo_pfull(pcs10g_tx_txfifo_pfull),
			.pcs10g_tx_use_default_base_address(pcs10g_tx_use_default_base_address),
			.pcs10g_tx_user_base_address(pcs10g_tx_user_base_address),
			.pcs10g_tx_wr_clk_sel(pcs10g_tx_wr_clk_sel),
			.pcs10g_tx_wrfifo_clken(pcs10g_tx_wrfifo_clken),
			
			// parameters for stratixv_hssi_8g_rx_pcs
			.pcs8g_rx_agg_block_sel(pcs8g_rx_agg_block_sel),
			//.pcs8g_rx_auto_deassert_pc_rst_cnt_data(pcs8g_rx_auto_deassert_pc_rst_cnt_data),
			.pcs8g_rx_auto_error_replacement(pcs8g_rx_auto_error_replacement),
			//.pcs8g_rx_auto_pc_en_cnt_data(pcs8g_rx_auto_pc_en_cnt_data),
			.pcs8g_rx_auto_speed_nego(pcs8g_rx_auto_speed_nego),
			.pcs8g_rx_bist_ver(pcs8g_rx_bist_ver),
			.pcs8g_rx_bist_ver_clr_flag(pcs8g_rx_bist_ver_clr_flag),
			.pcs8g_rx_bit_reversal(pcs8g_rx_bit_reversal),
			.pcs8g_rx_bo_pad(pcs8g_rx_bo_pad),
			.pcs8g_rx_bo_pattern(pcs8g_rx_bo_pattern),
			.pcs8g_rx_bypass_pipeline_reg(pcs8g_rx_bypass_pipeline_reg),
			.pcs8g_rx_byte_deserializer(pcs8g_rx_byte_deserializer),
			.pcs8g_rx_byte_order(pcs8g_rx_byte_order),
			.pcs8g_rx_cdr_ctrl(pcs8g_rx_cdr_ctrl),
			.pcs8g_rx_cdr_ctrl_rxvalid_mask(pcs8g_rx_cdr_ctrl_rxvalid_mask),
			.pcs8g_rx_cid_pattern(pcs8g_rx_cid_pattern),
			.pcs8g_rx_cid_pattern_len(pcs8g_rx_cid_pattern_len),
			.pcs8g_rx_clkcmp_pattern_n(pcs8g_rx_clkcmp_pattern_n),
			.pcs8g_rx_clkcmp_pattern_p(pcs8g_rx_clkcmp_pattern_p),
			.pcs8g_rx_clock_gate_bds_dec_asn(pcs8g_rx_clock_gate_bds_dec_asn),
			.pcs8g_rx_clock_gate_bist(pcs8g_rx_clock_gate_bist),
			.pcs8g_rx_clock_gate_byteorder(pcs8g_rx_clock_gate_byteorder),
			.pcs8g_rx_clock_gate_cdr_eidle(pcs8g_rx_clock_gate_cdr_eidle),
			.pcs8g_rx_clock_gate_dskw_rd(pcs8g_rx_clock_gate_dskw_rd),
			.pcs8g_rx_clock_gate_dw_dskw_wr(pcs8g_rx_clock_gate_dw_dskw_wr),
			.pcs8g_rx_clock_gate_dw_pc_wrclk(pcs8g_rx_clock_gate_dw_pc_wrclk),
			.pcs8g_rx_clock_gate_dw_rm_rd(pcs8g_rx_clock_gate_dw_rm_rd),
			.pcs8g_rx_clock_gate_dw_rm_wr(pcs8g_rx_clock_gate_dw_rm_wr),
			.pcs8g_rx_clock_gate_dw_wa(pcs8g_rx_clock_gate_dw_wa),
			.pcs8g_rx_clock_gate_pc_rdclk(pcs8g_rx_clock_gate_pc_rdclk),
			.pcs8g_rx_clock_gate_prbs(pcs8g_rx_clock_gate_prbs),
			.pcs8g_rx_clock_gate_sw_dskw_wr(pcs8g_rx_clock_gate_sw_dskw_wr),
			.pcs8g_rx_clock_gate_sw_pc_wrclk(pcs8g_rx_clock_gate_sw_pc_wrclk),
			.pcs8g_rx_clock_gate_sw_rm_rd(pcs8g_rx_clock_gate_sw_rm_rd),
			.pcs8g_rx_clock_gate_sw_rm_wr(pcs8g_rx_clock_gate_sw_rm_wr),
			.pcs8g_rx_clock_gate_sw_wa(pcs8g_rx_clock_gate_sw_wa),
			.pcs8g_rx_comp_fifo_rst_pld_ctrl(pcs8g_rx_comp_fifo_rst_pld_ctrl),
			.pcs8g_rx_ctrl_plane_bonding_compensation(
((pcs8g_rx_prot_mode!="pipe_g1")&& (pcs8g_rx_prot_mode!="pipe_g2")&& (pcs8g_rx_prot_mode!="pipe_g3")&& (pcs8g_rx_prot_mode!="xaui"))? "dis_compensation" :
(pcs8g_rx_byte_deserializer=="en_bds_by_4") ? "en_compensation" :
 "dis_compensation"
),
			.pcs8g_rx_ctrl_plane_bonding_consumption(
((pcs8g_rx_prot_mode!="pipe_g1")&& (pcs8g_rx_prot_mode!="pipe_g2")&& (pcs8g_rx_prot_mode!="pipe_g3")&& (pcs8g_rx_prot_mode!="xaui"))? "individual" :
(bonded_lanes==1)? "individual":
(i==bonding_master_ch)? "bundled_master":
(i < bonding_master_ch)? "bundled_slave_below":
"bundled_slave_above"
),
			.pcs8g_rx_ctrl_plane_bonding_distribution(
((pcs8g_rx_prot_mode!="pipe_g1")&& (pcs8g_rx_prot_mode!="pipe_g2")&& (pcs8g_rx_prot_mode!="pipe_g3")&& (pcs8g_rx_prot_mode!="xaui"))? "not_master_chnl_distr" :
(bonded_lanes==1)? "not_master_chnl_distr":
 (i==bonding_master_ch)? "master_chnl_distr":
"not_master_chnl_distr"
),
			.pcs8g_rx_deskew(pcs8g_rx_deskew),
			.pcs8g_rx_deskew_pattern(pcs8g_rx_deskew_pattern),
			.pcs8g_rx_deskew_prog_pattern_only(pcs8g_rx_deskew_prog_pattern_only),
			.pcs8g_rx_dw_one_or_two_symbol_bo(pcs8g_rx_dw_one_or_two_symbol_bo),
			.pcs8g_rx_eidle_entry_eios(pcs8g_rx_eidle_entry_eios),
			.pcs8g_rx_eidle_entry_iei(pcs8g_rx_eidle_entry_iei),
			.pcs8g_rx_eidle_entry_sd(pcs8g_rx_eidle_entry_sd),
			.pcs8g_rx_eightb_tenb_decoder(pcs8g_rx_eightb_tenb_decoder),
			.pcs8g_rx_eightbtenb_decoder_output_sel(pcs8g_rx_eightbtenb_decoder_output_sel),
			.pcs8g_rx_err_flags_sel(pcs8g_rx_err_flags_sel),
			.pcs8g_rx_fixed_pat_det(pcs8g_rx_fixed_pat_det),
			.pcs8g_rx_fixed_pat_num(pcs8g_rx_fixed_pat_num),
			.pcs8g_rx_force_signal_detect(pcs8g_rx_force_signal_detect),
			.pcs8g_rx_hip_mode(pcs8g_rx_hip_mode),
			.pcs8g_rx_ibm_invalid_code(pcs8g_rx_ibm_invalid_code),
			.pcs8g_rx_invalid_code_flag_only(pcs8g_rx_invalid_code_flag_only),
			.pcs8g_rx_mask_cnt(pcs8g_rx_mask_cnt),
			.pcs8g_rx_pad_or_edb_error_replace(pcs8g_rx_pad_or_edb_error_replace),
			.pcs8g_rx_pc_fifo_rst_pld_ctrl(pcs8g_rx_pc_fifo_rst_pld_ctrl),
			.pcs8g_rx_pcs_bypass(pcs8g_rx_pcs_bypass),
			.pcs8g_rx_phase_compensation_fifo(pcs8g_rx_phase_compensation_fifo),
			.pcs8g_rx_pipe_if_enable(pcs8g_rx_pipe_if_enable),
			.pcs8g_rx_pma_done_count(pcs8g_rx_pma_done_count),
			.pcs8g_rx_pma_dw(pcs8g_rx_pma_dw),
			.pcs8g_rx_polarity_inversion(pcs8g_rx_polarity_inversion),
			.pcs8g_rx_polinv_8b10b_dec(pcs8g_rx_polinv_8b10b_dec),
			.pcs8g_rx_prbs_ver(pcs8g_rx_prbs_ver),
			.pcs8g_rx_prbs_ver_clr_flag(pcs8g_rx_prbs_ver_clr_flag),
			.pcs8g_rx_prot_mode(pcs8g_rx_prot_mode),
			.pcs8g_rx_rate_match(pcs8g_rx_rate_match),
			.pcs8g_rx_re_bo_on_wa(pcs8g_rx_re_bo_on_wa),
			.pcs8g_rx_runlength_check(pcs8g_rx_runlength_check),
			.pcs8g_rx_runlength_val(pcs8g_rx_runlength_val),
			.pcs8g_rx_rx_clk1(pcs8g_rx_rx_clk1),
			.pcs8g_rx_rx_clk2(pcs8g_rx_rx_clk2),
			.pcs8g_rx_rx_clk_free_running(pcs8g_rx_rx_clk_free_running),
			.pcs8g_rx_rx_pcs_urst(pcs8g_rx_rx_pcs_urst),
			.pcs8g_rx_rx_rcvd_clk(pcs8g_rx_rx_rcvd_clk),
			.pcs8g_rx_rx_rd_clk(pcs8g_rx_rx_rd_clk),
			.pcs8g_rx_rx_refclk(pcs8g_rx_rx_refclk),
			.pcs8g_rx_rx_wr_clk(pcs8g_rx_rx_wr_clk),
			.pcs8g_rx_sup_mode(pcs8g_rx_sup_mode),
			.pcs8g_rx_symbol_swap(pcs8g_rx_symbol_swap),
			.pcs8g_rx_test_bus_sel(pcs8g_rx_test_bus_sel),
			.pcs8g_rx_test_mode(pcs8g_rx_test_mode),
			.pcs8g_rx_tx_rx_parallel_loopback(pcs8g_rx_tx_rx_parallel_loopback),
			.pcs8g_rx_use_default_base_address(pcs8g_rx_use_default_base_address),
			.pcs8g_rx_user_base_address(pcs8g_rx_user_base_address),
			.pcs8g_rx_wa_boundary_lock_ctrl(pcs8g_rx_wa_boundary_lock_ctrl),
			.pcs8g_rx_wa_clk_slip_spacing(pcs8g_rx_wa_clk_slip_spacing),
			.pcs8g_rx_wa_clk_slip_spacing_data(pcs8g_rx_wa_clk_slip_spacing_data),
			.pcs8g_rx_wa_det_latency_sync_status_beh(pcs8g_rx_wa_det_latency_sync_status_beh),
			.pcs8g_rx_wa_disp_err_flag(pcs8g_rx_wa_disp_err_flag),
			.pcs8g_rx_wa_kchar(pcs8g_rx_wa_kchar),
			.pcs8g_rx_wa_pd(pcs8g_rx_wa_pd),
			.pcs8g_rx_wa_pd_data(pcs8g_rx_wa_pd_data),
			.pcs8g_rx_wa_pd_polarity(pcs8g_rx_wa_pd_polarity),
			.pcs8g_rx_wa_pld_controlled(pcs8g_rx_wa_pld_controlled),
			.pcs8g_rx_wa_renumber_data(pcs8g_rx_wa_renumber_data),
			.pcs8g_rx_wa_rgnumber_data(pcs8g_rx_wa_rgnumber_data),
			.pcs8g_rx_wa_rknumber_data(pcs8g_rx_wa_rknumber_data),
			.pcs8g_rx_wa_rosnumber_data(pcs8g_rx_wa_rosnumber_data),
			.pcs8g_rx_wa_rvnumber_data(pcs8g_rx_wa_rvnumber_data),
			.pcs8g_rx_wa_sync_sm_ctrl(pcs8g_rx_wa_sync_sm_ctrl),
			.pcs8g_rx_wait_cnt(pcs8g_rx_wait_cnt),
			//.pcs8g_rx_wait_for_phfifo_cnt_data(pcs8g_rx_wait_for_phfifo_cnt_data),
			
			// parameters for stratixv_hssi_8g_tx_pcs
			.pcs8g_tx_agg_block_sel(pcs8g_tx_agg_block_sel),
			.pcs8g_tx_auto_speed_nego_gen2(pcs8g_tx_auto_speed_nego_gen2),
			.pcs8g_tx_bist_gen(pcs8g_tx_bist_gen),
			.pcs8g_tx_bit_reversal(pcs8g_tx_bit_reversal),
			.pcs8g_tx_bypass_pipeline_reg(pcs8g_tx_bypass_pipeline_reg),
			.pcs8g_tx_byte_serializer(pcs8g_tx_byte_serializer),
			.pcs8g_tx_cid_pattern(pcs8g_tx_cid_pattern),
			.pcs8g_tx_cid_pattern_len(pcs8g_tx_cid_pattern_len),
			.pcs8g_tx_clock_gate_bist(pcs8g_tx_clock_gate_bist),
			.pcs8g_tx_clock_gate_bs_enc(pcs8g_tx_clock_gate_bs_enc),
			.pcs8g_tx_clock_gate_dw_fifowr(pcs8g_tx_clock_gate_dw_fifowr),
			.pcs8g_tx_clock_gate_fiford(pcs8g_tx_clock_gate_fiford),
			.pcs8g_tx_clock_gate_prbs(pcs8g_tx_clock_gate_prbs),
			.pcs8g_tx_clock_gate_sw_fifowr(pcs8g_tx_clock_gate_sw_fifowr),
			.pcs8g_tx_ctrl_plane_bonding_compensation(
(pcs8g_rx_byte_deserializer=="en_bds_by_4") ? "en_compensation" : "dis_compensation"
),
			.pcs8g_tx_ctrl_plane_bonding_consumption(
(bonded_lanes==1)? "individual":
(i==bonding_master_ch)? "bundled_master":
(i<bonding_master_ch)? "bundled_slave_below":
"bundled_slave_above"
),
			.pcs8g_tx_ctrl_plane_bonding_distribution(
(bonded_lanes==1)? "not_master_chnl_distr" :
(i==bonding_master_ch)? "master_chnl_distr" :
"not_master_chnl_distr"
),
			.pcs8g_tx_data_selection_8b10b_encoder_input(pcs8g_tx_data_selection_8b10b_encoder_input),
			.pcs8g_tx_dynamic_clk_switch(pcs8g_tx_dynamic_clk_switch),
			.pcs8g_tx_eightb_tenb_disp_ctrl(pcs8g_tx_eightb_tenb_disp_ctrl),
			.pcs8g_tx_eightb_tenb_encoder(pcs8g_tx_eightb_tenb_encoder),
			.pcs8g_tx_force_echar(pcs8g_tx_force_echar),
			.pcs8g_tx_force_kchar(pcs8g_tx_force_kchar),
			.pcs8g_tx_hip_mode(pcs8g_tx_hip_mode),
			.pcs8g_tx_pcfifo_urst(pcs8g_tx_pcfifo_urst),
			.pcs8g_tx_pcs_bypass(pcs8g_tx_pcs_bypass),
			.pcs8g_tx_phase_compensation_fifo(pcs8g_tx_phase_compensation_fifo),
			.pcs8g_tx_phfifo_write_clk_sel(pcs8g_tx_phfifo_write_clk_sel),
			.pcs8g_tx_pma_dw(pcs8g_tx_pma_dw),
			.pcs8g_tx_polarity_inversion(pcs8g_tx_polarity_inversion),
			.pcs8g_tx_prbs_gen(pcs8g_tx_prbs_gen),
			.pcs8g_tx_prot_mode(pcs8g_tx_prot_mode),
			.pcs8g_tx_refclk_b_clk_sel(pcs8g_tx_refclk_b_clk_sel),
			.pcs8g_tx_revloop_back_rm(pcs8g_tx_revloop_back_rm),
			.pcs8g_tx_sup_mode(pcs8g_tx_sup_mode),
			.pcs8g_tx_symbol_swap(pcs8g_tx_symbol_swap),
			.pcs8g_tx_test_mode(pcs8g_tx_test_mode),
			.pcs8g_tx_tx_bitslip(pcs8g_tx_tx_bitslip),
			.pcs8g_tx_tx_compliance_controlled_disparity(pcs8g_tx_tx_compliance_controlled_disparity),
			.pcs8g_tx_txclk_freerun(pcs8g_tx_txclk_freerun),
			.pcs8g_tx_txpcs_urst(pcs8g_tx_txpcs_urst),
			.pcs8g_tx_use_default_base_address(pcs8g_tx_use_default_base_address),
			.pcs8g_tx_user_base_address(pcs8g_tx_user_base_address),
			
			// parameters for stratixv_hssi_common_pcs_pma_interface
			.com_pcs_pma_if_auto_speed_ena(com_pcs_pma_if_auto_speed_ena),
			.com_pcs_pma_if_force_freqdet(com_pcs_pma_if_force_freqdet),
			.com_pcs_pma_if_func_mode(com_pcs_pma_if_func_mode),
			.com_pcs_pma_if_pcie_gen3_cap(com_pcs_pma_if_pcie_gen3_cap),
			.com_pcs_pma_if_pipe_if_g3pcs(com_pcs_pma_if_pipe_if_g3pcs),
			.com_pcs_pma_if_pma_if_dft_en(com_pcs_pma_if_pma_if_dft_en),
			.com_pcs_pma_if_pma_if_dft_val(com_pcs_pma_if_pma_if_dft_val),
			.com_pcs_pma_if_ppm_cnt_rst(com_pcs_pma_if_ppm_cnt_rst),
			.com_pcs_pma_if_ppm_deassert_early(com_pcs_pma_if_ppm_deassert_early),
			.com_pcs_pma_if_ppm_gen1_2_cnt(com_pcs_pma_if_ppm_gen1_2_cnt),
			.com_pcs_pma_if_ppm_post_eidle_delay(com_pcs_pma_if_ppm_post_eidle_delay),
			.com_pcs_pma_if_ppmsel(com_pcs_pma_if_ppmsel),
			.com_pcs_pma_if_prot_mode(com_pcs_pma_if_prot_mode),
			.com_pcs_pma_if_refclk_dig_sel(com_pcs_pma_if_refclk_dig_sel),
			.com_pcs_pma_if_selectpcs(com_pcs_pma_if_selectpcs),
			.com_pcs_pma_if_sup_mode(com_pcs_pma_if_sup_mode),
			.com_pcs_pma_if_use_default_base_address(com_pcs_pma_if_use_default_base_address),
			.com_pcs_pma_if_user_base_address(com_pcs_pma_if_user_base_address),
			
			// parameters for stratixv_hssi_common_pld_pcs_interface
			.com_pld_pcs_if_data_source(com_pld_pcs_if_data_source),
			.com_pld_pcs_if_emsip_enable(com_pld_pcs_if_emsip_enable),
			.com_pld_pcs_if_hrdrstctrl_en_cfg(com_pld_pcs_if_hrdrstctrl_en_cfg),
			.com_pld_pcs_if_hrdrstctrl_en_cfgusr(com_pld_pcs_if_hrdrstctrl_en_cfgusr),
			.com_pld_pcs_if_pld_side_reserved_source0(com_pld_pcs_if_pld_side_reserved_source0),
			.com_pld_pcs_if_pld_side_reserved_source1(com_pld_pcs_if_pld_side_reserved_source1),
			.com_pld_pcs_if_pld_side_reserved_source10(com_pld_pcs_if_pld_side_reserved_source10),
			.com_pld_pcs_if_pld_side_reserved_source11(com_pld_pcs_if_pld_side_reserved_source11),
			.com_pld_pcs_if_pld_side_reserved_source2(com_pld_pcs_if_pld_side_reserved_source2),
			.com_pld_pcs_if_pld_side_reserved_source3(com_pld_pcs_if_pld_side_reserved_source3),
			.com_pld_pcs_if_pld_side_reserved_source4(com_pld_pcs_if_pld_side_reserved_source4),
			.com_pld_pcs_if_pld_side_reserved_source5(com_pld_pcs_if_pld_side_reserved_source5),
			.com_pld_pcs_if_pld_side_reserved_source6(com_pld_pcs_if_pld_side_reserved_source6),
			.com_pld_pcs_if_pld_side_reserved_source7(com_pld_pcs_if_pld_side_reserved_source7),
			.com_pld_pcs_if_pld_side_reserved_source8(com_pld_pcs_if_pld_side_reserved_source8),
			.com_pld_pcs_if_pld_side_reserved_source9(com_pld_pcs_if_pld_side_reserved_source9),
			.com_pld_pcs_if_testbus_sel(com_pld_pcs_if_testbus_sel),
			.com_pld_pcs_if_use_default_base_address(com_pld_pcs_if_use_default_base_address),
			.com_pld_pcs_if_user_base_address(com_pld_pcs_if_user_base_address),
			.com_pld_pcs_if_usrmode_sel4rst(com_pld_pcs_if_usrmode_sel4rst),
			
			// parameters for stratixv_hssi_gen3_rx_pcs
			.pcs_g3_rx_block_sync(pcs_g3_rx_block_sync),
			.pcs_g3_rx_block_sync_sm(pcs_g3_rx_block_sync_sm),
			.pcs_g3_rx_decoder(pcs_g3_rx_decoder),
			.pcs_g3_rx_descrambler(pcs_g3_rx_descrambler),
			.pcs_g3_rx_descrambler_lfsr_check(pcs_g3_rx_descrambler_lfsr_check),
			.pcs_g3_rx_lpbk_force(pcs_g3_rx_lpbk_force),
			.pcs_g3_rx_mode(pcs_g3_rx_mode),
			.pcs_g3_rx_parallel_lpbk(pcs_g3_rx_parallel_lpbk),
			.pcs_g3_rx_rate_match_fifo(pcs_g3_rx_rate_match_fifo),
			.pcs_g3_rx_rate_match_fifo_latency(pcs_g3_rx_rate_match_fifo_latency),
			.pcs_g3_rx_reverse_lpbk(pcs_g3_rx_reverse_lpbk),
			.pcs_g3_rx_rmfifo_empty(pcs_g3_rx_rmfifo_empty),
			.pcs_g3_rx_rmfifo_empty_data(pcs_g3_rx_rmfifo_empty_data),
			.pcs_g3_rx_rmfifo_full(pcs_g3_rx_rmfifo_full),
			.pcs_g3_rx_rmfifo_full_data(pcs_g3_rx_rmfifo_full_data),
			.pcs_g3_rx_rmfifo_pempty(pcs_g3_rx_rmfifo_pempty),
			.pcs_g3_rx_rmfifo_pempty_data(pcs_g3_rx_rmfifo_pempty_data),
			.pcs_g3_rx_rmfifo_pfull(pcs_g3_rx_rmfifo_pfull),
			.pcs_g3_rx_rmfifo_pfull_data(pcs_g3_rx_rmfifo_pfull_data),
			.pcs_g3_rx_rx_b4gb_par_lpbk(pcs_g3_rx_rx_b4gb_par_lpbk),
			.pcs_g3_rx_rx_clk_sel(pcs_g3_rx_rx_clk_sel),
			.pcs_g3_rx_rx_force_balign(pcs_g3_rx_rx_force_balign),
			.pcs_g3_rx_rx_g3_dcbal(pcs_g3_rx_rx_g3_dcbal),
			.pcs_g3_rx_rx_ins_del_one_skip(pcs_g3_rx_rx_ins_del_one_skip),
			.pcs_g3_rx_rx_lane_num(RX_LANE_NUM),
			.pcs_g3_rx_rx_num_fixed_pat(pcs_g3_rx_rx_num_fixed_pat),
			.pcs_g3_rx_rx_num_fixed_pat_data(pcs_g3_rx_rx_num_fixed_pat_data),
			.pcs_g3_rx_rx_pol_compl(pcs_g3_rx_rx_pol_compl),
			.pcs_g3_rx_rx_test_out_sel(pcs_g3_rx_rx_test_out_sel),
			.pcs_g3_rx_sup_mode(pcs_g3_rx_sup_mode),
			.pcs_g3_rx_tx_clk_sel(pcs_g3_rx_tx_clk_sel),
			.pcs_g3_rx_use_default_base_address(pcs_g3_rx_use_default_base_address),
			.pcs_g3_rx_user_base_address(pcs_g3_rx_user_base_address),
			
			// parameters for stratixv_hssi_gen3_tx_pcs
			.pcs_g3_tx_encoder(pcs_g3_tx_encoder),
			.pcs_g3_tx_mode(pcs_g3_tx_mode),
			.pcs_g3_tx_prbs_generator(pcs_g3_tx_prbs_generator),
			.pcs_g3_tx_reverse_lpbk(pcs_g3_tx_reverse_lpbk),
			.pcs_g3_tx_scrambler(pcs_g3_tx_scrambler),
			.pcs_g3_tx_sup_mode(pcs_g3_tx_sup_mode),
			.pcs_g3_tx_tx_bitslip(pcs_g3_tx_tx_bitslip),
			.pcs_g3_tx_tx_bitslip_data(pcs_g3_tx_tx_bitslip_data),
			.pcs_g3_tx_tx_clk_sel(pcs_g3_tx_tx_clk_sel),
			.pcs_g3_tx_tx_g3_dcbal(pcs_g3_tx_tx_g3_dcbal),
			.pcs_g3_tx_tx_gbox_byp(pcs_g3_tx_tx_gbox_byp),
			.pcs_g3_tx_tx_lane_num(TX_LANE_NUM),
			.pcs_g3_tx_tx_pol_compl(pcs_g3_tx_tx_pol_compl),
			.pcs_g3_tx_use_default_base_address(pcs_g3_tx_use_default_base_address),
			.pcs_g3_tx_user_base_address(pcs_g3_tx_user_base_address),
			
			// parameters for stratixv_hssi_pipe_gen1_2
			.pipe12_ctrl_plane_bonding_consumption(
((pcs8g_rx_prot_mode!="pipe_g1")&& (pcs8g_rx_prot_mode!="pipe_g2")&&(pcs8g_rx_prot_mode!="pipe_g3")&&(pcs8g_rx_prot_mode!="xaui"))? "individual" :
(bonded_lanes==1)? "individual":
(i==bonding_master_ch)? "bundled_master":
(i<bonding_master_ch)? "bundled_slave_below":
"bundled_slave_above"
),
			.pipe12_elec_idle_delay_val(pipe12_elec_idle_delay_val),
			.pipe12_elecidle_delay(pipe12_elecidle_delay),
			.pipe12_error_replace_pad(pipe12_error_replace_pad),
			.pipe12_hip_mode(pipe12_hip_mode),
			.pipe12_ind_error_reporting(pipe12_ind_error_reporting),
			.pipe12_phy_status_delay(pipe12_phy_status_delay),
			.pipe12_phystatus_delay_val(pipe12_phystatus_delay_val),
			.pipe12_phystatus_rst_toggle(pipe12_phystatus_rst_toggle),
			.pipe12_pipe_byte_de_serializer_en(pipe12_pipe_byte_de_serializer_en),
			.pipe12_prot_mode(pipe12_prot_mode),
			.pipe12_rpre_emph_a_val(pipe12_rpre_emph_a_val),
			.pipe12_rpre_emph_b_val(pipe12_rpre_emph_b_val),
			.pipe12_rpre_emph_c_val(pipe12_rpre_emph_c_val),
			.pipe12_rpre_emph_d_val(pipe12_rpre_emph_d_val),
			.pipe12_rpre_emph_e_val(pipe12_rpre_emph_e_val),
			.pipe12_rpre_emph_settings(pipe12_rpre_emph_settings),
			.pipe12_rvod_sel_a_val(pipe12_rvod_sel_a_val),
			.pipe12_rvod_sel_b_val(pipe12_rvod_sel_b_val),
			.pipe12_rvod_sel_c_val(pipe12_rvod_sel_c_val),
			.pipe12_rvod_sel_d_val(pipe12_rvod_sel_d_val),
			.pipe12_rvod_sel_e_val(pipe12_rvod_sel_e_val),
			.pipe12_rvod_sel_settings(pipe12_rvod_sel_settings),
			.pipe12_rx_pipe_enable(pipe12_rx_pipe_enable),
			.pipe12_rxdetect_bypass(pipe12_rxdetect_bypass),
			.pipe12_sup_mode(pipe12_sup_mode),
			.pipe12_tx_pipe_enable(pipe12_tx_pipe_enable),
			.pipe12_txswing(pipe12_txswing),
			.pipe12_use_default_base_address(pipe12_use_default_base_address),
			.pipe12_user_base_address(pipe12_user_base_address),
			
			// parameters for stratixv_hssi_pipe_gen3
			.pipe3_asn_clk_enable(pipe3_asn_clk_enable),
			.pipe3_asn_enable(pipe3_asn_enable),
			.pipe3_bypass_pma_sw_done(pipe3_bypass_pma_sw_done),
			.pipe3_bypass_rx_detection_enable(pipe3_bypass_rx_detection_enable),
			.pipe3_bypass_rx_preset(pipe3_bypass_rx_preset),
			.pipe3_bypass_rx_preset_data(pipe3_bypass_rx_preset_data),
			.pipe3_bypass_rx_preset_enable(pipe3_bypass_rx_preset_enable),
			.pipe3_bypass_send_syncp_fbkp(pipe3_bypass_send_syncp_fbkp),
			.pipe3_bypass_tx_coefficent(pipe3_bypass_tx_coefficent),
			.pipe3_bypass_tx_coefficent_data(pipe3_bypass_tx_coefficent_data),
			.pipe3_bypass_tx_coefficent_enable(pipe3_bypass_tx_coefficent_enable),
			.pipe3_cdr_control(pipe3_cdr_control),
			.pipe3_cid_enable(pipe3_cid_enable),
			.pipe3_cp_cons_sel(
(bonded_lanes==1)? "cp_cons_master":
(i==bonding_master_ch)? "cp_cons_master":
(i<bonding_master_ch)? "cp_cons_slave_blw":
"cp_cons_slave_abv"
),
			.pipe3_cp_dwn_mstr(
(bonded_lanes==1)? "true":
(i==bonding_master_ch)? "true":
(i<bonding_master_ch)? "false":
"false"
),
			.pipe3_cp_up_mstr(
(bonded_lanes==1)? "true":
(i==bonding_master_ch)? "true":
(i<bonding_master_ch)? "false":
"false"
),
			.pipe3_ctrl_plane_bonding(
(bonded_lanes==1)? "individual":
(i==bonding_master_ch)? "ctrl_master":
(i<bonding_master_ch)? "ctrl_slave_blw":
"ctrl_slave_abv"
),
			.pipe3_data_mask_count(pipe3_data_mask_count),
			.pipe3_data_mask_count_val(pipe3_data_mask_count_val),
			.pipe3_elecidle_delay_g3(pipe3_elecidle_delay_g3),
			.pipe3_elecidle_delay_g3_data(pipe3_elecidle_delay_g3_data),
			.pipe3_free_run_clk_enable(pipe3_free_run_clk_enable),
			.pipe3_ind_error_reporting(pipe3_ind_error_reporting),
			.pipe3_inf_ei_enable(pipe3_inf_ei_enable),
			.pipe3_mode(pipe3_mode),
			.pipe3_parity_chk_ts1(pipe3_parity_chk_ts1),
			.pipe3_pc_en_counter(pipe3_pc_en_counter),
			.pipe3_pc_en_counter_data(pipe3_pc_en_counter_data),
			.pipe3_pc_rst_counter(pipe3_pc_rst_counter),
			.pipe3_pc_rst_counter_data(pipe3_pc_rst_counter_data),
			.pipe3_ph_fifo_reg_mode(pipe3_ph_fifo_reg_mode),
			.pipe3_phfifo_flush_wait(pipe3_phfifo_flush_wait),
			.pipe3_phfifo_flush_wait_data(pipe3_phfifo_flush_wait_data),
			.pipe3_phy_status_delay_g12(pipe3_phy_status_delay_g12),
			.pipe3_phy_status_delay_g12_data(pipe3_phy_status_delay_g12_data),
			.pipe3_phy_status_delay_g3(pipe3_phy_status_delay_g3),
			.pipe3_phy_status_delay_g3_data(pipe3_phy_status_delay_g3_data),
			.pipe3_phystatus_rst_toggle_g12(pipe3_phystatus_rst_toggle_g12),
			.pipe3_phystatus_rst_toggle_g3(pipe3_phystatus_rst_toggle_g3),
			.pipe3_pipe_clk_sel(pipe3_pipe_clk_sel),
			.pipe3_pma_done_counter(pipe3_pma_done_counter),
			.pipe3_pma_done_counter_data(pipe3_pma_done_counter_data),
			.pipe3_rate_match_pad_insertion(pipe3_rate_match_pad_insertion),
			.pipe3_rxvalid_mask(pipe3_rxvalid_mask),
			.pipe3_sigdet_wait_counter(pipe3_sigdet_wait_counter),
			.pipe3_sigdet_wait_counter_data(pipe3_sigdet_wait_counter_data),
			.pipe3_spd_chnge_g2_sel(pipe3_spd_chnge_g2_sel),
			.pipe3_sup_mode(pipe3_sup_mode),
			.pipe3_test_mode_timers(pipe3_test_mode_timers),
			.pipe3_test_out_sel(pipe3_test_out_sel),
			.pipe3_use_default_base_address(pipe3_use_default_base_address),
			.pipe3_user_base_address(pipe3_user_base_address),
			.pipe3_wait_clk_on_off_timer(pipe3_wait_clk_on_off_timer),
			.pipe3_wait_clk_on_off_timer_data(pipe3_wait_clk_on_off_timer_data),
			.pipe3_wait_pipe_synchronizing(pipe3_wait_pipe_synchronizing),
			.pipe3_wait_pipe_synchronizing_data(pipe3_wait_pipe_synchronizing_data),
			.pipe3_wait_send_syncp_fbkp(pipe3_wait_send_syncp_fbkp),
			.pipe3_wait_send_syncp_fbkp_data(pipe3_wait_send_syncp_fbkp_data),
			
			// parameters for stratixv_hssi_rx_pcs_pma_interface
			.rx_pcs_pma_if_clkslip_sel(rx_pcs_pma_if_clkslip_sel),
			.rx_pcs_pma_if_prot_mode(rx_pcs_pma_if_prot_mode),
			.rx_pcs_pma_if_selectpcs(rx_pcs_pma_if_selectpcs),
			.rx_pcs_pma_if_use_default_base_address(rx_pcs_pma_if_use_default_base_address),
			.rx_pcs_pma_if_user_base_address(rx_pcs_pma_if_user_base_address),
			
			// parameters for stratixv_hssi_rx_pld_pcs_interface
			.rx_pld_pcs_if_data_source(rx_pld_pcs_if_data_source),
			.rx_pld_pcs_if_is_10g_0ppm(rx_pld_pcs_if_is_10g_0ppm),
			.rx_pld_pcs_if_is_8g_0ppm(rx_pld_pcs_if_is_8g_0ppm),
			.rx_pld_pcs_if_selectpcs(rx_pld_pcs_if_selectpcs),
			.rx_pld_pcs_if_use_default_base_address(rx_pld_pcs_if_use_default_base_address),
			.rx_pld_pcs_if_user_base_address(rx_pld_pcs_if_user_base_address),
			
			// parameters for stratixv_hssi_tx_pcs_pma_interface
			.tx_pcs_pma_if_selectpcs(tx_pcs_pma_if_selectpcs),
			.tx_pcs_pma_if_use_default_base_address(tx_pcs_pma_if_use_default_base_address),
			.tx_pcs_pma_if_user_base_address(tx_pcs_pma_if_user_base_address),
			
			// parameters for stratixv_hssi_tx_pld_pcs_interface
			.tx_pld_pcs_if_data_source(tx_pld_pcs_if_data_source),
			.tx_pld_pcs_if_is_10g_0ppm(tx_pld_pcs_if_is_10g_0ppm),
			.tx_pld_pcs_if_is_8g_0ppm(tx_pld_pcs_if_is_8g_0ppm),
			.tx_pld_pcs_if_use_default_base_address(tx_pld_pcs_if_use_default_base_address),
			.tx_pld_pcs_if_user_base_address(tx_pld_pcs_if_user_base_address)
		) inst_sv_pcs_ch (
			// ports
			.in_agg_align_status(in_agg_align_status[i]),
			.in_agg_align_status_sync_0(in_agg_align_status_sync_0[i]),
			.in_agg_align_status_sync_0_top_or_bot(in_agg_align_status_sync_0_top_or_bot[i]),
			.in_agg_align_status_top_or_bot(in_agg_align_status_top_or_bot[i]),
			.in_agg_cg_comp_rd_d_all(in_agg_cg_comp_rd_d_all[i]),
			.in_agg_cg_comp_rd_d_all_top_or_bot(in_agg_cg_comp_rd_d_all_top_or_bot[i]),
			.in_agg_cg_comp_wr_all(in_agg_cg_comp_wr_all[i]),
			.in_agg_cg_comp_wr_all_top_or_bot(in_agg_cg_comp_wr_all_top_or_bot[i]),
			.in_agg_del_cond_met_0(in_agg_del_cond_met_0[i]),
			.in_agg_del_cond_met_0_top_or_bot(in_agg_del_cond_met_0_top_or_bot[i]),
			.in_agg_en_dskw_qd(in_agg_en_dskw_qd[i]),
			.in_agg_en_dskw_qd_top_or_bot(in_agg_en_dskw_qd_top_or_bot[i]),
			.in_agg_en_dskw_rd_ptrs(in_agg_en_dskw_rd_ptrs[i]),
			.in_agg_en_dskw_rd_ptrs_top_or_bot(in_agg_en_dskw_rd_ptrs_top_or_bot[i]),
			.in_agg_fifo_ovr_0(in_agg_fifo_ovr_0[i]),
			.in_agg_fifo_ovr_0_top_or_bot(in_agg_fifo_ovr_0_top_or_bot[i]),
			.in_agg_fifo_rd_in_comp_0(in_agg_fifo_rd_in_comp_0[i]),
			.in_agg_fifo_rd_in_comp_0_top_or_bot(in_agg_fifo_rd_in_comp_0_top_or_bot[i]),
			.in_agg_fifo_rst_rd_qd(in_agg_fifo_rst_rd_qd[i]),
			.in_agg_fifo_rst_rd_qd_top_or_bot(in_agg_fifo_rst_rd_qd_top_or_bot[i]),
			.in_agg_insert_incomplete_0(in_agg_insert_incomplete_0[i]),
			.in_agg_insert_incomplete_0_top_or_bot(in_agg_insert_incomplete_0_top_or_bot[i]),
			.in_agg_latency_comp_0(in_agg_latency_comp_0[i]),
			.in_agg_latency_comp_0_top_or_bot(in_agg_latency_comp_0_top_or_bot[i]),
			.in_agg_rcvd_clk_agg(in_agg_rcvd_clk_agg[i]),
			.in_agg_rcvd_clk_agg_top_or_bot(in_agg_rcvd_clk_agg_top_or_bot[i]),
			.in_agg_rx_control_rs(in_agg_rx_control_rs[i]),
			.in_agg_rx_control_rs_top_or_bot(in_agg_rx_control_rs_top_or_bot[i]),
			.in_agg_rx_data_rs(in_agg_rx_data_rs[(i + 1) * 8 - 1 : i * 8]),
			.in_agg_rx_data_rs_top_or_bot(in_agg_rx_data_rs_top_or_bot[(i + 1) * 8 - 1 : i * 8]),
			.in_agg_test_so_to_pld_in(in_agg_test_so_to_pld_in[i]),
			.in_agg_testbus(in_agg_testbus[(i + 1) * 16 - 1 : i * 16]),
			.in_agg_tx_ctl_ts(in_agg_tx_ctl_ts[i]),
			.in_agg_tx_ctl_ts_top_or_bot(in_agg_tx_ctl_ts_top_or_bot[i]),
			.in_agg_tx_data_ts(in_agg_tx_data_ts[(i + 1) * 8 - 1 : i * 8]),
			.in_agg_tx_data_ts_top_or_bot(in_agg_tx_data_ts_top_or_bot[(i + 1) * 8 - 1 : i * 8]),
			.in_avmmaddress(in_avmmaddress[(i + 1) * 11 - 1 : i * 11]),
			.in_avmmbyteen(in_avmmbyteen[(i + 1) * 2 - 1 : i * 2]),
			.in_avmmclk(in_avmmclk[i]),
			.in_avmmread(in_avmmread[i]),
			.in_avmmrstn(in_avmmrstn[i]),
			.in_avmmwrite(in_avmmwrite[i]),
			.in_avmmwritedata(in_avmmwritedata[(i + 1) * 16 - 1 : i * 16]),
			.in_config_sel_in_chnl_down(w_pcs8g_rx_configseloutchnlup[i + 0]),
			.in_config_sel_in_chnl_up(w_pcs8g_rx_configseloutchnldown[i + 2]),
			.in_emsip_com_in(in_emsip_com_in[(i + 1) * 38 - 1 : i * 38]),
			.in_emsip_com_special_in(in_emsip_com_special_in[(i + 1) * 20 - 1 : i * 20]),
			.in_emsip_rx_clk_in(in_emsip_rx_clk_in[(i + 1) * 3 - 1 : i * 3]),
			.in_emsip_rx_in(in_emsip_rx_in[(i + 1) * 20 - 1 : i * 20]),
			.in_emsip_rx_special_in(in_emsip_rx_special_in[(i + 1) * 13 - 1 : i * 13]),
			.in_emsip_tx_clk_in(in_emsip_tx_clk_in[(i + 1) * 3 - 1 : i * 3]),
			.in_emsip_tx_in(in_emsip_tx_in[(i + 1) * 104 - 1 : i * 104]),
			.in_emsip_tx_special_in(in_emsip_tx_special_in[(i + 1) * 13 - 1 : i * 13]),
			.in_entest(in_entest[i]),
			.in_fifo_select_in_chnl_down(w_pcs8g_tx_fifoselectoutchnlup[(i + 1) * 2 - 1 : (i + 0) * 2]),
			.in_fifo_select_in_chnl_up(w_pcs8g_tx_fifoselectoutchnldown[(i + 3) * 2 - 1 : (i + 2) * 2]),
			.in_frzreg(in_frzreg[i]),
			.in_iocsr_rdy_dly(in_iocsr_rdy_dly[i]),
			.in_nfrzdrv(in_nfrzdrv[i]),
			.in_npor(in_npor[i]),
			.in_pcs_10g_bundling_in_down({w_pcs10g_tx_distupoutrdpfull[i + 0],w_pcs10g_tx_distupoutintlknrden[i + 0]}),
			.in_pcs_10g_bundling_in_up({w_pcs10g_tx_distdwnoutrdpfull[i + 2],w_pcs10g_tx_distdwnoutintlknrden[i + 2]}),
			.in_pcs_10g_distdwn_in_dv(w_pcs10g_tx_distupoutdv[i + 0]),
			.in_pcs_10g_distdwn_in_rden(w_pcs10g_tx_distupoutrden[i + 0]),
			.in_pcs_10g_distdwn_in_wren(w_pcs10g_tx_distupoutwren[i + 0]),
			.in_pcs_10g_distup_in_dv(w_pcs10g_tx_distdwnoutdv[i + 2]),
			.in_pcs_10g_distup_in_rden(w_pcs10g_tx_distdwnoutrden[i + 2]),
			.in_pcs_10g_distup_in_wren(w_pcs10g_tx_distdwnoutwren[i + 2]),
			.in_pcs_gen3_bundling_in_down(w_pipe3_bundlingoutup[(i + 1) * 11 - 1 : (i + 0) * 11]),
			.in_pcs_gen3_bundling_in_up(w_pipe3_bundlingoutdown[(i + 3) * 11 - 1 : (i + 2) * 11]),
			.in_pld_10g_refclk_dig(in_pld_10g_refclk_dig[i]),
			.in_pld_10g_rx_align_clr(in_pld_10g_rx_align_clr[i]),
			.in_pld_10g_rx_align_en(in_pld_10g_rx_align_en[i]),
			.in_pld_10g_rx_bitslip(in_pld_10g_rx_bitslip[i]),
			.in_pld_10g_rx_clr_ber_count(in_pld_10g_rx_clr_ber_count[i]),
			.in_pld_10g_rx_clr_errblk_cnt(in_pld_10g_rx_clr_errblk_cnt[i]),
			.in_pld_10g_rx_disp_clr(in_pld_10g_rx_disp_clr[i]),
			.in_pld_10g_rx_pld_clk(in_pld_10g_rx_pld_clk[i]),
			.in_pld_10g_rx_prbs_err_clr(in_pld_10g_rx_prbs_err_clr[i]),
			.in_pld_10g_rx_rd_en(in_pld_10g_rx_rd_en[i]),
			.in_pld_10g_rx_rst_n(in_pld_10g_rx_rst_n[i]),
			.in_pld_10g_tx_bitslip(in_pld_10g_tx_bitslip[(i + 1) * 7 - 1 : i * 7]),
			.in_pld_10g_tx_burst_en(in_pld_10g_tx_burst_en[i]),
			.in_pld_10g_tx_control(in_pld_10g_tx_control[(i + 1) * 9 - 1 : i * 9]),
			.in_pld_10g_tx_data_valid(in_pld_10g_tx_data_valid[i]),
			.in_pld_10g_tx_diag_status(in_pld_10g_tx_diag_status[(i + 1) * 2 - 1 : i * 2]),
			.in_pld_10g_tx_pld_clk(in_pld_10g_tx_pld_clk[i]),
			.in_pld_10g_tx_rst_n(in_pld_10g_tx_rst_n[i]),
			.in_pld_10g_tx_wordslip(in_pld_10g_tx_wordslip[i]),
			.in_pld_8g_a1a2_size(in_pld_8g_a1a2_size[i]),
			.in_pld_8g_bitloc_rev_en(in_pld_8g_bitloc_rev_en[i]),
			.in_pld_8g_bitslip(in_pld_8g_bitslip[i]),
			.in_pld_8g_byte_rev_en(in_pld_8g_byte_rev_en[i]),
			.in_pld_8g_bytordpld(in_pld_8g_bytordpld[i]),
			.in_pld_8g_cmpfifourst_n(in_pld_8g_cmpfifourst_n[i]),
			.in_pld_8g_encdt(in_pld_8g_encdt[i]),
			.in_pld_8g_phfifourst_rx_n(in_pld_8g_phfifourst_rx_n[i]),
			.in_pld_8g_phfifourst_tx_n(in_pld_8g_phfifourst_tx_n[i]),
			.in_pld_8g_pld_rx_clk(in_pld_8g_pld_rx_clk[i]),
			.in_pld_8g_pld_tx_clk(in_pld_8g_pld_tx_clk[i]),
			.in_pld_8g_polinv_rx(in_pld_8g_polinv_rx[i]),
			.in_pld_8g_polinv_tx(in_pld_8g_polinv_tx[i]),
			.in_pld_8g_powerdown(in_pld_8g_powerdown[(i + 1) * 2 - 1 : i * 2]),
			.in_pld_8g_prbs_cid_en(in_pld_8g_prbs_cid_en[i]),
			.in_pld_8g_rddisable_tx(in_pld_8g_rddisable_tx[i]),
			.in_pld_8g_rdenable_rmf(in_pld_8g_rdenable_rmf[i]),
			.in_pld_8g_rdenable_rx(in_pld_8g_rdenable_rx[i]),
			.in_pld_8g_refclk_dig(in_pld_8g_refclk_dig[i]),
			.in_pld_8g_refclk_dig2(in_pld_8g_refclk_dig2[i]),
			.in_pld_8g_rev_loopbk(in_pld_8g_rev_loopbk[i]),
			.in_pld_8g_rxpolarity(in_pld_8g_rxpolarity[i]),
			.in_pld_8g_rxurstpcs_n(in_pld_8g_rxurstpcs_n[i]),
			.in_pld_8g_tx_blk_start(in_pld_8g_tx_blk_start[(i + 1) * 4 - 1 : i * 4]),
			.in_pld_8g_tx_boundary_sel(in_pld_8g_tx_boundary_sel[(i + 1) * 5 - 1 : i * 5]),
			.in_pld_8g_tx_data_valid(in_pld_8g_tx_data_valid[(i + 1) * 4 - 1 : i * 4]),
			.in_pld_8g_tx_sync_hdr(in_pld_8g_tx_sync_hdr[(i + 1) * 2 - 1 : i * 2]),
			.in_pld_8g_txdeemph(in_pld_8g_txdeemph[i]),
			.in_pld_8g_txdetectrxloopback(in_pld_8g_txdetectrxloopback[i]),
			.in_pld_8g_txelecidle(in_pld_8g_txelecidle[i]),
			.in_pld_8g_txmargin(in_pld_8g_txmargin[(i + 1) * 3 - 1 : i * 3]),
			.in_pld_8g_txswing(in_pld_8g_txswing[i]),
			.in_pld_8g_txurstpcs_n(in_pld_8g_txurstpcs_n[i]),
			.in_pld_8g_wrdisable_rx(in_pld_8g_wrdisable_rx[i]),
			.in_pld_8g_wrenable_rmf(in_pld_8g_wrenable_rmf[i]),
			.in_pld_8g_wrenable_tx(in_pld_8g_wrenable_tx[i]),
			.in_pld_agg_refclk_dig(in_pld_agg_refclk_dig[i]),
			.in_pld_eidleinfersel(in_pld_eidleinfersel[(i + 1) * 3 - 1 : i * 3]),
			.in_pld_gen3_current_coeff(in_pld_gen3_current_coeff[(i + 1) * 18 - 1 : i * 18]),
			.in_pld_gen3_current_rxpreset(in_pld_gen3_current_rxpreset[(i + 1) * 3 - 1 : i * 3]),
			.in_pld_gen3_rx_rstn(in_pld_gen3_rx_rstn[i]),
			.in_pld_gen3_tx_rstn(in_pld_gen3_tx_rstn[i]),
			.in_pld_ltr(in_pld_ltr[i]),
			.in_pld_partial_reconfig_in(in_pld_partial_reconfig_in[i]),
			.in_pld_pcs_pma_if_refclk_dig(in_pld_pcs_pma_if_refclk_dig[i]),
			.in_pld_rate(in_pld_rate[(i + 1) * 2 - 1 : i * 2]),
			.in_pld_reserved_in(in_pld_reserved_in[(i + 1) * 12 - 1 : i * 12]),
			.in_pld_rx_clk_slip_in(in_pld_rx_clk_slip_in[i]),
			.in_pld_rxpma_rstb_in(in_pld_rxpma_rstb_in[i]),
			.in_pld_scan_mode_n(in_pld_scan_mode_n[i]),
			.in_pld_scan_shift_n(in_pld_scan_shift_n[i]),
			.in_pld_sync_sm_en(in_pld_sync_sm_en[i]),
			.in_pld_tx_data(in_pld_tx_data[(i + 1) * 64 - 1 : i * 64]),
			.in_plniotri(in_plniotri[i]),
			.in_pma_clkdiv33_lc_in(in_pma_clkdiv33_lc_in[i]),
			.in_pma_clkdiv33_txorrx_in(in_pma_clkdiv33_txorrx_in[i]),
			.in_pma_clklow_in(in_pma_clklow_in[i]),
			.in_pma_eye_monitor_in(in_pma_eye_monitor_in[(i + 1) * 2 - 1 : i * 2]),
			.in_pma_fref_in(in_pma_fref_in[i]),
			.in_pma_hclk(in_pma_hclk[i]),
			.in_pma_pcie_sw_done(in_pma_pcie_sw_done[(i + 1) * 2 - 1 : i * 2]),
			.in_pma_reserved_in(in_pma_reserved_in[(i + 1) * 5 - 1 : i * 5]),
			.in_pma_rx_data(in_pma_rx_data[(i + 1) * 80 - 1 : i * 80]),
			.in_pma_rx_detect_valid(in_pma_rx_detect_valid[i]),
			.in_pma_rx_found(in_pma_rx_found[i]),
			.in_pma_rx_freq_tx_cmu_pll_lock_in(in_pma_rx_freq_tx_cmu_pll_lock_in[i]),
			.in_pma_rx_pll_phase_lock_in(in_pma_rx_pll_phase_lock_in[i]),
			.in_pma_rx_pma_clk(in_pma_rx_pma_clk[i]),
			.in_pma_sigdet(in_pma_sigdet[i]),
			.in_pma_signal_ok(in_pma_signal_ok[i]),
			.in_pma_tx_lc_pll_lock_in(in_pma_tx_lc_pll_lock_in[i]),
			.in_pma_tx_pma_clk(in_pma_tx_pma_clk[i]),
			.in_reset_pc_ptrs_in_chnl_down(w_pcs8g_rx_resetpcptrsoutchnlup[i + 0]),
			.in_reset_pc_ptrs_in_chnl_up(w_pcs8g_rx_resetpcptrsoutchnldown[i + 2]),
			.in_reset_ppm_cntrs_in_chnl_down(w_pcs8g_rx_resetppmcntrsoutchnlup[i + 0]),
			.in_reset_ppm_cntrs_in_chnl_up(w_pcs8g_rx_resetppmcntrsoutchnldown[i + 2]),
			.in_rx_div_sync_in_chnl_down(w_pcs8g_rx_rxdivsyncoutchnlup[(i + 1) * 2 - 1 : (i + 0) * 2]),
			.in_rx_div_sync_in_chnl_up(w_pcs8g_rx_rxdivsyncoutchnldown[(i + 3) * 2 - 1 : (i + 2) * 2]),
			.in_rx_rd_enable_in_chnl_down(w_pcs8g_rx_rdenableoutchnlup[i + 0]),
			.in_rx_rd_enable_in_chnl_up(w_pcs8g_rx_rdenableoutchnldown[i + 2]),
			.in_rx_we_in_chnl_down(w_pcs8g_rx_rxweoutchnlup[(i + 1) * 2 - 1 : (i + 0) * 2]),
			.in_rx_we_in_chnl_up(w_pcs8g_rx_rxweoutchnldown[(i + 3) * 2 - 1 : (i + 2) * 2]),
			.in_rx_wr_enable_in_chnl_down(w_pcs8g_rx_wrenableoutchnlup[i + 0]),
			.in_rx_wr_enable_in_chnl_up(w_pcs8g_rx_wrenableoutchnldown[i + 2]),
			.in_speed_change_in_chnl_down(w_pcs8g_rx_speedchangeoutchnlup[i + 0]),
			.in_speed_change_in_chnl_up(w_pcs8g_rx_speedchangeoutchnldown[i + 2]),
			.in_tx_div_sync_in_chnl_down(w_pcs8g_tx_txdivsyncoutchnlup[(i + 1) * 2 - 1 : (i + 0) * 2]),
			.in_tx_div_sync_in_chnl_up(w_pcs8g_tx_txdivsyncoutchnldown[(i + 3) * 2 - 1 : (i + 2) * 2]),
			.in_tx_rd_enable_in_chnl_down(w_pcs8g_tx_rdenableoutchnlup[i + 0]),
			.in_tx_rd_enable_in_chnl_up(w_pcs8g_tx_rdenableoutchnldown[i + 2]),
			.in_tx_wr_enable_in_chnl_down(w_pcs8g_tx_wrenableoutchnlup[i + 0]),
			.in_tx_wr_enable_in_chnl_up(w_pcs8g_tx_wrenableoutchnldown[i + 2]),
			.in_usermode(in_usermode[i]),
			.out_agg_align_det_sync(out_agg_align_det_sync[(i + 1) * 2 - 1 : i * 2]),
			.out_agg_align_status_sync(out_agg_align_status_sync[i]),
			.out_agg_cg_comp_rd_d_out(out_agg_cg_comp_rd_d_out[(i + 1) * 2 - 1 : i * 2]),
			.out_agg_cg_comp_wr_out(out_agg_cg_comp_wr_out[(i + 1) * 2 - 1 : i * 2]),
			.out_agg_dec_ctl(out_agg_dec_ctl[i]),
			.out_agg_dec_data(out_agg_dec_data[(i + 1) * 8 - 1 : i * 8]),
			.out_agg_dec_data_valid(out_agg_dec_data_valid[i]),
			.out_agg_del_cond_met_out(out_agg_del_cond_met_out[i]),
			.out_agg_fifo_ovr_out(out_agg_fifo_ovr_out[i]),
			.out_agg_fifo_rd_out_comp(out_agg_fifo_rd_out_comp[i]),
			.out_agg_insert_incomplete_out(out_agg_insert_incomplete_out[i]),
			.out_agg_latency_comp_out(out_agg_latency_comp_out[i]),
			.out_agg_rd_align(out_agg_rd_align[(i + 1) * 2 - 1 : i * 2]),
			.out_agg_rd_enable_sync(out_agg_rd_enable_sync[i]),
			.out_agg_refclk_dig(out_agg_refclk_dig[i]),
			.out_agg_running_disp(out_agg_running_disp[(i + 1) * 2 - 1 : i * 2]),
			.out_agg_rxpcs_rst(out_agg_rxpcs_rst[i]),
			.out_agg_scan_mode_n(out_agg_scan_mode_n[i]),
			.out_agg_scan_shift_n(out_agg_scan_shift_n[i]),
			.out_agg_sync_status(out_agg_sync_status[i]),
			.out_agg_tx_ctl_tc(out_agg_tx_ctl_tc[i]),
			.out_agg_tx_data_tc(out_agg_tx_data_tc[(i + 1) * 8 - 1 : i * 8]),
			.out_agg_txpcs_rst(out_agg_txpcs_rst[i]),
			.out_avmmreaddata_com_pcs_pma_if(out_avmmreaddata_com_pcs_pma_if[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_com_pld_pcs_if(out_avmmreaddata_com_pld_pcs_if[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_pcs10g_rx(out_avmmreaddata_pcs10g_rx[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_pcs10g_tx(out_avmmreaddata_pcs10g_tx[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_pcs8g_rx(out_avmmreaddata_pcs8g_rx[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_pcs8g_tx(out_avmmreaddata_pcs8g_tx[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_pcs_g3_rx(out_avmmreaddata_pcs_g3_rx[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_pcs_g3_tx(out_avmmreaddata_pcs_g3_tx[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_pipe12(out_avmmreaddata_pipe12[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_pipe3(out_avmmreaddata_pipe3[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_rx_pcs_pma_if(out_avmmreaddata_rx_pcs_pma_if[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_rx_pld_pcs_if(out_avmmreaddata_rx_pld_pcs_if[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_tx_pcs_pma_if(out_avmmreaddata_tx_pcs_pma_if[(i + 1) * 16 - 1 : i * 16]),
			.out_avmmreaddata_tx_pld_pcs_if(out_avmmreaddata_tx_pld_pcs_if[(i + 1) * 16 - 1 : i * 16]),
			.out_blockselect_com_pcs_pma_if(out_blockselect_com_pcs_pma_if[i]),
			.out_blockselect_com_pld_pcs_if(out_blockselect_com_pld_pcs_if[i]),
			.out_blockselect_pcs10g_rx(out_blockselect_pcs10g_rx[i]),
			.out_blockselect_pcs10g_tx(out_blockselect_pcs10g_tx[i]),
			.out_blockselect_pcs8g_rx(out_blockselect_pcs8g_rx[i]),
			.out_blockselect_pcs8g_tx(out_blockselect_pcs8g_tx[i]),
			.out_blockselect_pcs_g3_rx(out_blockselect_pcs_g3_rx[i]),
			.out_blockselect_pcs_g3_tx(out_blockselect_pcs_g3_tx[i]),
			.out_blockselect_pipe12(out_blockselect_pipe12[i]),
			.out_blockselect_pipe3(out_blockselect_pipe3[i]),
			.out_blockselect_rx_pcs_pma_if(out_blockselect_rx_pcs_pma_if[i]),
			.out_blockselect_rx_pld_pcs_if(out_blockselect_rx_pld_pcs_if[i]),
			.out_blockselect_tx_pcs_pma_if(out_blockselect_tx_pcs_pma_if[i]),
			.out_blockselect_tx_pld_pcs_if(out_blockselect_tx_pld_pcs_if[i]),
			.out_config_sel_out_chnl_down(w_pcs8g_rx_configseloutchnldown[i + 1]),
			.out_config_sel_out_chnl_up(w_pcs8g_rx_configseloutchnlup[i + 1]),
			.out_emsip_com_clk_out(out_emsip_com_clk_out[(i + 1) * 3 - 1 : i * 3]),
			.out_emsip_com_out(out_emsip_com_out[(i + 1) * 27 - 1 : i * 27]),
			.out_emsip_com_special_out(out_emsip_com_special_out[(i + 1) * 20 - 1 : i * 20]),
			.out_emsip_rx_clk_out(out_emsip_rx_clk_out[(i + 1) * 3 - 1 : i * 3]),
			.out_emsip_rx_out(out_emsip_rx_out[(i + 1) * 129 - 1 : i * 129]),
			.out_emsip_rx_special_out(out_emsip_rx_special_out[(i + 1) * 16 - 1 : i * 16]),
			.out_emsip_tx_clk_out(out_emsip_tx_clk_out[(i + 1) * 3 - 1 : i * 3]),
			.out_emsip_tx_out(out_emsip_tx_out[(i + 1) * 12 - 1 : i * 12]),
			.out_emsip_tx_special_out(out_emsip_tx_special_out[(i + 1) * 16 - 1 : i * 16]),
			.out_fifo_select_out_chnl_down(w_pcs8g_tx_fifoselectoutchnldown[(i + 2) * 2 - 1 : (i + 1) * 2]),
			.out_fifo_select_out_chnl_up(w_pcs8g_tx_fifoselectoutchnlup[(i + 2) * 2 - 1 : (i + 1) * 2]),
			.out_pcs_10g_bundling_out_down({w_pcs10g_tx_distdwnoutrdpfull[i + 1],w_pcs10g_tx_distdwnoutintlknrden[i + 1]}),
			.out_pcs_10g_bundling_out_up({w_pcs10g_tx_distupoutrdpfull[i + 1],w_pcs10g_tx_distupoutintlknrden[i + 1]}),
			.out_pcs_10g_distdwn_out_dv(w_pcs10g_tx_distdwnoutdv[i + 1]),
			.out_pcs_10g_distdwn_out_rden(w_pcs10g_tx_distdwnoutrden[i + 1]),
			.out_pcs_10g_distdwn_out_wren(w_pcs10g_tx_distdwnoutwren[i + 1]),
			.out_pcs_10g_distup_out_dv(w_pcs10g_tx_distupoutdv[i + 1]),
			.out_pcs_10g_distup_out_rden(w_pcs10g_tx_distupoutrden[i + 1]),
			.out_pcs_10g_distup_out_wren(w_pcs10g_tx_distupoutwren[i + 1]),
			.out_pcs_gen3_bundling_out_down(w_pipe3_bundlingoutdown[(i + 2) * 11 - 1 : (i + 1) * 11]),
			.out_pcs_gen3_bundling_out_up(w_pipe3_bundlingoutup[(i + 2) * 11 - 1 : (i + 1) * 11]),
			.out_pld_10g_rx_align_val(out_pld_10g_rx_align_val[i]),
			.out_pld_10g_rx_blk_lock(out_pld_10g_rx_blk_lock[i]),
			.out_pld_10g_rx_clk_out(out_pld_10g_rx_clk_out[i]),
			.out_pld_10g_rx_control(out_pld_10g_rx_control[(i + 1) * 10 - 1 : i * 10]),
			.out_pld_10g_rx_crc32_err(out_pld_10g_rx_crc32_err[i]),
			.out_pld_10g_rx_data_valid(out_pld_10g_rx_data_valid[i]),
			.out_pld_10g_rx_diag_err(out_pld_10g_rx_diag_err[i]),
			.out_pld_10g_rx_diag_status(out_pld_10g_rx_diag_status[(i + 1) * 2 - 1 : i * 2]),
			.out_pld_10g_rx_empty(out_pld_10g_rx_empty[i]),
			.out_pld_10g_rx_fifo_del(out_pld_10g_rx_fifo_del[i]),
			.out_pld_10g_rx_fifo_insert(out_pld_10g_rx_fifo_insert[i]),
			.out_pld_10g_rx_frame_lock(out_pld_10g_rx_frame_lock[i]),
			.out_pld_10g_rx_hi_ber(out_pld_10g_rx_hi_ber[i]),
			.out_pld_10g_rx_mfrm_err(out_pld_10g_rx_mfrm_err[i]),
			.out_pld_10g_rx_oflw_err(out_pld_10g_rx_oflw_err[i]),
			.out_pld_10g_rx_pempty(out_pld_10g_rx_pempty[i]),
			.out_pld_10g_rx_pfull(out_pld_10g_rx_pfull[i]),
			.out_pld_10g_rx_prbs_err(out_pld_10g_rx_prbs_err[i]),
			.out_pld_10g_rx_pyld_ins(out_pld_10g_rx_pyld_ins[i]),
			.out_pld_10g_rx_rdneg_sts(out_pld_10g_rx_rdneg_sts[i]),
			.out_pld_10g_rx_rdpos_sts(out_pld_10g_rx_rdpos_sts[i]),
			.out_pld_10g_rx_rx_frame(out_pld_10g_rx_rx_frame[i]),
			.out_pld_10g_rx_scrm_err(out_pld_10g_rx_scrm_err[i]),
			.out_pld_10g_rx_sh_err(out_pld_10g_rx_sh_err[i]),
			.out_pld_10g_rx_skip_err(out_pld_10g_rx_skip_err[i]),
			.out_pld_10g_rx_skip_ins(out_pld_10g_rx_skip_ins[i]),
			.out_pld_10g_rx_sync_err(out_pld_10g_rx_sync_err[i]),
			.out_pld_10g_tx_burst_en_exe(out_pld_10g_tx_burst_en_exe[i]),
			.out_pld_10g_tx_clk_out(out_pld_10g_tx_clk_out[i]),
			.out_pld_10g_tx_empty(out_pld_10g_tx_empty[i]),
			.out_pld_10g_tx_fifo_del(out_pld_10g_tx_fifo_del[i]),
			.out_pld_10g_tx_fifo_insert(out_pld_10g_tx_fifo_insert[i]),
			.out_pld_10g_tx_frame(out_pld_10g_tx_frame[i]),
			.out_pld_10g_tx_full(out_pld_10g_tx_full[i]),
			.out_pld_10g_tx_pempty(out_pld_10g_tx_pempty[i]),
			.out_pld_10g_tx_pfull(out_pld_10g_tx_pfull[i]),
			.out_pld_10g_tx_wordslip_exe(out_pld_10g_tx_wordslip_exe[i]),
			.out_pld_8g_a1a2_k1k2_flag(out_pld_8g_a1a2_k1k2_flag[(i + 1) * 4 - 1 : i * 4]),
			.out_pld_8g_align_status(out_pld_8g_align_status[i]),
			.out_pld_8g_bistdone(out_pld_8g_bistdone[i]),
			.out_pld_8g_bisterr(out_pld_8g_bisterr[i]),
			.out_pld_8g_byteord_flag(out_pld_8g_byteord_flag[i]),
			.out_pld_8g_empty_rmf(out_pld_8g_empty_rmf[i]),
			.out_pld_8g_empty_rx(out_pld_8g_empty_rx[i]),
			.out_pld_8g_empty_tx(out_pld_8g_empty_tx[i]),
			.out_pld_8g_full_rmf(out_pld_8g_full_rmf[i]),
			.out_pld_8g_full_rx(out_pld_8g_full_rx[i]),
			.out_pld_8g_full_tx(out_pld_8g_full_tx[i]),
			.out_pld_8g_phystatus(out_pld_8g_phystatus[i]),
			.out_pld_8g_rlv_lt(out_pld_8g_rlv_lt[i]),
			.out_pld_8g_rx_blk_start(out_pld_8g_rx_blk_start[(i + 1) * 4 - 1 : i * 4]),
			.out_pld_8g_rx_clk_out(out_pld_8g_rx_clk_out[i]),
			.out_pld_8g_rx_data_valid(out_pld_8g_rx_data_valid[(i + 1) * 4 - 1 : i * 4]),
			.out_pld_8g_rx_sync_hdr(out_pld_8g_rx_sync_hdr[(i + 1) * 2 - 1 : i * 2]),
			.out_pld_8g_rxelecidle(out_pld_8g_rxelecidle[i]),
			.out_pld_8g_rxstatus(out_pld_8g_rxstatus[(i + 1) * 3 - 1 : i * 3]),
			.out_pld_8g_rxvalid(out_pld_8g_rxvalid[i]),
			.out_pld_8g_signal_detect_out(out_pld_8g_signal_detect_out[i]),
			.out_pld_8g_tx_clk_out(out_pld_8g_tx_clk_out[i]),
			.out_pld_8g_wa_boundary(out_pld_8g_wa_boundary[(i + 1) * 5 - 1 : i * 5]),
			.out_pld_clkdiv33_lc(out_pld_clkdiv33_lc[i]),
			.out_pld_clkdiv33_txorrx(out_pld_clkdiv33_txorrx[i]),
			.out_pld_clklow(out_pld_clklow[i]),
			.out_pld_fref(out_pld_fref[i]),
			.out_pld_gen3_mask_tx_pll(out_pld_gen3_mask_tx_pll[i]),
			.out_pld_gen3_rx_eq_ctrl(out_pld_gen3_rx_eq_ctrl[(i + 1) * 2 - 1 : i * 2]),
			.out_pld_gen3_rxdeemph(out_pld_gen3_rxdeemph[(i + 1) * 18 - 1 : i * 18]),
			.out_pld_reserved_out(out_pld_reserved_out[(i + 1) * 11 - 1 : i * 11]),
			.out_pld_rx_data(out_pld_rx_data[(i + 1) * 64 - 1 : i * 64]),
			.out_pld_test_data(out_pld_test_data[(i + 1) * 20 - 1 : i * 20]),
			.out_pld_test_si_to_agg_out(out_pld_test_si_to_agg_out[i]),
			.out_pma_current_coeff(out_pma_current_coeff[(i + 1) * 18 - 1 : i * 18]),
			.out_pma_current_rxpreset(out_pma_current_rxpreset[(i + 1) * 3 - 1 : i * 3]),
			.out_pma_early_eios(out_pma_early_eios[i]),
			.out_pma_eye_monitor_out(out_pma_eye_monitor_out[(i + 1) * 8 - 1 : i * 8]),
			.out_pma_lc_cmu_rstb(out_pma_lc_cmu_rstb[i]),
			.out_pma_ltr(out_pma_ltr[i]),
			.out_pma_nfrzdrv(out_pma_nfrzdrv[i]),
			.out_pma_partial_reconfig(out_pma_partial_reconfig[i]),
			.out_pma_pcie_switch(out_pma_pcie_switch[(i + 1) * 2 - 1 : i * 2]),
			.out_pma_ppm_lock(out_pma_ppm_lock[i]),
			.out_pma_reserved_out(out_pma_reserved_out[(i + 1) * 5 - 1 : i * 5]),
			.out_pma_rx_clk_out(out_pma_rx_clk_out[i]),
			.out_pma_rxclkslip(out_pma_rxclkslip[i]),
			.out_pma_rxpma_rstb(out_pma_rxpma_rstb[i]),
			.out_pma_tx_clk_out(out_pma_tx_clk_out[i]),
			.out_pma_tx_data(out_pma_tx_data[(i + 1) * 80 - 1 : i * 80]),
			.out_pma_tx_elec_idle(out_pma_tx_elec_idle[i]),
			.out_pma_tx_pma_syncp_fbkp(out_pma_tx_pma_syncp_fbkp[i]),
			.out_pma_txdetectrx(out_pma_txdetectrx[i]),
			.out_reset_pc_ptrs_out_chnl_down(w_pcs8g_rx_resetpcptrsoutchnldown[i + 1]),
			.out_reset_pc_ptrs_out_chnl_up(w_pcs8g_rx_resetpcptrsoutchnlup[i + 1]),
			.out_reset_ppm_cntrs_out_chnl_down(w_pcs8g_rx_resetppmcntrsoutchnldown[i + 1]),
			.out_reset_ppm_cntrs_out_chnl_up(w_pcs8g_rx_resetppmcntrsoutchnlup[i + 1]),
			.out_rx_div_sync_out_chnl_down(w_pcs8g_rx_rxdivsyncoutchnldown[(i + 2) * 2 - 1 : (i + 1) * 2]),
			.out_rx_div_sync_out_chnl_up(w_pcs8g_rx_rxdivsyncoutchnlup[(i + 2) * 2 - 1 : (i + 1) * 2]),
			.out_rx_rd_enable_out_chnl_down(w_pcs8g_rx_rdenableoutchnldown[i + 1]),
			.out_rx_rd_enable_out_chnl_up(w_pcs8g_rx_rdenableoutchnlup[i + 1]),
			.out_rx_we_out_chnl_down(w_pcs8g_rx_rxweoutchnldown[(i + 2) * 2 - 1 : (i + 1) * 2]),
			.out_rx_we_out_chnl_up(w_pcs8g_rx_rxweoutchnlup[(i + 2) * 2 - 1 : (i + 1) * 2]),
			.out_rx_wr_enable_out_chnl_down(w_pcs8g_rx_wrenableoutchnldown[i + 1]),
			.out_rx_wr_enable_out_chnl_up(w_pcs8g_rx_wrenableoutchnlup[i + 1]),
			.out_speed_change_out_chnl_down(w_pcs8g_rx_speedchangeoutchnldown[i + 1]),
			.out_speed_change_out_chnl_up(w_pcs8g_rx_speedchangeoutchnlup[i + 1]),
			.out_tx_div_sync_out_chnl_down(w_pcs8g_tx_txdivsyncoutchnldown[(i + 2) * 2 - 1 : (i + 1) * 2]),
			.out_tx_div_sync_out_chnl_up(w_pcs8g_tx_txdivsyncoutchnlup[(i + 2) * 2 - 1 : (i + 1) * 2]),
			.out_tx_rd_enable_out_chnl_down(w_pcs8g_tx_rdenableoutchnldown[i + 1]),
			.out_tx_rd_enable_out_chnl_up(w_pcs8g_tx_rdenableoutchnlup[i + 1]),
			.out_tx_wr_enable_out_chnl_down(w_pcs8g_tx_wrenableoutchnldown[i + 1]),
			.out_tx_wr_enable_out_chnl_up(w_pcs8g_tx_wrenableoutchnlup[i + 1])
		);
	end
	endgenerate

    
	// Tie-off bonding control-plane input signals for SpyGlass warnings.
         assign w_pcs8g_rx_rxdivsyncoutchnlup[1:0] = 2'b00;                  
         assign w_pcs8g_rx_rxdivsyncoutchnldown[(bonded_lanes + 2) * 2 - 1 : (bonded_lanes + 2) * 2 - 2] = 2'b00;         
         assign w_pcs8g_rx_rxweoutchnlup[1:0] = 2'b00;         
         assign w_pcs8g_rx_rxweoutchnldown[(bonded_lanes + 2) * 2 - 1 : (bonded_lanes + 2) * 2 - 2] = 2'b00;         
         assign w_pcs8g_tx_txdivsyncoutchnlup[1:0] = 2'b00;         
         assign w_pcs8g_tx_txdivsyncoutchnldown[(bonded_lanes + 2) * 2 - 1 : (bonded_lanes + 2) * 2 - 2] = 2'b00;
         assign w_pcs8g_tx_fifoselectoutchnlup[1:0] = 2'b00;
         assign w_pcs8g_tx_fifoselectoutchnldown[(bonded_lanes + 2) * 2 - 1 : (bonded_lanes + 2) * 2 - 2] = 2'b00;

         assign w_pcs8g_rx_configseloutchnlup[0] = 1'b0;
         assign w_pcs8g_rx_configseloutchnldown[bonded_lanes+1]= 1'b0;
         assign w_pcs8g_rx_resetpcptrsoutchnlup[0] = 1'b0;
         assign w_pcs8g_rx_resetpcptrsoutchnldown[bonded_lanes+1]= 1'b0;
         assign w_pcs8g_rx_resetppmcntrsoutchnlup[0] = 1'b0;
         assign w_pcs8g_rx_resetppmcntrsoutchnldown[bonded_lanes+1]= 1'b0;
         assign w_pcs8g_rx_rdenableoutchnlup[0] = 1'b0;
         assign w_pcs8g_rx_rdenableoutchnldown[bonded_lanes+1]= 1'b0;
         assign w_pcs8g_rx_wrenableoutchnlup[0] = 1'b0;
         assign w_pcs8g_rx_wrenableoutchnldown[bonded_lanes+1]= 1'b0;
         assign w_pcs8g_rx_speedchangeoutchnlup[0] = 1'b0;
         assign w_pcs8g_rx_speedchangeoutchnldown[bonded_lanes+1]= 1'b0;
         assign w_pcs8g_tx_rdenableoutchnlup[0] = 1'b0;
         assign w_pcs8g_tx_rdenableoutchnldown[bonded_lanes+1]= 1'b0;
         assign w_pcs8g_tx_wrenableoutchnlup[0] = 1'b0;
         assign w_pcs8g_tx_wrenableoutchnldown[bonded_lanes+1]= 1'b0;
 
         assign w_pcs10g_tx_distupoutrdpfull[0] = 1'b0;
         assign w_pcs10g_tx_distupoutintlknrden[0] = 1'b0;
         assign w_pcs10g_tx_distdwnoutrdpfull[bonded_lanes+1]= 1'b0;
         assign w_pcs10g_tx_distdwnoutintlknrden[bonded_lanes+1]= 1'b0;

         assign w_pcs10g_tx_distupoutdv[0] = 1'b0;
         assign w_pcs10g_tx_distupoutrden[0] = 1'b0;
         assign w_pcs10g_tx_distupoutwren[0] = 1'b0;
         assign w_pcs10g_tx_distdwnoutdv[bonded_lanes+1]= 1'b0;
         assign w_pcs10g_tx_distdwnoutrden[bonded_lanes+1]= 1'b0;
         assign w_pcs10g_tx_distdwnoutwren[bonded_lanes+1]= 1'b0;

endmodule
