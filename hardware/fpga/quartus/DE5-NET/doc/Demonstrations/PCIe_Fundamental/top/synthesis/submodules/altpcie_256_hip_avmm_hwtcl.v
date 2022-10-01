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


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

module altpcie_rxm_2_dma_controller_decode # (
    parameter  bar_type_hwtcl = 64
  ) (
      input  [bar_type_hwtcl-1:0] rxm_address_i,
      input  [31:0]  rxm_read_data_wr_ctrl_i,
      input  rxm_read_data_valid_wr_ctrl_i,
      input  [31:0]  rxm_read_data_rd_ctrl_i,
      input  rxm_read_data_valid_rd_ctrl_i,
      input  rxm_wait_request_rd_ctrl_i,
      input  rxm_wait_request_wr_ctrl_i,
      output rxm_read_data_valid_o,
      output [31:0] rxm_read_data_o,
      output chip_select_rdctrl_o,
      output chip_select_wrctrl_o,
      output rxm_wait_request_o
  );

  assign chip_select_wrctrl_o = rxm_address_i[8];
  assign chip_select_rdctrl_o = ~chip_select_wrctrl_o;
  assign rxm_read_data_valid_o = (chip_select_wrctrl_o) ?   rxm_read_data_valid_wr_ctrl_i  : rxm_read_data_valid_rd_ctrl_i;
  assign rxm_read_data_o       = (chip_select_wrctrl_o) ?   rxm_read_data_wr_ctrl_i        : rxm_read_data_rd_ctrl_i;
  assign rxm_wait_request_o    = (chip_select_wrctrl_o) ?   rxm_wait_request_wr_ctrl_i     : rxm_wait_request_rd_ctrl_i;

endmodule

module altpcie_256_hip_avmm_hwtcl # (

      parameter pll_refclk_freq_hwtcl                             = "100 MHz",
      parameter enable_slot_register_hwtcl                        = 0,
      parameter port_type_hwtcl                                   = "Native endpoint",
      parameter bypass_cdc_hwtcl                                  = "false",
      parameter enable_rx_buffer_checking_hwtcl                   = "false",
      parameter single_rx_detect_hwtcl                            = 0,
      parameter use_crc_forwarding_hwtcl                          = 0,
      parameter ast_width_hwtcl                                   = "rx_tx_64",
      parameter gen123_lane_rate_mode_hwtcl                       = "gen1",
      parameter lane_mask_hwtcl                                   = "x4",
      parameter disable_link_x2_support_hwtcl                     = "false",
      parameter hip_hard_reset_hwtcl                              = 1,
      parameter wrong_device_id_hwtcl                             = "disable",
      parameter data_pack_rx_hwtcl                                = "disable",
      parameter use_ast_parity                                    = 0,
      parameter ltssm_1ms_timeout_hwtcl                           = "disable",
      parameter ltssm_freqlocked_check_hwtcl                      = "disable",
      parameter deskew_comma_hwtcl                                = "com_deskw",
      parameter port_link_number_hwtcl                            = 1,
      parameter device_number_hwtcl                               = 0,
      parameter bypass_clk_switch_hwtcl                           = "TRUE",
      parameter pipex1_debug_sel_hwtcl                            = "disable",
      parameter pclk_out_sel_hwtcl                                = "pclk",
      parameter vendor_id_hwtcl                                   = 4466, 
      parameter device_id_hwtcl                                   = 57345,
      parameter revision_id_hwtcl                                 = 1,
      parameter class_code_hwtcl                                  = 16711680,
      parameter subsystem_vendor_id_hwtcl                         = 4466,
      parameter subsystem_device_id_hwtcl                         = 57345,
      parameter no_soft_reset_hwtcl                               = "false",
      parameter maximum_current_hwtcl                             = 0,
      parameter d1_support_hwtcl                                  = "false",
      parameter d2_support_hwtcl                                  = "false",
      parameter d0_pme_hwtcl                                      = "false",
      parameter d1_pme_hwtcl                                      = "false",
      parameter d2_pme_hwtcl                                      = "false",
      parameter d3_hot_pme_hwtcl                                  = "false",
      parameter d3_cold_pme_hwtcl                                 = "false",
      parameter use_aer_hwtcl                                     = 0,
      parameter low_priority_vc_hwtcl                             = "single_vc",
      parameter disable_snoop_packet_hwtcl                        = "false",
      parameter max_payload_size_hwtcl                            = 256,
      parameter surprise_down_error_support_hwtcl                 = 0,
      parameter dll_active_report_support_hwtcl                   = 0,
      parameter extend_tag_field_hwtcl                            = "false",
      parameter endpoint_l0_latency_hwtcl                         = 0,
      parameter endpoint_l1_latency_hwtcl                         = 0,
      parameter indicator_hwtcl                                   = 7,
      parameter slot_power_scale_hwtcl                            = 0,
      parameter enable_l1_aspm_hwtcl                              = "false",
      parameter l1_exit_latency_sameclock_hwtcl                   = 0,
      parameter l1_exit_latency_diffclock_hwtcl                   = 0,
      parameter hot_plug_support_hwtcl                            = 0,
      parameter slot_power_limit_hwtcl                            = 0,
      parameter slot_number_hwtcl                                 = 0,
      parameter diffclock_nfts_count_hwtcl                        = 0,
      parameter sameclock_nfts_count_hwtcl                        = 0,
      parameter completion_timeout_hwtcl                          = "abcd",
      parameter enable_completion_timeout_disable_hwtcl           = 1,
      parameter extended_tag_reset_hwtcl                          = "false",
      parameter ecrc_check_capable_hwtcl                          = 0,
      parameter ecrc_gen_capable_hwtcl                            = 0,
      parameter no_command_completed_hwtcl                        = "true",
      parameter msi_multi_message_capable_hwtcl                   = "count_4",
      parameter msi_64bit_addressing_capable_hwtcl                = "true",
      parameter msi_masking_capable_hwtcl                         = "false",
      parameter msi_support_hwtcl                                 = "true",
      parameter interrupt_pin_hwtcl                               = "inta",
      parameter enable_function_msix_support_hwtcl                = 0,
      parameter msix_table_size_hwtcl                             = 0,
      parameter msix_table_bir_hwtcl                              = 0,
      parameter msix_table_offset_hwtcl                           = "0",
      parameter msix_pba_bir_hwtcl                                = 0,
      parameter msix_pba_offset_hwtcl                             = "0",
      parameter bridge_port_vga_enable_hwtcl                      = "false",
      parameter bridge_port_ssid_support_hwtcl                    = "false",
      parameter ssvid_hwtcl                                       = 0,
      parameter ssid_hwtcl                                        = 0,
      parameter eie_before_nfts_count_hwtcl                       = 4,
      parameter gen2_diffclock_nfts_count_hwtcl                   = 255,
      parameter gen2_sameclock_nfts_count_hwtcl                   = 255,
      parameter deemphasis_enable_hwtcl                           = "false",
      parameter pcie_spec_version_hwtcl                           = "v2",
      parameter l0_exit_latency_sameclock_hwtcl                   = 6,
      parameter l0_exit_latency_diffclock_hwtcl                   = 6,
      parameter rx_ei_l0s_hwtcl                                   = 1,
      parameter l2_async_logic_hwtcl                              = "enable",
      parameter aspm_config_management_hwtcl                      = "true",
      parameter atomic_op_routing_hwtcl                           = "false",
      parameter atomic_op_completer_32bit_hwtcl                   = "false",
      parameter atomic_op_completer_64bit_hwtcl                   = "false",
      parameter cas_completer_128bit_hwtcl                        = "false",
      parameter ltr_mechanism_hwtcl                               = "false",
      parameter tph_completer_hwtcl                               = "false",
      parameter extended_format_field_hwtcl                       = "false",
      parameter atomic_malformed_hwtcl                            = "false",
      parameter flr_capability_hwtcl                              = "true",
      parameter enable_adapter_half_rate_mode_hwtcl               = "false",
      parameter vc0_clk_enable_hwtcl                              = "true",
      parameter register_pipe_signals_hwtcl                       = "false",
      parameter bar0_io_space_hwtcl                               = "Disabled",
      parameter bar0_type_hwtcl                                   = 64,
      parameter bar0_64bit_mem_space_hwtcl                        = "Enabled",
      parameter bar0_prefetchable_hwtcl                           = "Enabled",
      parameter bar0_size_mask_hwtcl                              = "256 MBytes - 28 bits",
      parameter bar1_io_space_hwtcl                               = "Disabled",
      parameter bar1_type_hwtcl                                   = 1,
      parameter bar1_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar1_prefetchable_hwtcl                           = "Disabled",
      parameter bar1_size_mask_hwtcl                              = "N/A",
      parameter bar2_io_space_hwtcl                               = "Disabled",
      parameter bar2_type_hwtcl                                   = 32,
      parameter bar2_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar2_prefetchable_hwtcl                           = "Disabled",
      parameter bar2_size_mask_hwtcl                              = "N/A",
      parameter bar3_io_space_hwtcl                               = "Disabled",
      parameter bar3_type_hwtcl                                   = 32,
      parameter bar3_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar3_prefetchable_hwtcl                           = "Disabled",
      parameter bar3_size_mask_hwtcl                              = "N/A",
      parameter bar4_io_space_hwtcl                               = "Disabled",
      parameter bar4_type_hwtcl                                   = 32,
      parameter bar4_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar4_prefetchable_hwtcl                           = "Disabled",
      parameter bar4_size_mask_hwtcl                              = "N/A",
      parameter bar5_io_space_hwtcl                               = "Disabled",
      parameter bar5_type_hwtcl                                   = 32,
      parameter bar5_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar5_prefetchable_hwtcl                           = "Disabled",
      parameter bar5_size_mask_hwtcl                              = "N/A",
      parameter rd_dma_size_mask_hwtcl                            = 8,
      parameter wr_dma_size_mask_hwtcl                            = 8,
      parameter expansion_base_address_register_hwtcl             = 0,
      parameter io_window_addr_width_hwtcl                        = "window_32_bit",
      parameter prefetchable_mem_window_addr_width_hwtcl          = "prefetch_32",
      parameter skp_os_gen3_count_hwtcl                           = 0,
      parameter tx_cdc_almost_empty_hwtcl                         = 5,
      parameter rx_cdc_almost_full_hwtcl                          = 6,
      parameter tx_cdc_almost_full_hwtcl                          = 6,
      parameter rx_l0s_count_idl_hwtcl                            = 0,
      parameter cdc_dummy_insert_limit_hwtcl                      = 11,
      parameter ei_delay_powerdown_count_hwtcl                    = 10,
      parameter millisecond_cycle_count_hwtcl                     = 0,
      parameter skp_os_schedule_count_hwtcl                       = 0,
      parameter fc_init_timer_hwtcl                               = 1024,
      parameter l01_entry_latency_hwtcl                           = 31,
      parameter flow_control_update_count_hwtcl                   = 30,
      parameter flow_control_timeout_count_hwtcl                  = 200,
      parameter credit_buffer_allocation_aux_hwtcl                = "balanced",
      parameter vc0_rx_flow_ctrl_posted_header_hwtcl              = 50,
      parameter vc0_rx_flow_ctrl_posted_data_hwtcl                = 360,
      parameter vc0_rx_flow_ctrl_nonposted_header_hwtcl           = 54,
      parameter vc0_rx_flow_ctrl_nonposted_data_hwtcl             = 0,
      parameter vc0_rx_flow_ctrl_compl_header_hwtcl               = 112,
      parameter vc0_rx_flow_ctrl_compl_data_hwtcl                 = 448,
      parameter rx_ptr0_posted_dpram_min_hwtcl                    = 0,
      parameter rx_ptr0_posted_dpram_max_hwtcl                    = 0,
      parameter rx_ptr0_nonposted_dpram_min_hwtcl                 = 0,
      parameter rx_ptr0_nonposted_dpram_max_hwtcl                 = 0,
      parameter retry_buffer_last_active_address_hwtcl            = 2047,
      parameter retry_buffer_memory_settings_hwtcl                = 0,
      parameter vc0_rx_buffer_memory_settings_hwtcl               = 0,
      parameter in_cvp_mode_hwtcl                                 = 0,
      parameter use_cvp_update_core_pof_hwtcl                     = 0,
      parameter slotclkcfg_hwtcl                                  = 1,
      parameter reconfig_to_xcvr_width                            = 350,
      parameter set_pld_clk_x1_625MHz_hwtcl                       = 0,
      parameter reconfig_from_xcvr_width                          = 230,
      parameter enable_l0s_aspm_hwtcl                             = "true",
      parameter cpl_spc_header_hwtcl                              = 195,
      parameter cpl_spc_data_hwtcl                                = 781,
      parameter port_width_be_hwtcl                               = 8,
      parameter port_width_data_hwtcl                             = 64,
      parameter reserved_debug_hwtcl                              = 0,
      parameter hip_reconfig_hwtcl                                = 0,
      parameter vsec_id_hwtcl                                     = 0,
      parameter vsec_rev_hwtcl                                    = 0,
      parameter gen3_rxfreqlock_counter_hwtcl                     = 0,
      parameter gen3_skip_ph2_ph3_hwtcl                           = 1,
      parameter g3_bypass_equlz_hwtcl                             = 1,
      parameter enable_tl_only_sim_hwtcl                          = 0,
      parameter use_atx_pll_hwtcl                                 = 0,
      parameter cvp_rate_sel_hwtcl                                = "full_rate",
      parameter cvp_data_compressed_hwtcl                         = "false",
      parameter cvp_data_encrypted_hwtcl                          = "false",
      parameter cvp_mode_reset_hwtcl                              = "false",
      parameter cvp_clk_reset_hwtcl                               = "false",
      parameter cseb_cpl_status_during_cvp_hwtcl                  = "config_retry_status",
      parameter core_clk_sel_hwtcl                                = "pld_clk",
      parameter g3_dis_rx_use_prst_hwtcl                          = "true",
      parameter g3_dis_rx_use_prst_ep_hwtcl                       = "false",

      parameter hwtcl_override_g2_txvod                           = 0, // When 1 use gen3 param from HWTCL, else use default
      parameter rpre_emph_a_val_hwtcl                             = 9 ,
      parameter rpre_emph_b_val_hwtcl                             = 0 ,
      parameter rpre_emph_c_val_hwtcl                             = 16,
      parameter rpre_emph_d_val_hwtcl                             = 11,
      parameter rpre_emph_e_val_hwtcl                             = 5 ,
      parameter rvod_sel_a_val_hwtcl                              = 42,
      parameter rvod_sel_b_val_hwtcl                              = 38,
      parameter rvod_sel_c_val_hwtcl                              = 38,
      parameter rvod_sel_d_val_hwtcl                              = 38,
      parameter rvod_sel_e_val_hwtcl                              = 15,

      /// Add AV/CV parameters VOD
      parameter av_rpre_emph_a_val_hwtcl                          = 12,
      parameter av_rpre_emph_b_val_hwtcl                          = 0,
      parameter av_rpre_emph_c_val_hwtcl                          = 19,
      parameter av_rpre_emph_d_val_hwtcl                          = 13,
      parameter av_rpre_emph_e_val_hwtcl                          = 21,
      parameter av_rvod_sel_a_val_hwtcl                           = 42,
      parameter av_rvod_sel_b_val_hwtcl                           = 30,
      parameter av_rvod_sel_c_val_hwtcl                           = 43,
      parameter av_rvod_sel_d_val_hwtcl                           = 43,
      parameter av_rvod_sel_e_val_hwtcl                           = 9,

      parameter cv_rpre_emph_a_val_hwtcl                          = 11,
      parameter cv_rpre_emph_b_val_hwtcl                          = 0,
      parameter cv_rpre_emph_c_val_hwtcl                          = 22,
      parameter cv_rpre_emph_d_val_hwtcl                          = 12,
      parameter cv_rpre_emph_e_val_hwtcl                          = 21,
      parameter cv_rvod_sel_a_val_hwtcl                           = 50,
      parameter cv_rvod_sel_b_val_hwtcl                           = 34,
      parameter cv_rvod_sel_c_val_hwtcl                           = 50,
      parameter cv_rvod_sel_d_val_hwtcl                           = 50,
      parameter cv_rvod_sel_e_val_hwtcl                           = 9,

      /// Reset and HIP parameters
      parameter enable_power_on_rst_pulse_hwtcl                   = 0,
      parameter enable_pcisigtest_hwtcl                           = 0,
      parameter hip_tag_checking_hwtcl                            = 1,
      parameter set_pll_coreclkout_cin_hwtcl                      = "NA",
      parameter set_pll_coreclkout_cout_hwtcl                     = "NA",

      /// Bridge Parameters
      parameter bar_prefetchable                                  = 1,
      parameter avmm_width_hwtcl                                  = 256,
      parameter avmm_burst_width_hwtcl                            = 7,
      parameter DMA_BRST_CNT_W                                    = 5,
      parameter DMA_WIDTH                                         = 256,
      parameter DMA_BE_WIDTH                                      = 32,
      parameter TX_S_ADDR_WIDTH                                   = 32,

      parameter INTENDED_DEVICE_FAMILY                            = "Stratix V",
      parameter use_tl_cfg_sync_hwtcl                             = 0,
      parameter internal_controller_hwtcl                         = 0,
      parameter enable_rxm_burst_hwtcl                            = 0,
      parameter enable_cra_hwtcl                                  = 1,

      // PCIe Toolkit
      parameter dma_use_scfifo_ext_hwtcl                          = 0,
      parameter tlp_inspector_hwtcl                               = 0,
      parameter tlp_inspector_use_signal_probe_hwtcl              = 0,
      parameter tlp_insp_trg_dw0_hwtcl                            = 1,
      parameter tlp_insp_trg_dw1_hwtcl                            = 0,
      parameter tlp_insp_trg_dw2_hwtcl                            = 0,
      parameter tlp_insp_trg_dw3_hwtcl                            = 0,
      parameter pcie_inspector_hwtcl                              = 0

) (

      // Reset signals
      input                 pin_perst,
      input                 npor,
      output                reset_status,

      // Serdes related
      input                 refclk,

      // HIP control signals
      input  [4 : 0]        hpg_ctrler,

      // Driven by the testbench
      // Input PIPE simulation for simulation only
      input                 simu_mode_pipe,          // When 1'b1 indicate running DUT under pipe simulation
      input [31 : 0]        test_in,
      output [127 : 0]      testout,
      output [1 : 0]        sim_pipe_rate,
      input                 sim_pipe_pclk_in,
      output                sim_pipe_pclk_out,
      output                sim_pipe_clk250_out,
      output                sim_pipe_clk500_out,
      output [4 : 0]        sim_ltssmstate,
      input                 phystatus0,
      input                 phystatus1,
      input                 phystatus2,
      input                 phystatus3,
      input                 phystatus4,
      input                 phystatus5,
      input                 phystatus6,
      input                 phystatus7,
      input  [7 : 0]        rxdata0,
      input  [7 : 0]        rxdata1,
      input  [7 : 0]        rxdata2,
      input  [7 : 0]        rxdata3,
      input  [7 : 0]        rxdata4,
      input  [7 : 0]        rxdata5,
      input  [7 : 0]        rxdata6,
      input  [7 : 0]        rxdata7,
      input                 rxdatak0,
      input                 rxdatak1,
      input                 rxdatak2,
      input                 rxdatak3,
      input                 rxdatak4,
      input                 rxdatak5,
      input                 rxdatak6,
      input                 rxdatak7,
      input                 rxelecidle0,
      input                 rxelecidle1,
      input                 rxelecidle2,
      input                 rxelecidle3,
      input                 rxelecidle4,
      input                 rxelecidle5,
      input                 rxelecidle6,
      input                 rxelecidle7,
      input                 rxfreqlocked0,
      input                 rxfreqlocked1,
      input                 rxfreqlocked2,
      input                 rxfreqlocked3,
      input                 rxfreqlocked4,
      input                 rxfreqlocked5,
      input                 rxfreqlocked6,
      input                 rxfreqlocked7,
      input  [2 : 0]        rxstatus0,
      input  [2 : 0]        rxstatus1,
      input  [2 : 0]        rxstatus2,
      input  [2 : 0]        rxstatus3,
      input  [2 : 0]        rxstatus4,
      input  [2 : 0]        rxstatus5,
      input  [2 : 0]        rxstatus6,
      input  [2 : 0]        rxstatus7,
      input                 rxdataskip0,
      input                 rxdataskip1,
      input                 rxdataskip2,
      input                 rxdataskip3,
      input                 rxdataskip4,
      input                 rxdataskip5,
      input                 rxdataskip6,
      input                 rxdataskip7,
      input                 rxblkst0,
      input                 rxblkst1,
      input                 rxblkst2,
      input                 rxblkst3,
      input                 rxblkst4,
      input                 rxblkst5,
      input                 rxblkst6,
      input                 rxblkst7,
      input  [1 : 0]        rxsynchd0,
      input  [1 : 0]        rxsynchd1,
      input  [1 : 0]        rxsynchd2,
      input  [1 : 0]        rxsynchd3,
      input  [1 : 0]        rxsynchd4,
      input  [1 : 0]        rxsynchd5,
      input  [1 : 0]        rxsynchd6,
      input  [1 : 0]        rxsynchd7,
      input                 rxvalid0,
      input                 rxvalid1,
      input                 rxvalid2,
      input                 rxvalid3,
      input                 rxvalid4,
      input                 rxvalid5,
      input                 rxvalid6,
      input                 rxvalid7,

      // Output Pipe interface
      output [2 : 0]        eidleinfersel0,
      output [2 : 0]        eidleinfersel1,
      output [2 : 0]        eidleinfersel2,
      output [2 : 0]        eidleinfersel3,
      output [2 : 0]        eidleinfersel4,
      output [2 : 0]        eidleinfersel5,
      output [2 : 0]        eidleinfersel6,
      output [2 : 0]        eidleinfersel7,
      output [1 : 0]        powerdown0,
      output [1 : 0]        powerdown1,
      output [1 : 0]        powerdown2,
      output [1 : 0]        powerdown3,
      output [1 : 0]        powerdown4,
      output [1 : 0]        powerdown5,
      output [1 : 0]        powerdown6,
      output [1 : 0]        powerdown7,
      output                rxpolarity0,
      output                rxpolarity1,
      output                rxpolarity2,
      output                rxpolarity3,
      output                rxpolarity4,
      output                rxpolarity5,
      output                rxpolarity6,
      output                rxpolarity7,
      output                txcompl0,
      output                txcompl1,
      output                txcompl2,
      output                txcompl3,
      output                txcompl4,
      output                txcompl5,
      output                txcompl6,
      output                txcompl7,
      output [7 : 0]        txdata0,
      output [7 : 0]        txdata1,
      output [7 : 0]        txdata2,
      output [7 : 0]        txdata3,
      output [7 : 0]        txdata4,
      output [7 : 0]        txdata5,
      output [7 : 0]        txdata6,
      output [7 : 0]        txdata7,
      output                txdatak0,
      output                txdatak1,
      output                txdatak2,
      output                txdatak3,
      output                txdatak4,
      output                txdatak5,
      output                txdatak6,
      output                txdatak7,
      output                txdatavalid0,
      output                txdatavalid1,
      output                txdatavalid2,
      output                txdatavalid3,
      output                txdatavalid4,
      output                txdatavalid5,
      output                txdatavalid6,
      output                txdatavalid7,
      output                txdetectrx0,
      output                txdetectrx1,
      output                txdetectrx2,
      output                txdetectrx3,
      output                txdetectrx4,
      output                txdetectrx5,
      output                txdetectrx6,
      output                txdetectrx7,
      output                txelecidle0,
      output                txelecidle1,
      output                txelecidle2,
      output                txelecidle3,
      output                txelecidle4,
      output                txelecidle5,
      output                txelecidle6,
      output                txelecidle7,
      output [2 : 0]        txmargin0,
      output [2 : 0]        txmargin1,
      output [2 : 0]        txmargin2,
      output [2 : 0]        txmargin3,
      output [2 : 0]        txmargin4,
      output [2 : 0]        txmargin5,
      output [2 : 0]        txmargin6,
      output [2 : 0]        txmargin7,
      output                txswing0,
      output                txswing1,
      output                txswing2,
      output                txswing3,
      output                txswing4,
      output                txswing5,
      output                txswing6,
      output                txswing7,
      output                txdeemph0,
      output                txdeemph1,
      output                txdeemph2,
      output                txdeemph3,
      output                txdeemph4,
      output                txdeemph5,
      output                txdeemph6,
      output                txdeemph7,
      output                txblkst0,
      output                txblkst1,
      output                txblkst2,
      output                txblkst3,
      output                txblkst4,
      output                txblkst5,
      output                txblkst6,
      output                txblkst7,
      output [1 : 0]        txsynchd0,
      output [1 : 0]        txsynchd1,
      output [1 : 0]        txsynchd2,
      output [1 : 0]        txsynchd3,
      output [1 : 0]        txsynchd4,
      output [1 : 0]        txsynchd5,
      output [1 : 0]        txsynchd6,
      output [1 : 0]        txsynchd7,
      output [17 : 0]       currentcoeff0,
      output [17 : 0]       currentcoeff1,
      output [17 : 0]       currentcoeff2,
      output [17 : 0]       currentcoeff3,
      output [17 : 0]       currentcoeff4,
      output [17 : 0]       currentcoeff5,
      output [17 : 0]       currentcoeff6,
      output [17 : 0]       currentcoeff7,
      output [2 : 0]        currentrxpreset0,
      output [2 : 0]        currentrxpreset1,
      output [2 : 0]        currentrxpreset2,
      output [2 : 0]        currentrxpreset3,
      output [2 : 0]        currentrxpreset4,
      output [2 : 0]        currentrxpreset5,
      output [2 : 0]        currentrxpreset6,
      output [2 : 0]        currentrxpreset7,
      output                coreclkout,

        // Reconfig GXB
      input                [reconfig_to_xcvr_width-1:0]   reconfig_to_xcvr,
      output               [reconfig_from_xcvr_width-1:0] reconfig_from_xcvr,
      output               fixedclk_locked,

      //  HIP Status signals
      output   [1 : 0]        currentspeed,
      output                  derr_cor_ext_rcv,
      output                  derr_cor_ext_rpl,
      output                  derr_rpl,
      output                  dlup,
      output                  dlup_exit,
      output                  ev128ns,
      output                  ev1us,
      output                  hotrst_exit,
      output   [3 : 0]        int_status,
      output                  l2_exit,
      output   [3 : 0]        lane_act,
      output   [4 : 0]        ltssmstate,
      output                  rx_par_err,
      output   [1 : 0]        tx_par_err,
      output                  cfg_par_err,
      output   [7 : 0]        ko_cpl_spc_header,
      output   [11: 0]        ko_cpl_spc_data,
      output   [31:0]         reservedin,

      // CFG TL signals
      output   [3 : 0]        tl_cfg_add,
      output   [31 : 0]       tl_cfg_ctl,
      output   [52 : 0]       tl_cfg_sts,

      // serial interface
      input    rx_in0,
      input    rx_in1,
      input    rx_in2,
      input    rx_in3,
      input    rx_in4,
      input    rx_in5,
      input    rx_in6,
      input    rx_in7,

      output   tx_out0,
      output   tx_out1,
      output   tx_out2,
      output   tx_out3,
      output   tx_out4,
      output   tx_out5,
      output   tx_out6,
      output   tx_out7,

      output                            WrDmaRead_o,
      output    [63:0]                  WrDmaAddress_o,
      output    [DMA_BRST_CNT_W-1:0]    WrDmaBurstCount_o,
      output    [31:0]                  WrDmaByteEnable_o,
      input                             WrDmaWaitRequest_i,
      input                             WrDmaReadDataValid_i,
      input    [DMA_WIDTH-1:0]          WrDmaReadData_i,


// Upstream PCIe Read DMA master port

      output                            RdDmaWrite_o,
      output    [63:0]                  RdDmaAddress_o,
      output    [DMA_WIDTH-1:0]         RdDmaWriteData_o,
      output    [DMA_BRST_CNT_W-1:0]    RdDmaBurstCount_o,
      output    [DMA_BE_WIDTH-1:0]      RdDmaWriteEnable_o,
      input                             RdDmaWaitRequest_i,

      // Read DMA AST Rx port
      output                            RdDmaRxReady_o,
      input     [159:0]                  RdDmaRxData_i,
      input                             RdDmaRxValid_i,

      // Read DMA AST Tx port
      output     [31:0]                 RdDmaTxData_o,
      output                            RdDmaTxValid_o,

      // Write DMA AST Rx port
      output                            WrDmaRxReady_o,
      input     [159:0]                 WrDmaRxData_i,
      input                             WrDmaRxValid_i,

      // Write DMA AST Tx port
      output     [31:0]                 WrDmaTxData_o,
      output                            WrDmaTxValid_o,

      // Avalon Tx Slave interface
      input                                  TxsChipSelect_i,
      input                                  TxsRead_i,
      input                                  TxsWrite_i,
      input  [31:0]                          TxsWriteData_i,
      input  [TX_S_ADDR_WIDTH-1:0]           TxsAddress_i,
      input  [3:0]                           TxsByteEnable_i,
      output                                 TxsReadDataValid_o,
      output  [31:0]                         TxsReadData_o,
      output                                 TxsWaitRequest_o,

      // Avalon Rx Master interface 0
      output                                 RxmWrite_0_o,
      output [bar0_type_hwtcl-1:0]           RxmAddress_0_o,
      output [31:0]                          RxmWriteData_0_o,
      output [3:0]                           RxmByteEnable_0_o,
      input                                  RxmWaitRequest_0_i,
      output                                 RxmRead_0_o,
      input  [31:0]                          RxmReadData_0_i,
      input                                  RxmReadDataValid_0_i,

      // Avalon Rx Master interface 1
      output                                 RxmWrite_1_o,
      output [bar1_type_hwtcl-1:0]           RxmAddress_1_o,
      output [31:0]                          RxmWriteData_1_o,
      output [3:0]                           RxmByteEnable_1_o,
      input                                  RxmWaitRequest_1_i,
      output                                 RxmRead_1_o,
      input  [31:0]                          RxmReadData_1_i,
      input                                  RxmReadDataValid_1_i,

      // Avalon Rx Master interface 2
      output                                 RxmWrite_2_o,
      output [bar2_type_hwtcl-1:0]           RxmAddress_2_o,
      output [31:0]                          RxmWriteData_2_o,
      output [3:0]                           RxmByteEnable_2_o,
      input                                  RxmWaitRequest_2_i,
      output                                 RxmRead_2_o,
      input  [31:0]                          RxmReadData_2_i,
      input                                  RxmReadDataValid_2_i,

      // Avalon Rx Master interface 3
      output                                 RxmWrite_3_o,
      output [bar3_type_hwtcl-1:0]           RxmAddress_3_o,
      output [31:0]                          RxmWriteData_3_o,
      output [3:0]                           RxmByteEnable_3_o,
      input                                  RxmWaitRequest_3_i,
      output                                 RxmRead_3_o,
      input  [31:0]                          RxmReadData_3_i,
      input                                  RxmReadDataValid_3_i,

      // Avalon Rx Master interface 4
      output                                 RxmWrite_4_o,
      output [bar4_type_hwtcl-1:0]           RxmAddress_4_o,
      output [31:0]                          RxmWriteData_4_o,
      output [3:0]                           RxmByteEnable_4_o,
      input                                  RxmWaitRequest_4_i,
      output                                 RxmRead_4_o,
      input  [31:0]                          RxmReadData_4_i,
      input                                  RxmReadDataValid_4_i,

      // Avalon Rx Master interface 5
      output                                 RxmWrite_5_o,
      output [bar5_type_hwtcl-1:0]           RxmAddress_5_o,
      output [31:0]                          RxmWriteData_5_o,
      output [3:0]                           RxmByteEnable_5_o,
      input                                  RxmWaitRequest_5_i,
      output                                 RxmRead_5_o,
      input  [31:0]                          RxmReadData_5_i,
      input                                  RxmReadDataValid_5_i,

      // Avalon High Performance Rx Master interface
      output                                 HPRxmWrite_o,
      output [bar2_type_hwtcl-1:0]           HPRxmAddress_o,
      output [DMA_WIDTH-1:0]                 HPRxmWriteData_o,
      output [(DMA_WIDTH/8)-1:0]             HPRxmByteEnable_o,
      input                                  HPRxmWaitRequest_i,
      output                                 HPRxmRead_o,
      input  [DMA_WIDTH-1:0]                 HPRxmReadData_i,
      output  [5:0]                          HPRxmBurstCount_o,
      input                                  HPRxmReadDataValid_i,

      /// DT 256-bit slave interface

      input                                  RdDTSChipSelect_i,
      input                                  RdDTSWrite_i,
      input  [4:0]                           RdDTSBurstCount_i,
      input  [7:0]                           RdDTSAddress_i,
      input  [255:0]                         RdDTSWriteData_i,
      output                                 RdDTSWaitRequest_o,

      input                                  WrDTSChipSelect_i,
      input                                  WrDTSWrite_i,
      input  [4:0]                           WrDTSBurstCount_i,
      input  [7:0]                           WrDTSAddress_i,
      input  [255:0]                         WrDTSWriteData_i,
      output                                 WrDTSWaitRequest_o,

      // AVMM Register Master Port (Write only)

      output [63:0]                          WrDCMAddress_o,
      output                                 WrDCMWrite_o,
      output [31:0]                          WrDCMWriteData_o,
      output                                 WrDCMRead_o,
      output [3:0]                           WrDCMByteEnable_o,
      input                                  WrDCMWaitRequest_i,
      input  [31:0]                          WrDCMReadData_i,
      input                                  WrDCMReadDataValid_i,

      output [63:0]                          RdDCMAddress_o,
      output                                 RdDCMWrite_o,
      output [31:0]                          RdDCMWriteData_o,
      output                                 RdDCMRead_o,
      output [3:0]                           RdDCMByteEnable_o,
      input                                  RdDCMWaitRequest_i,
      input  [31:0]                          RdDCMReadData_i,
      input                                  RdDCMReadDataValid_i,

      // Avalon Control Register Access (CRA)lave (This is 32-bit interface)
      input                                  CraChipSelect_i,
      input                                  CraRead,
      input                                  CraWrite,
      input  [31:0]                          CraWriteData_i,
      input  [13:0]                          CraAddress_i,
      input  [3:0]                           CraByteEnable_i,
      output [31:0]                          CraReadData_o,      // This comes from Rx Completion to be returned to Avalon master
      output                                 CraWaitRequest_o,
      output                                 CraIrq_o,

      /// MSI/MSI-X/INTx supported signals
      output  [81:0]                         MsiIntfc_o,
      output  [15:0]                         MsixIntfc_o,
      
      input                                  IntxReq_i,
      output                                 IntxAck_o,

      /// TL Direct BFM Interce
       output [1000 : 0]    tlbfm_in,
       input  [1000 : 0]    tlbfm_out
);


