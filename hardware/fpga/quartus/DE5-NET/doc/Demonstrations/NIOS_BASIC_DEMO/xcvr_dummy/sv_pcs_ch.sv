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
// ./core_phy_ip_hdl//sv_pcs_ch.sv
// automatically generated at 12:51:13, Thu Jan 26, 2012
//
//


// This module contains the following atoms:
// 	sv_hssi_rx_pcs_pma_interface
// 	sv_hssi_10g_rx_pcs
// 	sv_hssi_8g_rx_pcs
// 	sv_hssi_pipe_gen3
// 	sv_hssi_gen3_rx_pcs
// 	sv_hssi_8g_tx_pcs
// 	sv_hssi_gen3_tx_pcs
// 	sv_hssi_tx_pld_pcs_interface
// 	sv_hssi_rx_pld_pcs_interface
// 	sv_hssi_10g_tx_pcs
// 	sv_hssi_pipe_gen1_2
// 	sv_hssi_common_pcs_pma_interface
// 	sv_hssi_common_pld_pcs_interface
// 	sv_hssi_tx_pcs_pma_interface

`timescale 1ps/1ps
// altera message_off 10036 

module sv_pcs_ch
	#(
		parameter enable_10g_rx = "true",
		parameter enable_10g_tx = "true",
		parameter enable_8g_rx = "true",
		parameter enable_8g_tx = "true",
		parameter enable_dyn_reconfig = "true",
		parameter enable_gen12_pipe = "true",
		parameter enable_gen3_pipe = "true",
		parameter enable_gen3_rx = "true",
		parameter enable_gen3_tx = "true",
	        parameter enable_pma_direct_tx = "false",                    // (true,false) Enable, disable the PMA Direct path
	        parameter enable_pma_direct_rx = "false",                    // (true,false) Enable, disable the PMA Direct path				  
		parameter channel_number = 0,
		
		// parameters for sv_hssi_10g_rx_pcs
		parameter pcs10g_rx_align_del = "<auto_single>", // align_del_dis|align_del_en
		parameter pcs10g_rx_ber_bit_err_total_cnt = "bit_err_total_cnt_10g", // bit_err_total_cnt_10g
		parameter pcs10g_rx_ber_clken = "<auto_single>", // ber_clk_dis|ber_clk_en
		parameter pcs10g_rx_ber_xus_timer_window = "<auto_single>", // xus_timer_window_10g|xus_timer_window_user_setting
		parameter pcs10g_rx_ber_xus_timer_window_user = 21'b100110001001010,
		parameter pcs10g_rx_bit_reverse = "<auto_single>", // bit_reverse_dis|bit_reverse_en
		parameter pcs10g_rx_bitslip_mode = "<auto_single>", // bitslip_dis|bitslip_en
		parameter pcs10g_rx_bitslip_wait_cnt_user = 1, // 0..7
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
		parameter pcs10g_rx_crcchk_init_user = 32'b11111111111111111111111111111111,
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
		parameter pcs10g_rx_dispchk_rd_level_user = 8'b1100000,
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
		parameter pcs10g_rx_stretch_en = "stretch_en", // stretch_en|stretch_dis
		parameter pcs10g_rx_stretch_num_stages = "<auto_single>", // zero_stage|one_stage|two_stage|three_stage
		parameter pcs10g_rx_stretch_type = "<auto_single>", // stretch_auto|stretch_custom
		parameter pcs10g_rx_sup_mode = "<auto_single>", // user_mode|engineering_mode|stretch_mode|engr_mode
		parameter pcs10g_rx_test_bus_mode = "tx", // tx|rx
		parameter pcs10g_rx_test_mode = "<auto_single>", // test_off|pseudo_random|prbs_31|prbs_23|prbs_9|prbs_7
		parameter pcs10g_rx_use_default_base_address = "true", // false|true
		parameter pcs10g_rx_user_base_address = 0, // 0..2047
		parameter pcs10g_rx_wrfifo_clken = "<auto_single>", // wrfifo_clk_dis|wrfifo_clk_en
		
		// parameters for sv_hssi_10g_tx_pcs
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
		parameter pcs10g_tx_crcgen_init_user = 32'b11111111111111111111111111111111,
		parameter pcs10g_tx_crcgen_inv = "<auto_single>", // crcgen_inv_dis|crcgen_inv_en
		parameter pcs10g_tx_ctrl_bit_reverse = "<auto_single>", // ctrl_bit_reverse_dis|ctrl_bit_reverse_en
		parameter pcs10g_tx_ctrl_plane_bonding = "<auto_single>", // individual|ctrl_master|ctrl_slave_abv|ctrl_slave_blw
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
		parameter pcs10g_tx_stretch_en = "stretch_en", // stretch_en|stretch_dis
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
		
		// parameters for sv_hssi_8g_rx_pcs
		parameter pcs8g_rx_agg_block_sel = "<auto_single>", // same_smrt_pack|other_smrt_pack
		parameter pcs8g_rx_auto_deassert_pc_rst_cnt_data = 5'b0,
		parameter pcs8g_rx_auto_error_replacement = "<auto_single>", // dis_err_replace|en_err_replace
		parameter pcs8g_rx_auto_pc_en_cnt_data = 7'b0,
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
		parameter pcs8g_rx_ctrl_plane_bonding_compensation = "<auto_single>", // dis_compensation|en_compensation
		parameter pcs8g_rx_ctrl_plane_bonding_consumption = "<auto_single>", // individual|bundled_master|bundled_slave_below|bundled_slave_above
		parameter pcs8g_rx_ctrl_plane_bonding_distribution = "<auto_single>", // master_chnl_distr|not_master_chnl_distr
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
		parameter pcs8g_rx_wait_for_phfifo_cnt_data = 6'b0,
		
		// parameters for sv_hssi_8g_tx_pcs
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
		parameter pcs8g_tx_ctrl_plane_bonding_compensation = "<auto_single>", // dis_compensation|en_compensation
		parameter pcs8g_tx_ctrl_plane_bonding_consumption = "<auto_single>", // individual|bundled_master|bundled_slave_below|bundled_slave_above
		parameter pcs8g_tx_ctrl_plane_bonding_distribution = "<auto_single>", // master_chnl_distr|not_master_chnl_distr
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
		
		// parameters for sv_hssi_common_pcs_pma_interface
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
		
		// parameters for sv_hssi_common_pld_pcs_interface
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
		
		// parameters for sv_hssi_gen3_rx_pcs
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
		
		// parameters for sv_hssi_gen3_tx_pcs
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
		
		// parameters for sv_hssi_pipe_gen1_2
		parameter pipe12_ctrl_plane_bonding_consumption = "individual", // individual|bundled_master|bundled_slave_below|bundled_slave_above
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
		
		// parameters for sv_hssi_pipe_gen3
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
		parameter pipe3_cp_cons_sel = "<auto_single>", // cp_cons_master|cp_cons_slave_abv|cp_cons_slave_blw|cp_cons_default
		parameter pipe3_cp_dwn_mstr = "<auto_single>", // false|true
		parameter pipe3_cp_up_mstr = "<auto_single>", // false|true
		parameter pipe3_ctrl_plane_bonding = "<auto_single>", // individual|ctrl_master|ctrl_slave_blw|ctrl_slave_abv
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
		
		// parameters for sv_hssi_rx_pcs_pma_interface
		parameter rx_pcs_pma_if_clkslip_sel = "<auto_single>", // pld|slip_eight_g_pcs
		parameter rx_pcs_pma_if_prot_mode = "<auto_single>", // other_protocols|cpri_8g
		parameter rx_pcs_pma_if_selectpcs = "eight_g_pcs", // eight_g_pcs|ten_g_pcs|pcie_gen3|default
		parameter rx_pcs_pma_if_use_default_base_address = "true", // false|true
		parameter rx_pcs_pma_if_user_base_address = 0, // 0..2047
		
		// parameters for sv_hssi_rx_pld_pcs_interface
		parameter rx_pld_pcs_if_data_source = "pld", // emsip|pld
		parameter rx_pld_pcs_if_is_10g_0ppm = "false", // false|true
		parameter rx_pld_pcs_if_is_8g_0ppm = "false", // false|true
		parameter rx_pld_pcs_if_selectpcs = "eight_g_pcs", // eight_g_pcs|ten_g_pcs|default
		parameter rx_pld_pcs_if_use_default_base_address = "true", // false|true
		parameter rx_pld_pcs_if_user_base_address = 0, // 0..2047
		
		// parameters for sv_hssi_tx_pcs_pma_interface
		parameter tx_pcs_pma_if_selectpcs = "eight_g_pcs", // eight_g_pcs|ten_g_pcs|pcie_gen3|default
		parameter tx_pcs_pma_if_use_default_base_address = "true", // false|true
		parameter tx_pcs_pma_if_user_base_address = 0, // 0..2047
		
		// parameters for sv_hssi_tx_pld_pcs_interface
		parameter tx_pld_pcs_if_data_source = "pld", // emsip|pld
		parameter tx_pld_pcs_if_is_10g_0ppm = "false", // false|true
		parameter tx_pld_pcs_if_is_8g_0ppm = "false", // false|true
		parameter tx_pld_pcs_if_use_default_base_address = "true", // false|true
		parameter tx_pld_pcs_if_user_base_address = 0 // 0..2047
	)
	(
		input wire		in_agg_align_status,
		input wire		in_agg_align_status_sync_0,
		input wire		in_agg_align_status_sync_0_top_or_bot,
		input wire		in_agg_align_status_top_or_bot,
		input wire		in_agg_cg_comp_rd_d_all,
		input wire		in_agg_cg_comp_rd_d_all_top_or_bot,
		input wire		in_agg_cg_comp_wr_all,
		input wire		in_agg_cg_comp_wr_all_top_or_bot,
		input wire		in_agg_del_cond_met_0,
		input wire		in_agg_del_cond_met_0_top_or_bot,
		input wire		in_agg_en_dskw_qd,
		input wire		in_agg_en_dskw_qd_top_or_bot,
		input wire		in_agg_en_dskw_rd_ptrs,
		input wire		in_agg_en_dskw_rd_ptrs_top_or_bot,
		input wire		in_agg_fifo_ovr_0,
		input wire		in_agg_fifo_ovr_0_top_or_bot,
		input wire		in_agg_fifo_rd_in_comp_0,
		input wire		in_agg_fifo_rd_in_comp_0_top_or_bot,
		input wire		in_agg_fifo_rst_rd_qd,
		input wire		in_agg_fifo_rst_rd_qd_top_or_bot,
		input wire		in_agg_insert_incomplete_0,
		input wire		in_agg_insert_incomplete_0_top_or_bot,
		input wire		in_agg_latency_comp_0,
		input wire		in_agg_latency_comp_0_top_or_bot,
		input wire		in_agg_rcvd_clk_agg,
		input wire		in_agg_rcvd_clk_agg_top_or_bot,
		input wire		in_agg_rx_control_rs,
		input wire		in_agg_rx_control_rs_top_or_bot,
		input wire	[7:0]	in_agg_rx_data_rs,
		input wire	[7:0]	in_agg_rx_data_rs_top_or_bot,
		input wire		in_agg_test_so_to_pld_in,
		input wire	[15:0]	in_agg_testbus,
		input wire		in_agg_tx_ctl_ts,
		input wire		in_agg_tx_ctl_ts_top_or_bot,
		input wire	[7:0]	in_agg_tx_data_ts,
		input wire	[7:0]	in_agg_tx_data_ts_top_or_bot,
		input wire	[10:0]	in_avmmaddress,
		input wire	[1:0]	in_avmmbyteen,
		input wire		in_avmmclk,
		input wire		in_avmmread,
		input wire		in_avmmrstn,
		input wire		in_avmmwrite,
		input wire	[15:0]	in_avmmwritedata,
		input wire		in_config_sel_in_chnl_down,
		input wire		in_config_sel_in_chnl_up,
		input wire	[37:0]	in_emsip_com_in,
		input wire	[19:0]	in_emsip_com_special_in,
		input wire	[2:0]	in_emsip_rx_clk_in,
		input wire	[19:0]	in_emsip_rx_in,
		input wire	[12:0]	in_emsip_rx_special_in,
		input wire	[2:0]	in_emsip_tx_clk_in,
		input wire	[103:0]	in_emsip_tx_in,
		input wire	[12:0]	in_emsip_tx_special_in,
		input wire		in_entest,
		input wire	[1:0]	in_fifo_select_in_chnl_down,
		input wire	[1:0]	in_fifo_select_in_chnl_up,
		input wire		in_frzreg,
		input wire		in_iocsr_rdy_dly,
		input wire		in_nfrzdrv,
		input wire		in_npor,
		input wire	[1:0]	in_pcs_10g_bundling_in_down,
		input wire	[1:0]	in_pcs_10g_bundling_in_up,
		input wire		in_pcs_10g_distdwn_in_dv,
		input wire		in_pcs_10g_distdwn_in_rden,
		input wire		in_pcs_10g_distdwn_in_wren,
		input wire		in_pcs_10g_distup_in_dv,
		input wire		in_pcs_10g_distup_in_rden,
		input wire		in_pcs_10g_distup_in_wren,
		input wire	[10:0]	in_pcs_gen3_bundling_in_down,
		input wire	[10:0]	in_pcs_gen3_bundling_in_up,
		input wire		in_pld_10g_refclk_dig,
		input wire		in_pld_10g_rx_align_clr,
		input wire		in_pld_10g_rx_align_en,
		input wire		in_pld_10g_rx_bitslip,
		input wire		in_pld_10g_rx_clr_ber_count,
		input wire		in_pld_10g_rx_clr_errblk_cnt,
		input wire		in_pld_10g_rx_disp_clr,
		input wire		in_pld_10g_rx_pld_clk,
		input wire		in_pld_10g_rx_prbs_err_clr,
		input wire		in_pld_10g_rx_rd_en,
		input wire		in_pld_10g_rx_rst_n,
		input wire	[6:0]	in_pld_10g_tx_bitslip,
		input wire		in_pld_10g_tx_burst_en,
		input wire	[8:0]	in_pld_10g_tx_control,
		input wire		in_pld_10g_tx_data_valid,
		input wire	[1:0]	in_pld_10g_tx_diag_status,
		input wire		in_pld_10g_tx_pld_clk,
		input wire		in_pld_10g_tx_rst_n,
		input wire		in_pld_10g_tx_wordslip,
		input wire		in_pld_8g_a1a2_size,
		input wire		in_pld_8g_bitloc_rev_en,
		input wire		in_pld_8g_bitslip,
		input wire		in_pld_8g_byte_rev_en,
		input wire		in_pld_8g_bytordpld,
		input wire		in_pld_8g_cmpfifourst_n,
		input wire		in_pld_8g_encdt,
		input wire		in_pld_8g_phfifourst_rx_n,
		input wire		in_pld_8g_phfifourst_tx_n,
		input wire		in_pld_8g_pld_rx_clk,
		input wire		in_pld_8g_pld_tx_clk,
		input wire		in_pld_8g_polinv_rx,
		input wire		in_pld_8g_polinv_tx,
		input wire	[1:0]	in_pld_8g_powerdown,
		input wire		in_pld_8g_prbs_cid_en,
		input wire		in_pld_8g_rddisable_tx,
		input wire		in_pld_8g_rdenable_rmf,
		input wire		in_pld_8g_rdenable_rx,
		input wire		in_pld_8g_refclk_dig,
		input wire		in_pld_8g_refclk_dig2,
		input wire		in_pld_8g_rev_loopbk,
		input wire		in_pld_8g_rxpolarity,
		input wire		in_pld_8g_rxurstpcs_n,
		input wire	[3:0]	in_pld_8g_tx_blk_start,
		input wire	[4:0]	in_pld_8g_tx_boundary_sel,
		input wire	[3:0]	in_pld_8g_tx_data_valid,
		input wire	[1:0]	in_pld_8g_tx_sync_hdr,
		input wire		in_pld_8g_txdeemph,
		input wire		in_pld_8g_txdetectrxloopback,
		input wire		in_pld_8g_txelecidle,
		input wire	[2:0]	in_pld_8g_txmargin,
		input wire		in_pld_8g_txswing,
		input wire		in_pld_8g_txurstpcs_n,
		input wire		in_pld_8g_wrdisable_rx,
		input wire		in_pld_8g_wrenable_rmf,
		input wire		in_pld_8g_wrenable_tx,
		input wire		in_pld_agg_refclk_dig,
		input wire	[2:0]	in_pld_eidleinfersel,
		input wire	[17:0]	in_pld_gen3_current_coeff,
		input wire	[2:0]	in_pld_gen3_current_rxpreset,
		input wire		in_pld_gen3_rx_rstn,
		input wire		in_pld_gen3_tx_rstn,
		input wire		in_pld_ltr,
		input wire		in_pld_partial_reconfig_in,
		input wire		in_pld_pcs_pma_if_refclk_dig,
		input wire	[1:0]	in_pld_rate,
		input wire	[11:0]	in_pld_reserved_in,
		input wire		in_pld_rx_clk_slip_in,
		input wire		in_pld_rxpma_rstb_in,
		input wire		in_pld_scan_mode_n,
		input wire		in_pld_scan_shift_n,
		input wire		in_pld_sync_sm_en,
		input wire	[63:0]	in_pld_tx_data,
		input wire		in_plniotri,
		input wire		in_pma_clkdiv33_lc_in,
		input wire		in_pma_clkdiv33_txorrx_in,
		input wire		in_pma_clklow_in,
		input wire	[1:0]	in_pma_eye_monitor_in,
		input wire		in_pma_fref_in,
		input wire		in_pma_hclk,
		input wire	[1:0]	in_pma_pcie_sw_done,
		input wire	[4:0]	in_pma_reserved_in,
		input wire	[79:0]	in_pma_rx_data,
		input wire		in_pma_rx_detect_valid,
		input wire		in_pma_rx_found,
		input wire		in_pma_rx_freq_tx_cmu_pll_lock_in,
		input wire		in_pma_rx_pll_phase_lock_in,
		input wire		in_pma_rx_pma_clk,
		input wire		in_pma_sigdet,
		input wire		in_pma_signal_ok,
		input wire		in_pma_tx_lc_pll_lock_in,
		input wire		in_pma_tx_pma_clk,
		input wire		in_reset_pc_ptrs_in_chnl_down,
		input wire		in_reset_pc_ptrs_in_chnl_up,
		input wire		in_reset_ppm_cntrs_in_chnl_down,
		input wire		in_reset_ppm_cntrs_in_chnl_up,
		input wire	[1:0]	in_rx_div_sync_in_chnl_down,
		input wire	[1:0]	in_rx_div_sync_in_chnl_up,
		input wire		in_rx_rd_enable_in_chnl_down,
		input wire		in_rx_rd_enable_in_chnl_up,
		input wire	[1:0]	in_rx_we_in_chnl_down,
		input wire	[1:0]	in_rx_we_in_chnl_up,
		input wire		in_rx_wr_enable_in_chnl_down,
		input wire		in_rx_wr_enable_in_chnl_up,
		input wire		in_speed_change_in_chnl_down,
		input wire		in_speed_change_in_chnl_up,
		input wire	[1:0]	in_tx_div_sync_in_chnl_down,
		input wire	[1:0]	in_tx_div_sync_in_chnl_up,
		input wire		in_tx_rd_enable_in_chnl_down,
		input wire		in_tx_rd_enable_in_chnl_up,
		input wire		in_tx_wr_enable_in_chnl_down,
		input wire		in_tx_wr_enable_in_chnl_up,
		input wire		in_usermode,
		output wire	[1:0]	out_agg_align_det_sync,
		output wire		out_agg_align_status_sync,
		output wire	[1:0]	out_agg_cg_comp_rd_d_out,
		output wire	[1:0]	out_agg_cg_comp_wr_out,
		output wire		out_agg_dec_ctl,
		output wire	[7:0]	out_agg_dec_data,
		output wire		out_agg_dec_data_valid,
		output wire		out_agg_del_cond_met_out,
		output wire		out_agg_fifo_ovr_out,
		output wire		out_agg_fifo_rd_out_comp,
		output wire		out_agg_insert_incomplete_out,
		output wire		out_agg_latency_comp_out,
		output wire	[1:0]	out_agg_rd_align,
		output wire		out_agg_rd_enable_sync,
		output wire		out_agg_refclk_dig,
		output wire	[1:0]	out_agg_running_disp,
		output wire		out_agg_rxpcs_rst,
		output wire		out_agg_scan_mode_n,
		output wire		out_agg_scan_shift_n,
		output wire		out_agg_sync_status,
		output wire		out_agg_tx_ctl_tc,
		output wire	[7:0]	out_agg_tx_data_tc,
		output wire		out_agg_txpcs_rst,
		output wire	[15:0]	out_avmmreaddata_com_pcs_pma_if,
		output wire	[15:0]	out_avmmreaddata_com_pld_pcs_if,
		output wire	[15:0]	out_avmmreaddata_pcs10g_rx,
		output wire	[15:0]	out_avmmreaddata_pcs10g_tx,
		output wire	[15:0]	out_avmmreaddata_pcs8g_rx,
		output wire	[15:0]	out_avmmreaddata_pcs8g_tx,
		output wire	[15:0]	out_avmmreaddata_pcs_g3_rx,
		output wire	[15:0]	out_avmmreaddata_pcs_g3_tx,
		output wire	[15:0]	out_avmmreaddata_pipe12,
		output wire	[15:0]	out_avmmreaddata_pipe3,
		output wire	[15:0]	out_avmmreaddata_rx_pcs_pma_if,
		output wire	[15:0]	out_avmmreaddata_rx_pld_pcs_if,
		output wire	[15:0]	out_avmmreaddata_tx_pcs_pma_if,
		output wire	[15:0]	out_avmmreaddata_tx_pld_pcs_if,
		output wire		out_blockselect_com_pcs_pma_if,
		output wire		out_blockselect_com_pld_pcs_if,
		output wire		out_blockselect_pcs10g_rx,
		output wire		out_blockselect_pcs10g_tx,
		output wire		out_blockselect_pcs8g_rx,
		output wire		out_blockselect_pcs8g_tx,
		output wire		out_blockselect_pcs_g3_rx,
		output wire		out_blockselect_pcs_g3_tx,
		output wire		out_blockselect_pipe12,
		output wire		out_blockselect_pipe3,
		output wire		out_blockselect_rx_pcs_pma_if,
		output wire		out_blockselect_rx_pld_pcs_if,
		output wire		out_blockselect_tx_pcs_pma_if,
		output wire		out_blockselect_tx_pld_pcs_if,
		output wire		out_config_sel_out_chnl_down,
		output wire		out_config_sel_out_chnl_up,
		output wire	[2:0]	out_emsip_com_clk_out,
		output wire	[26:0]	out_emsip_com_out,
		output wire	[19:0]	out_emsip_com_special_out,
		output wire	[2:0]	out_emsip_rx_clk_out,
		output wire	[128:0]	out_emsip_rx_out,
		output wire	[15:0]	out_emsip_rx_special_out,
		output wire	[2:0]	out_emsip_tx_clk_out,
		output wire	[11:0]	out_emsip_tx_out,
		output wire	[15:0]	out_emsip_tx_special_out,
		output wire	[1:0]	out_fifo_select_out_chnl_down,
		output wire	[1:0]	out_fifo_select_out_chnl_up,
		output wire	[1:0]	out_pcs_10g_bundling_out_down,
		output wire	[1:0]	out_pcs_10g_bundling_out_up,
		output wire		out_pcs_10g_distdwn_out_dv,
		output wire		out_pcs_10g_distdwn_out_rden,
		output wire		out_pcs_10g_distdwn_out_wren,
		output wire		out_pcs_10g_distup_out_dv,
		output wire		out_pcs_10g_distup_out_rden,
		output wire		out_pcs_10g_distup_out_wren,
		output wire	[10:0]	out_pcs_gen3_bundling_out_down,
		output wire	[10:0]	out_pcs_gen3_bundling_out_up,
		output wire		out_pld_10g_rx_align_val,
		output wire		out_pld_10g_rx_blk_lock,
		output wire		out_pld_10g_rx_clk_out,
		output wire	[9:0]	out_pld_10g_rx_control,
		output wire		out_pld_10g_rx_crc32_err,
		output wire		out_pld_10g_rx_data_valid,
		output wire		out_pld_10g_rx_diag_err,
		output wire	[1:0]	out_pld_10g_rx_diag_status,
		output wire		out_pld_10g_rx_empty,
		output wire		out_pld_10g_rx_fifo_del,
		output wire		out_pld_10g_rx_fifo_insert,
		output wire		out_pld_10g_rx_frame_lock,
		output wire		out_pld_10g_rx_hi_ber,
		output wire		out_pld_10g_rx_mfrm_err,
		output wire		out_pld_10g_rx_oflw_err,
		output wire		out_pld_10g_rx_pempty,
		output wire		out_pld_10g_rx_pfull,
		output wire		out_pld_10g_rx_prbs_err,
		output wire		out_pld_10g_rx_pyld_ins,
		output wire		out_pld_10g_rx_rdneg_sts,
		output wire		out_pld_10g_rx_rdpos_sts,
		output wire		out_pld_10g_rx_rx_frame,
		output wire		out_pld_10g_rx_scrm_err,
		output wire		out_pld_10g_rx_sh_err,
		output wire		out_pld_10g_rx_skip_err,
		output wire		out_pld_10g_rx_skip_ins,
		output wire		out_pld_10g_rx_sync_err,
		output wire		out_pld_10g_tx_burst_en_exe,
		output wire		out_pld_10g_tx_clk_out,
		output wire		out_pld_10g_tx_empty,
		output wire		out_pld_10g_tx_fifo_del,
		output wire		out_pld_10g_tx_fifo_insert,
		output wire		out_pld_10g_tx_frame,
		output wire		out_pld_10g_tx_full,
		output wire		out_pld_10g_tx_pempty,
		output wire		out_pld_10g_tx_pfull,
		output wire		out_pld_10g_tx_wordslip_exe,
		output wire	[3:0]	out_pld_8g_a1a2_k1k2_flag,
		output wire		out_pld_8g_align_status,
		output wire		out_pld_8g_bistdone,
		output wire		out_pld_8g_bisterr,
		output wire		out_pld_8g_byteord_flag,
		output wire		out_pld_8g_empty_rmf,
		output wire		out_pld_8g_empty_rx,
		output wire		out_pld_8g_empty_tx,
		output wire		out_pld_8g_full_rmf,
		output wire		out_pld_8g_full_rx,
		output wire		out_pld_8g_full_tx,
		output wire		out_pld_8g_phystatus,
		output wire		out_pld_8g_rlv_lt,
		output wire	[3:0]	out_pld_8g_rx_blk_start,
		output wire		out_pld_8g_rx_clk_out,
		output wire	[3:0]	out_pld_8g_rx_data_valid,
		output wire	[1:0]	out_pld_8g_rx_sync_hdr,
		output wire		out_pld_8g_rxelecidle,
		output wire	[2:0]	out_pld_8g_rxstatus,
		output wire		out_pld_8g_rxvalid,
		output wire		out_pld_8g_signal_detect_out,
		output wire		out_pld_8g_tx_clk_out,
		output wire	[4:0]	out_pld_8g_wa_boundary,
		output wire		out_pld_clkdiv33_lc,
		output wire		out_pld_clkdiv33_txorrx,
		output wire		out_pld_clklow,
		output wire		out_pld_fref,
		output wire		out_pld_gen3_mask_tx_pll,
		output wire	[1:0]	out_pld_gen3_rx_eq_ctrl,
		output wire	[17:0]	out_pld_gen3_rxdeemph,
		output wire	[10:0]	out_pld_reserved_out,
		output wire	[63:0]	out_pld_rx_data,
		output wire	[19:0]	out_pld_test_data,
		output wire		out_pld_test_si_to_agg_out,
		output wire	[17:0]	out_pma_current_coeff,
		output wire	[2:0]	out_pma_current_rxpreset,
		output wire		out_pma_early_eios,
		output wire	[7:0]	out_pma_eye_monitor_out,
		output wire		out_pma_lc_cmu_rstb,
		output wire		out_pma_ltr,
		output wire		out_pma_nfrzdrv,
		output wire		out_pma_partial_reconfig,
		output wire	[1:0]	out_pma_pcie_switch,
		output wire		out_pma_ppm_lock,
		output wire	[4:0]	out_pma_reserved_out,
		output wire		out_pma_rx_clk_out,
		output wire		out_pma_rxclkslip,
		output wire		out_pma_rxpma_rstb,
		output wire		out_pma_tx_clk_out,
		output wire	[79:0]	out_pma_tx_data,
		output wire		out_pma_tx_elec_idle,
		output wire		out_pma_tx_pma_syncp_fbkp,
		output wire		out_pma_txdetectrx,
		output wire		out_reset_pc_ptrs_out_chnl_down,
		output wire		out_reset_pc_ptrs_out_chnl_up,
		output wire		out_reset_ppm_cntrs_out_chnl_down,
		output wire		out_reset_ppm_cntrs_out_chnl_up,
		output wire	[1:0]	out_rx_div_sync_out_chnl_down,
		output wire	[1:0]	out_rx_div_sync_out_chnl_up,
		output wire		out_rx_rd_enable_out_chnl_down,
		output wire		out_rx_rd_enable_out_chnl_up,
		output wire	[1:0]	out_rx_we_out_chnl_down,
		output wire	[1:0]	out_rx_we_out_chnl_up,
		output wire		out_rx_wr_enable_out_chnl_down,
		output wire		out_rx_wr_enable_out_chnl_up,
		output wire		out_speed_change_out_chnl_down,
		output wire		out_speed_change_out_chnl_up,
		output wire	[1:0]	out_tx_div_sync_out_chnl_down,
		output wire	[1:0]	out_tx_div_sync_out_chnl_up,
		output wire		out_tx_rd_enable_out_chnl_down,
		output wire		out_tx_rd_enable_out_chnl_up,
		output wire		out_tx_wr_enable_out_chnl_down,
		output wire		out_tx_wr_enable_out_chnl_up
	);
	//wire declarations
	
	// wires for module sv_hssi_pipe_gen1_2
	wire	[15:0]	w_pipe12_avmmreaddata;
	wire		w_pipe12_blockselect;
	wire	[17:0]	w_pipe12_currentcoeff;
	wire		w_pipe12_phystatus;
	wire		w_pipe12_polinvrxint;
	wire		w_pipe12_revloopbk;
	wire		w_pipe12_rxelecidle;
	wire		w_pipe12_rxelectricalidleout;
	wire	[2:0]	w_pipe12_rxstatus;
	wire		w_pipe12_rxvalid;
	wire		w_pipe12_speedchangeout;
	wire		w_pipe12_txdetectrx;
	wire		w_pipe12_txelecidleout;
	
	// wires for module sv_hssi_common_pcs_pma_interface
	wire	[1:0]	w_com_pcs_pma_if_aggaligndetsync;
	wire		w_com_pcs_pma_if_aggalignstatussync;
	wire	[1:0]	w_com_pcs_pma_if_aggcgcomprddout;
	wire	[1:0]	w_com_pcs_pma_if_aggcgcompwrout;
	wire		w_com_pcs_pma_if_aggdecctl;
	wire	[7:0]	w_com_pcs_pma_if_aggdecdata;
	wire		w_com_pcs_pma_if_aggdecdatavalid;
	wire		w_com_pcs_pma_if_aggdelcondmetout;
	wire		w_com_pcs_pma_if_aggfifoovrout;
	wire		w_com_pcs_pma_if_aggfifordoutcomp;
	wire		w_com_pcs_pma_if_agginsertincompleteout;
	wire		w_com_pcs_pma_if_agglatencycompout;
	wire	[1:0]	w_com_pcs_pma_if_aggrdalign;
	wire		w_com_pcs_pma_if_aggrdenablesync;
	wire		w_com_pcs_pma_if_aggrefclkdig;
	wire	[1:0]	w_com_pcs_pma_if_aggrunningdisp;
	wire		w_com_pcs_pma_if_aggrxpcsrst;
	wire		w_com_pcs_pma_if_aggscanmoden;
	wire		w_com_pcs_pma_if_aggscanshiftn;
	wire		w_com_pcs_pma_if_aggsyncstatus;
	wire		w_com_pcs_pma_if_aggtestsotopldout;
	wire		w_com_pcs_pma_if_aggtxctltc;
	wire	[7:0]	w_com_pcs_pma_if_aggtxdatatc;
	wire		w_com_pcs_pma_if_aggtxpcsrst;
	wire	[15:0]	w_com_pcs_pma_if_avmmreaddata;
	wire		w_com_pcs_pma_if_blockselect;
	wire		w_com_pcs_pma_if_freqlock;
	wire		w_com_pcs_pma_if_pcs8ggen2ngen1;
	wire		w_com_pcs_pma_if_pcs8gpmarxfound;
	wire		w_com_pcs_pma_if_pcs8gpowerstatetransitiondone;
	wire		w_com_pcs_pma_if_pcs8grxdetectvalid;
	wire		w_com_pcs_pma_if_pcsaggalignstatus;
	wire		w_com_pcs_pma_if_pcsaggalignstatussync0;
	wire		w_com_pcs_pma_if_pcsaggalignstatussync0toporbot;
	wire		w_com_pcs_pma_if_pcsaggalignstatustoporbot;
	wire		w_com_pcs_pma_if_pcsaggcgcomprddall;
	wire		w_com_pcs_pma_if_pcsaggcgcomprddalltoporbot;
	wire		w_com_pcs_pma_if_pcsaggcgcompwrall;
	wire		w_com_pcs_pma_if_pcsaggcgcompwralltoporbot;
	wire		w_com_pcs_pma_if_pcsaggdelcondmet0;
	wire		w_com_pcs_pma_if_pcsaggdelcondmet0toporbot;
	wire		w_com_pcs_pma_if_pcsaggendskwqd;
	wire		w_com_pcs_pma_if_pcsaggendskwqdtoporbot;
	wire		w_com_pcs_pma_if_pcsaggendskwrdptrs;
	wire		w_com_pcs_pma_if_pcsaggendskwrdptrstoporbot;
	wire		w_com_pcs_pma_if_pcsaggfifoovr0;
	wire		w_com_pcs_pma_if_pcsaggfifoovr0toporbot;
	wire		w_com_pcs_pma_if_pcsaggfifordincomp0;
	wire		w_com_pcs_pma_if_pcsaggfifordincomp0toporbot;
	wire		w_com_pcs_pma_if_pcsaggfiforstrdqd;
	wire		w_com_pcs_pma_if_pcsaggfiforstrdqdtoporbot;
	wire		w_com_pcs_pma_if_pcsagginsertincomplete0;
	wire		w_com_pcs_pma_if_pcsagginsertincomplete0toporbot;
	wire		w_com_pcs_pma_if_pcsagglatencycomp0;
	wire		w_com_pcs_pma_if_pcsagglatencycomp0toporbot;
	wire		w_com_pcs_pma_if_pcsaggrcvdclkagg;
	wire		w_com_pcs_pma_if_pcsaggrcvdclkaggtoporbot;
	wire		w_com_pcs_pma_if_pcsaggrxcontrolrs;
	wire		w_com_pcs_pma_if_pcsaggrxcontrolrstoporbot;
	wire	[7:0]	w_com_pcs_pma_if_pcsaggrxdatars;
	wire	[7:0]	w_com_pcs_pma_if_pcsaggrxdatarstoporbot;
	wire	[15:0]	w_com_pcs_pma_if_pcsaggtestbus;
	wire		w_com_pcs_pma_if_pcsaggtxctlts;
	wire		w_com_pcs_pma_if_pcsaggtxctltstoporbot;
	wire	[7:0]	w_com_pcs_pma_if_pcsaggtxdatats;
	wire	[7:0]	w_com_pcs_pma_if_pcsaggtxdatatstoporbot;
	wire		w_com_pcs_pma_if_pcsgen3pllfixedclk;
	wire	[1:0]	w_com_pcs_pma_if_pcsgen3pmapcieswdone;
	wire		w_com_pcs_pma_if_pcsgen3pmarxdetectvalid;
	wire		w_com_pcs_pma_if_pcsgen3pmarxfound;
	wire		w_com_pcs_pma_if_pldhclkout;
	wire		w_com_pcs_pma_if_pldtestsitoaggout;
	wire		w_com_pcs_pma_if_pmaclklowout;
	wire	[17:0]	w_com_pcs_pma_if_pmacurrentcoeff;
	wire	[2:0]	w_com_pcs_pma_if_pmacurrentrxpreset;
	wire		w_com_pcs_pma_if_pmaearlyeios;
	wire		w_com_pcs_pma_if_pmafrefout;
	wire	[9:0]	w_com_pcs_pma_if_pmaiftestbus;
	wire		w_com_pcs_pma_if_pmalccmurstb;
	wire		w_com_pcs_pma_if_pmaltr;
	wire		w_com_pcs_pma_if_pmanfrzdrv;
	wire		w_com_pcs_pma_if_pmapartialreconfig;
	wire	[1:0]	w_com_pcs_pma_if_pmapcieswitch;
	wire		w_com_pcs_pma_if_pmatxdetectrx;
	wire		w_com_pcs_pma_if_pmatxelecidle;
	
	// wires for module sv_hssi_10g_rx_pcs
	wire	[15:0]	w_pcs10g_rx_avmmreaddata;
	wire		w_pcs10g_rx_blockselect;
	wire		w_pcs10g_rx_rxalignval;
	wire		w_pcs10g_rx_rxblocklock;
	wire		w_pcs10g_rx_rxclkiqout;
	wire		w_pcs10g_rx_rxclkout;
	wire	[9:0]	w_pcs10g_rx_rxcontrol;
	wire		w_pcs10g_rx_rxcrc32error;
	wire	[63:0]	w_pcs10g_rx_rxdata;
	wire		w_pcs10g_rx_rxdatavalid;
	wire		w_pcs10g_rx_rxdiagnosticerror;
	wire	[1:0]	w_pcs10g_rx_rxdiagnosticstatus;
	wire		w_pcs10g_rx_rxfifodel;
	wire		w_pcs10g_rx_rxfifoempty;
	wire		w_pcs10g_rx_rxfifofull;
	wire		w_pcs10g_rx_rxfifoinsert;
	wire		w_pcs10g_rx_rxfifopartialempty;
	wire		w_pcs10g_rx_rxfifopartialfull;
	wire		w_pcs10g_rx_rxframelock;
	wire		w_pcs10g_rx_rxhighber;
	wire		w_pcs10g_rx_rxmetaframeerror;
	wire		w_pcs10g_rx_rxpayloadinserted;
	wire		w_pcs10g_rx_rxprbsdone;
	wire		w_pcs10g_rx_rxprbserr;
	wire		w_pcs10g_rx_rxrdnegsts;
	wire		w_pcs10g_rx_rxrdpossts;
	wire		w_pcs10g_rx_rxrxframe;
	wire		w_pcs10g_rx_rxscramblererror;
	wire		w_pcs10g_rx_rxskipinserted;
	wire		w_pcs10g_rx_rxskipworderror;
	wire		w_pcs10g_rx_rxsyncheadererror;
	wire		w_pcs10g_rx_rxsyncworderror;
	
	// wires for module sv_hssi_pipe_gen3
	wire	[15:0]	w_pipe3_avmmreaddata;
	wire		w_pipe3_blockselect;
	wire	[10:0]	w_pipe3_bundlingoutdown;
	wire	[10:0]	w_pipe3_bundlingoutup;
	wire		w_pipe3_dispcbyte;
	wire		w_pipe3_gen3clksel;
	wire		w_pipe3_gen3datasel;
	wire		w_pipe3_inferredrxvalidint;
	wire		w_pipe3_masktxpll;
	wire		w_pipe3_pcsrst;
	wire		w_pipe3_phystatus;
	wire	[17:0]	w_pipe3_pmacurrentcoeff;
	wire	[2:0]	w_pipe3_pmacurrentrxpreset;
	wire		w_pipe3_pmaearlyeios;
	wire		w_pipe3_pmaltr;
	wire	[1:0]	w_pipe3_pmapcieswitch;
	wire		w_pipe3_pmatxdetectrx;
	wire		w_pipe3_pmatxelecidle;
	wire		w_pipe3_ppmcntrst8gpcsout;
	wire		w_pipe3_ppmeidleexit;
	wire		w_pipe3_resetpcprts;
	wire		w_pipe3_revlpbk8gpcsout;
	wire		w_pipe3_revlpbkint;
	wire	[3:0]	w_pipe3_rxblkstart;
	wire	[63:0]	w_pipe3_rxd8gpcsout;
	wire	[3:0]	w_pipe3_rxdataskip;
	wire		w_pipe3_rxelecidle;
	wire		w_pipe3_rxpolarity8gpcsout;
	wire		w_pipe3_rxpolarityint;
	wire	[2:0]	w_pipe3_rxstatus;
	wire	[1:0]	w_pipe3_rxsynchdr;
	wire		w_pipe3_rxvalid;
	wire		w_pipe3_shutdownclk;
	wire	[19:0]	w_pipe3_testout;
	wire		w_pipe3_txblkstartint;
	wire	[31:0]	w_pipe3_txdataint;
	wire	[3:0]	w_pipe3_txdatakint;
	wire		w_pipe3_txdataskipint;
	wire		w_pipe3_txpmasyncp;
	wire	[1:0]	w_pipe3_txsynchdrint;
	
	// wires for module sv_hssi_tx_pcs_pma_interface
	wire	[15:0]	w_tx_pcs_pma_if_avmmreaddata;
	wire		w_tx_pcs_pma_if_blockselect;
	wire		w_tx_pcs_pma_if_clockoutto10gpcs;
	wire		w_tx_pcs_pma_if_clockoutto8gpcs;
	wire	[79:0]	w_tx_pcs_pma_if_dataouttopma;
	wire		w_tx_pcs_pma_if_pcs10gclkdiv33lc;
	wire		w_tx_pcs_pma_if_pmaclkdiv33lcout;
	wire		w_tx_pcs_pma_if_pmarxfreqtxcmuplllockout;
	wire		w_tx_pcs_pma_if_pmatxclkout;
	wire		w_tx_pcs_pma_if_pmatxlcplllockout;
	wire		w_tx_pcs_pma_if_pmatxpmasyncpfbkp;
	
	// wires for module sv_hssi_tx_pld_pcs_interface
	wire	[15:0]	w_tx_pld_pcs_if_avmmreaddata;
	wire		w_tx_pld_pcs_if_blockselect;
	wire	[63:0]	w_tx_pld_pcs_if_dataoutto10gpcs;
	wire	[43:0]	w_tx_pld_pcs_if_dataoutto8gpcs;
	wire	[2:0]	w_tx_pld_pcs_if_emsippcstxclkout;
	wire	[11:0]	w_tx_pld_pcs_if_emsiptxout;
	wire	[15:0]	w_tx_pld_pcs_if_emsiptxspecialout;
	wire	[6:0]	w_tx_pld_pcs_if_pcs10gtxbitslip;
	wire		w_tx_pld_pcs_if_pcs10gtxbursten;
	wire	[8:0]	w_tx_pld_pcs_if_pcs10gtxcontrol;
	wire		w_tx_pld_pcs_if_pcs10gtxdatavalid;
	wire	[1:0]	w_tx_pld_pcs_if_pcs10gtxdiagstatus;
	wire		w_tx_pld_pcs_if_pcs10gtxpldclk;
	wire		w_tx_pld_pcs_if_pcs10gtxpldrstn;
	wire		w_tx_pld_pcs_if_pcs10gtxwordslip;
	wire		w_tx_pld_pcs_if_pcs8gphfifoursttx;
	wire		w_tx_pld_pcs_if_pcs8gpldtxclk;
	wire		w_tx_pld_pcs_if_pcs8gpolinvtx;
	wire		w_tx_pld_pcs_if_pcs8grddisabletx;
	wire		w_tx_pld_pcs_if_pcs8grevloopbk;
	wire	[3:0]	w_tx_pld_pcs_if_pcs8gtxblkstart;
	wire	[4:0]	w_tx_pld_pcs_if_pcs8gtxboundarysel;
	wire	[3:0]	w_tx_pld_pcs_if_pcs8gtxdatavalid;
	wire	[1:0]	w_tx_pld_pcs_if_pcs8gtxsynchdr;
	wire		w_tx_pld_pcs_if_pcs8gtxurstpcs;
	wire		w_tx_pld_pcs_if_pcs8gwrenabletx;
	wire		w_tx_pld_pcs_if_pcsgen3txrst;
	wire		w_tx_pld_pcs_if_pld10gtxburstenexe;
	wire		w_tx_pld_pcs_if_pld10gtxclkout;
	wire		w_tx_pld_pcs_if_pld10gtxempty;
	wire		w_tx_pld_pcs_if_pld10gtxfifodel;
	wire		w_tx_pld_pcs_if_pld10gtxfifoinsert;
	wire		w_tx_pld_pcs_if_pld10gtxframe;
	wire		w_tx_pld_pcs_if_pld10gtxfull;
	wire		w_tx_pld_pcs_if_pld10gtxpempty;
	wire		w_tx_pld_pcs_if_pld10gtxpfull;
	wire		w_tx_pld_pcs_if_pld10gtxwordslipexe;
	wire		w_tx_pld_pcs_if_pld8gemptytx;
	wire		w_tx_pld_pcs_if_pld8gfulltx;
	wire		w_tx_pld_pcs_if_pld8gtxclkout;
	wire		w_tx_pld_pcs_if_pldclkdiv33lc;
	wire		w_tx_pld_pcs_if_pldlccmurstbout;
	wire		w_tx_pld_pcs_if_pldtxiqclkout;
	wire		w_tx_pld_pcs_if_pldtxpmasyncpfbkpout;
	
	// wires for module sv_hssi_10g_tx_pcs
	wire	[15:0]	w_pcs10g_tx_avmmreaddata;
	wire		w_pcs10g_tx_blockselect;
	wire	[8:0]	w_pcs10g_tx_dfxlpbkcontrolout;
	wire	[63:0]	w_pcs10g_tx_dfxlpbkdataout;
	wire		w_pcs10g_tx_dfxlpbkdatavalidout;
	wire		w_pcs10g_tx_distdwnoutdv;
	wire		w_pcs10g_tx_distdwnoutintlknrden;
	wire		w_pcs10g_tx_distdwnoutrden;
	wire		w_pcs10g_tx_distdwnoutrdpfull;
	wire		w_pcs10g_tx_distdwnoutwren;
	wire		w_pcs10g_tx_distupoutdv;
	wire		w_pcs10g_tx_distupoutintlknrden;
	wire		w_pcs10g_tx_distupoutrden;
	wire		w_pcs10g_tx_distupoutrdpfull;
	wire		w_pcs10g_tx_distupoutwren;
	wire	[79:0]	w_pcs10g_tx_lpbkdataout;
	wire		w_pcs10g_tx_txburstenexe;
	wire		w_pcs10g_tx_txclkiqout;
	wire		w_pcs10g_tx_txclkout;
	wire		w_pcs10g_tx_txfifodel;
	wire		w_pcs10g_tx_txfifoempty;
	wire		w_pcs10g_tx_txfifofull;
	wire		w_pcs10g_tx_txfifoinsert;
	wire		w_pcs10g_tx_txfifopartialempty;
	wire		w_pcs10g_tx_txfifopartialfull;
	wire		w_pcs10g_tx_txframe;
	wire	[79:0]	w_pcs10g_tx_txpmadata;
	wire		w_pcs10g_tx_txwordslipexe;
	
	// wires for module sv_hssi_8g_rx_pcs
	wire	[3:0]	w_pcs8g_rx_a1a2k1k2flag;
	wire		w_pcs8g_rx_aggrxpcsrst;
	wire	[1:0]	w_pcs8g_rx_aligndetsync;
	wire		w_pcs8g_rx_alignstatuspld;
	wire		w_pcs8g_rx_alignstatussync;
	wire	[15:0]	w_pcs8g_rx_avmmreaddata;
	wire		w_pcs8g_rx_bistdone;
	wire		w_pcs8g_rx_bisterr;
	wire		w_pcs8g_rx_blockselect;
	wire		w_pcs8g_rx_byteordflag;
	wire	[1:0]	w_pcs8g_rx_cgcomprddout;
	wire	[1:0]	w_pcs8g_rx_cgcompwrout;
	wire	[19:0]	w_pcs8g_rx_channeltestbusout;
	wire		w_pcs8g_rx_clocktopld;
	wire		w_pcs8g_rx_configseloutchnldown;
	wire		w_pcs8g_rx_configseloutchnlup;
	wire	[63:0]	w_pcs8g_rx_dataout;
	wire		w_pcs8g_rx_decoderctrl;
	wire	[7:0]	w_pcs8g_rx_decoderdata;
	wire		w_pcs8g_rx_decoderdatavalid;
	wire		w_pcs8g_rx_delcondmetout;
	wire		w_pcs8g_rx_disablepcfifobyteserdes;
	wire		w_pcs8g_rx_earlyeios;
	wire		w_pcs8g_rx_eidledetected;
	wire		w_pcs8g_rx_eidleexit;
	wire		w_pcs8g_rx_fifoovrout;
	wire		w_pcs8g_rx_fifordoutcomp;
	wire		w_pcs8g_rx_insertincompleteout;
	wire		w_pcs8g_rx_latencycompout;
	wire		w_pcs8g_rx_ltr;
	wire	[19:0]	w_pcs8g_rx_parallelrevloopback;
	wire		w_pcs8g_rx_pcfifoempty;
	wire		w_pcs8g_rx_pcfifofull;
	wire		w_pcs8g_rx_pcieswitch;
	wire		w_pcs8g_rx_phystatus;
	wire	[63:0]	w_pcs8g_rx_pipedata;
	wire	[1:0]	w_pcs8g_rx_rdalign;
	wire		w_pcs8g_rx_rdenableoutchnldown;
	wire		w_pcs8g_rx_rdenableoutchnlup;
	wire		w_pcs8g_rx_resetpcptrs;
	wire		w_pcs8g_rx_resetpcptrsinchnldownpipe;
	wire		w_pcs8g_rx_resetpcptrsinchnluppipe;
	wire		w_pcs8g_rx_resetpcptrsoutchnldown;
	wire		w_pcs8g_rx_resetpcptrsoutchnlup;
	wire		w_pcs8g_rx_resetppmcntrsoutchnldown;
	wire		w_pcs8g_rx_resetppmcntrsoutchnlup;
	wire		w_pcs8g_rx_resetppmcntrspcspma;
	wire		w_pcs8g_rx_rlvlt;
	wire		w_pcs8g_rx_rmfifoempty;
	wire		w_pcs8g_rx_rmfifofull;
	wire	[1:0]	w_pcs8g_rx_runningdisparity;
	wire	[3:0]	w_pcs8g_rx_rxblkstart;
	wire		w_pcs8g_rx_rxclkoutgen3;
	wire		w_pcs8g_rx_rxclkslip;
	wire	[3:0]	w_pcs8g_rx_rxdatavalid;
	wire	[1:0]	w_pcs8g_rx_rxdivsyncoutchnldown;
	wire	[1:0]	w_pcs8g_rx_rxdivsyncoutchnlup;
	wire		w_pcs8g_rx_rxpipeclk;
	wire		w_pcs8g_rx_rxpipesoftreset;
	wire	[2:0]	w_pcs8g_rx_rxstatus;
	wire	[1:0]	w_pcs8g_rx_rxsynchdr;
	wire		w_pcs8g_rx_rxvalid;
	wire	[1:0]	w_pcs8g_rx_rxweoutchnldown;
	wire	[1:0]	w_pcs8g_rx_rxweoutchnlup;
	wire		w_pcs8g_rx_signaldetectout;
	wire		w_pcs8g_rx_speedchange;
	wire		w_pcs8g_rx_speedchangeinchnldownpipe;
	wire		w_pcs8g_rx_speedchangeinchnluppipe;
	wire		w_pcs8g_rx_speedchangeoutchnldown;
	wire		w_pcs8g_rx_speedchangeoutchnlup;
	wire		w_pcs8g_rx_syncstatus;
	wire	[4:0]	w_pcs8g_rx_wordalignboundary;
	wire		w_pcs8g_rx_wrenableoutchnldown;
	wire		w_pcs8g_rx_wrenableoutchnlup;
	
	// wires for module sv_hssi_8g_tx_pcs
	wire		w_pcs8g_tx_aggtxpcsrst;
	wire	[15:0]	w_pcs8g_tx_avmmreaddata;
	wire		w_pcs8g_tx_blockselect;
	wire		w_pcs8g_tx_clkout;
	wire		w_pcs8g_tx_clkoutgen3;
	wire	[19:0]	w_pcs8g_tx_dataout;
	wire		w_pcs8g_tx_detectrxloopout;
	wire		w_pcs8g_tx_dynclkswitchn;
	wire	[1:0]	w_pcs8g_tx_fifoselectoutchnldown;
	wire	[1:0]	w_pcs8g_tx_fifoselectoutchnlup;
	wire	[2:0]	w_pcs8g_tx_grayelecidleinferselout;
	wire	[19:0]	w_pcs8g_tx_parallelfdbkout;
	wire		w_pcs8g_tx_phfifooverflow;
	wire		w_pcs8g_tx_phfifotxdeemph;
	wire	[2:0]	w_pcs8g_tx_phfifotxmargin;
	wire		w_pcs8g_tx_phfifotxswing;
	wire		w_pcs8g_tx_phfifounderflow;
	wire		w_pcs8g_tx_pipeenrevparallellpbkout;
	wire	[1:0]	w_pcs8g_tx_pipepowerdownout;
	wire		w_pcs8g_tx_polinvrxout;
	wire		w_pcs8g_tx_rdenableoutchnldown;
	wire		w_pcs8g_tx_rdenableoutchnlup;
	wire		w_pcs8g_tx_rdenablesync;
	wire		w_pcs8g_tx_refclkb;
	wire		w_pcs8g_tx_refclkbreset;
	wire		w_pcs8g_tx_rxpolarityout;
	wire	[3:0]	w_pcs8g_tx_txblkstartout;
	wire		w_pcs8g_tx_txcomplianceout;
	wire	[19:0]	w_pcs8g_tx_txctrlplanetestbus;
	wire	[3:0]	w_pcs8g_tx_txdatakouttogen3;
	wire	[31:0]	w_pcs8g_tx_txdataouttogen3;
	wire	[3:0]	w_pcs8g_tx_txdatavalidouttogen3;
	wire	[1:0]	w_pcs8g_tx_txdivsync;
	wire	[1:0]	w_pcs8g_tx_txdivsyncoutchnldown;
	wire	[1:0]	w_pcs8g_tx_txdivsyncoutchnlup;
	wire		w_pcs8g_tx_txelecidleout;
	wire		w_pcs8g_tx_txpipeclk;
	wire		w_pcs8g_tx_txpipeelectidle;
	wire		w_pcs8g_tx_txpipesoftreset;
	wire	[1:0]	w_pcs8g_tx_txsynchdrout;
	wire	[19:0]	w_pcs8g_tx_txtestbus;
	wire		w_pcs8g_tx_wrenableoutchnldown;
	wire		w_pcs8g_tx_wrenableoutchnlup;
	wire		w_pcs8g_tx_xgmctrlenable;
	wire	[7:0]	w_pcs8g_tx_xgmdataout;
	
	// wires for module sv_hssi_common_pld_pcs_interface
	wire	[15:0]	w_com_pld_pcs_if_avmmreaddata;
	wire		w_com_pld_pcs_if_blockselect;
	wire	[2:0]	w_com_pld_pcs_if_emsipcomclkout;
	wire	[26:0]	w_com_pld_pcs_if_emsipcomout;
	wire	[19:0]	w_com_pld_pcs_if_emsipcomspecialout;
	wire		w_com_pld_pcs_if_emsipenablediocsrrdydly;
	wire		w_com_pld_pcs_if_pcs10ghardreset;
	wire		w_com_pld_pcs_if_pcs10grefclkdig;
	wire	[2:0]	w_com_pld_pcs_if_pcs8geidleinfersel;
	wire		w_com_pld_pcs_if_pcs8ghardreset;
	wire		w_com_pld_pcs_if_pcs8gltr;
	wire	[1:0]	w_com_pld_pcs_if_pcs8gpowerdown;
	wire		w_com_pld_pcs_if_pcs8gprbsciden;
	wire		w_com_pld_pcs_if_pcs8grate;
	wire		w_com_pld_pcs_if_pcs8grefclkdig;
	wire		w_com_pld_pcs_if_pcs8grefclkdig2;
	wire		w_com_pld_pcs_if_pcs8grxpolarity;
	wire		w_com_pld_pcs_if_pcs8gscanmoden;
	wire		w_com_pld_pcs_if_pcs8gtxdeemph;
	wire		w_com_pld_pcs_if_pcs8gtxdetectrxloopback;
	wire		w_com_pld_pcs_if_pcs8gtxelecidle;
	wire	[2:0]	w_com_pld_pcs_if_pcs8gtxmargin;
	wire		w_com_pld_pcs_if_pcs8gtxswing;
	wire		w_com_pld_pcs_if_pcsaggrefclkdig;
	wire		w_com_pld_pcs_if_pcsaggtestsi;
	wire	[17:0]	w_com_pld_pcs_if_pcsgen3currentcoeff;
	wire	[2:0]	w_com_pld_pcs_if_pcsgen3currentrxpreset;
	wire	[2:0]	w_com_pld_pcs_if_pcsgen3eidleinfersel;
	wire		w_com_pld_pcs_if_pcsgen3hardreset;
	wire		w_com_pld_pcs_if_pcsgen3pldltr;
	wire	[1:0]	w_com_pld_pcs_if_pcsgen3rate;
	wire		w_com_pld_pcs_if_pcsgen3scanmoden;
	wire		w_com_pld_pcs_if_pcspcspmaifrefclkdig;
	wire		w_com_pld_pcs_if_pcspcspmaifscanmoden;
	wire		w_com_pld_pcs_if_pcspcspmaifscanshiftn;
	wire		w_com_pld_pcs_if_pcspmaifhardreset;
	wire		w_com_pld_pcs_if_pld8gphystatus;
	wire		w_com_pld_pcs_if_pld8grxelecidle;
	wire	[2:0]	w_com_pld_pcs_if_pld8grxstatus;
	wire		w_com_pld_pcs_if_pld8grxvalid;
	wire		w_com_pld_pcs_if_pldclklow;
	wire		w_com_pld_pcs_if_pldfref;
	wire		w_com_pld_pcs_if_pldgen3masktxpll;
	wire	[17:0]	w_com_pld_pcs_if_pldgen3rxdeemph;
	wire	[1:0]	w_com_pld_pcs_if_pldgen3rxeqctrl;
	wire		w_com_pld_pcs_if_pldnfrzdrv;
	wire		w_com_pld_pcs_if_pldpartialreconfigout;
	wire	[10:0]	w_com_pld_pcs_if_pldreservedout;
	wire	[19:0]	w_com_pld_pcs_if_pldtestdata;
	wire		w_com_pld_pcs_if_rstsel;
	wire		w_com_pld_pcs_if_usrrstsel;
	
	// wires for module sv_hssi_gen3_tx_pcs
	wire	[15:0]	w_pcs_g3_tx_avmmreaddata;
	wire		w_pcs_g3_tx_blockselect;
	wire	[31:0]	w_pcs_g3_tx_dataout;
	wire		w_pcs_g3_tx_errencode;
	wire	[35:0]	w_pcs_g3_tx_parlpbkb4gbout;
	wire	[31:0]	w_pcs_g3_tx_parlpbkout;
	wire	[19:0]	w_pcs_g3_tx_txtestout;
	
	// wires for module sv_hssi_rx_pld_pcs_interface
	wire	[15:0]	w_rx_pld_pcs_if_avmmreaddata;
	wire		w_rx_pld_pcs_if_blockselect;
	wire	[63:0]	w_rx_pld_pcs_if_dataouttopld;
	wire	[2:0]	w_rx_pld_pcs_if_emsiprxclkout;
	wire	[128:0]	w_rx_pld_pcs_if_emsiprxout;
	wire	[15:0]	w_rx_pld_pcs_if_emsiprxspecialout;
	wire		w_rx_pld_pcs_if_pcs10grxalignclr;
	wire		w_rx_pld_pcs_if_pcs10grxalignen;
	wire		w_rx_pld_pcs_if_pcs10grxbitslip;
	wire		w_rx_pld_pcs_if_pcs10grxclrbercount;
	wire		w_rx_pld_pcs_if_pcs10grxclrerrblkcnt;
	wire		w_rx_pld_pcs_if_pcs10grxdispclr;
	wire		w_rx_pld_pcs_if_pcs10grxpldclk;
	wire		w_rx_pld_pcs_if_pcs10grxpldrstn;
	wire		w_rx_pld_pcs_if_pcs10grxprbserrclr;
	wire		w_rx_pld_pcs_if_pcs10grxrden;
	wire		w_rx_pld_pcs_if_pcs8ga1a2size;
	wire		w_rx_pld_pcs_if_pcs8gbitlocreven;
	wire		w_rx_pld_pcs_if_pcs8gbitslip;
	wire		w_rx_pld_pcs_if_pcs8gbytereven;
	wire		w_rx_pld_pcs_if_pcs8gbytordpld;
	wire		w_rx_pld_pcs_if_pcs8gcmpfifourst;
	wire		w_rx_pld_pcs_if_pcs8gencdt;
	wire		w_rx_pld_pcs_if_pcs8gphfifourstrx;
	wire		w_rx_pld_pcs_if_pcs8gpldrxclk;
	wire		w_rx_pld_pcs_if_pcs8gpolinvrx;
	wire		w_rx_pld_pcs_if_pcs8grdenablerx;
	wire		w_rx_pld_pcs_if_pcs8grxurstpcs;
	wire		w_rx_pld_pcs_if_pcs8gsyncsmenoutput;
	wire		w_rx_pld_pcs_if_pcs8gwrdisablerx;
	wire		w_rx_pld_pcs_if_pcsgen3rxrst;
	wire		w_rx_pld_pcs_if_pcsgen3syncsmen;
	wire		w_rx_pld_pcs_if_pld10grxalignval;
	wire		w_rx_pld_pcs_if_pld10grxblklock;
	wire		w_rx_pld_pcs_if_pld10grxclkout;
	wire	[9:0]	w_rx_pld_pcs_if_pld10grxcontrol;
	wire		w_rx_pld_pcs_if_pld10grxcrc32err;
	wire		w_rx_pld_pcs_if_pld10grxdatavalid;
	wire		w_rx_pld_pcs_if_pld10grxdiagerr;
	wire	[1:0]	w_rx_pld_pcs_if_pld10grxdiagstatus;
	wire		w_rx_pld_pcs_if_pld10grxempty;
	wire		w_rx_pld_pcs_if_pld10grxfifodel;
	wire		w_rx_pld_pcs_if_pld10grxfifoinsert;
	wire		w_rx_pld_pcs_if_pld10grxframelock;
	wire		w_rx_pld_pcs_if_pld10grxhiber;
	wire		w_rx_pld_pcs_if_pld10grxmfrmerr;
	wire		w_rx_pld_pcs_if_pld10grxoflwerr;
	wire		w_rx_pld_pcs_if_pld10grxpempty;
	wire		w_rx_pld_pcs_if_pld10grxpfull;
	wire		w_rx_pld_pcs_if_pld10grxprbserr;
	wire		w_rx_pld_pcs_if_pld10grxpyldins;
	wire		w_rx_pld_pcs_if_pld10grxrdnegsts;
	wire		w_rx_pld_pcs_if_pld10grxrdpossts;
	wire		w_rx_pld_pcs_if_pld10grxrxframe;
	wire		w_rx_pld_pcs_if_pld10grxscrmerr;
	wire		w_rx_pld_pcs_if_pld10grxsherr;
	wire		w_rx_pld_pcs_if_pld10grxskiperr;
	wire		w_rx_pld_pcs_if_pld10grxskipins;
	wire		w_rx_pld_pcs_if_pld10grxsyncerr;
	wire	[3:0]	w_rx_pld_pcs_if_pld8ga1a2k1k2flag;
	wire		w_rx_pld_pcs_if_pld8galignstatus;
	wire		w_rx_pld_pcs_if_pld8gbistdone;
	wire		w_rx_pld_pcs_if_pld8gbisterr;
	wire		w_rx_pld_pcs_if_pld8gbyteordflag;
	wire		w_rx_pld_pcs_if_pld8gemptyrmf;
	wire		w_rx_pld_pcs_if_pld8gemptyrx;
	wire		w_rx_pld_pcs_if_pld8gfullrmf;
	wire		w_rx_pld_pcs_if_pld8gfullrx;
	wire		w_rx_pld_pcs_if_pld8grlvlt;
	wire	[3:0]	w_rx_pld_pcs_if_pld8grxblkstart;
	wire		w_rx_pld_pcs_if_pld8grxclkout;
	wire	[3:0]	w_rx_pld_pcs_if_pld8grxdatavalid;
	wire	[1:0]	w_rx_pld_pcs_if_pld8grxsynchdr;
	wire		w_rx_pld_pcs_if_pld8gsignaldetectout;
	wire	[4:0]	w_rx_pld_pcs_if_pld8gwaboundary;
	wire		w_rx_pld_pcs_if_pldclkdiv33txorrx;
	wire		w_rx_pld_pcs_if_pldrxclkslipout;
	wire		w_rx_pld_pcs_if_pldrxiqclkout;
	wire		w_rx_pld_pcs_if_pldrxpmarstbout;
	
	// wires for module sv_hssi_rx_pcs_pma_interface
	wire	[15:0]	w_rx_pcs_pma_if_avmmreaddata;
	wire		w_rx_pcs_pma_if_blockselect;
	wire		w_rx_pcs_pma_if_clkoutto10gpcs;
	wire		w_rx_pcs_pma_if_clockoutto8gpcs;
	wire		w_rx_pcs_pma_if_clockouttogen3pcs;
	wire	[79:0]	w_rx_pcs_pma_if_dataoutto10gpcs;
	wire	[19:0]	w_rx_pcs_pma_if_dataoutto8gpcs;
	wire	[31:0]	w_rx_pcs_pma_if_dataouttogen3pcs;
	wire		w_rx_pcs_pma_if_pcs10gclkdiv33txorrx;
	wire		w_rx_pcs_pma_if_pcs10gsignalok;
	wire		w_rx_pcs_pma_if_pcs8gsigdetni;
	wire		w_rx_pcs_pma_if_pcsgen3pmasignaldet;
	wire		w_rx_pcs_pma_if_pmaclkdiv33txorrxout;
	wire	[7:0]	w_rx_pcs_pma_if_pmaeyemonitorout;
	wire	[4:0]	w_rx_pcs_pma_if_pmareservedout;
	wire		w_rx_pcs_pma_if_pmarxclkout;
	wire		w_rx_pcs_pma_if_pmarxclkslip;
	wire		w_rx_pcs_pma_if_pmarxpllphaselockout;
	wire		w_rx_pcs_pma_if_pmarxpmarstb;
	
	// wires for module sv_hssi_gen3_rx_pcs
	wire	[15:0]	w_pcs_g3_rx_avmmreaddata;
	wire		w_pcs_g3_rx_blkalgndint;
	wire		w_pcs_g3_rx_blkstart;
	wire		w_pcs_g3_rx_blockselect;
	wire		w_pcs_g3_rx_clkcompdeleteint;
	wire		w_pcs_g3_rx_clkcompinsertint;
	wire		w_pcs_g3_rx_clkcompoverflint;
	wire		w_pcs_g3_rx_clkcompundflint;
	wire	[31:0]	w_pcs_g3_rx_dataout;
	wire		w_pcs_g3_rx_datavalid;
	wire		w_pcs_g3_rx_eidetint;
	wire		w_pcs_g3_rx_eipartialdetint;
	wire		w_pcs_g3_rx_errdecodeint;
	wire		w_pcs_g3_rx_idetint;
	wire		w_pcs_g3_rx_lpbkblkstart;
	wire	[33:0]	w_pcs_g3_rx_lpbkdata;
	wire		w_pcs_g3_rx_lpbkdatavalid;
	wire		w_pcs_g3_rx_rcvlfsrchkint;
	wire	[19:0]	w_pcs_g3_rx_rxtestout;
	wire	[1:0]	w_pcs_g3_rx_synchdr;
	
	
	generate
		
		//module instantiations
		
		// instantiating sv_hssi_pipe_gen1_2
		if ((enable_dyn_reconfig == "true") || (enable_gen12_pipe == "true")) begin
			sv_hssi_pipe_gen1_2_rbc #(
				.ctrl_plane_bonding_consumption(pipe12_ctrl_plane_bonding_consumption),
				.elec_idle_delay_val(pipe12_elec_idle_delay_val),
				.elecidle_delay(pipe12_elecidle_delay),
				.error_replace_pad(pipe12_error_replace_pad),
				.hip_mode(pipe12_hip_mode),
				.ind_error_reporting(pipe12_ind_error_reporting),
				.phy_status_delay(pipe12_phy_status_delay),
				.phystatus_delay_val(pipe12_phystatus_delay_val),
				.phystatus_rst_toggle(pipe12_phystatus_rst_toggle),
				.pipe_byte_de_serializer_en(pipe12_pipe_byte_de_serializer_en),
				.prot_mode(pipe12_prot_mode),
				.rpre_emph_a_val(pipe12_rpre_emph_a_val),
				.rpre_emph_b_val(pipe12_rpre_emph_b_val),
				.rpre_emph_c_val(pipe12_rpre_emph_c_val),
				.rpre_emph_d_val(pipe12_rpre_emph_d_val),
				.rpre_emph_e_val(pipe12_rpre_emph_e_val),
				.rpre_emph_settings(pipe12_rpre_emph_settings),
				.rvod_sel_a_val(pipe12_rvod_sel_a_val),
				.rvod_sel_b_val(pipe12_rvod_sel_b_val),
				.rvod_sel_c_val(pipe12_rvod_sel_c_val),
				.rvod_sel_d_val(pipe12_rvod_sel_d_val),
				.rvod_sel_e_val(pipe12_rvod_sel_e_val),
				.rvod_sel_settings(pipe12_rvod_sel_settings),
				.rx_pipe_enable(pipe12_rx_pipe_enable),
				.rxdetect_bypass(pipe12_rxdetect_bypass),
				.sup_mode(pipe12_sup_mode),
				.tx_pipe_enable(pipe12_tx_pipe_enable),
				.txswing(pipe12_txswing),
				.use_default_base_address(pipe12_use_default_base_address),
				.user_base_address(pipe12_user_base_address)
			) inst_sv_hssi_pipe_gen1_2 (
				// OUTPUTS
				.avmmreaddata(w_pipe12_avmmreaddata),
				.blockselect(w_pipe12_blockselect),
				.currentcoeff(w_pipe12_currentcoeff),
				.phystatus(w_pipe12_phystatus),
				.polinvrxint(w_pipe12_polinvrxint),
				.revloopbk(w_pipe12_revloopbk),
				.rxelecidle(w_pipe12_rxelecidle),
				.rxelectricalidleout(w_pipe12_rxelectricalidleout),
				.rxstatus(w_pipe12_rxstatus),
				.rxvalid(w_pipe12_rxvalid),
				.speedchangeout(w_pipe12_speedchangeout),
				.txdetectrx(w_pipe12_txdetectrx),
				.txelecidleout(w_pipe12_txelecidleout),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.pcieswitch(w_pcs8g_rx_pcieswitch),
				.piperxclk(w_pcs8g_rx_rxpipeclk),
				.pipetxclk(w_pcs8g_tx_txpipeclk),
				.polinvrx(w_pcs8g_tx_polinvrxout),
				.powerdown({w_pcs8g_tx_pipepowerdownout[1], w_pcs8g_tx_pipepowerdownout[0]}),
				.powerstatetransitiondone(w_com_pcs_pma_if_pcs8gpowerstatetransitiondone),
                                .powerstatetransitiondoneena(1'b0),
				.refclkb(w_pcs8g_tx_refclkb),
				.refclkbreset(w_pcs8g_tx_refclkbreset),
				.revloopback(w_pcs8g_tx_pipeenrevparallellpbkout),
				.revloopbkpcsgen3(w_pipe3_revlpbk8gpcsout),
				.rxd({w_pcs8g_rx_pipedata[63], w_pcs8g_rx_pipedata[62], w_pcs8g_rx_pipedata[61], w_pcs8g_rx_pipedata[60], w_pcs8g_rx_pipedata[59], w_pcs8g_rx_pipedata[58], w_pcs8g_rx_pipedata[57], w_pcs8g_rx_pipedata[56], w_pcs8g_rx_pipedata[55], w_pcs8g_rx_pipedata[54], w_pcs8g_rx_pipedata[53], w_pcs8g_rx_pipedata[52], w_pcs8g_rx_pipedata[51], w_pcs8g_rx_pipedata[50], w_pcs8g_rx_pipedata[49], w_pcs8g_rx_pipedata[48], w_pcs8g_rx_pipedata[47], w_pcs8g_rx_pipedata[46], w_pcs8g_rx_pipedata[45], w_pcs8g_rx_pipedata[44], w_pcs8g_rx_pipedata[43], w_pcs8g_rx_pipedata[42], w_pcs8g_rx_pipedata[41], w_pcs8g_rx_pipedata[40], w_pcs8g_rx_pipedata[39], w_pcs8g_rx_pipedata[38], w_pcs8g_rx_pipedata[37], w_pcs8g_rx_pipedata[36], w_pcs8g_rx_pipedata[35], w_pcs8g_rx_pipedata[34], w_pcs8g_rx_pipedata[33], w_pcs8g_rx_pipedata[32], w_pcs8g_rx_pipedata[31], w_pcs8g_rx_pipedata[30], w_pcs8g_rx_pipedata[29], w_pcs8g_rx_pipedata[28], w_pcs8g_rx_pipedata[27], w_pcs8g_rx_pipedata[26], w_pcs8g_rx_pipedata[25], w_pcs8g_rx_pipedata[24], w_pcs8g_rx_pipedata[23], w_pcs8g_rx_pipedata[22], w_pcs8g_rx_pipedata[21], w_pcs8g_rx_pipedata[20], w_pcs8g_rx_pipedata[19], w_pcs8g_rx_pipedata[18], w_pcs8g_rx_pipedata[17], w_pcs8g_rx_pipedata[16], w_pcs8g_rx_pipedata[15], w_pcs8g_rx_pipedata[14], w_pcs8g_rx_pipedata[13], w_pcs8g_rx_pipedata[12], w_pcs8g_rx_pipedata[11], w_pcs8g_rx_pipedata[10], w_pcs8g_rx_pipedata[9], w_pcs8g_rx_pipedata[8], w_pcs8g_rx_pipedata[7], w_pcs8g_rx_pipedata[6], w_pcs8g_rx_pipedata[5], w_pcs8g_rx_pipedata[4], w_pcs8g_rx_pipedata[3], w_pcs8g_rx_pipedata[2], w_pcs8g_rx_pipedata[1], w_pcs8g_rx_pipedata[0]}),
				.rxdetectvalid(w_com_pcs_pma_if_pcs8grxdetectvalid),
				.rxelectricalidle(w_pcs8g_rx_eidledetected),
				.rxelectricalidlepcsgen3(w_pipe3_rxelecidle),
				.rxfound(w_com_pcs_pma_if_pcs8gpmarxfound),
				.rxpipereset(w_pcs8g_rx_rxpipesoftreset),
				.rxpolarity(w_pcs8g_tx_rxpolarityout),
				.rxpolaritypcsgen3(w_pipe3_rxpolarity8gpcsout),
				.sigdetni(w_rx_pcs_pma_if_pcs8gsigdetni),
				.speedchange(w_pcs8g_rx_speedchange),
				.speedchangechnldown(w_pcs8g_rx_speedchangeinchnldownpipe),
				.speedchangechnlup(w_pcs8g_rx_speedchangeinchnluppipe),
				.txdch({w_tx_pld_pcs_if_dataoutto8gpcs[43], w_tx_pld_pcs_if_dataoutto8gpcs[42], w_tx_pld_pcs_if_dataoutto8gpcs[41], w_tx_pld_pcs_if_dataoutto8gpcs[40], w_tx_pld_pcs_if_dataoutto8gpcs[39], w_tx_pld_pcs_if_dataoutto8gpcs[38], w_tx_pld_pcs_if_dataoutto8gpcs[37], w_tx_pld_pcs_if_dataoutto8gpcs[36], w_tx_pld_pcs_if_dataoutto8gpcs[35], w_tx_pld_pcs_if_dataoutto8gpcs[34], w_tx_pld_pcs_if_dataoutto8gpcs[33], w_tx_pld_pcs_if_dataoutto8gpcs[32], w_tx_pld_pcs_if_dataoutto8gpcs[31], w_tx_pld_pcs_if_dataoutto8gpcs[30], w_tx_pld_pcs_if_dataoutto8gpcs[29], w_tx_pld_pcs_if_dataoutto8gpcs[28], w_tx_pld_pcs_if_dataoutto8gpcs[27], w_tx_pld_pcs_if_dataoutto8gpcs[26], w_tx_pld_pcs_if_dataoutto8gpcs[25], w_tx_pld_pcs_if_dataoutto8gpcs[24], w_tx_pld_pcs_if_dataoutto8gpcs[23], w_tx_pld_pcs_if_dataoutto8gpcs[22], w_tx_pld_pcs_if_dataoutto8gpcs[21], w_tx_pld_pcs_if_dataoutto8gpcs[20], w_tx_pld_pcs_if_dataoutto8gpcs[19], w_tx_pld_pcs_if_dataoutto8gpcs[18], w_tx_pld_pcs_if_dataoutto8gpcs[17], w_tx_pld_pcs_if_dataoutto8gpcs[16], w_tx_pld_pcs_if_dataoutto8gpcs[15], w_tx_pld_pcs_if_dataoutto8gpcs[14], w_tx_pld_pcs_if_dataoutto8gpcs[13], w_tx_pld_pcs_if_dataoutto8gpcs[12], w_tx_pld_pcs_if_dataoutto8gpcs[11], w_tx_pld_pcs_if_dataoutto8gpcs[10], w_tx_pld_pcs_if_dataoutto8gpcs[9], w_tx_pld_pcs_if_dataoutto8gpcs[8], w_tx_pld_pcs_if_dataoutto8gpcs[7], w_tx_pld_pcs_if_dataoutto8gpcs[6], w_tx_pld_pcs_if_dataoutto8gpcs[5], w_tx_pld_pcs_if_dataoutto8gpcs[4], w_tx_pld_pcs_if_dataoutto8gpcs[3], w_tx_pld_pcs_if_dataoutto8gpcs[2], w_tx_pld_pcs_if_dataoutto8gpcs[1], w_tx_pld_pcs_if_dataoutto8gpcs[0]}),
				.txdeemph(w_pcs8g_tx_phfifotxdeemph),
				.txdetectrxloopback(w_pcs8g_tx_detectrxloopout),
				.txelecidlecomp(w_pcs8g_tx_txpipeelectidle),
				.txelecidlein(w_com_pld_pcs_if_pcs8gtxelecidle),
				.txmargin({w_pcs8g_tx_phfifotxmargin[2], w_pcs8g_tx_phfifotxmargin[1], w_pcs8g_tx_phfifotxmargin[0]}),
				.txpipereset(w_pcs8g_tx_txpipesoftreset),
				.txswingport(w_pcs8g_tx_phfifotxswing),
				
				// UNUSEDs
				.rxdch(/*unused*/),
				.txd(/*unused*/)
			);
		end // if generate
		else begin
				assign w_pipe12_avmmreaddata[15:0] = 16'b0;
				assign w_pipe12_blockselect = 1'b0;
				assign w_pipe12_currentcoeff[17:0] = 18'b0;
				assign w_pipe12_phystatus = 1'b0;
				assign w_pipe12_polinvrxint = w_pcs8g_tx_polinvrxout;// connected when sv_hssi_pipe_gen1_2 is not instantiated
				assign w_pipe12_revloopbk = w_pcs8g_tx_pipeenrevparallellpbkout;// connected when sv_hssi_pipe_gen1_2 is not instantiated
				assign w_pipe12_rxelecidle = w_rx_pcs_pma_if_pcs8gsigdetni;// connected when sv_hssi_pipe_gen1_2 is not instantiated
				assign w_pipe12_rxelectricalidleout = 1'b0;
				assign w_pipe12_rxstatus[2:0] = {1'b0,w_com_pcs_pma_if_pcs8grxdetectvalid,w_com_pcs_pma_if_pcs8gpmarxfound};// connected when sv_hssi_pipe_gen1_2 is not instantiated
				assign w_pipe12_rxvalid = 1'b0;
				assign w_pipe12_speedchangeout = 1'b0;
				assign w_pipe12_txdetectrx = 1'b0;
				assign w_pipe12_txelecidleout = w_com_pld_pcs_if_pcs8gtxelecidle;// connected when sv_hssi_pipe_gen1_2 is not instantiated
		end // if not generate
		
		// instantiating sv_hssi_common_pcs_pma_interface
		if ((enable_10g_rx == "true") || (enable_8g_rx == "true") || (enable_pma_direct_rx == "true") || (enable_dyn_reconfig == "true")) begin
			sv_hssi_common_pcs_pma_interface_rbc #(
				.auto_speed_ena(com_pcs_pma_if_auto_speed_ena),
				.force_freqdet(com_pcs_pma_if_force_freqdet),
				.func_mode(com_pcs_pma_if_func_mode),
				.pcie_gen3_cap(com_pcs_pma_if_pcie_gen3_cap),
				.pipe_if_g3pcs(com_pcs_pma_if_pipe_if_g3pcs),
				.pma_if_dft_en(com_pcs_pma_if_pma_if_dft_en),
				.pma_if_dft_val(com_pcs_pma_if_pma_if_dft_val),
				.ppm_cnt_rst(com_pcs_pma_if_ppm_cnt_rst),
				.ppm_deassert_early(com_pcs_pma_if_ppm_deassert_early),
				.ppm_gen1_2_cnt(com_pcs_pma_if_ppm_gen1_2_cnt),
				.ppm_post_eidle_delay(com_pcs_pma_if_ppm_post_eidle_delay),
				.ppmsel(com_pcs_pma_if_ppmsel),
				.prot_mode(com_pcs_pma_if_prot_mode),
				.refclk_dig_sel(com_pcs_pma_if_refclk_dig_sel),
				.selectpcs(com_pcs_pma_if_selectpcs),
				.sup_mode(com_pcs_pma_if_sup_mode),
				.use_default_base_address(com_pcs_pma_if_use_default_base_address),
				.user_base_address(com_pcs_pma_if_user_base_address)
			) inst_sv_hssi_common_pcs_pma_interface (
				// OUTPUTS
				.aggaligndetsync(w_com_pcs_pma_if_aggaligndetsync),
				.aggalignstatussync(w_com_pcs_pma_if_aggalignstatussync),
				.aggcgcomprddout(w_com_pcs_pma_if_aggcgcomprddout),
				.aggcgcompwrout(w_com_pcs_pma_if_aggcgcompwrout),
				.aggdecctl(w_com_pcs_pma_if_aggdecctl),
				.aggdecdata(w_com_pcs_pma_if_aggdecdata),
				.aggdecdatavalid(w_com_pcs_pma_if_aggdecdatavalid),
				.aggdelcondmetout(w_com_pcs_pma_if_aggdelcondmetout),
				.aggfifoovrout(w_com_pcs_pma_if_aggfifoovrout),
				.aggfifordoutcomp(w_com_pcs_pma_if_aggfifordoutcomp),
				.agginsertincompleteout(w_com_pcs_pma_if_agginsertincompleteout),
				.agglatencycompout(w_com_pcs_pma_if_agglatencycompout),
				.aggrdalign(w_com_pcs_pma_if_aggrdalign),
				.aggrdenablesync(w_com_pcs_pma_if_aggrdenablesync),
				.aggrefclkdig(w_com_pcs_pma_if_aggrefclkdig),
				.aggrunningdisp(w_com_pcs_pma_if_aggrunningdisp),
				.aggrxpcsrst(w_com_pcs_pma_if_aggrxpcsrst),
				.aggscanmoden(w_com_pcs_pma_if_aggscanmoden),
				.aggscanshiftn(w_com_pcs_pma_if_aggscanshiftn),
				.aggsyncstatus(w_com_pcs_pma_if_aggsyncstatus),
				.aggtestsotopldout(w_com_pcs_pma_if_aggtestsotopldout),
				.aggtxctltc(w_com_pcs_pma_if_aggtxctltc),
				.aggtxdatatc(w_com_pcs_pma_if_aggtxdatatc),
				.aggtxpcsrst(w_com_pcs_pma_if_aggtxpcsrst),
				.avmmreaddata(w_com_pcs_pma_if_avmmreaddata),
				.blockselect(w_com_pcs_pma_if_blockselect),
				.freqlock(w_com_pcs_pma_if_freqlock),
				.pcs8ggen2ngen1(w_com_pcs_pma_if_pcs8ggen2ngen1),
				.pcs8gpmarxfound(w_com_pcs_pma_if_pcs8gpmarxfound),
				.pcs8gpowerstatetransitiondone(w_com_pcs_pma_if_pcs8gpowerstatetransitiondone),
				.pcs8grxdetectvalid(w_com_pcs_pma_if_pcs8grxdetectvalid),
				.pcsaggalignstatus(w_com_pcs_pma_if_pcsaggalignstatus),
				.pcsaggalignstatussync0(w_com_pcs_pma_if_pcsaggalignstatussync0),
				.pcsaggalignstatussync0toporbot(w_com_pcs_pma_if_pcsaggalignstatussync0toporbot),
				.pcsaggalignstatustoporbot(w_com_pcs_pma_if_pcsaggalignstatustoporbot),
				.pcsaggcgcomprddall(w_com_pcs_pma_if_pcsaggcgcomprddall),
				.pcsaggcgcomprddalltoporbot(w_com_pcs_pma_if_pcsaggcgcomprddalltoporbot),
				.pcsaggcgcompwrall(w_com_pcs_pma_if_pcsaggcgcompwrall),
				.pcsaggcgcompwralltoporbot(w_com_pcs_pma_if_pcsaggcgcompwralltoporbot),
				.pcsaggdelcondmet0(w_com_pcs_pma_if_pcsaggdelcondmet0),
				.pcsaggdelcondmet0toporbot(w_com_pcs_pma_if_pcsaggdelcondmet0toporbot),
				.pcsaggendskwqd(w_com_pcs_pma_if_pcsaggendskwqd),
				.pcsaggendskwqdtoporbot(w_com_pcs_pma_if_pcsaggendskwqdtoporbot),
				.pcsaggendskwrdptrs(w_com_pcs_pma_if_pcsaggendskwrdptrs),
				.pcsaggendskwrdptrstoporbot(w_com_pcs_pma_if_pcsaggendskwrdptrstoporbot),
				.pcsaggfifoovr0(w_com_pcs_pma_if_pcsaggfifoovr0),
				.pcsaggfifoovr0toporbot(w_com_pcs_pma_if_pcsaggfifoovr0toporbot),
				.pcsaggfifordincomp0(w_com_pcs_pma_if_pcsaggfifordincomp0),
				.pcsaggfifordincomp0toporbot(w_com_pcs_pma_if_pcsaggfifordincomp0toporbot),
				.pcsaggfiforstrdqd(w_com_pcs_pma_if_pcsaggfiforstrdqd),
				.pcsaggfiforstrdqdtoporbot(w_com_pcs_pma_if_pcsaggfiforstrdqdtoporbot),
				.pcsagginsertincomplete0(w_com_pcs_pma_if_pcsagginsertincomplete0),
				.pcsagginsertincomplete0toporbot(w_com_pcs_pma_if_pcsagginsertincomplete0toporbot),
				.pcsagglatencycomp0(w_com_pcs_pma_if_pcsagglatencycomp0),
				.pcsagglatencycomp0toporbot(w_com_pcs_pma_if_pcsagglatencycomp0toporbot),
				.pcsaggrcvdclkagg(w_com_pcs_pma_if_pcsaggrcvdclkagg),
				.pcsaggrcvdclkaggtoporbot(w_com_pcs_pma_if_pcsaggrcvdclkaggtoporbot),
				.pcsaggrxcontrolrs(w_com_pcs_pma_if_pcsaggrxcontrolrs),
				.pcsaggrxcontrolrstoporbot(w_com_pcs_pma_if_pcsaggrxcontrolrstoporbot),
				.pcsaggrxdatars(w_com_pcs_pma_if_pcsaggrxdatars),
				.pcsaggrxdatarstoporbot(w_com_pcs_pma_if_pcsaggrxdatarstoporbot),
				.pcsaggtestbus(w_com_pcs_pma_if_pcsaggtestbus),
				.pcsaggtxctlts(w_com_pcs_pma_if_pcsaggtxctlts),
				.pcsaggtxctltstoporbot(w_com_pcs_pma_if_pcsaggtxctltstoporbot),
				.pcsaggtxdatats(w_com_pcs_pma_if_pcsaggtxdatats),
				.pcsaggtxdatatstoporbot(w_com_pcs_pma_if_pcsaggtxdatatstoporbot),
				.pcsgen3pllfixedclk(w_com_pcs_pma_if_pcsgen3pllfixedclk),
				.pcsgen3pmapcieswdone(w_com_pcs_pma_if_pcsgen3pmapcieswdone),
				.pcsgen3pmarxdetectvalid(w_com_pcs_pma_if_pcsgen3pmarxdetectvalid),
				.pcsgen3pmarxfound(w_com_pcs_pma_if_pcsgen3pmarxfound),
				.pldhclkout(w_com_pcs_pma_if_pldhclkout),
				.pldtestsitoaggout(w_com_pcs_pma_if_pldtestsitoaggout),
				.pmaclklowout(w_com_pcs_pma_if_pmaclklowout),
				.pmacurrentcoeff(w_com_pcs_pma_if_pmacurrentcoeff),
				.pmacurrentrxpreset(w_com_pcs_pma_if_pmacurrentrxpreset),
				.pmaearlyeios(w_com_pcs_pma_if_pmaearlyeios),
				.pmafrefout(w_com_pcs_pma_if_pmafrefout),
				.pmaiftestbus(w_com_pcs_pma_if_pmaiftestbus),
				.pmalccmurstb(w_com_pcs_pma_if_pmalccmurstb),
				.pmaltr(w_com_pcs_pma_if_pmaltr),
				.pmanfrzdrv(w_com_pcs_pma_if_pmanfrzdrv),
				.pmapartialreconfig(w_com_pcs_pma_if_pmapartialreconfig),
				.pmapcieswitch(w_com_pcs_pma_if_pmapcieswitch),
				.pmatxdetectrx(w_com_pcs_pma_if_pmatxdetectrx),
				.pmatxelecidle(w_com_pcs_pma_if_pmatxelecidle),
				// INPUTS
				.aggalignstatus(in_agg_align_status),
				.aggalignstatussync0(in_agg_align_status_sync_0),
				.aggalignstatussync0toporbot(in_agg_align_status_sync_0_top_or_bot),
				.aggalignstatustoporbot(in_agg_align_status_top_or_bot),
				.aggcgcomprddall(in_agg_cg_comp_rd_d_all),
				.aggcgcomprddalltoporbot(in_agg_cg_comp_rd_d_all_top_or_bot),
				.aggcgcompwrall(in_agg_cg_comp_wr_all),
				.aggcgcompwralltoporbot(in_agg_cg_comp_wr_all_top_or_bot),
				.aggdelcondmet0(in_agg_del_cond_met_0),
				.aggdelcondmet0toporbot(in_agg_del_cond_met_0_top_or_bot),
				.aggendskwqd(in_agg_en_dskw_qd),
				.aggendskwqdtoporbot(in_agg_en_dskw_qd_top_or_bot),
				.aggendskwrdptrs(in_agg_en_dskw_rd_ptrs),
				.aggendskwrdptrstoporbot(in_agg_en_dskw_rd_ptrs_top_or_bot),
				.aggfifoovr0(in_agg_fifo_ovr_0),
				.aggfifoovr0toporbot(in_agg_fifo_ovr_0_top_or_bot),
				.aggfifordincomp0(in_agg_fifo_rd_in_comp_0),
				.aggfifordincomp0toporbot(in_agg_fifo_rd_in_comp_0_top_or_bot),
				.aggfiforstrdqd(in_agg_fifo_rst_rd_qd),
				.aggfiforstrdqdtoporbot(in_agg_fifo_rst_rd_qd_top_or_bot),
				.agginsertincomplete0(in_agg_insert_incomplete_0),
				.agginsertincomplete0toporbot(in_agg_insert_incomplete_0_top_or_bot),
				.agglatencycomp0(in_agg_latency_comp_0),
				.agglatencycomp0toporbot(in_agg_latency_comp_0_top_or_bot),
				.aggrcvdclkagg(in_agg_rcvd_clk_agg),
				.aggrcvdclkaggtoporbot(in_agg_rcvd_clk_agg_top_or_bot),
				.aggrxcontrolrs(in_agg_rx_control_rs),
				.aggrxcontrolrstoporbot(in_agg_rx_control_rs_top_or_bot),
				.aggrxdatars({in_agg_rx_data_rs[7], in_agg_rx_data_rs[6], in_agg_rx_data_rs[5], in_agg_rx_data_rs[4], in_agg_rx_data_rs[3], in_agg_rx_data_rs[2], in_agg_rx_data_rs[1], in_agg_rx_data_rs[0]}),
				.aggrxdatarstoporbot({in_agg_rx_data_rs_top_or_bot[7], in_agg_rx_data_rs_top_or_bot[6], in_agg_rx_data_rs_top_or_bot[5], in_agg_rx_data_rs_top_or_bot[4], in_agg_rx_data_rs_top_or_bot[3], in_agg_rx_data_rs_top_or_bot[2], in_agg_rx_data_rs_top_or_bot[1], in_agg_rx_data_rs_top_or_bot[0]}),
				.aggtestbus({in_agg_testbus[15], in_agg_testbus[14], in_agg_testbus[13], in_agg_testbus[12], in_agg_testbus[11], in_agg_testbus[10], in_agg_testbus[9], in_agg_testbus[8], in_agg_testbus[7], in_agg_testbus[6], in_agg_testbus[5], in_agg_testbus[4], in_agg_testbus[3], in_agg_testbus[2], in_agg_testbus[1], in_agg_testbus[0]}),
				.aggtestsotopldin(in_agg_test_so_to_pld_in),
				.aggtxctlts(in_agg_tx_ctl_ts),
				.aggtxctltstoporbot(in_agg_tx_ctl_ts_top_or_bot),
				.aggtxdatats({in_agg_tx_data_ts[7], in_agg_tx_data_ts[6], in_agg_tx_data_ts[5], in_agg_tx_data_ts[4], in_agg_tx_data_ts[3], in_agg_tx_data_ts[2], in_agg_tx_data_ts[1], in_agg_tx_data_ts[0]}),
				.aggtxdatatstoporbot({in_agg_tx_data_ts_top_or_bot[7], in_agg_tx_data_ts_top_or_bot[6], in_agg_tx_data_ts_top_or_bot[5], in_agg_tx_data_ts_top_or_bot[4], in_agg_tx_data_ts_top_or_bot[3], in_agg_tx_data_ts_top_or_bot[2], in_agg_tx_data_ts_top_or_bot[1], in_agg_tx_data_ts_top_or_bot[0]}),
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.clklow(in_pma_clklow_in),
				.fref(in_pma_fref_in),
				.hardreset(w_com_pld_pcs_if_pcspmaifhardreset),
				.pcs8gearlyeios(w_pcs8g_rx_earlyeios),
				.pcs8geidleexit(w_pcs8g_rx_eidleexit),
				.pcs8gltrpma(w_pcs8g_rx_ltr),
				.pcs8gpcieswitch(w_pcs8g_rx_pcieswitch),
				.pcs8gpmacurrentcoeff({w_pipe12_currentcoeff[17], w_pipe12_currentcoeff[16], w_pipe12_currentcoeff[15], w_pipe12_currentcoeff[14], w_pipe12_currentcoeff[13], w_pipe12_currentcoeff[12], w_pipe12_currentcoeff[11], w_pipe12_currentcoeff[10], w_pipe12_currentcoeff[9], w_pipe12_currentcoeff[8], w_pipe12_currentcoeff[7], w_pipe12_currentcoeff[6], w_pipe12_currentcoeff[5], w_pipe12_currentcoeff[4], w_pipe12_currentcoeff[3], w_pipe12_currentcoeff[2], w_pipe12_currentcoeff[1], w_pipe12_currentcoeff[0]}),
				.pcs8gtxdetectrx(w_pipe12_txdetectrx),
				.pcs8gtxelecidle(w_pipe12_txelecidleout),
				.pcsaggaligndetsync({w_pcs8g_rx_aligndetsync[1], w_pcs8g_rx_aligndetsync[0]}),
				.pcsaggalignstatussync(w_pcs8g_rx_alignstatussync),
				.pcsaggcgcomprddout({w_pcs8g_rx_cgcomprddout[1], w_pcs8g_rx_cgcomprddout[0]}),
				.pcsaggcgcompwrout({w_pcs8g_rx_cgcompwrout[1], w_pcs8g_rx_cgcompwrout[0]}),
				.pcsaggdecctl(w_pcs8g_rx_decoderctrl),
				.pcsaggdecdata({w_pcs8g_rx_decoderdata[7], w_pcs8g_rx_decoderdata[6], w_pcs8g_rx_decoderdata[5], w_pcs8g_rx_decoderdata[4], w_pcs8g_rx_decoderdata[3], w_pcs8g_rx_decoderdata[2], w_pcs8g_rx_decoderdata[1], w_pcs8g_rx_decoderdata[0]}),
				.pcsaggdecdatavalid(w_pcs8g_rx_decoderdatavalid),
				.pcsaggdelcondmetout(w_pcs8g_rx_delcondmetout),
				.pcsaggfifoovrout(w_pcs8g_rx_fifoovrout),
				.pcsaggfifordoutcomp(w_pcs8g_rx_fifordoutcomp),
				.pcsagginsertincompleteout(w_pcs8g_rx_insertincompleteout),
				.pcsagglatencycompout(w_pcs8g_rx_latencycompout),
				.pcsaggrdalign({w_pcs8g_rx_rdalign[1], w_pcs8g_rx_rdalign[0]}),
				.pcsaggrdenablesync(w_pcs8g_tx_rdenablesync),
				.pcsaggrefclkdig(w_com_pld_pcs_if_pcsaggrefclkdig),
				.pcsaggrunningdisp({w_pcs8g_rx_runningdisparity[1], w_pcs8g_rx_runningdisparity[0]}),
				.pcsaggrxpcsrst(w_pcs8g_rx_aggrxpcsrst),
				.pcsaggscanmoden(w_com_pld_pcs_if_pcs8gscanmoden),				
				.pcsaggsyncstatus(w_pcs8g_rx_syncstatus),
				.pcsaggtxctltc(w_pcs8g_tx_xgmctrlenable),
				.pcsaggtxdatatc({w_pcs8g_tx_xgmdataout[7], w_pcs8g_tx_xgmdataout[6], w_pcs8g_tx_xgmdataout[5], w_pcs8g_tx_xgmdataout[4], w_pcs8g_tx_xgmdataout[3], w_pcs8g_tx_xgmdataout[2], w_pcs8g_tx_xgmdataout[1], w_pcs8g_tx_xgmdataout[0]}),
				.pcsaggtxpcsrst(w_pcs8g_tx_aggtxpcsrst),
				.pcsgen3gen3datasel(w_pipe3_gen3datasel),
				.pcsgen3pmacurrentcoeff({w_pipe3_pmacurrentcoeff[17], w_pipe3_pmacurrentcoeff[16], w_pipe3_pmacurrentcoeff[15], w_pipe3_pmacurrentcoeff[14], w_pipe3_pmacurrentcoeff[13], w_pipe3_pmacurrentcoeff[12], w_pipe3_pmacurrentcoeff[11], w_pipe3_pmacurrentcoeff[10], w_pipe3_pmacurrentcoeff[9], w_pipe3_pmacurrentcoeff[8], w_pipe3_pmacurrentcoeff[7], w_pipe3_pmacurrentcoeff[6], w_pipe3_pmacurrentcoeff[5], w_pipe3_pmacurrentcoeff[4], w_pipe3_pmacurrentcoeff[3], w_pipe3_pmacurrentcoeff[2], w_pipe3_pmacurrentcoeff[1], w_pipe3_pmacurrentcoeff[0]}),
				.pcsgen3pmacurrentrxpreset({w_pipe3_pmacurrentrxpreset[2], w_pipe3_pmacurrentrxpreset[1], w_pipe3_pmacurrentrxpreset[0]}),
				.pcsgen3pmaearlyeios(w_pipe3_pmaearlyeios),
				.pcsgen3pmaltr(w_pipe3_pmaltr),
				.pcsgen3pmapcieswitch({w_pipe3_pmapcieswitch[1], w_pipe3_pmapcieswitch[0]}),
				.pcsgen3pmatxdetectrx(w_pipe3_pmatxdetectrx),
				.pcsgen3pmatxelecidle(w_pipe3_pmatxelecidle),
				.pcsgen3ppmeidleexit(w_pipe3_ppmeidleexit),
				.pcsrefclkdig(w_com_pld_pcs_if_pcspcspmaifrefclkdig),
				.pcsscanmoden(w_com_pld_pcs_if_pcspcspmaifscanmoden),
				.pcsscanshiftn(w_com_pld_pcs_if_pcspcspmaifscanshiftn),
				.pldlccmurstb(w_tx_pld_pcs_if_pldlccmurstbout),
				.pldnfrzdrv(w_com_pld_pcs_if_pldnfrzdrv),
				.pldpartialreconfig(w_com_pld_pcs_if_pldpartialreconfigout),
				.pldtestsitoaggin(w_com_pld_pcs_if_pcsaggtestsi),
				.pmahclk(in_pma_hclk),
				.pmapcieswdone({in_pma_pcie_sw_done[1], in_pma_pcie_sw_done[0]}),
				.pmarxdetectvalid(in_pma_rx_detect_valid),
				.pmarxfound(in_pma_rx_found),
				.pmarxpmarstb(w_rx_pcs_pma_if_pmarxpmarstb),
				.resetppmcntrs(w_pcs8g_rx_resetppmcntrspcspma),
				
				// UNUSEDs
				.pcsaggscanshiftn( /*unused*/ ),
				.asynchdatain( /*unused*/ ),
				.pmaoffcaldone(/*unused*/),
				.pmaoffcalenin(/*unused*/)
			);
		end // if generate
		else begin
				assign w_com_pcs_pma_if_aggaligndetsync[1:0] = 2'b0;
				assign w_com_pcs_pma_if_aggalignstatussync = 1'b0;
				assign w_com_pcs_pma_if_aggcgcomprddout[1:0] = 2'b0;
				assign w_com_pcs_pma_if_aggcgcompwrout[1:0] = 2'b0;
				assign w_com_pcs_pma_if_aggdecctl = 1'b0;
				assign w_com_pcs_pma_if_aggdecdata[7:0] = 8'b0;
				assign w_com_pcs_pma_if_aggdecdatavalid = 1'b0;
				assign w_com_pcs_pma_if_aggdelcondmetout = 1'b0;
				assign w_com_pcs_pma_if_aggfifoovrout = 1'b0;
				assign w_com_pcs_pma_if_aggfifordoutcomp = 1'b0;
				assign w_com_pcs_pma_if_agginsertincompleteout = 1'b0;
				assign w_com_pcs_pma_if_agglatencycompout = 1'b0;
				assign w_com_pcs_pma_if_aggrdalign[1:0] = 2'b0;
				assign w_com_pcs_pma_if_aggrdenablesync = 1'b0;
				assign w_com_pcs_pma_if_aggrefclkdig = 1'b0;
				assign w_com_pcs_pma_if_aggrunningdisp[1:0] = 2'b0;
				assign w_com_pcs_pma_if_aggrxpcsrst = 1'b0;
				assign w_com_pcs_pma_if_aggscanmoden = 1'b0;
				assign w_com_pcs_pma_if_aggscanshiftn = 1'b0;
				assign w_com_pcs_pma_if_aggsyncstatus = 1'b0;
				assign w_com_pcs_pma_if_aggtestsotopldout = 1'b0;
				assign w_com_pcs_pma_if_aggtxctltc = 1'b0;
				assign w_com_pcs_pma_if_aggtxdatatc[7:0] = 8'b0;
				assign w_com_pcs_pma_if_aggtxpcsrst = 1'b0;
				assign w_com_pcs_pma_if_avmmreaddata[15:0] = 16'b0;
				assign w_com_pcs_pma_if_blockselect = 1'b0;
				assign w_com_pcs_pma_if_freqlock = 1'b0;
				assign w_com_pcs_pma_if_pcs8ggen2ngen1 = 1'b0;
				assign w_com_pcs_pma_if_pcs8gpmarxfound = 1'b0;
				assign w_com_pcs_pma_if_pcs8gpowerstatetransitiondone = 1'b0;
				assign w_com_pcs_pma_if_pcs8grxdetectvalid = 1'b0;
				assign w_com_pcs_pma_if_pcsaggalignstatus = 1'b0;
				assign w_com_pcs_pma_if_pcsaggalignstatussync0 = 1'b0;
				assign w_com_pcs_pma_if_pcsaggalignstatussync0toporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggalignstatustoporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggcgcomprddall = 1'b0;
				assign w_com_pcs_pma_if_pcsaggcgcomprddalltoporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggcgcompwrall = 1'b0;
				assign w_com_pcs_pma_if_pcsaggcgcompwralltoporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggdelcondmet0 = 1'b0;
				assign w_com_pcs_pma_if_pcsaggdelcondmet0toporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggendskwqd = 1'b0;
				assign w_com_pcs_pma_if_pcsaggendskwqdtoporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggendskwrdptrs = 1'b0;
				assign w_com_pcs_pma_if_pcsaggendskwrdptrstoporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggfifoovr0 = 1'b0;
				assign w_com_pcs_pma_if_pcsaggfifoovr0toporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggfifordincomp0 = 1'b0;
				assign w_com_pcs_pma_if_pcsaggfifordincomp0toporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggfiforstrdqd = 1'b0;
				assign w_com_pcs_pma_if_pcsaggfiforstrdqdtoporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsagginsertincomplete0 = 1'b0;
				assign w_com_pcs_pma_if_pcsagginsertincomplete0toporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsagglatencycomp0 = 1'b0;
				assign w_com_pcs_pma_if_pcsagglatencycomp0toporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggrcvdclkagg = 1'b0;
				assign w_com_pcs_pma_if_pcsaggrcvdclkaggtoporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggrxcontrolrs = 1'b0;
				assign w_com_pcs_pma_if_pcsaggrxcontrolrstoporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggrxdatars[7:0] = 8'b0;
				assign w_com_pcs_pma_if_pcsaggrxdatarstoporbot[7:0] = 8'b0;
				assign w_com_pcs_pma_if_pcsaggtestbus[15:0] = 16'b0;
				assign w_com_pcs_pma_if_pcsaggtxctlts = 1'b0;
				assign w_com_pcs_pma_if_pcsaggtxctltstoporbot = 1'b0;
				assign w_com_pcs_pma_if_pcsaggtxdatats[7:0] = 8'b0;
				assign w_com_pcs_pma_if_pcsaggtxdatatstoporbot[7:0] = 8'b0;
				assign w_com_pcs_pma_if_pcsgen3pllfixedclk = 1'b0;
				assign w_com_pcs_pma_if_pcsgen3pmapcieswdone[1:0] = 2'b0;
				assign w_com_pcs_pma_if_pcsgen3pmarxdetectvalid = 1'b0;
				assign w_com_pcs_pma_if_pcsgen3pmarxfound = 1'b0;
				assign w_com_pcs_pma_if_pldhclkout = 1'b0;
				assign w_com_pcs_pma_if_pldtestsitoaggout = 1'b0;
				assign w_com_pcs_pma_if_pmaclklowout = 1'b0;
				assign w_com_pcs_pma_if_pmacurrentcoeff[17:0] = 18'b0;
				assign w_com_pcs_pma_if_pmacurrentrxpreset[2:0] = 3'b0;
				assign w_com_pcs_pma_if_pmaearlyeios = 1'b0;
				assign w_com_pcs_pma_if_pmafrefout = 1'b0;
				assign w_com_pcs_pma_if_pmaiftestbus[9:0] = 10'b0;
				assign w_com_pcs_pma_if_pmalccmurstb = 1'b0;
				assign w_com_pcs_pma_if_pmaltr = 1'b0;
				assign w_com_pcs_pma_if_pmanfrzdrv = 1'b0;
				assign w_com_pcs_pma_if_pmapartialreconfig = 1'b0;
				assign w_com_pcs_pma_if_pmapcieswitch[1:0] = 2'b0;
				assign w_com_pcs_pma_if_pmatxdetectrx = 1'b0;
				assign w_com_pcs_pma_if_pmatxelecidle = 1'b0;
		end // if not generate
		
		// instantiating sv_hssi_10g_rx_pcs
		if ((enable_10g_rx == "true") || (enable_dyn_reconfig == "true")) begin
			sv_hssi_10g_rx_pcs_rbc #(
				.align_del(pcs10g_rx_align_del),
				.ber_bit_err_total_cnt(pcs10g_rx_ber_bit_err_total_cnt),
				.ber_clken(pcs10g_rx_ber_clken),
				.ber_xus_timer_window(pcs10g_rx_ber_xus_timer_window),
				.ber_xus_timer_window_user(pcs10g_rx_ber_xus_timer_window_user),
				.bit_reverse(pcs10g_rx_bit_reverse),
				.bitslip_mode(pcs10g_rx_bitslip_mode),
				.bitslip_wait_cnt_user(pcs10g_rx_bitslip_wait_cnt_user),
				.blksync_bitslip_type(pcs10g_rx_blksync_bitslip_type),
				.blksync_bitslip_wait_cnt(pcs10g_rx_blksync_bitslip_wait_cnt),
				.blksync_bitslip_wait_cnt_user(pcs10g_rx_blksync_bitslip_wait_cnt_user),
				.blksync_bitslip_wait_type(pcs10g_rx_blksync_bitslip_wait_type),
				.blksync_bypass(pcs10g_rx_blksync_bypass),
				.blksync_clken(pcs10g_rx_blksync_clken),
				.blksync_enum_invalid_sh_cnt(pcs10g_rx_blksync_enum_invalid_sh_cnt),
				.blksync_knum_sh_cnt_postlock(pcs10g_rx_blksync_knum_sh_cnt_postlock),
				.blksync_knum_sh_cnt_prelock(pcs10g_rx_blksync_knum_sh_cnt_prelock),
				.blksync_pipeln(pcs10g_rx_blksync_pipeln),
				.channel_number(channel_number),
				.control_del(pcs10g_rx_control_del),
				.crcchk_bypass(pcs10g_rx_crcchk_bypass),
				.crcchk_clken(pcs10g_rx_crcchk_clken),
				.crcchk_init(pcs10g_rx_crcchk_init),
				.crcchk_init_user(pcs10g_rx_crcchk_init_user),
				.crcchk_inv(pcs10g_rx_crcchk_inv),
				.crcchk_pipeln(pcs10g_rx_crcchk_pipeln),
				.crcflag_pipeln(pcs10g_rx_crcflag_pipeln),
				.ctrl_bit_reverse(pcs10g_rx_ctrl_bit_reverse),
				.data_bit_reverse(pcs10g_rx_data_bit_reverse),
				.dec64b66b_clken(pcs10g_rx_dec64b66b_clken),
				.dec_64b66b_rxsm_bypass(pcs10g_rx_dec_64b66b_rxsm_bypass),
				.descrm_bypass(pcs10g_rx_descrm_bypass),
				.descrm_clken(pcs10g_rx_descrm_clken),
				.descrm_mode(pcs10g_rx_descrm_mode),
				.dis_signal_ok(pcs10g_rx_dis_signal_ok),
				.dispchk_bypass(pcs10g_rx_dispchk_bypass),
				.dispchk_clken(pcs10g_rx_dispchk_clken),
				.dispchk_pipeln(pcs10g_rx_dispchk_pipeln),
				.dispchk_rd_level(pcs10g_rx_dispchk_rd_level),
				.dispchk_rd_level_user(pcs10g_rx_dispchk_rd_level_user),
				.empty_flag_type(pcs10g_rx_empty_flag_type),
				.fast_path(pcs10g_rx_fast_path),
				.fifo_stop_rd(pcs10g_rx_fifo_stop_rd),
				.fifo_stop_wr(pcs10g_rx_fifo_stop_wr),
				.force_align(pcs10g_rx_force_align),
				.frmgen_diag_word(pcs10g_rx_frmgen_diag_word),
				.frmgen_scrm_word(pcs10g_rx_frmgen_scrm_word),
				.frmgen_skip_word(pcs10g_rx_frmgen_skip_word),
				.frmgen_sync_word(pcs10g_rx_frmgen_sync_word),
				.frmsync_bypass(pcs10g_rx_frmsync_bypass),
				.frmsync_clken(pcs10g_rx_frmsync_clken),
				.frmsync_enum_scrm(pcs10g_rx_frmsync_enum_scrm),
				.frmsync_enum_sync(pcs10g_rx_frmsync_enum_sync),
				.frmsync_flag_type(pcs10g_rx_frmsync_flag_type),
				.frmsync_knum_sync(pcs10g_rx_frmsync_knum_sync),
				.frmsync_mfrm_length(pcs10g_rx_frmsync_mfrm_length),
				.frmsync_mfrm_length_user(pcs10g_rx_frmsync_mfrm_length_user),
				.frmsync_pipeln(pcs10g_rx_frmsync_pipeln),
				.full_flag_type(pcs10g_rx_full_flag_type),
				.gb_rx_idwidth(pcs10g_rx_gb_rx_idwidth),
				.gb_rx_odwidth(pcs10g_rx_gb_rx_odwidth),
				.gb_sel_mode(pcs10g_rx_gb_sel_mode),
				.gbexp_clken(pcs10g_rx_gbexp_clken),
				.iqtxrx_clkout_sel(pcs10g_rx_iqtxrx_clkout_sel),
				.lpbk_mode(pcs10g_rx_lpbk_mode),
				.master_clk_sel(pcs10g_rx_master_clk_sel),
				.pempty_flag_type(pcs10g_rx_pempty_flag_type),
				.pfull_flag_type(pcs10g_rx_pfull_flag_type),
				.prbs_clken(pcs10g_rx_prbs_clken),
				.prot_mode(pcs10g_rx_prot_mode),
				.rand_clken(pcs10g_rx_rand_clken),
				.rd_clk_sel(pcs10g_rx_rd_clk_sel),
				.rdfifo_clken(pcs10g_rx_rdfifo_clken),
				.rx_dfx_lpbk(pcs10g_rx_rx_dfx_lpbk),
				.rx_fifo_write_ctrl(pcs10g_rx_rx_fifo_write_ctrl),
				.rx_polarity_inv(pcs10g_rx_rx_polarity_inv),
				.rx_prbs_mask(pcs10g_rx_rx_prbs_mask),
				.rx_scrm_width(pcs10g_rx_rx_scrm_width),
				.rx_sh_location(pcs10g_rx_rx_sh_location),
				.rx_signal_ok_sel(pcs10g_rx_rx_signal_ok_sel),
				.rx_sm_bypass(pcs10g_rx_rx_sm_bypass),
				.rx_sm_hiber(pcs10g_rx_rx_sm_hiber),
				.rx_sm_pipeln(pcs10g_rx_rx_sm_pipeln),
				.rx_testbus_sel(pcs10g_rx_rx_testbus_sel),
				.rx_true_b2b(pcs10g_rx_rx_true_b2b),
				.rxfifo_empty(pcs10g_rx_rxfifo_empty),
				.rxfifo_full(pcs10g_rx_rxfifo_full),
				.rxfifo_mode(pcs10g_rx_rxfifo_mode),
				.rxfifo_pempty(pcs10g_rx_rxfifo_pempty),
				.rxfifo_pfull(pcs10g_rx_rxfifo_pfull),
				.skip_ctrl(pcs10g_rx_skip_ctrl),
				.stretch_en(pcs10g_rx_stretch_en),
				.stretch_num_stages(pcs10g_rx_stretch_num_stages),
				.stretch_type(pcs10g_rx_stretch_type),
				.sup_mode(pcs10g_rx_sup_mode),
				.test_bus_mode(pcs10g_rx_test_bus_mode),
				.test_mode(pcs10g_rx_test_mode),
				.use_default_base_address(pcs10g_rx_use_default_base_address),
				.user_base_address(pcs10g_rx_user_base_address),
				.wrfifo_clken(pcs10g_rx_wrfifo_clken)
			) inst_sv_hssi_10g_rx_pcs (
				// OUTPUTS
				.avmmreaddata(w_pcs10g_rx_avmmreaddata),
				.blockselect(w_pcs10g_rx_blockselect),
				.rxalignval(w_pcs10g_rx_rxalignval),
				.rxblocklock(w_pcs10g_rx_rxblocklock),
				.rxclkiqout(w_pcs10g_rx_rxclkiqout),
				.rxclkout(w_pcs10g_rx_rxclkout),
				.rxcontrol(w_pcs10g_rx_rxcontrol),
				.rxcrc32error(w_pcs10g_rx_rxcrc32error),
				.rxdata(w_pcs10g_rx_rxdata),
				.rxdatavalid(w_pcs10g_rx_rxdatavalid),
				.rxdiagnosticerror(w_pcs10g_rx_rxdiagnosticerror),
				.rxdiagnosticstatus(w_pcs10g_rx_rxdiagnosticstatus),
				.rxfifodel(w_pcs10g_rx_rxfifodel),
				.rxfifoempty(w_pcs10g_rx_rxfifoempty),
				.rxfifofull(w_pcs10g_rx_rxfifofull),
				.rxfifoinsert(w_pcs10g_rx_rxfifoinsert),
				.rxfifopartialempty(w_pcs10g_rx_rxfifopartialempty),
				.rxfifopartialfull(w_pcs10g_rx_rxfifopartialfull),
				.rxframelock(w_pcs10g_rx_rxframelock),
				.rxhighber(w_pcs10g_rx_rxhighber),
				.rxmetaframeerror(w_pcs10g_rx_rxmetaframeerror),
				.rxpayloadinserted(w_pcs10g_rx_rxpayloadinserted),
				.rxprbsdone(w_pcs10g_rx_rxprbsdone),
				.rxprbserr(w_pcs10g_rx_rxprbserr),
				.rxrdnegsts(w_pcs10g_rx_rxrdnegsts),
				.rxrdpossts(w_pcs10g_rx_rxrdpossts),
				.rxrxframe(w_pcs10g_rx_rxrxframe),
				.rxscramblererror(w_pcs10g_rx_rxscramblererror),
				.rxskipinserted(w_pcs10g_rx_rxskipinserted),
				.rxskipworderror(w_pcs10g_rx_rxskipworderror),
				.rxsyncheadererror(w_pcs10g_rx_rxsyncheadererror),
				.rxsyncworderror(w_pcs10g_rx_rxsyncworderror),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.dfxlpbkcontrolin({1'b0, w_pcs10g_tx_dfxlpbkcontrolout[8], w_pcs10g_tx_dfxlpbkcontrolout[7], w_pcs10g_tx_dfxlpbkcontrolout[6], w_pcs10g_tx_dfxlpbkcontrolout[5], w_pcs10g_tx_dfxlpbkcontrolout[4], w_pcs10g_tx_dfxlpbkcontrolout[3], w_pcs10g_tx_dfxlpbkcontrolout[2], w_pcs10g_tx_dfxlpbkcontrolout[1], w_pcs10g_tx_dfxlpbkcontrolout[0]}),
				.dfxlpbkdatain({w_pcs10g_tx_dfxlpbkdataout[63], w_pcs10g_tx_dfxlpbkdataout[62], w_pcs10g_tx_dfxlpbkdataout[61], w_pcs10g_tx_dfxlpbkdataout[60], w_pcs10g_tx_dfxlpbkdataout[59], w_pcs10g_tx_dfxlpbkdataout[58], w_pcs10g_tx_dfxlpbkdataout[57], w_pcs10g_tx_dfxlpbkdataout[56], w_pcs10g_tx_dfxlpbkdataout[55], w_pcs10g_tx_dfxlpbkdataout[54], w_pcs10g_tx_dfxlpbkdataout[53], w_pcs10g_tx_dfxlpbkdataout[52], w_pcs10g_tx_dfxlpbkdataout[51], w_pcs10g_tx_dfxlpbkdataout[50], w_pcs10g_tx_dfxlpbkdataout[49], w_pcs10g_tx_dfxlpbkdataout[48], w_pcs10g_tx_dfxlpbkdataout[47], w_pcs10g_tx_dfxlpbkdataout[46], w_pcs10g_tx_dfxlpbkdataout[45], w_pcs10g_tx_dfxlpbkdataout[44], w_pcs10g_tx_dfxlpbkdataout[43], w_pcs10g_tx_dfxlpbkdataout[42], w_pcs10g_tx_dfxlpbkdataout[41], w_pcs10g_tx_dfxlpbkdataout[40], w_pcs10g_tx_dfxlpbkdataout[39], w_pcs10g_tx_dfxlpbkdataout[38], w_pcs10g_tx_dfxlpbkdataout[37], w_pcs10g_tx_dfxlpbkdataout[36], w_pcs10g_tx_dfxlpbkdataout[35], w_pcs10g_tx_dfxlpbkdataout[34], w_pcs10g_tx_dfxlpbkdataout[33], w_pcs10g_tx_dfxlpbkdataout[32], w_pcs10g_tx_dfxlpbkdataout[31], w_pcs10g_tx_dfxlpbkdataout[30], w_pcs10g_tx_dfxlpbkdataout[29], w_pcs10g_tx_dfxlpbkdataout[28], w_pcs10g_tx_dfxlpbkdataout[27], w_pcs10g_tx_dfxlpbkdataout[26], w_pcs10g_tx_dfxlpbkdataout[25], w_pcs10g_tx_dfxlpbkdataout[24], w_pcs10g_tx_dfxlpbkdataout[23], w_pcs10g_tx_dfxlpbkdataout[22], w_pcs10g_tx_dfxlpbkdataout[21], w_pcs10g_tx_dfxlpbkdataout[20], w_pcs10g_tx_dfxlpbkdataout[19], w_pcs10g_tx_dfxlpbkdataout[18], w_pcs10g_tx_dfxlpbkdataout[17], w_pcs10g_tx_dfxlpbkdataout[16], w_pcs10g_tx_dfxlpbkdataout[15], w_pcs10g_tx_dfxlpbkdataout[14], w_pcs10g_tx_dfxlpbkdataout[13], w_pcs10g_tx_dfxlpbkdataout[12], w_pcs10g_tx_dfxlpbkdataout[11], w_pcs10g_tx_dfxlpbkdataout[10], w_pcs10g_tx_dfxlpbkdataout[9], w_pcs10g_tx_dfxlpbkdataout[8], w_pcs10g_tx_dfxlpbkdataout[7], w_pcs10g_tx_dfxlpbkdataout[6], w_pcs10g_tx_dfxlpbkdataout[5], w_pcs10g_tx_dfxlpbkdataout[4], w_pcs10g_tx_dfxlpbkdataout[3], w_pcs10g_tx_dfxlpbkdataout[2], w_pcs10g_tx_dfxlpbkdataout[1], w_pcs10g_tx_dfxlpbkdataout[0]}),
				.dfxlpbkdatavalidin(w_pcs10g_tx_dfxlpbkdatavalidout),
				.hardresetn(w_com_pld_pcs_if_pcs10ghardreset),
				.lpbkdatain({w_pcs10g_tx_lpbkdataout[79], w_pcs10g_tx_lpbkdataout[78], w_pcs10g_tx_lpbkdataout[77], w_pcs10g_tx_lpbkdataout[76], w_pcs10g_tx_lpbkdataout[75], w_pcs10g_tx_lpbkdataout[74], w_pcs10g_tx_lpbkdataout[73], w_pcs10g_tx_lpbkdataout[72], w_pcs10g_tx_lpbkdataout[71], w_pcs10g_tx_lpbkdataout[70], w_pcs10g_tx_lpbkdataout[69], w_pcs10g_tx_lpbkdataout[68], w_pcs10g_tx_lpbkdataout[67], w_pcs10g_tx_lpbkdataout[66], w_pcs10g_tx_lpbkdataout[65], w_pcs10g_tx_lpbkdataout[64], w_pcs10g_tx_lpbkdataout[63], w_pcs10g_tx_lpbkdataout[62], w_pcs10g_tx_lpbkdataout[61], w_pcs10g_tx_lpbkdataout[60], w_pcs10g_tx_lpbkdataout[59], w_pcs10g_tx_lpbkdataout[58], w_pcs10g_tx_lpbkdataout[57], w_pcs10g_tx_lpbkdataout[56], w_pcs10g_tx_lpbkdataout[55], w_pcs10g_tx_lpbkdataout[54], w_pcs10g_tx_lpbkdataout[53], w_pcs10g_tx_lpbkdataout[52], w_pcs10g_tx_lpbkdataout[51], w_pcs10g_tx_lpbkdataout[50], w_pcs10g_tx_lpbkdataout[49], w_pcs10g_tx_lpbkdataout[48], w_pcs10g_tx_lpbkdataout[47], w_pcs10g_tx_lpbkdataout[46], w_pcs10g_tx_lpbkdataout[45], w_pcs10g_tx_lpbkdataout[44], w_pcs10g_tx_lpbkdataout[43], w_pcs10g_tx_lpbkdataout[42], w_pcs10g_tx_lpbkdataout[41], w_pcs10g_tx_lpbkdataout[40], w_pcs10g_tx_lpbkdataout[39], w_pcs10g_tx_lpbkdataout[38], w_pcs10g_tx_lpbkdataout[37], w_pcs10g_tx_lpbkdataout[36], w_pcs10g_tx_lpbkdataout[35], w_pcs10g_tx_lpbkdataout[34], w_pcs10g_tx_lpbkdataout[33], w_pcs10g_tx_lpbkdataout[32], w_pcs10g_tx_lpbkdataout[31], w_pcs10g_tx_lpbkdataout[30], w_pcs10g_tx_lpbkdataout[29], w_pcs10g_tx_lpbkdataout[28], w_pcs10g_tx_lpbkdataout[27], w_pcs10g_tx_lpbkdataout[26], w_pcs10g_tx_lpbkdataout[25], w_pcs10g_tx_lpbkdataout[24], w_pcs10g_tx_lpbkdataout[23], w_pcs10g_tx_lpbkdataout[22], w_pcs10g_tx_lpbkdataout[21], w_pcs10g_tx_lpbkdataout[20], w_pcs10g_tx_lpbkdataout[19], w_pcs10g_tx_lpbkdataout[18], w_pcs10g_tx_lpbkdataout[17], w_pcs10g_tx_lpbkdataout[16], w_pcs10g_tx_lpbkdataout[15], w_pcs10g_tx_lpbkdataout[14], w_pcs10g_tx_lpbkdataout[13], w_pcs10g_tx_lpbkdataout[12], w_pcs10g_tx_lpbkdataout[11], w_pcs10g_tx_lpbkdataout[10], w_pcs10g_tx_lpbkdataout[9], w_pcs10g_tx_lpbkdataout[8], w_pcs10g_tx_lpbkdataout[7], w_pcs10g_tx_lpbkdataout[6], w_pcs10g_tx_lpbkdataout[5], w_pcs10g_tx_lpbkdataout[4], w_pcs10g_tx_lpbkdataout[3], w_pcs10g_tx_lpbkdataout[2], w_pcs10g_tx_lpbkdataout[1], w_pcs10g_tx_lpbkdataout[0]}),
				.pmaclkdiv33txorrx(w_rx_pcs_pma_if_pcs10gclkdiv33txorrx),
				.refclkdig(w_com_pld_pcs_if_pcs10grefclkdig),
				.rxalignclr(w_rx_pld_pcs_if_pcs10grxalignclr),
				.rxalignen(w_rx_pld_pcs_if_pcs10grxalignen),
				.rxbitslip(w_rx_pld_pcs_if_pcs10grxbitslip),
				.rxclrbercount(w_rx_pld_pcs_if_pcs10grxclrbercount),
				.rxclrerrorblockcount(w_rx_pld_pcs_if_pcs10grxclrerrblkcnt),
				.rxdisparityclr(w_rx_pld_pcs_if_pcs10grxdispclr),
				.rxpldclk(w_rx_pld_pcs_if_pcs10grxpldclk),
				.rxpldrstn(w_rx_pld_pcs_if_pcs10grxpldrstn),
				.rxpmaclk(w_rx_pcs_pma_if_clkoutto10gpcs),
				.rxpmadata({w_rx_pcs_pma_if_dataoutto10gpcs[79], w_rx_pcs_pma_if_dataoutto10gpcs[78], w_rx_pcs_pma_if_dataoutto10gpcs[77], w_rx_pcs_pma_if_dataoutto10gpcs[76], w_rx_pcs_pma_if_dataoutto10gpcs[75], w_rx_pcs_pma_if_dataoutto10gpcs[74], w_rx_pcs_pma_if_dataoutto10gpcs[73], w_rx_pcs_pma_if_dataoutto10gpcs[72], w_rx_pcs_pma_if_dataoutto10gpcs[71], w_rx_pcs_pma_if_dataoutto10gpcs[70], w_rx_pcs_pma_if_dataoutto10gpcs[69], w_rx_pcs_pma_if_dataoutto10gpcs[68], w_rx_pcs_pma_if_dataoutto10gpcs[67], w_rx_pcs_pma_if_dataoutto10gpcs[66], w_rx_pcs_pma_if_dataoutto10gpcs[65], w_rx_pcs_pma_if_dataoutto10gpcs[64], w_rx_pcs_pma_if_dataoutto10gpcs[63], w_rx_pcs_pma_if_dataoutto10gpcs[62], w_rx_pcs_pma_if_dataoutto10gpcs[61], w_rx_pcs_pma_if_dataoutto10gpcs[60], w_rx_pcs_pma_if_dataoutto10gpcs[59], w_rx_pcs_pma_if_dataoutto10gpcs[58], w_rx_pcs_pma_if_dataoutto10gpcs[57], w_rx_pcs_pma_if_dataoutto10gpcs[56], w_rx_pcs_pma_if_dataoutto10gpcs[55], w_rx_pcs_pma_if_dataoutto10gpcs[54], w_rx_pcs_pma_if_dataoutto10gpcs[53], w_rx_pcs_pma_if_dataoutto10gpcs[52], w_rx_pcs_pma_if_dataoutto10gpcs[51], w_rx_pcs_pma_if_dataoutto10gpcs[50], w_rx_pcs_pma_if_dataoutto10gpcs[49], w_rx_pcs_pma_if_dataoutto10gpcs[48], w_rx_pcs_pma_if_dataoutto10gpcs[47], w_rx_pcs_pma_if_dataoutto10gpcs[46], w_rx_pcs_pma_if_dataoutto10gpcs[45], w_rx_pcs_pma_if_dataoutto10gpcs[44], w_rx_pcs_pma_if_dataoutto10gpcs[43], w_rx_pcs_pma_if_dataoutto10gpcs[42], w_rx_pcs_pma_if_dataoutto10gpcs[41], w_rx_pcs_pma_if_dataoutto10gpcs[40], w_rx_pcs_pma_if_dataoutto10gpcs[39], w_rx_pcs_pma_if_dataoutto10gpcs[38], w_rx_pcs_pma_if_dataoutto10gpcs[37], w_rx_pcs_pma_if_dataoutto10gpcs[36], w_rx_pcs_pma_if_dataoutto10gpcs[35], w_rx_pcs_pma_if_dataoutto10gpcs[34], w_rx_pcs_pma_if_dataoutto10gpcs[33], w_rx_pcs_pma_if_dataoutto10gpcs[32], w_rx_pcs_pma_if_dataoutto10gpcs[31], w_rx_pcs_pma_if_dataoutto10gpcs[30], w_rx_pcs_pma_if_dataoutto10gpcs[29], w_rx_pcs_pma_if_dataoutto10gpcs[28], w_rx_pcs_pma_if_dataoutto10gpcs[27], w_rx_pcs_pma_if_dataoutto10gpcs[26], w_rx_pcs_pma_if_dataoutto10gpcs[25], w_rx_pcs_pma_if_dataoutto10gpcs[24], w_rx_pcs_pma_if_dataoutto10gpcs[23], w_rx_pcs_pma_if_dataoutto10gpcs[22], w_rx_pcs_pma_if_dataoutto10gpcs[21], w_rx_pcs_pma_if_dataoutto10gpcs[20], w_rx_pcs_pma_if_dataoutto10gpcs[19], w_rx_pcs_pma_if_dataoutto10gpcs[18], w_rx_pcs_pma_if_dataoutto10gpcs[17], w_rx_pcs_pma_if_dataoutto10gpcs[16], w_rx_pcs_pma_if_dataoutto10gpcs[15], w_rx_pcs_pma_if_dataoutto10gpcs[14], w_rx_pcs_pma_if_dataoutto10gpcs[13], w_rx_pcs_pma_if_dataoutto10gpcs[12], w_rx_pcs_pma_if_dataoutto10gpcs[11], w_rx_pcs_pma_if_dataoutto10gpcs[10], w_rx_pcs_pma_if_dataoutto10gpcs[9], w_rx_pcs_pma_if_dataoutto10gpcs[8], w_rx_pcs_pma_if_dataoutto10gpcs[7], w_rx_pcs_pma_if_dataoutto10gpcs[6], w_rx_pcs_pma_if_dataoutto10gpcs[5], w_rx_pcs_pma_if_dataoutto10gpcs[4], w_rx_pcs_pma_if_dataoutto10gpcs[3], w_rx_pcs_pma_if_dataoutto10gpcs[2], w_rx_pcs_pma_if_dataoutto10gpcs[1], w_rx_pcs_pma_if_dataoutto10gpcs[0]}),
				.rxpmadatavalid(w_rx_pcs_pma_if_pcs10gsignalok),
				.rxprbserrorclr(w_rx_pld_pcs_if_pcs10grxprbserrclr),
				.rxrden(w_rx_pld_pcs_if_pcs10grxrden),
				.txpmaclk(w_tx_pcs_pma_if_clockoutto10gpcs),
				
				// UNUSEDs
				.rxtestdata( /*unused*/ ),
				.syncdatain( /*unused*/ )
			);
		end // if generate
		else begin
				assign w_pcs10g_rx_avmmreaddata[15:0] = 16'b0;
				assign w_pcs10g_rx_blockselect = 1'b0;
				assign w_pcs10g_rx_rxalignval = 1'b0;
				assign w_pcs10g_rx_rxblocklock = 1'b0;
				assign w_pcs10g_rx_rxclkiqout = 1'b0;
				assign w_pcs10g_rx_rxclkout = 1'b0;
				assign w_pcs10g_rx_rxcontrol[9:0] = 10'b0;
				assign w_pcs10g_rx_rxcrc32error = 1'b0;
				assign w_pcs10g_rx_rxdata[63:0] = 64'b0;
				assign w_pcs10g_rx_rxdatavalid = 1'b0;
				assign w_pcs10g_rx_rxdiagnosticerror = 1'b0;
				assign w_pcs10g_rx_rxdiagnosticstatus[1:0] = 2'b0;
				assign w_pcs10g_rx_rxfifodel = 1'b0;
				assign w_pcs10g_rx_rxfifoempty = 1'b0;
				assign w_pcs10g_rx_rxfifofull = 1'b0;
				assign w_pcs10g_rx_rxfifoinsert = 1'b0;
				assign w_pcs10g_rx_rxfifopartialempty = 1'b0;
				assign w_pcs10g_rx_rxfifopartialfull = 1'b0;
				assign w_pcs10g_rx_rxframelock = 1'b0;
				assign w_pcs10g_rx_rxhighber = 1'b0;
				assign w_pcs10g_rx_rxmetaframeerror = 1'b0;
				assign w_pcs10g_rx_rxpayloadinserted = 1'b0;
				assign w_pcs10g_rx_rxprbsdone = 1'b0;
				assign w_pcs10g_rx_rxprbserr = 1'b0;
				assign w_pcs10g_rx_rxrdnegsts = 1'b0;
				assign w_pcs10g_rx_rxrdpossts = 1'b0;
				assign w_pcs10g_rx_rxrxframe = 1'b0;
				assign w_pcs10g_rx_rxscramblererror = 1'b0;
				assign w_pcs10g_rx_rxskipinserted = 1'b0;
				assign w_pcs10g_rx_rxskipworderror = 1'b0;
				assign w_pcs10g_rx_rxsyncheadererror = 1'b0;
				assign w_pcs10g_rx_rxsyncworderror = 1'b0;
		end // if not generate
		
		// instantiating sv_hssi_pipe_gen3
		if ((enable_gen3_pipe == "true") || (enable_dyn_reconfig == "true")) begin
			sv_hssi_pipe_gen3_rbc #(
				.asn_clk_enable(pipe3_asn_clk_enable),
				.asn_enable(pipe3_asn_enable),
				.bypass_pma_sw_done(pipe3_bypass_pma_sw_done),
				.bypass_rx_detection_enable(pipe3_bypass_rx_detection_enable),
				.bypass_rx_preset(pipe3_bypass_rx_preset),
				.bypass_rx_preset_data(pipe3_bypass_rx_preset_data),
				.bypass_rx_preset_enable(pipe3_bypass_rx_preset_enable),
				.bypass_send_syncp_fbkp(pipe3_bypass_send_syncp_fbkp),
				.bypass_tx_coefficent(pipe3_bypass_tx_coefficent),
				.bypass_tx_coefficent_data(pipe3_bypass_tx_coefficent_data),
				.bypass_tx_coefficent_enable(pipe3_bypass_tx_coefficent_enable),
				.cdr_control(pipe3_cdr_control),
				.cid_enable(pipe3_cid_enable),
				.cp_cons_sel(pipe3_cp_cons_sel),
				.cp_dwn_mstr(pipe3_cp_dwn_mstr),
				.cp_up_mstr(pipe3_cp_up_mstr),
				.ctrl_plane_bonding(pipe3_ctrl_plane_bonding),
				.data_mask_count(pipe3_data_mask_count),
				.data_mask_count_val(pipe3_data_mask_count_val),
				.elecidle_delay_g3(pipe3_elecidle_delay_g3),
				.elecidle_delay_g3_data(pipe3_elecidle_delay_g3_data),
				.free_run_clk_enable(pipe3_free_run_clk_enable),
				.ind_error_reporting(pipe3_ind_error_reporting),
				.inf_ei_enable(pipe3_inf_ei_enable),
				.mode(pipe3_mode),
				.parity_chk_ts1(pipe3_parity_chk_ts1),
				.pc_en_counter(pipe3_pc_en_counter),
				.pc_en_counter_data(pipe3_pc_en_counter_data),
				.pc_rst_counter(pipe3_pc_rst_counter),
				.pc_rst_counter_data(pipe3_pc_rst_counter_data),
				.ph_fifo_reg_mode(pipe3_ph_fifo_reg_mode),
				.phfifo_flush_wait(pipe3_phfifo_flush_wait),
				.phfifo_flush_wait_data(pipe3_phfifo_flush_wait_data),
				.phy_status_delay_g12(pipe3_phy_status_delay_g12),
				.phy_status_delay_g12_data(pipe3_phy_status_delay_g12_data),
				.phy_status_delay_g3(pipe3_phy_status_delay_g3),
				.phy_status_delay_g3_data(pipe3_phy_status_delay_g3_data),
				.phystatus_rst_toggle_g12(pipe3_phystatus_rst_toggle_g12),
				.phystatus_rst_toggle_g3(pipe3_phystatus_rst_toggle_g3),
				.pipe_clk_sel(pipe3_pipe_clk_sel),
				.pma_done_counter(pipe3_pma_done_counter),
				.pma_done_counter_data(pipe3_pma_done_counter_data),
				.rate_match_pad_insertion(pipe3_rate_match_pad_insertion),
				.rxvalid_mask(pipe3_rxvalid_mask),
				.sigdet_wait_counter(pipe3_sigdet_wait_counter),
				.sigdet_wait_counter_data(pipe3_sigdet_wait_counter_data),
				.spd_chnge_g2_sel(pipe3_spd_chnge_g2_sel),
				.sup_mode(pipe3_sup_mode),
				.test_mode_timers(pipe3_test_mode_timers),
				.test_out_sel(pipe3_test_out_sel),
				.use_default_base_address(pipe3_use_default_base_address),
				.user_base_address(pipe3_user_base_address),
				.wait_clk_on_off_timer(pipe3_wait_clk_on_off_timer),
				.wait_clk_on_off_timer_data(pipe3_wait_clk_on_off_timer_data),
				.wait_pipe_synchronizing(pipe3_wait_pipe_synchronizing),
				.wait_pipe_synchronizing_data(pipe3_wait_pipe_synchronizing_data),
				.wait_send_syncp_fbkp(pipe3_wait_send_syncp_fbkp),
				.wait_send_syncp_fbkp_data(pipe3_wait_send_syncp_fbkp_data)
			) inst_sv_hssi_pipe_gen3 (
				// OUTPUTS
				.avmmreaddata(w_pipe3_avmmreaddata),
				.blockselect(w_pipe3_blockselect),
				.bundlingoutdown(w_pipe3_bundlingoutdown),
				.bundlingoutup(w_pipe3_bundlingoutup),
				.dispcbyte(w_pipe3_dispcbyte),
				.gen3clksel(w_pipe3_gen3clksel),
				.gen3datasel(w_pipe3_gen3datasel),
				.inferredrxvalidint(w_pipe3_inferredrxvalidint),
				.masktxpll(w_pipe3_masktxpll),
				.pcsrst(w_pipe3_pcsrst),
				.phystatus(w_pipe3_phystatus),
				.pmacurrentcoeff(w_pipe3_pmacurrentcoeff),
				.pmacurrentrxpreset(w_pipe3_pmacurrentrxpreset),
				.pmaearlyeios(w_pipe3_pmaearlyeios),
				.pmaltr(w_pipe3_pmaltr),
				.pmapcieswitch(w_pipe3_pmapcieswitch),
				.pmatxdetectrx(w_pipe3_pmatxdetectrx),
				.pmatxelecidle(w_pipe3_pmatxelecidle),
				.ppmcntrst8gpcsout(w_pipe3_ppmcntrst8gpcsout),
				.ppmeidleexit(w_pipe3_ppmeidleexit),
				.resetpcprts(w_pipe3_resetpcprts),
				.revlpbk8gpcsout(w_pipe3_revlpbk8gpcsout),
				.revlpbkint(w_pipe3_revlpbkint),
				.rxblkstart(w_pipe3_rxblkstart),
				.rxd8gpcsout(w_pipe3_rxd8gpcsout),
				.rxdataskip(w_pipe3_rxdataskip),
				.rxelecidle(w_pipe3_rxelecidle),
				.rxpolarity8gpcsout(w_pipe3_rxpolarity8gpcsout),
				.rxpolarityint(w_pipe3_rxpolarityint),
				.rxstatus(w_pipe3_rxstatus),
				.rxsynchdr(w_pipe3_rxsynchdr),
				.rxvalid(w_pipe3_rxvalid),
				.shutdownclk(w_pipe3_shutdownclk),
				.testout(w_pipe3_testout),
				.txblkstartint(w_pipe3_txblkstartint),
				.txdataint(w_pipe3_txdataint),
				.txdatakint(w_pipe3_txdatakint),
				.txdataskipint(w_pipe3_txdataskipint),
				.txpmasyncp(w_pipe3_txpmasyncp),
				.txsynchdrint(w_pipe3_txsynchdrint),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.blkalgndint(w_pcs_g3_rx_blkalgndint),
				.bundlingindown({in_pcs_gen3_bundling_in_down[10], in_pcs_gen3_bundling_in_down[9], in_pcs_gen3_bundling_in_down[8], in_pcs_gen3_bundling_in_down[7], in_pcs_gen3_bundling_in_down[6], in_pcs_gen3_bundling_in_down[5], in_pcs_gen3_bundling_in_down[4], in_pcs_gen3_bundling_in_down[3], in_pcs_gen3_bundling_in_down[2], in_pcs_gen3_bundling_in_down[1], in_pcs_gen3_bundling_in_down[0]}),
				.bundlinginup({in_pcs_gen3_bundling_in_up[10], in_pcs_gen3_bundling_in_up[9], in_pcs_gen3_bundling_in_up[8], in_pcs_gen3_bundling_in_up[7], in_pcs_gen3_bundling_in_up[6], in_pcs_gen3_bundling_in_up[5], in_pcs_gen3_bundling_in_up[4], in_pcs_gen3_bundling_in_up[3], in_pcs_gen3_bundling_in_up[2], in_pcs_gen3_bundling_in_up[1], in_pcs_gen3_bundling_in_up[0]}),
				.clkcompdeleteint(w_pcs_g3_rx_clkcompdeleteint),
				.clkcompinsertint(w_pcs_g3_rx_clkcompinsertint),
				.clkcompoverflint(w_pcs_g3_rx_clkcompoverflint),
				.clkcompundflint(w_pcs_g3_rx_clkcompundflint),
				.currentcoeff({w_com_pld_pcs_if_pcsgen3currentcoeff[17], w_com_pld_pcs_if_pcsgen3currentcoeff[16], w_com_pld_pcs_if_pcsgen3currentcoeff[15], w_com_pld_pcs_if_pcsgen3currentcoeff[14], w_com_pld_pcs_if_pcsgen3currentcoeff[13], w_com_pld_pcs_if_pcsgen3currentcoeff[12], w_com_pld_pcs_if_pcsgen3currentcoeff[11], w_com_pld_pcs_if_pcsgen3currentcoeff[10], w_com_pld_pcs_if_pcsgen3currentcoeff[9], w_com_pld_pcs_if_pcsgen3currentcoeff[8], w_com_pld_pcs_if_pcsgen3currentcoeff[7], w_com_pld_pcs_if_pcsgen3currentcoeff[6], w_com_pld_pcs_if_pcsgen3currentcoeff[5], w_com_pld_pcs_if_pcsgen3currentcoeff[4], w_com_pld_pcs_if_pcsgen3currentcoeff[3], w_com_pld_pcs_if_pcsgen3currentcoeff[2], w_com_pld_pcs_if_pcsgen3currentcoeff[1], w_com_pld_pcs_if_pcsgen3currentcoeff[0]}),
				.currentrxpreset({w_com_pld_pcs_if_pcsgen3currentrxpreset[2], w_com_pld_pcs_if_pcsgen3currentrxpreset[1], w_com_pld_pcs_if_pcsgen3currentrxpreset[0]}),
				.eidetint(w_pcs_g3_rx_eidetint),
				.eidleinfersel({w_com_pld_pcs_if_pcsgen3eidleinfersel[2], w_com_pld_pcs_if_pcsgen3eidleinfersel[1], w_com_pld_pcs_if_pcsgen3eidleinfersel[0]}),
				.eipartialdetint(w_pcs_g3_rx_eipartialdetint),
				.errdecodeint(w_pcs_g3_rx_errdecodeint),
				.errencodeint(w_pcs_g3_tx_errencode),
				.hardresetn(w_com_pld_pcs_if_pcsgen3hardreset),
				.idetint(w_pcs_g3_rx_idetint),
				.pldltr(w_com_pld_pcs_if_pcsgen3pldltr),
				.pllfixedclk(w_com_pcs_pma_if_pcsgen3pllfixedclk),
				.pmapcieswdone({w_com_pcs_pma_if_pcsgen3pmapcieswdone[1], w_com_pcs_pma_if_pcsgen3pmapcieswdone[0]}),
				.pmarxdetectvalid(w_com_pcs_pma_if_pcsgen3pmarxdetectvalid),
				.pmarxfound(w_com_pcs_pma_if_pcsgen3pmarxfound),
				.pmasignaldet(w_rx_pcs_pma_if_pcsgen3pmasignaldet),
				.powerdown({w_pcs8g_tx_pipepowerdownout[1], w_pcs8g_tx_pipepowerdownout[0]}),
				.rate({w_com_pld_pcs_if_pcsgen3rate[1], w_com_pld_pcs_if_pcsgen3rate[0]}),
				.rcvdclk(w_rx_pcs_pma_if_clockouttogen3pcs),
				.rcvlfsrchkint(w_pcs_g3_rx_rcvlfsrchkint),
				.rxblkstartint(w_pcs_g3_rx_blkstart),
				.rxd8gpcsin({w_pcs8g_rx_pipedata[63], w_pcs8g_rx_pipedata[62], w_pcs8g_rx_pipedata[61], w_pcs8g_rx_pipedata[60], w_pcs8g_rx_pipedata[59], w_pcs8g_rx_pipedata[58], w_pcs8g_rx_pipedata[57], w_pcs8g_rx_pipedata[56], w_pcs8g_rx_pipedata[55], w_pcs8g_rx_pipedata[54], w_pcs8g_rx_pipedata[53], w_pcs8g_rx_pipedata[52], w_pcs8g_rx_pipedata[51], w_pcs8g_rx_pipedata[50], w_pcs8g_rx_pipedata[49], w_pcs8g_rx_pipedata[48], w_pcs8g_rx_pipedata[47], w_pcs8g_rx_pipedata[46], w_pcs8g_rx_pipedata[45], w_pcs8g_rx_pipedata[44], w_pcs8g_rx_pipedata[43], w_pcs8g_rx_pipedata[42], w_pcs8g_rx_pipedata[41], w_pcs8g_rx_pipedata[40], w_pcs8g_rx_pipedata[39], w_pcs8g_rx_pipedata[38], w_pcs8g_rx_pipedata[37], w_pcs8g_rx_pipedata[36], w_pcs8g_rx_pipedata[35], w_pcs8g_rx_pipedata[34], w_pcs8g_rx_pipedata[33], w_pcs8g_rx_pipedata[32], w_pcs8g_rx_pipedata[31], w_pcs8g_rx_pipedata[30], w_pcs8g_rx_pipedata[29], w_pcs8g_rx_pipedata[28], w_pcs8g_rx_pipedata[27], w_pcs8g_rx_pipedata[26], w_pcs8g_rx_pipedata[25], w_pcs8g_rx_pipedata[24], w_pcs8g_rx_pipedata[23], w_pcs8g_rx_pipedata[22], w_pcs8g_rx_pipedata[21], w_pcs8g_rx_pipedata[20], w_pcs8g_rx_pipedata[19], w_pcs8g_rx_pipedata[18], w_pcs8g_rx_pipedata[17], w_pcs8g_rx_pipedata[16], w_pcs8g_rx_pipedata[15], w_pcs8g_rx_pipedata[14], w_pcs8g_rx_pipedata[13], w_pcs8g_rx_pipedata[12], w_pcs8g_rx_pipedata[11], w_pcs8g_rx_pipedata[10], w_pcs8g_rx_pipedata[9], w_pcs8g_rx_pipedata[8], w_pcs8g_rx_pipedata[7], w_pcs8g_rx_pipedata[6], w_pcs8g_rx_pipedata[5], w_pcs8g_rx_pipedata[4], w_pcs8g_rx_pipedata[3], w_pcs8g_rx_pipedata[2], w_pcs8g_rx_pipedata[1], w_pcs8g_rx_pipedata[0]}),
				.rxdataint({w_pcs_g3_rx_dataout[31], w_pcs_g3_rx_dataout[30], w_pcs_g3_rx_dataout[29], w_pcs_g3_rx_dataout[28], w_pcs_g3_rx_dataout[27], w_pcs_g3_rx_dataout[26], w_pcs_g3_rx_dataout[25], w_pcs_g3_rx_dataout[24], w_pcs_g3_rx_dataout[23], w_pcs_g3_rx_dataout[22], w_pcs_g3_rx_dataout[21], w_pcs_g3_rx_dataout[20], w_pcs_g3_rx_dataout[19], w_pcs_g3_rx_dataout[18], w_pcs_g3_rx_dataout[17], w_pcs_g3_rx_dataout[16], w_pcs_g3_rx_dataout[15], w_pcs_g3_rx_dataout[14], w_pcs_g3_rx_dataout[13], w_pcs_g3_rx_dataout[12], w_pcs_g3_rx_dataout[11], w_pcs_g3_rx_dataout[10], w_pcs_g3_rx_dataout[9], w_pcs_g3_rx_dataout[8], w_pcs_g3_rx_dataout[7], w_pcs_g3_rx_dataout[6], w_pcs_g3_rx_dataout[5], w_pcs_g3_rx_dataout[4], w_pcs_g3_rx_dataout[3], w_pcs_g3_rx_dataout[2], w_pcs_g3_rx_dataout[1], w_pcs_g3_rx_dataout[0]}),
				.rxdataskipint(w_pcs_g3_rx_datavalid),
				.rxelecidle8gpcsin(w_pipe12_rxelectricalidleout),
				.rxpolarity(w_pcs8g_tx_rxpolarityout),
				.rxrstn(w_rx_pld_pcs_if_pcsgen3rxrst),
				.rxsynchdrint({w_pcs_g3_rx_synchdr[1], w_pcs_g3_rx_synchdr[0]}),
				.rxtestout({w_pcs_g3_rx_rxtestout[19], w_pcs_g3_rx_rxtestout[18], w_pcs_g3_rx_rxtestout[17], w_pcs_g3_rx_rxtestout[16], w_pcs_g3_rx_rxtestout[15], w_pcs_g3_rx_rxtestout[14], w_pcs_g3_rx_rxtestout[13], w_pcs_g3_rx_rxtestout[12], w_pcs_g3_rx_rxtestout[11], w_pcs_g3_rx_rxtestout[10], w_pcs_g3_rx_rxtestout[9], w_pcs_g3_rx_rxtestout[8], w_pcs_g3_rx_rxtestout[7], w_pcs_g3_rx_rxtestout[6], w_pcs_g3_rx_rxtestout[5], w_pcs_g3_rx_rxtestout[4], w_pcs_g3_rx_rxtestout[3], w_pcs_g3_rx_rxtestout[2], w_pcs_g3_rx_rxtestout[1], w_pcs_g3_rx_rxtestout[0]}),
				.scanmoden(w_com_pld_pcs_if_pcsgen3scanmoden),
				.speedchangeg2(w_pipe12_speedchangeout),
				.txblkstart(w_pcs8g_tx_txblkstartout[0]),
				.txcompliance(w_pcs8g_tx_txcomplianceout),
				.txdata({w_pcs8g_tx_txdataouttogen3[31], w_pcs8g_tx_txdataouttogen3[30], w_pcs8g_tx_txdataouttogen3[29], w_pcs8g_tx_txdataouttogen3[28], w_pcs8g_tx_txdataouttogen3[27], w_pcs8g_tx_txdataouttogen3[26], w_pcs8g_tx_txdataouttogen3[25], w_pcs8g_tx_txdataouttogen3[24], w_pcs8g_tx_txdataouttogen3[23], w_pcs8g_tx_txdataouttogen3[22], w_pcs8g_tx_txdataouttogen3[21], w_pcs8g_tx_txdataouttogen3[20], w_pcs8g_tx_txdataouttogen3[19], w_pcs8g_tx_txdataouttogen3[18], w_pcs8g_tx_txdataouttogen3[17], w_pcs8g_tx_txdataouttogen3[16], w_pcs8g_tx_txdataouttogen3[15], w_pcs8g_tx_txdataouttogen3[14], w_pcs8g_tx_txdataouttogen3[13], w_pcs8g_tx_txdataouttogen3[12], w_pcs8g_tx_txdataouttogen3[11], w_pcs8g_tx_txdataouttogen3[10], w_pcs8g_tx_txdataouttogen3[9], w_pcs8g_tx_txdataouttogen3[8], w_pcs8g_tx_txdataouttogen3[7], w_pcs8g_tx_txdataouttogen3[6], w_pcs8g_tx_txdataouttogen3[5], w_pcs8g_tx_txdataouttogen3[4], w_pcs8g_tx_txdataouttogen3[3], w_pcs8g_tx_txdataouttogen3[2], w_pcs8g_tx_txdataouttogen3[1], w_pcs8g_tx_txdataouttogen3[0]}),
				.txdatak({w_pcs8g_tx_txdatakouttogen3[3], w_pcs8g_tx_txdatakouttogen3[2], w_pcs8g_tx_txdatakouttogen3[1], w_pcs8g_tx_txdatakouttogen3[0]}),
				.txdataskip(w_pcs8g_tx_txdatavalidouttogen3[0]),
				.txdeemph(w_pcs8g_tx_phfifotxdeemph),
				.txdetectrxloopback(w_pcs8g_tx_detectrxloopout),
				.txelecidle(w_pcs8g_tx_txelecidleout),
				.txmargin({w_pcs8g_tx_phfifotxmargin[2], w_pcs8g_tx_phfifotxmargin[1], w_pcs8g_tx_phfifotxmargin[0]}),
				.txpmaclk(w_pcs8g_tx_clkoutgen3),
				.txpmasyncphip(w_tx_pld_pcs_if_pldtxpmasyncpfbkpout),
				.txrstn(w_tx_pld_pcs_if_pcsgen3txrst),
				.txswing(w_pcs8g_tx_phfifotxswing),
				.txsynchdr({w_pcs8g_tx_txsynchdrout[1], w_pcs8g_tx_txsynchdrout[0]}),
				
				// UNUSEDs
				.pmarxdetpd( /*unused*/ ),
				.pmatxdeemph( /*unused*/ ),
				.pmatxmargin( /*unused*/ ),
				.pmatxswing( /*unused*/ ),
				.rrxdigclksel( /*unused*/ ),
				.rrxgen3capen( /*unused*/ ),
				.rtxdigclksel( /*unused*/ ),
				.rtxgen3capen( /*unused*/ ),
				.rxdatakint( /*unused*/ ),
				.rxupdatefc( /*unused*/ ),
				.testinfei( /*unused*/ )
			);
		end // if generate
		else begin
				assign w_pipe3_avmmreaddata[15:0] = 16'b0;
				assign w_pipe3_blockselect = 1'b0;
				assign w_pipe3_bundlingoutdown[10:0] = 11'b0;
				assign w_pipe3_bundlingoutup[10:0] = 11'b0;
				assign w_pipe3_dispcbyte = 1'b0;
				assign w_pipe3_gen3clksel = 1'b0;
				assign w_pipe3_gen3datasel = 1'b0;
				assign w_pipe3_inferredrxvalidint = 1'b0;
				assign w_pipe3_masktxpll = 1'b0;
				assign w_pipe3_pcsrst = 1'b0;
				assign w_pipe3_phystatus = 1'b0;
				assign w_pipe3_pmacurrentcoeff[17:0] = 18'b0;
				assign w_pipe3_pmacurrentrxpreset[2:0] = 3'b0;
				assign w_pipe3_pmaearlyeios = 1'b0;
				assign w_pipe3_pmaltr = 1'b0;
				assign w_pipe3_pmapcieswitch[1:0] = 2'b0;
				assign w_pipe3_pmatxdetectrx = 1'b0;
				assign w_pipe3_pmatxelecidle = 1'b0;
				assign w_pipe3_ppmcntrst8gpcsout = 1'b0;
				assign w_pipe3_ppmeidleexit = 1'b0;
				assign w_pipe3_resetpcprts = 1'b0;
				assign w_pipe3_revlpbk8gpcsout = 1'b0;
				assign w_pipe3_revlpbkint = 1'b0;
				assign w_pipe3_rxblkstart[3:0] = 4'b0;
				assign w_pipe3_rxd8gpcsout[63:0] = 64'b0;
				assign w_pipe3_rxdataskip[3:0] = 4'b0;
				assign w_pipe3_rxelecidle = 1'b0;
				assign w_pipe3_rxpolarity8gpcsout = 1'b0;
				assign w_pipe3_rxpolarityint = 1'b0;
				assign w_pipe3_rxstatus[2:0] = 3'b0;
				assign w_pipe3_rxsynchdr[1:0] = 2'b0;
				assign w_pipe3_rxvalid = 1'b0;
				assign w_pipe3_shutdownclk = 1'b0;
				assign w_pipe3_testout[19:0] = 20'b0;
				assign w_pipe3_txblkstartint = 1'b0;
				assign w_pipe3_txdataint[31:0] = 32'b0;
				assign w_pipe3_txdatakint[3:0] = 4'b0;
				assign w_pipe3_txdataskipint = 1'b0;
				assign w_pipe3_txpmasyncp = 1'b0;
				assign w_pipe3_txsynchdrint[1:0] = 2'b0;
		end // if not generate
		
		// instantiating sv_hssi_tx_pcs_pma_interface
		if ((enable_10g_tx == "true") || (enable_8g_tx == "true") || (enable_dyn_reconfig == "true")) begin
			sv_hssi_tx_pcs_pma_interface_rbc #(
				.selectpcs(tx_pcs_pma_if_selectpcs),
				.use_default_base_address(tx_pcs_pma_if_use_default_base_address),
				.user_base_address(tx_pcs_pma_if_user_base_address)
			) inst_sv_hssi_tx_pcs_pma_interface (
				// OUTPUTS
				.avmmreaddata(w_tx_pcs_pma_if_avmmreaddata),
				.blockselect(w_tx_pcs_pma_if_blockselect),
				.clockoutto10gpcs(w_tx_pcs_pma_if_clockoutto10gpcs),
				.clockoutto8gpcs(w_tx_pcs_pma_if_clockoutto8gpcs),
				.dataouttopma(w_tx_pcs_pma_if_dataouttopma),
				.pcs10gclkdiv33lc(w_tx_pcs_pma_if_pcs10gclkdiv33lc),
				.pmaclkdiv33lcout(w_tx_pcs_pma_if_pmaclkdiv33lcout),
				.pmarxfreqtxcmuplllockout(w_tx_pcs_pma_if_pmarxfreqtxcmuplllockout),
				.pmatxclkout(w_tx_pcs_pma_if_pmatxclkout),
				.pmatxlcplllockout(w_tx_pcs_pma_if_pmatxlcplllockout),
				.pmatxpmasyncpfbkp(w_tx_pcs_pma_if_pmatxpmasyncpfbkp),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.clockinfrompma(in_pma_tx_pma_clk),
				.datainfrom10gpcs({w_pcs10g_tx_txpmadata[79], w_pcs10g_tx_txpmadata[78], w_pcs10g_tx_txpmadata[77], w_pcs10g_tx_txpmadata[76], w_pcs10g_tx_txpmadata[75], w_pcs10g_tx_txpmadata[74], w_pcs10g_tx_txpmadata[73], w_pcs10g_tx_txpmadata[72], w_pcs10g_tx_txpmadata[71], w_pcs10g_tx_txpmadata[70], w_pcs10g_tx_txpmadata[69], w_pcs10g_tx_txpmadata[68], w_pcs10g_tx_txpmadata[67], w_pcs10g_tx_txpmadata[66], w_pcs10g_tx_txpmadata[65], w_pcs10g_tx_txpmadata[64], w_pcs10g_tx_txpmadata[63], w_pcs10g_tx_txpmadata[62], w_pcs10g_tx_txpmadata[61], w_pcs10g_tx_txpmadata[60], w_pcs10g_tx_txpmadata[59], w_pcs10g_tx_txpmadata[58], w_pcs10g_tx_txpmadata[57], w_pcs10g_tx_txpmadata[56], w_pcs10g_tx_txpmadata[55], w_pcs10g_tx_txpmadata[54], w_pcs10g_tx_txpmadata[53], w_pcs10g_tx_txpmadata[52], w_pcs10g_tx_txpmadata[51], w_pcs10g_tx_txpmadata[50], w_pcs10g_tx_txpmadata[49], w_pcs10g_tx_txpmadata[48], w_pcs10g_tx_txpmadata[47], w_pcs10g_tx_txpmadata[46], w_pcs10g_tx_txpmadata[45], w_pcs10g_tx_txpmadata[44], w_pcs10g_tx_txpmadata[43], w_pcs10g_tx_txpmadata[42], w_pcs10g_tx_txpmadata[41], w_pcs10g_tx_txpmadata[40], w_pcs10g_tx_txpmadata[39], w_pcs10g_tx_txpmadata[38], w_pcs10g_tx_txpmadata[37], w_pcs10g_tx_txpmadata[36], w_pcs10g_tx_txpmadata[35], w_pcs10g_tx_txpmadata[34], w_pcs10g_tx_txpmadata[33], w_pcs10g_tx_txpmadata[32], w_pcs10g_tx_txpmadata[31], w_pcs10g_tx_txpmadata[30], w_pcs10g_tx_txpmadata[29], w_pcs10g_tx_txpmadata[28], w_pcs10g_tx_txpmadata[27], w_pcs10g_tx_txpmadata[26], w_pcs10g_tx_txpmadata[25], w_pcs10g_tx_txpmadata[24], w_pcs10g_tx_txpmadata[23], w_pcs10g_tx_txpmadata[22], w_pcs10g_tx_txpmadata[21], w_pcs10g_tx_txpmadata[20], w_pcs10g_tx_txpmadata[19], w_pcs10g_tx_txpmadata[18], w_pcs10g_tx_txpmadata[17], w_pcs10g_tx_txpmadata[16], w_pcs10g_tx_txpmadata[15], w_pcs10g_tx_txpmadata[14], w_pcs10g_tx_txpmadata[13], w_pcs10g_tx_txpmadata[12], w_pcs10g_tx_txpmadata[11], w_pcs10g_tx_txpmadata[10], w_pcs10g_tx_txpmadata[9], w_pcs10g_tx_txpmadata[8], w_pcs10g_tx_txpmadata[7], w_pcs10g_tx_txpmadata[6], w_pcs10g_tx_txpmadata[5], w_pcs10g_tx_txpmadata[4], w_pcs10g_tx_txpmadata[3], w_pcs10g_tx_txpmadata[2], w_pcs10g_tx_txpmadata[1], w_pcs10g_tx_txpmadata[0]}),
				.datainfrom8gpcs({w_pcs8g_tx_dataout[19], w_pcs8g_tx_dataout[18], w_pcs8g_tx_dataout[17], w_pcs8g_tx_dataout[16], w_pcs8g_tx_dataout[15], w_pcs8g_tx_dataout[14], w_pcs8g_tx_dataout[13], w_pcs8g_tx_dataout[12], w_pcs8g_tx_dataout[11], w_pcs8g_tx_dataout[10], w_pcs8g_tx_dataout[9], w_pcs8g_tx_dataout[8], w_pcs8g_tx_dataout[7], w_pcs8g_tx_dataout[6], w_pcs8g_tx_dataout[5], w_pcs8g_tx_dataout[4], w_pcs8g_tx_dataout[3], w_pcs8g_tx_dataout[2], w_pcs8g_tx_dataout[1], w_pcs8g_tx_dataout[0]}),
				.datainfromgen3pcs({w_pcs_g3_tx_dataout[31], w_pcs_g3_tx_dataout[30], w_pcs_g3_tx_dataout[29], w_pcs_g3_tx_dataout[28], w_pcs_g3_tx_dataout[27], w_pcs_g3_tx_dataout[26], w_pcs_g3_tx_dataout[25], w_pcs_g3_tx_dataout[24], w_pcs_g3_tx_dataout[23], w_pcs_g3_tx_dataout[22], w_pcs_g3_tx_dataout[21], w_pcs_g3_tx_dataout[20], w_pcs_g3_tx_dataout[19], w_pcs_g3_tx_dataout[18], w_pcs_g3_tx_dataout[17], w_pcs_g3_tx_dataout[16], w_pcs_g3_tx_dataout[15], w_pcs_g3_tx_dataout[14], w_pcs_g3_tx_dataout[13], w_pcs_g3_tx_dataout[12], w_pcs_g3_tx_dataout[11], w_pcs_g3_tx_dataout[10], w_pcs_g3_tx_dataout[9], w_pcs_g3_tx_dataout[8], w_pcs_g3_tx_dataout[7], w_pcs_g3_tx_dataout[6], w_pcs_g3_tx_dataout[5], w_pcs_g3_tx_dataout[4], w_pcs_g3_tx_dataout[3], w_pcs_g3_tx_dataout[2], w_pcs_g3_tx_dataout[1], w_pcs_g3_tx_dataout[0]}),
				.pcs10gtxclkiqout(w_pcs10g_tx_txclkiqout),
				.pcs8gtxclkiqout(w_pcs8g_tx_clkout),
				.pcsemsiptxclkiqout(w_rx_pld_pcs_if_pldrxiqclkout),
				.pcsgen3gen3datasel(w_pipe3_gen3datasel),
				.pldtxpmasyncpfbkp(w_pipe3_txpmasyncp),
				.pmaclkdiv33lcin(in_pma_clkdiv33_lc_in),
				.pmarxfreqtxcmuplllockin(in_pma_rx_freq_tx_cmu_pll_lock_in),
				.pmatxlcplllockin(in_pma_tx_lc_pll_lock_in),
				.asynchdatain(/*unused*/),
				.reset(/*unused*/)
			);
		end // if generate
		else begin
				assign w_tx_pcs_pma_if_avmmreaddata[15:0] = 16'b0;
				assign w_tx_pcs_pma_if_blockselect = 1'b0;
				assign w_tx_pcs_pma_if_clockoutto10gpcs = 1'b0;
				assign w_tx_pcs_pma_if_clockoutto8gpcs = 1'b0;
				assign w_tx_pcs_pma_if_dataouttopma[79:0] = 80'b0;
				assign w_tx_pcs_pma_if_pcs10gclkdiv33lc = 1'b0;
				assign w_tx_pcs_pma_if_pmaclkdiv33lcout = 1'b0;
				assign w_tx_pcs_pma_if_pmarxfreqtxcmuplllockout = 1'b0;
				assign w_tx_pcs_pma_if_pmatxclkout = 1'b0;
				assign w_tx_pcs_pma_if_pmatxlcplllockout = 1'b0;
				assign w_tx_pcs_pma_if_pmatxpmasyncpfbkp = 1'b0;
		end // if not generate
		
		// instantiating sv_hssi_tx_pld_pcs_interface
		if ((enable_10g_tx == "true") || (enable_8g_tx == "true") || (enable_dyn_reconfig == "true")) begin
			sv_hssi_tx_pld_pcs_interface_rbc #(
				.data_source(tx_pld_pcs_if_data_source),
				.is_10g_0ppm(tx_pld_pcs_if_is_10g_0ppm),
				.is_8g_0ppm(tx_pld_pcs_if_is_8g_0ppm),
				.use_default_base_address(tx_pld_pcs_if_use_default_base_address),
				.user_base_address(tx_pld_pcs_if_user_base_address)
			) inst_sv_hssi_tx_pld_pcs_interface (
				// OUTPUTS
				.avmmreaddata(w_tx_pld_pcs_if_avmmreaddata),
				.blockselect(w_tx_pld_pcs_if_blockselect),
				.dataoutto10gpcs(w_tx_pld_pcs_if_dataoutto10gpcs),
				.dataoutto8gpcs(w_tx_pld_pcs_if_dataoutto8gpcs),
				.emsippcstxclkout(w_tx_pld_pcs_if_emsippcstxclkout),
				.emsiptxout(w_tx_pld_pcs_if_emsiptxout),
				.emsiptxspecialout(w_tx_pld_pcs_if_emsiptxspecialout),
				.pcs10gtxbitslip(w_tx_pld_pcs_if_pcs10gtxbitslip),
				.pcs10gtxbursten(w_tx_pld_pcs_if_pcs10gtxbursten),
				.pcs10gtxcontrol(w_tx_pld_pcs_if_pcs10gtxcontrol),
				.pcs10gtxdatavalid(w_tx_pld_pcs_if_pcs10gtxdatavalid),
				.pcs10gtxdiagstatus(w_tx_pld_pcs_if_pcs10gtxdiagstatus),
				.pcs10gtxpldclk(w_tx_pld_pcs_if_pcs10gtxpldclk),
				.pcs10gtxpldrstn(w_tx_pld_pcs_if_pcs10gtxpldrstn),
				.pcs10gtxwordslip(w_tx_pld_pcs_if_pcs10gtxwordslip),
				.pcs8gphfifoursttx(w_tx_pld_pcs_if_pcs8gphfifoursttx),
				.pcs8gpldtxclk(w_tx_pld_pcs_if_pcs8gpldtxclk),
				.pcs8gpolinvtx(w_tx_pld_pcs_if_pcs8gpolinvtx),
				.pcs8grddisabletx(w_tx_pld_pcs_if_pcs8grddisabletx),
				.pcs8grevloopbk(w_tx_pld_pcs_if_pcs8grevloopbk),
				.pcs8gtxblkstart(w_tx_pld_pcs_if_pcs8gtxblkstart),
				.pcs8gtxboundarysel(w_tx_pld_pcs_if_pcs8gtxboundarysel),
				.pcs8gtxdatavalid(w_tx_pld_pcs_if_pcs8gtxdatavalid),
				.pcs8gtxsynchdr(w_tx_pld_pcs_if_pcs8gtxsynchdr),
				.pcs8gtxurstpcs(w_tx_pld_pcs_if_pcs8gtxurstpcs),
				.pcs8gwrenabletx(w_tx_pld_pcs_if_pcs8gwrenabletx),
				.pcsgen3txrst(w_tx_pld_pcs_if_pcsgen3txrst),
				.pld10gtxburstenexe(w_tx_pld_pcs_if_pld10gtxburstenexe),
				.pld10gtxclkout(w_tx_pld_pcs_if_pld10gtxclkout),
				.pld10gtxempty(w_tx_pld_pcs_if_pld10gtxempty),
				.pld10gtxfifodel(w_tx_pld_pcs_if_pld10gtxfifodel),
				.pld10gtxfifoinsert(w_tx_pld_pcs_if_pld10gtxfifoinsert),
				.pld10gtxframe(w_tx_pld_pcs_if_pld10gtxframe),
				.pld10gtxfull(w_tx_pld_pcs_if_pld10gtxfull),
				.pld10gtxpempty(w_tx_pld_pcs_if_pld10gtxpempty),
				.pld10gtxpfull(w_tx_pld_pcs_if_pld10gtxpfull),
				.pld10gtxwordslipexe(w_tx_pld_pcs_if_pld10gtxwordslipexe),
				.pld8gemptytx(w_tx_pld_pcs_if_pld8gemptytx),
				.pld8gfulltx(w_tx_pld_pcs_if_pld8gfulltx),
				.pld8gtxclkout(w_tx_pld_pcs_if_pld8gtxclkout),
				.pldclkdiv33lc(w_tx_pld_pcs_if_pldclkdiv33lc),
				.pldlccmurstbout(w_tx_pld_pcs_if_pldlccmurstbout),
				.pldtxiqclkout(w_tx_pld_pcs_if_pldtxiqclkout),
				.pldtxpmasyncpfbkpout(w_tx_pld_pcs_if_pldtxpmasyncpfbkpout),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.clockinfrom10gpcs(w_pcs10g_tx_txclkout),
				.clockinfrom8gpcs(w_pcs8g_tx_clkout),
				.datainfrompld({in_pld_tx_data[63], in_pld_tx_data[62], in_pld_tx_data[61], in_pld_tx_data[60], in_pld_tx_data[59], in_pld_tx_data[58], in_pld_tx_data[57], in_pld_tx_data[56], in_pld_tx_data[55], in_pld_tx_data[54], in_pld_tx_data[53], in_pld_tx_data[52], in_pld_tx_data[51], in_pld_tx_data[50], in_pld_tx_data[49], in_pld_tx_data[48], in_pld_tx_data[47], in_pld_tx_data[46], in_pld_tx_data[45], in_pld_tx_data[44], in_pld_tx_data[43], in_pld_tx_data[42], in_pld_tx_data[41], in_pld_tx_data[40], in_pld_tx_data[39], in_pld_tx_data[38], in_pld_tx_data[37], in_pld_tx_data[36], in_pld_tx_data[35], in_pld_tx_data[34], in_pld_tx_data[33], in_pld_tx_data[32], in_pld_tx_data[31], in_pld_tx_data[30], in_pld_tx_data[29], in_pld_tx_data[28], in_pld_tx_data[27], in_pld_tx_data[26], in_pld_tx_data[25], in_pld_tx_data[24], in_pld_tx_data[23], in_pld_tx_data[22], in_pld_tx_data[21], in_pld_tx_data[20], in_pld_tx_data[19], in_pld_tx_data[18], in_pld_tx_data[17], in_pld_tx_data[16], in_pld_tx_data[15], in_pld_tx_data[14], in_pld_tx_data[13], in_pld_tx_data[12], in_pld_tx_data[11], in_pld_tx_data[10], in_pld_tx_data[9], in_pld_tx_data[8], in_pld_tx_data[7], in_pld_tx_data[6], in_pld_tx_data[5], in_pld_tx_data[4], in_pld_tx_data[3], in_pld_tx_data[2], in_pld_tx_data[1], in_pld_tx_data[0]}),
				.emsipenablediocsrrdydly(w_com_pld_pcs_if_emsipenablediocsrrdydly),
				.emsippcstxclkin({in_emsip_tx_clk_in[2], in_emsip_tx_clk_in[1], in_emsip_tx_clk_in[0]}),
				.emsiptxin({in_emsip_tx_in[103], in_emsip_tx_in[102], in_emsip_tx_in[101], in_emsip_tx_in[100], in_emsip_tx_in[99], in_emsip_tx_in[98], in_emsip_tx_in[97], in_emsip_tx_in[96], in_emsip_tx_in[95], in_emsip_tx_in[94], in_emsip_tx_in[93], in_emsip_tx_in[92], in_emsip_tx_in[91], in_emsip_tx_in[90], in_emsip_tx_in[89], in_emsip_tx_in[88], in_emsip_tx_in[87], in_emsip_tx_in[86], in_emsip_tx_in[85], in_emsip_tx_in[84], in_emsip_tx_in[83], in_emsip_tx_in[82], in_emsip_tx_in[81], in_emsip_tx_in[80], in_emsip_tx_in[79], in_emsip_tx_in[78], in_emsip_tx_in[77], in_emsip_tx_in[76], in_emsip_tx_in[75], in_emsip_tx_in[74], in_emsip_tx_in[73], in_emsip_tx_in[72], in_emsip_tx_in[71], in_emsip_tx_in[70], in_emsip_tx_in[69], in_emsip_tx_in[68], in_emsip_tx_in[67], in_emsip_tx_in[66], in_emsip_tx_in[65], in_emsip_tx_in[64], in_emsip_tx_in[63], in_emsip_tx_in[62], in_emsip_tx_in[61], in_emsip_tx_in[60], in_emsip_tx_in[59], in_emsip_tx_in[58], in_emsip_tx_in[57], in_emsip_tx_in[56], in_emsip_tx_in[55], in_emsip_tx_in[54], in_emsip_tx_in[53], in_emsip_tx_in[52], in_emsip_tx_in[51], in_emsip_tx_in[50], in_emsip_tx_in[49], in_emsip_tx_in[48], in_emsip_tx_in[47], in_emsip_tx_in[46], in_emsip_tx_in[45], in_emsip_tx_in[44], in_emsip_tx_in[43], in_emsip_tx_in[42], in_emsip_tx_in[41], in_emsip_tx_in[40], in_emsip_tx_in[39], in_emsip_tx_in[38], in_emsip_tx_in[37], in_emsip_tx_in[36], in_emsip_tx_in[35], in_emsip_tx_in[34], in_emsip_tx_in[33], in_emsip_tx_in[32], in_emsip_tx_in[31], in_emsip_tx_in[30], in_emsip_tx_in[29], in_emsip_tx_in[28], in_emsip_tx_in[27], in_emsip_tx_in[26], in_emsip_tx_in[25], in_emsip_tx_in[24], in_emsip_tx_in[23], in_emsip_tx_in[22], in_emsip_tx_in[21], in_emsip_tx_in[20], in_emsip_tx_in[19], in_emsip_tx_in[18], in_emsip_tx_in[17], in_emsip_tx_in[16], in_emsip_tx_in[15], in_emsip_tx_in[14], in_emsip_tx_in[13], in_emsip_tx_in[12], in_emsip_tx_in[11], in_emsip_tx_in[10], in_emsip_tx_in[9], in_emsip_tx_in[8], in_emsip_tx_in[7], in_emsip_tx_in[6], in_emsip_tx_in[5], in_emsip_tx_in[4], in_emsip_tx_in[3], in_emsip_tx_in[2], in_emsip_tx_in[1], in_emsip_tx_in[0]}),
				.emsiptxspecialin({in_emsip_tx_special_in[12], in_emsip_tx_special_in[11], in_emsip_tx_special_in[10], in_emsip_tx_special_in[9], in_emsip_tx_special_in[8], in_emsip_tx_special_in[7], in_emsip_tx_special_in[6], in_emsip_tx_special_in[5], in_emsip_tx_special_in[4], in_emsip_tx_special_in[3], in_emsip_tx_special_in[2], in_emsip_tx_special_in[1], in_emsip_tx_special_in[0]}),
				.pcs10gtxburstenexe(w_pcs10g_tx_txburstenexe),
				.pcs10gtxempty(w_pcs10g_tx_txfifoempty),
				.pcs10gtxfifodel(w_pcs10g_tx_txfifodel),
				.pcs10gtxfifoinsert(w_pcs10g_tx_txfifoinsert),
				.pcs10gtxframe(w_pcs10g_tx_txframe),
				.pcs10gtxfull(w_pcs10g_tx_txfifofull),
				.pcs10gtxpempty(w_pcs10g_tx_txfifopartialempty),
				.pcs10gtxpfull(w_pcs10g_tx_txfifopartialfull),
				.pcs10gtxwordslipexe(w_pcs10g_tx_txwordslipexe),
				.pcs8gemptytx(w_pcs8g_tx_phfifounderflow),
				.pcs8gfulltx(w_pcs8g_tx_phfifooverflow),
				.pld10gtxbitslip({in_pld_10g_tx_bitslip[6], in_pld_10g_tx_bitslip[5], in_pld_10g_tx_bitslip[4], in_pld_10g_tx_bitslip[3], in_pld_10g_tx_bitslip[2], in_pld_10g_tx_bitslip[1], in_pld_10g_tx_bitslip[0]}),
				.pld10gtxbursten(in_pld_10g_tx_burst_en),
				.pld10gtxcontrol({in_pld_10g_tx_control[8], in_pld_10g_tx_control[7], in_pld_10g_tx_control[6], in_pld_10g_tx_control[5], in_pld_10g_tx_control[4], in_pld_10g_tx_control[3], in_pld_10g_tx_control[2], in_pld_10g_tx_control[1], in_pld_10g_tx_control[0]}),
				.pld10gtxdatavalid(in_pld_10g_tx_data_valid),
				.pld10gtxdiagstatus({in_pld_10g_tx_diag_status[1], in_pld_10g_tx_diag_status[0]}),
				.pld10gtxpldclk(in_pld_10g_tx_pld_clk),
				.pld10gtxpldrstn(in_pld_10g_tx_rst_n),
				.pld10gtxwordslip(in_pld_10g_tx_wordslip),
				.pld8gphfifoursttxn(in_pld_8g_phfifourst_tx_n),
				.pld8gpldtxclk(in_pld_8g_pld_tx_clk),
				.pld8gpolinvtx(in_pld_8g_polinv_tx),
				.pld8grddisabletx(in_pld_8g_rddisable_tx),
				.pld8grevloopbk(in_pld_8g_rev_loopbk),
				.pld8gtxblkstart({in_pld_8g_tx_blk_start[3], in_pld_8g_tx_blk_start[2], in_pld_8g_tx_blk_start[1], in_pld_8g_tx_blk_start[0]}),
				.pld8gtxboundarysel({in_pld_8g_tx_boundary_sel[4], in_pld_8g_tx_boundary_sel[3], in_pld_8g_tx_boundary_sel[2], in_pld_8g_tx_boundary_sel[1], in_pld_8g_tx_boundary_sel[0]}),
				.pld8gtxdatavalid({in_pld_8g_tx_data_valid[3], in_pld_8g_tx_data_valid[2], in_pld_8g_tx_data_valid[1], in_pld_8g_tx_data_valid[0]}),
				.pld8gtxsynchdr({in_pld_8g_tx_sync_hdr[1], in_pld_8g_tx_sync_hdr[0]}),
				.pld8gtxurstpcsn(in_pld_8g_txurstpcs_n),
				.pld8gwrenabletx(in_pld_8g_wrenable_tx),
				.pldgen3txrstn(in_pld_gen3_tx_rstn),
				.pmaclkdiv33lc(w_tx_pcs_pma_if_pmaclkdiv33lcout),
				.pmatxcmuplllock(w_tx_pcs_pma_if_pmarxfreqtxcmuplllockout),
				.pmatxlcplllock(w_tx_pcs_pma_if_pmatxlcplllockout),
				.rstsel(w_com_pld_pcs_if_rstsel),
				.usrrstsel(w_com_pld_pcs_if_usrrstsel),
				.asynchdatain(/*unused*/),
				.pcsgen3txrstn(/*unused*/),
				.reset(/*unused*/)
			);
		end // if generate
		else begin
				assign w_tx_pld_pcs_if_avmmreaddata[15:0] = 16'b0;
				assign w_tx_pld_pcs_if_blockselect = 1'b0;
				assign w_tx_pld_pcs_if_dataoutto10gpcs[63:0] = 64'b0;
				assign w_tx_pld_pcs_if_dataoutto8gpcs[43:0] = 44'b0;
				assign w_tx_pld_pcs_if_emsippcstxclkout[2:0] = 3'b0;
				assign w_tx_pld_pcs_if_emsiptxout[11:0] = 12'b0;
				assign w_tx_pld_pcs_if_emsiptxspecialout[15:0] = 16'b0;
				assign w_tx_pld_pcs_if_pcs10gtxbitslip[6:0] = 7'b0;
				assign w_tx_pld_pcs_if_pcs10gtxbursten = 1'b0;
				assign w_tx_pld_pcs_if_pcs10gtxcontrol[8:0] = 9'b0;
				assign w_tx_pld_pcs_if_pcs10gtxdatavalid = 1'b0;
				assign w_tx_pld_pcs_if_pcs10gtxdiagstatus[1:0] = 2'b0;
				assign w_tx_pld_pcs_if_pcs10gtxpldclk = 1'b0;
				assign w_tx_pld_pcs_if_pcs10gtxpldrstn = 1'b0;
				assign w_tx_pld_pcs_if_pcs10gtxwordslip = 1'b0;
				assign w_tx_pld_pcs_if_pcs8gphfifoursttx = 1'b0;
				assign w_tx_pld_pcs_if_pcs8gpldtxclk = 1'b0;
				assign w_tx_pld_pcs_if_pcs8gpolinvtx = 1'b0;
				assign w_tx_pld_pcs_if_pcs8grddisabletx = 1'b0;
				assign w_tx_pld_pcs_if_pcs8grevloopbk = 1'b0;
				assign w_tx_pld_pcs_if_pcs8gtxblkstart[3:0] = 4'b0;
				assign w_tx_pld_pcs_if_pcs8gtxboundarysel[4:0] = 5'b0;
				assign w_tx_pld_pcs_if_pcs8gtxdatavalid[3:0] = 4'b0;
				assign w_tx_pld_pcs_if_pcs8gtxsynchdr[1:0] = 2'b0;
				assign w_tx_pld_pcs_if_pcs8gtxurstpcs = 1'b0;
				assign w_tx_pld_pcs_if_pcs8gwrenabletx = 1'b0;
				assign w_tx_pld_pcs_if_pcsgen3txrst = 1'b0;
				assign w_tx_pld_pcs_if_pld10gtxburstenexe = 1'b0;
				assign w_tx_pld_pcs_if_pld10gtxclkout = 1'b0;
				assign w_tx_pld_pcs_if_pld10gtxempty = 1'b0;
				assign w_tx_pld_pcs_if_pld10gtxfifodel = 1'b0;
				assign w_tx_pld_pcs_if_pld10gtxfifoinsert = 1'b0;
				assign w_tx_pld_pcs_if_pld10gtxframe = 1'b0;
				assign w_tx_pld_pcs_if_pld10gtxfull = 1'b0;
				assign w_tx_pld_pcs_if_pld10gtxpempty = 1'b0;
				assign w_tx_pld_pcs_if_pld10gtxpfull = 1'b0;
				assign w_tx_pld_pcs_if_pld10gtxwordslipexe = 1'b0;
				assign w_tx_pld_pcs_if_pld8gemptytx = 1'b0;
				assign w_tx_pld_pcs_if_pld8gfulltx = 1'b0;
				assign w_tx_pld_pcs_if_pld8gtxclkout = 1'b0;
				assign w_tx_pld_pcs_if_pldclkdiv33lc = 1'b0;
				assign w_tx_pld_pcs_if_pldlccmurstbout = 1'b0;
				assign w_tx_pld_pcs_if_pldtxiqclkout = 1'b0;
				assign w_tx_pld_pcs_if_pldtxpmasyncpfbkpout = 1'b0;
		end // if not generate
		
		// instantiating sv_hssi_10g_tx_pcs
		if ((enable_10g_tx == "true") || (enable_dyn_reconfig == "true")) begin
			sv_hssi_10g_tx_pcs_rbc #(
				.bit_reverse(pcs10g_tx_bit_reverse),
				.bitslip_en(pcs10g_tx_bitslip_en),
				.channel_number(channel_number),
				.comp_cnt(pcs10g_tx_comp_cnt),
				//.comp_del_sel_agg(pcs10g_tx_comp_del_sel_agg),
				.compin_sel(pcs10g_tx_compin_sel),
				.compin_sel_agg(pcs10g_tx_compin_sel_agg),
				.crcgen_bypass(pcs10g_tx_crcgen_bypass),
				.crcgen_clken(pcs10g_tx_crcgen_clken),
				.crcgen_err(pcs10g_tx_crcgen_err),
				.crcgen_init(pcs10g_tx_crcgen_init),
				.crcgen_init_user(pcs10g_tx_crcgen_init_user),
				.crcgen_inv(pcs10g_tx_crcgen_inv),
				.ctrl_bit_reverse(pcs10g_tx_ctrl_bit_reverse),
				.ctrl_plane_bonding(pcs10g_tx_ctrl_plane_bonding),
				.data_agg_bonding(pcs10g_tx_data_agg_bonding),
				.data_agg_comp(pcs10g_tx_data_agg_comp),
				.data_bit_reverse(pcs10g_tx_data_bit_reverse),
				.del_sel_frame_gen(pcs10g_tx_del_sel_frame_gen),
				.dispgen_bypass(pcs10g_tx_dispgen_bypass),
				.dispgen_clken(pcs10g_tx_dispgen_clken),
				.dispgen_err(pcs10g_tx_dispgen_err),
				.dispgen_pipeln(pcs10g_tx_dispgen_pipeln),
				.distdwn_bypass_pipeln(pcs10g_tx_distdwn_bypass_pipeln),
				.distdwn_bypass_pipeln_agg(pcs10g_tx_distdwn_bypass_pipeln_agg),
				.distdwn_master(pcs10g_tx_distdwn_master),
				.distdwn_master_agg(pcs10g_tx_distdwn_master_agg),
				.distup_bypass_pipeln(pcs10g_tx_distup_bypass_pipeln),
				.distup_bypass_pipeln_agg(pcs10g_tx_distup_bypass_pipeln_agg),
				.distup_master(pcs10g_tx_distup_master),
				.distup_master_agg(pcs10g_tx_distup_master_agg),
				.empty_flag_type(pcs10g_tx_empty_flag_type),
				.enc64b66b_txsm_clken(pcs10g_tx_enc64b66b_txsm_clken),
				.enc_64b66b_txsm_bypass(pcs10g_tx_enc_64b66b_txsm_bypass),
				.fastpath(pcs10g_tx_fastpath),
				.fifo_stop_rd(pcs10g_tx_fifo_stop_rd),
				.fifo_stop_wr(pcs10g_tx_fifo_stop_wr),
				.frmgen_burst(pcs10g_tx_frmgen_burst),
				.frmgen_bypass(pcs10g_tx_frmgen_bypass),
				.frmgen_clken(pcs10g_tx_frmgen_clken),
				.frmgen_diag_word(pcs10g_tx_frmgen_diag_word),
				.frmgen_mfrm_length(pcs10g_tx_frmgen_mfrm_length),
				.frmgen_mfrm_length_user(pcs10g_tx_frmgen_mfrm_length_user),
				.frmgen_pipeln(pcs10g_tx_frmgen_pipeln),
				.frmgen_pyld_ins(pcs10g_tx_frmgen_pyld_ins),
				.frmgen_scrm_word(pcs10g_tx_frmgen_scrm_word),
				.frmgen_skip_word(pcs10g_tx_frmgen_skip_word),
				.frmgen_sync_word(pcs10g_tx_frmgen_sync_word),
				.frmgen_wordslip(pcs10g_tx_frmgen_wordslip),
				.full_flag_type(pcs10g_tx_full_flag_type),
				.gb_sel_mode(pcs10g_tx_gb_sel_mode),
				.gb_tx_idwidth(pcs10g_tx_gb_tx_idwidth),
				.gb_tx_odwidth(pcs10g_tx_gb_tx_odwidth),
				.gbred_clken(pcs10g_tx_gbred_clken),
				.indv(pcs10g_tx_indv),
				.iqtxrx_clkout_sel(pcs10g_tx_iqtxrx_clkout_sel),
				.master_clk_sel(pcs10g_tx_master_clk_sel),
				.pempty_flag_type(pcs10g_tx_pempty_flag_type),
				.pfull_flag_type(pcs10g_tx_pfull_flag_type),
				.phcomp_rd_del(pcs10g_tx_phcomp_rd_del),
				.pmagate_en(pcs10g_tx_pmagate_en),
				.prbs_clken(pcs10g_tx_prbs_clken),
				.prot_mode(pcs10g_tx_prot_mode),
				.pseudo_random(pcs10g_tx_pseudo_random),
				.pseudo_seed_a(pcs10g_tx_pseudo_seed_a),
				.pseudo_seed_a_user(pcs10g_tx_pseudo_seed_a_user),
				.pseudo_seed_b(pcs10g_tx_pseudo_seed_b),
				.pseudo_seed_b_user(pcs10g_tx_pseudo_seed_b_user),
				.rdfifo_clken(pcs10g_tx_rdfifo_clken),
				.scrm_bypass(pcs10g_tx_scrm_bypass),
				.scrm_clken(pcs10g_tx_scrm_clken),
				.scrm_mode(pcs10g_tx_scrm_mode),
				.scrm_seed(pcs10g_tx_scrm_seed),
				.scrm_seed_user(pcs10g_tx_scrm_seed_user),
				.sh_err(pcs10g_tx_sh_err),
				.skip_ctrl(pcs10g_tx_skip_ctrl),
				.sq_wave(pcs10g_tx_sq_wave),
				.sqwgen_clken(pcs10g_tx_sqwgen_clken),
				.stretch_en(pcs10g_tx_stretch_en),
				.stretch_num_stages(pcs10g_tx_stretch_num_stages),
				.stretch_type(pcs10g_tx_stretch_type),
				.sup_mode(pcs10g_tx_sup_mode),
				.test_bus_mode(pcs10g_tx_test_bus_mode),
				.test_mode(pcs10g_tx_test_mode),
				.tx_polarity_inv(pcs10g_tx_tx_polarity_inv),
				.tx_scrm_err(pcs10g_tx_tx_scrm_err),
				.tx_scrm_width(pcs10g_tx_tx_scrm_width),
				.tx_sh_location(pcs10g_tx_tx_sh_location),
				.tx_sm_bypass(pcs10g_tx_tx_sm_bypass),
				.tx_sm_pipeln(pcs10g_tx_tx_sm_pipeln),
				.tx_testbus_sel(pcs10g_tx_tx_testbus_sel),
				.tx_true_b2b(pcs10g_tx_tx_true_b2b),
				.txfifo_empty(pcs10g_tx_txfifo_empty),
				.txfifo_full(pcs10g_tx_txfifo_full),
				.txfifo_mode(pcs10g_tx_txfifo_mode),
				.txfifo_pempty(pcs10g_tx_txfifo_pempty),
				.txfifo_pfull(pcs10g_tx_txfifo_pfull),
				.use_default_base_address(pcs10g_tx_use_default_base_address),
				.user_base_address(pcs10g_tx_user_base_address),
				.wr_clk_sel(pcs10g_tx_wr_clk_sel),
				.wrfifo_clken(pcs10g_tx_wrfifo_clken)
			) inst_sv_hssi_10g_tx_pcs (
				// OUTPUTS
				.avmmreaddata(w_pcs10g_tx_avmmreaddata),
				.blockselect(w_pcs10g_tx_blockselect),
				.dfxlpbkcontrolout(w_pcs10g_tx_dfxlpbkcontrolout),
				.dfxlpbkdataout(w_pcs10g_tx_dfxlpbkdataout),
				.dfxlpbkdatavalidout(w_pcs10g_tx_dfxlpbkdatavalidout),
				.distdwnoutdv(w_pcs10g_tx_distdwnoutdv),
				.distdwnoutintlknrden(w_pcs10g_tx_distdwnoutintlknrden),
				.distdwnoutrden(w_pcs10g_tx_distdwnoutrden),
				.distdwnoutrdpfull(w_pcs10g_tx_distdwnoutrdpfull),
				.distdwnoutwren(w_pcs10g_tx_distdwnoutwren),
				.distupoutdv(w_pcs10g_tx_distupoutdv),
				.distupoutintlknrden(w_pcs10g_tx_distupoutintlknrden),
				.distupoutrden(w_pcs10g_tx_distupoutrden),
				.distupoutrdpfull(w_pcs10g_tx_distupoutrdpfull),
				.distupoutwren(w_pcs10g_tx_distupoutwren),
				.lpbkdataout(w_pcs10g_tx_lpbkdataout),
				.txburstenexe(w_pcs10g_tx_txburstenexe),
				.txclkiqout(w_pcs10g_tx_txclkiqout),
				.txclkout(w_pcs10g_tx_txclkout),
				.txfifodel(w_pcs10g_tx_txfifodel),
				.txfifoempty(w_pcs10g_tx_txfifoempty),
				.txfifofull(w_pcs10g_tx_txfifofull),
				.txfifoinsert(w_pcs10g_tx_txfifoinsert),
				.txfifopartialempty(w_pcs10g_tx_txfifopartialempty),
				.txfifopartialfull(w_pcs10g_tx_txfifopartialfull),
				.txframe(w_pcs10g_tx_txframe),
				.txpmadata(w_pcs10g_tx_txpmadata),
				.txwordslipexe(w_pcs10g_tx_txwordslipexe),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.distdwnindv(in_pcs_10g_distdwn_in_dv),
				.distdwninintlknrden(in_pcs_10g_bundling_in_down[0]),
				.distdwninrden(in_pcs_10g_distdwn_in_rden),
				.distdwninrdpfull(in_pcs_10g_bundling_in_down[1]),
				.distdwninwren(in_pcs_10g_distdwn_in_wren),
				.distupindv(in_pcs_10g_distup_in_dv),
				.distupinintlknrden(in_pcs_10g_bundling_in_up[0]),
				.distupinrden(in_pcs_10g_distup_in_rden),
				.distupinrdpfull(in_pcs_10g_bundling_in_up[1]),
				.distupinwren(in_pcs_10g_distup_in_wren),
				.hardresetn(w_com_pld_pcs_if_pcs10ghardreset),
				.pmaclkdiv33lc(w_tx_pcs_pma_if_pcs10gclkdiv33lc),
				.refclkdig(w_com_pld_pcs_if_pcs10grefclkdig),
				.txbitslip({w_tx_pld_pcs_if_pcs10gtxbitslip[6], w_tx_pld_pcs_if_pcs10gtxbitslip[5], w_tx_pld_pcs_if_pcs10gtxbitslip[4], w_tx_pld_pcs_if_pcs10gtxbitslip[3], w_tx_pld_pcs_if_pcs10gtxbitslip[2], w_tx_pld_pcs_if_pcs10gtxbitslip[1], w_tx_pld_pcs_if_pcs10gtxbitslip[0]}),
				.txbursten(w_tx_pld_pcs_if_pcs10gtxbursten),
				.txcontrol({w_tx_pld_pcs_if_pcs10gtxcontrol[8], w_tx_pld_pcs_if_pcs10gtxcontrol[7], w_tx_pld_pcs_if_pcs10gtxcontrol[6], w_tx_pld_pcs_if_pcs10gtxcontrol[5], w_tx_pld_pcs_if_pcs10gtxcontrol[4], w_tx_pld_pcs_if_pcs10gtxcontrol[3], w_tx_pld_pcs_if_pcs10gtxcontrol[2], w_tx_pld_pcs_if_pcs10gtxcontrol[1], w_tx_pld_pcs_if_pcs10gtxcontrol[0]}),
				.txdata({w_tx_pld_pcs_if_dataoutto10gpcs[63], w_tx_pld_pcs_if_dataoutto10gpcs[62], w_tx_pld_pcs_if_dataoutto10gpcs[61], w_tx_pld_pcs_if_dataoutto10gpcs[60], w_tx_pld_pcs_if_dataoutto10gpcs[59], w_tx_pld_pcs_if_dataoutto10gpcs[58], w_tx_pld_pcs_if_dataoutto10gpcs[57], w_tx_pld_pcs_if_dataoutto10gpcs[56], w_tx_pld_pcs_if_dataoutto10gpcs[55], w_tx_pld_pcs_if_dataoutto10gpcs[54], w_tx_pld_pcs_if_dataoutto10gpcs[53], w_tx_pld_pcs_if_dataoutto10gpcs[52], w_tx_pld_pcs_if_dataoutto10gpcs[51], w_tx_pld_pcs_if_dataoutto10gpcs[50], w_tx_pld_pcs_if_dataoutto10gpcs[49], w_tx_pld_pcs_if_dataoutto10gpcs[48], w_tx_pld_pcs_if_dataoutto10gpcs[47], w_tx_pld_pcs_if_dataoutto10gpcs[46], w_tx_pld_pcs_if_dataoutto10gpcs[45], w_tx_pld_pcs_if_dataoutto10gpcs[44], w_tx_pld_pcs_if_dataoutto10gpcs[43], w_tx_pld_pcs_if_dataoutto10gpcs[42], w_tx_pld_pcs_if_dataoutto10gpcs[41], w_tx_pld_pcs_if_dataoutto10gpcs[40], w_tx_pld_pcs_if_dataoutto10gpcs[39], w_tx_pld_pcs_if_dataoutto10gpcs[38], w_tx_pld_pcs_if_dataoutto10gpcs[37], w_tx_pld_pcs_if_dataoutto10gpcs[36], w_tx_pld_pcs_if_dataoutto10gpcs[35], w_tx_pld_pcs_if_dataoutto10gpcs[34], w_tx_pld_pcs_if_dataoutto10gpcs[33], w_tx_pld_pcs_if_dataoutto10gpcs[32], w_tx_pld_pcs_if_dataoutto10gpcs[31], w_tx_pld_pcs_if_dataoutto10gpcs[30], w_tx_pld_pcs_if_dataoutto10gpcs[29], w_tx_pld_pcs_if_dataoutto10gpcs[28], w_tx_pld_pcs_if_dataoutto10gpcs[27], w_tx_pld_pcs_if_dataoutto10gpcs[26], w_tx_pld_pcs_if_dataoutto10gpcs[25], w_tx_pld_pcs_if_dataoutto10gpcs[24], w_tx_pld_pcs_if_dataoutto10gpcs[23], w_tx_pld_pcs_if_dataoutto10gpcs[22], w_tx_pld_pcs_if_dataoutto10gpcs[21], w_tx_pld_pcs_if_dataoutto10gpcs[20], w_tx_pld_pcs_if_dataoutto10gpcs[19], w_tx_pld_pcs_if_dataoutto10gpcs[18], w_tx_pld_pcs_if_dataoutto10gpcs[17], w_tx_pld_pcs_if_dataoutto10gpcs[16], w_tx_pld_pcs_if_dataoutto10gpcs[15], w_tx_pld_pcs_if_dataoutto10gpcs[14], w_tx_pld_pcs_if_dataoutto10gpcs[13], w_tx_pld_pcs_if_dataoutto10gpcs[12], w_tx_pld_pcs_if_dataoutto10gpcs[11], w_tx_pld_pcs_if_dataoutto10gpcs[10], w_tx_pld_pcs_if_dataoutto10gpcs[9], w_tx_pld_pcs_if_dataoutto10gpcs[8], w_tx_pld_pcs_if_dataoutto10gpcs[7], w_tx_pld_pcs_if_dataoutto10gpcs[6], w_tx_pld_pcs_if_dataoutto10gpcs[5], w_tx_pld_pcs_if_dataoutto10gpcs[4], w_tx_pld_pcs_if_dataoutto10gpcs[3], w_tx_pld_pcs_if_dataoutto10gpcs[2], w_tx_pld_pcs_if_dataoutto10gpcs[1], w_tx_pld_pcs_if_dataoutto10gpcs[0]}),
				.txdatavalid(w_tx_pld_pcs_if_pcs10gtxdatavalid),
				.txdiagnosticstatus({w_tx_pld_pcs_if_pcs10gtxdiagstatus[1], w_tx_pld_pcs_if_pcs10gtxdiagstatus[0]}),		                
				.txdisparityclr( /*unused*/),
				.txpldclk(w_tx_pld_pcs_if_pcs10gtxpldclk),
				.txpldrstn(w_tx_pld_pcs_if_pcs10gtxpldrstn),
				.txpmaclk(w_tx_pcs_pma_if_clockoutto10gpcs),
				.txwordslip(w_tx_pld_pcs_if_pcs10gtxwordslip),
                .syncdatain( /*unused*/ )
			);
		end // if generate
		else begin
				assign w_pcs10g_tx_avmmreaddata[15:0] = 16'b0;
				assign w_pcs10g_tx_blockselect = 1'b0;
				assign w_pcs10g_tx_dfxlpbkcontrolout[8:0] = 9'b0;
				assign w_pcs10g_tx_dfxlpbkdataout[63:0] = 64'b0;
				assign w_pcs10g_tx_dfxlpbkdatavalidout = 1'b0;
				assign w_pcs10g_tx_distdwnoutdv = 1'b0;
				assign w_pcs10g_tx_distdwnoutintlknrden = 1'b0;
				assign w_pcs10g_tx_distdwnoutrden = 1'b0;
				assign w_pcs10g_tx_distdwnoutrdpfull = 1'b0;
				assign w_pcs10g_tx_distdwnoutwren = 1'b0;
				assign w_pcs10g_tx_distupoutdv = 1'b0;
				assign w_pcs10g_tx_distupoutintlknrden = 1'b0;
				assign w_pcs10g_tx_distupoutrden = 1'b0;
				assign w_pcs10g_tx_distupoutrdpfull = 1'b0;
				assign w_pcs10g_tx_distupoutwren = 1'b0;
				assign w_pcs10g_tx_lpbkdataout[79:0] = 80'b0;
				assign w_pcs10g_tx_txburstenexe = 1'b0;
				assign w_pcs10g_tx_txclkiqout = 1'b0;
				assign w_pcs10g_tx_txclkout = 1'b0;
				assign w_pcs10g_tx_txfifodel = 1'b0;
				assign w_pcs10g_tx_txfifoempty = 1'b0;
				assign w_pcs10g_tx_txfifofull = 1'b0;
				assign w_pcs10g_tx_txfifoinsert = 1'b0;
				assign w_pcs10g_tx_txfifopartialempty = 1'b0;
				assign w_pcs10g_tx_txfifopartialfull = 1'b0;
				assign w_pcs10g_tx_txframe = 1'b0;
				assign w_pcs10g_tx_txpmadata[79:0] = 80'b0;
				assign w_pcs10g_tx_txwordslipexe = 1'b0;
		end // if not generate
		
		// instantiating sv_hssi_8g_rx_pcs
		if ((enable_8g_rx == "true") || (enable_dyn_reconfig == "true")) begin
			sv_hssi_8g_rx_pcs_rbc #(
				.agg_block_sel(pcs8g_rx_agg_block_sel),
				.auto_deassert_pc_rst_cnt_data(pcs8g_rx_auto_deassert_pc_rst_cnt_data),
				.auto_error_replacement(pcs8g_rx_auto_error_replacement),
				.auto_pc_en_cnt_data(pcs8g_rx_auto_pc_en_cnt_data),
				.auto_speed_nego(pcs8g_rx_auto_speed_nego),
				.bist_ver(pcs8g_rx_bist_ver),
				.bist_ver_clr_flag(pcs8g_rx_bist_ver_clr_flag),
				.bit_reversal(pcs8g_rx_bit_reversal),
				.bo_pad(pcs8g_rx_bo_pad),
				.bo_pattern(pcs8g_rx_bo_pattern),
				.bypass_pipeline_reg(pcs8g_rx_bypass_pipeline_reg),
				.byte_deserializer(pcs8g_rx_byte_deserializer),
				.byte_order(pcs8g_rx_byte_order),
				.cdr_ctrl(pcs8g_rx_cdr_ctrl),
				.cdr_ctrl_rxvalid_mask(pcs8g_rx_cdr_ctrl_rxvalid_mask),
				.channel_number(channel_number),
				.cid_pattern(pcs8g_rx_cid_pattern),
				.cid_pattern_len(pcs8g_rx_cid_pattern_len),
				.clkcmp_pattern_n(pcs8g_rx_clkcmp_pattern_n),
				.clkcmp_pattern_p(pcs8g_rx_clkcmp_pattern_p),
				.clock_gate_bds_dec_asn(pcs8g_rx_clock_gate_bds_dec_asn),
				.clock_gate_bist(pcs8g_rx_clock_gate_bist),
				.clock_gate_byteorder(pcs8g_rx_clock_gate_byteorder),
				.clock_gate_cdr_eidle(pcs8g_rx_clock_gate_cdr_eidle),
				.clock_gate_dskw_rd(pcs8g_rx_clock_gate_dskw_rd),
				.clock_gate_dw_dskw_wr(pcs8g_rx_clock_gate_dw_dskw_wr),
				.clock_gate_dw_pc_wrclk(pcs8g_rx_clock_gate_dw_pc_wrclk),
				.clock_gate_dw_rm_rd(pcs8g_rx_clock_gate_dw_rm_rd),
				.clock_gate_dw_rm_wr(pcs8g_rx_clock_gate_dw_rm_wr),
				.clock_gate_dw_wa(pcs8g_rx_clock_gate_dw_wa),
				.clock_gate_pc_rdclk(pcs8g_rx_clock_gate_pc_rdclk),
				.clock_gate_prbs(pcs8g_rx_clock_gate_prbs),
				.clock_gate_sw_dskw_wr(pcs8g_rx_clock_gate_sw_dskw_wr),
				.clock_gate_sw_pc_wrclk(pcs8g_rx_clock_gate_sw_pc_wrclk),
				.clock_gate_sw_rm_rd(pcs8g_rx_clock_gate_sw_rm_rd),
				.clock_gate_sw_rm_wr(pcs8g_rx_clock_gate_sw_rm_wr),
				.clock_gate_sw_wa(pcs8g_rx_clock_gate_sw_wa),
				.comp_fifo_rst_pld_ctrl(pcs8g_rx_comp_fifo_rst_pld_ctrl),
				.ctrl_plane_bonding_compensation(pcs8g_rx_ctrl_plane_bonding_compensation),
				.ctrl_plane_bonding_consumption(pcs8g_rx_ctrl_plane_bonding_consumption),
				.ctrl_plane_bonding_distribution(pcs8g_rx_ctrl_plane_bonding_distribution),
				.deskew(pcs8g_rx_deskew),
				.deskew_pattern(pcs8g_rx_deskew_pattern),
				.deskew_prog_pattern_only(pcs8g_rx_deskew_prog_pattern_only),
				.dw_one_or_two_symbol_bo(pcs8g_rx_dw_one_or_two_symbol_bo),
				.eidle_entry_eios(pcs8g_rx_eidle_entry_eios),
				.eidle_entry_iei(pcs8g_rx_eidle_entry_iei),
				.eidle_entry_sd(pcs8g_rx_eidle_entry_sd),
				.eightb_tenb_decoder(pcs8g_rx_eightb_tenb_decoder),
				.eightbtenb_decoder_output_sel(pcs8g_rx_eightbtenb_decoder_output_sel),
				.err_flags_sel(pcs8g_rx_err_flags_sel),
				.fixed_pat_det(pcs8g_rx_fixed_pat_det),
				.fixed_pat_num(pcs8g_rx_fixed_pat_num),
				.force_signal_detect(pcs8g_rx_force_signal_detect),
				.hip_mode(pcs8g_rx_hip_mode),
				.ibm_invalid_code(pcs8g_rx_ibm_invalid_code),
				.invalid_code_flag_only(pcs8g_rx_invalid_code_flag_only),
				.mask_cnt(pcs8g_rx_mask_cnt),
				.pad_or_edb_error_replace(pcs8g_rx_pad_or_edb_error_replace),
				.pc_fifo_rst_pld_ctrl(pcs8g_rx_pc_fifo_rst_pld_ctrl),
				.pcs_bypass(pcs8g_rx_pcs_bypass),
				.phase_compensation_fifo(pcs8g_rx_phase_compensation_fifo),
				.pipe_if_enable(pcs8g_rx_pipe_if_enable),
				.pma_done_count(pcs8g_rx_pma_done_count),
				.pma_dw(pcs8g_rx_pma_dw),
				.polarity_inversion(pcs8g_rx_polarity_inversion),
				.polinv_8b10b_dec(pcs8g_rx_polinv_8b10b_dec),
				.prbs_ver(pcs8g_rx_prbs_ver),
				.prbs_ver_clr_flag(pcs8g_rx_prbs_ver_clr_flag),
				.prot_mode(pcs8g_rx_prot_mode),
				.rate_match(pcs8g_rx_rate_match),
				.re_bo_on_wa(pcs8g_rx_re_bo_on_wa),
				.runlength_check(pcs8g_rx_runlength_check),
				.runlength_val(pcs8g_rx_runlength_val),
				.rx_clk1(pcs8g_rx_rx_clk1),
				.rx_clk2(pcs8g_rx_rx_clk2),
				.rx_clk_free_running(pcs8g_rx_rx_clk_free_running),
				.rx_pcs_urst(pcs8g_rx_rx_pcs_urst),
				.rx_rcvd_clk(pcs8g_rx_rx_rcvd_clk),
				.rx_rd_clk(pcs8g_rx_rx_rd_clk),
				.rx_refclk(pcs8g_rx_rx_refclk),
				.rx_wr_clk(pcs8g_rx_rx_wr_clk),
				.sup_mode(pcs8g_rx_sup_mode),
				.symbol_swap(pcs8g_rx_symbol_swap),
				.test_bus_sel(pcs8g_rx_test_bus_sel),
				.test_mode(pcs8g_rx_test_mode),
				.tx_rx_parallel_loopback(pcs8g_rx_tx_rx_parallel_loopback),
				.use_default_base_address(pcs8g_rx_use_default_base_address),
				.user_base_address(pcs8g_rx_user_base_address),
				.wa_boundary_lock_ctrl(pcs8g_rx_wa_boundary_lock_ctrl),
				.wa_clk_slip_spacing(pcs8g_rx_wa_clk_slip_spacing),
				.wa_clk_slip_spacing_data(pcs8g_rx_wa_clk_slip_spacing_data),
				.wa_det_latency_sync_status_beh(pcs8g_rx_wa_det_latency_sync_status_beh),
				.wa_disp_err_flag(pcs8g_rx_wa_disp_err_flag),
				.wa_kchar(pcs8g_rx_wa_kchar),
				.wa_pd(pcs8g_rx_wa_pd),
				.wa_pd_data(pcs8g_rx_wa_pd_data),
				.wa_pd_polarity(pcs8g_rx_wa_pd_polarity),
				.wa_pld_controlled(pcs8g_rx_wa_pld_controlled),
				.wa_renumber_data(pcs8g_rx_wa_renumber_data),
				.wa_rgnumber_data(pcs8g_rx_wa_rgnumber_data),
				.wa_rknumber_data(pcs8g_rx_wa_rknumber_data),
				.wa_rosnumber_data(pcs8g_rx_wa_rosnumber_data),
				.wa_rvnumber_data(pcs8g_rx_wa_rvnumber_data),
				.wa_sync_sm_ctrl(pcs8g_rx_wa_sync_sm_ctrl),
				.wait_cnt(pcs8g_rx_wait_cnt),
				.wait_for_phfifo_cnt_data(pcs8g_rx_wait_for_phfifo_cnt_data)
			) inst_sv_hssi_8g_rx_pcs (
				// OUTPUTS
				.a1a2k1k2flag(w_pcs8g_rx_a1a2k1k2flag),
				.aggrxpcsrst(w_pcs8g_rx_aggrxpcsrst),
				.aligndetsync(w_pcs8g_rx_aligndetsync),
				.alignstatuspld(w_pcs8g_rx_alignstatuspld),
				.alignstatussync(w_pcs8g_rx_alignstatussync),
				.avmmreaddata(w_pcs8g_rx_avmmreaddata),
				.bistdone(w_pcs8g_rx_bistdone),
				.bisterr(w_pcs8g_rx_bisterr),
				.blockselect(w_pcs8g_rx_blockselect),
				.byteordflag(w_pcs8g_rx_byteordflag),
				.cgcomprddout(w_pcs8g_rx_cgcomprddout),
				.cgcompwrout(w_pcs8g_rx_cgcompwrout),
				.channeltestbusout(w_pcs8g_rx_channeltestbusout),
				.clocktopld(w_pcs8g_rx_clocktopld),
				.configseloutchnldown(w_pcs8g_rx_configseloutchnldown),
				.configseloutchnlup(w_pcs8g_rx_configseloutchnlup),
				.dataout(w_pcs8g_rx_dataout),
				.decoderctrl(w_pcs8g_rx_decoderctrl),
				.decoderdata(w_pcs8g_rx_decoderdata),
				.decoderdatavalid(w_pcs8g_rx_decoderdatavalid),
				.delcondmetout(w_pcs8g_rx_delcondmetout),
				.disablepcfifobyteserdes(w_pcs8g_rx_disablepcfifobyteserdes),
				.earlyeios(w_pcs8g_rx_earlyeios),
				.eidledetected(w_pcs8g_rx_eidledetected),
				.eidleexit(w_pcs8g_rx_eidleexit),
				.fifoovrout(w_pcs8g_rx_fifoovrout),
				.fifordoutcomp(w_pcs8g_rx_fifordoutcomp),
				.insertincompleteout(w_pcs8g_rx_insertincompleteout),
				.latencycompout(w_pcs8g_rx_latencycompout),
				.ltr(w_pcs8g_rx_ltr),
				.parallelrevloopback(w_pcs8g_rx_parallelrevloopback),
				.pcfifoempty(w_pcs8g_rx_pcfifoempty),
				.pcfifofull(w_pcs8g_rx_pcfifofull),
				.pcieswitch(w_pcs8g_rx_pcieswitch),
				.phystatus(w_pcs8g_rx_phystatus),
				.pipedata(w_pcs8g_rx_pipedata),
				.rdalign(w_pcs8g_rx_rdalign),
				.rdenableoutchnldown(w_pcs8g_rx_rdenableoutchnldown),
				.rdenableoutchnlup(w_pcs8g_rx_rdenableoutchnlup),
				.resetpcptrs(w_pcs8g_rx_resetpcptrs),
				.resetpcptrsinchnldownpipe(w_pcs8g_rx_resetpcptrsinchnldownpipe),
				.resetpcptrsinchnluppipe(w_pcs8g_rx_resetpcptrsinchnluppipe),
				.resetpcptrsoutchnldown(w_pcs8g_rx_resetpcptrsoutchnldown),
				.resetpcptrsoutchnlup(w_pcs8g_rx_resetpcptrsoutchnlup),
				.resetppmcntrsoutchnldown(w_pcs8g_rx_resetppmcntrsoutchnldown),
				.resetppmcntrsoutchnlup(w_pcs8g_rx_resetppmcntrsoutchnlup),
				.resetppmcntrspcspma(w_pcs8g_rx_resetppmcntrspcspma),
				.rlvlt(w_pcs8g_rx_rlvlt),
				.rmfifoempty(w_pcs8g_rx_rmfifoempty),
				.rmfifofull(w_pcs8g_rx_rmfifofull),
				.runningdisparity(w_pcs8g_rx_runningdisparity),
				.rxblkstart(w_pcs8g_rx_rxblkstart),
				.rxclkoutgen3(w_pcs8g_rx_rxclkoutgen3),
				.rxclkslip(w_pcs8g_rx_rxclkslip),
				.rxdatavalid(w_pcs8g_rx_rxdatavalid),
				.rxdivsyncoutchnldown(w_pcs8g_rx_rxdivsyncoutchnldown),
				.rxdivsyncoutchnlup(w_pcs8g_rx_rxdivsyncoutchnlup),
				.rxpipeclk(w_pcs8g_rx_rxpipeclk),
				.rxpipesoftreset(w_pcs8g_rx_rxpipesoftreset),
				.rxstatus(w_pcs8g_rx_rxstatus),
				.rxsynchdr(w_pcs8g_rx_rxsynchdr),
				.rxvalid(w_pcs8g_rx_rxvalid),
				.rxweoutchnldown(w_pcs8g_rx_rxweoutchnldown),
				.rxweoutchnlup(w_pcs8g_rx_rxweoutchnlup),
				.signaldetectout(w_pcs8g_rx_signaldetectout),
				.speedchange(w_pcs8g_rx_speedchange),
				.speedchangeinchnldownpipe(w_pcs8g_rx_speedchangeinchnldownpipe),
				.speedchangeinchnluppipe(w_pcs8g_rx_speedchangeinchnluppipe),
				.speedchangeoutchnldown(w_pcs8g_rx_speedchangeoutchnldown),
				.speedchangeoutchnlup(w_pcs8g_rx_speedchangeoutchnlup),
				.syncstatus(w_pcs8g_rx_syncstatus),
				.wordalignboundary(w_pcs8g_rx_wordalignboundary),
				.wrenableoutchnldown(w_pcs8g_rx_wrenableoutchnldown),
				.wrenableoutchnlup(w_pcs8g_rx_wrenableoutchnlup),
				// INPUTS
				.a1a2size(w_rx_pld_pcs_if_pcs8ga1a2size),
				.aggtestbus({w_com_pcs_pma_if_pcsaggtestbus[15], w_com_pcs_pma_if_pcsaggtestbus[14], w_com_pcs_pma_if_pcsaggtestbus[13], w_com_pcs_pma_if_pcsaggtestbus[12], w_com_pcs_pma_if_pcsaggtestbus[11], w_com_pcs_pma_if_pcsaggtestbus[10], w_com_pcs_pma_if_pcsaggtestbus[9], w_com_pcs_pma_if_pcsaggtestbus[8], w_com_pcs_pma_if_pcsaggtestbus[7], w_com_pcs_pma_if_pcsaggtestbus[6], w_com_pcs_pma_if_pcsaggtestbus[5], w_com_pcs_pma_if_pcsaggtestbus[4], w_com_pcs_pma_if_pcsaggtestbus[3], w_com_pcs_pma_if_pcsaggtestbus[2], w_com_pcs_pma_if_pcsaggtestbus[1], w_com_pcs_pma_if_pcsaggtestbus[0]}),
				.alignstatus(w_com_pcs_pma_if_pcsaggalignstatus),
				.alignstatussync0(w_com_pcs_pma_if_pcsaggalignstatussync0),
				.alignstatussync0toporbot(w_com_pcs_pma_if_pcsaggalignstatussync0toporbot),
				.alignstatustoporbot(w_com_pcs_pma_if_pcsaggalignstatustoporbot),
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.bitreversalenable(w_rx_pld_pcs_if_pcs8gbitlocreven),
				.bitslip(w_rx_pld_pcs_if_pcs8gbitslip),
				.byteorder(w_rx_pld_pcs_if_pcs8gbytordpld),
				.bytereversalenable(w_rx_pld_pcs_if_pcs8gbytereven),
				.cgcomprddall(w_com_pcs_pma_if_pcsaggcgcomprddall),
				.cgcomprddalltoporbot(w_com_pcs_pma_if_pcsaggcgcomprddalltoporbot),
				.cgcompwrall(w_com_pcs_pma_if_pcsaggcgcompwrall),
				.cgcompwralltoporbot(w_com_pcs_pma_if_pcsaggcgcompwralltoporbot),
				.configselinchnldown(in_config_sel_in_chnl_down),
				.configselinchnlup(in_config_sel_in_chnl_up),
				.ctrlfromaggblock(w_com_pcs_pma_if_pcsaggrxcontrolrs),
				.datafrinaggblock({w_com_pcs_pma_if_pcsaggrxdatars[7], w_com_pcs_pma_if_pcsaggrxdatars[6], w_com_pcs_pma_if_pcsaggrxdatars[5], w_com_pcs_pma_if_pcsaggrxdatars[4], w_com_pcs_pma_if_pcsaggrxdatars[3], w_com_pcs_pma_if_pcsaggrxdatars[2], w_com_pcs_pma_if_pcsaggrxdatars[1], w_com_pcs_pma_if_pcsaggrxdatars[0]}),
				.datain({w_rx_pcs_pma_if_dataoutto8gpcs[19], w_rx_pcs_pma_if_dataoutto8gpcs[18], w_rx_pcs_pma_if_dataoutto8gpcs[17], w_rx_pcs_pma_if_dataoutto8gpcs[16], w_rx_pcs_pma_if_dataoutto8gpcs[15], w_rx_pcs_pma_if_dataoutto8gpcs[14], w_rx_pcs_pma_if_dataoutto8gpcs[13], w_rx_pcs_pma_if_dataoutto8gpcs[12], w_rx_pcs_pma_if_dataoutto8gpcs[11], w_rx_pcs_pma_if_dataoutto8gpcs[10], w_rx_pcs_pma_if_dataoutto8gpcs[9], w_rx_pcs_pma_if_dataoutto8gpcs[8], w_rx_pcs_pma_if_dataoutto8gpcs[7], w_rx_pcs_pma_if_dataoutto8gpcs[6], w_rx_pcs_pma_if_dataoutto8gpcs[5], w_rx_pcs_pma_if_dataoutto8gpcs[4], w_rx_pcs_pma_if_dataoutto8gpcs[3], w_rx_pcs_pma_if_dataoutto8gpcs[2], w_rx_pcs_pma_if_dataoutto8gpcs[1], w_rx_pcs_pma_if_dataoutto8gpcs[0]}),
				.delcondmet0(w_com_pcs_pma_if_pcsaggdelcondmet0),
				.delcondmet0toporbot(w_com_pcs_pma_if_pcsaggdelcondmet0toporbot),
				.dispcbytegen3(w_pipe3_dispcbyte),
				.dynclkswitchn(w_pcs8g_tx_dynclkswitchn),
				.eidleinfersel({w_pcs8g_tx_grayelecidleinferselout[2], w_pcs8g_tx_grayelecidleinferselout[1], w_pcs8g_tx_grayelecidleinferselout[0]}),
				.enablecommadetect(w_rx_pld_pcs_if_pcs8gencdt),
				.endskwqd(w_com_pcs_pma_if_pcsaggendskwqd),
				.endskwqdtoporbot(w_com_pcs_pma_if_pcsaggendskwqdtoporbot),
				.endskwrdptrs(w_com_pcs_pma_if_pcsaggendskwrdptrs),
				.endskwrdptrstoporbot(w_com_pcs_pma_if_pcsaggendskwrdptrstoporbot),
				.fifoovr0(w_com_pcs_pma_if_pcsaggfifoovr0),
				.fifoovr0toporbot(w_com_pcs_pma_if_pcsaggfifoovr0toporbot),
				.fifordincomp0toporbot(w_com_pcs_pma_if_pcsaggfifordincomp0toporbot),
				.fiforstrdqd(w_com_pcs_pma_if_pcsaggfiforstrdqd),
				.fiforstrdqdtoporbot(w_com_pcs_pma_if_pcsaggfiforstrdqdtoporbot),
				.gen2ngen1(w_com_pcs_pma_if_pcs8ggen2ngen1),
				.hrdrst(w_com_pld_pcs_if_pcs8ghardreset),
				.insertincomplete0(w_com_pcs_pma_if_pcsagginsertincomplete0),
				.insertincomplete0toporbot(w_com_pcs_pma_if_pcsagginsertincomplete0toporbot),
				.latencycomp0(w_com_pcs_pma_if_pcsagglatencycomp0),
				.latencycomp0toporbot(w_com_pcs_pma_if_pcsagglatencycomp0toporbot),
				.parallelloopback({w_pcs8g_tx_parallelfdbkout[19], w_pcs8g_tx_parallelfdbkout[18], w_pcs8g_tx_parallelfdbkout[17], w_pcs8g_tx_parallelfdbkout[16], w_pcs8g_tx_parallelfdbkout[15], w_pcs8g_tx_parallelfdbkout[14], w_pcs8g_tx_parallelfdbkout[13], w_pcs8g_tx_parallelfdbkout[12], w_pcs8g_tx_parallelfdbkout[11], w_pcs8g_tx_parallelfdbkout[10], w_pcs8g_tx_parallelfdbkout[9], w_pcs8g_tx_parallelfdbkout[8], w_pcs8g_tx_parallelfdbkout[7], w_pcs8g_tx_parallelfdbkout[6], w_pcs8g_tx_parallelfdbkout[5], w_pcs8g_tx_parallelfdbkout[4], w_pcs8g_tx_parallelfdbkout[3], w_pcs8g_tx_parallelfdbkout[2], w_pcs8g_tx_parallelfdbkout[1], w_pcs8g_tx_parallelfdbkout[0]}),
				.pcfifordenable(w_rx_pld_pcs_if_pcs8grdenablerx),
				.pcieswitchgen3(w_pipe3_pmapcieswitch[0]),
				.phfifouserrst(w_rx_pld_pcs_if_pcs8gphfifourstrx),
				.phystatusinternal(w_pipe12_phystatus),
				.phystatuspcsgen3(w_pipe3_phystatus),
				.pipeloopbk(w_pipe12_revloopbk),
				.pldltr(w_com_pld_pcs_if_pcs8gltr),
				.pldrxclk(w_rx_pld_pcs_if_pcs8gpldrxclk),
				.polinvrx(w_pipe12_polinvrxint),
				.prbscidenable(w_com_pld_pcs_if_pcs8gprbsciden),
				.pxfifowrdisable(w_rx_pld_pcs_if_pcs8gwrdisablerx),
				.rateswitchcontrol(w_com_pld_pcs_if_pcs8grate),
				.rcvdclkagg(w_com_pcs_pma_if_pcsaggrcvdclkagg),
				.rcvdclkaggtoporbot(w_com_pcs_pma_if_pcsaggrcvdclkaggtoporbot),
				.rcvdclkpma(w_rx_pcs_pma_if_clockoutto8gpcs),
				.rdenableinchnldown(in_rx_rd_enable_in_chnl_down),
				.rdenableinchnlup(in_rx_rd_enable_in_chnl_up),
				.refclkdig(w_com_pld_pcs_if_pcs8grefclkdig),
				.refclkdig2(w_com_pld_pcs_if_pcs8grefclkdig2),
				.resetpcptrsgen3(w_pipe3_resetpcprts),
				.resetpcptrsinchnldown(in_reset_pc_ptrs_in_chnl_down),
				.resetpcptrsinchnlup(in_reset_pc_ptrs_in_chnl_up),
				.resetppmcntrsgen3(w_pipe3_ppmcntrst8gpcsout),
				.resetppmcntrsinchnldown(in_reset_ppm_cntrs_in_chnl_down),
				.resetppmcntrsinchnlup(in_reset_ppm_cntrs_in_chnl_up),
				.rmfifordincomp0(w_com_pcs_pma_if_pcsaggfifordincomp0),
				.rmfifouserrst(w_rx_pld_pcs_if_pcs8gcmpfifourst),
				.rxblkstartpcsgen3({w_pipe3_rxblkstart[3], w_pipe3_rxblkstart[2], w_pipe3_rxblkstart[1], w_pipe3_rxblkstart[0]}),
				.rxcontrolrstoporbot(w_com_pcs_pma_if_pcsaggrxcontrolrstoporbot),
				.rxdatapcsgen3({w_pipe3_rxd8gpcsout[63], w_pipe3_rxd8gpcsout[62], w_pipe3_rxd8gpcsout[61], w_pipe3_rxd8gpcsout[60], w_pipe3_rxd8gpcsout[59], w_pipe3_rxd8gpcsout[58], w_pipe3_rxd8gpcsout[57], w_pipe3_rxd8gpcsout[56], w_pipe3_rxd8gpcsout[55], w_pipe3_rxd8gpcsout[54], w_pipe3_rxd8gpcsout[53], w_pipe3_rxd8gpcsout[52], w_pipe3_rxd8gpcsout[51], w_pipe3_rxd8gpcsout[50], w_pipe3_rxd8gpcsout[49], w_pipe3_rxd8gpcsout[48], w_pipe3_rxd8gpcsout[47], w_pipe3_rxd8gpcsout[46], w_pipe3_rxd8gpcsout[45], w_pipe3_rxd8gpcsout[44], w_pipe3_rxd8gpcsout[43], w_pipe3_rxd8gpcsout[42], w_pipe3_rxd8gpcsout[41], w_pipe3_rxd8gpcsout[40], w_pipe3_rxd8gpcsout[39], w_pipe3_rxd8gpcsout[38], w_pipe3_rxd8gpcsout[37], w_pipe3_rxd8gpcsout[36], w_pipe3_rxd8gpcsout[35], w_pipe3_rxd8gpcsout[34], w_pipe3_rxd8gpcsout[33], w_pipe3_rxd8gpcsout[32], w_pipe3_rxd8gpcsout[31], w_pipe3_rxd8gpcsout[30], w_pipe3_rxd8gpcsout[29], w_pipe3_rxd8gpcsout[28], w_pipe3_rxd8gpcsout[27], w_pipe3_rxd8gpcsout[26], w_pipe3_rxd8gpcsout[25], w_pipe3_rxd8gpcsout[24], w_pipe3_rxd8gpcsout[23], w_pipe3_rxd8gpcsout[22], w_pipe3_rxd8gpcsout[21], w_pipe3_rxd8gpcsout[20], w_pipe3_rxd8gpcsout[19], w_pipe3_rxd8gpcsout[18], w_pipe3_rxd8gpcsout[17], w_pipe3_rxd8gpcsout[16], w_pipe3_rxd8gpcsout[15], w_pipe3_rxd8gpcsout[14], w_pipe3_rxd8gpcsout[13], w_pipe3_rxd8gpcsout[12], w_pipe3_rxd8gpcsout[11], w_pipe3_rxd8gpcsout[10], w_pipe3_rxd8gpcsout[9], w_pipe3_rxd8gpcsout[8], w_pipe3_rxd8gpcsout[7], w_pipe3_rxd8gpcsout[6], w_pipe3_rxd8gpcsout[5], w_pipe3_rxd8gpcsout[4], w_pipe3_rxd8gpcsout[3], w_pipe3_rxd8gpcsout[2], w_pipe3_rxd8gpcsout[1], w_pipe3_rxd8gpcsout[0]}),
				.rxdatarstoporbot({w_com_pcs_pma_if_pcsaggrxdatarstoporbot[7], w_com_pcs_pma_if_pcsaggrxdatarstoporbot[6], w_com_pcs_pma_if_pcsaggrxdatarstoporbot[5], w_com_pcs_pma_if_pcsaggrxdatarstoporbot[4], w_com_pcs_pma_if_pcsaggrxdatarstoporbot[3], w_com_pcs_pma_if_pcsaggrxdatarstoporbot[2], w_com_pcs_pma_if_pcsaggrxdatarstoporbot[1], w_com_pcs_pma_if_pcsaggrxdatarstoporbot[0]}),
				.rxdatavalidpcsgen3({w_pipe3_rxdataskip[3], w_pipe3_rxdataskip[2], w_pipe3_rxdataskip[1], w_pipe3_rxdataskip[0]}),
				.rxdivsyncinchnldown({in_rx_div_sync_in_chnl_down[1], in_rx_div_sync_in_chnl_down[0]}),
				.rxdivsyncinchnlup({in_rx_div_sync_in_chnl_up[1], in_rx_div_sync_in_chnl_up[0]}),
				.rxpcsrst(w_rx_pld_pcs_if_pcs8grxurstpcs),
				.rxstatusinternal({w_pipe12_rxstatus[2], w_pipe12_rxstatus[1], w_pipe12_rxstatus[0]}),
				.rxstatuspcsgen3({w_pipe3_rxstatus[2], w_pipe3_rxstatus[1], w_pipe3_rxstatus[0]}),
				.rxsynchdrpcsgen3({w_pipe3_rxsynchdr[1], w_pipe3_rxsynchdr[0]}),
				.rxvalidinternal(w_pipe12_rxvalid),
				.rxvalidpcsgen3(w_pipe3_rxvalid),
				.rxweinchnldown({in_rx_we_in_chnl_down[1], in_rx_we_in_chnl_down[0]}),
				.rxweinchnlup({in_rx_we_in_chnl_up[1], in_rx_we_in_chnl_up[0]}),
				.scanmode(w_com_pld_pcs_if_pcs8gscanmoden),
				.sigdetfrompma(w_rx_pcs_pma_if_pcs8gsigdetni),
				.speedchangeinchnldown(in_speed_change_in_chnl_down),
				.speedchangeinchnlup(in_speed_change_in_chnl_up),
				.syncsmen(w_rx_pld_pcs_if_pcs8gsyncsmenoutput),
				.txctrlplanetestbus({w_pcs8g_tx_txctrlplanetestbus[19], w_pcs8g_tx_txctrlplanetestbus[18], w_pcs8g_tx_txctrlplanetestbus[17], w_pcs8g_tx_txctrlplanetestbus[16], w_pcs8g_tx_txctrlplanetestbus[15], w_pcs8g_tx_txctrlplanetestbus[14], w_pcs8g_tx_txctrlplanetestbus[13], w_pcs8g_tx_txctrlplanetestbus[12], w_pcs8g_tx_txctrlplanetestbus[11], w_pcs8g_tx_txctrlplanetestbus[10], w_pcs8g_tx_txctrlplanetestbus[9], w_pcs8g_tx_txctrlplanetestbus[8], w_pcs8g_tx_txctrlplanetestbus[7], w_pcs8g_tx_txctrlplanetestbus[6], w_pcs8g_tx_txctrlplanetestbus[5], w_pcs8g_tx_txctrlplanetestbus[4], w_pcs8g_tx_txctrlplanetestbus[3], w_pcs8g_tx_txctrlplanetestbus[2], w_pcs8g_tx_txctrlplanetestbus[1], w_pcs8g_tx_txctrlplanetestbus[0]}),
				.txdivsync({w_pcs8g_tx_txdivsync[1], w_pcs8g_tx_txdivsync[0]}),
				.txpmaclk(w_tx_pcs_pma_if_clockoutto8gpcs),
				.txtestbus({w_pcs8g_tx_txtestbus[19], w_pcs8g_tx_txtestbus[18], w_pcs8g_tx_txtestbus[17], w_pcs8g_tx_txtestbus[16], w_pcs8g_tx_txtestbus[15], w_pcs8g_tx_txtestbus[14], w_pcs8g_tx_txtestbus[13], w_pcs8g_tx_txtestbus[12], w_pcs8g_tx_txtestbus[11], w_pcs8g_tx_txtestbus[10], w_pcs8g_tx_txtestbus[9], w_pcs8g_tx_txtestbus[8], w_pcs8g_tx_txtestbus[7], w_pcs8g_tx_txtestbus[6], w_pcs8g_tx_txtestbus[5], w_pcs8g_tx_txtestbus[4], w_pcs8g_tx_txtestbus[3], w_pcs8g_tx_txtestbus[2], w_pcs8g_tx_txtestbus[1], w_pcs8g_tx_txtestbus[0]}),
				.wrenableinchnldown(in_rx_wr_enable_in_chnl_down),
				.wrenableinchnlup(in_rx_wr_enable_in_chnl_up),
				
				// UNUSEDs
				.errctrl( /*unused*/ ),
				.errdata(/*unused*/),
				.observablebyteserdesclock(/*unused*/),
				.prbsdone(/*unused*/),
				.prbserrlt(/*unused*/),
				.rmfifopartialempty(/*unused*/),
				.rmfifopartialfull(/*unused*/),
				.rmfiforeadenable(/*unused*/),
				.rmfifowriteenable(/*unused*/),
				.runlengthviolation(/*unused*/),
				.selftestdone(/*unused*/),
				.selftesterr(/*unused*/),
				.syncdatain(/*unused*/)
			);
		end // if generate
		else begin
				assign w_pcs8g_rx_a1a2k1k2flag[3:0] = 4'b0;
				assign w_pcs8g_rx_aggrxpcsrst = 1'b0;
				assign w_pcs8g_rx_aligndetsync[1:0] = 2'b0;
				assign w_pcs8g_rx_alignstatuspld = 1'b0;
				assign w_pcs8g_rx_alignstatussync = 1'b0;
				assign w_pcs8g_rx_avmmreaddata[15:0] = 16'b0;
				assign w_pcs8g_rx_bistdone = 1'b0;
				assign w_pcs8g_rx_bisterr = 1'b0;
				assign w_pcs8g_rx_blockselect = 1'b0;
				assign w_pcs8g_rx_byteordflag = 1'b0;
				assign w_pcs8g_rx_cgcomprddout[1:0] = 2'b0;
				assign w_pcs8g_rx_cgcompwrout[1:0] = 2'b0;
				assign w_pcs8g_rx_channeltestbusout[19:0] = 20'b0;
				assign w_pcs8g_rx_clocktopld = 1'b0;
				assign w_pcs8g_rx_configseloutchnldown = 1'b0;
				assign w_pcs8g_rx_configseloutchnlup = 1'b0;
				assign w_pcs8g_rx_dataout[63:0] = 64'b0;
				assign w_pcs8g_rx_decoderctrl = 1'b0;
				assign w_pcs8g_rx_decoderdata[7:0] = 8'b0;
				assign w_pcs8g_rx_decoderdatavalid = 1'b0;
				assign w_pcs8g_rx_delcondmetout = 1'b0;
				assign w_pcs8g_rx_disablepcfifobyteserdes = 1'b0;
				assign w_pcs8g_rx_earlyeios = 1'b0;
				assign w_pcs8g_rx_eidledetected = 1'b0;
				assign w_pcs8g_rx_eidleexit = 1'b0;
				assign w_pcs8g_rx_fifoovrout = 1'b0;
				assign w_pcs8g_rx_fifordoutcomp = 1'b0;
				assign w_pcs8g_rx_insertincompleteout = 1'b0;
				assign w_pcs8g_rx_latencycompout = 1'b0;
				assign w_pcs8g_rx_ltr = w_com_pld_pcs_if_pcs8gltr;// connected when sv_hssi_8g_rx_pcs is not instantiated
				assign w_pcs8g_rx_parallelrevloopback[19:0] = 20'b0;
				assign w_pcs8g_rx_pcfifoempty = 1'b0;
				assign w_pcs8g_rx_pcfifofull = 1'b0;
				assign w_pcs8g_rx_pcieswitch = 1'b0;
				assign w_pcs8g_rx_phystatus = 1'b0;
				assign w_pcs8g_rx_pipedata[63:0] = 64'b0;
				assign w_pcs8g_rx_rdalign[1:0] = 2'b0;
				assign w_pcs8g_rx_rdenableoutchnldown = 1'b0;
				assign w_pcs8g_rx_rdenableoutchnlup = 1'b0;
				assign w_pcs8g_rx_resetpcptrs = 1'b0;
				assign w_pcs8g_rx_resetpcptrsinchnldownpipe = 1'b0;
				assign w_pcs8g_rx_resetpcptrsinchnluppipe = 1'b0;
				assign w_pcs8g_rx_resetpcptrsoutchnldown = 1'b0;
				assign w_pcs8g_rx_resetpcptrsoutchnlup = 1'b0;
				assign w_pcs8g_rx_resetppmcntrsoutchnldown = 1'b0;
				assign w_pcs8g_rx_resetppmcntrsoutchnlup = 1'b0;
				assign w_pcs8g_rx_resetppmcntrspcspma = 1'b0;
				assign w_pcs8g_rx_rlvlt = 1'b0;
				assign w_pcs8g_rx_rmfifoempty = 1'b0;
				assign w_pcs8g_rx_rmfifofull = 1'b0;
				assign w_pcs8g_rx_runningdisparity[1:0] = 2'b0;
				assign w_pcs8g_rx_rxblkstart[3:0] = 4'b0;
				assign w_pcs8g_rx_rxclkoutgen3 = 1'b0;
				assign w_pcs8g_rx_rxclkslip = 1'b0;
				assign w_pcs8g_rx_rxdatavalid[3:0] = 4'b0;
				assign w_pcs8g_rx_rxdivsyncoutchnldown[1:0] = 2'b0;
				assign w_pcs8g_rx_rxdivsyncoutchnlup[1:0] = 2'b0;
				assign w_pcs8g_rx_rxpipeclk = 1'b0;
				assign w_pcs8g_rx_rxpipesoftreset = 1'b0;
				assign w_pcs8g_rx_rxstatus[2:0] = 3'b0;
				assign w_pcs8g_rx_rxsynchdr[1:0] = 2'b0;
				assign w_pcs8g_rx_rxvalid = 1'b0;
				assign w_pcs8g_rx_rxweoutchnldown[1:0] = 2'b0;
				assign w_pcs8g_rx_rxweoutchnlup[1:0] = 2'b0;
				assign w_pcs8g_rx_signaldetectout = 1'b0;
				assign w_pcs8g_rx_speedchange = 1'b0;
				assign w_pcs8g_rx_speedchangeinchnldownpipe = 1'b0;
				assign w_pcs8g_rx_speedchangeinchnluppipe = 1'b0;
				assign w_pcs8g_rx_speedchangeoutchnldown = 1'b0;
				assign w_pcs8g_rx_speedchangeoutchnlup = 1'b0;
				assign w_pcs8g_rx_syncstatus = 1'b0;
				assign w_pcs8g_rx_wordalignboundary[4:0] = 5'b0;
				assign w_pcs8g_rx_wrenableoutchnldown = 1'b0;
				assign w_pcs8g_rx_wrenableoutchnlup = 1'b0;
		end // if not generate
		
		// instantiating sv_hssi_8g_tx_pcs
		if ((enable_8g_tx == "true") || (enable_dyn_reconfig == "true")) begin
			sv_hssi_8g_tx_pcs_rbc #(
				.agg_block_sel(pcs8g_tx_agg_block_sel),
				.auto_speed_nego_gen2(pcs8g_tx_auto_speed_nego_gen2),
				.bist_gen(pcs8g_tx_bist_gen),
				.bit_reversal(pcs8g_tx_bit_reversal),
				.bypass_pipeline_reg(pcs8g_tx_bypass_pipeline_reg),
				.byte_serializer(pcs8g_tx_byte_serializer),
				.channel_number(channel_number),
				.cid_pattern(pcs8g_tx_cid_pattern),
				.cid_pattern_len(pcs8g_tx_cid_pattern_len),
				.clock_gate_bist(pcs8g_tx_clock_gate_bist),
				.clock_gate_bs_enc(pcs8g_tx_clock_gate_bs_enc),
				.clock_gate_dw_fifowr(pcs8g_tx_clock_gate_dw_fifowr),
				.clock_gate_fiford(pcs8g_tx_clock_gate_fiford),
				.clock_gate_prbs(pcs8g_tx_clock_gate_prbs),
				.clock_gate_sw_fifowr(pcs8g_tx_clock_gate_sw_fifowr),
				.ctrl_plane_bonding_compensation(pcs8g_tx_ctrl_plane_bonding_compensation),
				.ctrl_plane_bonding_consumption(pcs8g_tx_ctrl_plane_bonding_consumption),
				.ctrl_plane_bonding_distribution(pcs8g_tx_ctrl_plane_bonding_distribution),
				.data_selection_8b10b_encoder_input(pcs8g_tx_data_selection_8b10b_encoder_input),
				.dynamic_clk_switch(pcs8g_tx_dynamic_clk_switch),
				.eightb_tenb_disp_ctrl(pcs8g_tx_eightb_tenb_disp_ctrl),
				.eightb_tenb_encoder(pcs8g_tx_eightb_tenb_encoder),
				.force_echar(pcs8g_tx_force_echar),
				.force_kchar(pcs8g_tx_force_kchar),
				.hip_mode(pcs8g_tx_hip_mode),
				.pcfifo_urst(pcs8g_tx_pcfifo_urst),
				.pcs_bypass(pcs8g_tx_pcs_bypass),
				.phase_compensation_fifo(pcs8g_tx_phase_compensation_fifo),
				.phfifo_write_clk_sel(pcs8g_tx_phfifo_write_clk_sel),
				.pma_dw(pcs8g_tx_pma_dw),
				.polarity_inversion(pcs8g_tx_polarity_inversion),
				.prbs_gen(pcs8g_tx_prbs_gen),
				.prot_mode(pcs8g_tx_prot_mode),
				.refclk_b_clk_sel(pcs8g_tx_refclk_b_clk_sel),
				.revloop_back_rm(pcs8g_tx_revloop_back_rm),
				.sup_mode(pcs8g_tx_sup_mode),
				.symbol_swap(pcs8g_tx_symbol_swap),
				.test_mode(pcs8g_tx_test_mode),
				.tx_bitslip(pcs8g_tx_tx_bitslip),
				.tx_compliance_controlled_disparity(pcs8g_tx_tx_compliance_controlled_disparity),
				.txclk_freerun(pcs8g_tx_txclk_freerun),
				.txpcs_urst(pcs8g_tx_txpcs_urst),
				.use_default_base_address(pcs8g_tx_use_default_base_address),
				.user_base_address(pcs8g_tx_user_base_address)
			) inst_sv_hssi_8g_tx_pcs (
				// OUTPUTS
				.aggtxpcsrst(w_pcs8g_tx_aggtxpcsrst),
				.avmmreaddata(w_pcs8g_tx_avmmreaddata),
				.blockselect(w_pcs8g_tx_blockselect),
				.clkout(w_pcs8g_tx_clkout),
				.clkoutgen3(w_pcs8g_tx_clkoutgen3),
				.dataout(w_pcs8g_tx_dataout),
				.detectrxloopout(w_pcs8g_tx_detectrxloopout),
				.dynclkswitchn(w_pcs8g_tx_dynclkswitchn),
				.fifoselectoutchnldown(w_pcs8g_tx_fifoselectoutchnldown),
				.fifoselectoutchnlup(w_pcs8g_tx_fifoselectoutchnlup),
				.grayelecidleinferselout(w_pcs8g_tx_grayelecidleinferselout),
				.parallelfdbkout(w_pcs8g_tx_parallelfdbkout),
				.phfifooverflow(w_pcs8g_tx_phfifooverflow),
				.phfifotxdeemph(w_pcs8g_tx_phfifotxdeemph),
				.phfifotxmargin(w_pcs8g_tx_phfifotxmargin),
				.phfifotxswing(w_pcs8g_tx_phfifotxswing),
				.phfifounderflow(w_pcs8g_tx_phfifounderflow),
				.pipeenrevparallellpbkout(w_pcs8g_tx_pipeenrevparallellpbkout),
				.pipepowerdownout(w_pcs8g_tx_pipepowerdownout),
				.polinvrxout(w_pcs8g_tx_polinvrxout),
				.rdenableoutchnldown(w_pcs8g_tx_rdenableoutchnldown),
				.rdenableoutchnlup(w_pcs8g_tx_rdenableoutchnlup),
				.rdenablesync(w_pcs8g_tx_rdenablesync),
				.refclkb(w_pcs8g_tx_refclkb),
				.refclkbreset(w_pcs8g_tx_refclkbreset),
				.rxpolarityout(w_pcs8g_tx_rxpolarityout),
				.txblkstartout(w_pcs8g_tx_txblkstartout),
				.txcomplianceout(w_pcs8g_tx_txcomplianceout),
				.txctrlplanetestbus(w_pcs8g_tx_txctrlplanetestbus),
				.txdatakouttogen3(w_pcs8g_tx_txdatakouttogen3),
				.txdataouttogen3(w_pcs8g_tx_txdataouttogen3),
				.txdatavalidouttogen3(w_pcs8g_tx_txdatavalidouttogen3),
				.txdivsync(w_pcs8g_tx_txdivsync),
				.txdivsyncoutchnldown(w_pcs8g_tx_txdivsyncoutchnldown),
				.txdivsyncoutchnlup(w_pcs8g_tx_txdivsyncoutchnlup),
				.txelecidleout(w_pcs8g_tx_txelecidleout),
				.txpipeclk(w_pcs8g_tx_txpipeclk),
				.txpipeelectidle(w_pcs8g_tx_txpipeelectidle),
				.txpipesoftreset(w_pcs8g_tx_txpipesoftreset),
				.txsynchdrout(w_pcs8g_tx_txsynchdrout),
				.txtestbus(w_pcs8g_tx_txtestbus),
				.wrenableoutchnldown(w_pcs8g_tx_wrenableoutchnldown),
				.wrenableoutchnlup(w_pcs8g_tx_wrenableoutchnlup),
				.xgmctrlenable(w_pcs8g_tx_xgmctrlenable),
				.xgmdataout(w_pcs8g_tx_xgmdataout),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.bitslipboundaryselect({w_tx_pld_pcs_if_pcs8gtxboundarysel[4], w_tx_pld_pcs_if_pcs8gtxboundarysel[3], w_tx_pld_pcs_if_pcs8gtxboundarysel[2], w_tx_pld_pcs_if_pcs8gtxboundarysel[1], w_tx_pld_pcs_if_pcs8gtxboundarysel[0]}),
				.clkselgen3(w_pipe3_gen3clksel),
				.coreclk(w_tx_pld_pcs_if_pcs8gpldtxclk),
				.datain({w_tx_pld_pcs_if_dataoutto8gpcs[43], w_tx_pld_pcs_if_dataoutto8gpcs[42], w_tx_pld_pcs_if_dataoutto8gpcs[41], w_tx_pld_pcs_if_dataoutto8gpcs[40], w_tx_pld_pcs_if_dataoutto8gpcs[39], w_tx_pld_pcs_if_dataoutto8gpcs[38], w_tx_pld_pcs_if_dataoutto8gpcs[37], w_tx_pld_pcs_if_dataoutto8gpcs[36], w_tx_pld_pcs_if_dataoutto8gpcs[35], w_tx_pld_pcs_if_dataoutto8gpcs[34], w_tx_pld_pcs_if_dataoutto8gpcs[33], w_tx_pld_pcs_if_dataoutto8gpcs[32], w_tx_pld_pcs_if_dataoutto8gpcs[31], w_tx_pld_pcs_if_dataoutto8gpcs[30], w_tx_pld_pcs_if_dataoutto8gpcs[29], w_tx_pld_pcs_if_dataoutto8gpcs[28], w_tx_pld_pcs_if_dataoutto8gpcs[27], w_tx_pld_pcs_if_dataoutto8gpcs[26], w_tx_pld_pcs_if_dataoutto8gpcs[25], w_tx_pld_pcs_if_dataoutto8gpcs[24], w_tx_pld_pcs_if_dataoutto8gpcs[23], w_tx_pld_pcs_if_dataoutto8gpcs[22], w_tx_pld_pcs_if_dataoutto8gpcs[21], w_tx_pld_pcs_if_dataoutto8gpcs[20], w_tx_pld_pcs_if_dataoutto8gpcs[19], w_tx_pld_pcs_if_dataoutto8gpcs[18], w_tx_pld_pcs_if_dataoutto8gpcs[17], w_tx_pld_pcs_if_dataoutto8gpcs[16], w_tx_pld_pcs_if_dataoutto8gpcs[15], w_tx_pld_pcs_if_dataoutto8gpcs[14], w_tx_pld_pcs_if_dataoutto8gpcs[13], w_tx_pld_pcs_if_dataoutto8gpcs[12], w_tx_pld_pcs_if_dataoutto8gpcs[11], w_tx_pld_pcs_if_dataoutto8gpcs[10], w_tx_pld_pcs_if_dataoutto8gpcs[9], w_tx_pld_pcs_if_dataoutto8gpcs[8], w_tx_pld_pcs_if_dataoutto8gpcs[7], w_tx_pld_pcs_if_dataoutto8gpcs[6], w_tx_pld_pcs_if_dataoutto8gpcs[5], w_tx_pld_pcs_if_dataoutto8gpcs[4], w_tx_pld_pcs_if_dataoutto8gpcs[3], w_tx_pld_pcs_if_dataoutto8gpcs[2], w_tx_pld_pcs_if_dataoutto8gpcs[1], w_tx_pld_pcs_if_dataoutto8gpcs[0]}),
				.detectrxloopin(w_com_pld_pcs_if_pcs8gtxdetectrxloopback),
				.dispcbyte(w_pcs8g_rx_disablepcfifobyteserdes),
				.elecidleinfersel({w_com_pld_pcs_if_pcs8geidleinfersel[2], w_com_pld_pcs_if_pcs8geidleinfersel[1], w_com_pld_pcs_if_pcs8geidleinfersel[0]}),
				.enrevparallellpbk(w_pipe12_revloopbk),
				.fifoselectinchnldown({in_fifo_select_in_chnl_down[1], in_fifo_select_in_chnl_down[0]}),
				.fifoselectinchnlup({in_fifo_select_in_chnl_up[1], in_fifo_select_in_chnl_up[0]}),
				.hrdrst(w_com_pld_pcs_if_pcs8ghardreset),
				.invpol(w_tx_pld_pcs_if_pcs8gpolinvtx),
				.phfiforddisable(w_tx_pld_pcs_if_pcs8grddisabletx),
				.phfiforeset(w_tx_pld_pcs_if_pcs8gphfifoursttx),
				.phfifowrenable(w_tx_pld_pcs_if_pcs8gwrenabletx),
				.pipeenrevparallellpbkin(w_tx_pld_pcs_if_pcs8grevloopbk),
				.pipetxdeemph(w_com_pld_pcs_if_pcs8gtxdeemph),
				.pipetxmargin({w_com_pld_pcs_if_pcs8gtxmargin[2], w_com_pld_pcs_if_pcs8gtxmargin[1], w_com_pld_pcs_if_pcs8gtxmargin[0]}),
				.pipetxswing(w_com_pld_pcs_if_pcs8gtxswing),
				.polinvrxin(w_rx_pld_pcs_if_pcs8gpolinvrx),
				.powerdn({w_com_pld_pcs_if_pcs8gpowerdown[1], w_com_pld_pcs_if_pcs8gpowerdown[0]}),
				.prbscidenable(w_com_pld_pcs_if_pcs8gprbsciden),
				.rateswitch(w_com_pcs_pma_if_pcs8ggen2ngen1),
				.rdenableinchnldown(in_tx_rd_enable_in_chnl_down),
				.rdenableinchnlup(in_tx_rd_enable_in_chnl_up),
				.refclkdig(w_com_pld_pcs_if_pcs8grefclkdig),
				.resetpcptrs(w_pcs8g_rx_resetpcptrs),
				.resetpcptrsinchnldown(w_pcs8g_rx_resetpcptrsinchnldownpipe),
				.resetpcptrsinchnlup(w_pcs8g_rx_resetpcptrsinchnluppipe),
				.revparallellpbkdata({w_pcs8g_rx_parallelrevloopback[19], w_pcs8g_rx_parallelrevloopback[18], w_pcs8g_rx_parallelrevloopback[17], w_pcs8g_rx_parallelrevloopback[16], w_pcs8g_rx_parallelrevloopback[15], w_pcs8g_rx_parallelrevloopback[14], w_pcs8g_rx_parallelrevloopback[13], w_pcs8g_rx_parallelrevloopback[12], w_pcs8g_rx_parallelrevloopback[11], w_pcs8g_rx_parallelrevloopback[10], w_pcs8g_rx_parallelrevloopback[9], w_pcs8g_rx_parallelrevloopback[8], w_pcs8g_rx_parallelrevloopback[7], w_pcs8g_rx_parallelrevloopback[6], w_pcs8g_rx_parallelrevloopback[5], w_pcs8g_rx_parallelrevloopback[4], w_pcs8g_rx_parallelrevloopback[3], w_pcs8g_rx_parallelrevloopback[2], w_pcs8g_rx_parallelrevloopback[1], w_pcs8g_rx_parallelrevloopback[0]}),
				.rxpolarityin(w_com_pld_pcs_if_pcs8grxpolarity),
				.scanmode(w_com_pld_pcs_if_pcs8gscanmoden),
				.txblkstart({w_tx_pld_pcs_if_pcs8gtxblkstart[3], w_tx_pld_pcs_if_pcs8gtxblkstart[2], w_tx_pld_pcs_if_pcs8gtxblkstart[1], w_tx_pld_pcs_if_pcs8gtxblkstart[0]}),
				.txdatavalid({w_tx_pld_pcs_if_pcs8gtxdatavalid[3], w_tx_pld_pcs_if_pcs8gtxdatavalid[2], w_tx_pld_pcs_if_pcs8gtxdatavalid[1], w_tx_pld_pcs_if_pcs8gtxdatavalid[0]}),
				.txdivsyncinchnldown({in_tx_div_sync_in_chnl_down[1], in_tx_div_sync_in_chnl_down[0]}),
				.txdivsyncinchnlup({in_tx_div_sync_in_chnl_up[1], in_tx_div_sync_in_chnl_up[0]}),
				.txpcsreset(w_tx_pld_pcs_if_pcs8gtxurstpcs),
				.txpmalocalclk(w_tx_pcs_pma_if_clockoutto8gpcs),
				.txsynchdr({w_tx_pld_pcs_if_pcs8gtxsynchdr[1], w_tx_pld_pcs_if_pcs8gtxsynchdr[0]}),
				.wrenableinchnldown(in_tx_wr_enable_in_chnl_down),
				.wrenableinchnlup(in_tx_wr_enable_in_chnl_up),
				.xgmctrl(w_com_pcs_pma_if_pcsaggtxctlts),
				.xgmctrltoporbottom(w_com_pcs_pma_if_pcsaggtxctltstoporbot),
				.xgmdatain({w_com_pcs_pma_if_pcsaggtxdatats[7], w_com_pcs_pma_if_pcsaggtxdatats[6], w_com_pcs_pma_if_pcsaggtxdatats[5], w_com_pcs_pma_if_pcsaggtxdatats[4], w_com_pcs_pma_if_pcsaggtxdatats[3], w_com_pcs_pma_if_pcsaggtxdatats[2], w_com_pcs_pma_if_pcsaggtxdatats[1], w_com_pcs_pma_if_pcsaggtxdatats[0]}),
				.xgmdataintoporbottom({w_com_pcs_pma_if_pcsaggtxdatatstoporbot[7], w_com_pcs_pma_if_pcsaggtxdatatstoporbot[6], w_com_pcs_pma_if_pcsaggtxdatatstoporbot[5], w_com_pcs_pma_if_pcsaggtxdatatstoporbot[4], w_com_pcs_pma_if_pcsaggtxdatatstoporbot[3], w_com_pcs_pma_if_pcsaggtxdatatstoporbot[2], w_com_pcs_pma_if_pcsaggtxdatatstoporbot[1], w_com_pcs_pma_if_pcsaggtxdatatstoporbot[0]}),
				
				// UNUSEDs
				.observablebyteserdesclock(/*unused*/),
				.syncdatain(/*unused*/)
			);
		end // if generate
		else begin
				assign w_pcs8g_tx_aggtxpcsrst = 1'b0;
				assign w_pcs8g_tx_avmmreaddata[15:0] = 16'b0;
				assign w_pcs8g_tx_blockselect = 1'b0;
				assign w_pcs8g_tx_clkout = 1'b0;
				assign w_pcs8g_tx_clkoutgen3 = 1'b0;
				assign w_pcs8g_tx_dataout[19:0] = 20'b0;
				assign w_pcs8g_tx_detectrxloopout = 1'b0;
				assign w_pcs8g_tx_dynclkswitchn = 1'b0;
				assign w_pcs8g_tx_fifoselectoutchnldown[1:0] = 2'b0;
				assign w_pcs8g_tx_fifoselectoutchnlup[1:0] = 2'b0;
				assign w_pcs8g_tx_grayelecidleinferselout[2:0] = 3'b0;
				assign w_pcs8g_tx_parallelfdbkout[19:0] = 20'b0;
				assign w_pcs8g_tx_phfifooverflow = 1'b0;
				assign w_pcs8g_tx_phfifotxdeemph = 1'b0;
				assign w_pcs8g_tx_phfifotxmargin[2:0] = 3'b0;
				assign w_pcs8g_tx_phfifotxswing = 1'b0;
				assign w_pcs8g_tx_phfifounderflow = 1'b0;
				assign w_pcs8g_tx_pipeenrevparallellpbkout = 1'b0;
				assign w_pcs8g_tx_pipepowerdownout[1:0] = 2'b0;
				assign w_pcs8g_tx_polinvrxout = w_rx_pld_pcs_if_pcs8gpolinvrx;// connected when sv_hssi_8g_tx_pcs is not instantiated
				assign w_pcs8g_tx_rdenableoutchnldown = 1'b0;
				assign w_pcs8g_tx_rdenableoutchnlup = 1'b0;
				assign w_pcs8g_tx_rdenablesync = 1'b0;
				assign w_pcs8g_tx_refclkb = 1'b0;
				assign w_pcs8g_tx_refclkbreset = 1'b0;
				assign w_pcs8g_tx_rxpolarityout = 1'b0;
				assign w_pcs8g_tx_txblkstartout[3:0] = 4'b0;
				assign w_pcs8g_tx_txcomplianceout = 1'b0;
				assign w_pcs8g_tx_txctrlplanetestbus[19:0] = 20'b0;
				assign w_pcs8g_tx_txdatakouttogen3[3:0] = 4'b0;
				assign w_pcs8g_tx_txdataouttogen3[31:0] = 32'b0;
				assign w_pcs8g_tx_txdatavalidouttogen3[3:0] = 4'b0;
				assign w_pcs8g_tx_txdivsync[1:0] = 2'b0;
				assign w_pcs8g_tx_txdivsyncoutchnldown[1:0] = 2'b0;
				assign w_pcs8g_tx_txdivsyncoutchnlup[1:0] = 2'b0;
				assign w_pcs8g_tx_txelecidleout = 1'b0;
				assign w_pcs8g_tx_txpipeclk = 1'b0;
				assign w_pcs8g_tx_txpipeelectidle = 1'b0;
				assign w_pcs8g_tx_txpipesoftreset = 1'b0;
				assign w_pcs8g_tx_txsynchdrout[1:0] = 2'b0;
				assign w_pcs8g_tx_txtestbus[19:0] = 20'b0;
				assign w_pcs8g_tx_wrenableoutchnldown = 1'b0;
				assign w_pcs8g_tx_wrenableoutchnlup = 1'b0;
				assign w_pcs8g_tx_xgmctrlenable = 1'b0;
				assign w_pcs8g_tx_xgmdataout[7:0] = 8'b0;
		end // if not generate
		
		// instantiating sv_hssi_common_pld_pcs_interface
		if ((enable_10g_rx == "true") || (enable_8g_rx == "true") || (enable_dyn_reconfig == "true")) begin
			sv_hssi_common_pld_pcs_interface_rbc #(
				.data_source(com_pld_pcs_if_data_source),
				.emsip_enable(com_pld_pcs_if_emsip_enable),
				.hrdrstctrl_en_cfg(com_pld_pcs_if_hrdrstctrl_en_cfg),
				.hrdrstctrl_en_cfgusr(com_pld_pcs_if_hrdrstctrl_en_cfgusr),
				.pld_side_reserved_source0(com_pld_pcs_if_pld_side_reserved_source0),
				.pld_side_reserved_source1(com_pld_pcs_if_pld_side_reserved_source1),
				.pld_side_reserved_source10(com_pld_pcs_if_pld_side_reserved_source10),
				.pld_side_reserved_source11(com_pld_pcs_if_pld_side_reserved_source11),
				.pld_side_reserved_source2(com_pld_pcs_if_pld_side_reserved_source2),
				.pld_side_reserved_source3(com_pld_pcs_if_pld_side_reserved_source3),
				.pld_side_reserved_source4(com_pld_pcs_if_pld_side_reserved_source4),
				.pld_side_reserved_source5(com_pld_pcs_if_pld_side_reserved_source5),
				.pld_side_reserved_source6(com_pld_pcs_if_pld_side_reserved_source6),
				.pld_side_reserved_source7(com_pld_pcs_if_pld_side_reserved_source7),
				.pld_side_reserved_source8(com_pld_pcs_if_pld_side_reserved_source8),
				.pld_side_reserved_source9(com_pld_pcs_if_pld_side_reserved_source9),
				.testbus_sel(com_pld_pcs_if_testbus_sel),
				.use_default_base_address(com_pld_pcs_if_use_default_base_address),
				.user_base_address(com_pld_pcs_if_user_base_address),
				.usrmode_sel4rst(com_pld_pcs_if_usrmode_sel4rst)
			) inst_sv_hssi_common_pld_pcs_interface (
				// OUTPUTS
				.avmmreaddata(w_com_pld_pcs_if_avmmreaddata),
				.blockselect(w_com_pld_pcs_if_blockselect),
				.emsipcomclkout(w_com_pld_pcs_if_emsipcomclkout),
				.emsipcomout(w_com_pld_pcs_if_emsipcomout),
				.emsipcomspecialout(w_com_pld_pcs_if_emsipcomspecialout),
				.emsipenablediocsrrdydly(w_com_pld_pcs_if_emsipenablediocsrrdydly),
				.pcs10ghardreset(w_com_pld_pcs_if_pcs10ghardreset),
				.pcs10grefclkdig(w_com_pld_pcs_if_pcs10grefclkdig),
				.pcs8geidleinfersel(w_com_pld_pcs_if_pcs8geidleinfersel),
				.pcs8ghardreset(w_com_pld_pcs_if_pcs8ghardreset),
				.pcs8gltr(w_com_pld_pcs_if_pcs8gltr),
				.pcs8gpowerdown(w_com_pld_pcs_if_pcs8gpowerdown),
				.pcs8gprbsciden(w_com_pld_pcs_if_pcs8gprbsciden),
				.pcs8grate(w_com_pld_pcs_if_pcs8grate),
				.pcs8grefclkdig(w_com_pld_pcs_if_pcs8grefclkdig),
				.pcs8grefclkdig2(w_com_pld_pcs_if_pcs8grefclkdig2),
				.pcs8grxpolarity(w_com_pld_pcs_if_pcs8grxpolarity),
				.pcs8gscanmoden(w_com_pld_pcs_if_pcs8gscanmoden),
				.pcs8gtxdeemph(w_com_pld_pcs_if_pcs8gtxdeemph),
				.pcs8gtxdetectrxloopback(w_com_pld_pcs_if_pcs8gtxdetectrxloopback),
				.pcs8gtxelecidle(w_com_pld_pcs_if_pcs8gtxelecidle),
				.pcs8gtxmargin(w_com_pld_pcs_if_pcs8gtxmargin),
				.pcs8gtxswing(w_com_pld_pcs_if_pcs8gtxswing),
				.pcsaggrefclkdig(w_com_pld_pcs_if_pcsaggrefclkdig),
				.pcsaggtestsi(w_com_pld_pcs_if_pcsaggtestsi),
				.pcsgen3currentcoeff(w_com_pld_pcs_if_pcsgen3currentcoeff),
				.pcsgen3currentrxpreset(w_com_pld_pcs_if_pcsgen3currentrxpreset),
				.pcsgen3eidleinfersel(w_com_pld_pcs_if_pcsgen3eidleinfersel),
				.pcsgen3hardreset(w_com_pld_pcs_if_pcsgen3hardreset),
				.pcsgen3pldltr(w_com_pld_pcs_if_pcsgen3pldltr),
				.pcsgen3rate(w_com_pld_pcs_if_pcsgen3rate),
				.pcsgen3scanmoden(w_com_pld_pcs_if_pcsgen3scanmoden),
				.pcspcspmaifrefclkdig(w_com_pld_pcs_if_pcspcspmaifrefclkdig),
				.pcspcspmaifscanmoden(w_com_pld_pcs_if_pcspcspmaifscanmoden),
				.pcspcspmaifscanshiftn(w_com_pld_pcs_if_pcspcspmaifscanshiftn),
				.pcspmaifhardreset(w_com_pld_pcs_if_pcspmaifhardreset),
				.pld8gphystatus(w_com_pld_pcs_if_pld8gphystatus),
				.pld8grxelecidle(w_com_pld_pcs_if_pld8grxelecidle),
				.pld8grxstatus(w_com_pld_pcs_if_pld8grxstatus),
				.pld8grxvalid(w_com_pld_pcs_if_pld8grxvalid),
				.pldclklow(w_com_pld_pcs_if_pldclklow),
				.pldfref(w_com_pld_pcs_if_pldfref),
				.pldgen3masktxpll(w_com_pld_pcs_if_pldgen3masktxpll),
				.pldgen3rxdeemph(w_com_pld_pcs_if_pldgen3rxdeemph),
				.pldgen3rxeqctrl(w_com_pld_pcs_if_pldgen3rxeqctrl),
				.pldnfrzdrv(w_com_pld_pcs_if_pldnfrzdrv),
				.pldpartialreconfigout(w_com_pld_pcs_if_pldpartialreconfigout),
				.pldreservedout(w_com_pld_pcs_if_pldreservedout),
				.pldtestdata(w_com_pld_pcs_if_pldtestdata),
				.rstsel(w_com_pld_pcs_if_rstsel),
				.usrrstsel(w_com_pld_pcs_if_usrrstsel),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.emsipcomin({in_emsip_com_in[37], in_emsip_com_in[36], in_emsip_com_in[35], in_emsip_com_in[34], in_emsip_com_in[33], in_emsip_com_in[32], in_emsip_com_in[31], in_emsip_com_in[30], in_emsip_com_in[29], in_emsip_com_in[28], in_emsip_com_in[27], in_emsip_com_in[26], in_emsip_com_in[25], in_emsip_com_in[24], in_emsip_com_in[23], in_emsip_com_in[22], in_emsip_com_in[21], in_emsip_com_in[20], in_emsip_com_in[19], in_emsip_com_in[18], in_emsip_com_in[17], in_emsip_com_in[16], in_emsip_com_in[15], in_emsip_com_in[14], in_emsip_com_in[13], in_emsip_com_in[12], in_emsip_com_in[11], in_emsip_com_in[10], in_emsip_com_in[9], in_emsip_com_in[8], in_emsip_com_in[7], in_emsip_com_in[6], in_emsip_com_in[5], in_emsip_com_in[4], in_emsip_com_in[3], in_emsip_com_in[2], in_emsip_com_in[1], in_emsip_com_in[0]}),
				.emsipcomspecialin({in_emsip_com_special_in[19], in_emsip_com_special_in[18], in_emsip_com_special_in[17], in_emsip_com_special_in[16], in_emsip_com_special_in[15], in_emsip_com_special_in[14], in_emsip_com_special_in[13], in_emsip_com_special_in[12], in_emsip_com_special_in[11], in_emsip_com_special_in[10], in_emsip_com_special_in[9], in_emsip_com_special_in[8], in_emsip_com_special_in[7], in_emsip_com_special_in[6], in_emsip_com_special_in[5], in_emsip_com_special_in[4], in_emsip_com_special_in[3], in_emsip_com_special_in[2], in_emsip_com_special_in[1], in_emsip_com_special_in[0]}),
				.entest(in_entest),
				.frzreg(in_frzreg),
				.iocsrrdydly(in_iocsr_rdy_dly),
				.nfrzdrv(in_nfrzdrv),
				.npor(in_npor),
				.pcs10gextraout({1'b0, 1'b0, 1'b0, w_pcs10g_rx_rxprbsdone}),
				.pcs10gtestdata({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
				.pcs8gchnltestbusout({w_pcs8g_rx_channeltestbusout[19], w_pcs8g_rx_channeltestbusout[18], w_pcs8g_rx_channeltestbusout[17], w_pcs8g_rx_channeltestbusout[16], w_pcs8g_rx_channeltestbusout[15], w_pcs8g_rx_channeltestbusout[14], w_pcs8g_rx_channeltestbusout[13], w_pcs8g_rx_channeltestbusout[12], w_pcs8g_rx_channeltestbusout[11], w_pcs8g_rx_channeltestbusout[10], w_pcs8g_rx_channeltestbusout[9], w_pcs8g_rx_channeltestbusout[8], w_pcs8g_rx_channeltestbusout[7], w_pcs8g_rx_channeltestbusout[6], w_pcs8g_rx_channeltestbusout[5], w_pcs8g_rx_channeltestbusout[4], w_pcs8g_rx_channeltestbusout[3], w_pcs8g_rx_channeltestbusout[2], w_pcs8g_rx_channeltestbusout[1], w_pcs8g_rx_channeltestbusout[0]}),
				.pcs8gphystatus(w_pcs8g_rx_phystatus),
				.pcs8grxelecidle(w_pipe12_rxelecidle),
				.pcs8grxstatus({w_pcs8g_rx_rxstatus[2], w_pcs8g_rx_rxstatus[1], w_pcs8g_rx_rxstatus[0]}),
				.pcs8grxvalid(w_pcs8g_rx_rxvalid),
				.pcsaggtestso(w_com_pcs_pma_if_aggtestsotopldout),
				.pcsgen3masktxpll(w_pipe3_masktxpll),
				.pcsgen3testout({w_pipe3_testout[19], w_pipe3_testout[18], w_pipe3_testout[17], w_pipe3_testout[16], w_pipe3_testout[15], w_pipe3_testout[14], w_pipe3_testout[13], w_pipe3_testout[12], w_pipe3_testout[11], w_pipe3_testout[10], w_pipe3_testout[9], w_pipe3_testout[8], w_pipe3_testout[7], w_pipe3_testout[6], w_pipe3_testout[5], w_pipe3_testout[4], w_pipe3_testout[3], w_pipe3_testout[2], w_pipe3_testout[1], w_pipe3_testout[0]}),
				.pcspmaiftestbusout({w_com_pcs_pma_if_pmaiftestbus[9], w_com_pcs_pma_if_pmaiftestbus[8], w_com_pcs_pma_if_pmaiftestbus[7], w_com_pcs_pma_if_pmaiftestbus[6], w_com_pcs_pma_if_pmaiftestbus[5], w_com_pcs_pma_if_pmaiftestbus[4], w_com_pcs_pma_if_pmaiftestbus[3], w_com_pcs_pma_if_pmaiftestbus[2], w_com_pcs_pma_if_pmaiftestbus[1], w_com_pcs_pma_if_pmaiftestbus[0]}),
				.pld10grefclkdig(in_pld_10g_refclk_dig),
				.pld8gpowerdown({in_pld_8g_powerdown[1], in_pld_8g_powerdown[0]}),
				.pld8gprbsciden(in_pld_8g_prbs_cid_en),
				.pld8grefclkdig(in_pld_8g_refclk_dig),
				.pld8grefclkdig2(in_pld_8g_refclk_dig2),
				.pld8grxpolarity(in_pld_8g_rxpolarity),
				.pld8gtxdeemph(in_pld_8g_txdeemph),
				.pld8gtxdetectrxloopback(in_pld_8g_txdetectrxloopback),
				.pld8gtxelecidle(in_pld_8g_txelecidle),
				.pld8gtxmargin({in_pld_8g_txmargin[2], in_pld_8g_txmargin[1], in_pld_8g_txmargin[0]}),
				.pld8gtxswing(in_pld_8g_txswing),
				.pldaggrefclkdig(in_pld_agg_refclk_dig),
				.pldeidleinfersel({in_pld_eidleinfersel[2], in_pld_eidleinfersel[1], in_pld_eidleinfersel[0]}),
				.pldgen3currentcoeff({in_pld_gen3_current_coeff[17], in_pld_gen3_current_coeff[16], in_pld_gen3_current_coeff[15], in_pld_gen3_current_coeff[14], in_pld_gen3_current_coeff[13], in_pld_gen3_current_coeff[12], in_pld_gen3_current_coeff[11], in_pld_gen3_current_coeff[10], in_pld_gen3_current_coeff[9], in_pld_gen3_current_coeff[8], in_pld_gen3_current_coeff[7], in_pld_gen3_current_coeff[6], in_pld_gen3_current_coeff[5], in_pld_gen3_current_coeff[4], in_pld_gen3_current_coeff[3], in_pld_gen3_current_coeff[2], in_pld_gen3_current_coeff[1], in_pld_gen3_current_coeff[0]}),
				.pldgen3currentrxpreset({in_pld_gen3_current_rxpreset[2], in_pld_gen3_current_rxpreset[1], in_pld_gen3_current_rxpreset[0]}),
				.pldhclkin(w_com_pcs_pma_if_pldhclkout),
				.pldltr(in_pld_ltr),
				.pldoffcaldone(1'b0),
				.pldpartialreconfigin(in_pld_partial_reconfig_in),
				.pldpcspmaifrefclkdig(in_pld_pcs_pma_if_refclk_dig),
				.pldrate({in_pld_rate[1], in_pld_rate[0]}),
				.pldreservedin({in_pld_reserved_in[11], in_pld_reserved_in[10], in_pld_reserved_in[9], in_pld_reserved_in[8], in_pld_reserved_in[7], in_pld_reserved_in[6], in_pld_reserved_in[5], in_pld_reserved_in[4], in_pld_reserved_in[3], in_pld_reserved_in[2], in_pld_reserved_in[1], in_pld_reserved_in[0]}),
				.pldscanmoden(in_pld_scan_mode_n),
				.pldscanshiftn(in_pld_scan_shift_n),
				.plniotri(in_plniotri),
				.pmaclklow(w_com_pcs_pma_if_pmaclklowout),
				.pmafref(w_com_pcs_pma_if_pmafrefout),
				.usermode(in_usermode),
				.asynchdatain(/*unused*/),
				.pcs10gextrain(/*unused*/),
				.pcs10ghardresetn(/*unused*/),
				.pcs10gtestsi(/*unused*/),
				.pcs10gtestso(/*unused*/),
				.pcs8ghardresetn(/*unused*/),
				.pcs8gpldextrain(/*unused*/),
				.pcs8gpldextraout(/*unused*/),
				.pcs8gtestsi(/*unused*/),
				.pcs8gtestso(/*unused*/),
				.pcsgen3extrain(/*unused*/),
				.pcsgen3extraout(/*unused*/),
				.pcsgen3rxdeemph(/*unused*/),
				.pcsgen3rxeqctrl(/*unused*/),
				.pcsgen3testsi(/*unused*/),
				.pcsgen3testso(/*unused*/),
				.pcspmaiftestsi(/*unused*/),
				.pcspmaiftestso(/*unused*/),
				.pldoffcaldonein(/*unused*/),
				.pldoffcaldoneout(/*unused*/),
				.pldoffcalen(/*unused*/),
				.pmaoffcalen(/*unused*/)                
			);
		  
		end // if generate



// For PMA Direct mode
		// instantiating sv_hssi_common_pld_pcs_interface
		else if (enable_pma_direct_rx == "true")  begin
			sv_hssi_common_pld_pcs_interface_rbc #(
				.data_source(com_pld_pcs_if_data_source),
				.emsip_enable(com_pld_pcs_if_emsip_enable),
				.hrdrstctrl_en_cfg(com_pld_pcs_if_hrdrstctrl_en_cfg),
				.hrdrstctrl_en_cfgusr(com_pld_pcs_if_hrdrstctrl_en_cfgusr),
				.pld_side_reserved_source0(com_pld_pcs_if_pld_side_reserved_source0),
				.pld_side_reserved_source1(com_pld_pcs_if_pld_side_reserved_source1),
				.pld_side_reserved_source10(com_pld_pcs_if_pld_side_reserved_source10),
				.pld_side_reserved_source11(com_pld_pcs_if_pld_side_reserved_source11),
				.pld_side_reserved_source2(com_pld_pcs_if_pld_side_reserved_source2),
				.pld_side_reserved_source3(com_pld_pcs_if_pld_side_reserved_source3),
				.pld_side_reserved_source4(com_pld_pcs_if_pld_side_reserved_source4),
				.pld_side_reserved_source5(com_pld_pcs_if_pld_side_reserved_source5),
				.pld_side_reserved_source6(com_pld_pcs_if_pld_side_reserved_source6),
				.pld_side_reserved_source7(com_pld_pcs_if_pld_side_reserved_source7),
				.pld_side_reserved_source8(com_pld_pcs_if_pld_side_reserved_source8),
				.pld_side_reserved_source9(com_pld_pcs_if_pld_side_reserved_source9),
				.testbus_sel(com_pld_pcs_if_testbus_sel),
				.use_default_base_address(com_pld_pcs_if_use_default_base_address),
				.user_base_address(com_pld_pcs_if_user_base_address),
				.usrmode_sel4rst(com_pld_pcs_if_usrmode_sel4rst)
			) inst_sv_hssi_common_pld_pcs_interface (
				// OUTPUTS
				.avmmreaddata(w_com_pld_pcs_if_avmmreaddata),
				.blockselect(w_com_pld_pcs_if_blockselect),
				.emsipcomclkout(w_com_pld_pcs_if_emsipcomclkout),
				.emsipcomout(w_com_pld_pcs_if_emsipcomout),
				.emsipcomspecialout(w_com_pld_pcs_if_emsipcomspecialout),
				.emsipenablediocsrrdydly(w_com_pld_pcs_if_emsipenablediocsrrdydly),
				.pcs10ghardreset(w_com_pld_pcs_if_pcs10ghardreset),
				.pcs10grefclkdig(w_com_pld_pcs_if_pcs10grefclkdig),
				.pcs8geidleinfersel(w_com_pld_pcs_if_pcs8geidleinfersel),
				.pcs8ghardreset(w_com_pld_pcs_if_pcs8ghardreset),
				.pcs8gltr(w_com_pld_pcs_if_pcs8gltr),
				.pcs8gpowerdown(w_com_pld_pcs_if_pcs8gpowerdown),
				.pcs8gprbsciden(w_com_pld_pcs_if_pcs8gprbsciden),
				.pcs8grate(w_com_pld_pcs_if_pcs8grate),
				.pcs8grefclkdig(w_com_pld_pcs_if_pcs8grefclkdig),
				.pcs8grefclkdig2(w_com_pld_pcs_if_pcs8grefclkdig2),
				.pcs8grxpolarity(w_com_pld_pcs_if_pcs8grxpolarity),
				.pcs8gscanmoden(w_com_pld_pcs_if_pcs8gscanmoden),
				.pcs8gtxdeemph(w_com_pld_pcs_if_pcs8gtxdeemph),
				.pcs8gtxdetectrxloopback(w_com_pld_pcs_if_pcs8gtxdetectrxloopback),
				.pcs8gtxelecidle(w_com_pld_pcs_if_pcs8gtxelecidle),
				.pcs8gtxmargin(w_com_pld_pcs_if_pcs8gtxmargin),
				.pcs8gtxswing(w_com_pld_pcs_if_pcs8gtxswing),
				.pcsaggrefclkdig(w_com_pld_pcs_if_pcsaggrefclkdig),
				.pcsaggtestsi(w_com_pld_pcs_if_pcsaggtestsi),
				.pcsgen3currentcoeff(w_com_pld_pcs_if_pcsgen3currentcoeff),
				.pcsgen3currentrxpreset(w_com_pld_pcs_if_pcsgen3currentrxpreset),
				.pcsgen3eidleinfersel(w_com_pld_pcs_if_pcsgen3eidleinfersel),
				.pcsgen3hardreset(w_com_pld_pcs_if_pcsgen3hardreset),
				.pcsgen3pldltr(w_com_pld_pcs_if_pcsgen3pldltr),
				.pcsgen3rate(w_com_pld_pcs_if_pcsgen3rate),
				.pcsgen3scanmoden(w_com_pld_pcs_if_pcsgen3scanmoden),
				.pcspcspmaifrefclkdig(w_com_pld_pcs_if_pcspcspmaifrefclkdig),
				.pcspcspmaifscanmoden(w_com_pld_pcs_if_pcspcspmaifscanmoden),
				.pcspcspmaifscanshiftn(w_com_pld_pcs_if_pcspcspmaifscanshiftn),
				.pcspmaifhardreset(w_com_pld_pcs_if_pcspmaifhardreset),
				.pld8gphystatus(w_com_pld_pcs_if_pld8gphystatus),
				.pld8grxelecidle(w_com_pld_pcs_if_pld8grxelecidle),
				.pld8grxstatus(w_com_pld_pcs_if_pld8grxstatus),
				.pld8grxvalid(w_com_pld_pcs_if_pld8grxvalid),
				.pldclklow(w_com_pld_pcs_if_pldclklow),
				.pldfref(w_com_pld_pcs_if_pldfref),
				.pldgen3masktxpll(w_com_pld_pcs_if_pldgen3masktxpll),
				.pldgen3rxdeemph(w_com_pld_pcs_if_pldgen3rxdeemph),
				.pldgen3rxeqctrl(w_com_pld_pcs_if_pldgen3rxeqctrl),
				.pldnfrzdrv(w_com_pld_pcs_if_pldnfrzdrv),
				.pldpartialreconfigout(w_com_pld_pcs_if_pldpartialreconfigout),
				.pldreservedout(w_com_pld_pcs_if_pldreservedout),
				.pldtestdata(w_com_pld_pcs_if_pldtestdata),
				.rstsel(w_com_pld_pcs_if_rstsel),
				.usrrstsel(w_com_pld_pcs_if_usrrstsel),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.emsipcomin({in_emsip_com_in[37], in_emsip_com_in[36], in_emsip_com_in[35], in_emsip_com_in[34], in_emsip_com_in[33], in_emsip_com_in[32], in_emsip_com_in[31], in_emsip_com_in[30], in_emsip_com_in[29], in_emsip_com_in[28], in_emsip_com_in[27], in_emsip_com_in[26], in_emsip_com_in[25], in_emsip_com_in[24], in_emsip_com_in[23], in_emsip_com_in[22], in_emsip_com_in[21], in_emsip_com_in[20], in_emsip_com_in[19], in_emsip_com_in[18], in_emsip_com_in[17], in_emsip_com_in[16], in_emsip_com_in[15], in_emsip_com_in[14], in_emsip_com_in[13], in_emsip_com_in[12], in_emsip_com_in[11], in_emsip_com_in[10], in_emsip_com_in[9], in_emsip_com_in[8], in_emsip_com_in[7], in_emsip_com_in[6], in_emsip_com_in[5], in_emsip_com_in[4], in_emsip_com_in[3], in_emsip_com_in[2], in_emsip_com_in[1], in_emsip_com_in[0]}),
				.emsipcomspecialin({in_emsip_com_special_in[19], in_emsip_com_special_in[18], in_emsip_com_special_in[17], in_emsip_com_special_in[16], in_emsip_com_special_in[15], in_emsip_com_special_in[14], in_emsip_com_special_in[13], in_emsip_com_special_in[12], in_emsip_com_special_in[11], in_emsip_com_special_in[10], in_emsip_com_special_in[9], in_emsip_com_special_in[8], in_emsip_com_special_in[7], in_emsip_com_special_in[6], in_emsip_com_special_in[5], in_emsip_com_special_in[4], in_emsip_com_special_in[3], in_emsip_com_special_in[2], in_emsip_com_special_in[1], in_emsip_com_special_in[0]}),
				.entest(in_entest),
				.frzreg(in_frzreg),
				.iocsrrdydly(in_iocsr_rdy_dly),
				.nfrzdrv(in_nfrzdrv),
				.npor(in_npor),
				.pcs10gextraout({1'b0, 1'b0, 1'b0, w_pcs10g_rx_rxprbsdone}),
				.pcs10gtestdata({1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}),
				.pcs8gchnltestbusout({w_pcs8g_rx_channeltestbusout[19], w_pcs8g_rx_channeltestbusout[18], w_pcs8g_rx_channeltestbusout[17], w_pcs8g_rx_channeltestbusout[16], w_pcs8g_rx_channeltestbusout[15], w_pcs8g_rx_channeltestbusout[14], w_pcs8g_rx_channeltestbusout[13], w_pcs8g_rx_channeltestbusout[12], w_pcs8g_rx_channeltestbusout[11], w_pcs8g_rx_channeltestbusout[10], w_pcs8g_rx_channeltestbusout[9], w_pcs8g_rx_channeltestbusout[8], w_pcs8g_rx_channeltestbusout[7], w_pcs8g_rx_channeltestbusout[6], w_pcs8g_rx_channeltestbusout[5], w_pcs8g_rx_channeltestbusout[4], w_pcs8g_rx_channeltestbusout[3], w_pcs8g_rx_channeltestbusout[2], w_pcs8g_rx_channeltestbusout[1], w_pcs8g_rx_channeltestbusout[0]}),
				.pcs8gphystatus(w_pcs8g_rx_phystatus),
				.pcs8grxelecidle(w_pipe12_rxelecidle),
				.pcs8grxstatus({w_pcs8g_rx_rxstatus[2], w_pcs8g_rx_rxstatus[1], w_pcs8g_rx_rxstatus[0]}),
				.pcs8grxvalid(w_pcs8g_rx_rxvalid),
				.pcsaggtestso(w_com_pcs_pma_if_aggtestsotopldout),
				.pcsgen3masktxpll(w_pipe3_masktxpll),
				.pcsgen3testout({w_pipe3_testout[19], w_pipe3_testout[18], w_pipe3_testout[17], w_pipe3_testout[16], w_pipe3_testout[15], w_pipe3_testout[14], w_pipe3_testout[13], w_pipe3_testout[12], w_pipe3_testout[11], w_pipe3_testout[10], w_pipe3_testout[9], w_pipe3_testout[8], w_pipe3_testout[7], w_pipe3_testout[6], w_pipe3_testout[5], w_pipe3_testout[4], w_pipe3_testout[3], w_pipe3_testout[2], w_pipe3_testout[1], w_pipe3_testout[0]}),
				.pcspmaiftestbusout({w_com_pcs_pma_if_pmaiftestbus[9], w_com_pcs_pma_if_pmaiftestbus[8], w_com_pcs_pma_if_pmaiftestbus[7], w_com_pcs_pma_if_pmaiftestbus[6], w_com_pcs_pma_if_pmaiftestbus[5], w_com_pcs_pma_if_pmaiftestbus[4], w_com_pcs_pma_if_pmaiftestbus[3], w_com_pcs_pma_if_pmaiftestbus[2], w_com_pcs_pma_if_pmaiftestbus[1], w_com_pcs_pma_if_pmaiftestbus[0]}),
				.pld10grefclkdig(in_pld_10g_refclk_dig),
				.pld8gpowerdown({in_pld_8g_powerdown[1], in_pld_8g_powerdown[0]}),
				.pld8gprbsciden(in_pld_8g_prbs_cid_en),
				.pld8grefclkdig(in_pld_8g_refclk_dig),
				.pld8grefclkdig2(in_pld_8g_refclk_dig2),
				.pld8grxpolarity(in_pld_8g_rxpolarity),
				.pld8gtxdeemph(in_pld_8g_txdeemph),
				.pld8gtxdetectrxloopback(in_pld_8g_txdetectrxloopback),
				.pld8gtxelecidle(in_pld_8g_txelecidle),
				.pld8gtxmargin({in_pld_8g_txmargin[2], in_pld_8g_txmargin[1], in_pld_8g_txmargin[0]}),
				.pld8gtxswing(in_pld_8g_txswing),
				.pldaggrefclkdig(in_pld_agg_refclk_dig),
				.pldeidleinfersel(3'b111),
				.pldgen3currentcoeff(18'b111111111111111111),
                                .pldgen3currentrxpreset(3'b111),								       
//				.pldeidleinfersel({in_pld_eidleinfersel[2], in_pld_eidleinfersel[1], in_pld_eidleinfersel[0]}),
//				.pldgen3currentcoeff({in_pld_gen3_current_coeff[17], in_pld_gen3_current_coeff[16], in_pld_gen3_current_coeff[15], in_pld_gen3_current_coeff[14], in_pld_gen3_current_coeff[13], in_pld_gen3_current_coeff[12], in_pld_gen3_current_coeff[11], in_pld_gen3_current_coeff[10], in_pld_gen3_current_coeff[9], in_pld_gen3_current_coeff[8], in_pld_gen3_current_coeff[7], in_pld_gen3_current_coeff[6], in_pld_gen3_current_coeff[5], in_pld_gen3_current_coeff[4], in_pld_gen3_current_coeff[3], in_pld_gen3_current_coeff[2], in_pld_gen3_current_coeff[1], in_pld_gen3_current_coeff[0]}),
//				.pldgen3currentrxpreset({in_pld_gen3_current_rxpreset[2], in_pld_gen3_current_rxpreset[1], in_pld_gen3_current_rxpreset[0]}),
				.pldhclkin(w_com_pcs_pma_if_pldhclkout),
				.pldltr(in_pld_ltr),
				.pldoffcaldone(1'b0),
				.pldpartialreconfigin(in_pld_partial_reconfig_in),
				.pldpcspmaifrefclkdig(in_pld_pcs_pma_if_refclk_dig),
				.pldrate(2'b11),
//				.pldrate({in_pld_rate[1], in_pld_rate[0]}),
				.pldreservedin({in_pld_reserved_in[11], in_pld_reserved_in[10], in_pld_reserved_in[9], in_pld_reserved_in[8], in_pld_reserved_in[7], in_pld_reserved_in[6], in_pld_reserved_in[5], in_pld_reserved_in[4], in_pld_reserved_in[3], in_pld_reserved_in[2], in_pld_reserved_in[1], in_pld_reserved_in[0]}),
				.pldscanmoden(in_pld_scan_mode_n),
				.pldscanshiftn(in_pld_scan_shift_n),
				.plniotri(in_plniotri),
				.pmaclklow(w_com_pcs_pma_if_pmaclklowout),
				.pmafref(w_com_pcs_pma_if_pmafrefout),
				.usermode(in_usermode),
				.asynchdatain(/*unused*/),
				.pcs10gextrain(/*unused*/),
				.pcs10ghardresetn(/*unused*/),
				.pcs10gtestsi(/*unused*/),
				.pcs10gtestso(/*unused*/),
				.pcs8ghardresetn(/*unused*/),
				.pcs8gpldextrain(/*unused*/),
				.pcs8gpldextraout(/*unused*/),
				.pcs8gtestsi(/*unused*/),
				.pcs8gtestso(/*unused*/),
				.pcsgen3extrain(/*unused*/),
				.pcsgen3extraout(/*unused*/),
				.pcsgen3rxdeemph(/*unused*/),
				.pcsgen3rxeqctrl(/*unused*/),
				.pcsgen3testsi(/*unused*/),
				.pcsgen3testso(/*unused*/),
				.pcspmaiftestsi(/*unused*/),
				.pcspmaiftestso(/*unused*/),
				.pldoffcaldonein(/*unused*/),
				.pldoffcaldoneout(/*unused*/),
				.pldoffcalen(/*unused*/),				
				.pmaoffcalen(/*unused*/)
			);
		  
		end // if (enable_pma_direct_rx == "true")

	   
		else begin
				assign w_com_pld_pcs_if_avmmreaddata[15:0] = 16'b0;
				assign w_com_pld_pcs_if_blockselect = 1'b0;
				assign w_com_pld_pcs_if_emsipcomclkout[2:0] = 3'b0;
				assign w_com_pld_pcs_if_emsipcomout[26:0] = 27'b0;
				assign w_com_pld_pcs_if_emsipcomspecialout[19:0] = 20'b0;
				assign w_com_pld_pcs_if_emsipenablediocsrrdydly = 1'b0;
				assign w_com_pld_pcs_if_pcs10ghardreset = 1'b1;// connected when sv_hssi_common_pld_pcs_interface is not instantiated
				assign w_com_pld_pcs_if_pcs10grefclkdig = 1'b0;
				assign w_com_pld_pcs_if_pcs8geidleinfersel[2:0] = 3'b0;
				assign w_com_pld_pcs_if_pcs8ghardreset = 1'b1;// connected when sv_hssi_common_pld_pcs_interface is not instantiated
				assign w_com_pld_pcs_if_pcs8gltr = 1'b0;
				assign w_com_pld_pcs_if_pcs8gpowerdown[1:0] = 2'b0;
				assign w_com_pld_pcs_if_pcs8gprbsciden = 1'b0;
				assign w_com_pld_pcs_if_pcs8grate = 1'b0;
				assign w_com_pld_pcs_if_pcs8grefclkdig = 1'b0;
				assign w_com_pld_pcs_if_pcs8grefclkdig2 = 1'b0;
				assign w_com_pld_pcs_if_pcs8grxpolarity = 1'b0;
				assign w_com_pld_pcs_if_pcs8gscanmoden = 1'b1;// connected when sv_hssi_common_pld_pcs_interface is not instantiated
				assign w_com_pld_pcs_if_pcs8gtxdeemph = 1'b0;
				assign w_com_pld_pcs_if_pcs8gtxdetectrxloopback = 1'b0;
				assign w_com_pld_pcs_if_pcs8gtxelecidle = 1'b0;
				assign w_com_pld_pcs_if_pcs8gtxmargin[2:0] = 3'b0;
				assign w_com_pld_pcs_if_pcs8gtxswing = 1'b0;
				assign w_com_pld_pcs_if_pcsaggrefclkdig = 1'b0;
				assign w_com_pld_pcs_if_pcsaggtestsi = 1'b0;
				assign w_com_pld_pcs_if_pcsgen3currentcoeff[17:0] = 18'b0;
				assign w_com_pld_pcs_if_pcsgen3currentrxpreset[2:0] = 3'b0;
				assign w_com_pld_pcs_if_pcsgen3eidleinfersel[2:0] = 3'b0;
				assign w_com_pld_pcs_if_pcsgen3hardreset = 1'b1;// connected when sv_hssi_common_pld_pcs_interface is not instantiated
				assign w_com_pld_pcs_if_pcsgen3pldltr = 1'b0;
				assign w_com_pld_pcs_if_pcsgen3rate[1:0] = 2'b0;
				assign w_com_pld_pcs_if_pcsgen3scanmoden = 1'b1;// connected when sv_hssi_common_pld_pcs_interface is not instantiated
				assign w_com_pld_pcs_if_pcspcspmaifrefclkdig = 1'b0;
				assign w_com_pld_pcs_if_pcspcspmaifscanmoden = 1'b1;// connected when sv_hssi_common_pld_pcs_interface is not instantiated
				assign w_com_pld_pcs_if_pcspcspmaifscanshiftn = 1'b0;
				assign w_com_pld_pcs_if_pcspmaifhardreset = 1'b1;// connected when sv_hssi_common_pld_pcs_interface is not instantiated
				assign w_com_pld_pcs_if_pld8gphystatus = 1'b0;
				assign w_com_pld_pcs_if_pld8grxelecidle = 1'b0;
				assign w_com_pld_pcs_if_pld8grxstatus[2:0] = 3'b0;
				assign w_com_pld_pcs_if_pld8grxvalid = 1'b0;
				assign w_com_pld_pcs_if_pldclklow = 1'b0;
				assign w_com_pld_pcs_if_pldfref = 1'b0;
				assign w_com_pld_pcs_if_pldgen3masktxpll = 1'b0;
				assign w_com_pld_pcs_if_pldgen3rxdeemph[17:0] = 18'b0;
				assign w_com_pld_pcs_if_pldgen3rxeqctrl[1:0] = 2'b0;
				assign w_com_pld_pcs_if_pldnfrzdrv = 1'b0;
				assign w_com_pld_pcs_if_pldpartialreconfigout = 1'b0;
				assign w_com_pld_pcs_if_pldreservedout[10:0] = 11'b0;
				assign w_com_pld_pcs_if_pldtestdata[19:0] = 20'b0;
				assign w_com_pld_pcs_if_rstsel = 1'b0;
				assign w_com_pld_pcs_if_usrrstsel = 1'b1;// connected when sv_hssi_common_pld_pcs_interface is not instantiated
		end // if not generate
		
		// instantiating sv_hssi_gen3_tx_pcs
		if ((enable_gen3_tx == "true") || (enable_dyn_reconfig == "true")) begin
			stratixv_hssi_gen3_tx_pcs #(
				.encoder(pcs_g3_tx_encoder),
				.mode(pcs_g3_tx_mode),
				.prbs_generator(pcs_g3_tx_prbs_generator),
				.reverse_lpbk(pcs_g3_tx_reverse_lpbk),
				.scrambler(pcs_g3_tx_scrambler),
				.sup_mode(pcs_g3_tx_sup_mode),
				.tx_bitslip(pcs_g3_tx_tx_bitslip),
				.tx_bitslip_data(pcs_g3_tx_tx_bitslip_data),
				.tx_clk_sel(pcs_g3_tx_tx_clk_sel),
				.tx_g3_dcbal(pcs_g3_tx_tx_g3_dcbal),
				.tx_gbox_byp(pcs_g3_tx_tx_gbox_byp),
				.tx_lane_num(pcs_g3_tx_tx_lane_num),
				.tx_pol_compl(pcs_g3_tx_tx_pol_compl),
				.use_default_base_address(pcs_g3_tx_use_default_base_address),
				.user_base_address(pcs_g3_tx_user_base_address)
			) inst_sv_hssi_gen3_tx_pcs (
				// OUTPUTS
				.avmmreaddata(w_pcs_g3_tx_avmmreaddata),
				.blockselect(w_pcs_g3_tx_blockselect),
				.dataout(w_pcs_g3_tx_dataout),
				.errencode(w_pcs_g3_tx_errencode),
				.parlpbkb4gbout(w_pcs_g3_tx_parlpbkb4gbout),
				.parlpbkout(w_pcs_g3_tx_parlpbkout),
				.txtestout(w_pcs_g3_tx_txtestout),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.blkstartin(w_pipe3_txblkstartint),
				.datain({w_pipe3_txdataint[31], w_pipe3_txdataint[30], w_pipe3_txdataint[29], w_pipe3_txdataint[28], w_pipe3_txdataint[27], w_pipe3_txdataint[26], w_pipe3_txdataint[25], w_pipe3_txdataint[24], w_pipe3_txdataint[23], w_pipe3_txdataint[22], w_pipe3_txdataint[21], w_pipe3_txdataint[20], w_pipe3_txdataint[19], w_pipe3_txdataint[18], w_pipe3_txdataint[17], w_pipe3_txdataint[16], w_pipe3_txdataint[15], w_pipe3_txdataint[14], w_pipe3_txdataint[13], w_pipe3_txdataint[12], w_pipe3_txdataint[11], w_pipe3_txdataint[10], w_pipe3_txdataint[9], w_pipe3_txdataint[8], w_pipe3_txdataint[7], w_pipe3_txdataint[6], w_pipe3_txdataint[5], w_pipe3_txdataint[4], w_pipe3_txdataint[3], w_pipe3_txdataint[2], w_pipe3_txdataint[1], w_pipe3_txdataint[0]}),
				.datavalid(w_pipe3_txdataskipint),
				.gen3clksel(w_pipe3_gen3clksel),
				.hardresetn(w_com_pld_pcs_if_pcsgen3hardreset),
				.lpbkblkstart(w_pcs_g3_rx_lpbkblkstart),
				.lpbkdatain({w_pcs_g3_rx_lpbkdata[33], w_pcs_g3_rx_lpbkdata[32], w_pcs_g3_rx_lpbkdata[31], w_pcs_g3_rx_lpbkdata[30], w_pcs_g3_rx_lpbkdata[29], w_pcs_g3_rx_lpbkdata[28], w_pcs_g3_rx_lpbkdata[27], w_pcs_g3_rx_lpbkdata[26], w_pcs_g3_rx_lpbkdata[25], w_pcs_g3_rx_lpbkdata[24], w_pcs_g3_rx_lpbkdata[23], w_pcs_g3_rx_lpbkdata[22], w_pcs_g3_rx_lpbkdata[21], w_pcs_g3_rx_lpbkdata[20], w_pcs_g3_rx_lpbkdata[19], w_pcs_g3_rx_lpbkdata[18], w_pcs_g3_rx_lpbkdata[17], w_pcs_g3_rx_lpbkdata[16], w_pcs_g3_rx_lpbkdata[15], w_pcs_g3_rx_lpbkdata[14], w_pcs_g3_rx_lpbkdata[13], w_pcs_g3_rx_lpbkdata[12], w_pcs_g3_rx_lpbkdata[11], w_pcs_g3_rx_lpbkdata[10], w_pcs_g3_rx_lpbkdata[9], w_pcs_g3_rx_lpbkdata[8], w_pcs_g3_rx_lpbkdata[7], w_pcs_g3_rx_lpbkdata[6], w_pcs_g3_rx_lpbkdata[5], w_pcs_g3_rx_lpbkdata[4], w_pcs_g3_rx_lpbkdata[3], w_pcs_g3_rx_lpbkdata[2], w_pcs_g3_rx_lpbkdata[1], w_pcs_g3_rx_lpbkdata[0]}),
				.lpbkdatavalid(w_pcs_g3_rx_lpbkdatavalid),
				.lpbken(w_pipe3_revlpbkint),
				.pcsrst(w_pipe3_pcsrst),
				.scanmoden(w_com_pld_pcs_if_pcsgen3scanmoden),
				.shutdownclk(w_pipe3_shutdownclk),
				.syncin({w_pipe3_txsynchdrint[1], w_pipe3_txsynchdrint[0]}),
				.txelecidle(w_pcs8g_tx_txelecidleout),
				.txpmaclk(w_pcs8g_tx_clkoutgen3),
				.txrstn(w_tx_pld_pcs_if_pcsgen3txrst)
			);
		end // if generate
		else begin
				assign w_pcs_g3_tx_avmmreaddata[15:0] = 16'b0;
				assign w_pcs_g3_tx_blockselect = 1'b0;
				assign w_pcs_g3_tx_dataout[31:0] = 32'b0;
				assign w_pcs_g3_tx_errencode = 1'b0;
				assign w_pcs_g3_tx_parlpbkb4gbout[35:0] = 36'b0;
				assign w_pcs_g3_tx_parlpbkout[31:0] = 32'b0;
				assign w_pcs_g3_tx_txtestout[19:0] = 20'b0;
		end // if not generate
		
		// instantiating sv_hssi_rx_pld_pcs_interface
		if ((enable_10g_rx == "true") || (enable_8g_rx == "true") || (enable_pma_direct_rx == "true") || (enable_dyn_reconfig == "true")) begin
			sv_hssi_rx_pld_pcs_interface_rbc #(
				.data_source(rx_pld_pcs_if_data_source),
				.is_10g_0ppm(rx_pld_pcs_if_is_10g_0ppm),
				.is_8g_0ppm(rx_pld_pcs_if_is_8g_0ppm),
				.selectpcs(rx_pld_pcs_if_selectpcs),
				.use_default_base_address(rx_pld_pcs_if_use_default_base_address),
				.user_base_address(rx_pld_pcs_if_user_base_address)
			) inst_sv_hssi_rx_pld_pcs_interface (
				// OUTPUTS
				.avmmreaddata(w_rx_pld_pcs_if_avmmreaddata),
				.blockselect(w_rx_pld_pcs_if_blockselect),
				.dataouttopld(w_rx_pld_pcs_if_dataouttopld),
				.emsiprxclkout(w_rx_pld_pcs_if_emsiprxclkout),
				.emsiprxout(w_rx_pld_pcs_if_emsiprxout),
				.emsiprxspecialout(w_rx_pld_pcs_if_emsiprxspecialout),
				.pcs10grxalignclr(w_rx_pld_pcs_if_pcs10grxalignclr),
				.pcs10grxalignen(w_rx_pld_pcs_if_pcs10grxalignen),
				.pcs10grxbitslip(w_rx_pld_pcs_if_pcs10grxbitslip),
				.pcs10grxclrbercount(w_rx_pld_pcs_if_pcs10grxclrbercount),
				.pcs10grxclrerrblkcnt(w_rx_pld_pcs_if_pcs10grxclrerrblkcnt),
				.pcs10grxdispclr(w_rx_pld_pcs_if_pcs10grxdispclr),
				.pcs10grxpldclk(w_rx_pld_pcs_if_pcs10grxpldclk),
				.pcs10grxpldrstn(w_rx_pld_pcs_if_pcs10grxpldrstn),
				.pcs10grxprbserrclr(w_rx_pld_pcs_if_pcs10grxprbserrclr),
				.pcs10grxrden(w_rx_pld_pcs_if_pcs10grxrden),
				.pcs8ga1a2size(w_rx_pld_pcs_if_pcs8ga1a2size),
				.pcs8gbitlocreven(w_rx_pld_pcs_if_pcs8gbitlocreven),
				.pcs8gbitslip(w_rx_pld_pcs_if_pcs8gbitslip),
				.pcs8gbytereven(w_rx_pld_pcs_if_pcs8gbytereven),
				.pcs8gbytordpld(w_rx_pld_pcs_if_pcs8gbytordpld),
				.pcs8gcmpfifourst(w_rx_pld_pcs_if_pcs8gcmpfifourst),
				.pcs8gencdt(w_rx_pld_pcs_if_pcs8gencdt),
				.pcs8gphfifourstrx(w_rx_pld_pcs_if_pcs8gphfifourstrx),
				.pcs8gpldrxclk(w_rx_pld_pcs_if_pcs8gpldrxclk),
				.pcs8gpolinvrx(w_rx_pld_pcs_if_pcs8gpolinvrx),
				.pcs8grdenablerx(w_rx_pld_pcs_if_pcs8grdenablerx),
				.pcs8grxurstpcs(w_rx_pld_pcs_if_pcs8grxurstpcs),
				.pcs8gsyncsmenoutput(w_rx_pld_pcs_if_pcs8gsyncsmenoutput),
				.pcs8gwrdisablerx(w_rx_pld_pcs_if_pcs8gwrdisablerx),
				.pcsgen3rxrst(w_rx_pld_pcs_if_pcsgen3rxrst),
				.pcsgen3syncsmen(w_rx_pld_pcs_if_pcsgen3syncsmen),
				.pld10grxalignval(w_rx_pld_pcs_if_pld10grxalignval),
				.pld10grxblklock(w_rx_pld_pcs_if_pld10grxblklock),
				.pld10grxclkout(w_rx_pld_pcs_if_pld10grxclkout),
				.pld10grxcontrol(w_rx_pld_pcs_if_pld10grxcontrol),
				.pld10grxcrc32err(w_rx_pld_pcs_if_pld10grxcrc32err),
				.pld10grxdatavalid(w_rx_pld_pcs_if_pld10grxdatavalid),
				.pld10grxdiagerr(w_rx_pld_pcs_if_pld10grxdiagerr),
				.pld10grxdiagstatus(w_rx_pld_pcs_if_pld10grxdiagstatus),
				.pld10grxempty(w_rx_pld_pcs_if_pld10grxempty),
				.pld10grxfifodel(w_rx_pld_pcs_if_pld10grxfifodel),
				.pld10grxfifoinsert(w_rx_pld_pcs_if_pld10grxfifoinsert),
				.pld10grxframelock(w_rx_pld_pcs_if_pld10grxframelock),
				.pld10grxhiber(w_rx_pld_pcs_if_pld10grxhiber),
				.pld10grxmfrmerr(w_rx_pld_pcs_if_pld10grxmfrmerr),
				.pld10grxoflwerr(w_rx_pld_pcs_if_pld10grxoflwerr),
				.pld10grxpempty(w_rx_pld_pcs_if_pld10grxpempty),
				.pld10grxpfull(w_rx_pld_pcs_if_pld10grxpfull),
				.pld10grxprbserr(w_rx_pld_pcs_if_pld10grxprbserr),
				.pld10grxpyldins(w_rx_pld_pcs_if_pld10grxpyldins),
				.pld10grxrdnegsts(w_rx_pld_pcs_if_pld10grxrdnegsts),
				.pld10grxrdpossts(w_rx_pld_pcs_if_pld10grxrdpossts),
				.pld10grxrxframe(w_rx_pld_pcs_if_pld10grxrxframe),
				.pld10grxscrmerr(w_rx_pld_pcs_if_pld10grxscrmerr),
				.pld10grxsherr(w_rx_pld_pcs_if_pld10grxsherr),
				.pld10grxskiperr(w_rx_pld_pcs_if_pld10grxskiperr),
				.pld10grxskipins(w_rx_pld_pcs_if_pld10grxskipins),
				.pld10grxsyncerr(w_rx_pld_pcs_if_pld10grxsyncerr),
				.pld8ga1a2k1k2flag(w_rx_pld_pcs_if_pld8ga1a2k1k2flag),
				.pld8galignstatus(w_rx_pld_pcs_if_pld8galignstatus),
				.pld8gbistdone(w_rx_pld_pcs_if_pld8gbistdone),
				.pld8gbisterr(w_rx_pld_pcs_if_pld8gbisterr),
				.pld8gbyteordflag(w_rx_pld_pcs_if_pld8gbyteordflag),
				.pld8gemptyrmf(w_rx_pld_pcs_if_pld8gemptyrmf),
				.pld8gemptyrx(w_rx_pld_pcs_if_pld8gemptyrx),
				.pld8gfullrmf(w_rx_pld_pcs_if_pld8gfullrmf),
				.pld8gfullrx(w_rx_pld_pcs_if_pld8gfullrx),
				.pld8grlvlt(w_rx_pld_pcs_if_pld8grlvlt),
				.pld8grxblkstart(w_rx_pld_pcs_if_pld8grxblkstart),
				.pld8grxclkout(w_rx_pld_pcs_if_pld8grxclkout),
				.pld8grxdatavalid(w_rx_pld_pcs_if_pld8grxdatavalid),
				.pld8grxsynchdr(w_rx_pld_pcs_if_pld8grxsynchdr),
				.pld8gsignaldetectout(w_rx_pld_pcs_if_pld8gsignaldetectout),
				.pld8gwaboundary(w_rx_pld_pcs_if_pld8gwaboundary),
				.pldclkdiv33txorrx(w_rx_pld_pcs_if_pldclkdiv33txorrx),
				.pldrxclkslipout(w_rx_pld_pcs_if_pldrxclkslipout),
				.pldrxiqclkout(w_rx_pld_pcs_if_pldrxiqclkout),
				.pldrxpmarstbout(w_rx_pld_pcs_if_pldrxpmarstbout),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.clockinfrom10gpcs(w_pcs10g_rx_rxclkout),
				.clockinfrom8gpcs(w_pcs8g_rx_clocktopld),
				.datainfrom10gpcs({w_pcs10g_rx_rxdata[63], w_pcs10g_rx_rxdata[62], w_pcs10g_rx_rxdata[61], w_pcs10g_rx_rxdata[60], w_pcs10g_rx_rxdata[59], w_pcs10g_rx_rxdata[58], w_pcs10g_rx_rxdata[57], w_pcs10g_rx_rxdata[56], w_pcs10g_rx_rxdata[55], w_pcs10g_rx_rxdata[54], w_pcs10g_rx_rxdata[53], w_pcs10g_rx_rxdata[52], w_pcs10g_rx_rxdata[51], w_pcs10g_rx_rxdata[50], w_pcs10g_rx_rxdata[49], w_pcs10g_rx_rxdata[48], w_pcs10g_rx_rxdata[47], w_pcs10g_rx_rxdata[46], w_pcs10g_rx_rxdata[45], w_pcs10g_rx_rxdata[44], w_pcs10g_rx_rxdata[43], w_pcs10g_rx_rxdata[42], w_pcs10g_rx_rxdata[41], w_pcs10g_rx_rxdata[40], w_pcs10g_rx_rxdata[39], w_pcs10g_rx_rxdata[38], w_pcs10g_rx_rxdata[37], w_pcs10g_rx_rxdata[36], w_pcs10g_rx_rxdata[35], w_pcs10g_rx_rxdata[34], w_pcs10g_rx_rxdata[33], w_pcs10g_rx_rxdata[32], w_pcs10g_rx_rxdata[31], w_pcs10g_rx_rxdata[30], w_pcs10g_rx_rxdata[29], w_pcs10g_rx_rxdata[28], w_pcs10g_rx_rxdata[27], w_pcs10g_rx_rxdata[26], w_pcs10g_rx_rxdata[25], w_pcs10g_rx_rxdata[24], w_pcs10g_rx_rxdata[23], w_pcs10g_rx_rxdata[22], w_pcs10g_rx_rxdata[21], w_pcs10g_rx_rxdata[20], w_pcs10g_rx_rxdata[19], w_pcs10g_rx_rxdata[18], w_pcs10g_rx_rxdata[17], w_pcs10g_rx_rxdata[16], w_pcs10g_rx_rxdata[15], w_pcs10g_rx_rxdata[14], w_pcs10g_rx_rxdata[13], w_pcs10g_rx_rxdata[12], w_pcs10g_rx_rxdata[11], w_pcs10g_rx_rxdata[10], w_pcs10g_rx_rxdata[9], w_pcs10g_rx_rxdata[8], w_pcs10g_rx_rxdata[7], w_pcs10g_rx_rxdata[6], w_pcs10g_rx_rxdata[5], w_pcs10g_rx_rxdata[4], w_pcs10g_rx_rxdata[3], w_pcs10g_rx_rxdata[2], w_pcs10g_rx_rxdata[1], w_pcs10g_rx_rxdata[0]}),
				.datainfrom8gpcs({w_pcs8g_rx_dataout[63], w_pcs8g_rx_dataout[62], w_pcs8g_rx_dataout[61], w_pcs8g_rx_dataout[60], w_pcs8g_rx_dataout[59], w_pcs8g_rx_dataout[58], w_pcs8g_rx_dataout[57], w_pcs8g_rx_dataout[56], w_pcs8g_rx_dataout[55], w_pcs8g_rx_dataout[54], w_pcs8g_rx_dataout[53], w_pcs8g_rx_dataout[52], w_pcs8g_rx_dataout[51], w_pcs8g_rx_dataout[50], w_pcs8g_rx_dataout[49], w_pcs8g_rx_dataout[48], w_pcs8g_rx_dataout[47], w_pcs8g_rx_dataout[46], w_pcs8g_rx_dataout[45], w_pcs8g_rx_dataout[44], w_pcs8g_rx_dataout[43], w_pcs8g_rx_dataout[42], w_pcs8g_rx_dataout[41], w_pcs8g_rx_dataout[40], w_pcs8g_rx_dataout[39], w_pcs8g_rx_dataout[38], w_pcs8g_rx_dataout[37], w_pcs8g_rx_dataout[36], w_pcs8g_rx_dataout[35], w_pcs8g_rx_dataout[34], w_pcs8g_rx_dataout[33], w_pcs8g_rx_dataout[32], w_pcs8g_rx_dataout[31], w_pcs8g_rx_dataout[30], w_pcs8g_rx_dataout[29], w_pcs8g_rx_dataout[28], w_pcs8g_rx_dataout[27], w_pcs8g_rx_dataout[26], w_pcs8g_rx_dataout[25], w_pcs8g_rx_dataout[24], w_pcs8g_rx_dataout[23], w_pcs8g_rx_dataout[22], w_pcs8g_rx_dataout[21], w_pcs8g_rx_dataout[20], w_pcs8g_rx_dataout[19], w_pcs8g_rx_dataout[18], w_pcs8g_rx_dataout[17], w_pcs8g_rx_dataout[16], w_pcs8g_rx_dataout[15], w_pcs8g_rx_dataout[14], w_pcs8g_rx_dataout[13], w_pcs8g_rx_dataout[12], w_pcs8g_rx_dataout[11], w_pcs8g_rx_dataout[10], w_pcs8g_rx_dataout[9], w_pcs8g_rx_dataout[8], w_pcs8g_rx_dataout[7], w_pcs8g_rx_dataout[6], w_pcs8g_rx_dataout[5], w_pcs8g_rx_dataout[4], w_pcs8g_rx_dataout[3], w_pcs8g_rx_dataout[2], w_pcs8g_rx_dataout[1], w_pcs8g_rx_dataout[0]}),
				.emsipenablediocsrrdydly(w_com_pld_pcs_if_emsipenablediocsrrdydly),
				.emsiprxclkin({in_emsip_rx_clk_in[2], in_emsip_rx_clk_in[1], in_emsip_rx_clk_in[0]}),
				.emsiprxin({in_emsip_rx_in[19], in_emsip_rx_in[18], in_emsip_rx_in[17], in_emsip_rx_in[16], in_emsip_rx_in[15], in_emsip_rx_in[14], in_emsip_rx_in[13], in_emsip_rx_in[12], in_emsip_rx_in[11], in_emsip_rx_in[10], in_emsip_rx_in[9], in_emsip_rx_in[8], in_emsip_rx_in[7], in_emsip_rx_in[6], in_emsip_rx_in[5], in_emsip_rx_in[4], in_emsip_rx_in[3], in_emsip_rx_in[2], in_emsip_rx_in[1], in_emsip_rx_in[0]}),
				.emsiprxspecialin({in_emsip_rx_special_in[12], in_emsip_rx_special_in[11], in_emsip_rx_special_in[10], in_emsip_rx_special_in[9], in_emsip_rx_special_in[8], in_emsip_rx_special_in[7], in_emsip_rx_special_in[6], in_emsip_rx_special_in[5], in_emsip_rx_special_in[4], in_emsip_rx_special_in[3], in_emsip_rx_special_in[2], in_emsip_rx_special_in[1], in_emsip_rx_special_in[0]}),
				.pcs10grxalignval(w_pcs10g_rx_rxalignval),
				.pcs10grxblklock(w_pcs10g_rx_rxblocklock),
				.pcs10grxcontrol({w_pcs10g_rx_rxcontrol[9], w_pcs10g_rx_rxcontrol[8], w_pcs10g_rx_rxcontrol[7], w_pcs10g_rx_rxcontrol[6], w_pcs10g_rx_rxcontrol[5], w_pcs10g_rx_rxcontrol[4], w_pcs10g_rx_rxcontrol[3], w_pcs10g_rx_rxcontrol[2], w_pcs10g_rx_rxcontrol[1], w_pcs10g_rx_rxcontrol[0]}),
				.pcs10grxcrc32err(w_pcs10g_rx_rxcrc32error),
				.pcs10grxdatavalid(w_pcs10g_rx_rxdatavalid),
				.pcs10grxdiagerr(w_pcs10g_rx_rxdiagnosticerror),
				.pcs10grxdiagstatus({w_pcs10g_rx_rxdiagnosticstatus[1], w_pcs10g_rx_rxdiagnosticstatus[0]}),
				.pcs10grxempty(w_pcs10g_rx_rxfifoempty),
				.pcs10grxfifodel(w_pcs10g_rx_rxfifodel),
				.pcs10grxfifoinsert(w_pcs10g_rx_rxfifoinsert),
				.pcs10grxframelock(w_pcs10g_rx_rxframelock),
				.pcs10grxhiber(w_pcs10g_rx_rxhighber),
				.pcs10grxmfrmerr(w_pcs10g_rx_rxmetaframeerror),
				.pcs10grxoflwerr(w_pcs10g_rx_rxfifofull),
				.pcs10grxpempty(w_pcs10g_rx_rxfifopartialempty),
				.pcs10grxpfull(w_pcs10g_rx_rxfifopartialfull),
				.pcs10grxprbserr(w_pcs10g_rx_rxprbserr),
				.pcs10grxpyldins(w_pcs10g_rx_rxpayloadinserted),
				.pcs10grxrdnegsts(w_pcs10g_rx_rxrdnegsts),
				.pcs10grxrdpossts(w_pcs10g_rx_rxrdpossts),
				.pcs10grxrxframe(w_pcs10g_rx_rxrxframe),
				.pcs10grxscrmerr(w_pcs10g_rx_rxscramblererror),
				.pcs10grxsherr(w_pcs10g_rx_rxsyncheadererror),
				.pcs10grxskiperr(w_pcs10g_rx_rxskipworderror),
				.pcs10grxskipins(w_pcs10g_rx_rxskipinserted),
				.pcs10grxsyncerr(w_pcs10g_rx_rxsyncworderror),
				.pcs8ga1a2k1k2flag({w_pcs8g_rx_a1a2k1k2flag[3], w_pcs8g_rx_a1a2k1k2flag[2], w_pcs8g_rx_a1a2k1k2flag[1], w_pcs8g_rx_a1a2k1k2flag[0]}),
				.pcs8galignstatus(w_pcs8g_rx_alignstatuspld),
				.pcs8gbistdone(w_pcs8g_rx_bistdone),
				.pcs8gbisterr(w_pcs8g_rx_bisterr),
				.pcs8gbyteordflag(w_pcs8g_rx_byteordflag),
				.pcs8gemptyrmf(w_pcs8g_rx_rmfifoempty),
				.pcs8gemptyrx(w_pcs8g_rx_pcfifoempty),
				.pcs8gfullrmf(w_pcs8g_rx_rmfifofull),
				.pcs8gfullrx(w_pcs8g_rx_pcfifofull),
				.pcs8grlvlt(w_pcs8g_rx_rlvlt),
				.pcs8grxblkstart({w_pcs8g_rx_rxblkstart[3], w_pcs8g_rx_rxblkstart[2], w_pcs8g_rx_rxblkstart[1], w_pcs8g_rx_rxblkstart[0]}),
				.pcs8grxdatavalid({w_pcs8g_rx_rxdatavalid[3], w_pcs8g_rx_rxdatavalid[2], w_pcs8g_rx_rxdatavalid[1], w_pcs8g_rx_rxdatavalid[0]}),
				.pcs8grxsynchdr({w_pcs8g_rx_rxsynchdr[1], w_pcs8g_rx_rxsynchdr[0]}),
				.pcs8gsignaldetectout(w_pcs8g_rx_signaldetectout),
				.pcs8gwaboundary({w_pcs8g_rx_wordalignboundary[4], w_pcs8g_rx_wordalignboundary[3], w_pcs8g_rx_wordalignboundary[2], w_pcs8g_rx_wordalignboundary[1], w_pcs8g_rx_wordalignboundary[0]}),
				.pld10grxalignclr(in_pld_10g_rx_align_clr),
				.pld10grxalignen(in_pld_10g_rx_align_en),
				.pld10grxbitslip(in_pld_10g_rx_bitslip),
				.pld10grxclrbercount(in_pld_10g_rx_clr_ber_count),
				.pld10grxclrerrblkcnt(in_pld_10g_rx_clr_errblk_cnt),
				.pld10grxdispclr(in_pld_10g_rx_disp_clr),
				.pld10grxpldclk(in_pld_10g_rx_pld_clk),
				.pld10grxpldrstn(in_pld_10g_rx_rst_n),
				.pld10grxprbserrclr(in_pld_10g_rx_prbs_err_clr),
				.pld10grxrden(in_pld_10g_rx_rd_en),
				.pld8ga1a2size(in_pld_8g_a1a2_size),
				.pld8gbitlocreven(in_pld_8g_bitloc_rev_en),
				.pld8gbitslip(in_pld_8g_bitslip),
				.pld8gbytereven(in_pld_8g_byte_rev_en),
				.pld8gbytordpld(in_pld_8g_bytordpld),
				.pld8gcmpfifourstn(in_pld_8g_cmpfifourst_n),
				.pld8gencdt(in_pld_8g_encdt),
				.pld8gphfifourstrxn(in_pld_8g_phfifourst_rx_n),
				.pld8gpldrxclk(in_pld_8g_pld_rx_clk),
				.pld8gpolinvrx(in_pld_8g_polinv_rx),
				.pld8grdenablermf(in_pld_8g_rdenable_rmf),
				.pld8grdenablerx(in_pld_8g_rdenable_rx),
				.pld8grxurstpcsn(in_pld_8g_rxurstpcs_n),
				.pld8gsyncsmeninput(in_pld_sync_sm_en),
				.pld8gwrdisablerx(in_pld_8g_wrdisable_rx),
				.pld8gwrenablermf(in_pld_8g_wrenable_rmf),
				.pldgen3rxrstn(in_pld_gen3_rx_rstn),
				.pldrxclkslipin(in_pld_rx_clk_slip_in),
				.pldrxpmarstbin(in_pld_rxpma_rstb_in),
				.pmaclkdiv33txorrx(w_rx_pcs_pma_if_pmaclkdiv33txorrxout),
				.pmarxplllock(w_rx_pcs_pma_if_pmarxpllphaselockout),
				.rstsel(w_com_pld_pcs_if_rstsel),
				.usrrstsel(w_com_pld_pcs_if_usrrstsel),
				
				// UNUSEDs
				.asynchdatain( /*unused*/ ),
				.pcs8gphystatus( /*unused*/ ),
				.pcs8grdenablermf( /*unused*/ ),
				.pcs8grxelecidle( /*unused*/ ),
				.pcs8grxstatus( /*unused*/ ),
				.pcs8grxvalid( /*unused*/ ),
				.pcs8gwrenablermf( /*unused*/ ),
				.pcsgen3rxrstn( /*unused*/ ),
				.pcsgen3rxupdatefc( /*unused*/ ),
				.pldgen3rxupdatefc( /*unused*/ ),
				.reset( /*unused*/ )
			);
		end // if generate
		else begin
				assign w_rx_pld_pcs_if_avmmreaddata[15:0] = 16'b0;
				assign w_rx_pld_pcs_if_blockselect = 1'b0;
				assign w_rx_pld_pcs_if_dataouttopld[63:0] = 64'b0;
				assign w_rx_pld_pcs_if_emsiprxclkout[2:0] = 3'b0;
				assign w_rx_pld_pcs_if_emsiprxout[128:0] = 129'b0;
				assign w_rx_pld_pcs_if_emsiprxspecialout[15:0] = 16'b0;
				assign w_rx_pld_pcs_if_pcs10grxalignclr = 1'b0;
				assign w_rx_pld_pcs_if_pcs10grxalignen = 1'b0;
				assign w_rx_pld_pcs_if_pcs10grxbitslip = 1'b0;
				assign w_rx_pld_pcs_if_pcs10grxclrbercount = 1'b0;
				assign w_rx_pld_pcs_if_pcs10grxclrerrblkcnt = 1'b0;
				assign w_rx_pld_pcs_if_pcs10grxdispclr = 1'b0;
				assign w_rx_pld_pcs_if_pcs10grxpldclk = 1'b0;
				assign w_rx_pld_pcs_if_pcs10grxpldrstn = 1'b0;
				assign w_rx_pld_pcs_if_pcs10grxprbserrclr = 1'b0;
				assign w_rx_pld_pcs_if_pcs10grxrden = 1'b0;
				assign w_rx_pld_pcs_if_pcs8ga1a2size = 1'b0;
				assign w_rx_pld_pcs_if_pcs8gbitlocreven = 1'b0;
				assign w_rx_pld_pcs_if_pcs8gbitslip = 1'b0;
				assign w_rx_pld_pcs_if_pcs8gbytereven = 1'b0;
				assign w_rx_pld_pcs_if_pcs8gbytordpld = 1'b0;
				assign w_rx_pld_pcs_if_pcs8gcmpfifourst = 1'b0;
				assign w_rx_pld_pcs_if_pcs8gencdt = 1'b0;
				assign w_rx_pld_pcs_if_pcs8gphfifourstrx = 1'b0;
				assign w_rx_pld_pcs_if_pcs8gpldrxclk = 1'b0;
				assign w_rx_pld_pcs_if_pcs8gpolinvrx = 1'b0;
				assign w_rx_pld_pcs_if_pcs8grdenablerx = 1'b0;
				assign w_rx_pld_pcs_if_pcs8grxurstpcs = 1'b0;
				assign w_rx_pld_pcs_if_pcs8gsyncsmenoutput = 1'b0;
				assign w_rx_pld_pcs_if_pcs8gwrdisablerx = 1'b0;
				assign w_rx_pld_pcs_if_pcsgen3rxrst = 1'b0;
				assign w_rx_pld_pcs_if_pcsgen3syncsmen = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxalignval = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxblklock = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxclkout = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxcontrol[9:0] = 10'b0;
				assign w_rx_pld_pcs_if_pld10grxcrc32err = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxdatavalid = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxdiagerr = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxdiagstatus[1:0] = 2'b0;
				assign w_rx_pld_pcs_if_pld10grxempty = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxfifodel = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxfifoinsert = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxframelock = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxhiber = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxmfrmerr = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxoflwerr = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxpempty = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxpfull = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxprbserr = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxpyldins = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxrdnegsts = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxrdpossts = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxrxframe = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxscrmerr = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxsherr = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxskiperr = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxskipins = 1'b0;
				assign w_rx_pld_pcs_if_pld10grxsyncerr = 1'b0;
				assign w_rx_pld_pcs_if_pld8ga1a2k1k2flag[3:0] = 4'b0;
				assign w_rx_pld_pcs_if_pld8galignstatus = 1'b0;
				assign w_rx_pld_pcs_if_pld8gbistdone = 1'b0;
				assign w_rx_pld_pcs_if_pld8gbisterr = 1'b0;
				assign w_rx_pld_pcs_if_pld8gbyteordflag = 1'b0;
				assign w_rx_pld_pcs_if_pld8gemptyrmf = 1'b0;
				assign w_rx_pld_pcs_if_pld8gemptyrx = 1'b0;
				assign w_rx_pld_pcs_if_pld8gfullrmf = 1'b0;
				assign w_rx_pld_pcs_if_pld8gfullrx = 1'b0;
				assign w_rx_pld_pcs_if_pld8grlvlt = 1'b0;
				assign w_rx_pld_pcs_if_pld8grxblkstart[3:0] = 4'b0;
				assign w_rx_pld_pcs_if_pld8grxclkout = 1'b0;
				assign w_rx_pld_pcs_if_pld8grxdatavalid[3:0] = 4'b0;
				assign w_rx_pld_pcs_if_pld8grxsynchdr[1:0] = 2'b0;
				assign w_rx_pld_pcs_if_pld8gsignaldetectout = 1'b0;
				assign w_rx_pld_pcs_if_pld8gwaboundary[4:0] = 5'b0;
				assign w_rx_pld_pcs_if_pldclkdiv33txorrx = 1'b0;
				assign w_rx_pld_pcs_if_pldrxclkslipout = 1'b0;
				assign w_rx_pld_pcs_if_pldrxiqclkout = 1'b0;
				assign w_rx_pld_pcs_if_pldrxpmarstbout = 1'b0;
		end // if not generate
		
		// instantiating sv_hssi_rx_pcs_pma_interface
		if ((enable_10g_rx == "true") || (enable_8g_rx == "true") || (enable_pma_direct_rx == "true") || (enable_dyn_reconfig == "true")) begin
			sv_hssi_rx_pcs_pma_interface_rbc #(
				.clkslip_sel(rx_pcs_pma_if_clkslip_sel),
				.prot_mode(rx_pcs_pma_if_prot_mode),
				.selectpcs(rx_pcs_pma_if_selectpcs),
				.use_default_base_address(rx_pcs_pma_if_use_default_base_address),
				.user_base_address(rx_pcs_pma_if_user_base_address)
			) inst_sv_hssi_rx_pcs_pma_interface (
				// OUTPUTS
				.avmmreaddata(w_rx_pcs_pma_if_avmmreaddata),
				.blockselect(w_rx_pcs_pma_if_blockselect),
				.clkoutto10gpcs(w_rx_pcs_pma_if_clkoutto10gpcs),
				.clockoutto8gpcs(w_rx_pcs_pma_if_clockoutto8gpcs),
				.clockouttogen3pcs(w_rx_pcs_pma_if_clockouttogen3pcs),
				.dataoutto10gpcs(w_rx_pcs_pma_if_dataoutto10gpcs),
				.dataoutto8gpcs(w_rx_pcs_pma_if_dataoutto8gpcs),
				.dataouttogen3pcs(w_rx_pcs_pma_if_dataouttogen3pcs),
				.pcs10gclkdiv33txorrx(w_rx_pcs_pma_if_pcs10gclkdiv33txorrx),
				.pcs10gsignalok(w_rx_pcs_pma_if_pcs10gsignalok),
				.pcs8gsigdetni(w_rx_pcs_pma_if_pcs8gsigdetni),
				.pcsgen3pmasignaldet(w_rx_pcs_pma_if_pcsgen3pmasignaldet),
				.pmaclkdiv33txorrxout(w_rx_pcs_pma_if_pmaclkdiv33txorrxout),
				.pmaeyemonitorout(w_rx_pcs_pma_if_pmaeyemonitorout),
				.pmareservedout(w_rx_pcs_pma_if_pmareservedout),
				.pmarxclkout(w_rx_pcs_pma_if_pmarxclkout),
				.pmarxclkslip(w_rx_pcs_pma_if_pmarxclkslip),
				.pmarxpllphaselockout(w_rx_pcs_pma_if_pmarxpllphaselockout),
				.pmarxpmarstb(w_rx_pcs_pma_if_pmarxpmarstb),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.clockinfrompma(in_pma_rx_pma_clk),
				.datainfrompma({in_pma_rx_data[79], in_pma_rx_data[78], in_pma_rx_data[77], in_pma_rx_data[76], in_pma_rx_data[75], in_pma_rx_data[74], in_pma_rx_data[73], in_pma_rx_data[72], in_pma_rx_data[71], in_pma_rx_data[70], in_pma_rx_data[69], in_pma_rx_data[68], in_pma_rx_data[67], in_pma_rx_data[66], in_pma_rx_data[65], in_pma_rx_data[64], in_pma_rx_data[63], in_pma_rx_data[62], in_pma_rx_data[61], in_pma_rx_data[60], in_pma_rx_data[59], in_pma_rx_data[58], in_pma_rx_data[57], in_pma_rx_data[56], in_pma_rx_data[55], in_pma_rx_data[54], in_pma_rx_data[53], in_pma_rx_data[52], in_pma_rx_data[51], in_pma_rx_data[50], in_pma_rx_data[49], in_pma_rx_data[48], in_pma_rx_data[47], in_pma_rx_data[46], in_pma_rx_data[45], in_pma_rx_data[44], in_pma_rx_data[43], in_pma_rx_data[42], in_pma_rx_data[41], in_pma_rx_data[40], in_pma_rx_data[39], in_pma_rx_data[38], in_pma_rx_data[37], in_pma_rx_data[36], in_pma_rx_data[35], in_pma_rx_data[34], in_pma_rx_data[33], in_pma_rx_data[32], in_pma_rx_data[31], in_pma_rx_data[30], in_pma_rx_data[29], in_pma_rx_data[28], in_pma_rx_data[27], in_pma_rx_data[26], in_pma_rx_data[25], in_pma_rx_data[24], in_pma_rx_data[23], in_pma_rx_data[22], in_pma_rx_data[21], in_pma_rx_data[20], in_pma_rx_data[19], in_pma_rx_data[18], in_pma_rx_data[17], in_pma_rx_data[16], in_pma_rx_data[15], in_pma_rx_data[14], in_pma_rx_data[13], in_pma_rx_data[12], in_pma_rx_data[11], in_pma_rx_data[10], in_pma_rx_data[9], in_pma_rx_data[8], in_pma_rx_data[7], in_pma_rx_data[6], in_pma_rx_data[5], in_pma_rx_data[4], in_pma_rx_data[3], in_pma_rx_data[2], in_pma_rx_data[1], in_pma_rx_data[0]}),
				.pcs10grxclkiqout(w_pcs10g_rx_rxclkiqout),
				.pcs8grxclkiqout(w_pcs8g_rx_clocktopld),
				.pcs8grxclkslip(w_pcs8g_rx_rxclkslip),
`ifdef ALTERA_RESERVED_QIS_ES
        			.pcsgen3eyemonitorout(),
`else 
				.pcsgen3eyemonitorout({w_tx_pld_pcs_if_pcsgen3txrst, 7'b0000000}),
`endif 
        			.pcsemsiprxclkiqout(w_tx_pld_pcs_if_pldtxiqclkout),
				.pldrxclkslip(w_rx_pld_pcs_if_pldrxclkslipout),
				.pldrxpmarstb(w_rx_pld_pcs_if_pldrxpmarstbout),
				.pmaclkdiv33txorrxin(in_pma_clkdiv33_txorrx_in),
				.pmaeyemonitorin({in_pma_eye_monitor_in[1], in_pma_eye_monitor_in[0]}),
				.pmareservedin({in_pma_reserved_in[4], in_pma_reserved_in[3], in_pma_reserved_in[2], in_pma_reserved_in[1], in_pma_reserved_in[0]}),
				.pmarxpllphaselockin(in_pma_rx_pll_phase_lock_in),
				.pmasigdet(in_pma_sigdet),
				.pmasignalok(in_pma_signal_ok),
				
				// UNUSEDs
				.asynchdatain(/*unused*/),
				.pcsgen3eyemonitorin(/*unused*/),
				.reset(/*unused*/)
			);
      
		end // if generate
		else begin
				assign w_rx_pcs_pma_if_avmmreaddata[15:0] = 16'b0;
				assign w_rx_pcs_pma_if_blockselect = 1'b0;
				assign w_rx_pcs_pma_if_clkoutto10gpcs = 1'b0;
				assign w_rx_pcs_pma_if_clockoutto8gpcs = 1'b0;
				assign w_rx_pcs_pma_if_clockouttogen3pcs = 1'b0;
				assign w_rx_pcs_pma_if_dataoutto10gpcs[79:0] = 80'b0;
				assign w_rx_pcs_pma_if_dataoutto8gpcs[19:0] = 20'b0;
				assign w_rx_pcs_pma_if_dataouttogen3pcs[31:0] = 32'b0;
				assign w_rx_pcs_pma_if_pcs10gclkdiv33txorrx = 1'b0;
				assign w_rx_pcs_pma_if_pcs10gsignalok = 1'b0;
				assign w_rx_pcs_pma_if_pcs8gsigdetni = 1'b0;
				assign w_rx_pcs_pma_if_pcsgen3pmasignaldet = 1'b0;
				assign w_rx_pcs_pma_if_pmaclkdiv33txorrxout = 1'b0;
				assign w_rx_pcs_pma_if_pmaeyemonitorout[7:0] = 8'b0;
				assign w_rx_pcs_pma_if_pmareservedout[4:0] = 5'b0;
				assign w_rx_pcs_pma_if_pmarxclkout = 1'b0;
				assign w_rx_pcs_pma_if_pmarxclkslip = 1'b0;
				assign w_rx_pcs_pma_if_pmarxpllphaselockout = 1'b0;
				assign w_rx_pcs_pma_if_pmarxpmarstb = 1'b0;
		end // if not generate
		
		// instantiating sv_hssi_gen3_rx_pcs
		if ((enable_gen3_rx == "true") || (enable_dyn_reconfig == "true")) begin
			stratixv_hssi_gen3_rx_pcs #(
				.block_sync(pcs_g3_rx_block_sync),
				.block_sync_sm(pcs_g3_rx_block_sync_sm),
				.decoder(pcs_g3_rx_decoder),
				.descrambler(pcs_g3_rx_descrambler),
				.descrambler_lfsr_check(pcs_g3_rx_descrambler_lfsr_check),
				.lpbk_force(pcs_g3_rx_lpbk_force),
				.mode(pcs_g3_rx_mode),
				.parallel_lpbk(pcs_g3_rx_parallel_lpbk),
				.rate_match_fifo(pcs_g3_rx_rate_match_fifo),
				.rate_match_fifo_latency(pcs_g3_rx_rate_match_fifo_latency),
				.reverse_lpbk(pcs_g3_rx_reverse_lpbk),
				.rmfifo_empty(pcs_g3_rx_rmfifo_empty),
				.rmfifo_empty_data(pcs_g3_rx_rmfifo_empty_data),
				.rmfifo_full(pcs_g3_rx_rmfifo_full),
				.rmfifo_full_data(pcs_g3_rx_rmfifo_full_data),
				.rmfifo_pempty(pcs_g3_rx_rmfifo_pempty),
				.rmfifo_pempty_data(pcs_g3_rx_rmfifo_pempty_data),
				.rmfifo_pfull(pcs_g3_rx_rmfifo_pfull),
				.rmfifo_pfull_data(pcs_g3_rx_rmfifo_pfull_data),
				.rx_b4gb_par_lpbk(pcs_g3_rx_rx_b4gb_par_lpbk),
				.rx_clk_sel(pcs_g3_rx_rx_clk_sel),
				.rx_force_balign(pcs_g3_rx_rx_force_balign),
				.rx_g3_dcbal(pcs_g3_rx_rx_g3_dcbal),
				.rx_ins_del_one_skip(pcs_g3_rx_rx_ins_del_one_skip),
				.rx_lane_num(pcs_g3_rx_rx_lane_num),
				.rx_num_fixed_pat(pcs_g3_rx_rx_num_fixed_pat),
				.rx_num_fixed_pat_data(pcs_g3_rx_rx_num_fixed_pat_data),
				.rx_pol_compl(pcs_g3_rx_rx_pol_compl),
				.rx_test_out_sel(pcs_g3_rx_rx_test_out_sel),
				.sup_mode(pcs_g3_rx_sup_mode),
				.tx_clk_sel(pcs_g3_rx_tx_clk_sel),
				.use_default_base_address(pcs_g3_rx_use_default_base_address),
				.user_base_address(pcs_g3_rx_user_base_address)
			) inst_sv_hssi_gen3_rx_pcs (
				// OUTPUTS
				.avmmreaddata(w_pcs_g3_rx_avmmreaddata),
				.blkalgndint(w_pcs_g3_rx_blkalgndint),
				.blkstart(w_pcs_g3_rx_blkstart),
				.blockselect(w_pcs_g3_rx_blockselect),
				.clkcompdeleteint(w_pcs_g3_rx_clkcompdeleteint),
				.clkcompinsertint(w_pcs_g3_rx_clkcompinsertint),
				.clkcompoverflint(w_pcs_g3_rx_clkcompoverflint),
				.clkcompundflint(w_pcs_g3_rx_clkcompundflint),
				.dataout(w_pcs_g3_rx_dataout),
				.datavalid(w_pcs_g3_rx_datavalid),
				.eidetint(w_pcs_g3_rx_eidetint),
				.eipartialdetint(w_pcs_g3_rx_eipartialdetint),
				.errdecodeint(w_pcs_g3_rx_errdecodeint),
				.idetint(w_pcs_g3_rx_idetint),
				.lpbkblkstart(w_pcs_g3_rx_lpbkblkstart),
				.lpbkdata(w_pcs_g3_rx_lpbkdata),
				.lpbkdatavalid(w_pcs_g3_rx_lpbkdatavalid),
				.rcvlfsrchkint(w_pcs_g3_rx_rcvlfsrchkint),
				.rxtestout(w_pcs_g3_rx_rxtestout),
				.synchdr(w_pcs_g3_rx_synchdr),
				// INPUTS
				.avmmaddress({in_avmmaddress[10], in_avmmaddress[9], in_avmmaddress[8], in_avmmaddress[7], in_avmmaddress[6], in_avmmaddress[5], in_avmmaddress[4], in_avmmaddress[3], in_avmmaddress[2], in_avmmaddress[1], in_avmmaddress[0]}),
				.avmmbyteen({in_avmmbyteen[1], in_avmmbyteen[0]}),
				.avmmclk(in_avmmclk),
				.avmmread(in_avmmread),
				.avmmrstn(in_avmmrstn),
				.avmmwrite(in_avmmwrite),
				.avmmwritedata({in_avmmwritedata[15], in_avmmwritedata[14], in_avmmwritedata[13], in_avmmwritedata[12], in_avmmwritedata[11], in_avmmwritedata[10], in_avmmwritedata[9], in_avmmwritedata[8], in_avmmwritedata[7], in_avmmwritedata[6], in_avmmwritedata[5], in_avmmwritedata[4], in_avmmwritedata[3], in_avmmwritedata[2], in_avmmwritedata[1], in_avmmwritedata[0]}),
				.datain({w_rx_pcs_pma_if_dataouttogen3pcs[31], w_rx_pcs_pma_if_dataouttogen3pcs[30], w_rx_pcs_pma_if_dataouttogen3pcs[29], w_rx_pcs_pma_if_dataouttogen3pcs[28], w_rx_pcs_pma_if_dataouttogen3pcs[27], w_rx_pcs_pma_if_dataouttogen3pcs[26], w_rx_pcs_pma_if_dataouttogen3pcs[25], w_rx_pcs_pma_if_dataouttogen3pcs[24], w_rx_pcs_pma_if_dataouttogen3pcs[23], w_rx_pcs_pma_if_dataouttogen3pcs[22], w_rx_pcs_pma_if_dataouttogen3pcs[21], w_rx_pcs_pma_if_dataouttogen3pcs[20], w_rx_pcs_pma_if_dataouttogen3pcs[19], w_rx_pcs_pma_if_dataouttogen3pcs[18], w_rx_pcs_pma_if_dataouttogen3pcs[17], w_rx_pcs_pma_if_dataouttogen3pcs[16], w_rx_pcs_pma_if_dataouttogen3pcs[15], w_rx_pcs_pma_if_dataouttogen3pcs[14], w_rx_pcs_pma_if_dataouttogen3pcs[13], w_rx_pcs_pma_if_dataouttogen3pcs[12], w_rx_pcs_pma_if_dataouttogen3pcs[11], w_rx_pcs_pma_if_dataouttogen3pcs[10], w_rx_pcs_pma_if_dataouttogen3pcs[9], w_rx_pcs_pma_if_dataouttogen3pcs[8], w_rx_pcs_pma_if_dataouttogen3pcs[7], w_rx_pcs_pma_if_dataouttogen3pcs[6], w_rx_pcs_pma_if_dataouttogen3pcs[5], w_rx_pcs_pma_if_dataouttogen3pcs[4], w_rx_pcs_pma_if_dataouttogen3pcs[3], w_rx_pcs_pma_if_dataouttogen3pcs[2], w_rx_pcs_pma_if_dataouttogen3pcs[1], w_rx_pcs_pma_if_dataouttogen3pcs[0]}),
				.gen3clksel(w_pipe3_gen3clksel),
				.hardresetn(w_com_pld_pcs_if_pcsgen3hardreset),
				.inferredrxvalid(w_pipe3_inferredrxvalidint),
				.lpbken(w_pipe3_revlpbkint),
				.parlpbkb4gbin({w_pcs_g3_tx_parlpbkb4gbout[35], w_pcs_g3_tx_parlpbkb4gbout[34], w_pcs_g3_tx_parlpbkb4gbout[33], w_pcs_g3_tx_parlpbkb4gbout[32], w_pcs_g3_tx_parlpbkb4gbout[31], w_pcs_g3_tx_parlpbkb4gbout[30], w_pcs_g3_tx_parlpbkb4gbout[29], w_pcs_g3_tx_parlpbkb4gbout[28], w_pcs_g3_tx_parlpbkb4gbout[27], w_pcs_g3_tx_parlpbkb4gbout[26], w_pcs_g3_tx_parlpbkb4gbout[25], w_pcs_g3_tx_parlpbkb4gbout[24], w_pcs_g3_tx_parlpbkb4gbout[23], w_pcs_g3_tx_parlpbkb4gbout[22], w_pcs_g3_tx_parlpbkb4gbout[21], w_pcs_g3_tx_parlpbkb4gbout[20], w_pcs_g3_tx_parlpbkb4gbout[19], w_pcs_g3_tx_parlpbkb4gbout[18], w_pcs_g3_tx_parlpbkb4gbout[17], w_pcs_g3_tx_parlpbkb4gbout[16], w_pcs_g3_tx_parlpbkb4gbout[15], w_pcs_g3_tx_parlpbkb4gbout[14], w_pcs_g3_tx_parlpbkb4gbout[13], w_pcs_g3_tx_parlpbkb4gbout[12], w_pcs_g3_tx_parlpbkb4gbout[11], w_pcs_g3_tx_parlpbkb4gbout[10], w_pcs_g3_tx_parlpbkb4gbout[9], w_pcs_g3_tx_parlpbkb4gbout[8], w_pcs_g3_tx_parlpbkb4gbout[7], w_pcs_g3_tx_parlpbkb4gbout[6], w_pcs_g3_tx_parlpbkb4gbout[5], w_pcs_g3_tx_parlpbkb4gbout[4], w_pcs_g3_tx_parlpbkb4gbout[3], w_pcs_g3_tx_parlpbkb4gbout[2], w_pcs_g3_tx_parlpbkb4gbout[1], w_pcs_g3_tx_parlpbkb4gbout[0]}),
				.parlpbkin({w_pcs_g3_tx_parlpbkout[31], w_pcs_g3_tx_parlpbkout[30], w_pcs_g3_tx_parlpbkout[29], w_pcs_g3_tx_parlpbkout[28], w_pcs_g3_tx_parlpbkout[27], w_pcs_g3_tx_parlpbkout[26], w_pcs_g3_tx_parlpbkout[25], w_pcs_g3_tx_parlpbkout[24], w_pcs_g3_tx_parlpbkout[23], w_pcs_g3_tx_parlpbkout[22], w_pcs_g3_tx_parlpbkout[21], w_pcs_g3_tx_parlpbkout[20], w_pcs_g3_tx_parlpbkout[19], w_pcs_g3_tx_parlpbkout[18], w_pcs_g3_tx_parlpbkout[17], w_pcs_g3_tx_parlpbkout[16], w_pcs_g3_tx_parlpbkout[15], w_pcs_g3_tx_parlpbkout[14], w_pcs_g3_tx_parlpbkout[13], w_pcs_g3_tx_parlpbkout[12], w_pcs_g3_tx_parlpbkout[11], w_pcs_g3_tx_parlpbkout[10], w_pcs_g3_tx_parlpbkout[9], w_pcs_g3_tx_parlpbkout[8], w_pcs_g3_tx_parlpbkout[7], w_pcs_g3_tx_parlpbkout[6], w_pcs_g3_tx_parlpbkout[5], w_pcs_g3_tx_parlpbkout[4], w_pcs_g3_tx_parlpbkout[3], w_pcs_g3_tx_parlpbkout[2], w_pcs_g3_tx_parlpbkout[1], w_pcs_g3_tx_parlpbkout[0]}),
				.pcsrst(w_pipe3_pcsrst),
				.pldclk28gpcs(w_pcs8g_rx_rxclkoutgen3),
				.rcvdclk(w_rx_pcs_pma_if_clockouttogen3pcs),
				.rxpolarity(w_pipe3_rxpolarityint),
				.rxrstn(w_rx_pld_pcs_if_pcsgen3rxrst),
				.scanmoden(w_com_pld_pcs_if_pcsgen3scanmoden),
				.shutdownclk(w_pipe3_shutdownclk),
				.syncsmen(w_rx_pld_pcs_if_pcsgen3syncsmen),
				.txdatakin({w_pipe3_txdatakint[3], w_pipe3_txdatakint[2], w_pipe3_txdatakint[1], w_pipe3_txdatakint[0]}),
				.txelecidle(w_pcs8g_tx_txelecidleout),
				.txpmaclk(w_pcs8g_tx_clkoutgen3)
			);
		end // if generate
		else begin
				assign w_pcs_g3_rx_avmmreaddata[15:0] = 16'b0;
				assign w_pcs_g3_rx_blkalgndint = 1'b0;
				assign w_pcs_g3_rx_blkstart = 1'b0;
				assign w_pcs_g3_rx_blockselect = 1'b0;
				assign w_pcs_g3_rx_clkcompdeleteint = 1'b0;
				assign w_pcs_g3_rx_clkcompinsertint = 1'b0;
				assign w_pcs_g3_rx_clkcompoverflint = 1'b0;
				assign w_pcs_g3_rx_clkcompundflint = 1'b0;
				assign w_pcs_g3_rx_dataout[31:0] = 32'b0;
				assign w_pcs_g3_rx_datavalid = 1'b0;
				assign w_pcs_g3_rx_eidetint = 1'b0;
				assign w_pcs_g3_rx_eipartialdetint = 1'b0;
				assign w_pcs_g3_rx_errdecodeint = 1'b0;
				assign w_pcs_g3_rx_idetint = 1'b0;
				assign w_pcs_g3_rx_lpbkblkstart = 1'b0;
				assign w_pcs_g3_rx_lpbkdata[33:0] = 34'b0;
				assign w_pcs_g3_rx_lpbkdatavalid = 1'b0;
				assign w_pcs_g3_rx_rcvlfsrchkint = 1'b0;
				assign w_pcs_g3_rx_rxtestout[19:0] = 20'b0;
				assign w_pcs_g3_rx_synchdr[1:0] = 2'b0;
		end // if not generate
		
		//output assignments
		assign out_agg_align_det_sync = {w_com_pcs_pma_if_aggaligndetsync[1], w_com_pcs_pma_if_aggaligndetsync[0]};
		assign out_agg_align_status_sync = w_com_pcs_pma_if_aggalignstatussync;
		assign out_agg_cg_comp_rd_d_out = {w_com_pcs_pma_if_aggcgcomprddout[1], w_com_pcs_pma_if_aggcgcomprddout[0]};
		assign out_agg_cg_comp_wr_out = {w_com_pcs_pma_if_aggcgcompwrout[1], w_com_pcs_pma_if_aggcgcompwrout[0]};
		assign out_agg_dec_ctl = w_com_pcs_pma_if_aggdecctl;
		assign out_agg_dec_data = {w_com_pcs_pma_if_aggdecdata[7], w_com_pcs_pma_if_aggdecdata[6], w_com_pcs_pma_if_aggdecdata[5], w_com_pcs_pma_if_aggdecdata[4], w_com_pcs_pma_if_aggdecdata[3], w_com_pcs_pma_if_aggdecdata[2], w_com_pcs_pma_if_aggdecdata[1], w_com_pcs_pma_if_aggdecdata[0]};
		assign out_agg_dec_data_valid = w_com_pcs_pma_if_aggdecdatavalid;
		assign out_agg_del_cond_met_out = w_com_pcs_pma_if_aggdelcondmetout;
		assign out_agg_fifo_ovr_out = w_com_pcs_pma_if_aggfifoovrout;
		assign out_agg_fifo_rd_out_comp = w_com_pcs_pma_if_aggfifordoutcomp;
		assign out_agg_insert_incomplete_out = w_com_pcs_pma_if_agginsertincompleteout;
		assign out_agg_latency_comp_out = w_com_pcs_pma_if_agglatencycompout;
		assign out_agg_rd_align = {w_com_pcs_pma_if_aggrdalign[1], w_com_pcs_pma_if_aggrdalign[0]};
		assign out_agg_rd_enable_sync = w_com_pcs_pma_if_aggrdenablesync;
		assign out_agg_refclk_dig = w_com_pcs_pma_if_aggrefclkdig;
		assign out_agg_running_disp = {w_com_pcs_pma_if_aggrunningdisp[1], w_com_pcs_pma_if_aggrunningdisp[0]};
		assign out_agg_rxpcs_rst = w_com_pcs_pma_if_aggrxpcsrst;
		assign out_agg_scan_mode_n = w_com_pcs_pma_if_aggscanmoden;
		assign out_agg_scan_shift_n = w_com_pcs_pma_if_aggscanshiftn;
		assign out_agg_sync_status = w_com_pcs_pma_if_aggsyncstatus;
		assign out_agg_tx_ctl_tc = w_com_pcs_pma_if_aggtxctltc;
		assign out_agg_tx_data_tc = {w_com_pcs_pma_if_aggtxdatatc[7], w_com_pcs_pma_if_aggtxdatatc[6], w_com_pcs_pma_if_aggtxdatatc[5], w_com_pcs_pma_if_aggtxdatatc[4], w_com_pcs_pma_if_aggtxdatatc[3], w_com_pcs_pma_if_aggtxdatatc[2], w_com_pcs_pma_if_aggtxdatatc[1], w_com_pcs_pma_if_aggtxdatatc[0]};
		assign out_agg_txpcs_rst = w_com_pcs_pma_if_aggtxpcsrst;
		assign out_avmmreaddata_com_pcs_pma_if = {w_com_pcs_pma_if_avmmreaddata[15], w_com_pcs_pma_if_avmmreaddata[14], w_com_pcs_pma_if_avmmreaddata[13], w_com_pcs_pma_if_avmmreaddata[12], w_com_pcs_pma_if_avmmreaddata[11], w_com_pcs_pma_if_avmmreaddata[10], w_com_pcs_pma_if_avmmreaddata[9], w_com_pcs_pma_if_avmmreaddata[8], w_com_pcs_pma_if_avmmreaddata[7], w_com_pcs_pma_if_avmmreaddata[6], w_com_pcs_pma_if_avmmreaddata[5], w_com_pcs_pma_if_avmmreaddata[4], w_com_pcs_pma_if_avmmreaddata[3], w_com_pcs_pma_if_avmmreaddata[2], w_com_pcs_pma_if_avmmreaddata[1], w_com_pcs_pma_if_avmmreaddata[0]};
		assign out_avmmreaddata_com_pld_pcs_if = {w_com_pld_pcs_if_avmmreaddata[15], w_com_pld_pcs_if_avmmreaddata[14], w_com_pld_pcs_if_avmmreaddata[13], w_com_pld_pcs_if_avmmreaddata[12], w_com_pld_pcs_if_avmmreaddata[11], w_com_pld_pcs_if_avmmreaddata[10], w_com_pld_pcs_if_avmmreaddata[9], w_com_pld_pcs_if_avmmreaddata[8], w_com_pld_pcs_if_avmmreaddata[7], w_com_pld_pcs_if_avmmreaddata[6], w_com_pld_pcs_if_avmmreaddata[5], w_com_pld_pcs_if_avmmreaddata[4], w_com_pld_pcs_if_avmmreaddata[3], w_com_pld_pcs_if_avmmreaddata[2], w_com_pld_pcs_if_avmmreaddata[1], w_com_pld_pcs_if_avmmreaddata[0]};
		assign out_avmmreaddata_pcs10g_rx = {w_pcs10g_rx_avmmreaddata[15], w_pcs10g_rx_avmmreaddata[14], w_pcs10g_rx_avmmreaddata[13], w_pcs10g_rx_avmmreaddata[12], w_pcs10g_rx_avmmreaddata[11], w_pcs10g_rx_avmmreaddata[10], w_pcs10g_rx_avmmreaddata[9], w_pcs10g_rx_avmmreaddata[8], w_pcs10g_rx_avmmreaddata[7], w_pcs10g_rx_avmmreaddata[6], w_pcs10g_rx_avmmreaddata[5], w_pcs10g_rx_avmmreaddata[4], w_pcs10g_rx_avmmreaddata[3], w_pcs10g_rx_avmmreaddata[2], w_pcs10g_rx_avmmreaddata[1], w_pcs10g_rx_avmmreaddata[0]};
		assign out_avmmreaddata_pcs10g_tx = {w_pcs10g_tx_avmmreaddata[15], w_pcs10g_tx_avmmreaddata[14], w_pcs10g_tx_avmmreaddata[13], w_pcs10g_tx_avmmreaddata[12], w_pcs10g_tx_avmmreaddata[11], w_pcs10g_tx_avmmreaddata[10], w_pcs10g_tx_avmmreaddata[9], w_pcs10g_tx_avmmreaddata[8], w_pcs10g_tx_avmmreaddata[7], w_pcs10g_tx_avmmreaddata[6], w_pcs10g_tx_avmmreaddata[5], w_pcs10g_tx_avmmreaddata[4], w_pcs10g_tx_avmmreaddata[3], w_pcs10g_tx_avmmreaddata[2], w_pcs10g_tx_avmmreaddata[1], w_pcs10g_tx_avmmreaddata[0]};
		assign out_avmmreaddata_pcs8g_rx = {w_pcs8g_rx_avmmreaddata[15], w_pcs8g_rx_avmmreaddata[14], w_pcs8g_rx_avmmreaddata[13], w_pcs8g_rx_avmmreaddata[12], w_pcs8g_rx_avmmreaddata[11], w_pcs8g_rx_avmmreaddata[10], w_pcs8g_rx_avmmreaddata[9], w_pcs8g_rx_avmmreaddata[8], w_pcs8g_rx_avmmreaddata[7], w_pcs8g_rx_avmmreaddata[6], w_pcs8g_rx_avmmreaddata[5], w_pcs8g_rx_avmmreaddata[4], w_pcs8g_rx_avmmreaddata[3], w_pcs8g_rx_avmmreaddata[2], w_pcs8g_rx_avmmreaddata[1], w_pcs8g_rx_avmmreaddata[0]};
		assign out_avmmreaddata_pcs8g_tx = {w_pcs8g_tx_avmmreaddata[15], w_pcs8g_tx_avmmreaddata[14], w_pcs8g_tx_avmmreaddata[13], w_pcs8g_tx_avmmreaddata[12], w_pcs8g_tx_avmmreaddata[11], w_pcs8g_tx_avmmreaddata[10], w_pcs8g_tx_avmmreaddata[9], w_pcs8g_tx_avmmreaddata[8], w_pcs8g_tx_avmmreaddata[7], w_pcs8g_tx_avmmreaddata[6], w_pcs8g_tx_avmmreaddata[5], w_pcs8g_tx_avmmreaddata[4], w_pcs8g_tx_avmmreaddata[3], w_pcs8g_tx_avmmreaddata[2], w_pcs8g_tx_avmmreaddata[1], w_pcs8g_tx_avmmreaddata[0]};
		assign out_avmmreaddata_pcs_g3_rx = {w_pcs_g3_rx_avmmreaddata[15], w_pcs_g3_rx_avmmreaddata[14], w_pcs_g3_rx_avmmreaddata[13], w_pcs_g3_rx_avmmreaddata[12], w_pcs_g3_rx_avmmreaddata[11], w_pcs_g3_rx_avmmreaddata[10], w_pcs_g3_rx_avmmreaddata[9], w_pcs_g3_rx_avmmreaddata[8], w_pcs_g3_rx_avmmreaddata[7], w_pcs_g3_rx_avmmreaddata[6], w_pcs_g3_rx_avmmreaddata[5], w_pcs_g3_rx_avmmreaddata[4], w_pcs_g3_rx_avmmreaddata[3], w_pcs_g3_rx_avmmreaddata[2], w_pcs_g3_rx_avmmreaddata[1], w_pcs_g3_rx_avmmreaddata[0]};
		assign out_avmmreaddata_pcs_g3_tx = {w_pcs_g3_tx_avmmreaddata[15], w_pcs_g3_tx_avmmreaddata[14], w_pcs_g3_tx_avmmreaddata[13], w_pcs_g3_tx_avmmreaddata[12], w_pcs_g3_tx_avmmreaddata[11], w_pcs_g3_tx_avmmreaddata[10], w_pcs_g3_tx_avmmreaddata[9], w_pcs_g3_tx_avmmreaddata[8], w_pcs_g3_tx_avmmreaddata[7], w_pcs_g3_tx_avmmreaddata[6], w_pcs_g3_tx_avmmreaddata[5], w_pcs_g3_tx_avmmreaddata[4], w_pcs_g3_tx_avmmreaddata[3], w_pcs_g3_tx_avmmreaddata[2], w_pcs_g3_tx_avmmreaddata[1], w_pcs_g3_tx_avmmreaddata[0]};
		assign out_avmmreaddata_pipe12 = {w_pipe12_avmmreaddata[15], w_pipe12_avmmreaddata[14], w_pipe12_avmmreaddata[13], w_pipe12_avmmreaddata[12], w_pipe12_avmmreaddata[11], w_pipe12_avmmreaddata[10], w_pipe12_avmmreaddata[9], w_pipe12_avmmreaddata[8], w_pipe12_avmmreaddata[7], w_pipe12_avmmreaddata[6], w_pipe12_avmmreaddata[5], w_pipe12_avmmreaddata[4], w_pipe12_avmmreaddata[3], w_pipe12_avmmreaddata[2], w_pipe12_avmmreaddata[1], w_pipe12_avmmreaddata[0]};
		assign out_avmmreaddata_pipe3 = {w_pipe3_avmmreaddata[15], w_pipe3_avmmreaddata[14], w_pipe3_avmmreaddata[13], w_pipe3_avmmreaddata[12], w_pipe3_avmmreaddata[11], w_pipe3_avmmreaddata[10], w_pipe3_avmmreaddata[9], w_pipe3_avmmreaddata[8], w_pipe3_avmmreaddata[7], w_pipe3_avmmreaddata[6], w_pipe3_avmmreaddata[5], w_pipe3_avmmreaddata[4], w_pipe3_avmmreaddata[3], w_pipe3_avmmreaddata[2], w_pipe3_avmmreaddata[1], w_pipe3_avmmreaddata[0]};
		assign out_avmmreaddata_rx_pcs_pma_if = {w_rx_pcs_pma_if_avmmreaddata[15], w_rx_pcs_pma_if_avmmreaddata[14], w_rx_pcs_pma_if_avmmreaddata[13], w_rx_pcs_pma_if_avmmreaddata[12], w_rx_pcs_pma_if_avmmreaddata[11], w_rx_pcs_pma_if_avmmreaddata[10], w_rx_pcs_pma_if_avmmreaddata[9], w_rx_pcs_pma_if_avmmreaddata[8], w_rx_pcs_pma_if_avmmreaddata[7], w_rx_pcs_pma_if_avmmreaddata[6], w_rx_pcs_pma_if_avmmreaddata[5], w_rx_pcs_pma_if_avmmreaddata[4], w_rx_pcs_pma_if_avmmreaddata[3], w_rx_pcs_pma_if_avmmreaddata[2], w_rx_pcs_pma_if_avmmreaddata[1], w_rx_pcs_pma_if_avmmreaddata[0]};
		assign out_avmmreaddata_rx_pld_pcs_if = {w_rx_pld_pcs_if_avmmreaddata[15], w_rx_pld_pcs_if_avmmreaddata[14], w_rx_pld_pcs_if_avmmreaddata[13], w_rx_pld_pcs_if_avmmreaddata[12], w_rx_pld_pcs_if_avmmreaddata[11], w_rx_pld_pcs_if_avmmreaddata[10], w_rx_pld_pcs_if_avmmreaddata[9], w_rx_pld_pcs_if_avmmreaddata[8], w_rx_pld_pcs_if_avmmreaddata[7], w_rx_pld_pcs_if_avmmreaddata[6], w_rx_pld_pcs_if_avmmreaddata[5], w_rx_pld_pcs_if_avmmreaddata[4], w_rx_pld_pcs_if_avmmreaddata[3], w_rx_pld_pcs_if_avmmreaddata[2], w_rx_pld_pcs_if_avmmreaddata[1], w_rx_pld_pcs_if_avmmreaddata[0]};
		assign out_avmmreaddata_tx_pcs_pma_if = {w_tx_pcs_pma_if_avmmreaddata[15], w_tx_pcs_pma_if_avmmreaddata[14], w_tx_pcs_pma_if_avmmreaddata[13], w_tx_pcs_pma_if_avmmreaddata[12], w_tx_pcs_pma_if_avmmreaddata[11], w_tx_pcs_pma_if_avmmreaddata[10], w_tx_pcs_pma_if_avmmreaddata[9], w_tx_pcs_pma_if_avmmreaddata[8], w_tx_pcs_pma_if_avmmreaddata[7], w_tx_pcs_pma_if_avmmreaddata[6], w_tx_pcs_pma_if_avmmreaddata[5], w_tx_pcs_pma_if_avmmreaddata[4], w_tx_pcs_pma_if_avmmreaddata[3], w_tx_pcs_pma_if_avmmreaddata[2], w_tx_pcs_pma_if_avmmreaddata[1], w_tx_pcs_pma_if_avmmreaddata[0]};
		assign out_avmmreaddata_tx_pld_pcs_if = {w_tx_pld_pcs_if_avmmreaddata[15], w_tx_pld_pcs_if_avmmreaddata[14], w_tx_pld_pcs_if_avmmreaddata[13], w_tx_pld_pcs_if_avmmreaddata[12], w_tx_pld_pcs_if_avmmreaddata[11], w_tx_pld_pcs_if_avmmreaddata[10], w_tx_pld_pcs_if_avmmreaddata[9], w_tx_pld_pcs_if_avmmreaddata[8], w_tx_pld_pcs_if_avmmreaddata[7], w_tx_pld_pcs_if_avmmreaddata[6], w_tx_pld_pcs_if_avmmreaddata[5], w_tx_pld_pcs_if_avmmreaddata[4], w_tx_pld_pcs_if_avmmreaddata[3], w_tx_pld_pcs_if_avmmreaddata[2], w_tx_pld_pcs_if_avmmreaddata[1], w_tx_pld_pcs_if_avmmreaddata[0]};
		assign out_blockselect_com_pcs_pma_if = w_com_pcs_pma_if_blockselect;
		assign out_blockselect_com_pld_pcs_if = w_com_pld_pcs_if_blockselect;
		assign out_blockselect_pcs10g_rx = w_pcs10g_rx_blockselect;
		assign out_blockselect_pcs10g_tx = w_pcs10g_tx_blockselect;
		assign out_blockselect_pcs8g_rx = w_pcs8g_rx_blockselect;
		assign out_blockselect_pcs8g_tx = w_pcs8g_tx_blockselect;
		assign out_blockselect_pcs_g3_rx = w_pcs_g3_rx_blockselect;
		assign out_blockselect_pcs_g3_tx = w_pcs_g3_tx_blockselect;
		assign out_blockselect_pipe12 = w_pipe12_blockselect;
		assign out_blockselect_pipe3 = w_pipe3_blockselect;
		assign out_blockselect_rx_pcs_pma_if = w_rx_pcs_pma_if_blockselect;
		assign out_blockselect_rx_pld_pcs_if = w_rx_pld_pcs_if_blockselect;
		assign out_blockselect_tx_pcs_pma_if = w_tx_pcs_pma_if_blockselect;
		assign out_blockselect_tx_pld_pcs_if = w_tx_pld_pcs_if_blockselect;
		assign out_config_sel_out_chnl_down = w_pcs8g_rx_configseloutchnldown;
		assign out_config_sel_out_chnl_up = w_pcs8g_rx_configseloutchnlup;
		assign out_emsip_com_clk_out = {w_com_pld_pcs_if_emsipcomclkout[2], w_com_pld_pcs_if_emsipcomclkout[1], w_com_pld_pcs_if_emsipcomclkout[0]};
		assign out_emsip_com_out = {w_com_pld_pcs_if_emsipcomout[26], w_com_pld_pcs_if_emsipcomout[25], w_com_pld_pcs_if_emsipcomout[24], w_com_pld_pcs_if_emsipcomout[23], w_com_pld_pcs_if_emsipcomout[22], w_com_pld_pcs_if_emsipcomout[21], w_com_pld_pcs_if_emsipcomout[20], w_com_pld_pcs_if_emsipcomout[19], w_com_pld_pcs_if_emsipcomout[18], w_com_pld_pcs_if_emsipcomout[17], w_com_pld_pcs_if_emsipcomout[16], w_com_pld_pcs_if_emsipcomout[15], w_com_pld_pcs_if_emsipcomout[14], w_com_pld_pcs_if_emsipcomout[13], w_com_pld_pcs_if_emsipcomout[12], w_com_pld_pcs_if_emsipcomout[11], w_com_pld_pcs_if_emsipcomout[10], w_com_pld_pcs_if_emsipcomout[9], w_com_pld_pcs_if_emsipcomout[8], w_com_pld_pcs_if_emsipcomout[7], w_com_pld_pcs_if_emsipcomout[6], w_com_pld_pcs_if_emsipcomout[5], w_com_pld_pcs_if_emsipcomout[4], w_com_pld_pcs_if_emsipcomout[3], w_com_pld_pcs_if_emsipcomout[2], w_com_pld_pcs_if_emsipcomout[1], w_com_pld_pcs_if_emsipcomout[0]};
		assign out_emsip_com_special_out = {w_com_pld_pcs_if_emsipcomspecialout[19], w_com_pld_pcs_if_emsipcomspecialout[18], w_com_pld_pcs_if_emsipcomspecialout[17], w_com_pld_pcs_if_emsipcomspecialout[16], w_com_pld_pcs_if_emsipcomspecialout[15], w_com_pld_pcs_if_emsipcomspecialout[14], w_com_pld_pcs_if_emsipcomspecialout[13], w_com_pld_pcs_if_emsipcomspecialout[12], w_com_pld_pcs_if_emsipcomspecialout[11], w_com_pld_pcs_if_emsipcomspecialout[10], w_com_pld_pcs_if_emsipcomspecialout[9], w_com_pld_pcs_if_emsipcomspecialout[8], w_com_pld_pcs_if_emsipcomspecialout[7], w_com_pld_pcs_if_emsipcomspecialout[6], w_com_pld_pcs_if_emsipcomspecialout[5], w_com_pld_pcs_if_emsipcomspecialout[4], w_com_pld_pcs_if_emsipcomspecialout[3], w_com_pld_pcs_if_emsipcomspecialout[2], w_com_pld_pcs_if_emsipcomspecialout[1], w_com_pld_pcs_if_emsipcomspecialout[0]};
		assign out_emsip_rx_clk_out = {w_rx_pld_pcs_if_emsiprxclkout[2], w_rx_pld_pcs_if_emsiprxclkout[1], w_rx_pld_pcs_if_emsiprxclkout[0]};
		assign out_emsip_rx_out = {w_rx_pld_pcs_if_emsiprxout[128], w_rx_pld_pcs_if_emsiprxout[127], w_rx_pld_pcs_if_emsiprxout[126], w_rx_pld_pcs_if_emsiprxout[125], w_rx_pld_pcs_if_emsiprxout[124], w_rx_pld_pcs_if_emsiprxout[123], w_rx_pld_pcs_if_emsiprxout[122], w_rx_pld_pcs_if_emsiprxout[121], w_rx_pld_pcs_if_emsiprxout[120], w_rx_pld_pcs_if_emsiprxout[119], w_rx_pld_pcs_if_emsiprxout[118], w_rx_pld_pcs_if_emsiprxout[117], w_rx_pld_pcs_if_emsiprxout[116], w_rx_pld_pcs_if_emsiprxout[115], w_rx_pld_pcs_if_emsiprxout[114], w_rx_pld_pcs_if_emsiprxout[113], w_rx_pld_pcs_if_emsiprxout[112], w_rx_pld_pcs_if_emsiprxout[111], w_rx_pld_pcs_if_emsiprxout[110], w_rx_pld_pcs_if_emsiprxout[109], w_rx_pld_pcs_if_emsiprxout[108], w_rx_pld_pcs_if_emsiprxout[107], w_rx_pld_pcs_if_emsiprxout[106], w_rx_pld_pcs_if_emsiprxout[105], w_rx_pld_pcs_if_emsiprxout[104], w_rx_pld_pcs_if_emsiprxout[103], w_rx_pld_pcs_if_emsiprxout[102], w_rx_pld_pcs_if_emsiprxout[101], w_rx_pld_pcs_if_emsiprxout[100], w_rx_pld_pcs_if_emsiprxout[99], w_rx_pld_pcs_if_emsiprxout[98], w_rx_pld_pcs_if_emsiprxout[97], w_rx_pld_pcs_if_emsiprxout[96], w_rx_pld_pcs_if_emsiprxout[95], w_rx_pld_pcs_if_emsiprxout[94], w_rx_pld_pcs_if_emsiprxout[93], w_rx_pld_pcs_if_emsiprxout[92], w_rx_pld_pcs_if_emsiprxout[91], w_rx_pld_pcs_if_emsiprxout[90], w_rx_pld_pcs_if_emsiprxout[89], w_rx_pld_pcs_if_emsiprxout[88], w_rx_pld_pcs_if_emsiprxout[87], w_rx_pld_pcs_if_emsiprxout[86], w_rx_pld_pcs_if_emsiprxout[85], w_rx_pld_pcs_if_emsiprxout[84], w_rx_pld_pcs_if_emsiprxout[83], w_rx_pld_pcs_if_emsiprxout[82], w_rx_pld_pcs_if_emsiprxout[81], w_rx_pld_pcs_if_emsiprxout[80], w_rx_pld_pcs_if_emsiprxout[79], w_rx_pld_pcs_if_emsiprxout[78], w_rx_pld_pcs_if_emsiprxout[77], w_rx_pld_pcs_if_emsiprxout[76], w_rx_pld_pcs_if_emsiprxout[75], w_rx_pld_pcs_if_emsiprxout[74], w_rx_pld_pcs_if_emsiprxout[73], w_rx_pld_pcs_if_emsiprxout[72], w_rx_pld_pcs_if_emsiprxout[71], w_rx_pld_pcs_if_emsiprxout[70], w_rx_pld_pcs_if_emsiprxout[69], w_rx_pld_pcs_if_emsiprxout[68], w_rx_pld_pcs_if_emsiprxout[67], w_rx_pld_pcs_if_emsiprxout[66], w_rx_pld_pcs_if_emsiprxout[65], w_rx_pld_pcs_if_emsiprxout[64], w_rx_pld_pcs_if_emsiprxout[63], w_rx_pld_pcs_if_emsiprxout[62], w_rx_pld_pcs_if_emsiprxout[61], w_rx_pld_pcs_if_emsiprxout[60], w_rx_pld_pcs_if_emsiprxout[59], w_rx_pld_pcs_if_emsiprxout[58], w_rx_pld_pcs_if_emsiprxout[57], w_rx_pld_pcs_if_emsiprxout[56], w_rx_pld_pcs_if_emsiprxout[55], w_rx_pld_pcs_if_emsiprxout[54], w_rx_pld_pcs_if_emsiprxout[53], w_rx_pld_pcs_if_emsiprxout[52], w_rx_pld_pcs_if_emsiprxout[51], w_rx_pld_pcs_if_emsiprxout[50], w_rx_pld_pcs_if_emsiprxout[49], w_rx_pld_pcs_if_emsiprxout[48], w_rx_pld_pcs_if_emsiprxout[47], w_rx_pld_pcs_if_emsiprxout[46], w_rx_pld_pcs_if_emsiprxout[45], w_rx_pld_pcs_if_emsiprxout[44], w_rx_pld_pcs_if_emsiprxout[43], w_rx_pld_pcs_if_emsiprxout[42], w_rx_pld_pcs_if_emsiprxout[41], w_rx_pld_pcs_if_emsiprxout[40], w_rx_pld_pcs_if_emsiprxout[39], w_rx_pld_pcs_if_emsiprxout[38], w_rx_pld_pcs_if_emsiprxout[37], w_rx_pld_pcs_if_emsiprxout[36], w_rx_pld_pcs_if_emsiprxout[35], w_rx_pld_pcs_if_emsiprxout[34], w_rx_pld_pcs_if_emsiprxout[33], w_rx_pld_pcs_if_emsiprxout[32], w_rx_pld_pcs_if_emsiprxout[31], w_rx_pld_pcs_if_emsiprxout[30], w_rx_pld_pcs_if_emsiprxout[29], w_rx_pld_pcs_if_emsiprxout[28], w_rx_pld_pcs_if_emsiprxout[27], w_rx_pld_pcs_if_emsiprxout[26], w_rx_pld_pcs_if_emsiprxout[25], w_rx_pld_pcs_if_emsiprxout[24], w_rx_pld_pcs_if_emsiprxout[23], w_rx_pld_pcs_if_emsiprxout[22], w_rx_pld_pcs_if_emsiprxout[21], w_rx_pld_pcs_if_emsiprxout[20], w_rx_pld_pcs_if_emsiprxout[19], w_rx_pld_pcs_if_emsiprxout[18], w_rx_pld_pcs_if_emsiprxout[17], w_rx_pld_pcs_if_emsiprxout[16], w_rx_pld_pcs_if_emsiprxout[15], w_rx_pld_pcs_if_emsiprxout[14], w_rx_pld_pcs_if_emsiprxout[13], w_rx_pld_pcs_if_emsiprxout[12], w_rx_pld_pcs_if_emsiprxout[11], w_rx_pld_pcs_if_emsiprxout[10], w_rx_pld_pcs_if_emsiprxout[9], w_rx_pld_pcs_if_emsiprxout[8], w_rx_pld_pcs_if_emsiprxout[7], w_rx_pld_pcs_if_emsiprxout[6], w_rx_pld_pcs_if_emsiprxout[5], w_rx_pld_pcs_if_emsiprxout[4], w_rx_pld_pcs_if_emsiprxout[3], w_rx_pld_pcs_if_emsiprxout[2], w_rx_pld_pcs_if_emsiprxout[1], w_rx_pld_pcs_if_emsiprxout[0]};
		assign out_emsip_rx_special_out = {w_rx_pld_pcs_if_emsiprxspecialout[15], w_rx_pld_pcs_if_emsiprxspecialout[14], w_rx_pld_pcs_if_emsiprxspecialout[13], w_rx_pld_pcs_if_emsiprxspecialout[12], w_rx_pld_pcs_if_emsiprxspecialout[11], w_rx_pld_pcs_if_emsiprxspecialout[10], w_rx_pld_pcs_if_emsiprxspecialout[9], w_rx_pld_pcs_if_emsiprxspecialout[8], w_rx_pld_pcs_if_emsiprxspecialout[7], w_rx_pld_pcs_if_emsiprxspecialout[6], w_rx_pld_pcs_if_emsiprxspecialout[5], w_rx_pld_pcs_if_emsiprxspecialout[4], w_rx_pld_pcs_if_emsiprxspecialout[3], w_rx_pld_pcs_if_emsiprxspecialout[2], w_rx_pld_pcs_if_emsiprxspecialout[1], w_rx_pld_pcs_if_emsiprxspecialout[0]};
		assign out_emsip_tx_clk_out = {w_tx_pld_pcs_if_emsippcstxclkout[2], w_tx_pld_pcs_if_emsippcstxclkout[1], w_tx_pld_pcs_if_emsippcstxclkout[0]};
		assign out_emsip_tx_out = {w_tx_pld_pcs_if_emsiptxout[11], w_tx_pld_pcs_if_emsiptxout[10], w_tx_pld_pcs_if_emsiptxout[9], w_tx_pld_pcs_if_emsiptxout[8], w_tx_pld_pcs_if_emsiptxout[7], w_tx_pld_pcs_if_emsiptxout[6], w_tx_pld_pcs_if_emsiptxout[5], w_tx_pld_pcs_if_emsiptxout[4], w_tx_pld_pcs_if_emsiptxout[3], w_tx_pld_pcs_if_emsiptxout[2], w_tx_pld_pcs_if_emsiptxout[1], w_tx_pld_pcs_if_emsiptxout[0]};
		assign out_emsip_tx_special_out = {w_tx_pld_pcs_if_emsiptxspecialout[15], w_tx_pld_pcs_if_emsiptxspecialout[14], w_tx_pld_pcs_if_emsiptxspecialout[13], w_tx_pld_pcs_if_emsiptxspecialout[12], w_tx_pld_pcs_if_emsiptxspecialout[11], w_tx_pld_pcs_if_emsiptxspecialout[10], w_tx_pld_pcs_if_emsiptxspecialout[9], w_tx_pld_pcs_if_emsiptxspecialout[8], w_tx_pld_pcs_if_emsiptxspecialout[7], w_tx_pld_pcs_if_emsiptxspecialout[6], w_tx_pld_pcs_if_emsiptxspecialout[5], w_tx_pld_pcs_if_emsiptxspecialout[4], w_tx_pld_pcs_if_emsiptxspecialout[3], w_tx_pld_pcs_if_emsiptxspecialout[2], w_tx_pld_pcs_if_emsiptxspecialout[1], w_tx_pld_pcs_if_emsiptxspecialout[0]};
		assign out_fifo_select_out_chnl_down = {w_pcs8g_tx_fifoselectoutchnldown[1], w_pcs8g_tx_fifoselectoutchnldown[0]};
		assign out_fifo_select_out_chnl_up = {w_pcs8g_tx_fifoselectoutchnlup[1], w_pcs8g_tx_fifoselectoutchnlup[0]};
		assign out_pcs_10g_bundling_out_down = {w_pcs10g_tx_distdwnoutrdpfull, w_pcs10g_tx_distdwnoutintlknrden};
		assign out_pcs_10g_bundling_out_up = {w_pcs10g_tx_distupoutrdpfull, w_pcs10g_tx_distupoutintlknrden};
		assign out_pcs_10g_distdwn_out_dv = w_pcs10g_tx_distdwnoutdv;
		assign out_pcs_10g_distdwn_out_rden = w_pcs10g_tx_distdwnoutrden;
		assign out_pcs_10g_distdwn_out_wren = w_pcs10g_tx_distdwnoutwren;
		assign out_pcs_10g_distup_out_dv = w_pcs10g_tx_distupoutdv;
		assign out_pcs_10g_distup_out_rden = w_pcs10g_tx_distupoutrden;
		assign out_pcs_10g_distup_out_wren = w_pcs10g_tx_distupoutwren;
		assign out_pcs_gen3_bundling_out_down = {w_pipe3_bundlingoutdown[10], w_pipe3_bundlingoutdown[9], w_pipe3_bundlingoutdown[8], w_pipe3_bundlingoutdown[7], w_pipe3_bundlingoutdown[6], w_pipe3_bundlingoutdown[5], w_pipe3_bundlingoutdown[4], w_pipe3_bundlingoutdown[3], w_pipe3_bundlingoutdown[2], w_pipe3_bundlingoutdown[1], w_pipe3_bundlingoutdown[0]};
		assign out_pcs_gen3_bundling_out_up = {w_pipe3_bundlingoutup[10], w_pipe3_bundlingoutup[9], w_pipe3_bundlingoutup[8], w_pipe3_bundlingoutup[7], w_pipe3_bundlingoutup[6], w_pipe3_bundlingoutup[5], w_pipe3_bundlingoutup[4], w_pipe3_bundlingoutup[3], w_pipe3_bundlingoutup[2], w_pipe3_bundlingoutup[1], w_pipe3_bundlingoutup[0]};
		assign out_pld_10g_rx_align_val = w_rx_pld_pcs_if_pld10grxalignval;
		assign out_pld_10g_rx_blk_lock = w_rx_pld_pcs_if_pld10grxblklock;
		assign out_pld_10g_rx_clk_out = w_rx_pld_pcs_if_pld10grxclkout;
		assign out_pld_10g_rx_control = {w_rx_pld_pcs_if_pld10grxcontrol[9], w_rx_pld_pcs_if_pld10grxcontrol[8], w_rx_pld_pcs_if_pld10grxcontrol[7], w_rx_pld_pcs_if_pld10grxcontrol[6], w_rx_pld_pcs_if_pld10grxcontrol[5], w_rx_pld_pcs_if_pld10grxcontrol[4], w_rx_pld_pcs_if_pld10grxcontrol[3], w_rx_pld_pcs_if_pld10grxcontrol[2], w_rx_pld_pcs_if_pld10grxcontrol[1], w_rx_pld_pcs_if_pld10grxcontrol[0]};
		assign out_pld_10g_rx_crc32_err = w_rx_pld_pcs_if_pld10grxcrc32err;
		assign out_pld_10g_rx_data_valid = w_rx_pld_pcs_if_pld10grxdatavalid;
		assign out_pld_10g_rx_diag_err = w_rx_pld_pcs_if_pld10grxdiagerr;
		assign out_pld_10g_rx_diag_status = {w_rx_pld_pcs_if_pld10grxdiagstatus[1], w_rx_pld_pcs_if_pld10grxdiagstatus[0]};
		assign out_pld_10g_rx_empty = w_rx_pld_pcs_if_pld10grxempty;
		assign out_pld_10g_rx_fifo_del = w_rx_pld_pcs_if_pld10grxfifodel;
		assign out_pld_10g_rx_fifo_insert = w_rx_pld_pcs_if_pld10grxfifoinsert;
		assign out_pld_10g_rx_frame_lock = w_rx_pld_pcs_if_pld10grxframelock;
		assign out_pld_10g_rx_hi_ber = w_rx_pld_pcs_if_pld10grxhiber;
		assign out_pld_10g_rx_mfrm_err = w_rx_pld_pcs_if_pld10grxmfrmerr;
		assign out_pld_10g_rx_oflw_err = w_rx_pld_pcs_if_pld10grxoflwerr;
		assign out_pld_10g_rx_pempty = w_rx_pld_pcs_if_pld10grxpempty;
		assign out_pld_10g_rx_pfull = w_rx_pld_pcs_if_pld10grxpfull;
		assign out_pld_10g_rx_prbs_err = w_rx_pld_pcs_if_pld10grxprbserr;
		assign out_pld_10g_rx_pyld_ins = w_rx_pld_pcs_if_pld10grxpyldins;
		assign out_pld_10g_rx_rdneg_sts = w_rx_pld_pcs_if_pld10grxrdnegsts;
		assign out_pld_10g_rx_rdpos_sts = w_rx_pld_pcs_if_pld10grxrdpossts;
		assign out_pld_10g_rx_rx_frame = w_rx_pld_pcs_if_pld10grxrxframe;
		assign out_pld_10g_rx_scrm_err = w_rx_pld_pcs_if_pld10grxscrmerr;
		assign out_pld_10g_rx_sh_err = w_rx_pld_pcs_if_pld10grxsherr;
		assign out_pld_10g_rx_skip_err = w_rx_pld_pcs_if_pld10grxskiperr;
		assign out_pld_10g_rx_skip_ins = w_rx_pld_pcs_if_pld10grxskipins;
		assign out_pld_10g_rx_sync_err = w_rx_pld_pcs_if_pld10grxsyncerr;
		assign out_pld_10g_tx_burst_en_exe = w_tx_pld_pcs_if_pld10gtxburstenexe;
		assign out_pld_10g_tx_clk_out = w_tx_pld_pcs_if_pld10gtxclkout;
		assign out_pld_10g_tx_empty = w_tx_pld_pcs_if_pld10gtxempty;
		assign out_pld_10g_tx_fifo_del = w_tx_pld_pcs_if_pld10gtxfifodel;
		assign out_pld_10g_tx_fifo_insert = w_tx_pld_pcs_if_pld10gtxfifoinsert;
		assign out_pld_10g_tx_frame = w_tx_pld_pcs_if_pld10gtxframe;
		assign out_pld_10g_tx_full = w_tx_pld_pcs_if_pld10gtxfull;
		assign out_pld_10g_tx_pempty = w_tx_pld_pcs_if_pld10gtxpempty;
		assign out_pld_10g_tx_pfull = w_tx_pld_pcs_if_pld10gtxpfull;
		assign out_pld_10g_tx_wordslip_exe = w_tx_pld_pcs_if_pld10gtxwordslipexe;
		assign out_pld_8g_a1a2_k1k2_flag = {w_rx_pld_pcs_if_pld8ga1a2k1k2flag[3], w_rx_pld_pcs_if_pld8ga1a2k1k2flag[2], w_rx_pld_pcs_if_pld8ga1a2k1k2flag[1], w_rx_pld_pcs_if_pld8ga1a2k1k2flag[0]};
		assign out_pld_8g_align_status = w_rx_pld_pcs_if_pld8galignstatus;
		assign out_pld_8g_bistdone = w_rx_pld_pcs_if_pld8gbistdone;
		assign out_pld_8g_bisterr = w_rx_pld_pcs_if_pld8gbisterr;
		assign out_pld_8g_byteord_flag = w_rx_pld_pcs_if_pld8gbyteordflag;
		assign out_pld_8g_empty_rmf = w_rx_pld_pcs_if_pld8gemptyrmf;
		assign out_pld_8g_empty_rx = w_rx_pld_pcs_if_pld8gemptyrx;
		assign out_pld_8g_empty_tx = w_tx_pld_pcs_if_pld8gemptytx;
		assign out_pld_8g_full_rmf = w_rx_pld_pcs_if_pld8gfullrmf;
		assign out_pld_8g_full_rx = w_rx_pld_pcs_if_pld8gfullrx;
		assign out_pld_8g_full_tx = w_tx_pld_pcs_if_pld8gfulltx;
		assign out_pld_8g_phystatus = w_com_pld_pcs_if_pld8gphystatus;
		assign out_pld_8g_rlv_lt = w_rx_pld_pcs_if_pld8grlvlt;
		assign out_pld_8g_rx_blk_start = {w_rx_pld_pcs_if_pld8grxblkstart[3], w_rx_pld_pcs_if_pld8grxblkstart[2], w_rx_pld_pcs_if_pld8grxblkstart[1], w_rx_pld_pcs_if_pld8grxblkstart[0]};
		assign out_pld_8g_rx_clk_out = w_rx_pld_pcs_if_pld8grxclkout;
		assign out_pld_8g_rx_data_valid = {w_rx_pld_pcs_if_pld8grxdatavalid[3], w_rx_pld_pcs_if_pld8grxdatavalid[2], w_rx_pld_pcs_if_pld8grxdatavalid[1], w_rx_pld_pcs_if_pld8grxdatavalid[0]};
		assign out_pld_8g_rx_sync_hdr = {w_rx_pld_pcs_if_pld8grxsynchdr[1], w_rx_pld_pcs_if_pld8grxsynchdr[0]};
		assign out_pld_8g_rxelecidle = w_com_pld_pcs_if_pld8grxelecidle;
		assign out_pld_8g_rxstatus = {w_com_pld_pcs_if_pld8grxstatus[2], w_com_pld_pcs_if_pld8grxstatus[1], w_com_pld_pcs_if_pld8grxstatus[0]};
		assign out_pld_8g_rxvalid = w_com_pld_pcs_if_pld8grxvalid;
		assign out_pld_8g_signal_detect_out = w_rx_pld_pcs_if_pld8gsignaldetectout;
		assign out_pld_8g_tx_clk_out = w_tx_pld_pcs_if_pld8gtxclkout;
		assign out_pld_8g_wa_boundary = {w_rx_pld_pcs_if_pld8gwaboundary[4], w_rx_pld_pcs_if_pld8gwaboundary[3], w_rx_pld_pcs_if_pld8gwaboundary[2], w_rx_pld_pcs_if_pld8gwaboundary[1], w_rx_pld_pcs_if_pld8gwaboundary[0]};
		assign out_pld_clkdiv33_lc = w_tx_pld_pcs_if_pldclkdiv33lc;
		assign out_pld_clkdiv33_txorrx = w_rx_pld_pcs_if_pldclkdiv33txorrx;
		assign out_pld_clklow = w_com_pld_pcs_if_pldclklow;
		assign out_pld_fref = w_com_pld_pcs_if_pldfref;
		assign out_pld_gen3_mask_tx_pll = w_com_pld_pcs_if_pldgen3masktxpll;
		assign out_pld_gen3_rx_eq_ctrl = {w_com_pld_pcs_if_pldgen3rxeqctrl[1], w_com_pld_pcs_if_pldgen3rxeqctrl[0]};
		assign out_pld_gen3_rxdeemph = {w_com_pld_pcs_if_pldgen3rxdeemph[17], w_com_pld_pcs_if_pldgen3rxdeemph[16], w_com_pld_pcs_if_pldgen3rxdeemph[15], w_com_pld_pcs_if_pldgen3rxdeemph[14], w_com_pld_pcs_if_pldgen3rxdeemph[13], w_com_pld_pcs_if_pldgen3rxdeemph[12], w_com_pld_pcs_if_pldgen3rxdeemph[11], w_com_pld_pcs_if_pldgen3rxdeemph[10], w_com_pld_pcs_if_pldgen3rxdeemph[9], w_com_pld_pcs_if_pldgen3rxdeemph[8], w_com_pld_pcs_if_pldgen3rxdeemph[7], w_com_pld_pcs_if_pldgen3rxdeemph[6], w_com_pld_pcs_if_pldgen3rxdeemph[5], w_com_pld_pcs_if_pldgen3rxdeemph[4], w_com_pld_pcs_if_pldgen3rxdeemph[3], w_com_pld_pcs_if_pldgen3rxdeemph[2], w_com_pld_pcs_if_pldgen3rxdeemph[1], w_com_pld_pcs_if_pldgen3rxdeemph[0]};
		assign out_pld_reserved_out = {w_com_pld_pcs_if_pldreservedout[10], w_com_pld_pcs_if_pldreservedout[9], w_com_pld_pcs_if_pldreservedout[8], w_com_pld_pcs_if_pldreservedout[7], w_com_pld_pcs_if_pldreservedout[6], w_com_pld_pcs_if_pldreservedout[5], w_com_pld_pcs_if_pldreservedout[4], w_com_pld_pcs_if_pldreservedout[3], w_com_pld_pcs_if_pldreservedout[2], w_com_pld_pcs_if_pldreservedout[1], w_com_pld_pcs_if_pldreservedout[0]};
		assign out_pld_rx_data = {w_rx_pld_pcs_if_dataouttopld[63], w_rx_pld_pcs_if_dataouttopld[62], w_rx_pld_pcs_if_dataouttopld[61], w_rx_pld_pcs_if_dataouttopld[60], w_rx_pld_pcs_if_dataouttopld[59], w_rx_pld_pcs_if_dataouttopld[58], w_rx_pld_pcs_if_dataouttopld[57], w_rx_pld_pcs_if_dataouttopld[56], w_rx_pld_pcs_if_dataouttopld[55], w_rx_pld_pcs_if_dataouttopld[54], w_rx_pld_pcs_if_dataouttopld[53], w_rx_pld_pcs_if_dataouttopld[52], w_rx_pld_pcs_if_dataouttopld[51], w_rx_pld_pcs_if_dataouttopld[50], w_rx_pld_pcs_if_dataouttopld[49], w_rx_pld_pcs_if_dataouttopld[48], w_rx_pld_pcs_if_dataouttopld[47], w_rx_pld_pcs_if_dataouttopld[46], w_rx_pld_pcs_if_dataouttopld[45], w_rx_pld_pcs_if_dataouttopld[44], w_rx_pld_pcs_if_dataouttopld[43], w_rx_pld_pcs_if_dataouttopld[42], w_rx_pld_pcs_if_dataouttopld[41], w_rx_pld_pcs_if_dataouttopld[40], w_rx_pld_pcs_if_dataouttopld[39], w_rx_pld_pcs_if_dataouttopld[38], w_rx_pld_pcs_if_dataouttopld[37], w_rx_pld_pcs_if_dataouttopld[36], w_rx_pld_pcs_if_dataouttopld[35], w_rx_pld_pcs_if_dataouttopld[34], w_rx_pld_pcs_if_dataouttopld[33], w_rx_pld_pcs_if_dataouttopld[32], w_rx_pld_pcs_if_dataouttopld[31], w_rx_pld_pcs_if_dataouttopld[30], w_rx_pld_pcs_if_dataouttopld[29], w_rx_pld_pcs_if_dataouttopld[28], w_rx_pld_pcs_if_dataouttopld[27], w_rx_pld_pcs_if_dataouttopld[26], w_rx_pld_pcs_if_dataouttopld[25], w_rx_pld_pcs_if_dataouttopld[24], w_rx_pld_pcs_if_dataouttopld[23], w_rx_pld_pcs_if_dataouttopld[22], w_rx_pld_pcs_if_dataouttopld[21], w_rx_pld_pcs_if_dataouttopld[20], w_rx_pld_pcs_if_dataouttopld[19], w_rx_pld_pcs_if_dataouttopld[18], w_rx_pld_pcs_if_dataouttopld[17], w_rx_pld_pcs_if_dataouttopld[16], w_rx_pld_pcs_if_dataouttopld[15], w_rx_pld_pcs_if_dataouttopld[14], w_rx_pld_pcs_if_dataouttopld[13], w_rx_pld_pcs_if_dataouttopld[12], w_rx_pld_pcs_if_dataouttopld[11], w_rx_pld_pcs_if_dataouttopld[10], w_rx_pld_pcs_if_dataouttopld[9], w_rx_pld_pcs_if_dataouttopld[8], w_rx_pld_pcs_if_dataouttopld[7], w_rx_pld_pcs_if_dataouttopld[6], w_rx_pld_pcs_if_dataouttopld[5], w_rx_pld_pcs_if_dataouttopld[4], w_rx_pld_pcs_if_dataouttopld[3], w_rx_pld_pcs_if_dataouttopld[2], w_rx_pld_pcs_if_dataouttopld[1], w_rx_pld_pcs_if_dataouttopld[0]};
		assign out_pld_test_data = {w_com_pld_pcs_if_pldtestdata[19], w_com_pld_pcs_if_pldtestdata[18], w_com_pld_pcs_if_pldtestdata[17], w_com_pld_pcs_if_pldtestdata[16], w_com_pld_pcs_if_pldtestdata[15], w_com_pld_pcs_if_pldtestdata[14], w_com_pld_pcs_if_pldtestdata[13], w_com_pld_pcs_if_pldtestdata[12], w_com_pld_pcs_if_pldtestdata[11], w_com_pld_pcs_if_pldtestdata[10], w_com_pld_pcs_if_pldtestdata[9], w_com_pld_pcs_if_pldtestdata[8], w_com_pld_pcs_if_pldtestdata[7], w_com_pld_pcs_if_pldtestdata[6], w_com_pld_pcs_if_pldtestdata[5], w_com_pld_pcs_if_pldtestdata[4], w_com_pld_pcs_if_pldtestdata[3], w_com_pld_pcs_if_pldtestdata[2], w_com_pld_pcs_if_pldtestdata[1], w_com_pld_pcs_if_pldtestdata[0]};
		assign out_pld_test_si_to_agg_out = w_com_pcs_pma_if_pldtestsitoaggout;
		assign out_pma_current_coeff = {w_com_pcs_pma_if_pmacurrentcoeff[17], w_com_pcs_pma_if_pmacurrentcoeff[16], w_com_pcs_pma_if_pmacurrentcoeff[15], w_com_pcs_pma_if_pmacurrentcoeff[14], w_com_pcs_pma_if_pmacurrentcoeff[13], w_com_pcs_pma_if_pmacurrentcoeff[12], w_com_pcs_pma_if_pmacurrentcoeff[11], w_com_pcs_pma_if_pmacurrentcoeff[10], w_com_pcs_pma_if_pmacurrentcoeff[9], w_com_pcs_pma_if_pmacurrentcoeff[8], w_com_pcs_pma_if_pmacurrentcoeff[7], w_com_pcs_pma_if_pmacurrentcoeff[6], w_com_pcs_pma_if_pmacurrentcoeff[5], w_com_pcs_pma_if_pmacurrentcoeff[4], w_com_pcs_pma_if_pmacurrentcoeff[3], w_com_pcs_pma_if_pmacurrentcoeff[2], w_com_pcs_pma_if_pmacurrentcoeff[1], w_com_pcs_pma_if_pmacurrentcoeff[0]};
		assign out_pma_current_rxpreset = {w_com_pcs_pma_if_pmacurrentrxpreset[2], w_com_pcs_pma_if_pmacurrentrxpreset[1], w_com_pcs_pma_if_pmacurrentrxpreset[0]};
		assign out_pma_early_eios = w_com_pcs_pma_if_pmaearlyeios;
		assign out_pma_eye_monitor_out = {w_rx_pcs_pma_if_pmaeyemonitorout[7], w_rx_pcs_pma_if_pmaeyemonitorout[6], w_rx_pcs_pma_if_pmaeyemonitorout[5], w_rx_pcs_pma_if_pmaeyemonitorout[4], w_rx_pcs_pma_if_pmaeyemonitorout[3], w_rx_pcs_pma_if_pmaeyemonitorout[2], w_rx_pcs_pma_if_pmaeyemonitorout[1], w_rx_pcs_pma_if_pmaeyemonitorout[0]};
		assign out_pma_lc_cmu_rstb = w_com_pcs_pma_if_pmalccmurstb;
		assign out_pma_ltr = w_com_pcs_pma_if_pmaltr;
		assign out_pma_nfrzdrv = w_com_pcs_pma_if_pmanfrzdrv;
		assign out_pma_partial_reconfig = w_com_pcs_pma_if_pmapartialreconfig;
		assign out_pma_pcie_switch = {w_com_pcs_pma_if_pmapcieswitch[1], w_com_pcs_pma_if_pmapcieswitch[0]};
		assign out_pma_ppm_lock = w_com_pcs_pma_if_freqlock;
		assign out_pma_reserved_out = {w_rx_pcs_pma_if_pmareservedout[4], w_rx_pcs_pma_if_pmareservedout[3], w_rx_pcs_pma_if_pmareservedout[2], w_rx_pcs_pma_if_pmareservedout[1], w_rx_pcs_pma_if_pmareservedout[0]};
		assign out_pma_rx_clk_out = w_rx_pcs_pma_if_pmarxclkout;
		assign out_pma_rxclkslip = w_rx_pcs_pma_if_pmarxclkslip;
		assign out_pma_rxpma_rstb = w_rx_pcs_pma_if_pmarxpmarstb;
		assign out_pma_tx_clk_out = w_tx_pcs_pma_if_pmatxclkout;
		assign out_pma_tx_data = {w_tx_pcs_pma_if_dataouttopma[79], w_tx_pcs_pma_if_dataouttopma[78], w_tx_pcs_pma_if_dataouttopma[77], w_tx_pcs_pma_if_dataouttopma[76], w_tx_pcs_pma_if_dataouttopma[75], w_tx_pcs_pma_if_dataouttopma[74], w_tx_pcs_pma_if_dataouttopma[73], w_tx_pcs_pma_if_dataouttopma[72], w_tx_pcs_pma_if_dataouttopma[71], w_tx_pcs_pma_if_dataouttopma[70], w_tx_pcs_pma_if_dataouttopma[69], w_tx_pcs_pma_if_dataouttopma[68], w_tx_pcs_pma_if_dataouttopma[67], w_tx_pcs_pma_if_dataouttopma[66], w_tx_pcs_pma_if_dataouttopma[65], w_tx_pcs_pma_if_dataouttopma[64], w_tx_pcs_pma_if_dataouttopma[63], w_tx_pcs_pma_if_dataouttopma[62], w_tx_pcs_pma_if_dataouttopma[61], w_tx_pcs_pma_if_dataouttopma[60], w_tx_pcs_pma_if_dataouttopma[59], w_tx_pcs_pma_if_dataouttopma[58], w_tx_pcs_pma_if_dataouttopma[57], w_tx_pcs_pma_if_dataouttopma[56], w_tx_pcs_pma_if_dataouttopma[55], w_tx_pcs_pma_if_dataouttopma[54], w_tx_pcs_pma_if_dataouttopma[53], w_tx_pcs_pma_if_dataouttopma[52], w_tx_pcs_pma_if_dataouttopma[51], w_tx_pcs_pma_if_dataouttopma[50], w_tx_pcs_pma_if_dataouttopma[49], w_tx_pcs_pma_if_dataouttopma[48], w_tx_pcs_pma_if_dataouttopma[47], w_tx_pcs_pma_if_dataouttopma[46], w_tx_pcs_pma_if_dataouttopma[45], w_tx_pcs_pma_if_dataouttopma[44], w_tx_pcs_pma_if_dataouttopma[43], w_tx_pcs_pma_if_dataouttopma[42], w_tx_pcs_pma_if_dataouttopma[41], w_tx_pcs_pma_if_dataouttopma[40], w_tx_pcs_pma_if_dataouttopma[39], w_tx_pcs_pma_if_dataouttopma[38], w_tx_pcs_pma_if_dataouttopma[37], w_tx_pcs_pma_if_dataouttopma[36], w_tx_pcs_pma_if_dataouttopma[35], w_tx_pcs_pma_if_dataouttopma[34], w_tx_pcs_pma_if_dataouttopma[33], w_tx_pcs_pma_if_dataouttopma[32], w_tx_pcs_pma_if_dataouttopma[31], w_tx_pcs_pma_if_dataouttopma[30], w_tx_pcs_pma_if_dataouttopma[29], w_tx_pcs_pma_if_dataouttopma[28], w_tx_pcs_pma_if_dataouttopma[27], w_tx_pcs_pma_if_dataouttopma[26], w_tx_pcs_pma_if_dataouttopma[25], w_tx_pcs_pma_if_dataouttopma[24], w_tx_pcs_pma_if_dataouttopma[23], w_tx_pcs_pma_if_dataouttopma[22], w_tx_pcs_pma_if_dataouttopma[21], w_tx_pcs_pma_if_dataouttopma[20], w_tx_pcs_pma_if_dataouttopma[19], w_tx_pcs_pma_if_dataouttopma[18], w_tx_pcs_pma_if_dataouttopma[17], w_tx_pcs_pma_if_dataouttopma[16], w_tx_pcs_pma_if_dataouttopma[15], w_tx_pcs_pma_if_dataouttopma[14], w_tx_pcs_pma_if_dataouttopma[13], w_tx_pcs_pma_if_dataouttopma[12], w_tx_pcs_pma_if_dataouttopma[11], w_tx_pcs_pma_if_dataouttopma[10], w_tx_pcs_pma_if_dataouttopma[9], w_tx_pcs_pma_if_dataouttopma[8], w_tx_pcs_pma_if_dataouttopma[7], w_tx_pcs_pma_if_dataouttopma[6], w_tx_pcs_pma_if_dataouttopma[5], w_tx_pcs_pma_if_dataouttopma[4], w_tx_pcs_pma_if_dataouttopma[3], w_tx_pcs_pma_if_dataouttopma[2], w_tx_pcs_pma_if_dataouttopma[1], w_tx_pcs_pma_if_dataouttopma[0]};
		assign out_pma_tx_elec_idle = w_com_pcs_pma_if_pmatxelecidle;
		assign out_pma_tx_pma_syncp_fbkp = w_tx_pcs_pma_if_pmatxpmasyncpfbkp;
		assign out_pma_txdetectrx = w_com_pcs_pma_if_pmatxdetectrx;
		assign out_reset_pc_ptrs_out_chnl_down = w_pcs8g_rx_resetpcptrsoutchnldown;
		assign out_reset_pc_ptrs_out_chnl_up = w_pcs8g_rx_resetpcptrsoutchnlup;
		assign out_reset_ppm_cntrs_out_chnl_down = w_pcs8g_rx_resetppmcntrsoutchnldown;
		assign out_reset_ppm_cntrs_out_chnl_up = w_pcs8g_rx_resetppmcntrsoutchnlup;
		assign out_rx_div_sync_out_chnl_down = {w_pcs8g_rx_rxdivsyncoutchnldown[1], w_pcs8g_rx_rxdivsyncoutchnldown[0]};
		assign out_rx_div_sync_out_chnl_up = {w_pcs8g_rx_rxdivsyncoutchnlup[1], w_pcs8g_rx_rxdivsyncoutchnlup[0]};
		assign out_rx_rd_enable_out_chnl_down = w_pcs8g_rx_rdenableoutchnldown;
		assign out_rx_rd_enable_out_chnl_up = w_pcs8g_rx_rdenableoutchnlup;
		assign out_rx_we_out_chnl_down = {w_pcs8g_rx_rxweoutchnldown[1], w_pcs8g_rx_rxweoutchnldown[0]};
		assign out_rx_we_out_chnl_up = {w_pcs8g_rx_rxweoutchnlup[1], w_pcs8g_rx_rxweoutchnlup[0]};
		assign out_rx_wr_enable_out_chnl_down = w_pcs8g_rx_wrenableoutchnldown;
		assign out_rx_wr_enable_out_chnl_up = w_pcs8g_rx_wrenableoutchnlup;
		assign out_speed_change_out_chnl_down = w_pcs8g_rx_speedchangeoutchnldown;
		assign out_speed_change_out_chnl_up = w_pcs8g_rx_speedchangeoutchnlup;
		assign out_tx_div_sync_out_chnl_down = {w_pcs8g_tx_txdivsyncoutchnldown[1], w_pcs8g_tx_txdivsyncoutchnldown[0]};
		assign out_tx_div_sync_out_chnl_up = {w_pcs8g_tx_txdivsyncoutchnlup[1], w_pcs8g_tx_txdivsyncoutchnlup[0]};
		assign out_tx_rd_enable_out_chnl_down = w_pcs8g_tx_rdenableoutchnldown;
		assign out_tx_rd_enable_out_chnl_up = w_pcs8g_tx_rdenableoutchnlup;
		assign out_tx_wr_enable_out_chnl_down = w_pcs8g_tx_wrenableoutchnldown;
		assign out_tx_wr_enable_out_chnl_up = w_pcs8g_tx_wrenableoutchnlup;
	endgenerate
endmodule
// altera message_on 10036 