wire [1 :0]        tx_st_empty;
wire               tx_st_eop;
wire               tx_st_err;
wire               tx_st_sop;
wire [avmm_width_hwtcl-1 : 0]     tx_st_data;
wire [(avmm_width_hwtcl/8)-1:0]      tx_st_parity;
wire [avmm_width_hwtcl-1 : 0]     rx_st_data;
wire [(avmm_width_hwtcl/8)-1:0]      rx_st_parity;
wire [(avmm_width_hwtcl/8)-1:0]      rx_st_be;
wire [3 : 0]       rx_st_sop_int;
wire [3 : 0]       rx_st_valid_int;
wire [1 : 0]       rx_st_empty_int;
wire [3 : 0]       rx_st_eop_int;
wire [3 : 0]       rx_st_err_int;
wire [7 : 0]       rx_st_bardec1;
wire [7 : 0]       rx_st_bardec2;


wire                serdes_pll_locked;
wire                avmm_dma_bridge_pll_coreclkout_locked;
wire                pld_clk_inuse;
wire                pld_core_ready;
wire                coreclkout_pll_locked;
wire                coreclkout_hip;
wire                pld_clk_hip;
reg           [1:0] pld_clk_rst_r;
reg                 pld_clk_rst;
wire                avmm_rstn;

//  Application interface
wire                  serr_out;
wire                  app_int_ack;
wire                  app_msi_ack;
wire                  lmi_ack;
wire   [31 : 0]       lmi_dout;
wire                  pme_to_sr;

wire   [7 : 0]        rx_st_bar;
wire                  rx_st_sop;
wire                  rx_st_valid;
wire  [1 : 0]         rx_st_empty;
wire                  rx_st_eop;
wire                  rx_st_err;

wire   [11 : 0]       tx_cred_datafccp;
wire   [11 : 0]       tx_cred_datafcnp;
wire   [11 : 0]       tx_cred_datafcp;
wire   [5 : 0]        tx_cred_fchipcons;
wire   [5 : 0]        tx_cred_fcinfinite;
wire   [7 : 0]        tx_cred_hdrfccp;
wire   [7 : 0]        tx_cred_hdrfcnp;
wire   [7 : 0]        tx_cred_hdrfcp;
wire                  tx_st_ready;


// Internal wire for internal test port (PE/TE)
wire [32 : 0] open_csebaddr;
wire [4 : 0]  open_csebaddrparity;
wire [3 : 0]  open_csebbe;
wire          open_csebisshadow;
wire          open_csebrden;
wire [31 : 0] open_csebwrdata;
wire [3 : 0]  open_csebwrdataparity;
wire          open_csebwren;
wire          open_csebwrrespreq;
wire [6 : 0]  open_swdnout;
wire [2 : 0]  open_swupout;
wire          open_bistdonearcv;
wire          open_bistdonearcv1;
wire          open_bistdonearpl;
wire          open_bistdonebrcv;
wire          open_bistdonebrcv1;
wire          open_bistdonebrpl;
wire          open_bistpassrcv;
wire          open_bistpassrcv1;
wire          open_bistpassrpl;
wire          open_bistscanoutrcv;
wire          open_bistscanoutrcv1;
wire          open_bistscanoutrpl;
wire          open_memredscout;
wire          open_memregscanout;
wire          open_wakeoen;


// Application signals
wire  [4 : 0]        aer_msi_num;
wire                 app_int_sts;
wire  [4 : 0]        app_msi_num;
wire                 app_msi_req;
wire  [2 : 0]        app_msi_tc;
wire  [4 : 0]        pex_msi_num;

wire                 pm_auxpwr;
wire  [9 : 0]        pm_data;
wire                 pme_to_cr;
wire                 pm_event;
wire                 rx_st_mask;
wire                 rx_st_ready;

wire                 tx_st_valid;
wire  [6 :0]         cpl_err;
wire                 cpl_pending;
wire                 tl_slotclk_cfg;

wire           avalon_clk;

reg [2:0]   reset_status_sync_pldclk_r;
wire        reset_status_sync_pldclk;


wire      reset_status_int;
wire      app_int_sts_internal;
wire      tx_cons_cred_sel = 1'b0;

assign   testout= 128'h0;
assign   txdatavalid0 = 1'b0;
assign   txdatavalid1 = 1'b0;
assign   txdatavalid2 = 1'b0;
assign   txdatavalid3 = 1'b0;
assign   txdatavalid4 = 1'b0;
assign   txdatavalid5 = 1'b0;
assign   txdatavalid6 = 1'b0;
assign   txdatavalid7 = 1'b0;
assign   CraIrq_o = 1'b0;
assign   IntxAck_o = app_int_ack;

localparam WRDMA_VERSION_2 = (DMA_WIDTH == 256)? 1 : 0;
localparam rd_dma_size_mask = (rd_dma_size_mask_hwtcl > 0)? rd_dma_size_mask_hwtcl : 64;
localparam wr_dma_size_mask = (wr_dma_size_mask_hwtcl > 0)? wr_dma_size_mask_hwtcl : 64;


generate if ( (INTENDED_DEVICE_FAMILY == "Stratix V") || (INTENDED_DEVICE_FAMILY == "Arria V GZ") )
begin
     altpcie_sv_hip_ast_hwtcl # (
            .pll_refclk_freq_hwtcl                         (pll_refclk_freq_hwtcl                                   ),
            .enable_slot_register_hwtcl                    (enable_slot_register_hwtcl                              ),
            .port_type_hwtcl                               (port_type_hwtcl                                         ),
            .bypass_cdc_hwtcl                              (bypass_cdc_hwtcl                                        ),
            .enable_rx_buffer_checking_hwtcl               (enable_rx_buffer_checking_hwtcl                         ),
            .single_rx_detect_hwtcl                        (single_rx_detect_hwtcl                                  ),
            .use_crc_forwarding_hwtcl                      (use_crc_forwarding_hwtcl                                ),
            .gen123_lane_rate_mode_hwtcl                   (gen123_lane_rate_mode_hwtcl                             ),
            .lane_mask_hwtcl                               (lane_mask_hwtcl                                         ),
            .set_pld_clk_x1_625MHz_hwtcl                   (set_pld_clk_x1_625MHz_hwtcl                             ),
            .in_cvp_mode_hwtcl                             (in_cvp_mode_hwtcl                                       ),
            .use_cvp_update_core_pof_hwtcl                 (use_cvp_update_core_pof_hwtcl                           ),
            .slotclkcfg_hwtcl                              (slotclkcfg_hwtcl                                        ),
            .reconfig_to_xcvr_width                        (reconfig_to_xcvr_width                                  ),
            .reconfig_from_xcvr_width                      (reconfig_from_xcvr_width                                ),
            .enable_l0s_aspm_hwtcl                         (enable_l0s_aspm_hwtcl                                   ),
            .cpl_spc_header_hwtcl                          (cpl_spc_header_hwtcl                                    ),
            .cpl_spc_data_hwtcl                            (cpl_spc_data_hwtcl                                      ),
            .port_width_be_hwtcl                           (port_width_be_hwtcl                                     ),
            .port_width_data_hwtcl                         (port_width_data_hwtcl                                   ),
            .reserved_debug_hwtcl                          (reserved_debug_hwtcl                                    ),
            .hip_reconfig_hwtcl                            (hip_reconfig_hwtcl                                      ),
            .vsec_id_hwtcl                                 (vsec_id_hwtcl                                           ),
            .vsec_rev_hwtcl                                (vsec_rev_hwtcl                                          ),
            .gen3_rxfreqlock_counter_hwtcl                 (gen3_rxfreqlock_counter_hwtcl                           ),
            .gen3_skip_ph2_ph3_hwtcl                       (gen3_skip_ph2_ph3_hwtcl                                 ),
            .g3_bypass_equlz_hwtcl                         (g3_bypass_equlz_hwtcl                                   ),
            .enable_tl_only_sim_hwtcl                      (enable_tl_only_sim_hwtcl                                ),
            .use_atx_pll_hwtcl                             (use_atx_pll_hwtcl                                       ),
            .cvp_rate_sel_hwtcl                            (cvp_rate_sel_hwtcl                                      ),
            .cvp_data_compressed_hwtcl                     (cvp_data_compressed_hwtcl                               ),
            .cvp_data_encrypted_hwtcl                      (cvp_data_encrypted_hwtcl                                ),
            .cvp_mode_reset_hwtcl                          (cvp_mode_reset_hwtcl                                    ),
            .cvp_clk_reset_hwtcl                           (cvp_clk_reset_hwtcl                                     ),
            .cseb_cpl_status_during_cvp_hwtcl              (cseb_cpl_status_during_cvp_hwtcl                        ),
            .core_clk_sel_hwtcl                            (core_clk_sel_hwtcl                                      ),
            .disable_link_x2_support_hwtcl                 (disable_link_x2_support_hwtcl                           ),
            .hip_hard_reset_hwtcl                          (hip_hard_reset_hwtcl                                    ),
            .enable_power_on_rst_pulse_hwtcl               (enable_power_on_rst_pulse_hwtcl                         ),
            .enable_pcisigtest_hwtcl                       (enable_pcisigtest_hwtcl                                 ),
            .hip_tag_checking_hwtcl                        (hip_tag_checking_hwtcl                                  ),
            .wrong_device_id_hwtcl                         (wrong_device_id_hwtcl                                   ),
            .data_pack_rx_hwtcl                            (data_pack_rx_hwtcl                                      ),
            .ast_width_hwtcl                               (ast_width_hwtcl                                         ),
            .use_ast_parity                                (use_ast_parity                                          ),
            .ltssm_1ms_timeout_hwtcl                       (ltssm_1ms_timeout_hwtcl                                 ),
            .ltssm_freqlocked_check_hwtcl                  (ltssm_freqlocked_check_hwtcl                            ),
            .deskew_comma_hwtcl                            (deskew_comma_hwtcl                                      ),
            .port_link_number_hwtcl                        (port_link_number_hwtcl                                  ),
            .device_number_hwtcl                           (device_number_hwtcl                                     ),
            .bypass_clk_switch_hwtcl                       (bypass_clk_switch_hwtcl                                 ),
            .pipex1_debug_sel_hwtcl                        (pipex1_debug_sel_hwtcl                                  ),
            .pclk_out_sel_hwtcl                            (pclk_out_sel_hwtcl                                      ),
            .vendor_id_hwtcl                               (vendor_id_hwtcl                                         ),
            .device_id_hwtcl                               (device_id_hwtcl                                         ),
            .revision_id_hwtcl                             (revision_id_hwtcl                                       ),
            .class_code_hwtcl                              (class_code_hwtcl                                        ),
            .subsystem_vendor_id_hwtcl                     (subsystem_vendor_id_hwtcl                               ),
            .subsystem_device_id_hwtcl                     (subsystem_device_id_hwtcl                               ),
            .no_soft_reset_hwtcl                           (no_soft_reset_hwtcl                                     ),
            .maximum_current_hwtcl                         (maximum_current_hwtcl                                   ),
            .d1_support_hwtcl                              (d1_support_hwtcl                                        ),
            .d2_support_hwtcl                              (d2_support_hwtcl                                        ),
            .d0_pme_hwtcl                                  (d0_pme_hwtcl                                            ),
            .d1_pme_hwtcl                                  (d1_pme_hwtcl                                            ),
            .d2_pme_hwtcl                                  (d2_pme_hwtcl                                            ),
            .d3_hot_pme_hwtcl                              (d3_hot_pme_hwtcl                                        ),
            .d3_cold_pme_hwtcl                             (d3_cold_pme_hwtcl                                       ),
            .use_aer_hwtcl                                 (use_aer_hwtcl                                           ),
            .low_priority_vc_hwtcl                         (low_priority_vc_hwtcl                                   ),
            .disable_snoop_packet_hwtcl                    (disable_snoop_packet_hwtcl                              ),
            .max_payload_size_hwtcl                        (max_payload_size_hwtcl                                  ),
            .surprise_down_error_support_hwtcl             (surprise_down_error_support_hwtcl                       ),
            .dll_active_report_support_hwtcl               (dll_active_report_support_hwtcl                         ),
            .extend_tag_field_hwtcl                        (extend_tag_field_hwtcl                                  ),
            .endpoint_l0_latency_hwtcl                     (endpoint_l0_latency_hwtcl                               ),
            .endpoint_l1_latency_hwtcl                     (endpoint_l1_latency_hwtcl                               ),
            .indicator_hwtcl                               (indicator_hwtcl                                         ),
            .slot_power_scale_hwtcl                        (slot_power_scale_hwtcl                                  ),
            .enable_l1_aspm_hwtcl                          (enable_l1_aspm_hwtcl                                    ),
            .l1_exit_latency_sameclock_hwtcl               (l1_exit_latency_sameclock_hwtcl                         ),
            .l1_exit_latency_diffclock_hwtcl               (l1_exit_latency_diffclock_hwtcl                         ),
            .hot_plug_support_hwtcl                        (hot_plug_support_hwtcl                                  ),
            .slot_power_limit_hwtcl                        (slot_power_limit_hwtcl                                  ),
            .slot_number_hwtcl                             (slot_number_hwtcl                                       ),
            .diffclock_nfts_count_hwtcl                    (diffclock_nfts_count_hwtcl                              ),
            .sameclock_nfts_count_hwtcl                    (sameclock_nfts_count_hwtcl                              ),
            .completion_timeout_hwtcl                      (completion_timeout_hwtcl                                ),
            .enable_completion_timeout_disable_hwtcl       (enable_completion_timeout_disable_hwtcl                 ),
            .extended_tag_reset_hwtcl                      (extended_tag_reset_hwtcl                                ),
            .ecrc_check_capable_hwtcl                      (ecrc_check_capable_hwtcl                                ),
            .ecrc_gen_capable_hwtcl                        (ecrc_gen_capable_hwtcl                                  ),
            .no_command_completed_hwtcl                    (no_command_completed_hwtcl                              ),
            .msi_multi_message_capable_hwtcl               (msi_multi_message_capable_hwtcl                         ),
            .msi_64bit_addressing_capable_hwtcl            (msi_64bit_addressing_capable_hwtcl                      ),
            .msi_masking_capable_hwtcl                     (msi_masking_capable_hwtcl                               ),
            .msi_support_hwtcl                             (msi_support_hwtcl                                       ),
            .interrupt_pin_hwtcl                           (interrupt_pin_hwtcl                                     ),
            .enable_function_msix_support_hwtcl            (enable_function_msix_support_hwtcl                      ),
            .msix_table_size_hwtcl                         (msix_table_size_hwtcl                                   ),
            .msix_table_bir_hwtcl                          (msix_table_bir_hwtcl                                    ),
            .msix_table_offset_hwtcl                       (msix_table_offset_hwtcl                                 ),
            .msix_pba_bir_hwtcl                            (msix_pba_bir_hwtcl                                      ),
            .msix_pba_offset_hwtcl                         (msix_pba_offset_hwtcl                                   ),
            .bridge_port_vga_enable_hwtcl                  (bridge_port_vga_enable_hwtcl                            ),
            .bridge_port_ssid_support_hwtcl                (bridge_port_ssid_support_hwtcl                          ),
            .ssvid_hwtcl                                   (ssvid_hwtcl                                             ),
            .ssid_hwtcl                                    (ssid_hwtcl                                              ),
            .eie_before_nfts_count_hwtcl                   (eie_before_nfts_count_hwtcl                             ),
            .gen2_diffclock_nfts_count_hwtcl               (gen2_diffclock_nfts_count_hwtcl                         ),
            .gen2_sameclock_nfts_count_hwtcl               (gen2_sameclock_nfts_count_hwtcl                         ),
            .deemphasis_enable_hwtcl                       (deemphasis_enable_hwtcl                                 ),
            .pcie_spec_version_hwtcl                       (pcie_spec_version_hwtcl                                 ),
            .l0_exit_latency_sameclock_hwtcl               (l0_exit_latency_sameclock_hwtcl                         ),
            .l0_exit_latency_diffclock_hwtcl               (l0_exit_latency_diffclock_hwtcl                         ),
            .rx_ei_l0s_hwtcl                               (rx_ei_l0s_hwtcl                                         ),
            .l2_async_logic_hwtcl                          (l2_async_logic_hwtcl                                    ),
            .aspm_config_management_hwtcl                  (aspm_config_management_hwtcl                            ),
            .atomic_op_routing_hwtcl                       (atomic_op_routing_hwtcl                                 ),
            .atomic_op_completer_32bit_hwtcl               (atomic_op_completer_32bit_hwtcl                         ),
            .atomic_op_completer_64bit_hwtcl               (atomic_op_completer_64bit_hwtcl                         ),
            .cas_completer_128bit_hwtcl                    (cas_completer_128bit_hwtcl                              ),
            .ltr_mechanism_hwtcl                           (ltr_mechanism_hwtcl                                     ),
            .tph_completer_hwtcl                           (tph_completer_hwtcl                                     ),
            .extended_format_field_hwtcl                   (extended_format_field_hwtcl                             ),
            .atomic_malformed_hwtcl                        (atomic_malformed_hwtcl                                  ),
            .flr_capability_hwtcl                          (flr_capability_hwtcl                                    ),
            .enable_adapter_half_rate_mode_hwtcl           (enable_adapter_half_rate_mode_hwtcl                     ),
            .vc0_clk_enable_hwtcl                          (vc0_clk_enable_hwtcl                                    ),
            .register_pipe_signals_hwtcl                   (register_pipe_signals_hwtcl                             ),
            .bar0_io_space_hwtcl                           (bar0_io_space_hwtcl                                     ),
            .bar0_64bit_mem_space_hwtcl                    (bar0_64bit_mem_space_hwtcl                              ),
            .bar0_prefetchable_hwtcl                       (bar0_prefetchable_hwtcl                                 ),
            .bar0_size_mask_hwtcl                          (bar0_size_mask_hwtcl                                    ),
            .bar1_io_space_hwtcl                           (bar1_io_space_hwtcl                                     ),
            .bar1_64bit_mem_space_hwtcl                    (bar1_64bit_mem_space_hwtcl                              ),
            .bar1_prefetchable_hwtcl                       (bar1_prefetchable_hwtcl                                 ),
            .bar1_size_mask_hwtcl                          (bar1_size_mask_hwtcl                                    ),
            .bar2_io_space_hwtcl                           (bar2_io_space_hwtcl                                     ),
            .bar2_64bit_mem_space_hwtcl                    (bar2_64bit_mem_space_hwtcl                              ),
            .bar2_prefetchable_hwtcl                       (bar2_prefetchable_hwtcl                                 ),
            .bar2_size_mask_hwtcl                          (bar2_size_mask_hwtcl                                    ),
            .bar3_io_space_hwtcl                           (bar3_io_space_hwtcl                                     ),
            .bar3_64bit_mem_space_hwtcl                    (bar3_64bit_mem_space_hwtcl                              ),
            .bar3_prefetchable_hwtcl                       (bar3_prefetchable_hwtcl                                 ),
            .bar3_size_mask_hwtcl                          (bar3_size_mask_hwtcl                                    ),
            .bar4_io_space_hwtcl                           (bar4_io_space_hwtcl                                     ),
            .bar4_64bit_mem_space_hwtcl                    (bar4_64bit_mem_space_hwtcl                              ),
            .bar4_prefetchable_hwtcl                       (bar4_prefetchable_hwtcl                                 ),
            .bar4_size_mask_hwtcl                          (bar4_size_mask_hwtcl                                    ),
            .bar5_io_space_hwtcl                           (bar5_io_space_hwtcl                                     ),
            .bar5_64bit_mem_space_hwtcl                    (bar5_64bit_mem_space_hwtcl                              ),
            .bar5_prefetchable_hwtcl                       (bar5_prefetchable_hwtcl                                 ),
            .bar5_size_mask_hwtcl                          (bar5_size_mask_hwtcl                                    ),
            .expansion_base_address_register_hwtcl         (expansion_base_address_register_hwtcl                   ),
            .io_window_addr_width_hwtcl                    (io_window_addr_width_hwtcl                              ),
            .prefetchable_mem_window_addr_width_hwtcl      (prefetchable_mem_window_addr_width_hwtcl                ),
            .skp_os_gen3_count_hwtcl                       (skp_os_gen3_count_hwtcl                                 ),
            .tx_cdc_almost_empty_hwtcl                     (tx_cdc_almost_empty_hwtcl                               ),
            .rx_cdc_almost_full_hwtcl                      (rx_cdc_almost_full_hwtcl                                ),
            .tx_cdc_almost_full_hwtcl                      (tx_cdc_almost_full_hwtcl                                ),
            .rx_l0s_count_idl_hwtcl                        (rx_l0s_count_idl_hwtcl                                  ),
            .cdc_dummy_insert_limit_hwtcl                  (cdc_dummy_insert_limit_hwtcl                            ),
            .ei_delay_powerdown_count_hwtcl                (ei_delay_powerdown_count_hwtcl                          ),
            .millisecond_cycle_count_hwtcl                 (millisecond_cycle_count_hwtcl                           ),
            .skp_os_schedule_count_hwtcl                   (skp_os_schedule_count_hwtcl                             ),
            .fc_init_timer_hwtcl                           (fc_init_timer_hwtcl                                     ),
            .l01_entry_latency_hwtcl                       (l01_entry_latency_hwtcl                                 ),
            .flow_control_update_count_hwtcl               (flow_control_update_count_hwtcl                         ),
            .flow_control_timeout_count_hwtcl              (flow_control_timeout_count_hwtcl                        ),
            .credit_buffer_allocation_aux_hwtcl            (credit_buffer_allocation_aux_hwtcl                      ),
            .vc0_rx_flow_ctrl_posted_header_hwtcl          (vc0_rx_flow_ctrl_posted_header_hwtcl                    ),
            .vc0_rx_flow_ctrl_posted_data_hwtcl            (vc0_rx_flow_ctrl_posted_data_hwtcl                      ),
            .vc0_rx_flow_ctrl_nonposted_header_hwtcl       (vc0_rx_flow_ctrl_nonposted_header_hwtcl                 ),
            .vc0_rx_flow_ctrl_nonposted_data_hwtcl         (vc0_rx_flow_ctrl_nonposted_data_hwtcl                   ),
            .vc0_rx_flow_ctrl_compl_header_hwtcl           (vc0_rx_flow_ctrl_compl_header_hwtcl                     ),
            .vc0_rx_flow_ctrl_compl_data_hwtcl             (vc0_rx_flow_ctrl_compl_data_hwtcl                       ),
            .retry_buffer_last_active_address_hwtcl        (retry_buffer_last_active_address_hwtcl                  ),
            .g3_dis_rx_use_prst_hwtcl                      (g3_dis_rx_use_prst_hwtcl                                ),
            .g3_dis_rx_use_prst_ep_hwtcl                   (g3_dis_rx_use_prst_ep_hwtcl                             ),
            .hwtcl_override_g2_txvod                       (hwtcl_override_g2_txvod                                 ),
            .rpre_emph_a_val_hwtcl                         (rpre_emph_a_val_hwtcl                                   ),
            .rpre_emph_b_val_hwtcl                         (rpre_emph_b_val_hwtcl                                   ),
            .rpre_emph_c_val_hwtcl                         (rpre_emph_c_val_hwtcl                                   ),
            .rpre_emph_d_val_hwtcl                         (rpre_emph_d_val_hwtcl                                   ),
            .rpre_emph_e_val_hwtcl                         (rpre_emph_e_val_hwtcl                                   ),
            .rvod_sel_a_val_hwtcl                          (rvod_sel_a_val_hwtcl                                    ),
            .rvod_sel_b_val_hwtcl                          (rvod_sel_b_val_hwtcl                                    ),
            .rvod_sel_c_val_hwtcl                          (rvod_sel_c_val_hwtcl                                    ),
            .rvod_sel_d_val_hwtcl                          (rvod_sel_d_val_hwtcl                                    ),
            .rvod_sel_e_val_hwtcl                          (rvod_sel_e_val_hwtcl                                    ),
            .tlp_inspector_hwtcl                           (tlp_inspector_hwtcl                                     ),
            .tlp_inspector_use_signal_probe_hwtcl          (tlp_inspector_use_signal_probe_hwtcl                    ),
            .tlp_insp_trg_dw0_hwtcl                        (tlp_insp_trg_dw0_hwtcl                                  ),
            .tlp_insp_trg_dw1_hwtcl                        (tlp_insp_trg_dw1_hwtcl                                  ),
            .tlp_insp_trg_dw2_hwtcl                        (tlp_insp_trg_dw2_hwtcl                                  ),
            .tlp_insp_trg_dw3_hwtcl                        (tlp_insp_trg_dw3_hwtcl                                  ),
            .pcie_inspector_hwtcl                          (pcie_inspector_hwtcl                                    )

     ) altera_s5_a2p (
         // Control signals
         .test_in(test_in),
         .simu_mode_pipe(simu_mode_pipe),          // When 1'b1 indicate running DUT under pipe simulation

         // Reset signals
         .pin_perst         (pin_perst        ),
         .npor              (npor             ),
         .reset_status      (reset_status_int ),
         .serdes_pll_locked (serdes_pll_locked),
         .pld_clk_inuse     (pld_clk_inuse    ),
         .pld_core_ready    (pld_core_ready   ),
         .testin_zero       (      ),

         // Clock
         .pld_clk(pld_clk_hip),

         // Serdes related
         .refclk(refclk),

         // HIP control signals
         .hpg_ctrler(hpg_ctrler),

         // Input PIPE simulation _ext for simulation only
         .sim_pipe_rate(sim_pipe_rate),
         .sim_pipe_pclk_in(sim_pipe_pclk_in),
         .sim_pipe_pclk_out(sim_pipe_pclk_out),
         .sim_pipe_clk250_out(sim_pipe_clk250_out),
         .sim_pipe_clk500_out(sim_pipe_clk500_out),
         .sim_ltssmstate(sim_ltssmstate),
         .phystatus0(phystatus0),
         .phystatus1(phystatus1),
         .phystatus2(phystatus2),
         .phystatus3(phystatus3),
         .phystatus4(phystatus4),
         .phystatus5(phystatus5),
         .phystatus6(phystatus6),
         .phystatus7(phystatus7),
         .rxdata0(rxdata0),
         .rxdata1(rxdata1),
         .rxdata2(rxdata2),
         .rxdata3(rxdata3),
         .rxdata4(rxdata4),
         .rxdata5(rxdata5),
         .rxdata6(rxdata6),
         .rxdata7(rxdata7),
         .rxdatak0(rxdatak0),
         .rxdatak1(rxdatak1),
         .rxdatak2(rxdatak2),
         .rxdatak3(rxdatak3),
         .rxdatak4(rxdatak4),
         .rxdatak5(rxdatak5),
         .rxdatak6(rxdatak6),
         .rxdatak7(rxdatak7),
         .rxelecidle0(rxelecidle0),
         .rxelecidle1(rxelecidle1),
         .rxelecidle2(rxelecidle2),
         .rxelecidle3(rxelecidle3),
         .rxelecidle4(rxelecidle4),
         .rxelecidle5(rxelecidle5),
         .rxelecidle6(rxelecidle6),
         .rxelecidle7(rxelecidle7),
         .rxfreqlocked0(rxfreqlocked0),
         .rxfreqlocked1(rxfreqlocked1),
         .rxfreqlocked2(rxfreqlocked2),
         .rxfreqlocked3(rxfreqlocked3),
         .rxfreqlocked4(rxfreqlocked4),
         .rxfreqlocked5(rxfreqlocked5),
         .rxfreqlocked6(rxfreqlocked6),
         .rxfreqlocked7(rxfreqlocked7),
         .rxstatus0(rxstatus0),
         .rxstatus1(rxstatus1),
         .rxstatus2(rxstatus2),
         .rxstatus3(rxstatus3),
         .rxstatus4(rxstatus4),
         .rxstatus5(rxstatus5),
         .rxstatus6(rxstatus6),
         .rxstatus7(rxstatus7),
         .rxdataskip0(rxdataskip0),
         .rxdataskip1(rxdataskip1),
         .rxdataskip2(rxdataskip2),
         .rxdataskip3(rxdataskip3),
         .rxdataskip4(rxdataskip4),
         .rxdataskip5(rxdataskip5),
         .rxdataskip6(rxdataskip6),
         .rxdataskip7(rxdataskip7),
         .rxblkst0(rxblkst0),
         .rxblkst1(rxblkst1),
         .rxblkst2(rxblkst2),
         .rxblkst3(rxblkst3),
         .rxblkst4(rxblkst4),
         .rxblkst5(rxblkst5),
         .rxblkst6(rxblkst6),
         .rxblkst7(rxblkst7),
         .rxsynchd0(rxsynchd0),
         .rxsynchd1(rxsynchd1),
         .rxsynchd2(rxsynchd2),
         .rxsynchd3(rxsynchd3),
         .rxsynchd4(rxsynchd4),
         .rxsynchd5(rxsynchd5),
         .rxsynchd6(rxsynchd6),
         .rxsynchd7(rxsynchd7),
         .rxvalid0(rxvalid0),
         .rxvalid1(rxvalid1),
         .rxvalid2(rxvalid2),
         .rxvalid3(rxvalid3),
         .rxvalid4(rxvalid4),
         .rxvalid5(rxvalid5),
         .rxvalid6(rxvalid6),
         .rxvalid7(rxvalid7),

         // Application signals inputs
         .aer_msi_num(aer_msi_num),
         .app_int_sts(IntxReq_i),
         .app_msi_num(app_msi_num),
         .app_msi_req(app_msi_req),
         .app_msi_tc(app_msi_tc),
         .pex_msi_num(pex_msi_num),
         .lmi_addr(12'h0),
         .lmi_din(32'h0),
         .lmi_rden(1'b0),
         .lmi_wren(1'b0),
         .pm_auxpwr(1'b0),
         .pm_data(10'h0),
         .pme_to_cr(1'b0),
         .pm_event(1'b0),
         .rx_st_mask(1'b0),
         .rx_st_ready(rx_st_ready),

         .tx_st_data(tx_st_data),

         .tx_st_empty(tx_st_empty),
         .tx_st_eop(tx_st_eop),
         .tx_st_err(1'b0),
         .tx_st_sop(tx_st_sop),
         .tx_st_parity(0),
         .tx_st_valid(tx_st_valid),
         .reconfig_to_xcvr                                               (reconfig_to_xcvr                                           ),
         .reconfig_from_xcvr                                             (reconfig_from_xcvr                                         ),
         .fixedclk_locked                                                (fixedclk_locked                                            ),

         .cpl_err(7'h0),
         .cpl_pending(cpl_pending),

         // Output Pipe interface
         .eidleinfersel0(eidleinfersel0),
         .eidleinfersel1(eidleinfersel1),
         .eidleinfersel2(eidleinfersel2),
         .eidleinfersel3(eidleinfersel3),
         .eidleinfersel4(eidleinfersel4),
         .eidleinfersel5(eidleinfersel5),
         .eidleinfersel6(eidleinfersel6),
         .eidleinfersel7(eidleinfersel7),
         .powerdown0(powerdown0),
         .powerdown1(powerdown1),
         .powerdown2(powerdown2),
         .powerdown3(powerdown3),
         .powerdown4(powerdown4),
         .powerdown5(powerdown5),
         .powerdown6(powerdown6),
         .powerdown7(powerdown7),
         .rxpolarity0(rxpolarity0),
         .rxpolarity1(rxpolarity1),
         .rxpolarity2(rxpolarity2),
         .rxpolarity3(rxpolarity3),
         .rxpolarity4(rxpolarity4),
         .rxpolarity5(rxpolarity5),
         .rxpolarity6(rxpolarity6),
         .rxpolarity7(rxpolarity7),
         .txcompl0(txcompl0),
         .txcompl1(txcompl1),
         .txcompl2(txcompl2),
         .txcompl3(txcompl3),
         .txcompl4(txcompl4),
         .txcompl5(txcompl5),
         .txcompl6(txcompl6),
         .txcompl7(txcompl7),
         .txdata0(txdata0),
         .txdata1(txdata1),
         .txdata2(txdata2),
         .txdata3(txdata3),
         .txdata4(txdata4),
         .txdata5(txdata5),
         .txdata6(txdata6),
         .txdata7(txdata7),
         .txdatak0(txdatak0),
         .txdatak1(txdatak1),
         .txdatak2(txdatak2),
         .txdatak3(txdatak3),
         .txdatak4(txdatak4),
         .txdatak5(txdatak5),
         .txdatak6(txdatak6),
         .txdatak7(txdatak7),
         .txdetectrx0(txdetectrx0),
         .txdetectrx1(txdetectrx1),
         .txdetectrx2(txdetectrx2),
         .txdetectrx3(txdetectrx3),
         .txdetectrx4(txdetectrx4),
         .txdetectrx5(txdetectrx5),
         .txdetectrx6(txdetectrx6),
         .txdetectrx7(txdetectrx7),
         .txelecidle0(txelecidle0),
         .txelecidle1(txelecidle1),
         .txelecidle2(txelecidle2),
         .txelecidle3(txelecidle3),
         .txelecidle4(txelecidle4),
         .txelecidle5(txelecidle5),
         .txelecidle6(txelecidle6),
         .txelecidle7(txelecidle7),
         .txmargin0  (txmargin0  ),
         .txmargin1  (txmargin1  ),
         .txmargin2  (txmargin2  ),
         .txmargin3  (txmargin3  ),
         .txmargin4  (txmargin4  ),
         .txmargin5  (txmargin5  ),
         .txmargin6  (txmargin6  ),
         .txmargin7  (txmargin7  ),
         .txswing0  (txswing0  ),
         .txswing1  (txswing1  ),
         .txswing2  (txswing2  ),
         .txswing3  (txswing3  ),
         .txswing4  (txswing4  ),
         .txswing5  (txswing5  ),
         .txswing6  (txswing6  ),
         .txswing7  (txswing7  ),
         .txdeemph0  (txdeemph0  ),
         .txdeemph1  (txdeemph1  ),
         .txdeemph2  (txdeemph2  ),
         .txdeemph3  (txdeemph3  ),
         .txdeemph4  (txdeemph4  ),
         .txdeemph5  (txdeemph5  ),
         .txdeemph6  (txdeemph6  ),
         .txdeemph7  (txdeemph7  ),
         .txblkst0( txblkst0     ),
         .txblkst1( txblkst1     ),
         .txblkst2( txblkst2     ),
         .txblkst3( txblkst3     ),
         .txblkst4( txblkst4     ),
         .txblkst5( txblkst5     ),
         .txblkst6( txblkst6     ),
         .txblkst7( txblkst7     ),
         .txsynchd0(txsynchd0    ),
         .txsynchd1(txsynchd1    ),
         .txsynchd2(txsynchd2    ),
         .txsynchd3(txsynchd3    ),
         .txsynchd4(txsynchd4    ),
         .txsynchd5(txsynchd5    ),
         .txsynchd6(txsynchd6    ),
         .txsynchd7(txsynchd7    ),
         .currentcoeff0( currentcoeff0 ),
         .currentcoeff1( currentcoeff1 ),
         .currentcoeff2( currentcoeff2 ),
         .currentcoeff3( currentcoeff3 ),
         .currentcoeff4( currentcoeff4 ),
         .currentcoeff5( currentcoeff5 ),
         .currentcoeff6( currentcoeff6 ),
         .currentcoeff7( currentcoeff7 ),
         .currentrxpreset0(currentrxpreset0 ),
         .currentrxpreset1(currentrxpreset1 ),
         .currentrxpreset2(currentrxpreset2 ),
         .currentrxpreset3(currentrxpreset3 ),
         .currentrxpreset4(currentrxpreset4 ),
         .currentrxpreset5(currentrxpreset5 ),
         .currentrxpreset6(currentrxpreset6 ),
         .currentrxpreset7(currentrxpreset7 ),


         // Output HIP Status signals
         .coreclkout_hip(coreclkout_hip),
         .currentspeed(currentspeed),
         .derr_cor_ext_rcv(derr_cor_ext_rcv),
         .derr_cor_ext_rpl(derr_cor_ext_rpl),
         .derr_rpl(derr_rpl),
         .dlup(dlup),
         .dlup_exit(dlup_exit),
         .ev128ns(ev128ns),
         .ev1us(ev1us),
         .hotrst_exit(hotrst_exit),
         .int_status(int_status),
         .l2_exit(l2_exit),
         .lane_act(lane_act),
         .ltssmstate(ltssmstate),

         // Output Application interface
         .serr_out(),
         .app_int_ack(app_int_ack),
         .app_msi_ack(app_msi_ack),
         .lmi_ack(),
         .lmi_dout(),
         .pme_to_sr(),
         .rx_st_bar(rx_st_bar),

         .rx_st_be(rx_st_be),
         .rx_st_parity(rx_st_parity),
         .rx_st_data(rx_st_data),
         .rx_st_sop(rx_st_sop),
         .rx_st_valid(rx_st_valid),
         .rx_st_empty(rx_st_empty),
         .rx_st_eop(rx_st_eop),
         .rx_st_err(rx_st_err),
         .tl_cfg_add(tl_cfg_add),
         .tl_cfg_ctl(tl_cfg_ctl),
         .tl_cfg_sts(tl_cfg_sts),
         .tx_cred_datafccp(tx_cred_datafccp),
         .tx_cred_datafcnp(tx_cred_datafcnp),
         .tx_cred_datafcp(tx_cred_datafcp),
         .tx_cred_fchipcons(tx_cred_fchipcons),
         .tx_cred_fcinfinite(tx_cred_fcinfinite),
         .tx_cred_hdrfccp(tx_cred_hdrfccp),
         .tx_cred_hdrfcnp(tx_cred_hdrfcnp),
         .tx_cred_hdrfcp(tx_cred_hdrfcp),
         .tx_st_ready(tx_st_ready),
         .rx_in0(rx_in0),
         .rx_in1(rx_in1),
         .rx_in2(rx_in2),
         .rx_in3(rx_in3),
         .rx_in4(rx_in4),
         .rx_in5(rx_in5),
         .rx_in6(rx_in6),
         .rx_in7(rx_in7),
         .tx_out0(tx_out0),
         .tx_out1(tx_out1),
         .tx_out2(tx_out2),
         .tx_out3(tx_out3),
         .tx_out4(tx_out4),
         .tx_out5(tx_out5),
         .tx_out6(tx_out6),
         .tx_out7(tx_out7),
         .rx_par_err(rx_par_err),
         .tx_par_err(tx_par_err),
         .cfg_par_err(cfg_par_err),
         .ko_cpl_spc_header(ko_cpl_spc_header),
         .ko_cpl_spc_data(ko_cpl_spc_data),
         .tlbfm_in  (tlbfm_in),
         .tlbfm_out (tlbfm_out),

         .reservedin(reservedin)
   );
end
else if (INTENDED_DEVICE_FAMILY == "Arria V") begin
        altpcie_av_hip_ast_hwtcl #(
                .lane_mask_hwtcl                           (lane_mask_hwtcl),
                .gen12_lane_rate_mode_hwtcl                (gen123_lane_rate_mode_hwtcl),
                .pcie_spec_version_hwtcl                   (pcie_spec_version_hwtcl),
                .ast_width_hwtcl                           (ast_width_hwtcl),
                .pll_refclk_freq_hwtcl                     (pll_refclk_freq_hwtcl),
                .set_pld_clk_x1_625MHz_hwtcl               (set_pld_clk_x1_625MHz_hwtcl),
                .in_cvp_mode_hwtcl                         (in_cvp_mode_hwtcl),
                .num_of_func_hwtcl                         (1),
                .use_crc_forwarding_hwtcl                  (use_crc_forwarding_hwtcl),
                .port_link_number_hwtcl                    (port_link_number_hwtcl),
                .slotclkcfg_hwtcl                          (slotclkcfg_hwtcl),
                .enable_slot_register_hwtcl                (enable_slot_register_hwtcl),
                .porttype_func0_hwtcl                      (port_type_hwtcl),
                .bar0_size_mask_0_hwtcl                    (bar0_size_mask_hwtcl),
                .bar0_io_space_0_hwtcl                     (bar0_io_space_hwtcl),
                .bar0_64bit_mem_space_0_hwtcl              (bar0_64bit_mem_space_hwtcl),
                .bar0_prefetchable_0_hwtcl                 (bar0_prefetchable_hwtcl),
                .bar1_size_mask_0_hwtcl                    (bar1_size_mask_hwtcl),
                .bar1_io_space_0_hwtcl                     (bar1_io_space_hwtcl),
                .bar1_prefetchable_0_hwtcl                 (bar1_prefetchable_hwtcl),
                .bar2_size_mask_0_hwtcl                    (bar2_size_mask_hwtcl),
                .bar2_io_space_0_hwtcl                     (bar2_io_space_hwtcl),
                .bar2_64bit_mem_space_0_hwtcl              (bar2_64bit_mem_space_hwtcl),
                .bar2_prefetchable_0_hwtcl                 (bar2_prefetchable_hwtcl),
                .bar3_size_mask_0_hwtcl                    (bar3_size_mask_hwtcl),
                .bar3_io_space_0_hwtcl                     (bar3_io_space_hwtcl),
                .bar3_prefetchable_0_hwtcl                 (bar3_prefetchable_hwtcl),
                .bar4_size_mask_0_hwtcl                    (bar4_size_mask_hwtcl                       ),
                .bar4_io_space_0_hwtcl                     (bar4_io_space_hwtcl                        ),
                .bar4_64bit_mem_space_0_hwtcl              (bar4_64bit_mem_space_hwtcl                 ),
                .bar4_prefetchable_0_hwtcl                 (bar4_prefetchable_hwtcl                    ),
                .bar5_size_mask_0_hwtcl                    (bar5_size_mask_hwtcl                       ),
                .bar5_io_space_0_hwtcl                     (bar5_io_space_hwtcl                        ),
                .bar5_prefetchable_0_hwtcl                 (bar5_prefetchable_hwtcl                    ),
                .expansion_base_address_register_0_hwtcl   (expansion_base_address_register_hwtcl),
                .io_window_addr_width_hwtcl                (io_window_addr_width_hwtcl),
                .prefetchable_mem_window_addr_width_hwtcl  (prefetchable_mem_window_addr_width_hwtcl),
                .vendor_id_0_hwtcl                         (vendor_id_hwtcl                            ),
                .device_id_0_hwtcl                         (device_id_hwtcl                            ),
                .revision_id_0_hwtcl                       (revision_id_hwtcl                          ),
                .class_code_0_hwtcl                        (class_code_hwtcl                           ),
                .subsystem_vendor_id_0_hwtcl               (subsystem_vendor_id_hwtcl                  ),
                .subsystem_device_id_0_hwtcl               (subsystem_device_id_hwtcl                  ),
                .max_payload_size_0_hwtcl                  (max_payload_size_hwtcl                     ),
                .extend_tag_field_0_hwtcl                  (extend_tag_field_hwtcl                     ),
                .completion_timeout_0_hwtcl                (completion_timeout_hwtcl                   ),
                .enable_completion_timeout_disable_0_hwtcl (enable_completion_timeout_disable_hwtcl    ),
                .flr_capability_0_hwtcl                    (flr_capability_hwtcl                       ),
                .use_aer_0_hwtcl                           (use_aer_hwtcl                              ),
                .ecrc_check_capable_0_hwtcl                (ecrc_check_capable_hwtcl                   ),
                .ecrc_gen_capable_0_hwtcl                  (ecrc_gen_capable_hwtcl                     ),
                .dll_active_report_support_0_hwtcl         (dll_active_report_support_hwtcl            ),
                .surprise_down_error_support_0_hwtcl       (surprise_down_error_support_hwtcl          ),
                .msi_multi_message_capable_0_hwtcl         (msi_multi_message_capable_hwtcl            ),
                .msi_64bit_addressing_capable_0_hwtcl      (msi_64bit_addressing_capable_hwtcl         ),
                .msi_masking_capable_0_hwtcl               (msi_masking_capable_hwtcl                  ),
                .msi_support_0_hwtcl                       (msi_support_hwtcl                          ),
                .enable_function_msix_support_0_hwtcl      (enable_function_msix_support_hwtcl         ),
                .msix_table_size_0_hwtcl                   (msix_table_size_hwtcl                      ),
                .msix_table_offset_0_hwtcl                 (msix_table_offset_hwtcl                    ),
                .msix_table_bir_0_hwtcl                    (msix_table_bir_hwtcl                       ),
                .msix_pba_offset_0_hwtcl                   (msix_pba_offset_hwtcl                      ),
                .msix_pba_bir_0_hwtcl                      (msix_pba_bir_hwtcl                         ),
                .interrupt_pin_0_hwtcl                     (interrupt_pin_hwtcl                        ),
                .slot_power_scale_0_hwtcl                  (slot_power_scale_hwtcl                     ),
                .slot_power_limit_0_hwtcl                  (slot_power_limit_hwtcl                     ),
                .slot_number_0_hwtcl                       (slot_number_hwtcl                          ),
                .rx_ei_l0s_0_hwtcl                         (rx_ei_l0s_hwtcl                            ),
                .endpoint_l0_latency_0_hwtcl               (endpoint_l0_latency_hwtcl                  ),
                .endpoint_l1_latency_0_hwtcl               (endpoint_l1_latency_hwtcl                  ),

                .hip_reconfig_hwtcl                        (hip_reconfig_hwtcl),
                .hip_hard_reset_hwtcl                      (hip_hard_reset_hwtcl),
                .enable_rx_buffer_checking_hwtcl           (enable_rx_buffer_checking_hwtcl),
                .single_rx_detect_hwtcl                    (single_rx_detect_hwtcl),
                .disable_link_x2_support_hwtcl             (disable_link_x2_support_hwtcl),
                .device_number_hwtcl                       (device_number_hwtcl),
                .bypass_clk_switch_hwtcl                   (bypass_clk_switch_hwtcl),
                .pipex1_debug_sel_hwtcl                    (pipex1_debug_sel_hwtcl),
                .pclk_out_sel_hwtcl                        (pclk_out_sel_hwtcl),
                .no_soft_reset_hwtcl                       (no_soft_reset_hwtcl),
                .maximum_current_0_hwtcl                   (maximum_current_hwtcl),
                .d1_support_hwtcl                          (d1_support_hwtcl),
                .d2_support_hwtcl                          (d2_support_hwtcl),
                .d0_pme_hwtcl                              (d0_pme_hwtcl),
                .d1_pme_hwtcl                              (d1_pme_hwtcl                       ),
                .d2_pme_hwtcl                              (d2_pme_hwtcl                       ),
                .d3_hot_pme_hwtcl                          (d3_hot_pme_hwtcl                   ),
                .d3_cold_pme_hwtcl                         (d3_cold_pme_hwtcl                  ),
                .low_priority_vc_hwtcl                     (low_priority_vc_hwtcl              ),
                .disable_snoop_packet_0_hwtcl              (disable_snoop_packet_hwtcl),

                .indicator_hwtcl                           (indicator_hwtcl                                                     ),
                .enable_l1_aspm_hwtcl                      (enable_l1_aspm_hwtcl                                                ),
                .enable_l0s_aspm_hwtcl                     (enable_l0s_aspm_hwtcl                                               ),
                .l1_exit_latency_sameclock_hwtcl           (l1_exit_latency_sameclock_hwtcl                                     ),
                .l1_exit_latency_diffclock_hwtcl           (l1_exit_latency_diffclock_hwtcl                                     ),
                .hot_plug_support_hwtcl                    (hot_plug_support_hwtcl                                              ),
                .diffclock_nfts_count_hwtcl                (diffclock_nfts_count_hwtcl                                          ),
                .sameclock_nfts_count_hwtcl                (sameclock_nfts_count_hwtcl                                          ),
                .no_command_completed_hwtcl                (no_command_completed_hwtcl                                          ),
                .use_tl_cfg_sync_hwtcl                     (use_tl_cfg_sync_hwtcl                                             ),
                .bridge_port_vga_enable_0_hwtcl            (bridge_port_vga_enable_hwtcl                                      ),
                .bridge_port_ssid_support_0_hwtcl          (bridge_port_ssid_support_hwtcl                                    ),
                .ssvid_0_hwtcl                             (ssvid_hwtcl                                                       ),
                .ssid_0_hwtcl                              (ssid_hwtcl                                                        ),
                .eie_before_nfts_count_hwtcl               (eie_before_nfts_count_hwtcl                                         ),
                .gen2_diffclock_nfts_count_hwtcl           (gen2_diffclock_nfts_count_hwtcl                                     ),
                .gen2_sameclock_nfts_count_hwtcl           (gen2_sameclock_nfts_count_hwtcl                                     ),
                .deemphasis_enable_hwtcl                   (deemphasis_enable_hwtcl                                             ),
                .l0_exit_latency_sameclock_hwtcl           (l0_exit_latency_sameclock_hwtcl                                     ),
                .l0_exit_latency_diffclock_hwtcl           (l0_exit_latency_diffclock_hwtcl                                     ),
                .l2_async_logic_hwtcl                      (l2_async_logic_hwtcl                                                ),
                .aspm_optionality_hwtcl                    ("true"                                              ),
                .enable_adapter_half_rate_mode_hwtcl       (enable_adapter_half_rate_mode_hwtcl                                 ),
                .vc0_clk_enable_hwtcl                      (vc0_clk_enable_hwtcl                                                ),
                .register_pipe_signals_hwtcl               (register_pipe_signals_hwtcl                                         ),
                .tx_cdc_almost_empty_hwtcl                 (tx_cdc_almost_empty_hwtcl                                           ),
                .rx_cdc_almost_full_hwtcl                  (rx_cdc_almost_full_hwtcl                                            ),
                .tx_cdc_almost_full_hwtcl                  (tx_cdc_almost_full_hwtcl                                            ),
                .rx_l0s_count_idl_hwtcl                    (rx_l0s_count_idl_hwtcl                                              ),
                .cdc_dummy_insert_limit_hwtcl              (cdc_dummy_insert_limit_hwtcl                                        ),
                .ei_delay_powerdown_count_hwtcl            (ei_delay_powerdown_count_hwtcl                                      ),
                .millisecond_cycle_count_hwtcl             (millisecond_cycle_count_hwtcl                                       ),
                .skp_os_schedule_count_hwtcl               (skp_os_schedule_count_hwtcl                                         ),
                .fc_init_timer_hwtcl                       (fc_init_timer_hwtcl                                                 ),
                .l01_entry_latency_hwtcl                   (l01_entry_latency_hwtcl                                             ),
                .flow_control_update_count_hwtcl           (flow_control_update_count_hwtcl                                     ),
                .flow_control_timeout_count_hwtcl          (flow_control_timeout_count_hwtcl                                    ),
                .credit_buffer_allocation_aux_hwtcl        (credit_buffer_allocation_aux_hwtcl                                  ),
                .vc0_rx_flow_ctrl_posted_header_hwtcl      (vc0_rx_flow_ctrl_posted_header_hwtcl                                ),
                .vc0_rx_flow_ctrl_posted_data_hwtcl        (vc0_rx_flow_ctrl_posted_data_hwtcl                                  ),
                .vc0_rx_flow_ctrl_nonposted_header_hwtcl   (vc0_rx_flow_ctrl_nonposted_header_hwtcl                             ),
                .vc0_rx_flow_ctrl_nonposted_data_hwtcl     (vc0_rx_flow_ctrl_nonposted_data_hwtcl                               ),
                .vc0_rx_flow_ctrl_compl_header_hwtcl       (vc0_rx_flow_ctrl_compl_header_hwtcl                                 ),
                .vc0_rx_flow_ctrl_compl_data_hwtcl         (vc0_rx_flow_ctrl_compl_data_hwtcl                                   ),
                .cpl_spc_header_hwtcl                      (cpl_spc_header_hwtcl                                                ),
                .cpl_spc_data_hwtcl                        (cpl_spc_data_hwtcl                                                  ),
                .retry_buffer_last_active_address_hwtcl    (retry_buffer_last_active_address_hwtcl                              ),
                .port_width_data_hwtcl                     (port_width_data_hwtcl                                               ),
                .reserved_debug_hwtcl                      (reserved_debug_hwtcl                                                ),
                .core_clk_sel_hwtcl                        (core_clk_sel_hwtcl                                                  ),
                .rpre_emph_a_val_hwtcl                     (av_rpre_emph_a_val_hwtcl                                            ),
                .rpre_emph_b_val_hwtcl                     (av_rpre_emph_b_val_hwtcl                                            ),
                .rpre_emph_c_val_hwtcl                     (av_rpre_emph_c_val_hwtcl                                            ),
                .rpre_emph_d_val_hwtcl                     (av_rpre_emph_d_val_hwtcl                                            ),
                .rpre_emph_e_val_hwtcl                     (av_rpre_emph_e_val_hwtcl                                            ),
                .rvod_sel_a_val_hwtcl                      (av_rvod_sel_a_val_hwtcl                                             ),
                .rvod_sel_b_val_hwtcl                      (av_rvod_sel_b_val_hwtcl                                             ),
                .rvod_sel_c_val_hwtcl                      (av_rvod_sel_c_val_hwtcl                                             ),
                .rvod_sel_d_val_hwtcl                      (av_rvod_sel_d_val_hwtcl                                             ),
                .rvod_sel_e_val_hwtcl                      (av_rvod_sel_e_val_hwtcl                                             ),

                .porttype_func1_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_1_hwtcl                    (28),
                .bar0_io_space_1_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_1_hwtcl              ("Enabled"),
                .bar0_prefetchable_1_hwtcl                 ("Enabled"),
                .bar1_size_mask_1_hwtcl                    (0),
                .bar1_io_space_1_hwtcl                     ("Disabled"),
                .bar1_prefetchable_1_hwtcl                 ("Disabled"),
                .bar2_size_mask_1_hwtcl                    (0),
                .bar2_io_space_1_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_1_hwtcl              ("Disabled"),
                .bar2_prefetchable_1_hwtcl                 ("Disabled"),
                .bar3_size_mask_1_hwtcl                    (0),
                .bar3_io_space_1_hwtcl                     ("Disabled"),
                .bar3_prefetchable_1_hwtcl                 ("Disabled"),
                .bar4_size_mask_1_hwtcl                    (0),
                .bar4_io_space_1_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_1_hwtcl              ("Disabled"),
                .bar4_prefetchable_1_hwtcl                 ("Disabled"),
                .bar5_size_mask_1_hwtcl                    (0),
                .bar5_io_space_1_hwtcl                     ("Disabled"),
                .bar5_prefetchable_1_hwtcl                 ("Disabled"),
                .expansion_base_address_register_1_hwtcl   (0),
                .vendor_id_1_hwtcl                         (0),
                .device_id_1_hwtcl                         (1),
                .revision_id_1_hwtcl                       (1),
                .class_code_1_hwtcl                        (0),
                .subsystem_vendor_id_1_hwtcl               (0),
                .subsystem_device_id_1_hwtcl               (0),
                .max_payload_size_1_hwtcl                  (128),
                .extend_tag_field_1_hwtcl                  ("32"),
                .completion_timeout_1_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_1_hwtcl (1),
                .flr_capability_1_hwtcl                    (0),
                .use_aer_1_hwtcl                           (0),
                .ecrc_check_capable_1_hwtcl                (0),
                .ecrc_gen_capable_1_hwtcl                  (0),
                .dll_active_report_support_1_hwtcl         (0),
                .surprise_down_error_support_1_hwtcl       (0),
                .msi_multi_message_capable_1_hwtcl         ("4"),
                .msi_64bit_addressing_capable_1_hwtcl      ("true"),
                .msi_masking_capable_1_hwtcl               ("false"),
                .msi_support_1_hwtcl                       ("true"),
                .enable_function_msix_support_1_hwtcl      (0),
                .msix_table_size_1_hwtcl                   (0),
                .msix_table_offset_1_hwtcl                 (0),
                .msix_table_bir_1_hwtcl                    (0),
                .msix_pba_offset_1_hwtcl                   (0),
                .msix_pba_bir_1_hwtcl                      (0),
                .interrupt_pin_1_hwtcl                     ("inta"),
                .slot_power_scale_1_hwtcl                  (0),
                .slot_power_limit_1_hwtcl                  (0),
                .slot_number_1_hwtcl                       (0),
                .rx_ei_l0s_1_hwtcl                         (0),
                .endpoint_l0_latency_1_hwtcl               (0),
                .endpoint_l1_latency_1_hwtcl               (0),
                .maximum_current_1_hwtcl                   (0),
                .disable_snoop_packet_1_hwtcl              ("false"),
                .bridge_port_vga_enable_1_hwtcl            ("false"),
                .bridge_port_ssid_support_1_hwtcl          ("false"),
                .ssvid_1_hwtcl                             (0),
                .ssid_1_hwtcl                              (0),
                .porttype_func2_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_2_hwtcl                    (28),
                .bar0_io_space_2_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_2_hwtcl              ("Enabled"),
                .bar0_prefetchable_2_hwtcl                 ("Enabled"),
                .bar1_size_mask_2_hwtcl                    (0),
                .bar1_io_space_2_hwtcl                     ("Disabled"),
                .bar1_prefetchable_2_hwtcl                 ("Disabled"),
                .bar2_size_mask_2_hwtcl                    (0),
                .bar2_io_space_2_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_2_hwtcl              ("Disabled"),
                .bar2_prefetchable_2_hwtcl                 ("Disabled"),
                .bar3_size_mask_2_hwtcl                    (0),
                .bar3_io_space_2_hwtcl                     ("Disabled"),
                .bar3_prefetchable_2_hwtcl                 ("Disabled"),
                .bar4_size_mask_2_hwtcl                    (0),
                .bar4_io_space_2_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_2_hwtcl              ("Disabled"),
                .bar4_prefetchable_2_hwtcl                 ("Disabled"),
                .bar5_size_mask_2_hwtcl                    (0),
                .bar5_io_space_2_hwtcl                     ("Disabled"),
                .bar5_prefetchable_2_hwtcl                 ("Disabled"),
                .expansion_base_address_register_2_hwtcl   (0),
                .vendor_id_2_hwtcl                         (0),
                .device_id_2_hwtcl                         (1),
                .revision_id_2_hwtcl                       (1),
                .class_code_2_hwtcl                        (0),
                .subsystem_vendor_id_2_hwtcl               (0),
                .subsystem_device_id_2_hwtcl               (0),
                .max_payload_size_2_hwtcl                  (128),
                .extend_tag_field_2_hwtcl                  ("32"),
                .completion_timeout_2_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_2_hwtcl (1),
                .flr_capability_2_hwtcl                    (0),
                .use_aer_2_hwtcl                           (0),
                .ecrc_check_capable_2_hwtcl                (0),
                .ecrc_gen_capable_2_hwtcl                  (0),
                .dll_active_report_support_2_hwtcl         (0),
                .surprise_down_error_support_2_hwtcl       (0),
                .msi_multi_message_capable_2_hwtcl         ("4"),
                .msi_64bit_addressing_capable_2_hwtcl      ("true"),
                .msi_masking_capable_2_hwtcl               ("false"),
                .msi_support_2_hwtcl                       ("true"),
                .enable_function_msix_support_2_hwtcl      (0),
                .msix_table_size_2_hwtcl                   (0),
                .msix_table_offset_2_hwtcl                 (0),
                .msix_table_bir_2_hwtcl                    (0),
                .msix_pba_offset_2_hwtcl                   (0),
                .msix_pba_bir_2_hwtcl                      (0),
                .interrupt_pin_2_hwtcl                     ("inta"),
                .slot_power_scale_2_hwtcl                  (0),
                .slot_power_limit_2_hwtcl                  (0),
                .slot_number_2_hwtcl                       (0),
                .rx_ei_l0s_2_hwtcl                         (0),
                .endpoint_l0_latency_2_hwtcl               (0),
                .endpoint_l1_latency_2_hwtcl               (0),
                .maximum_current_2_hwtcl                   (0),
                .disable_snoop_packet_2_hwtcl              ("false"),
                .bridge_port_vga_enable_2_hwtcl            ("false"),
                .bridge_port_ssid_support_2_hwtcl          ("false"),
                .ssvid_2_hwtcl                             (0),
                .ssid_2_hwtcl                              (0),
                .porttype_func3_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_3_hwtcl                    (28),
                .bar0_io_space_3_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_3_hwtcl              ("Enabled"),
                .bar0_prefetchable_3_hwtcl                 ("Enabled"),
                .bar1_size_mask_3_hwtcl                    (0),
                .bar1_io_space_3_hwtcl                     ("Disabled"),
                .bar1_prefetchable_3_hwtcl                 ("Disabled"),
                .bar2_size_mask_3_hwtcl                    (0),
                .bar2_io_space_3_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_3_hwtcl              ("Disabled"),
                .bar2_prefetchable_3_hwtcl                 ("Disabled"),
                .bar3_size_mask_3_hwtcl                    (0),
                .bar3_io_space_3_hwtcl                     ("Disabled"),
                .bar3_prefetchable_3_hwtcl                 ("Disabled"),
                .bar4_size_mask_3_hwtcl                    (0),
                .bar4_io_space_3_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_3_hwtcl              ("Disabled"),
                .bar4_prefetchable_3_hwtcl                 ("Disabled"),
                .bar5_size_mask_3_hwtcl                    (0),
                .bar5_io_space_3_hwtcl                     ("Disabled"),
                .bar5_prefetchable_3_hwtcl                 ("Disabled"),
                .expansion_base_address_register_3_hwtcl   (0),
                .vendor_id_3_hwtcl                         (0),
                .device_id_3_hwtcl                         (1),
                .revision_id_3_hwtcl                       (1),
                .class_code_3_hwtcl                        (0),
                .subsystem_vendor_id_3_hwtcl               (0),
                .subsystem_device_id_3_hwtcl               (0),
                .max_payload_size_3_hwtcl                  (128),
                .extend_tag_field_3_hwtcl                  ("32"),
                .completion_timeout_3_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_3_hwtcl (1),
                .flr_capability_3_hwtcl                    (0),
                .use_aer_3_hwtcl                           (0),
                .ecrc_check_capable_3_hwtcl                (0),
                .ecrc_gen_capable_3_hwtcl                  (0),
                .dll_active_report_support_3_hwtcl         (0),
                .surprise_down_error_support_3_hwtcl       (0),
                .msi_multi_message_capable_3_hwtcl         ("4"),
                .msi_64bit_addressing_capable_3_hwtcl      ("true"),
                .msi_masking_capable_3_hwtcl               ("false"),
                .msi_support_3_hwtcl                       ("true"),
                .enable_function_msix_support_3_hwtcl      (0),
                .msix_table_size_3_hwtcl                   (0),
                .msix_table_offset_3_hwtcl                 (0),
                .msix_table_bir_3_hwtcl                    (0),
                .msix_pba_offset_3_hwtcl                   (0),
                .msix_pba_bir_3_hwtcl                      (0),
                .interrupt_pin_3_hwtcl                     ("inta"),
                .slot_power_scale_3_hwtcl                  (0),
                .slot_power_limit_3_hwtcl                  (0),
                .slot_number_3_hwtcl                       (0),
                .rx_ei_l0s_3_hwtcl                         (0),
                .endpoint_l0_latency_3_hwtcl               (0),
                .endpoint_l1_latency_3_hwtcl               (0),
                .maximum_current_3_hwtcl                   (0),
                .disable_snoop_packet_3_hwtcl              ("false"),
                .bridge_port_vga_enable_3_hwtcl            ("false"),
                .bridge_port_ssid_support_3_hwtcl          ("false"),
                .ssvid_3_hwtcl                             (0),
                .ssid_3_hwtcl                              (0),
                .porttype_func4_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_4_hwtcl                    (28),
                .bar0_io_space_4_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_4_hwtcl              ("Enabled"),
                .bar0_prefetchable_4_hwtcl                 ("Enabled"),
                .bar1_size_mask_4_hwtcl                    (0),
                .bar1_io_space_4_hwtcl                     ("Disabled"),
                .bar1_prefetchable_4_hwtcl                 ("Disabled"),
                .bar2_size_mask_4_hwtcl                    (0),
                .bar2_io_space_4_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_4_hwtcl              ("Disabled"),
                .bar2_prefetchable_4_hwtcl                 ("Disabled"),
                .bar3_size_mask_4_hwtcl                    (0),
                .bar3_io_space_4_hwtcl                     ("Disabled"),
                .bar3_prefetchable_4_hwtcl                 ("Disabled"),
                .bar4_size_mask_4_hwtcl                    (0),
                .bar4_io_space_4_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_4_hwtcl              ("Disabled"),
                .bar4_prefetchable_4_hwtcl                 ("Disabled"),
                .bar5_size_mask_4_hwtcl                    (0),
                .bar5_io_space_4_hwtcl                     ("Disabled"),
                .bar5_prefetchable_4_hwtcl                 ("Disabled"),
                .expansion_base_address_register_4_hwtcl   (0),
                .vendor_id_4_hwtcl                         (0),
                .device_id_4_hwtcl                         (1),
                .revision_id_4_hwtcl                       (1),
                .class_code_4_hwtcl                        (0),
                .subsystem_vendor_id_4_hwtcl               (0),
                .subsystem_device_id_4_hwtcl               (0),
                .max_payload_size_4_hwtcl                  (128),
                .extend_tag_field_4_hwtcl                  ("32"),
                .completion_timeout_4_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_4_hwtcl (1),
                .flr_capability_4_hwtcl                    (0),
                .use_aer_4_hwtcl                           (0),
                .ecrc_check_capable_4_hwtcl                (0),
                .ecrc_gen_capable_4_hwtcl                  (0),
                .dll_active_report_support_4_hwtcl         (0),
                .surprise_down_error_support_4_hwtcl       (0),
                .msi_multi_message_capable_4_hwtcl         ("4"),
                .msi_64bit_addressing_capable_4_hwtcl      ("true"),
                .msi_masking_capable_4_hwtcl               ("false"),
                .msi_support_4_hwtcl                       ("true"),
                .enable_function_msix_support_4_hwtcl      (0),
                .msix_table_size_4_hwtcl                   (0),
                .msix_table_offset_4_hwtcl                 (0),
                .msix_table_bir_4_hwtcl                    (0),
                .msix_pba_offset_4_hwtcl                   (0),
                .msix_pba_bir_4_hwtcl                      (0),
                .interrupt_pin_4_hwtcl                     ("inta"),
                .slot_power_scale_4_hwtcl                  (0),
                .slot_power_limit_4_hwtcl                  (0),
                .slot_number_4_hwtcl                       (0),
                .rx_ei_l0s_4_hwtcl                         (0),
                .endpoint_l0_latency_4_hwtcl               (0),
                .endpoint_l1_latency_4_hwtcl               (0),
                .maximum_current_4_hwtcl                   (0),
                .disable_snoop_packet_4_hwtcl              ("false"),
                .bridge_port_vga_enable_4_hwtcl            ("false"),
                .bridge_port_ssid_support_4_hwtcl          ("false"),
                .ssvid_4_hwtcl                             (0),
                .ssid_4_hwtcl                              (0),
                .porttype_func5_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_5_hwtcl                    (28),
                .bar0_io_space_5_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_5_hwtcl              ("Enabled"),
                .bar0_prefetchable_5_hwtcl                 ("Enabled"),
                .bar1_size_mask_5_hwtcl                    (0),
                .bar1_io_space_5_hwtcl                     ("Disabled"),
                .bar1_prefetchable_5_hwtcl                 ("Disabled"),
                .bar2_size_mask_5_hwtcl                    (0),
                .bar2_io_space_5_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_5_hwtcl              ("Disabled"),
                .bar2_prefetchable_5_hwtcl                 ("Disabled"),
                .bar3_size_mask_5_hwtcl                    (0),
                .bar3_io_space_5_hwtcl                     ("Disabled"),
                .bar3_prefetchable_5_hwtcl                 ("Disabled"),
                .bar4_size_mask_5_hwtcl                    (0),
                .bar4_io_space_5_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_5_hwtcl              ("Disabled"),
                .bar4_prefetchable_5_hwtcl                 ("Disabled"),
                .bar5_size_mask_5_hwtcl                    (0),
                .bar5_io_space_5_hwtcl                     ("Disabled"),
                .bar5_prefetchable_5_hwtcl                 ("Disabled"),
                .expansion_base_address_register_5_hwtcl   (0),
                .vendor_id_5_hwtcl                         (0),
                .device_id_5_hwtcl                         (1),
                .revision_id_5_hwtcl                       (1),
                .class_code_5_hwtcl                        (0),
                .subsystem_vendor_id_5_hwtcl               (0),
                .subsystem_device_id_5_hwtcl               (0),
                .max_payload_size_5_hwtcl                  (128),
                .extend_tag_field_5_hwtcl                  ("32"),
                .completion_timeout_5_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_5_hwtcl (1),
                .flr_capability_5_hwtcl                    (0),
                .use_aer_5_hwtcl                           (0),
                .ecrc_check_capable_5_hwtcl                (0),
                .ecrc_gen_capable_5_hwtcl                  (0),
                .dll_active_report_support_5_hwtcl         (0),
                .surprise_down_error_support_5_hwtcl       (0),
                .msi_multi_message_capable_5_hwtcl         ("4"),
                .msi_64bit_addressing_capable_5_hwtcl      ("true"),
                .msi_masking_capable_5_hwtcl               ("false"),
                .msi_support_5_hwtcl                       ("true"),
                .enable_function_msix_support_5_hwtcl      (0),
                .msix_table_size_5_hwtcl                   (0),
                .msix_table_offset_5_hwtcl                 (0),
                .msix_table_bir_5_hwtcl                    (0),
                .msix_pba_offset_5_hwtcl                   (0),
                .msix_pba_bir_5_hwtcl                      (0),
                .interrupt_pin_5_hwtcl                     ("inta"),
                .slot_power_scale_5_hwtcl                  (0),
                .slot_power_limit_5_hwtcl                  (0),
                .slot_number_5_hwtcl                       (0),
                .rx_ei_l0s_5_hwtcl                         (0),
                .endpoint_l0_latency_5_hwtcl               (0),
                .endpoint_l1_latency_5_hwtcl               (0),
                .maximum_current_5_hwtcl                   (0),
                .disable_snoop_packet_5_hwtcl              ("false"),
                .bridge_port_vga_enable_5_hwtcl            ("false"),
                .bridge_port_ssid_support_5_hwtcl          ("false"),
                .ssvid_5_hwtcl                             (0),
                .ssid_5_hwtcl                              (0),
                .porttype_func6_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_6_hwtcl                    (28),
                .bar0_io_space_6_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_6_hwtcl              ("Enabled"),
                .bar0_prefetchable_6_hwtcl                 ("Enabled"),
                .bar1_size_mask_6_hwtcl                    (0),
                .bar1_io_space_6_hwtcl                     ("Disabled"),
                .bar1_prefetchable_6_hwtcl                 ("Disabled"),
                .bar2_size_mask_6_hwtcl                    (0),
                .bar2_io_space_6_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_6_hwtcl              ("Disabled"),
                .bar2_prefetchable_6_hwtcl                 ("Disabled"),
                .bar3_size_mask_6_hwtcl                    (0),
                .bar3_io_space_6_hwtcl                     ("Disabled"),
                .bar3_prefetchable_6_hwtcl                 ("Disabled"),
                .bar4_size_mask_6_hwtcl                    (0),
                .bar4_io_space_6_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_6_hwtcl              ("Disabled"),
                .bar4_prefetchable_6_hwtcl                 ("Disabled"),
                .bar5_size_mask_6_hwtcl                    (0),
                .bar5_io_space_6_hwtcl                     ("Disabled"),
                .bar5_prefetchable_6_hwtcl                 ("Disabled"),
                .expansion_base_address_register_6_hwtcl   (0),
                .vendor_id_6_hwtcl                         (0),
                .device_id_6_hwtcl                         (1),
                .revision_id_6_hwtcl                       (1),
                .class_code_6_hwtcl                        (0),
                .subsystem_vendor_id_6_hwtcl               (0),
                .subsystem_device_id_6_hwtcl               (0),
                .max_payload_size_6_hwtcl                  (128),
                .extend_tag_field_6_hwtcl                  ("32"),
                .completion_timeout_6_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_6_hwtcl (1),
                .flr_capability_6_hwtcl                    (0),
                .use_aer_6_hwtcl                           (0),
                .ecrc_check_capable_6_hwtcl                (0),
                .ecrc_gen_capable_6_hwtcl                  (0),
                .dll_active_report_support_6_hwtcl         (0),
                .surprise_down_error_support_6_hwtcl       (0),
                .msi_multi_message_capable_6_hwtcl         ("4"),
                .msi_64bit_addressing_capable_6_hwtcl      ("true"),
                .msi_masking_capable_6_hwtcl               ("false"),
                .msi_support_6_hwtcl                       ("true"),
                .enable_function_msix_support_6_hwtcl      (0),
                .msix_table_size_6_hwtcl                   (0),
                .msix_table_offset_6_hwtcl                 (0),
                .msix_table_bir_6_hwtcl                    (0),
                .msix_pba_offset_6_hwtcl                   (0),
                .msix_pba_bir_6_hwtcl                      (0),
                .interrupt_pin_6_hwtcl                     ("inta"),
                .slot_power_scale_6_hwtcl                  (0),
                .slot_power_limit_6_hwtcl                  (0),
                .slot_number_6_hwtcl                       (0),
                .rx_ei_l0s_6_hwtcl                         (0),
                .endpoint_l0_latency_6_hwtcl               (0),
                .endpoint_l1_latency_6_hwtcl               (0),
                .maximum_current_6_hwtcl                   (0),
                .disable_snoop_packet_6_hwtcl              ("false"),
                .bridge_port_vga_enable_6_hwtcl            ("false"),
                .bridge_port_ssid_support_6_hwtcl          ("false"),
                .ssvid_6_hwtcl                             (0),
                .ssid_6_hwtcl                              (0),
                .porttype_func7_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_7_hwtcl                    (28),
                .bar0_io_space_7_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_7_hwtcl              ("Enabled"),
                .bar0_prefetchable_7_hwtcl                 ("Enabled"),
                .bar1_size_mask_7_hwtcl                    (0),
                .bar1_io_space_7_hwtcl                     ("Disabled"),
                .bar1_prefetchable_7_hwtcl                 ("Disabled"),
                .bar2_size_mask_7_hwtcl                    (0),
                .bar2_io_space_7_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_7_hwtcl              ("Disabled"),
                .bar2_prefetchable_7_hwtcl                 ("Disabled"),
                .bar3_size_mask_7_hwtcl                    (0),
                .bar3_io_space_7_hwtcl                     ("Disabled"),
                .bar3_prefetchable_7_hwtcl                 ("Disabled"),
                .bar4_size_mask_7_hwtcl                    (0),
                .bar4_io_space_7_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_7_hwtcl              ("Disabled"),
                .bar4_prefetchable_7_hwtcl                 ("Disabled"),
                .bar5_size_mask_7_hwtcl                    (0),
                .bar5_io_space_7_hwtcl                     ("Disabled"),
                .bar5_prefetchable_7_hwtcl                 ("Disabled"),
                .expansion_base_address_register_7_hwtcl   (0),
                .vendor_id_7_hwtcl                         (0),
                .device_id_7_hwtcl                         (1),
                .revision_id_7_hwtcl                       (1),
                .class_code_7_hwtcl                        (0),
                .subsystem_vendor_id_7_hwtcl               (0),
                .subsystem_device_id_7_hwtcl               (0),
                .max_payload_size_7_hwtcl                  (128),
                .extend_tag_field_7_hwtcl                  ("32"),
                .completion_timeout_7_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_7_hwtcl (1),
                .flr_capability_7_hwtcl                    (0),
                .use_aer_7_hwtcl                           (0),
                .ecrc_check_capable_7_hwtcl                (0),
                .ecrc_gen_capable_7_hwtcl                  (0),
                .dll_active_report_support_7_hwtcl         (0),
                .surprise_down_error_support_7_hwtcl       (0),
                .msi_multi_message_capable_7_hwtcl         ("4"),
                .msi_64bit_addressing_capable_7_hwtcl      ("true"),
                .msi_masking_capable_7_hwtcl               ("false"),
                .msi_support_7_hwtcl                       ("true"),
                .enable_function_msix_support_7_hwtcl      (0),
                .msix_table_size_7_hwtcl                   (0),
                .msix_table_offset_7_hwtcl                 (0),
                .msix_table_bir_7_hwtcl                    (0),
                .msix_pba_offset_7_hwtcl                   (0),
                .msix_pba_bir_7_hwtcl                      (0),
                .interrupt_pin_7_hwtcl                     ("inta"),
                .slot_power_scale_7_hwtcl                  (0),
                .slot_power_limit_7_hwtcl                  (0),
                .slot_number_7_hwtcl                       (0),
                .rx_ei_l0s_7_hwtcl                         (0),
                .endpoint_l0_latency_7_hwtcl               (0),
                .endpoint_l1_latency_7_hwtcl               (0),
                .maximum_current_7_hwtcl                   (0),
                .disable_snoop_packet_7_hwtcl              ("false"),
                .bridge_port_vga_enable_7_hwtcl            ("false"),
                .bridge_port_ssid_support_7_hwtcl          ("false"),
                .ssvid_7_hwtcl                             (0),
                .ssid_7_hwtcl                              (0),
                .reconfig_to_xcvr_width                    (reconfig_to_xcvr_width),
                .reconfig_from_xcvr_width                  (reconfig_from_xcvr_width)

        ) a5_hip_ast (
                .npor                    (npor),                 //               npor.npor
                .pin_perst               (pin_perst),            //                   .pin_perst
                .test_in                 (test_in),          //           hip_ctrl.test_in
                .simu_mode_pipe          (simu_mode_pipe),   //                   .simu_mode_pipe
                .pld_clk                 (pld_clk_hip),                        //            pld_clk.clk
                .coreclkout              (coreclkout_hip),                      //     coreclkout_hip.clk
                .refclk                  (refclk),                //             refclk.clk
                .rx_in0                  (rx_in0),         //         hip_serial.rx_in0
                .tx_out0                 (tx_out0),        //                   .tx_out0
                .rx_st_valid             (rx_st_valid),                             //              rx_st.valid
                .rx_st_sop               (rx_st_sop),                     //                   .startofpacket
                .rx_st_eop               (rx_st_eop),                       //                   .endofpacket
                .rx_st_ready             (rx_st_ready),                             //                   .ready
                .rx_st_err               (rx_st_err),                             //                   .error
                .rx_st_data              (rx_st_data),                              //                   .data
                .rx_st_bar               (rx_st_bar),                     //          rx_bar_be.rx_st_bar
                .rx_st_be                (rx_st_be),                      //                   .rx_st_be
                .rx_st_mask              (rx_st_mask),                   //                   .rx_st_mask
                .tx_st_valid             (tx_st_valid),                            //              tx_st.valid
                .tx_st_sop               (tx_st_sop),                    //                   .startofpacket
                .tx_st_eop               (tx_st_eop),                      //                   .endofpacket
                .tx_st_ready             (tx_st_ready),                            //                   .ready
                .tx_st_err               (1'b0),                            //                   .error
                .tx_st_data             (tx_st_data),                             //                   .data
                .tx_cred_datafccp        (tx_cred_datafccp),                //            tx_cred.tx_cred_datafccp
                .tx_cred_datafcnp        (tx_cred_datafcnp),                //                   .tx_cred_datafcnp
                .tx_cred_datafcp         (tx_cred_datafcp),                 //                   .tx_cred_datafcp
                .tx_cred_fchipcons       (tx_cred_fchipcons),               //                   .tx_cred_fchipcons
                .tx_cred_fcinfinite      (tx_cred_fcinfinite),              //                   .tx_cred_fcinfinite
                .tx_cred_hdrfccp         (tx_cred_hdrfccp),                 //                   .tx_cred_hdrfccp
                .tx_cred_hdrfcnp         (tx_cred_hdrfcnp),                 //                   .tx_cred_hdrfcnp
                .tx_cred_hdrfcp          (tx_cred_hdrfcp),                  //                   .tx_cred_hdrfcp

                .sim_pipe_pclk_in        (sim_pipe_pclk_in), //           hip_pipe.sim_pipe_pclk_in
                .sim_pipe_rate           (sim_pipe_rate),    //                   .sim_pipe_rate
                .sim_ltssmstate          (sim_ltssmstate),   //                   .sim_ltssmstate
                .eidleinfersel0          (eidleinfersel0),   //                   .eidleinfersel0
                .powerdown0              (powerdown0),       //                   .powerdown0
                .rxpolarity0             (rxpolarity0),      //                   .rxpolarity0
                .txcompl0                (txcompl0),         //                   .txcompl0
                .txdata0                 (txdata0),          //                   .txdata0
                .txdatak0                (txdatak0),         //                   .txdatak0
                .txdetectrx0             (txdetectrx0),      //                   .txdetectrx0
                .txelecidle0             (txelecidle0),      //                   .txelecidle0
                .txdeemph0               (txdeemph0),        //                   .txdeemph0
                .phystatus0              (phystatus0),       //                   .phystatus0
                .rxdata0                 (rxdata0),          //                   .rxdata0
                .rxdatak0                (rxdatak0),         //                   .rxdatak0
                .rxelecidle0             (rxelecidle0),      //                   .rxelecidle0
                .rxstatus0               (rxstatus0),        //                   .rxstatus0
                .rxvalid0                (rxvalid0),         //                   .rxvalid0
                .reset_status            (reset_status_int),                    //            hip_rst.reset_status
                .serdes_pll_locked       (serdes_pll_locked),               //                   .serdes_pll_locked
                .pld_clk_inuse           (pld_clk_inuse),                   //                   .pld_clk_inuse
                .pld_core_ready          (pld_core_ready),                 //                   .pld_core_ready
                .testin_zero             (),                     //                   .testin_zero
                .lmi_addr                (12'h0),                           //                lmi.lmi_addr
                .lmi_din                 (32'h0),                            //                   .lmi_din
                .lmi_rden                (1'b0),                           //                   .lmi_rden
                .lmi_wren                (1'b0),                           //                   .lmi_wren
                .lmi_ack                 (),                             //                   .lmi_ack
                .lmi_dout                (),                            //                   .lmi_dout
                .pm_auxpwr               (1'b0),                   //         power_mngt.pm_auxpwr
                .pm_data                 (10'h0),                     //                   .pm_data
                .pme_to_cr               (1'b0),                   //                   .pme_to_cr
                .pm_event                (1'b0),                    //                   .pm_event
                .pme_to_sr               (pme_to_sr),                    //                   .pme_to_sr
                //.busy_xcvr_reconfig      (busy_xcvr_reconfig),    //   reconfig_to_xcvr.busy_xcvr_reconfig
                .fixedclk_locked         (fixedclk_locked),      // reconfig_from_xcvr.fixedclk_locked
                .reconfig_from_xcvr      (reconfig_from_xcvr),
                .reconfig_to_xcvr        (reconfig_to_xcvr),
                .app_int_sts_vec      (app_int_sts_internal),                    //            int_msi.app_int_sts
                //.app_inta_ack         (app_int_ack),                     //                   .app_int_ack
                .app_msi_num          (app_msi_num),                    //                   .app_msi_num
                .app_msi_req          (app_msi_req),                    //                   .app_msi_req
                .app_msi_tc           (app_msi_tc),                     //                   .app_msi_tc
                .app_msi_ack          (app_msi_ack),                     //                   .app_msi_ack
                .serr_out                (serr_out),                        //                   .serr_out
                .tl_hpg_ctrl_er          (hpg_ctrler),                   //          config_tl.hpg_ctrler
                .tl_cfg_ctl              (tl_cfg_ctl),                    //                   .tl_cfg_ctl
                .cpl_err                 (7'h0),                      //                   .cpl_err
                .tl_cfg_add              (tl_cfg_add),                    //                   .tl_cfg_add
                .tl_cfg_sts              (tl_cfg_sts),                    //                   .tl_cfg_sts
                .cpl_pending             (cpl_pending),                  //                   .cpl_pending
                .dl_current_speed        (currentspeed),                 //         hip_status.currentspeed
                .derr_cor_ext_rcv0       (derr_cor_ext_rcv),             //                   .derr_cor_ext_rcv
                .derr_cor_ext_rpl        (derr_cor_ext_rpl),             //                   .derr_cor_ext_rpl
                .derr_rpl                (derr_rpl),                     //                   .derr_rpl
                .dlup_exit               (dlup_exit),                    //                   .dlup_exit
                .dl_ltssm                (ltssmstate),                   //                   .ltssmstate
                .ev128ns                 (ev128ns),                      //                   .ev128ns
                .ev1us                   (ev1us),                        //                   .ev1us
                .hotrst_exit             (hotrst_exit),                  //                   .hotrst_exit
                .int_status              (int_status),                   //                   .int_status
                .l2_exit                 (l2_exit),                      //                   .l2_exit
                .lane_act                (lane_act),                     //                   .lane_act
                .ko_cpl_spc_header       (ko_cpl_spc_header),            //                   .ko_cpl_spc_header
                .ko_cpl_spc_data         (ko_cpl_spc_data),              //                   .ko_cpl_spc_data
                .rx_in1                  (rx_in1            ),                                        //        (terminated)
                .rx_in2                  (rx_in2            ),                                        //        (terminated)
                .rx_in3                  (rx_in3            ),                                        //        (terminated)
                .rx_in4                  (rx_in4            ),                                        //        (terminated)
                .rx_in5                  (rx_in5            ),                                        //        (terminated)
                .rx_in6                  (rx_in6            ),                                        //        (terminated)
                .rx_in7                  (rx_in7            ),                                        //        (terminated)
                .tx_out1                 (tx_out1),                                            //        (terminated)
                .tx_out2                 (tx_out2),                                            //        (terminated)
                .tx_out3                 (tx_out3),                                            //        (terminated)
                .tx_out4                 (tx_out4),                                            //        (terminated)
                .tx_out5                 (tx_out5),                                            //        (terminated)
                .tx_out6                 (tx_out6),                                            //        (terminated)
                .tx_out7                 (tx_out7),                                            //        (terminated)
                .rx_st_empty         (rx_st_empty),                                            //        (terminated)
                .rx_bar_dec_func_num (),                                            //        (terminated)
                .tx_st_empty             (tx_st_empty),                                       //        (terminated)
                .eidleinfersel1          (eidleinfersel1                    ),                                            //        (terminated)
                .eidleinfersel2          (eidleinfersel2                    ),                                            //        (terminated)
                .eidleinfersel3          (eidleinfersel3                    ),                                            //        (terminated)
                .eidleinfersel4          (eidleinfersel4                    ),                                            //        (terminated)
                .eidleinfersel5          (eidleinfersel5                    ),                                            //        (terminated)
                .eidleinfersel6          (eidleinfersel6                    ),                                            //        (terminated)
                .eidleinfersel7          (eidleinfersel7                    ),                                            //        (terminated)
                .powerdown1              (powerdown1                   ),                                            //        (terminated)
                .powerdown2              (powerdown2                   ),                                            //        (terminated)
                .powerdown3              (powerdown3                   ),                                            //        (terminated)
                .powerdown4              (powerdown4                   ),                                            //        (terminated)
                .powerdown5              (powerdown5                   ),                                            //        (terminated)
                .powerdown6              (powerdown6                   ),                                            //        (terminated)
                .powerdown7              (powerdown7                   ),                                            //        (terminated)
                .rxpolarity1             (rxpolarity1                  ),                                            //        (terminated)
                .rxpolarity2             (rxpolarity2                  ),                                            //        (terminated)
                .rxpolarity3             (rxpolarity3                  ),                                            //        (terminated)
                .rxpolarity4             (rxpolarity4                  ),                                            //        (terminated)
                .rxpolarity5             (rxpolarity5                  ),                                            //        (terminated)
                .rxpolarity6             (rxpolarity6                  ),                                            //        (terminated)
                .rxpolarity7             (rxpolarity7                  ),                                            //        (terminated)
                .txcompl1                (txcompl1                     ),                                            //        (terminated)
                .txcompl2                (txcompl2                     ),                                            //        (terminated)
                .txcompl3                (txcompl3                     ),                                            //        (terminated)
                .txcompl4                (txcompl4                     ),                                            //        (terminated)
                .txcompl5                (txcompl5                     ),                                            //        (terminated)
                .txcompl6                (txcompl6                     ),                                            //        (terminated)
                .txcompl7                (txcompl7                     ),                                            //        (terminated)
                .txdata1                 (txdata1                      ),                                            //        (terminated)
                .txdata2                 (txdata2                      ),                                            //        (terminated)
                .txdata3                 (txdata3                      ),                                            //        (terminated)
                .txdata4                 (txdata4                      ),                                            //        (terminated)
                .txdata5                 (txdata5                      ),                                            //        (terminated)
                .txdata6                 (txdata6                      ),                                            //        (terminated)
                .txdata7                 (txdata7                      ),                                            //        (terminated)
                .txdatak1                (txdatak1                     ),                                            //        (terminated)
                .txdatak2                (txdatak2                     ),                                            //        (terminated)
                .txdatak3                (txdatak3                     ),                                            //        (terminated)
                .txdatak4                (txdatak4                     ),                                            //        (terminated)
                .txdatak5                (txdatak5                     ),                                            //        (terminated)
                .txdatak6                (txdatak6                     ),                                            //        (terminated)
                .txdatak7                (txdatak7                     ),                                            //        (terminated)
                .txdetectrx1             (txdetectrx1                  ),                                            //        (terminated)
                .txdetectrx2             (txdetectrx2                  ),                                            //        (terminated)
                .txdetectrx3             (txdetectrx3                  ),                                            //        (terminated)
                .txdetectrx4             (txdetectrx4                  ),                                            //        (terminated)
                .txdetectrx5             (txdetectrx5                  ),                                            //        (terminated)
                .txdetectrx6             (txdetectrx6                  ),                                            //        (terminated)
                .txdetectrx7             (txdetectrx7                  ),                                            //        (terminated)
                .txelecidle1             (txelecidle1                  ),                                            //        (terminated)
                .txelecidle2             (txelecidle2                  ),                                            //        (terminated)
                .txelecidle3             (txelecidle3                  ),                                            //        (terminated)
                .txelecidle4             (txelecidle4                  ),                                            //        (terminated)
                .txelecidle5             (txelecidle5                  ),                                            //        (terminated)
                .txelecidle6             (txelecidle6                  ),                                            //        (terminated)
                .txelecidle7             (txelecidle7                  ),                                            //        (terminated)
                .txdeemph1               (txdeemph1                    ),                                            //        (terminated)
                .txdeemph2               (txdeemph2                    ),                                            //        (terminated)
                .txdeemph3               (txdeemph3                    ),                                            //        (terminated)
                .txdeemph4               (txdeemph4                    ),                                            //        (terminated)
                .txdeemph5               (txdeemph5                    ),                                            //        (terminated)
                .txdeemph6               (txdeemph6                    ),                                            //        (terminated)
                .txdeemph7               (txdeemph7                    ),                                            //        (terminated)
                .phystatus1              (phystatus1                      ),                                        //        (terminated)
                .phystatus2              (phystatus2                      ),                                        //        (terminated)
                .phystatus3              (phystatus3                      ),                                        //        (terminated)
                .phystatus4              (phystatus4                      ),                                        //        (terminated)
                .phystatus5              (phystatus5                      ),                                        //        (terminated)
                .phystatus6              (phystatus6                      ),                                        //        (terminated)
                .phystatus7              (phystatus7                      ),                                        //        (terminated)
                .rxdata1                 (rxdata1                        ),                                 //        (terminated)
                .rxdata2                 (rxdata2                        ),                                 //        (terminated)
                .rxdata3                 (rxdata3                        ),                                 //        (terminated)
                .rxdata4                 (rxdata4                        ),                                 //        (terminated)
                .rxdata5                 (rxdata5                        ),                                 //        (terminated)
                .rxdata6                 (rxdata6                        ),                                 //        (terminated)
                .rxdata7                 (rxdata7                        ),                                 //        (terminated)
                .rxdatak1                (rxdatak1                        ),                                        //        (terminated)
                .rxdatak2                (rxdatak2                        ),                                        //        (terminated)
                .rxdatak3                (rxdatak3                        ),                                        //        (terminated)
                .rxdatak4                (rxdatak4                        ),                                        //        (terminated)
                .rxdatak5                (rxdatak5                        ),                                        //        (terminated)
                .rxdatak6                (rxdatak6                        ),                                        //        (terminated)
                .rxdatak7                (rxdatak7                        ),                                        //        (terminated)
                .rxelecidle1             (rxelecidle1                     ),                                        //        (terminated)
                .rxelecidle2             (rxelecidle2                     ),                                        //        (terminated)
                .rxelecidle3             (rxelecidle3                     ),                                        //        (terminated)
                .rxelecidle4             (rxelecidle4                     ),                                        //        (terminated)
                .rxelecidle5             (rxelecidle5                     ),                                        //        (terminated)
                .rxelecidle6             (rxelecidle6                     ),                                        //        (terminated)
                .rxelecidle7             (rxelecidle7                     ),                                        //        (terminated)
                .rxstatus1               (rxstatus1                        ),                                      //        (terminated)
                .rxstatus2               (rxstatus2                        ),                                      //        (terminated)
                .rxstatus3               (rxstatus3                        ),                                      //        (terminated)
                .rxstatus4               (rxstatus4                        ),                                      //        (terminated)
                .rxstatus5               (rxstatus5                        ),                                      //        (terminated)
                .rxstatus6               (rxstatus6                        ),                                      //        (terminated)
                .rxstatus7               (rxstatus7                        ),                                      //        (terminated)
                .rxvalid1                (rxvalid1                         ),                                        //        (terminated)
                .rxvalid2                (rxvalid2                         ),                                        //        (terminated)
                .rxvalid3                (rxvalid3                         ),                                        //        (terminated)
                .rxvalid4                (rxvalid4                         ),                                        //        (terminated)
                .rxvalid5                (rxvalid5                         ),                                        //        (terminated)
                .rxvalid6                (rxvalid6                         ),                                        //        (terminated)
                .rxvalid7                (rxvalid7                         ),                                        //        (terminated)
                .txmargin0               (txmargin0                        ),                                            //        (terminated)
                .txmargin1               (txmargin1                        ),                                            //        (terminated)
                .txmargin2               (txmargin2                        ),                                            //        (terminated)
                .txmargin3               (txmargin3                        ),                                            //        (terminated)
                .txmargin4               (txmargin4                        ),                                            //        (terminated)
                .txmargin5               (txmargin5                        ),                                            //        (terminated)
                .txmargin6               (txmargin6                        ),                                            //        (terminated)
                .txmargin7               (txmargin7                        ),                                            //        (terminated)

                .sim_pipe_pclk_out       (sim_pipe_pclk_out),                                            //        (terminated)
                .pm_event_func           (3'b000),                                      //        (terminated)
                .app_msi_func         (3'b000),                                      //        (terminated)
                .aer_msi_num          (5'b00000),                                    //        (terminated)
                .pex_msi_num          (5'b00000),                                    //        (terminated)
                .cpl_err_func            (3'b000),                                      //        (terminated)
                .tl_cfg_ctl_wr           (),                                            //        (terminated)
                .tl_cfg_sts_wr           ()                                            //        (terminated)
        //      .derr_cor_ext_rcv1       ()                                             //        (terminated)
        );
end
else if (INTENDED_DEVICE_FAMILY == "Cyclone V") begin
   altpcie_cv_hip_ast_hwtcl #(
                .lane_mask_hwtcl                           (lane_mask_hwtcl),
                .gen12_lane_rate_mode_hwtcl                (gen123_lane_rate_mode_hwtcl),
                .pcie_spec_version_hwtcl                   (pcie_spec_version_hwtcl),
                .ast_width_hwtcl                           (ast_width_hwtcl),
                .pll_refclk_freq_hwtcl                     (pll_refclk_freq_hwtcl),
                .set_pld_clk_x1_625MHz_hwtcl               (set_pld_clk_x1_625MHz_hwtcl),
                .in_cvp_mode_hwtcl                         (in_cvp_mode_hwtcl),
                .num_of_func_hwtcl                         (1),
                .use_crc_forwarding_hwtcl                  (use_crc_forwarding_hwtcl),
                .port_link_number_hwtcl                    (port_link_number_hwtcl),
                .slotclkcfg_hwtcl                          (slotclkcfg_hwtcl),
                .enable_slot_register_hwtcl                (enable_slot_register_hwtcl),
                .porttype_func0_hwtcl                      (port_type_hwtcl),
                .bar0_size_mask_0_hwtcl                    (bar0_size_mask_hwtcl),
                .bar0_io_space_0_hwtcl                     (bar0_io_space_hwtcl),
                .bar0_64bit_mem_space_0_hwtcl              (bar0_64bit_mem_space_hwtcl),
                .bar0_prefetchable_0_hwtcl                 (bar0_prefetchable_hwtcl),
                .bar1_size_mask_0_hwtcl                    (bar1_size_mask_hwtcl),
                .bar1_io_space_0_hwtcl                     (bar1_io_space_hwtcl),
                .bar1_prefetchable_0_hwtcl                 (bar1_prefetchable_hwtcl),
                .bar2_size_mask_0_hwtcl                    (bar2_size_mask_hwtcl),
                .bar2_io_space_0_hwtcl                     (bar2_io_space_hwtcl),
                .bar2_64bit_mem_space_0_hwtcl              (bar2_64bit_mem_space_hwtcl),
                .bar2_prefetchable_0_hwtcl                 (bar2_prefetchable_hwtcl),
                .bar3_size_mask_0_hwtcl                    (bar3_size_mask_hwtcl),
                .bar3_io_space_0_hwtcl                     (bar3_io_space_hwtcl),
                .bar3_prefetchable_0_hwtcl                 (bar3_prefetchable_hwtcl),
                .bar4_size_mask_0_hwtcl                    (bar4_size_mask_hwtcl                       ),
                .bar4_io_space_0_hwtcl                     (bar4_io_space_hwtcl                        ),
                .bar4_64bit_mem_space_0_hwtcl              (bar4_64bit_mem_space_hwtcl                 ),
                .bar4_prefetchable_0_hwtcl                 (bar4_prefetchable_hwtcl                    ),
                .bar5_size_mask_0_hwtcl                    (bar5_size_mask_hwtcl                       ),
                .bar5_io_space_0_hwtcl                     (bar5_io_space_hwtcl                        ),
                .bar5_prefetchable_0_hwtcl                 (bar5_prefetchable_hwtcl                    ),
                .expansion_base_address_register_0_hwtcl   (expansion_base_address_register_hwtcl),
                .io_window_addr_width_hwtcl                (io_window_addr_width_hwtcl),
                .prefetchable_mem_window_addr_width_hwtcl  (prefetchable_mem_window_addr_width_hwtcl),
                .vendor_id_0_hwtcl                         (vendor_id_hwtcl                            ),
                .device_id_0_hwtcl                         (device_id_hwtcl                            ),
                .revision_id_0_hwtcl                       (revision_id_hwtcl                          ),
                .class_code_0_hwtcl                        (class_code_hwtcl                           ),
                .subsystem_vendor_id_0_hwtcl               (subsystem_vendor_id_hwtcl                  ),
                .subsystem_device_id_0_hwtcl               (subsystem_device_id_hwtcl                  ),
                .max_payload_size_0_hwtcl                  (max_payload_size_hwtcl                     ),
                .extend_tag_field_0_hwtcl                  (extend_tag_field_hwtcl                     ),
                .completion_timeout_0_hwtcl                (completion_timeout_hwtcl                   ),
                .enable_completion_timeout_disable_0_hwtcl (enable_completion_timeout_disable_hwtcl    ),
                .flr_capability_0_hwtcl                    (flr_capability_hwtcl                       ),
                .use_aer_0_hwtcl                           (use_aer_hwtcl                              ),
                .ecrc_check_capable_0_hwtcl                (ecrc_check_capable_hwtcl                   ),
                .ecrc_gen_capable_0_hwtcl                  (ecrc_gen_capable_hwtcl                     ),
                .dll_active_report_support_0_hwtcl         (dll_active_report_support_hwtcl            ),
                .surprise_down_error_support_0_hwtcl       (surprise_down_error_support_hwtcl          ),
                .msi_multi_message_capable_0_hwtcl         (msi_multi_message_capable_hwtcl            ),
                .msi_64bit_addressing_capable_0_hwtcl      (msi_64bit_addressing_capable_hwtcl         ),
                .msi_masking_capable_0_hwtcl               (msi_masking_capable_hwtcl                  ),
                .msi_support_0_hwtcl                       (msi_support_hwtcl                          ),
                .enable_function_msix_support_0_hwtcl      (enable_function_msix_support_hwtcl         ),
                .msix_table_size_0_hwtcl                   (msix_table_size_hwtcl                      ),
                .msix_table_offset_0_hwtcl                 (msix_table_offset_hwtcl                    ),
                .msix_table_bir_0_hwtcl                    (msix_table_bir_hwtcl                       ),
                .msix_pba_offset_0_hwtcl                   (msix_pba_offset_hwtcl                      ),
                .msix_pba_bir_0_hwtcl                      (msix_pba_bir_hwtcl                         ),
                .interrupt_pin_0_hwtcl                     (interrupt_pin_hwtcl                        ),
                .slot_power_scale_0_hwtcl                  (slot_power_scale_hwtcl                     ),
                .slot_power_limit_0_hwtcl                  (slot_power_limit_hwtcl                     ),
                .slot_number_0_hwtcl                       (slot_number_hwtcl                          ),
                .rx_ei_l0s_0_hwtcl                         (rx_ei_l0s_hwtcl                            ),
                .endpoint_l0_latency_0_hwtcl               (endpoint_l0_latency_hwtcl                  ),
                .endpoint_l1_latency_0_hwtcl               (endpoint_l1_latency_hwtcl                  ),

                .hip_reconfig_hwtcl                        (hip_reconfig_hwtcl),
                .hip_hard_reset_hwtcl                      (hip_hard_reset_hwtcl),
                .enable_rx_buffer_checking_hwtcl           (enable_rx_buffer_checking_hwtcl),
                .single_rx_detect_hwtcl                    (single_rx_detect_hwtcl),
                .disable_link_x2_support_hwtcl             (disable_link_x2_support_hwtcl),
                .device_number_hwtcl                       (device_number_hwtcl),
                .bypass_clk_switch_hwtcl                   (bypass_clk_switch_hwtcl),
                .pipex1_debug_sel_hwtcl                    (pipex1_debug_sel_hwtcl),
                .pclk_out_sel_hwtcl                        (pclk_out_sel_hwtcl),
                .no_soft_reset_hwtcl                       (no_soft_reset_hwtcl),
                .maximum_current_0_hwtcl                   (maximum_current_hwtcl),
                .d1_support_hwtcl                          (d1_support_hwtcl),
                .d2_support_hwtcl                          (d2_support_hwtcl),
                .d0_pme_hwtcl                              (d0_pme_hwtcl),
                .d1_pme_hwtcl                              (d1_pme_hwtcl                       ),
                .d2_pme_hwtcl                              (d2_pme_hwtcl                       ),
                .d3_hot_pme_hwtcl                          (d3_hot_pme_hwtcl                   ),
                .d3_cold_pme_hwtcl                         (d3_cold_pme_hwtcl                  ),
                .low_priority_vc_hwtcl                     (low_priority_vc_hwtcl              ),
                .disable_snoop_packet_0_hwtcl              (disable_snoop_packet_hwtcl),

                .indicator_hwtcl                           (indicator_hwtcl                                                     ),
                .enable_l1_aspm_hwtcl                      (enable_l1_aspm_hwtcl                                                ),
                .enable_l0s_aspm_hwtcl                     (enable_l0s_aspm_hwtcl                                               ),
                .l1_exit_latency_sameclock_hwtcl           (l1_exit_latency_sameclock_hwtcl                                     ),
                .l1_exit_latency_diffclock_hwtcl           (l1_exit_latency_diffclock_hwtcl                                     ),
                .hot_plug_support_hwtcl                    (hot_plug_support_hwtcl                                              ),
                .diffclock_nfts_count_hwtcl                (diffclock_nfts_count_hwtcl                                          ),
                .sameclock_nfts_count_hwtcl                (sameclock_nfts_count_hwtcl                                          ),
                .no_command_completed_hwtcl                (no_command_completed_hwtcl                                          ),
                .use_tl_cfg_sync_hwtcl                     (use_tl_cfg_sync_hwtcl                                             ),
                .bridge_port_vga_enable_0_hwtcl            (bridge_port_vga_enable_hwtcl                                      ),
                .bridge_port_ssid_support_0_hwtcl          (bridge_port_ssid_support_hwtcl                                    ),
                .ssvid_0_hwtcl                             (ssvid_hwtcl                                                       ),
                .ssid_0_hwtcl                              (ssid_hwtcl                                                        ),
                .eie_before_nfts_count_hwtcl               (eie_before_nfts_count_hwtcl                                         ),
                .gen2_diffclock_nfts_count_hwtcl           (gen2_diffclock_nfts_count_hwtcl                                     ),
                .gen2_sameclock_nfts_count_hwtcl           (gen2_sameclock_nfts_count_hwtcl                                     ),
                .deemphasis_enable_hwtcl                   (deemphasis_enable_hwtcl                                             ),
                .l0_exit_latency_sameclock_hwtcl           (l0_exit_latency_sameclock_hwtcl                                     ),
                .l0_exit_latency_diffclock_hwtcl           (l0_exit_latency_diffclock_hwtcl                                     ),
                .l2_async_logic_hwtcl                      (l2_async_logic_hwtcl                                                ),
                .aspm_optionality_hwtcl                    ("true"                                                              ),
                .enable_adapter_half_rate_mode_hwtcl       (enable_adapter_half_rate_mode_hwtcl                                 ),
                .vc0_clk_enable_hwtcl                      (vc0_clk_enable_hwtcl                                                ),
                .register_pipe_signals_hwtcl               (register_pipe_signals_hwtcl                                         ),
                .tx_cdc_almost_empty_hwtcl                 (tx_cdc_almost_empty_hwtcl                                           ),
                .rx_cdc_almost_full_hwtcl                  (rx_cdc_almost_full_hwtcl                                            ),
                .tx_cdc_almost_full_hwtcl                  (tx_cdc_almost_full_hwtcl                                            ),
                .rx_l0s_count_idl_hwtcl                    (rx_l0s_count_idl_hwtcl                                              ),
                .cdc_dummy_insert_limit_hwtcl              (cdc_dummy_insert_limit_hwtcl                                        ),
                .ei_delay_powerdown_count_hwtcl            (ei_delay_powerdown_count_hwtcl                                      ),
                .millisecond_cycle_count_hwtcl             (millisecond_cycle_count_hwtcl                                       ),
                .skp_os_schedule_count_hwtcl               (skp_os_schedule_count_hwtcl                                         ),
                .fc_init_timer_hwtcl                       (fc_init_timer_hwtcl                                                 ),
                .l01_entry_latency_hwtcl                   (l01_entry_latency_hwtcl                                             ),
                .flow_control_update_count_hwtcl           (flow_control_update_count_hwtcl                                     ),
                .flow_control_timeout_count_hwtcl          (flow_control_timeout_count_hwtcl                                    ),
                .credit_buffer_allocation_aux_hwtcl        (credit_buffer_allocation_aux_hwtcl                                  ),
                .vc0_rx_flow_ctrl_posted_header_hwtcl      (vc0_rx_flow_ctrl_posted_header_hwtcl                                ),
                .vc0_rx_flow_ctrl_posted_data_hwtcl        (vc0_rx_flow_ctrl_posted_data_hwtcl                                  ),
                .vc0_rx_flow_ctrl_nonposted_header_hwtcl   (vc0_rx_flow_ctrl_nonposted_header_hwtcl                             ),
                .vc0_rx_flow_ctrl_nonposted_data_hwtcl     (vc0_rx_flow_ctrl_nonposted_data_hwtcl                               ),
                .vc0_rx_flow_ctrl_compl_header_hwtcl       (vc0_rx_flow_ctrl_compl_header_hwtcl                                 ),
                .vc0_rx_flow_ctrl_compl_data_hwtcl         (vc0_rx_flow_ctrl_compl_data_hwtcl                                   ),
                .cpl_spc_header_hwtcl                      (cpl_spc_header_hwtcl                                                ),
                .cpl_spc_data_hwtcl                        (cpl_spc_data_hwtcl                                                  ),
                .retry_buffer_last_active_address_hwtcl    (retry_buffer_last_active_address_hwtcl                              ),
                .port_width_data_hwtcl                     (port_width_data_hwtcl                                               ),
                .reserved_debug_hwtcl                      (reserved_debug_hwtcl                                                ),
                .core_clk_sel_hwtcl                        (core_clk_sel_hwtcl),
                .rpre_emph_a_val_hwtcl                     (cv_rpre_emph_a_val_hwtcl),
                .rpre_emph_b_val_hwtcl                     (cv_rpre_emph_b_val_hwtcl),
                .rpre_emph_c_val_hwtcl                     (cv_rpre_emph_c_val_hwtcl),
                .rpre_emph_d_val_hwtcl                     (cv_rpre_emph_d_val_hwtcl),
                .rpre_emph_e_val_hwtcl                     (cv_rpre_emph_e_val_hwtcl),
                .rvod_sel_a_val_hwtcl                      (cv_rvod_sel_a_val_hwtcl ),
                .rvod_sel_b_val_hwtcl                      (cv_rvod_sel_b_val_hwtcl ),
                .rvod_sel_c_val_hwtcl                      (cv_rvod_sel_c_val_hwtcl ),
                .rvod_sel_d_val_hwtcl                      (cv_rvod_sel_d_val_hwtcl ),
                .rvod_sel_e_val_hwtcl                      (cv_rvod_sel_e_val_hwtcl ),

                .porttype_func1_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_1_hwtcl                    (28),
                .bar0_io_space_1_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_1_hwtcl              ("Enabled"),
                .bar0_prefetchable_1_hwtcl                 ("Enabled"),
                .bar1_size_mask_1_hwtcl                    (0),
                .bar1_io_space_1_hwtcl                     ("Disabled"),
                .bar1_prefetchable_1_hwtcl                 ("Disabled"),
                .bar2_size_mask_1_hwtcl                    (0),
                .bar2_io_space_1_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_1_hwtcl              ("Disabled"),
                .bar2_prefetchable_1_hwtcl                 ("Disabled"),
                .bar3_size_mask_1_hwtcl                    (0),
                .bar3_io_space_1_hwtcl                     ("Disabled"),
                .bar3_prefetchable_1_hwtcl                 ("Disabled"),
                .bar4_size_mask_1_hwtcl                    (0),
                .bar4_io_space_1_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_1_hwtcl              ("Disabled"),
                .bar4_prefetchable_1_hwtcl                 ("Disabled"),
                .bar5_size_mask_1_hwtcl                    (0),
                .bar5_io_space_1_hwtcl                     ("Disabled"),
                .bar5_prefetchable_1_hwtcl                 ("Disabled"),
                .expansion_base_address_register_1_hwtcl   (0),
                .vendor_id_1_hwtcl                         (0),
                .device_id_1_hwtcl                         (1),
                .revision_id_1_hwtcl                       (1),
                .class_code_1_hwtcl                        (0),
                .subsystem_vendor_id_1_hwtcl               (0),
                .subsystem_device_id_1_hwtcl               (0),
                .max_payload_size_1_hwtcl                  (128),
                .extend_tag_field_1_hwtcl                  ("32"),
                .completion_timeout_1_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_1_hwtcl (1),
                .flr_capability_1_hwtcl                    (0),
                .use_aer_1_hwtcl                           (0),
                .ecrc_check_capable_1_hwtcl                (0),
                .ecrc_gen_capable_1_hwtcl                  (0),
                .dll_active_report_support_1_hwtcl         (0),
                .surprise_down_error_support_1_hwtcl       (0),
                .msi_multi_message_capable_1_hwtcl         ("4"),
                .msi_64bit_addressing_capable_1_hwtcl      ("true"),
                .msi_masking_capable_1_hwtcl               ("false"),
                .msi_support_1_hwtcl                       ("true"),
                .enable_function_msix_support_1_hwtcl      (0),
                .msix_table_size_1_hwtcl                   (0),
                .msix_table_offset_1_hwtcl                 (0),
                .msix_table_bir_1_hwtcl                    (0),
                .msix_pba_offset_1_hwtcl                   (0),
                .msix_pba_bir_1_hwtcl                      (0),
                .interrupt_pin_1_hwtcl                     ("inta"),
                .slot_power_scale_1_hwtcl                  (0),
                .slot_power_limit_1_hwtcl                  (0),
                .slot_number_1_hwtcl                       (0),
                .rx_ei_l0s_1_hwtcl                         (0),
                .endpoint_l0_latency_1_hwtcl               (0),
                .endpoint_l1_latency_1_hwtcl               (0),
                .maximum_current_1_hwtcl                   (0),
                .disable_snoop_packet_1_hwtcl              ("false"),
                .bridge_port_vga_enable_1_hwtcl            ("false"),
                .bridge_port_ssid_support_1_hwtcl          ("false"),
                .ssvid_1_hwtcl                             (0),
                .ssid_1_hwtcl                              (0),
                .porttype_func2_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_2_hwtcl                    (28),
                .bar0_io_space_2_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_2_hwtcl              ("Enabled"),
                .bar0_prefetchable_2_hwtcl                 ("Enabled"),
                .bar1_size_mask_2_hwtcl                    (0),
                .bar1_io_space_2_hwtcl                     ("Disabled"),
                .bar1_prefetchable_2_hwtcl                 ("Disabled"),
                .bar2_size_mask_2_hwtcl                    (0),
                .bar2_io_space_2_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_2_hwtcl              ("Disabled"),
                .bar2_prefetchable_2_hwtcl                 ("Disabled"),
                .bar3_size_mask_2_hwtcl                    (0),
                .bar3_io_space_2_hwtcl                     ("Disabled"),
                .bar3_prefetchable_2_hwtcl                 ("Disabled"),
                .bar4_size_mask_2_hwtcl                    (0),
                .bar4_io_space_2_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_2_hwtcl              ("Disabled"),
                .bar4_prefetchable_2_hwtcl                 ("Disabled"),
                .bar5_size_mask_2_hwtcl                    (0),
                .bar5_io_space_2_hwtcl                     ("Disabled"),
                .bar5_prefetchable_2_hwtcl                 ("Disabled"),
                .expansion_base_address_register_2_hwtcl   (0),
                .vendor_id_2_hwtcl                         (0),
                .device_id_2_hwtcl                         (1),
                .revision_id_2_hwtcl                       (1),
                .class_code_2_hwtcl                        (0),
                .subsystem_vendor_id_2_hwtcl               (0),
                .subsystem_device_id_2_hwtcl               (0),
                .max_payload_size_2_hwtcl                  (128),
                .extend_tag_field_2_hwtcl                  ("32"),
                .completion_timeout_2_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_2_hwtcl (1),
                .flr_capability_2_hwtcl                    (0),
                .use_aer_2_hwtcl                           (0),
                .ecrc_check_capable_2_hwtcl                (0),
                .ecrc_gen_capable_2_hwtcl                  (0),
                .dll_active_report_support_2_hwtcl         (0),
                .surprise_down_error_support_2_hwtcl       (0),
                .msi_multi_message_capable_2_hwtcl         ("4"),
                .msi_64bit_addressing_capable_2_hwtcl      ("true"),
                .msi_masking_capable_2_hwtcl               ("false"),
                .msi_support_2_hwtcl                       ("true"),
                .enable_function_msix_support_2_hwtcl      (0),
                .msix_table_size_2_hwtcl                   (0),
                .msix_table_offset_2_hwtcl                 (0),
                .msix_table_bir_2_hwtcl                    (0),
                .msix_pba_offset_2_hwtcl                   (0),
                .msix_pba_bir_2_hwtcl                      (0),
                .interrupt_pin_2_hwtcl                     ("inta"),
                .slot_power_scale_2_hwtcl                  (0),
                .slot_power_limit_2_hwtcl                  (0),
                .slot_number_2_hwtcl                       (0),
                .rx_ei_l0s_2_hwtcl                         (0),
                .endpoint_l0_latency_2_hwtcl               (0),
                .endpoint_l1_latency_2_hwtcl               (0),
                .maximum_current_2_hwtcl                   (0),
                .disable_snoop_packet_2_hwtcl              ("false"),
                .bridge_port_vga_enable_2_hwtcl            ("false"),
                .bridge_port_ssid_support_2_hwtcl          ("false"),
                .ssvid_2_hwtcl                             (0),
                .ssid_2_hwtcl                              (0),
                .porttype_func3_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_3_hwtcl                    (28),
                .bar0_io_space_3_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_3_hwtcl              ("Enabled"),
                .bar0_prefetchable_3_hwtcl                 ("Enabled"),
                .bar1_size_mask_3_hwtcl                    (0),
                .bar1_io_space_3_hwtcl                     ("Disabled"),
                .bar1_prefetchable_3_hwtcl                 ("Disabled"),
                .bar2_size_mask_3_hwtcl                    (0),
                .bar2_io_space_3_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_3_hwtcl              ("Disabled"),
                .bar2_prefetchable_3_hwtcl                 ("Disabled"),
                .bar3_size_mask_3_hwtcl                    (0),
                .bar3_io_space_3_hwtcl                     ("Disabled"),
                .bar3_prefetchable_3_hwtcl                 ("Disabled"),
                .bar4_size_mask_3_hwtcl                    (0),
                .bar4_io_space_3_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_3_hwtcl              ("Disabled"),
                .bar4_prefetchable_3_hwtcl                 ("Disabled"),
                .bar5_size_mask_3_hwtcl                    (0),
                .bar5_io_space_3_hwtcl                     ("Disabled"),
                .bar5_prefetchable_3_hwtcl                 ("Disabled"),
                .expansion_base_address_register_3_hwtcl   (0),
                .vendor_id_3_hwtcl                         (0),
                .device_id_3_hwtcl                         (1),
                .revision_id_3_hwtcl                       (1),
                .class_code_3_hwtcl                        (0),
                .subsystem_vendor_id_3_hwtcl               (0),
                .subsystem_device_id_3_hwtcl               (0),
                .max_payload_size_3_hwtcl                  (128),
                .extend_tag_field_3_hwtcl                  ("32"),
                .completion_timeout_3_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_3_hwtcl (1),
                .flr_capability_3_hwtcl                    (0),
                .use_aer_3_hwtcl                           (0),
                .ecrc_check_capable_3_hwtcl                (0),
                .ecrc_gen_capable_3_hwtcl                  (0),
                .dll_active_report_support_3_hwtcl         (0),
                .surprise_down_error_support_3_hwtcl       (0),
                .msi_multi_message_capable_3_hwtcl         ("4"),
                .msi_64bit_addressing_capable_3_hwtcl      ("true"),
                .msi_masking_capable_3_hwtcl               ("false"),
                .msi_support_3_hwtcl                       ("true"),
                .enable_function_msix_support_3_hwtcl      (0),
                .msix_table_size_3_hwtcl                   (0),
                .msix_table_offset_3_hwtcl                 (0),
                .msix_table_bir_3_hwtcl                    (0),
                .msix_pba_offset_3_hwtcl                   (0),
                .msix_pba_bir_3_hwtcl                      (0),
                .interrupt_pin_3_hwtcl                     ("inta"),
                .slot_power_scale_3_hwtcl                  (0),
                .slot_power_limit_3_hwtcl                  (0),
                .slot_number_3_hwtcl                       (0),
                .rx_ei_l0s_3_hwtcl                         (0),
                .endpoint_l0_latency_3_hwtcl               (0),
                .endpoint_l1_latency_3_hwtcl               (0),
                .maximum_current_3_hwtcl                   (0),
                .disable_snoop_packet_3_hwtcl              ("false"),
                .bridge_port_vga_enable_3_hwtcl            ("false"),
                .bridge_port_ssid_support_3_hwtcl          ("false"),
                .ssvid_3_hwtcl                             (0),
                .ssid_3_hwtcl                              (0),
                .porttype_func4_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_4_hwtcl                    (28),
                .bar0_io_space_4_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_4_hwtcl              ("Enabled"),
                .bar0_prefetchable_4_hwtcl                 ("Enabled"),
                .bar1_size_mask_4_hwtcl                    (0),
                .bar1_io_space_4_hwtcl                     ("Disabled"),
                .bar1_prefetchable_4_hwtcl                 ("Disabled"),
                .bar2_size_mask_4_hwtcl                    (0),
                .bar2_io_space_4_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_4_hwtcl              ("Disabled"),
                .bar2_prefetchable_4_hwtcl                 ("Disabled"),
                .bar3_size_mask_4_hwtcl                    (0),
                .bar3_io_space_4_hwtcl                     ("Disabled"),
                .bar3_prefetchable_4_hwtcl                 ("Disabled"),
                .bar4_size_mask_4_hwtcl                    (0),
                .bar4_io_space_4_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_4_hwtcl              ("Disabled"),
                .bar4_prefetchable_4_hwtcl                 ("Disabled"),
                .bar5_size_mask_4_hwtcl                    (0),
                .bar5_io_space_4_hwtcl                     ("Disabled"),
                .bar5_prefetchable_4_hwtcl                 ("Disabled"),
                .expansion_base_address_register_4_hwtcl   (0),
                .vendor_id_4_hwtcl                         (0),
                .device_id_4_hwtcl                         (1),
                .revision_id_4_hwtcl                       (1),
                .class_code_4_hwtcl                        (0),
                .subsystem_vendor_id_4_hwtcl               (0),
                .subsystem_device_id_4_hwtcl               (0),
                .max_payload_size_4_hwtcl                  (128),
                .extend_tag_field_4_hwtcl                  ("32"),
                .completion_timeout_4_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_4_hwtcl (1),
                .flr_capability_4_hwtcl                    (0),
                .use_aer_4_hwtcl                           (0),
                .ecrc_check_capable_4_hwtcl                (0),
                .ecrc_gen_capable_4_hwtcl                  (0),
                .dll_active_report_support_4_hwtcl         (0),
                .surprise_down_error_support_4_hwtcl       (0),
                .msi_multi_message_capable_4_hwtcl         ("4"),
                .msi_64bit_addressing_capable_4_hwtcl      ("true"),
                .msi_masking_capable_4_hwtcl               ("false"),
                .msi_support_4_hwtcl                       ("true"),
                .enable_function_msix_support_4_hwtcl      (0),
                .msix_table_size_4_hwtcl                   (0),
                .msix_table_offset_4_hwtcl                 (0),
                .msix_table_bir_4_hwtcl                    (0),
                .msix_pba_offset_4_hwtcl                   (0),
                .msix_pba_bir_4_hwtcl                      (0),
                .interrupt_pin_4_hwtcl                     ("inta"),
                .slot_power_scale_4_hwtcl                  (0),
                .slot_power_limit_4_hwtcl                  (0),
                .slot_number_4_hwtcl                       (0),
                .rx_ei_l0s_4_hwtcl                         (0),
                .endpoint_l0_latency_4_hwtcl               (0),
                .endpoint_l1_latency_4_hwtcl               (0),
                .maximum_current_4_hwtcl                   (0),
                .disable_snoop_packet_4_hwtcl              ("false"),
                .bridge_port_vga_enable_4_hwtcl            ("false"),
                .bridge_port_ssid_support_4_hwtcl          ("false"),
                .ssvid_4_hwtcl                             (0),
                .ssid_4_hwtcl                              (0),
                .porttype_func5_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_5_hwtcl                    (28),
                .bar0_io_space_5_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_5_hwtcl              ("Enabled"),
                .bar0_prefetchable_5_hwtcl                 ("Enabled"),
                .bar1_size_mask_5_hwtcl                    (0),
                .bar1_io_space_5_hwtcl                     ("Disabled"),
                .bar1_prefetchable_5_hwtcl                 ("Disabled"),
                .bar2_size_mask_5_hwtcl                    (0),
                .bar2_io_space_5_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_5_hwtcl              ("Disabled"),
                .bar2_prefetchable_5_hwtcl                 ("Disabled"),
                .bar3_size_mask_5_hwtcl                    (0),
                .bar3_io_space_5_hwtcl                     ("Disabled"),
                .bar3_prefetchable_5_hwtcl                 ("Disabled"),
                .bar4_size_mask_5_hwtcl                    (0),
                .bar4_io_space_5_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_5_hwtcl              ("Disabled"),
                .bar4_prefetchable_5_hwtcl                 ("Disabled"),
                .bar5_size_mask_5_hwtcl                    (0),
                .bar5_io_space_5_hwtcl                     ("Disabled"),
                .bar5_prefetchable_5_hwtcl                 ("Disabled"),
                .expansion_base_address_register_5_hwtcl   (0),
                .vendor_id_5_hwtcl                         (0),
                .device_id_5_hwtcl                         (1),
                .revision_id_5_hwtcl                       (1),
                .class_code_5_hwtcl                        (0),
                .subsystem_vendor_id_5_hwtcl               (0),
                .subsystem_device_id_5_hwtcl               (0),
                .max_payload_size_5_hwtcl                  (128),
                .extend_tag_field_5_hwtcl                  ("32"),
                .completion_timeout_5_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_5_hwtcl (1),
                .flr_capability_5_hwtcl                    (0),
                .use_aer_5_hwtcl                           (0),
                .ecrc_check_capable_5_hwtcl                (0),
                .ecrc_gen_capable_5_hwtcl                  (0),
                .dll_active_report_support_5_hwtcl         (0),
                .surprise_down_error_support_5_hwtcl       (0),
                .msi_multi_message_capable_5_hwtcl         ("4"),
                .msi_64bit_addressing_capable_5_hwtcl      ("true"),
                .msi_masking_capable_5_hwtcl               ("false"),
                .msi_support_5_hwtcl                       ("true"),
                .enable_function_msix_support_5_hwtcl      (0),
                .msix_table_size_5_hwtcl                   (0),
                .msix_table_offset_5_hwtcl                 (0),
                .msix_table_bir_5_hwtcl                    (0),
                .msix_pba_offset_5_hwtcl                   (0),
                .msix_pba_bir_5_hwtcl                      (0),
                .interrupt_pin_5_hwtcl                     ("inta"),
                .slot_power_scale_5_hwtcl                  (0),
                .slot_power_limit_5_hwtcl                  (0),
                .slot_number_5_hwtcl                       (0),
                .rx_ei_l0s_5_hwtcl                         (0),
                .endpoint_l0_latency_5_hwtcl               (0),
                .endpoint_l1_latency_5_hwtcl               (0),
                .maximum_current_5_hwtcl                   (0),
                .disable_snoop_packet_5_hwtcl              ("false"),
                .bridge_port_vga_enable_5_hwtcl            ("false"),
                .bridge_port_ssid_support_5_hwtcl          ("false"),
                .ssvid_5_hwtcl                             (0),
                .ssid_5_hwtcl                              (0),
                .porttype_func6_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_6_hwtcl                    (28),
                .bar0_io_space_6_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_6_hwtcl              ("Enabled"),
                .bar0_prefetchable_6_hwtcl                 ("Enabled"),
                .bar1_size_mask_6_hwtcl                    (0),
                .bar1_io_space_6_hwtcl                     ("Disabled"),
                .bar1_prefetchable_6_hwtcl                 ("Disabled"),
                .bar2_size_mask_6_hwtcl                    (0),
                .bar2_io_space_6_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_6_hwtcl              ("Disabled"),
                .bar2_prefetchable_6_hwtcl                 ("Disabled"),
                .bar3_size_mask_6_hwtcl                    (0),
                .bar3_io_space_6_hwtcl                     ("Disabled"),
                .bar3_prefetchable_6_hwtcl                 ("Disabled"),
                .bar4_size_mask_6_hwtcl                    (0),
                .bar4_io_space_6_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_6_hwtcl              ("Disabled"),
                .bar4_prefetchable_6_hwtcl                 ("Disabled"),
                .bar5_size_mask_6_hwtcl                    (0),
                .bar5_io_space_6_hwtcl                     ("Disabled"),
                .bar5_prefetchable_6_hwtcl                 ("Disabled"),
                .expansion_base_address_register_6_hwtcl   (0),
                .vendor_id_6_hwtcl                         (0),
                .device_id_6_hwtcl                         (1),
                .revision_id_6_hwtcl                       (1),
                .class_code_6_hwtcl                        (0),
                .subsystem_vendor_id_6_hwtcl               (0),
                .subsystem_device_id_6_hwtcl               (0),
                .max_payload_size_6_hwtcl                  (128),
                .extend_tag_field_6_hwtcl                  ("32"),
                .completion_timeout_6_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_6_hwtcl (1),
                .flr_capability_6_hwtcl                    (0),
                .use_aer_6_hwtcl                           (0),
                .ecrc_check_capable_6_hwtcl                (0),
                .ecrc_gen_capable_6_hwtcl                  (0),
                .dll_active_report_support_6_hwtcl         (0),
                .surprise_down_error_support_6_hwtcl       (0),
                .msi_multi_message_capable_6_hwtcl         ("4"),
                .msi_64bit_addressing_capable_6_hwtcl      ("true"),
                .msi_masking_capable_6_hwtcl               ("false"),
                .msi_support_6_hwtcl                       ("true"),
                .enable_function_msix_support_6_hwtcl      (0),
                .msix_table_size_6_hwtcl                   (0),
                .msix_table_offset_6_hwtcl                 (0),
                .msix_table_bir_6_hwtcl                    (0),
                .msix_pba_offset_6_hwtcl                   (0),
                .msix_pba_bir_6_hwtcl                      (0),
                .interrupt_pin_6_hwtcl                     ("inta"),
                .slot_power_scale_6_hwtcl                  (0),
                .slot_power_limit_6_hwtcl                  (0),
                .slot_number_6_hwtcl                       (0),
                .rx_ei_l0s_6_hwtcl                         (0),
                .endpoint_l0_latency_6_hwtcl               (0),
                .endpoint_l1_latency_6_hwtcl               (0),
                .maximum_current_6_hwtcl                   (0),
                .disable_snoop_packet_6_hwtcl              ("false"),
                .bridge_port_vga_enable_6_hwtcl            ("false"),
                .bridge_port_ssid_support_6_hwtcl          ("false"),
                .ssvid_6_hwtcl                             (0),
                .ssid_6_hwtcl                              (0),
                .porttype_func7_hwtcl                      ("Native endpoint"),
                .bar0_size_mask_7_hwtcl                    (28),
                .bar0_io_space_7_hwtcl                     ("Disabled"),
                .bar0_64bit_mem_space_7_hwtcl              ("Enabled"),
                .bar0_prefetchable_7_hwtcl                 ("Enabled"),
                .bar1_size_mask_7_hwtcl                    (0),
                .bar1_io_space_7_hwtcl                     ("Disabled"),
                .bar1_prefetchable_7_hwtcl                 ("Disabled"),
                .bar2_size_mask_7_hwtcl                    (0),
                .bar2_io_space_7_hwtcl                     ("Disabled"),
                .bar2_64bit_mem_space_7_hwtcl              ("Disabled"),
                .bar2_prefetchable_7_hwtcl                 ("Disabled"),
                .bar3_size_mask_7_hwtcl                    (0),
                .bar3_io_space_7_hwtcl                     ("Disabled"),
                .bar3_prefetchable_7_hwtcl                 ("Disabled"),
                .bar4_size_mask_7_hwtcl                    (0),
                .bar4_io_space_7_hwtcl                     ("Disabled"),
                .bar4_64bit_mem_space_7_hwtcl              ("Disabled"),
                .bar4_prefetchable_7_hwtcl                 ("Disabled"),
                .bar5_size_mask_7_hwtcl                    (0),
                .bar5_io_space_7_hwtcl                     ("Disabled"),
                .bar5_prefetchable_7_hwtcl                 ("Disabled"),
                .expansion_base_address_register_7_hwtcl   (0),
                .vendor_id_7_hwtcl                         (0),
                .device_id_7_hwtcl                         (1),
                .revision_id_7_hwtcl                       (1),
                .class_code_7_hwtcl                        (0),
                .subsystem_vendor_id_7_hwtcl               (0),
                .subsystem_device_id_7_hwtcl               (0),
                .max_payload_size_7_hwtcl                  (128),
                .extend_tag_field_7_hwtcl                  ("32"),
                .completion_timeout_7_hwtcl                ("ABCD"),
                .enable_completion_timeout_disable_7_hwtcl (1),
                .flr_capability_7_hwtcl                    (0),
                .use_aer_7_hwtcl                           (0),
                .ecrc_check_capable_7_hwtcl                (0),
                .ecrc_gen_capable_7_hwtcl                  (0),
                .dll_active_report_support_7_hwtcl         (0),
                .surprise_down_error_support_7_hwtcl       (0),
                .msi_multi_message_capable_7_hwtcl         ("4"),
                .msi_64bit_addressing_capable_7_hwtcl      ("true"),
                .msi_masking_capable_7_hwtcl               ("false"),
                .msi_support_7_hwtcl                       ("true"),
                .enable_function_msix_support_7_hwtcl      (0),
                .msix_table_size_7_hwtcl                   (0),
                .msix_table_offset_7_hwtcl                 (0),
                .msix_table_bir_7_hwtcl                    (0),
                .msix_pba_offset_7_hwtcl                   (0),
                .msix_pba_bir_7_hwtcl                      (0),
                .interrupt_pin_7_hwtcl                     ("inta"),
                .slot_power_scale_7_hwtcl                  (0),
                .slot_power_limit_7_hwtcl                  (0),
                .slot_number_7_hwtcl                       (0),
                .rx_ei_l0s_7_hwtcl                         (0),
                .endpoint_l0_latency_7_hwtcl               (0),
                .endpoint_l1_latency_7_hwtcl               (0),
                .maximum_current_7_hwtcl                   (0),
                .disable_snoop_packet_7_hwtcl              ("false"),
                .bridge_port_vga_enable_7_hwtcl            ("false"),
                .bridge_port_ssid_support_7_hwtcl          ("false"),
                .ssvid_7_hwtcl                             (0),
                .ssid_7_hwtcl                              (0),
                .reconfig_to_xcvr_width                    (reconfig_to_xcvr_width),
                .reconfig_from_xcvr_width                  (reconfig_from_xcvr_width)

        ) c5_hip_ast (
                .npor                    (npor),                 //               npor.npor
                .pin_perst               (pin_perst),            //                   .pin_perst
                .test_in                 (test_in),          //           hip_ctrl.test_in
                .simu_mode_pipe          (simu_mode_pipe),   //                   .simu_mode_pipe
                .pld_clk                 (pld_clk_hip),                        //            pld_clk.clk
                .coreclkout              (coreclkout_hip),                      //     coreclkout_hip.clk
                .refclk                  (refclk),                //             refclk.clk
                .rx_in0                  (rx_in0),         //         hip_serial.rx_in0
                .tx_out0                 (tx_out0),        //                   .tx_out0
                .rx_st_valid         (rx_st_valid),                             //              rx_st.valid
                .rx_st_sop           (rx_st_sop),                     //                   .startofpacket
                .rx_st_eop           (rx_st_eop),                       //                   .endofpacket
                .rx_st_ready         (rx_st_ready),                             //                   .ready
                .rx_st_err           (rx_st_err),                             //                   .error
                .rx_st_data          (rx_st_data),                              //                   .data
                .rx_st_bar               (rx_st_bar),                     //          rx_bar_be.rx_st_bar
                .rx_st_be                (rx_st_be),                      //                   .rx_st_be
                .rx_st_mask              (rx_st_mask),                   //                   .rx_st_mask
                .tx_st_valid         (tx_st_valid),                            //              tx_st.valid
                .tx_st_sop           (tx_st_sop),                    //                   .startofpacket
                .tx_st_eop           (tx_st_eop),                      //                   .endofpacket
                .tx_st_ready         (tx_st_ready),                            //                   .ready
                .tx_st_err           (1'b0),                            //                   .error
                .tx_st_data          (tx_st_data),                             //                   .data
                .tx_cred_datafccp        (tx_cred_datafccp),                //            tx_cred.tx_cred_datafccp
                .tx_cred_datafcnp        (tx_cred_datafcnp),                //                   .tx_cred_datafcnp
                .tx_cred_datafcp         (tx_cred_datafcp),                 //                   .tx_cred_datafcp
                .tx_cred_fchipcons       (tx_cred_fchipcons),               //                   .tx_cred_fchipcons
                .tx_cred_fcinfinite      (tx_cred_fcinfinite),              //                   .tx_cred_fcinfinite
                .tx_cred_hdrfccp         (tx_cred_hdrfccp),                 //                   .tx_cred_hdrfccp
                .tx_cred_hdrfcnp         (tx_cred_hdrfcnp),                 //                   .tx_cred_hdrfcnp
                .tx_cred_hdrfcp          (tx_cred_hdrfcp),                  //                   .tx_cred_hdrfcp

                .sim_pipe_pclk_in        (sim_pipe_pclk_in), //           hip_pipe.sim_pipe_pclk_in
                .sim_pipe_rate           (sim_pipe_rate),    //                   .sim_pipe_rate
                .sim_ltssmstate          (sim_ltssmstate),   //                   .sim_ltssmstate
                .eidleinfersel0          (eidleinfersel0),   //                   .eidleinfersel0
                .powerdown0              (powerdown0),       //                   .powerdown0
                .rxpolarity0             (rxpolarity0),      //                   .rxpolarity0
                .txcompl0                (txcompl0),         //                   .txcompl0
                .txdata0                 (txdata0),          //                   .txdata0
                .txdatak0                (txdatak0),         //                   .txdatak0
                .txdetectrx0             (txdetectrx0),      //                   .txdetectrx0
                .txelecidle0             (txelecidle0),      //                   .txelecidle0
                .txdeemph0               (txdeemph0),        //                   .txdeemph0
                .phystatus0              (phystatus0),       //                   .phystatus0
                .rxdata0                 (rxdata0),          //                   .rxdata0
                .rxdatak0                (rxdatak0),         //                   .rxdatak0
                .rxelecidle0             (rxelecidle0),      //                   .rxelecidle0
                .rxstatus0               (rxstatus0),        //                   .rxstatus0
                .rxvalid0                (rxvalid0),         //                   .rxvalid0
                .reset_status            (reset_status_int),                    //            hip_rst.reset_status
                .serdes_pll_locked       (serdes_pll_locked),               //                   .serdes_pll_locked
                .pld_clk_inuse           (pld_clk_inuse),                   //                   .pld_clk_inuse
                .pld_core_ready          (pld_core_ready),                 //                   .pld_core_ready
                .testin_zero             (),                     //                   .testin_zero
                .lmi_addr                (12'h0),                           //                lmi.lmi_addr
                .lmi_din                 (32'h0),                            //                   .lmi_din
                .lmi_rden                (1'b0),                           //                   .lmi_rden
                .lmi_wren                (1'b0),                           //                   .lmi_wren
                .lmi_ack                 (),                             //                   .lmi_ack
                .lmi_dout                (),                            //                   .lmi_dout
                .pm_auxpwr               (1'b0),                   //         power_mngt.pm_auxpwr
                .pm_data                 (10'h0),                     //                   .pm_data
                .pme_to_cr               (1'b0),                   //                   .pme_to_cr
                .pm_event                (1'b0),                    //                   .pm_event
                .pme_to_sr               (pme_to_sr),                    //                   .pme_to_sr
               // .busy_xcvr_reconfig      (busy_xcvr_reconfig),    //   reconfig_to_xcvr.busy_xcvr_reconfig
                .fixedclk_locked         (fixedclk_locked),      // reconfig_from_xcvr.fixedclk_locked
                .reconfig_from_xcvr      (reconfig_from_xcvr),
                .reconfig_to_xcvr        (reconfig_to_xcvr),
                .app_int_sts_vec      (app_int_sts_internal),                    //            int_msi.app_int_sts
                .app_msi_num          (app_msi_num),                    //                   .app_msi_num
                .app_msi_req          (app_msi_req),                    //                   .app_msi_req
                .app_msi_tc           (app_msi_tc),                     //                   .app_msi_tc
                .app_msi_ack          (app_msi_ack),                     //                   .app_msi_ack
                .serr_out                (serr_out),                        //                   .serr_out
                .tl_hpg_ctrl_er          (hpg_ctrler),                   //          config_tl.hpg_ctrler
                .tl_cfg_ctl              (tl_cfg_ctl),                    //                   .tl_cfg_ctl
                .cpl_err                 (7'h0),                      //                   .cpl_err
                .tl_cfg_add              (tl_cfg_add),                    //                   .tl_cfg_add
                .tl_cfg_sts              (tl_cfg_sts),                    //                   .tl_cfg_sts
                .cpl_pending             (cpl_pending),                  //                   .cpl_pending
                .dl_current_speed        (currentspeed),                 //         hip_status.currentspeed
                .derr_cor_ext_rcv0       (derr_cor_ext_rcv),             //                   .derr_cor_ext_rcv
                .derr_cor_ext_rpl        (derr_cor_ext_rpl),             //                   .derr_cor_ext_rpl
                .derr_rpl                (derr_rpl),                     //                   .derr_rpl
                .dlup_exit               (dlup_exit),                    //                   .dlup_exit
                .dl_ltssm                (ltssmstate),                   //                   .ltssmstate
                .ev128ns                 (ev128ns),                      //                   .ev128ns
                .ev1us                   (ev1us),                        //                   .ev1us
                .hotrst_exit             (hotrst_exit),                  //                   .hotrst_exit
                .int_status              (int_status),                   //                   .int_status
                .l2_exit                 (l2_exit),                      //                   .l2_exit
                .lane_act                (lane_act),                     //                   .lane_act
                .ko_cpl_spc_header       (ko_cpl_spc_header),            //                   .ko_cpl_spc_header
                .ko_cpl_spc_data         (ko_cpl_spc_data),              //                   .ko_cpl_spc_data
                .rx_in1                  (rx_in1            ),                                        //        (terminated)
                .rx_in2                  (rx_in2            ),                                        //        (terminated)
                .rx_in3                  (rx_in3            ),                                        //        (terminated)
                .rx_in4                  (rx_in4            ),                                        //        (terminated)
                .rx_in5                  (rx_in5            ),                                        //        (terminated)
                .rx_in6                  (rx_in6            ),                                        //        (terminated)
                .rx_in7                  (rx_in7            ),                                        //        (terminated)
                .tx_out1                 (tx_out1),                                            //        (terminated)
                .tx_out2                 (tx_out2),                                            //        (terminated)
                .tx_out3                 (tx_out3),                                            //        (terminated)
                .tx_out4                 (tx_out4),                                            //        (terminated)
                .tx_out5                 (tx_out5),                                            //        (terminated)
                .tx_out6                 (tx_out6),                                            //        (terminated)
                .tx_out7                 (tx_out7),                                            //        (terminated)
                .rx_st_empty         (rx_st_empty),                                            //        (terminated)
                .rx_bar_dec_func_num (),                                            //        (terminated)
                .tx_st_empty         (tx_st_empty),                                       //        (terminated)
                .eidleinfersel1          (eidleinfersel1                    ),                                            //        (terminated)
                .eidleinfersel2          (eidleinfersel2                    ),                                            //        (terminated)
                .eidleinfersel3          (eidleinfersel3                    ),                                            //        (terminated)
                .eidleinfersel4          (eidleinfersel4                    ),                                            //        (terminated)
                .eidleinfersel5          (eidleinfersel5                    ),                                            //        (terminated)
                .eidleinfersel6          (eidleinfersel6                    ),                                            //        (terminated)
                .eidleinfersel7          (eidleinfersel7                    ),                                            //        (terminated)
                .powerdown1              (powerdown1                   ),                                            //        (terminated)
                .powerdown2              (powerdown2                   ),                                            //        (terminated)
                .powerdown3              (powerdown3                   ),                                            //        (terminated)
                .powerdown4              (powerdown4                   ),                                            //        (terminated)
                .powerdown5              (powerdown5                   ),                                            //        (terminated)
                .powerdown6              (powerdown6                   ),                                            //        (terminated)
                .powerdown7              (powerdown7                   ),                                            //        (terminated)
                .rxpolarity1             (rxpolarity1                  ),                                            //        (terminated)
                .rxpolarity2             (rxpolarity2                  ),                                            //        (terminated)
                .rxpolarity3             (rxpolarity3                  ),                                            //        (terminated)
                .rxpolarity4             (rxpolarity4                  ),                                            //        (terminated)
                .rxpolarity5             (rxpolarity5                  ),                                            //        (terminated)
                .rxpolarity6             (rxpolarity6                  ),                                            //        (terminated)
                .rxpolarity7             (rxpolarity7                  ),                                            //        (terminated)
                .txcompl1                (txcompl1                     ),                                            //        (terminated)
                .txcompl2                (txcompl2                     ),                                            //        (terminated)
                .txcompl3                (txcompl3                     ),                                            //        (terminated)
                .txcompl4                (txcompl4                     ),                                            //        (terminated)
                .txcompl5                (txcompl5                     ),                                            //        (terminated)
                .txcompl6                (txcompl6                     ),                                            //        (terminated)
                .txcompl7                (txcompl7                     ),                                            //        (terminated)
                .txdata1                 (txdata1                      ),                                            //        (terminated)
                .txdata2                 (txdata2                      ),                                            //        (terminated)
                .txdata3                 (txdata3                      ),                                            //        (terminated)
                .txdata4                 (txdata4                      ),                                            //        (terminated)
                .txdata5                 (txdata5                      ),                                            //        (terminated)
                .txdata6                 (txdata6                      ),                                            //        (terminated)
                .txdata7                 (txdata7                      ),                                            //        (terminated)
                .txdatak1                (txdatak1                     ),                                            //        (terminated)
                .txdatak2                (txdatak2                     ),                                            //        (terminated)
                .txdatak3                (txdatak3                     ),                                            //        (terminated)
                .txdatak4                (txdatak4                     ),                                            //        (terminated)
                .txdatak5                (txdatak5                     ),                                            //        (terminated)
                .txdatak6                (txdatak6                     ),                                            //        (terminated)
                .txdatak7                (txdatak7                     ),                                            //        (terminated)
                .txdetectrx1             (txdetectrx1                  ),                                            //        (terminated)
                .txdetectrx2             (txdetectrx2                  ),                                            //        (terminated)
                .txdetectrx3             (txdetectrx3                  ),                                            //        (terminated)
                .txdetectrx4             (txdetectrx4                  ),                                            //        (terminated)
                .txdetectrx5             (txdetectrx5                  ),                                            //        (terminated)
                .txdetectrx6             (txdetectrx6                  ),                                            //        (terminated)
                .txdetectrx7             (txdetectrx7                  ),                                            //        (terminated)
                .txelecidle1             (txelecidle1                  ),                                            //        (terminated)
                .txelecidle2             (txelecidle2                  ),                                            //        (terminated)
                .txelecidle3             (txelecidle3                  ),                                            //        (terminated)
                .txelecidle4             (txelecidle4                  ),                                            //        (terminated)
                .txelecidle5             (txelecidle5                  ),                                            //        (terminated)
                .txelecidle6             (txelecidle6                  ),                                            //        (terminated)
                .txelecidle7             (txelecidle7                  ),                                            //        (terminated)
                .txdeemph1               (txdeemph1                    ),                                            //        (terminated)
                .txdeemph2               (txdeemph2                    ),                                            //        (terminated)
                .txdeemph3               (txdeemph3                    ),                                            //        (terminated)
                .txdeemph4               (txdeemph4                    ),                                            //        (terminated)
                .txdeemph5               (txdeemph5                    ),                                            //        (terminated)
                .txdeemph6               (txdeemph6                    ),                                            //        (terminated)
                .txdeemph7               (txdeemph7                    ),                                            //        (terminated)
                .phystatus1              (phystatus1                      ),                                        //        (terminated)
                .phystatus2              (phystatus2                      ),                                        //        (terminated)
                .phystatus3              (phystatus3                      ),                                        //        (terminated)
                .phystatus4              (phystatus4                      ),                                        //        (terminated)
                .phystatus5              (phystatus5                      ),                                        //        (terminated)
                .phystatus6              (phystatus6                      ),                                        //        (terminated)
                .phystatus7              (phystatus7                      ),                                        //        (terminated)
                .rxdata1                 (rxdata1                        ),                                 //        (terminated)
                .rxdata2                 (rxdata2                        ),                                 //        (terminated)
                .rxdata3                 (rxdata3                        ),                                 //        (terminated)
                .rxdata4                 (rxdata4                        ),                                 //        (terminated)
                .rxdata5                 (rxdata5                        ),                                 //        (terminated)
                .rxdata6                 (rxdata6                        ),                                 //        (terminated)
                .rxdata7                 (rxdata7                        ),                                 //        (terminated)
                .rxdatak1                (rxdatak1                        ),                                        //        (terminated)
                .rxdatak2                (rxdatak2                        ),                                        //        (terminated)
                .rxdatak3                (rxdatak3                        ),                                        //        (terminated)
                .rxdatak4                (rxdatak4                        ),                                        //        (terminated)
                .rxdatak5                (rxdatak5                        ),                                        //        (terminated)
                .rxdatak6                (rxdatak6                        ),                                        //        (terminated)
                .rxdatak7                (rxdatak7                        ),                                        //        (terminated)
                .rxelecidle1             (rxelecidle1                     ),                                        //        (terminated)
                .rxelecidle2             (rxelecidle2                     ),                                        //        (terminated)
                .rxelecidle3             (rxelecidle3                     ),                                        //        (terminated)
                .rxelecidle4             (rxelecidle4                     ),                                        //        (terminated)
                .rxelecidle5             (rxelecidle5                     ),                                        //        (terminated)
                .rxelecidle6             (rxelecidle6                     ),                                        //        (terminated)
                .rxelecidle7             (rxelecidle7                     ),                                        //        (terminated)
                .rxstatus1               (rxstatus1                        ),                                      //        (terminated)
                .rxstatus2               (rxstatus2                        ),                                      //        (terminated)
                .rxstatus3               (rxstatus3                        ),                                      //        (terminated)
                .rxstatus4               (rxstatus4                        ),                                      //        (terminated)
                .rxstatus5               (rxstatus5                        ),                                      //        (terminated)
                .rxstatus6               (rxstatus6                        ),                                      //        (terminated)
                .rxstatus7               (rxstatus7                        ),                                      //        (terminated)
                .rxvalid1                (rxvalid1                         ),                                        //        (terminated)
                .rxvalid2                (rxvalid2                         ),                                        //        (terminated)
                .rxvalid3                (rxvalid3                         ),                                        //        (terminated)
                .rxvalid4                (rxvalid4                         ),                                        //        (terminated)
                .rxvalid5                (rxvalid5                         ),                                        //        (terminated)
                .rxvalid6                (rxvalid6                         ),                                        //        (terminated)
                .rxvalid7                (rxvalid7                         ),                                        //        (terminated)
                .txmargin0               (txmargin0                        ),                                            //        (terminated)
                .txmargin1               (txmargin1                        ),                                            //        (terminated)
                .txmargin2               (txmargin2                        ),                                            //        (terminated)
                .txmargin3               (txmargin3                        ),                                            //        (terminated)
                .txmargin4               (txmargin4                        ),                                            //        (terminated)
                .txmargin5               (txmargin5                        ),                                            //        (terminated)
                .txmargin6               (txmargin6                        ),                                            //        (terminated)
                .txmargin7               (txmargin7                        ),                                            //        (terminated)

                .sim_pipe_pclk_out       (sim_pipe_pclk_out),                                            //        (terminated)
                .pm_event_func           (3'b000),                                      //        (terminated)
                .app_msi_func         (3'b000),                                      //        (terminated)
                .aer_msi_num          (5'b00000),                                    //        (terminated)
                .pex_msi_num          (5'b00000),                                    //        (terminated)
                .cpl_err_func            (3'b000),                                      //        (terminated)
                .tl_cfg_ctl_wr           (),                                            //        (terminated)
                .tl_cfg_sts_wr           ()                                            //        (terminated)
        //      .derr_cor_ext_rcv1       ()                                             //        (terminated)
        );
end
endgenerate

wire dma_control_0_wrdcs_slave_0_chipselect;
wire dma_control_0_rddcs_slave_0_chipselect;
wire dma_control_0_wrdcs_slave_0_waitrequest;
wire dma_control_0_rddcs_slave_0_waitrequest;
wire [31:0] dma_control_0_wrdcs_slave_0_readdata;
wire [31:0] dma_control_0_rddcs_slave_0_readdata;
wire dma_control_0_wrdcs_slave_0_readdatavalid;
wire dma_control_0_rddcs_slave_0_readdatavalid;
wire dma_control_0_dcs_slave_0_write;
wire dma_control_0_dcs_slave_0_read;
wire dma_control_0_dcs_slave_0_readdatavalid;
wire [31:0] dma_control_0_dcs_slave_0_readdata;
wire [bar0_type_hwtcl-1:0]      dma_control_0_dcs_slave_0_address;
wire [31:0]                     dma_control_0_dcs_slave_0_writedata;
wire [(avmm_width_hwtcl/8)-1:0] dma_control_0_dcs_slave_0_byteenable;
wire dma_control_0_dcs_slave_0_waitrequest;

wire [159:0] dma_control_0_rddma_tx_data;
wire dma_control_0_rddma_tx_valid;
wire dma_control_0_rddma_tx_ready;
wire [31:0] dut_rd_ast_tx_data;
wire dut_rd_ast_tx_valid;

wire [159:0] dma_control_0_wrdma_tx_data;
wire dma_control_0_wrdma_tx_valid;
wire dma_control_0_wrdma_tx_ready;
wire [31:0] dut_wr_ast_tx_data;
wire dut_wr_ast_tx_valid;
wire [81:0] MsiInterface_wire;

generate if (internal_controller_hwtcl == 1)
    begin
  altpcie_rxm_2_dma_controller_decode # (
    .bar_type_hwtcl                  (bar0_type_hwtcl)
  ) altpcie_rxm_2_dma_controller_decode
    (
      .rxm_address_i                (dma_control_0_dcs_slave_0_address),
      .rxm_read_data_wr_ctrl_i      (dma_control_0_wrdcs_slave_0_readdata),
      .rxm_read_data_valid_wr_ctrl_i(dma_control_0_wrdcs_slave_0_readdatavalid),
      .rxm_read_data_rd_ctrl_i      (dma_control_0_rddcs_slave_0_readdata),
      .rxm_read_data_valid_rd_ctrl_i(dma_control_0_rddcs_slave_0_readdatavalid),
      .rxm_read_data_valid_o        (dma_control_0_dcs_slave_0_readdatavalid),
      .rxm_read_data_o              (dma_control_0_dcs_slave_0_readdata),
      .rxm_wait_request_rd_ctrl_i   (dma_control_0_rddcs_slave_0_waitrequest),
      .rxm_wait_request_wr_ctrl_i   (dma_control_0_wrdcs_slave_0_waitrequest),
      .chip_select_rdctrl_o         (dma_control_0_rddcs_slave_0_chipselect),
      .chip_select_wrctrl_o         (dma_control_0_wrdcs_slave_0_chipselect),
      .rxm_wait_request_o           (dma_control_0_dcs_slave_0_waitrequest)
    );

   assign dma_control_0_wrdcs_slave_0_readdatavalid = ~dma_control_0_wrdcs_slave_0_waitrequest & dma_control_0_dcs_slave_0_read;
   assign dma_control_0_rddcs_slave_0_readdatavalid = ~dma_control_0_rddcs_slave_0_waitrequest & dma_control_0_dcs_slave_0_read;

  dma_control # (
      .dma_use_scfifo_ext(dma_use_scfifo_ext_hwtcl),
      .DMA_WIDTH (DMA_WIDTH)
      ) dma_control_0 (
     //
     .Clk_i                (avalon_clk ),                                                          //        clock.clk
     .Rstn_i               (avmm_rstn   ),                                                          //       Resetn.reset_n
     .MsiInterface_i       (MsiInterface_wire),
     .RdDCSChipSelect_i    (dma_control_0_rddcs_slave_0_chipselect),                               //  RdDCS_slave.chipsele
     .RdDCSWrite_i         (dma_control_0_dcs_slave_0_write),                                      //             .write
     .RdDCSAddress_i       (dma_control_0_dcs_slave_0_address),                                    //             .address
     .RdDCSWriteData_i     (dma_control_0_dcs_slave_0_writedata),                                  //             .writedata
     .RdDCSByteEnable_i    (dma_control_0_dcs_slave_0_byteenable),                                 //             .byteenable
     .RdDCSWaitRequest_o   (dma_control_0_rddcs_slave_0_waitrequest),                              //             .waitrequest
     .RdDCSReadData_o      (dma_control_0_rddcs_slave_0_readdata),                                 //             .readdata
     .RdDCSRead_i          (dma_control_0_dcs_slave_0_read),                                       //             .read
     //
     .RdDTSChipSelect_i    (RdDTSChipSelect_i),                                                    //  RdDTS_slave.chipselect
     .RdDTSWrite_i         (RdDTSWrite_i),                                                         //             .write
     .RdDTSBurstCount_i    (RdDTSBurstCount_i),                                                    //             .burstcount
     .RdDTSAddress_i       (RdDTSAddress_i),                                                       //             .address
     .RdDTSWriteData_i     (RdDTSWriteData_i),                                                     //             .writedata
     .RdDTSWaitRequest_o   (RdDTSWaitRequest_o),                                                   //             .waitrequest
     //
     .RdDmaTxData_o        (dma_control_0_rddma_tx_data),                                          //     RdDMA_Tx.data
     .RdDmaTxValid_o       (dma_control_0_rddma_tx_valid),                                         //             .valid
     .RdDmaTxReady_i       (dma_control_0_rddma_tx_ready),                                         //             .ready
     .RdDmaRxData_i        (dut_rd_ast_tx_data),                                                   //     RdDMA_Rx.data
     .RdDmaRxValid_i       (dut_rd_ast_tx_valid),                                                  //             .valid
     //
     .RdDCMAddress_o       (RdDCMAddress_o),                                                       // RdDCM_Master.address
     .RdDCMWrite_o         (RdDCMWrite_o),                                                         //             .write
     .RdDCMWriteData_o     (RdDCMWriteData_o),                                                     //             .writedata
     .RdDCMRead_o          (RdDCMRead_o),                                                          //             .read
     .RdDCMByteEnable_o    (RdDCMByteEnable_o),                                                    //             .byteenable
     .RdDCMWaitRequest_i   (RdDCMWaitRequest_i),                                                   //             .waitrequest
     .RdDCMReadData_i      (RdDCMReadData_i),                                                      //             .readdata
     .RdDCMReadDataValid_i (RdDCMReadDataValid_i),                                                 //             .readdatavalid
     //
     .WrDCSChipSelect_i    (dma_control_0_wrdcs_slave_0_chipselect),                               //  WrDCS_slave.chipselect
     .WrDCSWrite_i         (dma_control_0_dcs_slave_0_write),                                      //             .write
     .WrDCSAddress_i       (dma_control_0_dcs_slave_0_address),                                    //             .address
     .WrDCSWriteData_i     (dma_control_0_dcs_slave_0_writedata),                                  //             .writedata
     .WrDCSByteEnable_i    (dma_control_0_dcs_slave_0_byteenable),                                 //             .byteenable
     .WrDCSWaitRequest_o   (dma_control_0_wrdcs_slave_0_waitrequest),                              //             .waitrequest
     .WrDCSReadData_o      (dma_control_0_wrdcs_slave_0_readdata),                                 //             .readdata
     .WrDCSRead_i          (dma_control_0_dcs_slave_0_read),                                       //             .read
     //
     .WrDTSChipSelect_i    (WrDTSChipSelect_i),                                                    //  WrDTS_slave.chipselect
     .WrDTSWrite_i         (WrDTSWrite_i),                                                         //             .write
     .WrDTSBurstCount_i    (WrDTSBurstCount_i),                                                    //             .burstcount
     .WrDTSAddress_i       (WrDTSAddress_i),                                                       //             .address
     .WrDTSWriteData_i     (WrDTSWriteData_i),                                                     //             .writedata
     .WrDTSWaitRequest_o   (WrDTSWaitRequest_o),                                                   //             .waitrequest
     //
     .WrDmaTxData_o        (dma_control_0_wrdma_tx_data),                                          //     WrDMA_Tx.data
     .WrDmaTxValid_o       (dma_control_0_wrdma_tx_valid),                                         //             .valid
     .WrDmaTxReady_i       (dma_control_0_wrdma_tx_ready),                                         //             .ready
     .WrDmaRxData_i        (dut_wr_ast_tx_data),                                                   //     WrDMA_Rx.data
     .WrDmaRxValid_i       (dut_wr_ast_tx_valid),                                                  //             .valid
     //
     .WrDCMAddress_o       (WrDCMAddress_o),                                                       // WrDCM_Master.address
     .WrDCMWrite_o         (WrDCMWrite_o),                                                         //             .write
     .WrDCMWriteData_o     (WrDCMWriteData_o),                                                     //             .writedata
     .WrDCMRead_o          (WrDCMRead_o),                                                          //             .read
     .WrDCMByteEnable_o    (WrDCMByteEnable_o),                                                    //             .byteenable
     .WrDCMWaitRequest_i   (WrDCMWaitRequest_i),                                                   //             .waitrequest
     .WrDCMReadData_i      (WrDCMReadData_i),                                                      //             .readdata
     .WrDCMReadDataValid_i (WrDCMReadDataValid_i)                                                 //             .readdatavalid
   );

    assign RdDmaTxData_o    = 32'h0;
    assign WrDmaTxData_o    = 32'h0;
    assign RxmAddress_0_o   =  {(bar0_type_hwtcl){1'b0}};
    assign RxmWriteData_0_o = 32'h0;
    assign RxmByteEnable_0_o = 4'h0;
    assign RdDmaRxReady_o    = 1'b0;
    assign RdDmaTxValid_o   = 1'b0;
    assign WrDmaRxReady_o   = 1'b0;
    assign WrDmaTxData_o    = 32'h0;
    assign WrDmaTxValid_o   = 1'b0;
    assign RxmWrite_0_o       = 1'b0;
    assign RxmRead_0_o        = 1'b0;


end
else
begin
  assign RxmWrite_0_o       = dma_control_0_dcs_slave_0_write;
  assign RxmRead_0_o        = dma_control_0_dcs_slave_0_read;
  assign dma_control_0_dcs_slave_0_readdatavalid = RxmReadDataValid_0_i;
  assign dma_control_0_dcs_slave_0_readdata = RxmReadData_0_i;
  assign RxmAddress_0_o     = dma_control_0_dcs_slave_0_address;
  assign RxmWriteData_0_o   = dma_control_0_dcs_slave_0_writedata;
  assign RxmByteEnable_0_o  = dma_control_0_dcs_slave_0_byteenable;
  assign dma_control_0_dcs_slave_0_waitrequest = RxmWaitRequest_0_i;

  assign RdDmaRxReady_o   = dma_control_0_rddma_tx_ready;
  assign dma_control_0_rddma_tx_data = RdDmaRxData_i;
  assign dma_control_0_rddma_tx_valid = RdDmaRxValid_i;
  assign RdDmaTxData_o    = dut_rd_ast_tx_data;
  assign RdDmaTxValid_o   = dut_rd_ast_tx_valid;

  assign WrDmaRxReady_o   = dma_control_0_wrdma_tx_ready;
  assign dma_control_0_wrdma_tx_data = WrDmaRxData_i;
  assign dma_control_0_wrdma_tx_valid = WrDmaRxValid_i;
  assign WrDmaTxData_o    = dut_wr_ast_tx_data;
  assign WrDmaTxValid_o   = dut_wr_ast_tx_valid;
end
endgenerate

//// instantiate the Avalon-MM bridge logic
assign MsiIntfc_o = MsiInterface_wire;
wire [9:0] app_resetn;
assign app_resetn = {avmm_rstn, avmm_rstn, avmm_rstn, avmm_rstn, avmm_rstn, avmm_rstn, avmm_rstn, avmm_rstn, avmm_rstn, avmm_rstn};

      altpcieav_256_app
       # (
         .DEVICE_FAMILY                  (INTENDED_DEVICE_FAMILY),
         .DMA_WIDTH                      (DMA_WIDTH             ),
         .DMA_BE_WIDTH                   (DMA_BE_WIDTH          ),
         .DMA_BRST_CNT_W                 (DMA_BRST_CNT_W        ),
         .RDDMA_AVL_ADDR_WIDTH           (rd_dma_size_mask),
         .WRDMA_AVL_ADDR_WIDTH           (wr_dma_size_mask),
         .BAR0_SIZE_MASK                 (bar0_size_mask_hwtcl  ),
         .BAR1_SIZE_MASK                 (bar1_size_mask_hwtcl  ),
         .BAR2_SIZE_MASK                 (bar2_size_mask_hwtcl  ),
         .BAR3_SIZE_MASK                 (bar3_size_mask_hwtcl  ),
         .BAR4_SIZE_MASK                 (bar4_size_mask_hwtcl  ),
         .BAR5_SIZE_MASK                 (bar5_size_mask_hwtcl  ),
         .BAR0_TYPE                      (bar0_type_hwtcl       ),
         .BAR1_TYPE                      (bar1_type_hwtcl       ),
         .BAR2_TYPE                      (bar2_type_hwtcl       ),
         .BAR3_TYPE                      (bar3_type_hwtcl       ),
         .BAR4_TYPE                      (bar4_type_hwtcl       ),
         .BAR5_TYPE                      (bar5_type_hwtcl       ),
         .TX_S_ADDR_WIDTH                (TX_S_ADDR_WIDTH       ),
         .dma_use_scfifo_ext             (dma_use_scfifo_ext_hwtcl),
         .enable_rxm_burst_hwtcl         (enable_rxm_burst_hwtcl),
         .enable_cra_hwtcl               (enable_cra_hwtcl),
         .WRDMA_VERSION_2                (WRDMA_VERSION_2)
       )
      altpcieav_256_app
       (
         .Clk_i                          ( avalon_clk            ),
         .Rstn_i                         ( app_resetn              ),
         .HipRxStReady_o                 ( rx_st_ready           ),
         .HipRxStMask_o                  ( rx_st_mask            ),
         .HipRxStData_i                  ( rx_st_data            ),
         .HipRxStBe_i                    ( rx_st_be              ),
         .HipRxStEmpty_i                 ( rx_st_empty           ),
         .HipRxStErr_i                   ( rx_st_err             ),
         .HipRxStSop_i                   ( rx_st_sop             ),
         .HipRxStEop_i                   ( rx_st_eop             ),
         .HipRxStValid_i                 ( rx_st_valid           ),
         .HipRxStBarDec1_i               ( rx_st_bar             ),
         .HipTxStReady_i                 ( tx_st_ready           ),
         .HipTxStData_o                  ( tx_st_data            ),
         .HipTxStSop_o                   ( tx_st_sop             ),
         .HipTxStEop_o                   ( tx_st_eop             ),
         .HipTxStEmpty_o                 ( tx_st_empty           ),
         .HipTxStValid_o                 ( tx_st_valid           ),
         .HipCplPending_o                ( cpl_pending           ),
         .AvWrDmaRead_o                  ( WrDmaRead_o           ),
         .AvWrDmaAddress_o               ( WrDmaAddress_o        ),
         .AvWrDmaBurstCount_o            ( WrDmaBurstCount_o     ),
         .AvWrDmaReadByteEnable_o        ( WrDmaByteEnable_o     ),
         .AvWrDmaWaitRequest_i           ( WrDmaWaitRequest_i    ),
         .AvWrDmaReadDataValid_i         ( WrDmaReadDataValid_i  ),
         .AvWrDmaReadData_i              ( WrDmaReadData_i       ),
         .AvRdDmaWrite_o                 ( RdDmaWrite_o          ),
         .AvRdDmaAddress_o               ( RdDmaAddress_o        ),
         .AvRdDmaWriteData_o             ( RdDmaWriteData_o      ),
         .AvRdDmaBurstCount_o            ( RdDmaBurstCount_o     ),
         .AvRdDmaWriteEnable_o           ( RdDmaWriteEnable_o    ),
         .AvRdDmaWaitRequest_i           ( RdDmaWaitRequest_i    ),
         .AvRxmWrite_0_o                 ( dma_control_0_dcs_slave_0_write       ),
         .AvRxmAddress_0_o               ( dma_control_0_dcs_slave_0_address     ),
         .AvRxmWriteData_0_o             ( dma_control_0_dcs_slave_0_writedata   ),
         .AvRxmByteEnable_0_o            ( dma_control_0_dcs_slave_0_byteenable  ),
         .AvRxmWaitRequest_0_i           ( dma_control_0_dcs_slave_0_waitrequest ),
         .AvRxmRead_0_o                  ( dma_control_0_dcs_slave_0_read),
         .AvRxmReadData_0_i              ( dma_control_0_dcs_slave_0_readdata),
         .AvRxmReadDataValid_0_i         ( dma_control_0_dcs_slave_0_readdatavalid),
         .AvRxmWrite_1_o                 ( RxmWrite_1_o          ),
         .AvRxmAddress_1_o               ( RxmAddress_1_o        ),
         .AvRxmWriteData_1_o             ( RxmWriteData_1_o      ),
         .AvRxmByteEnable_1_o            ( RxmByteEnable_1_o     ),
         .AvRxmWaitRequest_1_i           ( RxmWaitRequest_1_i    ),
         .AvRxmRead_1_o                  ( RxmRead_1_o           ),
         .AvRxmReadData_1_i              ( RxmReadData_1_i       ),
         .AvRxmReadDataValid_1_i         ( RxmReadDataValid_1_i  ),
         .AvRxmWrite_2_o                 ( RxmWrite_2_o          ),
         .AvRxmAddress_2_o               ( RxmAddress_2_o        ),
         .AvRxmWriteData_2_o             ( RxmWriteData_2_o      ),
         .AvRxmByteEnable_2_o            ( RxmByteEnable_2_o     ),
         .AvRxmWaitRequest_2_i           ( RxmWaitRequest_2_i    ),
         .AvRxmRead_2_o                  ( RxmRead_2_o           ),
         .AvRxmReadData_2_i              ( RxmReadData_2_i       ),
         .AvRxmReadDataValid_2_i         ( RxmReadDataValid_2_i  ),
         .AvRxmWrite_3_o                 ( RxmWrite_3_o          ),
         .AvRxmAddress_3_o               ( RxmAddress_3_o        ),
         .AvRxmWriteData_3_o             ( RxmWriteData_3_o      ),
         .AvRxmByteEnable_3_o            ( RxmByteEnable_3_o     ),
         .AvRxmWaitRequest_3_i           ( RxmWaitRequest_3_i    ),
         .AvRxmRead_3_o                  ( RxmRead_3_o           ),
         .AvRxmReadData_3_i              ( RxmReadData_3_i       ),
         .AvRxmReadDataValid_3_i         ( RxmReadDataValid_3_i  ),
         .AvRxmWrite_4_o                 ( RxmWrite_4_o          ),
         .AvRxmAddress_4_o               ( RxmAddress_4_o        ),
         .AvRxmWriteData_4_o             ( RxmWriteData_4_o      ),
         .AvRxmByteEnable_4_o            ( RxmByteEnable_4_o     ),
         .AvRxmWaitRequest_4_i           ( RxmWaitRequest_4_i    ),
         .AvRxmRead_4_o                  ( RxmRead_4_o           ),
         .AvRxmReadData_4_i              ( RxmReadData_4_i       ),
         .AvRxmReadDataValid_4_i         ( RxmReadDataValid_4_i  ),
         .AvRxmWrite_5_o                 ( RxmWrite_5_o          ),
         .AvRxmAddress_5_o               ( RxmAddress_5_o        ),
         .AvRxmWriteData_5_o             ( RxmWriteData_5_o      ),
         .AvRxmByteEnable_5_o            ( RxmByteEnable_5_o     ),
         .AvRxmWaitRequest_5_i           ( RxmWaitRequest_5_i    ),
         .AvRxmRead_5_o                  ( RxmRead_5_o           ),
         .AvRxmReadData_5_i              ( RxmReadData_5_i       ),
         .AvRxmReadDataValid_5_i         ( RxmReadDataValid_5_i  ),

         .AvHPRxmWrite_o(HPRxmWrite_o),
         .AvHPRxmAddress_o(HPRxmAddress_o),
         .AvHPRxmWriteData_o(HPRxmWriteData_o),
         .AvHPRxmByteEnable_o(HPRxmByteEnable_o),
         .AvHPRxmBurstCount_o(HPRxmBurstCount_o),
         .AvHPRxmWaitRequest_i(HPRxmWaitRequest_i),
         .AvHPRxmRead_o(HPRxmRead_o),
         .AvHPRxmReadData_i(HPRxmReadData_i),
         .AvHPRxmReadDataValid_i(HPRxmReadDataValid_i),

         .AvTxsWrite_i                   ( TxsWrite_i            ),
         .AvTxsAddress_i                 ( TxsAddress_i          ),
         .AvTxsWriteData_i               ( TxsWriteData_i        ),
         .AvTxsByteEnable_i              ( TxsByteEnable_i       ),
         .AvTxsWaitRequest_o             ( TxsWaitRequest_o      ),
         .AvTxsRead_i                    ( TxsRead_i             ),
         .AvTxsReadData_o                ( TxsReadData_o         ),
         .AvTxsReadDataValid_o           ( TxsReadDataValid_o    ),
         .AvTxsChipSelect_i              ( TxsChipSelect_i       ),
         .AvCraChipSelect_i              ( CraChipSelect_i       ),
         .AvCraRead_i                    ( CraRead             ),
         .AvCraWrite_i                   ( CraWrite            ),
         .AvCraWriteData_i               ( CraWriteData_i        ),
         .AvCraAddress_i                 ( CraAddress_i          ),
         .AvCraByteEnable_i              ( CraByteEnable_i       ),
         .AvCraReadData_o                ( CraReadData_o         ),
         .AvCraWaitRequest_o             ( CraWaitRequest_o      ),
         .AvRdDmaRxReady_o               (dma_control_0_rddma_tx_ready),
         .AvRdDmaRxData_i                (dma_control_0_rddma_tx_data ),
         .AvRdDmaRxValid_i               (dma_control_0_rddma_tx_valid),
         .AvRdDmaTxData_o                (dut_rd_ast_tx_data          ),
         .AvRdDmaTxValid_o               (dut_rd_ast_tx_valid         ),
         .AvWrDmaRxReady_o               (dma_control_0_wrdma_tx_ready),
         .AvWrDmaRxData_i                (dma_control_0_wrdma_tx_data ),
         .AvWrDmaRxValid_i               (dma_control_0_wrdma_tx_valid),
         .AvWrDmaTxData_o                (dut_wr_ast_tx_data          ),
         .AvWrDmaTxValid_o               (dut_wr_ast_tx_valid         ),
         .AvMsiIntfc_o                   ( MsiInterface_wire          ),
         .AvMsixIntfc_o                  ( MsixIntfc_o           ),
         .HipCfgAddr_i                   ( tl_cfg_add            ),
         .HipCfgCtl_i                    ( tl_cfg_ctl            ),
         .TLCfgSts_i                     ( tl_cfg_sts[46:31]     ),
         .Ltssm_i(ltssmstate),
         .CurrentSpeed_i(currentspeed),
         .LaneAct_i(lane_act),
         .ko_cpl_spc_header(ko_cpl_spc_header),
         .ko_cpl_spc_data(ko_cpl_spc_data)
       );

// Intx export

assign avalon_clk = coreclkout;



  //////////////// SIMULATION-ONLY CONTENTS
   //synthesis translate_off
   initial begin
      reset_status_sync_pldclk_r = 3'b111;
   end
  //synthesis translate_on

   always @(posedge coreclkout or posedge reset_status_int) begin
      if (reset_status_int == 1'b1) begin
         reset_status_sync_pldclk_r <= 3'b111;
      end
      else begin
         reset_status_sync_pldclk_r[0] <= 1'b0;
         reset_status_sync_pldclk_r[1] <= reset_status_sync_pldclk_r[0];
         reset_status_sync_pldclk_r[2] <= reset_status_sync_pldclk_r[1];
      end
   end
   assign reset_status_sync_pldclk = reset_status_sync_pldclk_r[2];

assign reset_status = avmm_rstn;

   altpcierd_hip_rs rs_hip (
      .dlup_exit     (dlup_exit),
      .hotrst_exit   (~reset_status_sync_pldclk),
      .l2_exit       (l2_exit),
      .ltssm         (ltssmstate),
      .npor          ((serdes_pll_locked==1'b0)?1'b0:
                      (avmm_dma_bridge_pll_coreclkout_locked==1'b0)?1'b0:
                      (~reset_status_sync_pldclk) & pld_clk_inuse),
      .pld_clk       (coreclkout),
      .test_sim      (1'b1),
      .app_rstn      (avmm_rstn)
   );

assign pld_core_ready =  serdes_pll_locked && avmm_dma_bridge_pll_coreclkout_locked;

generate begin : g_coreclkout
   if ((set_pll_coreclkout_cin_hwtcl == "NA" )||(set_pll_coreclkout_cout_hwtcl == "NA" )) begin

      // SIMULATION CONTENTS
      //synthesis translate_off
         assign coreclkout = coreclkout_hip;
      // END SIMULATION CONTENTS
      //synthesis translate_on

      assign avmm_dma_bridge_pll_coreclkout_locked = 1'b1;
      //synthesis read_comments_as_HDL on
      //global u_global_buffer_coreclkout (.in(coreclkout_hip), .out(coreclkout));
      //synthesis read_comments_as_HDL off

      assign pld_clk_hip   = coreclkout;

   end
   else begin
      // SIMULATION CONTENTS
      //synthesis translate_off
         assign coreclkout                            = coreclkout_hip;
         assign avmm_dma_bridge_pll_coreclkout_locked = 1'b1;
      // END SIMULATION CONTENTS
      //synthesis translate_on
      assign pld_clk_hip   = coreclkout;
      //synthesis read_comments_as_HDL on
      //  altera_pll #(
      //          .fractional_vco_multiplier("false"),
      //          .reference_clock_frequency(set_pll_coreclkout_cin_hwtcl),
      //          .operation_mode("direct"),
      //          .number_of_clocks(1),
      //          .output_clock_frequency0(set_pll_coreclkout_cout_hwtcl),
      //          .phase_shift0("0 ps"),
      //          .duty_cycle0(50),
      //          .output_clock_frequency1("0 MHz"),
      //          .phase_shift1("0 ps"),
      //          .duty_cycle1(50),
      //          .output_clock_frequency2("0 MHz"),
      //          .phase_shift2("0 ps"),
      //          .duty_cycle2(50),
      //          .output_clock_frequency3("0 MHz"),
      //          .phase_shift3("0 ps"),
      //          .duty_cycle3(50),
      //          .output_clock_frequency4("0 MHz"),
      //          .phase_shift4("0 ps"),
      //          .duty_cycle4(50),
      //          .output_clock_frequency5("0 MHz"),
      //          .phase_shift5("0 ps"),
      //          .duty_cycle5(50),
      //          .output_clock_frequency6("0 MHz"),
      //          .phase_shift6("0 ps"),
      //          .duty_cycle6(50),
      //          .output_clock_frequency7("0 MHz"),
      //          .phase_shift7("0 ps"),
      //          .duty_cycle7(50),
      //          .output_clock_frequency8("0 MHz"),
      //          .phase_shift8("0 ps"),
      //          .duty_cycle8(50),
      //          .output_clock_frequency9("0 MHz"),
      //          .phase_shift9("0 ps"),
      //          .duty_cycle9(50),
      //          .output_clock_frequency10("0 MHz"),
      //          .phase_shift10("0 ps"),
      //          .duty_cycle10(50),
      //          .output_clock_frequency11("0 MHz"),
      //          .phase_shift11("0 ps"),
      //          .duty_cycle11(50),
      //          .output_clock_frequency12("0 MHz"),
      //          .phase_shift12("0 ps"),
      //          .duty_cycle12(50),
      //          .output_clock_frequency13("0 MHz"),
      //          .phase_shift13("0 ps"),
      //          .duty_cycle13(50),
      //          .output_clock_frequency14("0 MHz"),
      //          .phase_shift14("0 ps"),
      //          .duty_cycle14(50),
      //          .output_clock_frequency15("0 MHz"),
      //          .phase_shift15("0 ps"),
      //          .duty_cycle15(50),
      //          .output_clock_frequency16("0 MHz"),
      //          .phase_shift16("0 ps"),
      //          .duty_cycle16(50),
      //          .output_clock_frequency17("0 MHz"),
      //          .phase_shift17("0 ps"),
      //          .duty_cycle17(50),
      //          .pll_type("General"),
      //          .pll_subtype("General")
      //  ) pll_coreclkout_hip (
      //          .rst    (reset_status),
      //          .outclk (coreclkout),
      //          .locked (avmm_dma_bridge_pll_coreclkout_locked),
      //          .fboutclk       ( ),
      //          .fbclk  (1'b0),
      //          .refclk (coreclkout_hip)
      //  );
      //synthesis read_comments_as_HDL off
   end
end
endgenerate


assign reservedin[31:0] = {22'h0,tx_cons_cred_sel ,9'h0};

endmodule
