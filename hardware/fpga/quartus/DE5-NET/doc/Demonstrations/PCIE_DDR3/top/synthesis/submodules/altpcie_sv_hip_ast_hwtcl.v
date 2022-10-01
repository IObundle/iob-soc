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

module altpcie_sv_hip_ast_hwtcl # (

      parameter pll_refclk_freq_hwtcl                             = "100 MHz",
      parameter set_pld_clk_x1_625MHz_hwtcl                       = 0,
      parameter enable_slot_register_hwtcl                        = 0,
      parameter port_type_hwtcl                                   = "Native endpoint",
      parameter bypass_cdc_hwtcl                                  = "false",
      parameter slotclkcfg_hwtcl                                  = 1,
      parameter enable_rx_buffer_checking_hwtcl                   = "false",
      parameter single_rx_detect_hwtcl                            = 0,
      parameter use_crc_forwarding_hwtcl                          = 0,
      parameter gen123_lane_rate_mode_hwtcl                       = "gen1",
      parameter lane_mask_hwtcl                                   = "x4",
      parameter in_cvp_mode_hwtcl                                 = 0,
      parameter disable_link_x2_support_hwtcl                     = "false",
      parameter wrong_device_id_hwtcl                             = "disable",
      parameter data_pack_rx_hwtcl                                = "disable",
      parameter ast_width_hwtcl                                   = "Avalon-ST 64-bit",
      parameter use_ast_parity                                    = 0,
      parameter ltssm_1ms_timeout_hwtcl                           = "disable",
      parameter ltssm_freqlocked_check_hwtcl                      = "disable",
      parameter gen3_rxfreqlock_counter_hwtcl                     = 0,
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
      parameter indicator_hwtcl                                   = 0,
      parameter slot_power_scale_hwtcl                            = 0,
      parameter enable_l0s_aspm_hwtcl                             = "true",
      parameter enable_l1_aspm_hwtcl                              = "false",
      parameter l1_exit_latency_sameclock_hwtcl                   = 0,
      parameter l1_exit_latency_diffclock_hwtcl                   = 0,
      parameter hot_plug_support_hwtcl                            = 0,
      parameter slot_power_limit_hwtcl                            = 0,
      parameter slot_number_hwtcl                                 = 0,
      parameter diffclock_nfts_count_hwtcl                        = 128,
      parameter sameclock_nfts_count_hwtcl                        = 128,
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
      parameter l2_async_logic_hwtcl                              = "disable",
      parameter aspm_config_management_hwtcl                      = "true",
      parameter atomic_op_routing_hwtcl                           = "false",
      parameter atomic_op_completer_32bit_hwtcl                   = "false",
      parameter atomic_op_completer_64bit_hwtcl                   = "false",
      parameter cas_completer_128bit_hwtcl                        = "false",
      parameter ltr_mechanism_hwtcl                               = "false",
      parameter tph_completer_hwtcl                               = "false",
      parameter extended_format_field_hwtcl                       = "false",
      parameter atomic_malformed_hwtcl                            = "true",
      parameter flr_capability_hwtcl                              = "false",
      parameter enable_adapter_half_rate_mode_hwtcl               = "false",
      parameter vc0_clk_enable_hwtcl                              = "true",
      parameter register_pipe_signals_hwtcl                       = "false",
      parameter bar0_io_space_hwtcl                               = "Disabled",
      parameter bar0_64bit_mem_space_hwtcl                        = "Enabled",
      parameter bar0_prefetchable_hwtcl                           = "Enabled",
      parameter bar0_size_mask_hwtcl                              = 28,
      parameter bar1_io_space_hwtcl                               = "Disabled",
      parameter bar1_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar1_prefetchable_hwtcl                           = "Disabled",
      parameter bar1_size_mask_hwtcl                              = 0,
      parameter bar2_io_space_hwtcl                               = "Disabled",
      parameter bar2_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar2_prefetchable_hwtcl                           = "Disabled",
      parameter bar2_size_mask_hwtcl                              = 0,
      parameter bar3_io_space_hwtcl                               = "Disabled",
      parameter bar3_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar3_prefetchable_hwtcl                           = "Disabled",
      parameter bar3_size_mask_hwtcl                              = 0,
      parameter bar4_io_space_hwtcl                               = "Disabled",
      parameter bar4_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar4_prefetchable_hwtcl                           = "Disabled",
      parameter bar4_size_mask_hwtcl                              = 0,
      parameter bar5_io_space_hwtcl                               = "Disabled",
      parameter bar5_64bit_mem_space_hwtcl                        = "Disabled",
      parameter bar5_prefetchable_hwtcl                           = "Disabled",
      parameter bar5_size_mask_hwtcl                              = 0,
      parameter expansion_base_address_register_hwtcl             = 0,
      parameter io_window_addr_width_hwtcl                        = 0,
      parameter prefetchable_mem_window_addr_width_hwtcl          = 0,
      parameter skp_os_gen3_count_hwtcl                           = 0,
      parameter tx_cdc_almost_empty_hwtcl                         = 5,
      parameter rx_cdc_almost_full_hwtcl                          = 12,
      parameter tx_cdc_almost_full_hwtcl                          = 11,
      parameter rx_l0s_count_idl_hwtcl                            = 0,
      parameter cdc_dummy_insert_limit_hwtcl                      = 11,
      parameter ei_delay_powerdown_count_hwtcl                    = 10,
      parameter millisecond_cycle_count_hwtcl                     = 124250,
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
      parameter cpl_spc_header_hwtcl                              = 112,
      parameter cpl_spc_data_hwtcl                                = 448,
      parameter retry_buffer_last_active_address_hwtcl            = 2047,
      parameter reconfig_to_xcvr_width                            = 350,
      parameter reconfig_from_xcvr_width                          = 230,
      parameter hip_hard_reset_hwtcl                              = 1,
      parameter reserved_debug_hwtcl                              = 0,
      parameter gen3_skip_ph2_ph3_hwtcl                           = 1,
      parameter gen3_dcbal_en_hwtcl                               = 1,
      parameter g3_bypass_equlz_hwtcl                             = 1,

      parameter use_tx_cons_cred_sel_hwtcl                        = 0,
      parameter enable_pipe32_sim_hwtcl                           = 0,
      parameter enable_tl_only_sim_hwtcl                          = 0,
      parameter use_atx_pll_hwtcl                                 = 0,
      parameter hip_reconfig_hwtcl                                = 0,
      parameter port_width_data_hwtcl                             = 256,
      parameter port_width_be_hwtcl                               = 32,
      parameter use_config_bypass_hwtcl                           = 0,
      parameter use_pci_ext_hwtcl                                 = 0,
      parameter use_pcie_ext_hwtcl                                = 0,
      parameter multiple_packets_per_cycle_hwtcl                  = 0,
      parameter vsec_id_hwtcl                                     = 0,
      parameter user_id_hwtcl                                     = 0,
      parameter vsec_rev_hwtcl                                    = 0,
      parameter full_swing_hwtcl                                  = 35,
      parameter low_latency_mode_hwtcl                            = 0,


      parameter hwtcl_override_g3rxcoef                       = 0, // When 1 use gen3 param from HWTCL, else use default

      parameter gen3_coeff_1_hwtcl                            = 7,
      parameter gen3_coeff_1_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_1_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_1_nxtber_more_ptr_hwtcl            = 1,
      parameter gen3_coeff_1_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_1_nxtber_less_ptr_hwtcl            = 1,
      parameter gen3_coeff_1_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_1_reqber_hwtcl                     = 0,
      parameter gen3_coeff_1_ber_meas_hwtcl                   = 2,

      parameter gen3_coeff_2_hwtcl                            = 0,
      parameter gen3_coeff_2_sel_hwtcl                        = "preset_2",
      parameter gen3_coeff_2_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_2_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_2_nxtber_more_hwtcl                = "g3_coeff_2_nxtber_more",
      parameter gen3_coeff_2_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_2_nxtber_less_hwtcl                = "g3_coeff_2_nxtber_less",
      parameter gen3_coeff_2_reqber_hwtcl                     = 0,
      parameter gen3_coeff_2_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_3_hwtcl                            = 0,
      parameter gen3_coeff_3_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_3_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_3_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_3_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_3_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_3_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_3_reqber_hwtcl                     = 0,
      parameter gen3_coeff_3_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_4_hwtcl                            = 0,
      parameter gen3_coeff_4_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_4_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_4_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_4_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_4_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_4_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_4_reqber_hwtcl                     = 0,
      parameter gen3_coeff_4_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_5_hwtcl                            = 0,
      parameter gen3_coeff_5_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_5_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_5_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_5_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_5_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_5_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_5_reqber_hwtcl                     = 0,
      parameter gen3_coeff_5_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_6_hwtcl                            = 0,
      parameter gen3_coeff_6_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_6_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_6_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_6_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_6_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_6_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_6_reqber_hwtcl                     = 0,
      parameter gen3_coeff_6_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_7_hwtcl                            = 0,
      parameter gen3_coeff_7_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_7_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_7_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_7_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_7_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_7_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_7_reqber_hwtcl                     = 0,
      parameter gen3_coeff_7_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_8_hwtcl                            = 0,
      parameter gen3_coeff_8_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_8_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_8_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_8_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_8_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_8_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_8_reqber_hwtcl                     = 0,
      parameter gen3_coeff_8_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_9_hwtcl                            = 0,
      parameter gen3_coeff_9_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_9_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_9_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_9_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_9_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_9_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_9_reqber_hwtcl                     = 0,
      parameter gen3_coeff_9_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_10_hwtcl                            = 0,
      parameter gen3_coeff_10_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_10_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_10_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_10_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_10_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_10_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_10_reqber_hwtcl                     = 0,
      parameter gen3_coeff_10_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_11_hwtcl                            = 0,
      parameter gen3_coeff_11_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_11_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_11_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_11_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_11_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_11_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_11_reqber_hwtcl                     = 0,
      parameter gen3_coeff_11_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_12_hwtcl                            = 0,
      parameter gen3_coeff_12_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_12_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_12_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_12_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_12_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_12_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_12_reqber_hwtcl                     = 0,
      parameter gen3_coeff_12_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_13_hwtcl                            = 0,
      parameter gen3_coeff_13_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_13_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_13_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_13_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_13_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_13_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_13_reqber_hwtcl                     = 0,
      parameter gen3_coeff_13_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_14_hwtcl                            = 0,
      parameter gen3_coeff_14_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_14_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_14_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_14_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_14_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_14_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_14_reqber_hwtcl                     = 0,
      parameter gen3_coeff_14_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_15_hwtcl                            = 0,
      parameter gen3_coeff_15_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_15_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_15_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_15_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_15_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_15_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_15_reqber_hwtcl                     = 0,
      parameter gen3_coeff_15_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_16_hwtcl                            = 0,
      parameter gen3_coeff_16_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_16_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_16_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_16_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_16_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_16_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_16_reqber_hwtcl                     = 0,
      parameter gen3_coeff_16_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_17_hwtcl                            = 0,
      parameter gen3_coeff_17_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_17_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_17_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_17_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_17_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_17_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_17_reqber_hwtcl                     = 0,
      parameter gen3_coeff_17_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_18_hwtcl                            = 0,
      parameter gen3_coeff_18_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_18_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_18_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_18_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_18_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_18_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_18_reqber_hwtcl                     = 0,
      parameter gen3_coeff_18_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_19_hwtcl                            = 0,
      parameter gen3_coeff_19_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_19_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_19_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_19_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_19_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_19_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_19_reqber_hwtcl                     = 0,
      parameter gen3_coeff_19_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_20_hwtcl                            = 0,
      parameter gen3_coeff_20_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_20_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_20_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_20_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_20_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_20_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_20_reqber_hwtcl                     = 0,
      parameter gen3_coeff_20_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_21_hwtcl                            = 0,
      parameter gen3_coeff_21_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_21_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_21_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_21_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_21_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_21_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_21_reqber_hwtcl                     = 0,
      parameter gen3_coeff_21_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_22_hwtcl                            = 0,
      parameter gen3_coeff_22_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_22_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_22_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_22_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_22_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_22_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_22_reqber_hwtcl                     = 0,
      parameter gen3_coeff_22_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_23_hwtcl                            = 0,
      parameter gen3_coeff_23_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_23_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_23_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_23_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_23_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_23_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_23_reqber_hwtcl                     = 0,
      parameter gen3_coeff_23_ber_meas_hwtcl                   = 0,

      parameter gen3_coeff_24_hwtcl                            = 0,
      parameter gen3_coeff_24_sel_hwtcl                        = "preset_1",
      parameter gen3_coeff_24_preset_hint_hwtcl                = 0,
      parameter gen3_coeff_24_nxtber_more_ptr_hwtcl            = 0,
      parameter gen3_coeff_24_nxtber_more_hwtcl                = "g3_coeff_1_nxtber_more",
      parameter gen3_coeff_24_nxtber_less_ptr_hwtcl            = 0,
      parameter gen3_coeff_24_nxtber_less_hwtcl                = "g3_coeff_1_nxtber_less",
      parameter gen3_coeff_24_reqber_hwtcl                     = 0,
      parameter gen3_coeff_24_ber_meas_hwtcl                   = 0,

      parameter hwtcl_override_g3txcoef                  = 0, // When 1 use gen3 param from HWTCL, else use default
      parameter gen3_preset_coeff_1_hwtcl                      = 0,
      parameter gen3_preset_coeff_2_hwtcl                      = 0,
      parameter gen3_preset_coeff_3_hwtcl                      = 0,
      parameter gen3_preset_coeff_4_hwtcl                      = 0,
      parameter gen3_preset_coeff_5_hwtcl                      = 0,
      parameter gen3_preset_coeff_6_hwtcl                      = 0,
      parameter gen3_preset_coeff_7_hwtcl                      = 0,
      parameter gen3_preset_coeff_8_hwtcl                      = 0,
      parameter gen3_preset_coeff_9_hwtcl                      = 0,
      parameter gen3_preset_coeff_10_hwtcl                     = 0,
      parameter gen3_preset_coeff_11_hwtcl                     = 0,
      parameter gen3_low_freq_hwtcl                            = 0,
      parameter gen3_full_swing_hwtcl                          = 35,


      parameter hwtcl_override_g2_txvod                        = 0, // When 1 use gen3 param from HWTCL, else use default
      parameter rpre_emph_a_val_hwtcl                          = 9 ,
      parameter rpre_emph_b_val_hwtcl                          = 0 ,
      parameter rpre_emph_c_val_hwtcl                          = 16,
      parameter rpre_emph_d_val_hwtcl                          = 11,
      parameter rpre_emph_e_val_hwtcl                          = 5 ,
      parameter rvod_sel_a_val_hwtcl                           = 42,
      parameter rvod_sel_b_val_hwtcl                           = 38,
      parameter rvod_sel_c_val_hwtcl                           = 38,
      parameter rvod_sel_d_val_hwtcl                           = 38,
      parameter rvod_sel_e_val_hwtcl                           = 15,

      parameter ACDS_VERSION_HWTCL                             = "",

      parameter hip_tag_checking_hwtcl                         = 1,
      parameter enable_power_on_rst_pulse_hwtcl                = 0,
      parameter enable_pcisigtest_hwtcl                        = 0,

      parameter cvp_rate_sel_hwtcl                             = "full_rate",
      parameter cvp_data_compressed_hwtcl                      = "false",
      parameter cvp_data_encrypted_hwtcl                       = "false",
      parameter cvp_mode_reset_hwtcl                           = "false",
      parameter cvp_clk_reset_hwtcl                            = "false",
      parameter use_cvp_update_core_pof_hwtcl                  = 0,


      parameter cseb_cpl_status_during_cvp_hwtcl               = "config_retry_status",
      parameter core_clk_sel_hwtcl                             = "pld_clk",
      parameter fixed_preset_on                                = 0,
      parameter g3_dis_rx_use_prst_hwtcl                       = "true",
      parameter g3_dis_rx_use_prst_ep_hwtcl                    = "false",

      parameter tlp_inspector_hwtcl                            = 0,
      parameter tlp_inspector_use_signal_probe_hwtcl           = 0,
      parameter tlp_insp_trg_dw0_hwtcl                         = 1,
      parameter tlp_insp_trg_dw1_hwtcl                         = 0,
      parameter tlp_insp_trg_dw2_hwtcl                         = 0,
      parameter tlp_insp_trg_dw3_hwtcl                         = 0,
      parameter pcie_inspector_hwtcl                           = 0
) (
      // Control signals
      input  [31 : 0]       test_in,
      input                 simu_mode_pipe,          // When 1'b1 indicate running DUT under pipe simulation
      input  [31 : 0]       reservedin,

      // Reset signals
      input                 pin_perst,
      input                 npor,
      output                reset_status,
      output                serdes_pll_locked,
      output                pld_clk_inuse,
      input                 pld_core_ready,
      output                testin_zero,

      // Clock
      input                 pld_clk,

      // Serdes related
      input                 refclk,

      // Reconfig GXB
      input                [reconfig_to_xcvr_width-1:0]   reconfig_to_xcvr,
      output               [reconfig_from_xcvr_width-1:0] reconfig_from_xcvr,
      output               fixedclk_locked,

      // HIP control signals
      input  [4 : 0]        hpg_ctrler,

      // Input PIPE simulation _ext for simulation only
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

      //TL BFM Ports
      output [1000 : 0]    tlbfm_in,
      input  [1000 : 0]    tlbfm_out,


      // Application signals inputs
      input  [4 : 0]        aer_msi_num,
      input                 app_int_sts,
      input  [4 : 0]        app_msi_num,
      input                 app_msi_req,
      input  [2 : 0]        app_msi_tc,
      input  [4 : 0]        pex_msi_num,

      input  [11 : 0]       lmi_addr,
      input  [31 : 0]       lmi_din,
      input                 lmi_rden,
      input                 lmi_wren,
      input                 pm_auxpwr,
      input  [9 : 0]        pm_data,
      input                 pme_to_cr,
      input                 pm_event,
      input                 rx_st_mask,
      input                 rx_st_ready,

      input [port_width_data_hwtcl-1 : 0]             tx_st_data,
      input [1 :0]                                    tx_st_empty,
      input [multiple_packets_per_cycle_hwtcl :0]     tx_st_eop,
      input [multiple_packets_per_cycle_hwtcl :0]     tx_st_err,
      input [multiple_packets_per_cycle_hwtcl :0]     tx_st_sop,
      input [port_width_be_hwtcl-1 :0]                tx_st_parity,
      input [multiple_packets_per_cycle_hwtcl :0]     tx_st_valid,

      input  [6 :0]         cpl_err,
      input                 cpl_pending,


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
      output                txdeemph0,
      output                txdeemph1,
      output                txdeemph2,
      output                txdeemph3,
      output                txdeemph4,
      output                txdeemph5,
      output                txdeemph6,
      output                txdeemph7,
      output                txswing0,
      output                txswing1,
      output                txswing2,
      output                txswing3,
      output                txswing4,
      output                txswing5,
      output                txswing6,
      output                txswing7,
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


      // Output HIP Status signals
      output                coreclkout_hip,
      output [1 : 0]        currentspeed,
      output                derr_cor_ext_rcv,
      output                derr_cor_ext_rpl,
      output                derr_rpl,
      output                rx_par_err ,
      output [1:0]          tx_par_err ,
      output                cfg_par_err,
      output                dlup,
      output                dlup_exit,
      output                ev128ns,
      output                ev1us,
      output                hotrst_exit,
      output [3 : 0]        int_status,
      output                l2_exit,
      output [3 : 0]        lane_act,
      output [4 : 0]        ltssmstate,
      output [7 :0]         ko_cpl_spc_header,
      output [11 :0]        ko_cpl_spc_data,
      output                rxfc_cplbuf_ovf,

      // Output Application interface
      output                serr_out,
      output                app_int_ack,
      output                app_msi_ack,
      output                lmi_ack,
      output [31 : 0]       lmi_dout,
      output                pme_to_sr,

      output [7 : 0]        rx_st_bar,

      output [port_width_be_hwtcl-1 : 0]              rx_st_be,
      output [port_width_be_hwtcl-1 : 0]              rx_st_parity,
      output [port_width_data_hwtcl-1 : 0]            rx_st_data,
      output [multiple_packets_per_cycle_hwtcl:0]     rx_st_sop,
      output [multiple_packets_per_cycle_hwtcl:0]     rx_st_valid,
      output [1:0]                                    rx_st_empty,
      output [multiple_packets_per_cycle_hwtcl:0]     rx_st_eop,
      output [multiple_packets_per_cycle_hwtcl:0]     rx_st_err,

      input                 tx_cons_cred_sel,
      output [3 : 0]        tl_cfg_add,
      output [31 : 0]       tl_cfg_ctl,
      output [52 : 0]       tl_cfg_sts,
      output [11 : 0]       tx_cred_datafccp,
      output [11 : 0]       tx_cred_datafcnp,
      output [11 : 0]       tx_cred_datafcp,
      output [5 : 0]        tx_cred_fchipcons,
      output [5 : 0]        tx_cred_fcinfinite,
      output [7 : 0]        tx_cred_hdrfccp,
      output [7 : 0]        tx_cred_hdrfcnp,
      output [7 : 0]        tx_cred_hdrfcp,
      output                tx_st_ready,
      //
      // HIP Reconfig
      input                               hip_reconfig_rst_n,      // DPRIO reset
      input                               hip_reconfig_clk,        // DPRIO clock
      input                               hip_reconfig_write,      // write enable input
      input                               hip_reconfig_read,       // read enable input
      input   [1:0]                       hip_reconfig_byte_en,    // Byte enable
      input   [9:0]                       hip_reconfig_address,    // address input
      input   [15:0]                      hip_reconfig_writedata,  // write data input
      output  [15:0]                      hip_reconfig_readdata,   // Read data output
      input                               ser_shift_load,          // 1'b1=shift in data from si into scan flop
                                                                   // 1'b0=load data from writedata into scan flop
                                                                   // Toggle 1->0 (10 clock cycle) 0->1 cp CSR  bits into DPRIO  Register
      input                               interface_sel,           // Interface selection inputs
                                                                   // 1'b1: select CSR as a source for CRAM
                                                                   // After toggling ser_shift_load
                                                                   // de-assert interface_sel 1-->0
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


      // Config. Bypass
      input  [12:0]     cfgbp_link2csr,
      input             cfgbp_comclk_reg,
      input             cfgbp_extsy_reg,
      input  [2:0]      cfgbp_max_pload,
      input             cfgbp_tx_ecrcgen,
      input             cfgbp_rx_ecrchk,
      input  [7:0]      cfgbp_secbus,
      input             cfgbp_linkcsr_bit0,
      input             cfgbp_tx_req_pm,
      input  [2:0]      cfgbp_tx_typ_pm,
      input  [3:0]      cfgbp_req_phypm,
      input  [3:0]      cfgbp_req_phycfg,
      input  [6:0]      cfgbp_vc0_tcmap_pld,
      input             cfgbp_inh_dllp,
      input             cfgbp_inh_tx_tlp,
      input             cfgbp_req_wake,
      input  [1:0]      cfgbp_link3_ctl,

      output [7:0]      cfgbp_lane_err,
      output            cfgbp_link_equlz_req,
      output            cfgbp_equiz_complete,
      output            cfgbp_phase_3_successful,
      output            cfgbp_phase_2_successful,
      output            cfgbp_phase_1_successful,
      output            cfgbp_current_deemph,
      output [1:0]      cfgbp_current_speed,
      output            cfgbp_link_up,
      output            cfgbp_link_train,
      output            cfgbp_10state,
      output            cfgbp_10sstate,
      output            cfgbp_rx_val_pm,
      output [2:0]      cfgbp_rx_typ_pm,
      output            cfgbp_tx_ack_pm,
      output [1:0]      cfgbp_ack_phypm,
      output            cfgbp_vc_status,
      output            cfgbp_rxfc_max,
      output            cfgbp_txfc_max,
      output            cfgbp_txbuf_emp,
      output            cfgbp_cfgbuf_emp,
      output            cfgbp_rpbuf_emp,
      output            cfgbp_dll_req,
      output            cfgbp_link_auto_bdw_status,
      output            cfgbp_link_bdw_mng_status,
      output            cfgbp_rst_tx_margin_field,
      output            cfgbp_rst_enter_comp_bit,
      output [3:0]      cfgbp_rx_st_ecrcerr,
      output            cfgbp_err_uncorr_internal,
      output            cfgbp_rx_corr_internal,
      output            cfgbp_err_tlrcvovf,
      output            cfgbp_txfc_err,
      output            cfgbp_err_tlmalf,
      output            cfgbp_err_surpdwn_dll,
      output            cfgbp_err_dllrev,
      output            cfgbp_err_dll_repnum,
      output            cfgbp_err_dllreptim,
      output            cfgbp_err_dllp_baddllp,
      output            cfgbp_err_dll_badtlp,
      output            cfgbp_err_phy_tng,
      output            cfgbp_err_phy_rcv,
      output            cfgbp_root_err_reg_sts,
      output            cfgbp_corr_err_reg_sts,
      output            cfgbp_unc_err_reg_sts,


      // CSEB I/O
      input  [31 : 0]       cseb_rddata,
      input  [3 : 0]        cseb_rddata_parity,
      input  [4 : 0]        cseb_rdresponse,
      input                 cseb_waitrequest,
      input  [4 : 0]        cseb_wrresponse,
      input                 cseb_wrresp_valid,

      output [32 : 0]       cseb_addr,
      output [4 : 0]        cseb_addr_parity,
      output [3 : 0]        cseb_be,
      output                cseb_is_shadow,
      output                cseb_rden,
      output [31 : 0]       cseb_wrdata,
      output [3 : 0]        cseb_wrdata_parity,
      output                cseb_wren,
      output                cseb_wrresp_req


      );


localparam integer MAX_CHARS = 32;
// Convert a string to an integer
// Uses pre-existing str2hz function
function integer str2int(
    input [MAX_CHARS*8-1:0] instring
  );
   time temp;

   begin
    temp = str2hz({instring,"Hz"});
    str2int = temp[31:0];
   end
endfunction

// convert frequency string into integer Hz.  Fractional Hz are truncated
// Must remain a constant function - can't use string.atoi().
function time str2hz (
                input [8*MAX_CHARS:1] s
        );

                integer i;
                integer c; // temp char storage for frequency conversion
                integer unit_tens; // assume already Hz
                integer is_numeric;
                integer saw_dot;

                reg [8:1] c_dot; // = ".";
                reg [8:1] c_space; // = " ";
                reg [8:1] c_a; // = 8'h61; //"a";
                reg [8:1] c_z; // = 8'h7a; //"z";
                reg [8*4:1] s_unit;
                reg [8*MAX_CHARS:1] s_shift;

                begin
                        // frequency ratio calculations
                        str2hz = 0;
                        unit_tens = 0; // assume already Hz
                        is_numeric = 1;
                        saw_dot = 0;
                        s_unit = "";

                        // Modelsim optimizer bug forces us to initialize these non-statically
                        c_dot = ".";
                        c_space = " ";
                        c_a = "a";
                        c_z = "z";
                        for (i=(MAX_CHARS-1); i>=0; i=i-1) begin
                                s_shift = (s >> (i*8));
                                c = s_shift[8:1] & 8'hff;
                                if (c > 0) begin
                                        //$display("[%d] => '%1s',", i, c);
                                        if (c >= 8'h30 && c <= 8'h39 && is_numeric) begin
                                                str2hz = (str2hz * 10) + (c & 8'h0f);
                                                if (saw_dot) unit_tens = unit_tens - 1;  // count digits after decimal point
                                        end else if (c == c_dot) saw_dot = 1;
                                        else if (c != c_space) begin
                                                is_numeric = 0; // stop accepting new numeric digits in value
                                                // if it's a-z, convert to upper case A-Z
                                                if (c >= c_a && c <= c_z) c = (c & 8'h5f);      // convert a-z (lower) to A-Z (upper)
                                                s_unit = (s_unit << 8) | c;
                                        end
                                end
                        end
                        //$display("numeric = %d x 10**(%2d), unit = '%0s'", str2hz, unit_tens, s_unit);

                        // account for frequency unit
                        if (s_unit == "GHZ" || s_unit == "GBPS") unit_tens = unit_tens + 9; // 10**9
                        else if (s_unit == "MHZ" || s_unit == "MBPS") unit_tens = unit_tens + 6; // 10**6
                        else if (s_unit == "KHZ" || s_unit == "KBPS") unit_tens = unit_tens + 3; // 10**3
                        else if (s_unit != "HZ" && s_unit != "BPS") begin
                                $display("Invalid frequency unit '%0s', assuming %d x 10**(%2d) 'Hz'", s_unit, str2hz, unit_tens);
                        end
                        //$display("numeric in Hz = %d x 10**(%2d)", str2hz, unit_tens);

                        // align numeric to Hz
                        if (unit_tens < 0) begin
                                //str2hz = str2hz / (10**(-unit_tens));
                                for (i=0; i>unit_tens; i=i-1) begin
                                        str2hz = str2hz / 10;
                                end
                        end else begin
                                //str2hz = str2hz * (10**unit_tens);
                                for (i=0; i<unit_tens; i=i+1) begin
                                        str2hz = str2hz * 10;
                                end
                        end
                        //$display("%d Hz", str2hz);
                end
endfunction


function [8*25:1] low_str;
// Convert parameter strings to lower case
   input [8*25:1] input_string;
   reg [8*25:1] return_string;
   reg [8*25:1] reg_string;
   reg [8:1] tmp;
   reg [8:1] conv_char;
   integer byte_count;
   begin
      reg_string = input_string;
      for (byte_count = 25; byte_count >= 1; byte_count = byte_count - 1) begin
         tmp = reg_string[8*25:(8*(25-1)+1)];
         reg_string = reg_string << 8;
         if ((tmp >= 65) && (tmp <= 90)) // ASCII number of 'A' is 65, 'Z' is 90
            begin
            conv_char = tmp + 32; // 32 is the difference in the position of 'A' and 'a' in the ASCII char set
            return_string = {return_string, conv_char};
            end
         else
            return_string = {return_string, tmp};
      end
   low_str = return_string;
   end
endfunction

function [43:0] calc_k_ptr_sv;
   // purpose: Calculate the k_ptr values based on the supplied parameters
   // calc_k_ptr_sv
   input[55:0] k_vc;
   reg[10:0]   post_min;
   reg[10:0]   post_max;
   reg[10:0]   nonp_min;
   reg[10:0]   nonp_max;
   integer     nonp_siz;
   begin
      post_min = 11'b000_0000_0000;
      nonp_max = 11'b111_1111_1111;
      // Reserve Space for the NonPosted Headers (and also NonPosted Data)
      nonp_siz = ((k_vc[27:20])) * 2;
      post_max = (use_crc_forwarding_hwtcl==1)?nonp_max - (nonp_siz[10 : 0])-({1'b0 , nonp_siz[10:1]}) :
                                                             nonp_max - nonp_siz[10:0];
      nonp_min = post_max + 11'h1;
      calc_k_ptr_sv = ({nonp_max[10:0], nonp_min[10:0], post_max[10:0], post_min[10:0]});
   end
endfunction

function [63:0] get_bar_size_mask;
   // Compute bar size mask based on BAR size
   input integer bara_64bit_mem_space ;// Integer 1 or 0
   input integer bara_size            ;// Integer number of bits
   input integer barb_size            ;// Integer number of bits
   reg [63:0] barab_size_mask64;
   reg [31:0] bara_size_mask32;
   reg [31:0] barb_size_mask32;
   begin
      barab_size_mask64 = {60'hffff_ffff_ffff_fff << (bara_size - 4), 4'h0};
      bara_size_mask32  = {28'hffff_fff           << (bara_size - 4), 4'h0};
      barb_size_mask32  = {28'hffff_fff           << (barb_size - 4), 4'h0};
      get_bar_size_mask = (bara_64bit_mem_space == 1)? barab_size_mask64[63:0]:
                              {barb_size_mask32[31:0]  , bara_size_mask32[31:0]};
   end
endfunction

function [31:0] get_expansion_base_addr_mask;
   // Compute expansion ROM size mask based on expansion ROM size
   input integer expansion_base_address_size;
   begin
      get_expansion_base_addr_mask = {28'hffff_fff << (expansion_base_address_size - 4), 4'h0};
   end
endfunction

//synthesis translate_off
localparam ALTPCIE_SV_HIP_AST_HWTCL_SIM_ONLY  = 1;
//synthesis translate_on

//synthesis read_comments_as_HDL on
//localparam ALTPCIE_SV_HIP_AST_HWTCL_SIM_ONLY  = 0;
//synthesis read_comments_as_HDL off

localparam QW_ZERO                                       = 64'h0;
localparam in_cvp_mode                                   = (ALTPCIE_SV_HIP_AST_HWTCL_SIM_ONLY==1)?"not_in_cvp_mode"          :(in_cvp_mode_hwtcl==0)?"not_in_cvp_mode":"in_cvp_mode";
localparam use_cvp_update_core_pof                       = (in_cvp_mode=="not_in_cvp_mode")?0                                : use_cvp_update_core_pof_hwtcl;
localparam enable_pipe32_sim                             = (ALTPCIE_SV_HIP_AST_HWTCL_SIM_ONLY==1)?enable_pipe32_sim_hwtcl    :0;
localparam enable_tl_only_sim                            = enable_tl_only_sim_hwtcl;
localparam pll_refclk_freq                               = pll_refclk_freq_hwtcl                                               ;// String  : "100 MHz";
localparam enable_slot_register                          = (enable_slot_register_hwtcl==1)?"true":"false"                      ;// String  : "false";
localparam bypass_cdc                                    = bypass_cdc_hwtcl                                                    ;// String  : "false";
localparam enable_rx_buffer_checking                     = enable_rx_buffer_checking_hwtcl                                     ;// String  : "false";
localparam [3:0] single_rx_detect                        = single_rx_detect_hwtcl [3:0]                                        ;// integer : 4'b0;
localparam use_crc_forwarding                            = (use_crc_forwarding_hwtcl==1)?"true":"false"                        ;// String  : "false";
localparam gen123_lane_rate_mode                         = (gen123_lane_rate_mode_hwtcl=="Gen3 (8.0 Gbps)")?"gen1_gen2_gen3":
                                                            (gen123_lane_rate_mode_hwtcl=="Gen2 (5.0 Gbps)")?"gen1_gen2":"gen1";// String  : "gen1";
localparam lane_mask                                     = lane_mask_hwtcl                                                     ;// String  : "x4";
localparam disable_link_x2_support                       = disable_link_x2_support_hwtcl                                       ;// String  : "false";
localparam dis_paritychk                                 = (use_ast_parity==0)?"disable":"enable"                              ;// String  : "enable";
localparam wrong_device_id                               = wrong_device_id_hwtcl                                               ;// String  : "disable";
localparam data_pack_rx                                  = data_pack_rx_hwtcl                                                  ;// String  : "disable";
localparam ast_width                                     = (ast_width_hwtcl=="Avalon-ST 256-bit")?"rx_tx_256":(ast_width_hwtcl=="Avalon-ST 128-bit")?"rx_tx_128":"rx_tx_64";// String  : "rx_tx_64";
localparam rx_ast_parity                                 = (use_ast_parity==0)?"disable":"enable"                              ;// String  : "disable";
localparam tx_ast_parity                                 = (use_ast_parity==0)?"disable":"enable"                              ;// String  : "disable";
localparam ltssm_1ms_timeout                             = ltssm_1ms_timeout_hwtcl                                             ;// String  : "disable";
localparam ltssm_freqlocked_check                        = ltssm_freqlocked_check_hwtcl                                        ;// String  : "disable";
localparam deskew_comma                                  = deskew_comma_hwtcl                                                  ;// String  : "skp_eieos_deskw";
localparam [7:0] port_link_number                        = port_link_number_hwtcl  [7:0]                                       ;// integer : 8'b1;
localparam [4:0] device_number                           = device_number_hwtcl     [4:0]                                       ;// Integer : 5'b0;
localparam bypass_clk_switch                             = bypass_clk_switch_hwtcl                                             ;// String  : "TRUE";
localparam pipex1_debug_sel                              = pipex1_debug_sel_hwtcl                                              ;// String  : "disable";
localparam pclk_out_sel                                  = pclk_out_sel_hwtcl                                                  ;// String  : "pclk";
localparam [15:0] vendor_id                              = vendor_id_hwtcl            [15:0]                                   ;// integer : 16'b1000101110010;
localparam [15:0] device_id                              = device_id_hwtcl            [15:0]                                   ;// integer : 16'b1;
localparam [ 7:0] revision_id                            = revision_id_hwtcl          [ 7:0]                                   ;// integer : 8'b1;
localparam [23:0] class_code                             = class_code_hwtcl           [23:0]                                   ;// integer : 24'b111111110000000000000000;
localparam [15:0] subsystem_vendor_id                    = subsystem_vendor_id_hwtcl  [15:0]                                   ;// integer : 16'b1000101110010;
localparam [15:0] subsystem_device_id                    = subsystem_device_id_hwtcl  [15:0]                                   ;// integer : 16'b1;

localparam no_soft_reset                                 = no_soft_reset_hwtcl                                                 ;// String  : "false";
localparam [2:0] maximum_current                         = maximum_current_hwtcl   [2:0]                                       ;// integer : 3'b0;
localparam d1_support                                    = d1_support_hwtcl                                                    ;// String  : "false";
localparam d2_support                                    = d2_support_hwtcl                                                    ;// String  : "false";
localparam d0_pme                                        = d0_pme_hwtcl                                                        ;// String  : "false";
localparam d1_pme                                        = d1_pme_hwtcl                                                        ;// String  : "false";
localparam d2_pme                                        = d2_pme_hwtcl                                                        ;// String  : "false";
localparam d3_hot_pme                                    = d3_hot_pme_hwtcl                                                    ;// String  : "false";
localparam d3_cold_pme                                   = d3_cold_pme_hwtcl                                                   ;// String  : "false";
localparam use_aer                                       = (use_aer_hwtcl==1)?"true":"false"                                   ;// String  : "false";
localparam low_priority_vc                               = low_priority_vc_hwtcl                                               ;// String  : "single_vc";
localparam disable_snoop_packet                          = disable_snoop_packet_hwtcl                                          ;// String  : "false";
localparam max_payload_size                              = (max_payload_size_hwtcl==128 )?"payload_128":
                                                           (max_payload_size_hwtcl==256 )?"payload_256":
                                                           (max_payload_size_hwtcl==512 )?"payload_512":
                                                           (max_payload_size_hwtcl==1024)?"payload_1024":
                                                           (max_payload_size_hwtcl==2048)?"payload_2048":"payload_128"         ;// String  : "payload_512";
localparam surprise_down_error_support                   = (surprise_down_error_support_hwtcl==1)?"true":"false"               ;// String  : "false";
localparam dll_active_report_support                     = (dll_active_report_support_hwtcl  ==1)?"true":"false"               ;// String  : "false";
localparam extend_tag_field                              = (extend_tag_field_hwtcl=="32")?"false":"true"                       ;// String  : "false";
localparam [2:0] endpoint_l0_latency                     = endpoint_l0_latency_hwtcl [2:0]                                     ;// Integer : 3'b0;
localparam [2:0] endpoint_l1_latency                     = endpoint_l1_latency_hwtcl [2:0]                                     ;// Integer : 3'b0;
localparam [2:0] indicator                               = indicator_hwtcl           [2:0]                                     ;// Integer : 3'b111;
localparam [1:0] slot_power_scale                        = slot_power_scale_hwtcl    [1:0]                                     ;// Integer : 2'b0;
localparam max_link_width                                = lane_mask_hwtcl                                                     ;// String  : "x4";
localparam enable_l0s_aspm                               = enable_l0s_aspm_hwtcl                                               ;// String  : "false";
localparam enable_l1_aspm                                = enable_l1_aspm_hwtcl                                                ;// String  : "false";
localparam [2:0] l1_exit_latency_sameclock               = l1_exit_latency_sameclock_hwtcl   [2:0]                             ;// Integer : 3'b0;
localparam [2:0] l1_exit_latency_diffclock               = l1_exit_latency_diffclock_hwtcl   [2:0]                             ;// Integer : 3'b0;
localparam [6:0] hot_plug_support                        = hot_plug_support_hwtcl            [6:0]                             ;// Integer : 7'b0;
localparam [7:0] slot_power_limit                        = slot_power_limit_hwtcl            [7:0]                             ;// Integer : 8'b0;
localparam [12:0] slot_number                            = slot_number_hwtcl                 [12:0]                            ;// Integer : 13'b0;
localparam [7:0] diffclock_nfts_count                    = diffclock_nfts_count_hwtcl        [7:0]                             ;// Integer : 8'b0;
localparam [7:0] sameclock_nfts_count                    = sameclock_nfts_count_hwtcl        [7:0]                             ;// Integer : 8'b0;
localparam completion_timeout                            = completion_timeout_hwtcl                                            ;// String  : "abcd";
localparam enable_completion_timeout_disable             = (enable_completion_timeout_disable_hwtcl==1)?"true":"false"         ;// String  : "true";
localparam extended_tag_reset                            = extended_tag_reset_hwtcl                                            ;// String  : "false";
localparam ecrc_check_capable                            = (ecrc_check_capable_hwtcl==1)?"true":"false"                        ;// String  : "true";
localparam ecrc_gen_capable                              = (ecrc_gen_capable_hwtcl  ==1)?"true":"false"                        ;// String  : "true";
localparam no_command_completed                          = no_command_completed_hwtcl                                          ;// String  : "true";
localparam msi_multi_message_capable                     = (msi_multi_message_capable_hwtcl=="1") ?"count_1":
                                                           (msi_multi_message_capable_hwtcl=="2") ?"count_2":
                                                           (msi_multi_message_capable_hwtcl=="4") ?"count_4":
                                                           (msi_multi_message_capable_hwtcl=="8") ?"count_8":
                                                           (msi_multi_message_capable_hwtcl=="16")?"count_16":"count_32"       ;// String  : "count_4";
localparam msi_64bit_addressing_capable                  = msi_64bit_addressing_capable_hwtcl                                  ;// String  : "true";
localparam msi_masking_capable                           = msi_masking_capable_hwtcl                                           ;// String  : "false";
localparam msi_support                                   = msi_support_hwtcl                                                   ;// String  : "true";
localparam interrupt_pin                                 = interrupt_pin_hwtcl                                                 ;// String  : "inta";
localparam enable_function_msix_support                  = (enable_function_msix_support_hwtcl==1)?"true":"false"              ;// String  : "true";
localparam [10:0]msix_table_size                         = msix_table_size_hwtcl [10:0]                                    ;// Integer : 11'b0;
localparam [ 2:0]msix_table_bir                          = msix_table_bir_hwtcl  [ 2:0]                                     ;// Integer : 3'b0;
localparam [31:0]msix_table_offset                       = str2int(msix_table_offset_hwtcl)                          ;// Integer : 29'b0;
localparam [ 2:0]msix_pba_bir                            = msix_pba_bir_hwtcl    [ 2:0]                                     ;// Integer : 3'b0;
localparam [31:0]msix_pba_offset                         = str2int(msix_pba_offset_hwtcl)                             ;// Integer : 29'b0;
localparam bridge_port_vga_enable                        = bridge_port_vga_enable_hwtcl                                        ;// String  : "false";
localparam bridge_port_ssid_support                      = bridge_port_ssid_support_hwtcl                                      ;// String  : "false";
localparam [15:0]ssvid                                   = ssvid_hwtcl                       [15:0]                        ;// String  : 16'b0;
localparam [15:0]ssid                                    = ssid_hwtcl                        [15:0]                        ;// String  : 16'b0;
localparam [3:0] eie_before_nfts_count                   = eie_before_nfts_count_hwtcl       [3:0]                          ;// String  : 4'b100;
localparam [7:0] gen2_diffclock_nfts_count               = gen2_diffclock_nfts_count_hwtcl   [7:0]                          ;// String  : 8'b11111111;
localparam [7:0] gen2_sameclock_nfts_count               = gen2_sameclock_nfts_count_hwtcl   [7:0]                          ;// String  : 8'b11111111;
localparam deemphasis_enable                             = deemphasis_enable_hwtcl                                             ;// String  : "false";
localparam pcie_spec_version                             = (pcie_spec_version_hwtcl=="2.1")?"v2":"v3"                          ;// String  : "v2";
localparam [2:0] l0_exit_latency_sameclock               = l0_exit_latency_sameclock_hwtcl    [2:0]                         ;// String  : 3'b110;
localparam [2:0] l0_exit_latency_diffclock               = l0_exit_latency_diffclock_hwtcl    [2:0]                         ;// String  : 3'b110;
localparam rx_ei_l0s                                     = (rx_ei_l0s_hwtcl==0)?"disable":"enable"                             ;// String  : "disable";
localparam l2_async_logic                                = l2_async_logic_hwtcl                                                ;// String  : "enable";
localparam aspm_config_management                        = aspm_config_management_hwtcl                                        ;// String  : "true";
localparam atomic_op_routing                             = atomic_op_routing_hwtcl                                             ;// String  : "false";
localparam atomic_op_completer_32bit                     = atomic_op_completer_32bit_hwtcl                                     ;// String  : "false";
localparam atomic_op_completer_64bit                     = atomic_op_completer_64bit_hwtcl                                     ;// String  : "false";
localparam cas_completer_128bit                          = cas_completer_128bit_hwtcl                                          ;// String  : "false";
localparam ltr_mechanism                                 = ltr_mechanism_hwtcl                                                 ;// String  : "false";
localparam tph_completer                                 = tph_completer_hwtcl                                                 ;// String  : "false";
localparam extended_format_field                         = extended_format_field_hwtcl                                         ;// String  : "true";
localparam atomic_malformed                              = atomic_malformed_hwtcl                                              ;// String  : "false";
localparam flr_capability                                = flr_capability_hwtcl                                                ;// String  : "true";
localparam enable_adapter_half_rate_mode                 = enable_adapter_half_rate_mode_hwtcl                                 ;// String  : "false";
localparam vc0_clk_enable                                = vc0_clk_enable_hwtcl                                                ;// String  : "true";
localparam register_pipe_signals                         = register_pipe_signals_hwtcl                                         ;// String  : "false";

localparam [63:0] bar01_size_mask                        = get_bar_size_mask((bar0_64bit_mem_space_hwtcl=="Enabled")?1:0,bar0_size_mask_hwtcl, bar1_size_mask_hwtcl) ;
localparam bar0_io_space                                 = (bar0_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar0_64bit_mem_space                          = (bar0_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "true";
localparam bar0_prefetchable                             = (bar0_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "true";
localparam [27:0] bar0_size_mask                         = bar01_size_mask[31:4]                                               ;// Bit vector
localparam bar1_io_space_64                              = (bar01_size_mask[32]==1'b1)?"true":"false";
localparam bar1_64bit_mem_space_64                       = (bar01_size_mask[34:33]==2'b11)?"all_one":(bar01_size_mask[34:33]==2'b10)?"true":"false";
localparam bar1_prefetchable_64                          = (bar01_size_mask[35]==1'b1)?"true":"false";
localparam bar1_io_space                                 = (bar0_64bit_mem_space_hwtcl == "Enabled")? bar1_io_space_64       : (bar1_io_space_hwtcl        == "Enabled")?"true":"false";// String  : "false";
localparam bar1_64bit_mem_space                          = (bar0_64bit_mem_space_hwtcl == "Enabled")? bar1_64bit_mem_space_64:                                                  "false";// String  : "false";
localparam bar1_prefetchable                             = (bar0_64bit_mem_space_hwtcl == "Enabled")? bar1_prefetchable_64   : (bar1_prefetchable_hwtcl    == "Enabled")?"true":"false";// String  : "false";
localparam [27:0] bar1_size_mask                         = bar01_size_mask[63:36]                                              ;// String  : "N/A";

localparam [63:0] bar23_size_mask                        = get_bar_size_mask((bar2_64bit_mem_space_hwtcl=="Enabled")?1:0,bar2_size_mask_hwtcl, bar3_size_mask_hwtcl) ;
localparam bar2_io_space                                 = (bar2_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar2_64bit_mem_space                          = (bar2_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "true";
localparam bar2_prefetchable                             = (bar2_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "true";
localparam [27:0] bar2_size_mask                         = bar23_size_mask[31:4]                                               ;// Bit vector
localparam bar3_io_space_64                              = (bar23_size_mask[32]==1'b1)?"true":"false";
localparam bar3_64bit_mem_space_64                       = (bar23_size_mask[34:33]==2'b11)?"all_one":(bar23_size_mask[34:33]==2'b10)?"true":"false";
localparam bar3_prefetchable_64                          = (bar23_size_mask[35]==1'b1)?"true":"false";
localparam bar3_io_space                                 = (bar2_64bit_mem_space_hwtcl == "Enabled")? bar3_io_space_64       : (bar3_io_space_hwtcl        == "Enabled")?"true":"false";// String  : "false";
localparam bar3_64bit_mem_space                          = (bar2_64bit_mem_space_hwtcl == "Enabled")? bar3_64bit_mem_space_64:                                                  "false";// String  : "false";
localparam bar3_prefetchable                             = (bar2_64bit_mem_space_hwtcl == "Enabled")? bar3_prefetchable_64   : (bar3_prefetchable_hwtcl    == "Enabled")?"true":"false";// String  : "false";
localparam [27:0] bar3_size_mask                         = bar23_size_mask[63:36]                                              ;// String  : "N/A";

localparam [63:0] bar45_size_mask                        = get_bar_size_mask((bar4_64bit_mem_space_hwtcl=="Enabled")?1:0,bar4_size_mask_hwtcl, bar5_size_mask_hwtcl) ;
localparam bar4_io_space                                 = (bar4_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar4_64bit_mem_space                          = (bar4_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "true";
localparam bar4_prefetchable                             = (bar4_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "true";
localparam [27:0] bar4_size_mask                         = bar45_size_mask[31:4]                                               ;// Bit vector
localparam bar5_io_space_64                              = (bar45_size_mask[32]==1'b1)?"true":"false";
localparam bar5_64bit_mem_space_64                       = (bar45_size_mask[34:33]==2'b11)?"all_one":(bar45_size_mask[34:33]==2'b10)?"true":"false";
localparam bar5_prefetchable_64                          = (bar45_size_mask[35]==1'b1)?"true":"false";
localparam bar5_io_space                                 = (bar4_64bit_mem_space_hwtcl == "Enabled")? bar5_io_space_64       : (bar5_io_space_hwtcl        == "Enabled")?"true":"false";// String  : "false";
localparam bar5_64bit_mem_space                          = (bar4_64bit_mem_space_hwtcl == "Enabled")? bar5_64bit_mem_space_64:                                                  "false";// String  : "false";
localparam bar5_prefetchable                             = (bar4_64bit_mem_space_hwtcl == "Enabled")? bar5_prefetchable_64   : (bar5_prefetchable_hwtcl    == "Enabled")?"true":"false";// String  : "false";
localparam [27:0] bar5_size_mask                         = bar45_size_mask[63:36]                                              ;// String  : "N/A";

localparam [31:0] expansion_base_address_register        = get_expansion_base_addr_mask(expansion_base_address_register_hwtcl) ;

localparam io_window_addr_width                          = (io_window_addr_width_hwtcl==1)?"window_16_bit":(io_window_addr_width_hwtcl==2)?"window_32_bit":"none";// String  : "window_32_bit";
localparam prefetchable_mem_window_addr_width            = (prefetchable_mem_window_addr_width_hwtcl==0)?"prefetch_0":(prefetchable_mem_window_addr_width_hwtcl==2)?"prefetch_64":"prefetch_32";// String  : "prefetch_32";
localparam [10:0]skp_os_gen3_count                       = skp_os_gen3_count_hwtcl            [10:0]                       ;// Integer : 11'b0;
localparam [3 :0]tx_cdc_almost_empty                     = tx_cdc_almost_empty_hwtcl          [3 :0]                       ;// Integer : 4'b101;
localparam [3 :0]rx_cdc_almost_full                      = rx_cdc_almost_full_hwtcl           [3 :0]                       ;// Integer : 4'b1100;
localparam [3 :0]tx_cdc_almost_full                      = tx_cdc_almost_full_hwtcl           [3 :0]                       ;// Integer : 4'b1100;
localparam [7 :0]rx_l0s_count_idl                        = rx_l0s_count_idl_hwtcl             [7 :0]                       ;// Integer : 8'b0;
localparam [3 :0]cdc_dummy_insert_limit                  = cdc_dummy_insert_limit_hwtcl       [3 :0]                       ;// Integer : 4'b1011;
localparam [7 :0]ei_delay_powerdown_count                = ei_delay_powerdown_count_hwtcl     [7 :0]                       ;// Integer : 8'b1010;
localparam [19:0]millisecond_cycle_count                 = millisecond_cycle_count_hwtcl      [19:0]                       ;// Integer : 20'b0;
localparam [10:0]skp_os_schedule_count                   = skp_os_schedule_count_hwtcl        [10:0]                       ;// Integer : 11'b0;
localparam [10:0]fc_init_timer                           = fc_init_timer_hwtcl                [10:0]                       ;// Integer : 11'b10000000000;
localparam [4 :0]l01_entry_latency                       = l01_entry_latency_hwtcl            [4 :0]                       ;// Integer : 5'b11111;
localparam [4 :0]flow_control_update_count               = flow_control_update_count_hwtcl    [4 :0]                       ;// Integer : 5'b11110;
localparam [7 :0]flow_control_timeout_count              = flow_control_timeout_count_hwtcl   [7 :0]                       ;// Integer : 8'b11001000;


localparam [ 9:0]retry_buffer_last_active_address        = retry_buffer_last_active_address_hwtcl [ 9:0]                   ;// Integer : 11'b11111111111;
localparam [52:0] retry_buffer_memory_settings           = 53'b0_1000_1011_0010_0001_0101_0010_0000_0101_1100_1010_0010_0110_0000;
localparam [52:0] vc0_rx_buffer_memory_settings          = 53'b0_1000_1011_0010_0001_0101_0010_0000_0101_1100_1010_0010_0110_0000;

// Credit Allocation
localparam credit_buffer_allocation_aux                  = (low_str(credit_buffer_allocation_aux_hwtcl)=="balanced")   ?"balanced":
                                                           (low_str(credit_buffer_allocation_aux_hwtcl)=="target")     ?"target":
                                                           (low_str(credit_buffer_allocation_aux_hwtcl)=="initiator")  ?"initiator":"absolute";
localparam [7:0]  vc0_rx_flow_ctrl_posted_header         = vc0_rx_flow_ctrl_posted_header_hwtcl        [7:0]               ;// Integer : 8'b110010;
localparam [11:0] vc0_rx_flow_ctrl_posted_data           = vc0_rx_flow_ctrl_posted_data_hwtcl          [11:0]              ;// Integer : 12'b101101000;
localparam [7:0]  vc0_rx_flow_ctrl_nonposted_header      = vc0_rx_flow_ctrl_nonposted_header_hwtcl     [7:0]               ;// Integer : 8'b110110;
localparam [7:0]  vc0_rx_flow_ctrl_nonposted_data        = vc0_rx_flow_ctrl_nonposted_data_hwtcl       [7:0]               ;// Integer : 8'b0;
localparam [7:0]  vc0_rx_flow_ctrl_compl_header          = vc0_rx_flow_ctrl_compl_header_hwtcl         [7:0]               ;// Integer : 8'b1110000;
localparam [11:0] vc0_rx_flow_ctrl_compl_data            = vc0_rx_flow_ctrl_compl_data_hwtcl           [11:0]              ;// Integer : 12'b111000000;
localparam [43:0] k_ptr                                  = calc_k_ptr_sv({ vc0_rx_flow_ctrl_compl_data      ,
                                                                           vc0_rx_flow_ctrl_compl_header    ,
                                                                           vc0_rx_flow_ctrl_nonposted_data  ,
                                                                           vc0_rx_flow_ctrl_nonposted_header,
                                                                           vc0_rx_flow_ctrl_posted_data     ,
                                                                           vc0_rx_flow_ctrl_posted_header   });
localparam [10:0] rx_ptr0_posted_dpram_min               = k_ptr[10:0];
localparam [10:0] rx_ptr0_posted_dpram_max               = k_ptr[21:11];
localparam [10:0] rx_ptr0_nonposted_dpram_min            = k_ptr[32:22];
localparam [10:0] rx_ptr0_nonposted_dpram_max            = k_ptr[43:33];

// Not visible parameters
localparam pcie_mode                                     = (port_type_hwtcl=="Root port")?"rp":(port_type_hwtcl=="Legacy endpoint")?"ep_legacy":"ep_native"                 ;// String  : "shared_mode";
localparam rx_sop_ctrl                                   = ((multiple_packets_per_cycle_hwtcl==1) || (low_str(ast_width)=="rx_tx_128"))? "boundary_128":(low_str(ast_width)=="rx_tx_256")? "boundary_256":"boundary_64";// String  : "boundary_64";
localparam tx_sop_ctrl                                   = ((multiple_packets_per_cycle_hwtcl==1) || (low_str(ast_width)=="rx_tx_128"))? "boundary_128":(low_str(ast_width)=="rx_tx_256")? "boundary_256":"boundary_64";// String  : "boundary_64";
localparam bist_memory_settings                          =  75'b0;
localparam iei_enable_settings                           =  "gen3gen2_infei_infsd_gen1_infei_sd";
localparam rpltim_set                                    =  "true";
localparam rpltim_base_data                              =  13'h10;
localparam acknak_set                                    =  "false";
localparam acknak_base_data                              =  13'h0;
localparam [15:0] vsec_id                                =  vsec_id_hwtcl [15:0];             //16'b1000101110010;
localparam [3:0] vsec_rev                                =  vsec_rev_hwtcl[3:0] ;
localparam [127:0] jtag_id                               =  128'h0;
localparam [15:0] user_id                                =  user_id_hwtcl [15:0];
localparam cvp_rate_sel                                  =  cvp_rate_sel_hwtcl;
localparam cvp_data_compressed                           =  cvp_data_compressed_hwtcl;
localparam cvp_data_encrypted                            =  cvp_data_encrypted_hwtcl;
localparam cvp_mode_reset                                =  cvp_mode_reset_hwtcl;
localparam cvp_clk_reset                                 =  cvp_clk_reset_hwtcl;
localparam core_clk_sel                                  =  core_clk_sel_hwtcl;
localparam pipe_low_latency_syncronous_mode              =  low_latency_mode_hwtcl;
`ifdef ALTERA_RESERVED_QIS_ES
   localparam hip_hard_reset                             =  (gen123_lane_rate_mode_hwtcl=="Gen2 (5.0 Gbps)")? "disable":(hip_hard_reset_hwtcl==0)? "disable" : "enable";
`else
   localparam hip_hard_reset                             =  (hip_hard_reset_hwtcl==0)? "disable" : "enable";
`endif
localparam hard_reset_bypass                             =  (in_cvp_mode_hwtcl==1)? "false":(hip_hard_reset=="disable")? "true" : "false";
localparam use_atx_pll                                   =  (use_atx_pll_hwtcl==1)? "true":"false";
localparam enable_power_on_rst_pulse                     =  (hip_hard_reset=="enable")?0:enable_power_on_rst_pulse_hwtcl;

localparam ACDS_V10=1;
localparam MEM_CHECK=0;
localparam USE_INTERNAL_250MHZ_PLL = 1;
localparam cseb_on                                       = ((use_pci_ext_hwtcl==1) || (use_pcie_ext_hwtcl==1))?1:0;
localparam cseb_extend_pci                               = (use_pci_ext_hwtcl==1)?"true":"false";
localparam cseb_extend_pcie                              = (use_pcie_ext_hwtcl==1)?"true":"false";
localparam cseb_cpl_status_during_cvp                    = cseb_cpl_status_during_cvp_hwtcl;
localparam cseb_route_to_avl_rx_st                       = (use_config_bypass_hwtcl==1)    ?"avst":"cseb";
localparam cseb_config_bypass                            = (use_config_bypass_hwtcl==1)    ?"enable":"disable";
localparam cseb_cpl_tag_checking                         = (use_config_bypass_hwtcl==1)    ?"disable":(hip_tag_checking_hwtcl==1)?"enable":"disable";
localparam cseb_bar_match_checking                       = (use_config_bypass_hwtcl==1)    ?"disable":"enable";
localparam cseb_min_error_checking = "false";
localparam cseb_temp_busy_crs = "completer_abort";
localparam cseb_disable_auto_crs = "false";
localparam gen3_diffclock_nfts_count = 8'b10000000;
localparam gen3_sameclock_nfts_count = 8'b10000000;
localparam gen3_coeff_errchk = "enable";
localparam gen3_paritychk = "disable";          //Disable TS1 parity check in OSDEC
localparam gen3_coeff_delay_count = 7'b1111101;
localparam gen3_skip_ph2_ph3 =  (gen3_skip_ph2_ph3_hwtcl==1)? "true":"false";
localparam gen3_dcbal_en =  (gen3_dcbal_en_hwtcl==1)? "true":"false";
localparam g3_bypass_equlz =  (g3_bypass_equlz_hwtcl==1)? "true":"false";


//Equlz Phase 2
localparam [17:0]gen3_coeff_1                  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_1_hwtcl                  [17:0]: 18'h7;
localparam       gen3_coeff_1_sel              = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_1_sel_hwtcl                    : "preset_1"; // Valid coeff_1 or preset_1
localparam [2:0] gen3_coeff_1_preset_hint      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_1_preset_hint_hwtcl      [2:0] : 3'h0;
localparam [3:0] gen3_coeff_1_nxtber_more_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_1_nxtber_more_ptr_hwtcl  [3:0] : 4'h1;       // next preset
localparam       gen3_coeff_1_nxtber_more      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_1_nxtber_more_hwtcl            : "g3_coeff_1_nxtber_more";
localparam [3:0] gen3_coeff_1_nxtber_less_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_1_nxtber_less_ptr_hwtcl  [3:0] : 4'h2;
localparam       gen3_coeff_1_nxtber_less      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_1_nxtber_less_hwtcl            : "g3_coeff_1_nxtber_less";
localparam [4:0] gen3_coeff_1_reqber           = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_1_reqber_hwtcl           [4:0] : 5'h0;
localparam [5:0] gen3_coeff_1_ber_meas         = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_1_ber_meas_hwtcl         [5:0] : 6'h4;

localparam [17:0]gen3_coeff_2                  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_2_hwtcl                  [17:0]: 18'h8;
localparam       gen3_coeff_2_sel              = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_2_sel_hwtcl                    : "preset_2";
localparam [2:0] gen3_coeff_2_preset_hint      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_2_preset_hint_hwtcl      [2:0] : 3'h0;
localparam [3:0] gen3_coeff_2_nxtber_more_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_2_nxtber_more_ptr_hwtcl  [3:0] : 4'h3;
localparam       gen3_coeff_2_nxtber_more      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_2_nxtber_more_hwtcl            : "g3_coeff_2_nxtber_more";
localparam [3:0] gen3_coeff_2_nxtber_less_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_2_nxtber_less_ptr_hwtcl  [3:0] : 4'h3;
localparam       gen3_coeff_2_nxtber_less      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_2_nxtber_less_hwtcl            : "g3_coeff_2_nxtber_less";
localparam [4:0] gen3_coeff_2_reqber           = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_2_reqber_hwtcl           [4:0] : 5'h0;
localparam [5:0] gen3_coeff_2_ber_meas         = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_2_ber_meas_hwtcl         [5:0] : 6'h4;

localparam [17:0]gen3_coeff_3                  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_3_hwtcl                  [17:0]: 18'h7;
localparam       gen3_coeff_3_sel              = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_3_sel_hwtcl                    : "preset_3";
localparam [2:0] gen3_coeff_3_preset_hint      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_3_preset_hint_hwtcl      [2:0] : 3'h0;
localparam [3:0] gen3_coeff_3_nxtber_more_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_3_nxtber_more_ptr_hwtcl  [3:0] : 4'h4;
localparam       gen3_coeff_3_nxtber_more      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_3_nxtber_more_hwtcl            : "g3_coeff_3_nxtber_more";
localparam [3:0] gen3_coeff_3_nxtber_less_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_3_nxtber_less_ptr_hwtcl  [3:0] : 4'h4;
localparam       gen3_coeff_3_nxtber_less      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_3_nxtber_less_hwtcl            : "g3_coeff_3_nxtber_less";
localparam [4:0] gen3_coeff_3_reqber           = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_3_reqber_hwtcl           [4:0] : 5'h1f;
localparam [5:0] gen3_coeff_3_ber_meas         = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_3_ber_meas_hwtcl         [5:0] : 6'h8;

localparam [17:0]gen3_coeff_4                  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_4_hwtcl                  [17:0]: 18'h8;
localparam       gen3_coeff_4_sel              = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_4_sel_hwtcl                    : "preset_4";
localparam [2:0] gen3_coeff_4_preset_hint      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_4_preset_hint_hwtcl      [2:0] : 3'h0;
localparam [3:0] gen3_coeff_4_nxtber_more_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_4_nxtber_more_ptr_hwtcl  [3:0] : 4'h4;
localparam       gen3_coeff_4_nxtber_more      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_4_nxtber_more_hwtcl            : "g3_coeff_4_nxtber_more";
localparam [3:0] gen3_coeff_4_nxtber_less_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_4_nxtber_less_ptr_hwtcl  [3:0] : 4'h4;
localparam       gen3_coeff_4_nxtber_less      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_4_nxtber_less_hwtcl            : "g3_coeff_4_nxtber_less";
localparam [4:0] gen3_coeff_4_reqber           = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_4_reqber_hwtcl           [4:0] : 5'h1f;
localparam [5:0] gen3_coeff_4_ber_meas         = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_4_ber_meas_hwtcl         [5:0] : 6'h4;

localparam [17:0]gen3_coeff_5                  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_5_hwtcl                  [17:0]: 18'h0;
localparam       gen3_coeff_5_sel              = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_5_sel_hwtcl                    : "preset_5";
localparam [2:0] gen3_coeff_5_preset_hint      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_5_preset_hint_hwtcl      [2:0] : 3'h0;
localparam [3:0] gen3_coeff_5_nxtber_more_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_5_nxtber_more_ptr_hwtcl  [3:0] : 4'h0;
localparam       gen3_coeff_5_nxtber_more      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_5_nxtber_more_hwtcl            : "g3_coeff_5_nxtber_more";
localparam [3:0] gen3_coeff_5_nxtber_less_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_5_nxtber_less_ptr_hwtcl  [3:0] : 4'h0;
localparam       gen3_coeff_5_nxtber_less      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_5_nxtber_less_hwtcl            : "g3_coeff_5_nxtber_less";
localparam [4:0] gen3_coeff_5_reqber           = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_5_reqber_hwtcl           [4:0] : 5'h0;
localparam [5:0] gen3_coeff_5_ber_meas         = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_5_ber_meas_hwtcl         [5:0] : 6'h0;     // When 0 exit

localparam [17:0]gen3_coeff_6                  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_6_hwtcl                  [17:0]: 18'h0;
localparam       gen3_coeff_6_sel              = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_6_sel_hwtcl                    : "preset_6";
localparam [2:0] gen3_coeff_6_preset_hint      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_6_preset_hint_hwtcl      [2:0] : 3'h0;
localparam [3:0] gen3_coeff_6_nxtber_more_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_6_nxtber_more_ptr_hwtcl  [3:0] : 4'h0;
localparam       gen3_coeff_6_nxtber_more      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_6_nxtber_more_hwtcl            : "g3_coeff_6_nxtber_more";
localparam [3:0] gen3_coeff_6_nxtber_less_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_6_nxtber_less_ptr_hwtcl  [3:0] : 4'h0;
localparam       gen3_coeff_6_nxtber_less      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_6_nxtber_less_hwtcl            : "g3_coeff_6_nxtber_less";
localparam [4:0] gen3_coeff_6_reqber           = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_6_reqber_hwtcl           [4:0] : 5'h0;
localparam [5:0] gen3_coeff_6_ber_meas         = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_6_ber_meas_hwtcl         [5:0] : 6'h0;

localparam [17:0]gen3_coeff_7                  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_7_hwtcl                  [17:0]: 18'h0;
localparam       gen3_coeff_7_sel              = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_7_sel_hwtcl                    : "preset_7";
localparam [2:0] gen3_coeff_7_preset_hint      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_7_preset_hint_hwtcl      [2:0] : 3'h0;
localparam [3:0] gen3_coeff_7_nxtber_more_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_7_nxtber_more_ptr_hwtcl  [3:0] : 4'h0;
localparam       gen3_coeff_7_nxtber_more      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_7_nxtber_more_hwtcl            : "g3_coeff_7_nxtber_more";
localparam [3:0] gen3_coeff_7_nxtber_less_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_7_nxtber_less_ptr_hwtcl  [3:0] : 4'h0;
localparam       gen3_coeff_7_nxtber_less      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_7_nxtber_less_hwtcl            : "g3_coeff_7_nxtber_less";
localparam [4:0] gen3_coeff_7_reqber           = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_7_reqber_hwtcl           [4:0] : 5'h0;
localparam [5:0] gen3_coeff_7_ber_meas         = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_7_ber_meas_hwtcl         [5:0] : 6'h0;

localparam [17:0]gen3_coeff_8                  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_8_hwtcl                  [17:0]: 18'h0;
localparam       gen3_coeff_8_sel              = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_8_sel_hwtcl                    : "preset_8";
localparam [2:0] gen3_coeff_8_preset_hint      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_8_preset_hint_hwtcl      [2:0] : 3'h0;
localparam [3:0] gen3_coeff_8_nxtber_more_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_8_nxtber_more_ptr_hwtcl  [3:0] : 4'h0;
localparam       gen3_coeff_8_nxtber_more      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_8_nxtber_more_hwtcl            : "g3_coeff_8_nxtber_more";
localparam [3:0] gen3_coeff_8_nxtber_less_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_8_nxtber_less_ptr_hwtcl  [3:0] : 4'h0;
localparam       gen3_coeff_8_nxtber_less      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_8_nxtber_less_hwtcl            : "g3_coeff_8_nxtber_less";
localparam [4:0] gen3_coeff_8_reqber           = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_8_reqber_hwtcl           [4:0] : 5'h0;
localparam [5:0] gen3_coeff_8_ber_meas         = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_8_ber_meas_hwtcl         [5:0] : 6'h0;

localparam [17:0]gen3_coeff_9                  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_9_hwtcl                  [17:0]: 18'h0;
localparam       gen3_coeff_9_sel              = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_9_sel_hwtcl                    : "preset_9";
localparam [2:0] gen3_coeff_9_preset_hint      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_9_preset_hint_hwtcl      [2:0] : 3'h0;
localparam [3:0] gen3_coeff_9_nxtber_more_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_9_nxtber_more_ptr_hwtcl  [3:0] : 4'h0;
localparam       gen3_coeff_9_nxtber_more      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_9_nxtber_more_hwtcl            : "g3_coeff_9_nxtber_more";
localparam [3:0] gen3_coeff_9_nxtber_less_ptr  = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_9_nxtber_less_ptr_hwtcl  [3:0] : 4'h0;
localparam       gen3_coeff_9_nxtber_less      = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_9_nxtber_less_hwtcl            : "g3_coeff_9_nxtber_less";
localparam [4:0] gen3_coeff_9_reqber           = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_9_reqber_hwtcl           [4:0] : 5'h0;
localparam [5:0] gen3_coeff_9_ber_meas         = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_9_ber_meas_hwtcl         [5:0] : 6'h0;

localparam [17:0]gen3_coeff_10                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_10_hwtcl                 [17:0]: 18'h0;
localparam       gen3_coeff_10_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_10_sel_hwtcl                   : "preset_10";
localparam [2:0] gen3_coeff_10_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_10_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_10_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_10_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_10_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_10_nxtber_more_hwtcl           : "g3_coeff_10_nxtber_more";
localparam [3:0] gen3_coeff_10_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_10_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_10_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_10_nxtber_less_hwtcl           : "g3_coeff_10_nxtber_less";
localparam [4:0] gen3_coeff_10_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_10_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_10_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_10_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_11                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_11_hwtcl                 [17:0]: 18'h0;
localparam       gen3_coeff_11_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_11_sel_hwtcl                   : "preset_11";
localparam [2:0] gen3_coeff_11_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_11_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_11_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_11_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_11_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_11_nxtber_more_hwtcl           : "g3_coeff_11_nxtber_more";
localparam [3:0] gen3_coeff_11_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_11_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_11_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_11_nxtber_less_hwtcl           : "g3_coeff_11_nxtber_less";
localparam [4:0] gen3_coeff_11_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_11_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_11_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_11_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_12                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_12_hwtcl                 [17:0]: 18'h0;
localparam       gen3_coeff_12_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_12_sel_hwtcl                   : "preset_12";
localparam [2:0] gen3_coeff_12_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_12_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_12_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_12_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_12_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_12_nxtber_more_hwtcl           : "g3_coeff_12_nxtber_more";
localparam [3:0] gen3_coeff_12_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_12_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_12_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_12_nxtber_less_hwtcl           : "g3_coeff_12_nxtber_less";
localparam [4:0] gen3_coeff_12_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_12_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_12_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_12_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_13                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_13_hwtcl                 [17:0]: 18'h0;
localparam       gen3_coeff_13_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_13_sel_hwtcl                   : "preset_13";
localparam [2:0] gen3_coeff_13_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_13_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_13_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_13_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_13_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_13_nxtber_more_hwtcl           : "g3_coeff_13_nxtber_more";
localparam [3:0] gen3_coeff_13_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_13_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_13_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_13_nxtber_less_hwtcl           : "g3_coeff_13_nxtber_less";
localparam [4:0] gen3_coeff_13_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_13_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_13_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_13_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_14                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_14_hwtcl                 [17:0]: 18'h0;
localparam       gen3_coeff_14_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_14_sel_hwtcl                   : "preset_14";
localparam [2:0] gen3_coeff_14_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_14_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_14_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_14_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_14_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_14_nxtber_more_hwtcl           : "g3_coeff_14_nxtber_more";
localparam [3:0] gen3_coeff_14_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_14_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_14_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_14_nxtber_less_hwtcl           : "g3_coeff_14_nxtber_less";
localparam [4:0] gen3_coeff_14_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_14_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_14_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_14_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_15                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_15_hwtcl                 [17:0]: 18'h0;
localparam       gen3_coeff_15_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_15_sel_hwtcl                   : "preset_15";
localparam [2:0] gen3_coeff_15_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_15_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_15_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_15_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_15_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_15_nxtber_more_hwtcl           : "g3_coeff_15_nxtber_more";
localparam [3:0] gen3_coeff_15_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_15_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_15_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_15_nxtber_less_hwtcl           : "g3_coeff_15_nxtber_less";
localparam [4:0] gen3_coeff_15_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_15_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_15_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_15_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_16                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_16_hwtcl                 [17:0]: 18'h0;
localparam       gen3_coeff_16_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_16_sel_hwtcl                   : "preset_16";
localparam [2:0] gen3_coeff_16_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_16_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_16_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_16_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_16_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_16_nxtber_more_hwtcl           : "g3_coeff_16_nxtber_more";
localparam [3:0] gen3_coeff_16_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_16_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_16_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_16_nxtber_less_hwtcl           : "g3_coeff_16_nxtber_less";
localparam [4:0] gen3_coeff_16_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_16_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_16_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_16_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_17                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_17_hwtcl                 [17:0]: 18'b110000000000000000;
localparam       gen3_coeff_17_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_17_sel_hwtcl                   : "preset_17";
localparam [2:0] gen3_coeff_17_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_17_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_17_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_17_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_17_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_17_nxtber_more_hwtcl           : "g3_coeff_17_nxtber_more";
localparam [3:0] gen3_coeff_17_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_17_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_17_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_17_nxtber_less_hwtcl           : "g3_coeff_17_nxtber_less";
localparam [4:0] gen3_coeff_17_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_17_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_17_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_17_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_18                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_18_hwtcl                 [17:0]: 18'b110000000000000001;
localparam       gen3_coeff_18_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_18_sel_hwtcl                   : "preset_18";
localparam [2:0] gen3_coeff_18_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_18_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_18_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_18_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_18_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_18_nxtber_more_hwtcl           : "g3_coeff_18_nxtber_more";
localparam [3:0] gen3_coeff_18_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_18_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_18_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_18_nxtber_less_hwtcl           : "g3_coeff_18_nxtber_less";
localparam [4:0] gen3_coeff_18_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_18_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_18_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_18_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_19                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_19_hwtcl                 [17:0]: 18'b110000000000000001;
localparam       gen3_coeff_19_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_19_sel_hwtcl                   : "preset_19";
localparam [2:0] gen3_coeff_19_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_19_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_19_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_19_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_19_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_19_nxtber_more_hwtcl           : "g3_coeff_19_nxtber_more";
localparam [3:0] gen3_coeff_19_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_19_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_19_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_19_nxtber_less_hwtcl           : "g3_coeff_19_nxtber_less";
localparam [4:0] gen3_coeff_19_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_19_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_19_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_19_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_20                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_20_hwtcl                 [17:0]: 18'b110000000000000001;
localparam       gen3_coeff_20_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_20_sel_hwtcl                   : "preset_20";
localparam [2:0] gen3_coeff_20_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_20_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_20_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_20_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_20_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_20_nxtber_more_hwtcl           : "g3_coeff_20_nxtber_more";
localparam [3:0] gen3_coeff_20_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_20_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_20_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_20_nxtber_less_hwtcl           : "g3_coeff_20_nxtber_less";
localparam [4:0] gen3_coeff_20_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_20_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_20_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_20_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_21                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_21_hwtcl                 [17:0]: 18'b110000000000000001;
localparam       gen3_coeff_21_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_21_sel_hwtcl                   : "preset_21";
localparam [2:0] gen3_coeff_21_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_21_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_21_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_21_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_21_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_21_nxtber_more_hwtcl           : "g3_coeff_21_nxtber_more";
localparam [3:0] gen3_coeff_21_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_21_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_21_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_21_nxtber_less_hwtcl           : "g3_coeff_21_nxtber_less";
localparam [4:0] gen3_coeff_21_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_21_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_21_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_21_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_22                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_22_hwtcl                 [17:0]: 18'b110000000000000001;
localparam       gen3_coeff_22_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_22_sel_hwtcl                   : "preset_22";
localparam [2:0] gen3_coeff_22_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_22_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_22_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_22_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_22_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_22_nxtber_more_hwtcl           : "g3_coeff_22_nxtber_more";
localparam [3:0] gen3_coeff_22_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_22_nxtber_less_ptr_hwtcl [3:0] : 4'b0111;
localparam       gen3_coeff_22_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_22_nxtber_less_hwtcl           : "g3_coeff_22_nxtber_less";
localparam [4:0] gen3_coeff_22_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_22_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_22_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_22_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_23                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_23_hwtcl                 [17:0]: 18'b110000000000000001;
localparam       gen3_coeff_23_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_23_sel_hwtcl                   : "preset_23";
localparam [2:0] gen3_coeff_23_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_23_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_23_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_23_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_23_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_23_nxtber_more_hwtcl           : "g3_coeff_23_nxtber_more";
localparam [3:0] gen3_coeff_23_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_23_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_23_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_23_nxtber_less_hwtcl           : "g3_coeff_23_nxtber_less";
localparam [4:0] gen3_coeff_23_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_23_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_23_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_23_ber_meas_hwtcl        [5:0] : 6'h0;

localparam [17:0]gen3_coeff_24                 = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_24_hwtcl                 [17:0]: 18'b110000000000000001;
localparam       gen3_coeff_24_sel             = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_24_sel_hwtcl                   : "preset_24";
localparam [2:0] gen3_coeff_24_preset_hint     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_24_preset_hint_hwtcl     [2:0] : 3'h0;
localparam [3:0] gen3_coeff_24_nxtber_more_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_24_nxtber_more_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_24_nxtber_more     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_24_nxtber_more_hwtcl           : "g3_coeff_24_nxtber_more";
localparam [3:0] gen3_coeff_24_nxtber_less_ptr = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_24_nxtber_less_ptr_hwtcl [3:0] : 4'h0;
localparam       gen3_coeff_24_nxtber_less     = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_24_nxtber_less_hwtcl           : "g3_coeff_24_nxtber_less";
localparam [4:0] gen3_coeff_24_reqber          = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_24_reqber_hwtcl          [4:0] : 5'h0;
localparam [5:0] gen3_coeff_24_ber_meas        = ( hwtcl_override_g3rxcoef==1 )?gen3_coeff_24_ber_meas_hwtcl        [5:0] : 6'h0;
//
// END RX SV PMA Gen3 Setting //////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function [203:0] get_coef;
   // Compute bar size mask based on BAR size
   input integer fs ;// Integer 1 or 0
   reg [17:0] c1 ;
   reg [17:0] c2 ;
   reg [17:0] c3 ;
   reg [17:0] c4 ;
   reg [17:0] c5 ;
   reg [17:0] c6 ;
   reg [17:0] c7 ;
   reg [17:0] c8 ;
   reg [17:0] c9 ;
   reg [17:0] c10;
   reg [17:0] c11;
   reg [5:0]  c12;
   begin
   if (fs==20) begin
      c1 = 18'b000000_010100_000000;
      c2 = 18'b000100_010000_000000;
      c3 = 18'b000101_001111_000000;
      c4 = 18'b000000_010000_000100;
      c5 = 18'b000011_001111_000010;      //*
      c6 = 18'b000100_001110_000010;
      c7 = 18'b000000_010010_000010;
      c8 = 18'b000000_010001_000011;
      c9 = 18'b000011_010001_000000;
      c10= 18'b000100_010000_000000;
      c11= 18'b000110_001110_000000;
      c12=  6'b001000;
   end
   else if (fs==21) begin
      c1 = 18'b000000_010101_000000;
      c2 = 18'b000100_010001_000000;
      c3 = 18'b000110_001111_000000;
      c4 = 18'b000000_010001_000100;
      c5 = 18'b000011_001111_000011;
      c6 = 18'b000101_001110_000010;      //*
      c7 = 18'b000000_010010_000011;
      c8 = 18'b000000_010010_000011;
      c9 = 18'b000011_010010_000000;
      c10= 18'b000101_010000_000000;
      c11= 18'b000111_001110_000000;    //*
      c12=  6'b000110;
   end
   else if (fs==22) begin
      c1 = 18'b000000_010110_000000;
      c2 = 18'b000100_010010_000000;
      c3 = 18'b000110_010000_000000;
      c4 = 18'b000000_010010_000100;
      c5 = 18'b000011_010000_000011;
      c6 = 18'b000101_001111_000010;     //*
      c7 = 18'b000000_010011_000011;
      c8 = 18'b000000_010011_000011;
      c9 = 18'b000011_010011_000000;
      c10= 18'b000101_010001_000000;
      c11= 18'b000111_001111_000000;    //*
      c12=  6'b000111;
   end
   else if (fs==23) begin
      c1 = 18'b000000_010111_000000;
      c2 = 18'b000100_010011_000000;
      c3 = 18'b000110_010001_000000;
      c4 = 18'b000000_010011_000100;
      c5 = 18'b000011_010001_000011;
      c6 = 18'b000101_010000_000010;     //*
      c7 = 18'b000000_010100_000011;
      c8 = 18'b000000_010100_000011;
      c9 = 18'b000011_010100_000000;
      c10= 18'b000101_010010_000000;
      c11= 18'b000111_010000_000000;    //*
      c12=  6'b001000;
   end
   else if (fs==24) begin
      c1 = 18'b000000_011000_000000;
      c2 = 18'b000101_010011_000000;
      c3 = 18'b000110_010010_000000;
      c4 = 18'b000000_010100_000100;
      c5 = 18'b000011_010010_000011;
      c6 = 18'b000101_010000_000011;
      c7 = 18'b000000_010101_000011;
      c8 = 18'b000000_010101_000011;
      c9 = 18'b000011_010101_000000;
      c10= 18'b000101_010011_000000;
      c11= 18'b001000_010000_000000;
      c12=  6'b001000;
   end
   else if (fs==25) begin
      c1 = 18'b000000_011001_000000;
      c2 = 18'b000101_010100_000000;
      c3 = 18'b000111_010010_000000;
      c4 = 18'b000000_010100_000101;
      c5 = 18'b000100_010010_000011;            //*
      c6 = 18'b000101_010001_000011;
      c7 = 18'b000000_010110_000011;
      c8 = 18'b000000_010101_000100;
      c9 = 18'b000100_010101_000000;
      c10= 18'b000101_010100_000000;
      c11= 18'b001000_010001_000000;
      c12=  6'b001001;
   end
   else if (fs==26) begin
      c1 = 18'b000000_011010_000000;
      c2 = 18'b000101_010101_000000;
      c3 = 18'b000111_010011_000000;
      c4 = 18'b000000_010101_000101;
      c5 = 18'b000100_010011_000011;            //*
      c6 = 18'b000101_010010_000011;
      c7 = 18'b000000_010111_000011;
      c8 = 18'b000000_010110_000100;
      c9 = 18'b000100_010110_000000;
      c10= 18'b000110_010100_000000;
      c11= 18'b001000_010010_000000;
      c12=  6'b001001;
   end
   else if (fs==27) begin
      c1 = 18'b000000_011011_000000;
      c2 = 18'b000101_010110_000000;
      c3 = 18'b000111_010100_000000;
      c4 = 18'b000000_010110_000101;
      c5 = 18'b000100_010100_000011;            //*
      c6 = 18'b000110_010010_000011;
      c7 = 18'b000000_011000_000011;
      c8 = 18'b000000_010111_000100;
      c9 = 18'b000100_010111_000000;
      c10= 18'b000110_010101_000000;
      c11= 18'b001001_010010_000000;
      c12=  6'b001001;
   end
   else if (fs==28) begin
      c1 = 18'b000000_011100_000000;
      c2 = 18'b000101_010111_000000;
      c3 = 18'b000111_010101_000000;
      c4 = 18'b000000_010111_000101;
      c5 = 18'b000100_010101_000011;            //*
      c6 = 18'b000110_010011_000011;
      c7 = 18'b000000_011001_000011;
      c8 = 18'b000000_011000_000100;
      c9 = 18'b000100_011000_000000;
      c10= 18'b000110_010110_000000;
      c11= 18'b001001_010011_000000;
      c12=  6'b001010;
   end
   else if (fs==29) begin
      c1 = 18'b000000_011101_000000;
      c2 = 18'b000101_011000_000000;
      c3 = 18'b001000_010101_000000;
      c4 = 18'b000000_011000_000101;
      c5 = 18'b000100_010101_000100;
      c6 = 18'b000110_010100_000011;
      c7 = 18'b000000_011010_000011;
      c8 = 18'b000000_011001_000100;
      c9 = 18'b000100_011001_000000;
      c10= 18'b000110_010111_000000;
      c11= 18'b001001_010100_000000;
      c12=  6'b001011;
   end
   else if (fs==30) begin
      c1 = 18'b000000_011110_000000;
      c2 = 18'b000110_011000_000000;
      c3 = 18'b001000_010110_000000;
      c4 = 18'b000000_011001_000101;
      c5 = 18'b000100_010110_000100;
      c6 = 18'b000110_010101_000011;
      c7 = 18'b000000_011011_000011;
      c8 = 18'b000000_011010_000100;
      c9 = 18'b000100_011010_000000;
      c10= 18'b000110_011000_000000;
      c11= 18'b001001_010101_000000;
      c12=  6'b001100;
   end
   else if (fs==31) begin
      c1 = 18'b000000_011111_000000;
      c2 = 18'b000110_011001_000000;
      c3 = 18'b001000_010111_000000;
      c4 = 18'b000000_011001_000110;
      c5 = 18'b000100_010111_000100;
      c6 = 18'b000111_010101_000011;    //*
      c7 = 18'b000000_011011_000100;
      c8 = 18'b000000_011011_000100;
      c9 = 18'b000100_011011_000000;
      c10= 18'b000111_011000_000000;
      c11= 18'b001010_010101_000000;    //*
      c12=  6'b001010;
   end
   else if (fs==32) begin
      c1 = 18'b000000_100000_000000;
      c2 = 18'b000110_011010_000000;
      c3 = 18'b001000_011000_000000;
      c4 = 18'b000000_011010_000110;
      c5 = 18'b000100_011000_000100;
      c6 = 18'b000111_010110_000011;     //*
      c7 = 18'b000000_011100_000100;
      c8 = 18'b000000_011100_000100;
      c9 = 18'b000100_011100_000000;
      c10= 18'b000111_011001_000000;
      c11= 18'b001010_010110_000000;    //*
      c12=  6'b001011;
   end
   else if (fs==33) begin
      c1 = 18'b000000_100001_000000;
      c2 = 18'b000110_011011_000000;
      c3 = 18'b001001_011000_000000;
      c4 = 18'b000000_011011_000110;
      c5 = 18'b000101_011000_000100;    //*
      c6 = 18'b000111_010111_000011;    //*
      c7 = 18'b000000_011101_000100;
      c8 = 18'b000000_011100_000101;
      c9 = 18'b000101_011100_000000;
      c10= 18'b000111_011010_000000;
      c11= 18'b001010_010111_000000;    //*
      c12=  6'b001100;
   end
   else if (fs==34) begin
      c1 = 18'b000000_100010_000000;
      c2 = 18'b000110_011100_000000;
      c3 = 18'b001001_011001_000000;
      c4 = 18'b000000_011100_000110;
      c5 = 18'b000101_011001_000100;    //*
      c6 = 18'b000111_010111_000100;
      c7 = 18'b000000_011110_000100;
      c8 = 18'b000000_011101_000101;
      c9 = 18'b000101_011101_000000;
      c10= 18'b000111_011011_000000;
      c11= 18'b001011_010111_000000;
      c12=  6'b001100;
   end
   else if (fs==35) begin
      c1 = 18'b000000_100011_000000;
      c2 = 18'b000110_011101_000000;
      c3 = 18'b001001_011010_000000;
      c4 = 18'b000000_011101_000110;
      c5 = 18'b000101_011010_000100;    //*
      c6 = 18'b000111_011000_000100;
      c7 = 18'b000000_011111_000100;
      c8 = 18'b000000_011110_000101;
      c9 = 18'b000101_011110_000000;
      c10= 18'b000111_011100_000000;
      c11= 18'b001011_011000_000000;
      c12=  6'b001101;
   end
   else if (fs==36) begin
      c1 = 18'b000000_100100_000000;
      c2 = 18'b000111_011101_000000;
      c3 = 18'b001001_011011_000000;
      c4 = 18'b000000_011110_000110;
      c5 = 18'b000101_011011_000100;    //*
      c6 = 18'b001000_011001_000011;    //*
      c7 = 18'b000000_100000_000100;
      c8 = 18'b000000_011111_000101;
      c9 = 18'b000101_011111_000000;
      c10= 18'b001000_011100_000000;
      c11= 18'b001011_011001_000000;    //*
      c12=  6'b001101;
   end
   else if (fs==37) begin
      c1 = 18'b000000_100101_000000;
      c2 = 18'b000111_011110_000000;
      c3 = 18'b001010_011011_000000;
      c4 = 18'b000000_011110_000111;
      c5 = 18'b000101_011011_000101;
      c6 = 18'b001000_011001_000100;
      c7 = 18'b000000_100001_000100;
      c8 = 18'b000000_100000_000101;
      c9 = 18'b000101_100000_000000;
      c10= 18'b001000_011101_000000;
      c11= 18'b001100_011001_000000;
      c12=  6'b001101;
   end
   else if (fs==38) begin
      c1 = 18'b000000_100110_000000;
      c2 = 18'b000111_011111_000000;
      c3 = 18'b001010_011100_000000;
      c4 = 18'b000000_011111_000111;
      c5 = 18'b000101_011100_000101;
      c6 = 18'b001000_011010_000100;
      c7 = 18'b000000_100010_000100;
      c8 = 18'b000000_100001_000101;
      c9 = 18'b000101_100001_000000;
      c10= 18'b001000_011110_000000;
      c11= 18'b001100_011010_000000;
      c12=  6'b001110;
   end
   else if (fs==39) begin
      c1 = 18'b000000_100111_000000;
      c2 = 18'b000111_100000_000000;
      c3 = 18'b001010_011101_000000;
      c4 = 18'b000000_100000_000111;
      c5 = 18'b000101_011101_000101;
      c6 = 18'b001000_011011_000100;
      c7 = 18'b000000_100011_000100;
      c8 = 18'b000000_100010_000101;
      c9 = 18'b000101_100010_000000;
      c10= 18'b001000_011111_000000;
      c11= 18'b001100_011011_000000;
      c12=  6'b001111;
   end
   else if (fs==40) begin
      c1 = 18'b000000_101000_000000;
      c2 = 18'b000111_100001_000000;
      c3 = 18'b001010_011110_000000;
      c4 = 18'b000000_100001_000111;
      c5 = 18'b000101_011110_000101;
      c6 = 18'b001000_011100_000100;
      c7 = 18'b000000_100100_000100;
      c8 = 18'b000000_100011_000101;
      c9 = 18'b000101_100011_000000;
      c10= 18'b001000_100000_000000;
      c11= 18'b001100_011100_000000;
      c12=  6'b010000;
   end
   else if (fs==41) begin
      c1 = 18'b000000_101001_000000;
      c2 = 18'b000111_100010_000000;
      c3 = 18'b001011_011110_000000;
      c4 = 18'b000000_100010_000111;
      c5 = 18'b000110_011110_000110;
      c6 = 18'b001001_011100_000100;    //*
      c7 = 18'b000000_100100_000101;
      c8 = 18'b000000_100011_000110;
      c9 = 18'b000110_100011_000000;
      c10= 18'b001001_100000_000000;
      c11= 18'b001101_011100_000000;    //*
      c12=  6'b001110;
   end
   else if (fs==42) begin
      c1 = 18'b000000_101010_000000;
      c2 = 18'b001000_100010_000000;
      c3 = 18'b001011_011111_000000;
      c4 = 18'b000000_100011_000111;
      c5 = 18'b000110_011111_000110;
      c6 = 18'b001001_011101_000101;
      c7 = 18'b000000_100101_000101;
      c8 = 18'b000000_100100_000110;
      c9 = 18'b000110_100100_000000;
      c10= 18'b001001_100001_000000;
      c11= 18'b001110_011101_000000;
      c12=  6'b001111;
   end
   else if (fs==43) begin
      c1 = 18'b000000_101011_000000;
      c2 = 18'b001000_100011_000000;
      c3 = 18'b001011_100000_000000;
      c4 = 18'b000000_100011_001000;
      c5 = 18'b000110_100000_000110;
      c6 = 18'b001001_011110_000101;
      c7 = 18'b000000_100110_000101;
      c8 = 18'b000000_100101_000110;
      c9 = 18'b000110_100101_000000;
      c10= 18'b001001_100010_000000;
      c11= 18'b001110_011110_000000;
      c12=  6'b010000;
   end
   else if (fs==44) begin
      c1 = 18'b000000_101100_000000;
      c2 = 18'b001000_100100_000000;
      c3 = 18'b001011_100001_000000;
      c4 = 18'b000000_100100_001000;
      c5 = 18'b000110_100001_000110;
      c6 = 18'b001001_011110_000101;
      c7 = 18'b000000_100111_000101;
      c8 = 18'b000000_100110_000110;
      c9 = 18'b000110_100110_000000;
      c10= 18'b001001_100011_000000;
      c11= 18'b001110_011110_000000;
      c12=  6'b010000;
   end
   else if (fs==45) begin
      c1 = 18'b000000_101101_000000;
      c2 = 18'b001000_100101_000000;
      c3 = 18'b001100_100001_000000;
      c4 = 18'b000000_100101_001000;
      c5 = 18'b000110_100001_000110;
      c6 = 18'b001001_011111_000101;
      c7 = 18'b000000_101000_000101;
      c8 = 18'b000000_100111_000110;
      c9 = 18'b000110_100111_000000;
      c10= 18'b001001_100100_000000;
      c11= 18'b001110_011111_000000;
      c12=  6'b010001;
   end
   else if (fs==46) begin
      c1 = 18'b000000_101110_000000;
      c2 = 18'b001000_100110_000000;
      c3 = 18'b001100_100010_000000;
      c4 = 18'b000000_100110_001000;
      c5 = 18'b000110_100010_000110;
      c6 = 18'b001010_100000_000101;
      c7 = 18'b000000_101001_000101;
      c8 = 18'b000000_101000_000110;
      c9 = 18'b000110_101000_000000;
      c10= 18'b001010_100100_000000;
      c11= 18'b001111_100000_000000;
      c12=  6'b010001;
   end
   else if (fs==47) begin
      c1 = 18'b000000_101111_000000;
      c2 = 18'b001000_100111_000000;
      c3 = 18'b001100_100011_000000;
      c4 = 18'b000000_100111_001000;
      c5 = 18'b000110_100011_000110;
      c6 = 18'b001010_100000_000101;
      c7 = 18'b000000_101010_000101;
      c8 = 18'b000000_101001_000110;
      c9 = 18'b000110_101001_000000;
      c10= 18'b001010_100101_000000;
      c11= 18'b001111_100000_000000;
      c12=  6'b010001;
   end
   else if (fs==48) begin
      c1 = 18'b000000_110000_000000;
      c2 = 18'b001001_100111_000000;
      c3 = 18'b001100_100100_000000;
      c4 = 18'b000000_101000_001000;
      c5 = 18'b000110_100100_000110;
      c6 = 18'b001010_100001_000101;
      c7 = 18'b000000_101011_000101;
      c8 = 18'b000000_101010_000110;
      c9 = 18'b000110_101010_000000;
      c10= 18'b001010_100110_000000;
      c11= 18'b001111_100001_000000;
      c12=  6'b010010;
   end
   else if (fs==49) begin
      c1 = 18'b000000_110001_000000;
      c2 = 18'b001001_101000_000000;
      c3 = 18'b001101_100100_000000;
      c4 = 18'b000000_101000_001001;
      c5 = 18'b000111_100100_000110;    //*
      c6 = 18'b001010_100010_000101;
      c7 = 18'b000000_101100_000101;
      c8 = 18'b000000_101010_000111;
      c9 = 18'b000111_101010_000000;
      c10= 18'b001010_100111_000000;
      c11= 18'b001111_100010_000000;
      c12=  6'b010011;
   end
   else if (fs==50) begin
      c1 = 18'b000000_110010_000000;
      c2 = 18'b001001_101001_000000;
      c3 = 18'b001101_100101_000000;
      c4 = 18'b000000_101001_001001;
      c5 = 18'b000111_100101_000110;    //*
      c6 = 18'b001010_100011_000101;
      c7 = 18'b000000_101101_000101;
      c8 = 18'b000000_101011_000111;
      c9 = 18'b000111_101011_000000;
      c10= 18'b001010_101000_000000;
      c11= 18'b001111_100011_000000;
      c12=  6'b010100;
   end
   else if (fs==51) begin
      c1 = 18'b000000_110011_000000;
      c2 = 18'b001001_101010_000000;
      c3 = 18'b001101_100110_000000;
      c4 = 18'b000000_101010_001001;
      c5 = 18'b000111_100110_000110;    //*
      c6 = 18'b001011_100011_000101;    //*
      c7 = 18'b000000_101101_000110;
      c8 = 18'b000000_101100_000111;
      c9 = 18'b000111_101100_000000;
      c10= 18'b001011_101000_000000;
      c11= 18'b010000_100011_000000;    //*
      c12=  6'b010010;
   end
   else if (fs==52) begin
      c1 = 18'b000000_110100_000000;
      c2 = 18'b001001_101011_000000;
      c3 = 18'b001101_100111_000000;
      c4 = 18'b000000_101011_001001;
      c5 = 18'b000111_100111_000110;    //*
      c6 = 18'b001011_100100_000101;    //*
      c7 = 18'b000000_101110_000110;
      c8 = 18'b000000_101101_000111;
      c9 = 18'b000111_101101_000000;
      c10= 18'b001011_101001_000000;
      c11= 18'b010000_100100_000000;    //*
      c12=  6'b010011;
   end
   else if (fs==53) begin
      c1 = 18'b000000_110101_000000;
      c2 = 18'b001001_101100_000000;
      c3 = 18'b001110_100111_000000;
      c4 = 18'b000000_101100_001001;
      c5 = 18'b000111_100111_000111;
      c6 = 18'b001011_100101_000101;    //*
      c7 = 18'b000000_101111_000110;
      c8 = 18'b000000_101110_000111;
      c9 = 18'b000111_101110_000000;
      c10= 18'b001011_101010_000000;
      c11= 18'b010000_100101_000000;    //*
      c12=  6'b010100;
   end
   else if (fs==54) begin
      c1 = 18'b000000_110110_000000;
      c2 = 18'b001010_101100_000000;
      c3 = 18'b001110_101000_000000;
      c4 = 18'b000000_101101_001001;
      c5 = 18'b000111_101000_000111;
      c6 = 18'b001011_100101_000110;
      c7 = 18'b000000_110000_000110;
      c8 = 18'b000000_101111_000111;
      c9 = 18'b000111_101111_000000;
      c10= 18'b001011_101011_000000;
      c11= 18'b010001_100101_000000;
      c12=  6'b010100;
   end
   else if (fs==55) begin
      c1 = 18'b000000_110111_000000;
      c2 = 18'b001010_101101_000000;
      c3 = 18'b001110_101001_000000;
      c4 = 18'b000000_101101_001010;
      c5 = 18'b000111_101001_000111;
      c6 = 18'b001011_100110_000110;
      c7 = 18'b000000_110001_000110;
      c8 = 18'b000000_110000_000111;
      c9 = 18'b000111_110000_000000;
      c10= 18'b001011_101100_000000;
      c11= 18'b010001_100110_000000;
      c12=  6'b010101;
   end
   else if (fs==56) begin
      c1 = 18'b000000_111000_000000;
      c2 = 18'b001010_101110_000000;
      c3 = 18'b001110_101010_000000;
      c4 = 18'b000000_101110_001010;
      c5 = 18'b000111_101010_000111;
      c6 = 18'b001100_100111_000101;    //*
      c7 = 18'b000000_110010_000110;
      c8 = 18'b000000_110001_000111;
      c9 = 18'b000111_110001_000000;
      c10= 18'b001100_101100_000000;
      c11= 18'b010001_100111_000000;    //*
      c12=  6'b010101;
   end
   else if (fs==57) begin
      c1 = 18'b000000_111001_000000;
      c2 = 18'b001010_101111_000000;
      c3 = 18'b001111_101010_000000;
      c4 = 18'b000000_101111_001010;
      c5 = 18'b001000_101010_000111;    //*
      c6 = 18'b001100_100111_000110;
      c7 = 18'b000000_110011_000110;
      c8 = 18'b000000_110001_001000;
      c9 = 18'b001000_110001_000000;
      c10= 18'b001100_101101_000000;
      c11= 18'b010010_100111_000000;
      c12=  6'b010101;
   end
   else if (fs==58) begin
      c1 = 18'b000000_111010_000000;
      c2 = 18'b001010_110000_000000;
      c3 = 18'b001111_101011_000000;
      c4 = 18'b000000_110000_001010;
      c5 = 18'b001000_101011_000111;    //*
      c6 = 18'b001100_101000_000110;
      c7 = 18'b000000_110100_000110;
      c8 = 18'b000000_110010_001000;
      c9 = 18'b001000_110010_000000;
      c10= 18'b001100_101110_000000;
      c11= 18'b010010_101000_000000;
      c12=  6'b010110;
   end
   else if (fs==59) begin
      c1 = 18'b000000_111011_000000;
      c2 = 18'b001010_110001_000000;
      c3 = 18'b001111_101100_000000;
      c4 = 18'b000000_110001_001010;
      c5 = 18'b001000_101100_000111;    //*
      c6 = 18'b001100_101001_000110;
      c7 = 18'b000000_110101_000110;
      c8 = 18'b000000_110011_001000;
      c9 = 18'b001000_110011_000000;
      c10= 18'b001100_101111_000000;
      c11= 18'b010010_101001_000000;
      c12=  6'b010111;
   end
   else if (fs==60) begin
      c1 = 18'b000000_111100_000000;
      c2 = 18'b001011_110001_000000;
      c3 = 18'b001111_101101_000000;
      c4 = 18'b000000_110010_001010;
      c5 = 18'b001000_101101_000111;    //*
      c6 = 18'b001100_101010_000110;
      c7 = 18'b000000_110110_000110;
      c8 = 18'b000000_110100_001000;
      c9 = 18'b001000_110100_000000;
      c10= 18'b001100_110000_000000;
      c11= 18'b010010_101010_000000;
      c12=  6'b011000;
   end
   else if (fs==61) begin
      c1 = 18'b000000_111101_000000;
      c2 = 18'b001011_110010_000000;
      c3 = 18'b010000_101101_000000;
      c4 = 18'b000000_110010_001011;
      c5 = 18'b001000_101101_001000;
      c6 = 18'b001101_101010_000110;
      c7 = 18'b000000_110110_000111;
      c8 = 18'b000000_110101_001000;
      c9 = 18'b001000_110101_000000;
      c10= 18'b001101_110000_000000;
      c11= 18'b010011_101010_000000;
      c12=  6'b010110;
   end
   else if (fs==62) begin
      c1 = 18'b000000_111110_000000;
      c2 = 18'b001011_110011_000000;
      c3 = 18'b010000_101110_000000;
      c4 = 18'b000000_110011_001011;
      c5 = 18'b001000_101110_001000;
      c6 = 18'b001101_101011_000110;    //*
      c7 = 18'b000000_110111_000111;
      c8 = 18'b000000_110110_001000;
      c9 = 18'b001000_110110_000000;
      c10= 18'b001101_110001_000000;
      c11= 18'b010011_101011_000000;    //*
      c12=  6'b010111;
   end
   else if (fs==63) begin
      c1 = 18'b000000_111111_000000;
      c2 = 18'b001011_110100_000000;
      c3 = 18'b010000_101111_000000;
      c4 = 18'b000000_110100_001011;
      c5 = 18'b001000_101111_001000;
      c6 = 18'b001101_101100_000110;    //*
      c7 = 18'b000000_111000_000111;
      c8 = 18'b000000_110111_001000;
      c9 = 18'b001000_110111_000000;
      c10= 18'b001101_110010_000000;
      c11= 18'b010011_101100_000000;    //*
      c12=  6'b011000;
   end

   get_coef = {c12, c11, c10, c9, c8, c7, c6, c5, c4, c3, c2, c1};

   end
endfunction

localparam [203:0] g3_preset_coeffs = get_coef(full_swing_hwtcl);

localparam [17:0] gen3_preset_coeff_5     = (hwtcl_override_g3txcoef==1)?gen3_preset_coeff_5_hwtcl  [17:0] : (fixed_preset_on==1)?g3_preset_coeffs[53:36]:g3_preset_coeffs[17:0];
localparam [17:0] gen3_preset_coeff_2     = (hwtcl_override_g3txcoef==1)?gen3_preset_coeff_2_hwtcl  [17:0] : (fixed_preset_on==1)?g3_preset_coeffs[53:36]:g3_preset_coeffs[35:18];
localparam [17:0] gen3_preset_coeff_1     = (hwtcl_override_g3txcoef==1)?gen3_preset_coeff_1_hwtcl  [17:0] : g3_preset_coeffs[53:36];
localparam [17:0] gen3_preset_coeff_10    = (hwtcl_override_g3txcoef==1)?gen3_preset_coeff_10_hwtcl [17:0] : (fixed_preset_on==1)?g3_preset_coeffs[53:36]:g3_preset_coeffs[71:54];
localparam [17:0] gen3_preset_coeff_9     = (hwtcl_override_g3txcoef==1)?gen3_preset_coeff_9_hwtcl  [17:0] : (fixed_preset_on==1)?g3_preset_coeffs[53:36]:g3_preset_coeffs[89:72];
localparam [17:0] gen3_preset_coeff_8     = (hwtcl_override_g3txcoef==1)?gen3_preset_coeff_8_hwtcl  [17:0] : (fixed_preset_on==1)?g3_preset_coeffs[53:36]:g3_preset_coeffs[107:90];
localparam [17:0] gen3_preset_coeff_6     = (hwtcl_override_g3txcoef==1)?gen3_preset_coeff_6_hwtcl  [17:0] : (fixed_preset_on==1)?g3_preset_coeffs[53:36]:g3_preset_coeffs[125:108];
localparam [17:0] gen3_preset_coeff_7     = (hwtcl_override_g3txcoef==1)?gen3_preset_coeff_7_hwtcl  [17:0] : (fixed_preset_on==1)?g3_preset_coeffs[53:36]:g3_preset_coeffs[143:126];
localparam [17:0] gen3_preset_coeff_4     = (hwtcl_override_g3txcoef==1)?gen3_preset_coeff_4_hwtcl  [17:0] : (fixed_preset_on==1)?g3_preset_coeffs[53:36]:g3_preset_coeffs[161:144];
localparam [17:0] gen3_preset_coeff_3     = (hwtcl_override_g3txcoef==1)?gen3_preset_coeff_3_hwtcl  [17:0] : (fixed_preset_on==1)?g3_preset_coeffs[53:36]:g3_preset_coeffs[179:162];
localparam [17:0] gen3_preset_coeff_11    = (hwtcl_override_g3txcoef==1)?gen3_preset_coeff_11_hwtcl [17:0] : (fixed_preset_on==1)?g3_preset_coeffs[53:36]:g3_preset_coeffs[197:180];
localparam [5:0]  gen3_low_freq           = (hwtcl_override_g3txcoef==1)?gen3_low_freq_hwtcl        [5:0]  : g3_preset_coeffs[203:198];
localparam [5:0]  gen3_full_swing         = (hwtcl_override_g3txcoef==1)?full_swing_hwtcl           [5:0]  : gen3_full_swing_hwtcl[5:0];
localparam [19:0] gen3_rxfreqlock_counter = gen3_rxfreqlock_counter_hwtcl                           [19:0] ;

//Pre-emphasis and VOD static values
localparam [5:0] rpre_emph_a_val = (hwtcl_override_g2_txvod==1)?rpre_emph_a_val_hwtcl[5:0] :6'b001001;
localparam [5:0] rpre_emph_b_val = (hwtcl_override_g2_txvod==1)?rpre_emph_b_val_hwtcl[5:0] :6'b000000;
localparam [5:0] rpre_emph_c_val = (hwtcl_override_g2_txvod==1)?rpre_emph_c_val_hwtcl[5:0] :6'b010000;
localparam [5:0] rpre_emph_d_val = (hwtcl_override_g2_txvod==1)?rpre_emph_d_val_hwtcl[5:0] :6'b001101;
localparam [5:0] rpre_emph_e_val = (hwtcl_override_g2_txvod==1)?rpre_emph_e_val_hwtcl[5:0] :6'b000101;
localparam [5:0] rvod_sel_a_val  = (hwtcl_override_g2_txvod==1)?rvod_sel_a_val_hwtcl [5:0] :6'b101010;
localparam [5:0] rvod_sel_b_val  = (hwtcl_override_g2_txvod==1)?rvod_sel_b_val_hwtcl [5:0] :6'b100110;
localparam [5:0] rvod_sel_c_val  = (hwtcl_override_g2_txvod==1)?rvod_sel_c_val_hwtcl [5:0] :6'b100110;
localparam [5:0] rvod_sel_d_val  = (hwtcl_override_g2_txvod==1)?rvod_sel_d_val_hwtcl [5:0] :6'b101011;
localparam [5:0] rvod_sel_e_val  = (hwtcl_override_g2_txvod==1)?rvod_sel_e_val_hwtcl [5:0] :6'b001111;


/////////////////////////////// TLP Inspector

localparam TLP_INSPECTOR                           = tlp_inspector_hwtcl;
localparam TLP_INSPECTOR_USE_SIGNAL_PROBE          = tlp_inspector_use_signal_probe_hwtcl;
localparam [127:0] TLP_INSPECTOR_POWER_UP_TRIGGER  = {tlp_insp_trg_dw3_hwtcl[31:0],tlp_insp_trg_dw2_hwtcl[31:0],tlp_insp_trg_dw1_hwtcl[31:0],tlp_insp_trg_dw0_hwtcl[31:0] };

// Input for internal test port (PE/TE)

wire                 gnd_frzlogic           = 1'b0;
wire                 gnd_frzreg             = 1'b0;
wire  [7 : 0]        gnd_idrcv              = QW_ZERO[7 : 0];
wire  [7 : 0]        gnd_idrpl              = QW_ZERO[7 : 0];
wire                 gnd_bistenrcv          = 1'b0;
wire                 gnd_bistenrpl          = 1'b0;
wire                 gnd_bistscanen         = 1'b0;
wire                 gnd_bistscanin         = 1'b0;
wire                 gnd_bisttesten         = 1'b0;
wire                 gnd_memhiptestenable   = 1'b0;
wire                 gnd_memredenscan       = 1'b0;
wire                 gnd_memredscen         = 1'b0;
wire                 gnd_memredscin         = 1'b0;
wire                 gnd_memredsclk         = 1'b0;
wire                 gnd_memredscrst        = 1'b0;
wire                 gnd_memredscsel        = 1'b0;
wire                 gnd_memregscanen       = 1'b0;
wire                 gnd_memregscanin       = 1'b0;
wire                 gnd_scanmoden          = 1'b0;
wire                 gnd_usermode           = 1'b0;
wire                 gnd_scanshiftn         = 1'b0;
wire                 gnd_nfrzdrv            = 1'b0;
// Input for past QII 10.0 support
wire  [31 : 0]       gnd_csebrddata         = QW_ZERO[31 : 0];
wire  [3 : 0]        gnd_csebrddataparity   = QW_ZERO[3 : 0];
wire  [4 : 0]        gnd_csebrdresponse     = QW_ZERO[4 : 0];
wire                 gnd_csebwaitrequest    = 1'b0;
wire  [4 : 0]        gnd_csebwrresponse     = QW_ZERO[4 : 0];
wire                 gnd_csebwrrespvalid    = 1'b0;
wire  [1 : 0]        gnd_swctmod            = QW_ZERO[1 : 0];
wire [43:0]          gnd_dbgpipex1rx        = 44'h0;


wire [3 :0]        tx_st_eop_int;
wire [3 :0]        tx_st_err_int;
wire [3 :0]        tx_st_sop_int;
wire [255 : 0]     tx_st_data_int;
wire [31 : 0]      tx_st_parity_int;
wire [255 : 0]     rx_st_data_int;
wire [31 : 0]      rx_st_parity_int;
wire [31 : 0]      rx_st_be_int;
wire [3 : 0]       rx_st_sop_int;
wire [3 : 0]       rx_st_valid_int;
wire [3 : 0]       rx_st_eop_int;
wire [3 : 0]       rx_st_err_int;
wire [7 : 0]       rx_st_bardec1;
wire [7 : 0]       rx_st_bardec2;


wire  [1 : 0]        mode;

// Internal wire for internal test port (PE/TE)
//wire [32 : 0] open_csebaddr;
//wire [4 : 0]  open_csebaddrparity;
//wire [3 : 0]  open_csebbe;
//wire          open_csebisshadow;
//wire          open_csebrden;
//wire [31 : 0] open_csebwrdata;
//wire [3 : 0]  open_csebwrdataparity;
//wire          open_csebwren;
//wire          open_csebwrrespreq;
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

wire  [31 : 0]  reservedin_int;

wire [319:0] testout;
wire [63:0]  testin;
wire         reservedclkin;
wire [31:0]  reservedout;
wire         reservedclkout;

initial begin
   $display("Stratix V Hard IP for PCI Express %s", ACDS_VERSION_HWTCL);
end

assign mode                                             = (port_type_hwtcl=="Native endpoint")?2'b00:2'b10;
assign tx_st_eop_int                                    = (multiple_packets_per_cycle_hwtcl==1)?{2'b00, tx_st_eop}:{3'b000, tx_st_eop};
assign tx_st_err_int                                    = (multiple_packets_per_cycle_hwtcl==1)?{2'b00, tx_st_err}:{3'b000, tx_st_err};
assign tx_st_sop_int                                    = (multiple_packets_per_cycle_hwtcl==1)?{2'b00, tx_st_sop}:{3'b000, tx_st_sop};
assign rx_st_sop   [multiple_packets_per_cycle_hwtcl:0] = (multiple_packets_per_cycle_hwtcl==1)?rx_st_sop_int[1:0]:rx_st_sop_int[0];
assign rx_st_valid [multiple_packets_per_cycle_hwtcl:0] = (multiple_packets_per_cycle_hwtcl==1)?{1'b0,rx_st_valid_int[0]}:rx_st_valid_int[0];
assign rx_st_eop   [multiple_packets_per_cycle_hwtcl:0] = (multiple_packets_per_cycle_hwtcl==1)?rx_st_eop_int[1:0]:rx_st_eop_int[0];
assign rx_st_err   [multiple_packets_per_cycle_hwtcl:0] = (multiple_packets_per_cycle_hwtcl==1)?{1'b0,|rx_st_err_int}:|rx_st_err_int;

assign rx_st_bar       =  rx_st_bardec1[7:0];
assign reservedclkin = 1'b0;

generate begin : g_tx_data
   if (ast_width=="rx_tx_256") begin
      assign tx_st_data_int[255:0]       = tx_st_data[255:0] ;
      assign tx_st_parity_int[31:0]      = tx_st_parity[31:0];
   end
   else if (ast_width=="rx_tx_128") begin
      assign tx_st_data_int[255:0]       = {128'h0,tx_st_data[127:0]};
      assign tx_st_parity_int[31:0]      = {16'h0,tx_st_parity[15:0]};
   end
   else begin
      assign tx_st_data_int[255:0]       = {192'h0,tx_st_data[63:0]};
      assign tx_st_parity_int[31:0]      = {24'h0,tx_st_parity[7:0]};
   end
end
endgenerate

assign rx_st_be[port_width_be_hwtcl-1 :0]      = rx_st_be_int[ port_width_be_hwtcl-1:0];
assign rx_st_parity[port_width_be_hwtcl-1 :0]  = rx_st_parity_int[ port_width_be_hwtcl-1:0];
assign rx_st_data[port_width_data_hwtcl-1 :0]  = rx_st_data_int[ port_width_data_hwtcl-1 :0];

//npor Reset Synchronizer on pld_clk
assign testin_zero             = test_in[0];
assign sim_ltssmstate          = ltssmstate;
assign sim_pipe_pclk_out       = sim_pipe_pclk_in;
assign ko_cpl_spc_header[7 :0] = cpl_spc_header_hwtcl[7 :0];
assign ko_cpl_spc_data [11 :0] = cpl_spc_data_hwtcl[11 :0];
assign rxfc_cplbuf_ovf         = reservedout[1];

//Config. Bypass output ports
assign cfgbp_lane_err               = tl_cfg_sts[52:45];
assign cfgbp_link_equlz_req         = tl_cfg_sts[44];
assign cfgbp_equiz_complete         = tl_cfg_sts[43];
assign cfgbp_phase_3_successful     = tl_cfg_sts[42];
assign cfgbp_phase_2_successful     = tl_cfg_sts[41];
assign cfgbp_phase_1_successful     = tl_cfg_sts[40];
assign cfgbp_current_deemph         = tl_cfg_sts[39];
assign cfgbp_current_speed          = tl_cfg_sts[38:37];
assign cfgbp_link_up                = tl_cfg_sts[26];
assign cfgbp_link_train             = tl_cfg_sts[25];
assign cfgbp_10state                = tl_cfg_sts[24];
assign cfgbp_10sstate               = tl_cfg_sts[23];
assign cfgbp_rx_val_pm              = tl_cfg_sts[19];
assign cfgbp_rx_typ_pm              = tl_cfg_sts[18:16];
assign cfgbp_tx_ack_pm              = tl_cfg_sts[15];
assign cfgbp_ack_phypm              = tl_cfg_sts[12:11];
assign cfgbp_vc_status              = tl_cfg_sts[10];
assign cfgbp_rxfc_max               = tl_cfg_sts[9];
assign cfgbp_txfc_max               = tl_cfg_sts[8];
assign cfgbp_txbuf_emp              = tl_cfg_sts[7];
assign cfgbp_cfgbuf_emp             = tl_cfg_sts[6];
assign cfgbp_rpbuf_emp              = tl_cfg_sts[5];
assign cfgbp_dll_req                = tl_cfg_sts[4];
assign cfgbp_link_auto_bdw_status   = tl_cfg_sts[3];
assign cfgbp_link_bdw_mng_status    = tl_cfg_sts[2];
assign cfgbp_rst_tx_margin_field    = tl_cfg_sts[1];
assign cfgbp_rst_enter_comp_bit     = tl_cfg_sts[0];
assign cfgbp_rx_st_ecrcerr          = rx_st_bardec1[3:0];
assign cfgbp_err_uncorr_internal    = tl_cfg_ctl[15];
assign cfgbp_rx_corr_internal       = tl_cfg_ctl[14];
assign cfgbp_err_tlrcvovf           = tl_cfg_ctl[13];
assign cfgbp_txfc_err               = tl_cfg_ctl[12];
assign cfgbp_err_tlmalf             = tl_cfg_ctl[11];
assign cfgbp_err_surpdwn_dll        = tl_cfg_ctl[10];
assign cfgbp_err_dllrev             = tl_cfg_ctl[9];
assign cfgbp_err_dll_repnum         = tl_cfg_ctl[8];
assign cfgbp_err_dllreptim          = tl_cfg_ctl[7];
assign cfgbp_err_dllp_baddllp       = tl_cfg_ctl[6];
assign cfgbp_err_dll_badtlp         = tl_cfg_ctl[5];
assign cfgbp_err_phy_tng            = tl_cfg_ctl[4];
assign cfgbp_err_phy_rcv            = tl_cfg_ctl[3];
assign cfgbp_root_err_reg_sts       = tl_cfg_ctl[2];
assign cfgbp_corr_err_reg_sts       = tl_cfg_ctl[1];
assign cfgbp_unc_err_reg_sts        = tl_cfg_ctl[0];

assign reservedin_int[31:10]        = reservedin[31:10];
assign reservedin_int[8:0]          = reservedin[8:0];
assign reservedin_int[9]            = (use_tx_cons_cred_sel_hwtcl==1'b1)?tx_cons_cred_sel:reservedin[9];

altpcie_hip_256_pipen1b # (
      .ACDS_V10                                                      (ACDS_V10                                                      ),
      .MEM_CHECK                                                     (MEM_CHECK                                                     ),
      .USE_INTERNAL_250MHZ_PLL                                       (USE_INTERNAL_250MHZ_PLL                                       ),
      .use_config_bypass_hwtcl                                       (use_config_bypass_hwtcl                                       ),
      .pll_refclk_freq                                               (pll_refclk_freq                                               ),
      .enable_pipe32_sim                                             (enable_pipe32_sim                                             ),
      .enable_tl_only_sim                                            (enable_tl_only_sim                                            ),
      .set_pld_clk_x1_625MHz                                         (set_pld_clk_x1_625MHz_hwtcl                                   ),
      .enable_slot_register                                          (enable_slot_register                                          ),
      .pcie_mode                                                     (pcie_mode                                                     ),
      .hip_reconfig                                                  (hip_reconfig_hwtcl                                            ),
      .bypass_cdc                                                    (bypass_cdc                                                    ),
      .enable_power_on_rst_pulse                                     (enable_power_on_rst_pulse                                     ),
      .enable_pcisigtest                                             (enable_pcisigtest_hwtcl                                       ),
      .enable_rx_buffer_checking                                     (enable_rx_buffer_checking                                     ),
      .single_rx_detect                                              (single_rx_detect                                              ),
      .use_crc_forwarding                                            (use_crc_forwarding                                            ),
      .gen123_lane_rate_mode                                         (gen123_lane_rate_mode                                         ),
      .lane_mask                                                     (lane_mask                                                     ),
      .disable_link_x2_support                                       (disable_link_x2_support                                       ),
      .hip_hard_reset                                                (hip_hard_reset                                                ),
      .use_atx_pll                                                   (use_atx_pll                                                   ),
      .dis_paritychk                                                 (dis_paritychk                                                 ),
      .reconfig_to_xcvr_width                                        (reconfig_to_xcvr_width                                        ),
      .reconfig_from_xcvr_width                                      (reconfig_from_xcvr_width                                      ),
      .wrong_device_id                                               (wrong_device_id                                               ),
      .data_pack_rx                                                  (data_pack_rx                                                  ),
      .ast_width                                                     (ast_width                                                     ),
      .rx_sop_ctrl                                                   (rx_sop_ctrl                                                   ),
      .tx_sop_ctrl                                                   (tx_sop_ctrl                                                   ),
      .rx_ast_parity                                                 (rx_ast_parity                                                 ),
      .tx_ast_parity                                                 (tx_ast_parity                                                 ),
      .ltssm_1ms_timeout                                             (ltssm_1ms_timeout                                             ),
      .ltssm_freqlocked_check                                        (ltssm_freqlocked_check                                        ),
      .deskew_comma                                                  (deskew_comma                                                  ),
      .port_link_number                                              (port_link_number                                              ),
      .device_number                                                 (device_number                                                 ),
      .bypass_clk_switch                                             (bypass_clk_switch                                             ),
      .pipex1_debug_sel                                              (pipex1_debug_sel                                              ),
      .pclk_out_sel                                                  (pclk_out_sel                                                  ),
      .vendor_id                                                     (vendor_id                                                     ),
      .device_id                                                     (device_id                                                     ),
      .revision_id                                                   (revision_id                                                   ),
      .class_code                                                    (class_code                                                    ),
      .subsystem_vendor_id                                           (subsystem_vendor_id                                           ),
      .subsystem_device_id                                           (subsystem_device_id                                           ),
      .no_soft_reset                                                 (no_soft_reset                                                 ),
      .maximum_current                                               (maximum_current                                               ),
      .d1_support                                                    (d1_support                                                    ),
      .d2_support                                                    (d2_support                                                    ),
      .d0_pme                                                        (d0_pme                                                        ),
      .d1_pme                                                        (d1_pme                                                        ),
      .d2_pme                                                        (d2_pme                                                        ),
      .d3_hot_pme                                                    (d3_hot_pme                                                    ),
      .d3_cold_pme                                                   (d3_cold_pme                                                   ),
      .use_aer                                                       (use_aer                                                       ),
      .low_priority_vc                                               (low_priority_vc                                               ),
      .disable_snoop_packet                                          (disable_snoop_packet                                          ),
      .max_payload_size                                              (max_payload_size                                              ),
      .surprise_down_error_support                                   (surprise_down_error_support                                   ),
      .dll_active_report_support                                     (dll_active_report_support                                     ),
      .extend_tag_field                                              (extend_tag_field                                              ),
      .endpoint_l0_latency                                           (endpoint_l0_latency                                           ),
      .endpoint_l1_latency                                           (endpoint_l1_latency                                           ),
      .indicator                                                     (indicator                                                     ),
      .slot_power_scale                                              (slot_power_scale                                              ),
      .max_link_width                                                (max_link_width                                                ),
      .enable_l0s_aspm                                               (enable_l0s_aspm                                               ),
      .enable_l1_aspm                                                (enable_l1_aspm                                                ),
      .l1_exit_latency_sameclock                                     (l1_exit_latency_sameclock                                     ),
      .l1_exit_latency_diffclock                                     (l1_exit_latency_diffclock                                     ),
      .hot_plug_support                                              (hot_plug_support                                              ),
      .slot_power_limit                                              (slot_power_limit                                              ),
      .slot_number                                                   (slot_number                                                   ),
      .diffclock_nfts_count                                          (diffclock_nfts_count                                          ),
      .sameclock_nfts_count                                          (sameclock_nfts_count                                          ),
      .completion_timeout                                            (completion_timeout                                            ),
      .enable_completion_timeout_disable                             (enable_completion_timeout_disable                             ),
      .extended_tag_reset                                            (extended_tag_reset                                            ),
      .ecrc_check_capable                                            (ecrc_check_capable                                            ),
      .ecrc_gen_capable                                              (ecrc_gen_capable                                              ),
      .no_command_completed                                          (no_command_completed                                          ),
      .msi_multi_message_capable                                     (msi_multi_message_capable                                     ),
      .msi_64bit_addressing_capable                                  (msi_64bit_addressing_capable                                  ),
      .msi_masking_capable                                           (msi_masking_capable                                           ),
      .msi_support                                                   (msi_support                                                   ),
      .interrupt_pin                                                 (interrupt_pin                                                 ),
      .enable_function_msix_support                                  (enable_function_msix_support                                  ),
      .msix_table_size                                               (msix_table_size                                               ),
      .msix_table_bir                                                (msix_table_bir                                                ),
      .msix_table_offset                                             (msix_table_offset  >> 3                                       ),
      .msix_pba_bir                                                  (msix_pba_bir                                                  ),
      .msix_pba_offset                                               (msix_pba_offset >> 3                                          ),
      .bridge_port_vga_enable                                        (bridge_port_vga_enable                                        ),
      .bridge_port_ssid_support                                      (bridge_port_ssid_support                                      ),
      .ssvid                                                         (ssvid                                                         ),
      .ssid                                                          (ssid                                                          ),
      .eie_before_nfts_count                                         (eie_before_nfts_count                                         ),
      .gen2_diffclock_nfts_count                                     (gen2_diffclock_nfts_count                                     ),
      .gen2_sameclock_nfts_count                                     (gen2_sameclock_nfts_count                                     ),
      .deemphasis_enable                                             (deemphasis_enable                                             ),
      .pcie_spec_version                                             (pcie_spec_version                                             ),
      .l0_exit_latency_sameclock                                     (l0_exit_latency_sameclock                                     ),
      .l0_exit_latency_diffclock                                     (l0_exit_latency_diffclock                                     ),
      .rx_ei_l0s                                                     (rx_ei_l0s                                                     ),
      .l2_async_logic                                                (l2_async_logic                                                ),
      .aspm_config_management                                        (aspm_config_management                                        ),
      .atomic_op_routing                                             (atomic_op_routing                                             ),
      .atomic_op_completer_32bit                                     (atomic_op_completer_32bit                                     ),
      .atomic_op_completer_64bit                                     (atomic_op_completer_64bit                                     ),
      .cas_completer_128bit                                          (cas_completer_128bit                                          ),
      .ltr_mechanism                                                 (ltr_mechanism                                                 ),
      .tph_completer                                                 (tph_completer                                                 ),
      .extended_format_field                                         (extended_format_field                                         ),
      .atomic_malformed                                              (atomic_malformed                                              ),
      .flr_capability                                                (flr_capability                                                ),
      .enable_adapter_half_rate_mode                                 (enable_adapter_half_rate_mode                                 ),
      .vc0_clk_enable                                                (vc0_clk_enable                                                ),
      .register_pipe_signals                                         (register_pipe_signals                                         ),
      .bar0_io_space                                                 (bar0_io_space                                                 ),
      .bar0_64bit_mem_space                                          (bar0_64bit_mem_space                                          ),
      .bar0_prefetchable                                             (bar0_prefetchable                                             ),
      .bar0_size_mask                                                (bar0_size_mask                                                ),
      .bar1_io_space                                                 (bar1_io_space                                                 ),
      .bar1_64bit_mem_space                                          (bar1_64bit_mem_space                                          ),
      .bar1_prefetchable                                             (bar1_prefetchable                                             ),
      .bar1_size_mask                                                (bar1_size_mask                                                ),
      .bar2_io_space                                                 (bar2_io_space                                                 ),
      .bar2_64bit_mem_space                                          (bar2_64bit_mem_space                                          ),
      .bar2_prefetchable                                             (bar2_prefetchable                                             ),
      .bar2_size_mask                                                (bar2_size_mask                                                ),
      .bar3_io_space                                                 (bar3_io_space                                                 ),
      .bar3_64bit_mem_space                                          (bar3_64bit_mem_space                                          ),
      .bar3_prefetchable                                             (bar3_prefetchable                                             ),
      .bar3_size_mask                                                (bar3_size_mask                                                ),
      .bar4_io_space                                                 (bar4_io_space                                                 ),
      .bar4_64bit_mem_space                                          (bar4_64bit_mem_space                                          ),
      .bar4_prefetchable                                             (bar4_prefetchable                                             ),
      .bar4_size_mask                                                (bar4_size_mask                                                ),
      .bar5_io_space                                                 (bar5_io_space                                                 ),
      .bar5_64bit_mem_space                                          (bar5_64bit_mem_space                                          ),
      .bar5_prefetchable                                             (bar5_prefetchable                                             ),
      .bar5_size_mask                                                (bar5_size_mask                                                ),
      .expansion_base_address_register                               (expansion_base_address_register                               ),
      .io_window_addr_width                                          (io_window_addr_width                                          ),
      .prefetchable_mem_window_addr_width                            (prefetchable_mem_window_addr_width                            ),
      .skp_os_gen3_count                                             (skp_os_gen3_count                                             ),
      .tx_cdc_almost_empty                                           (tx_cdc_almost_empty                                           ),
      .rx_cdc_almost_full                                            (rx_cdc_almost_full                                            ),
      .tx_cdc_almost_full                                            (tx_cdc_almost_full                                            ),
      .rx_l0s_count_idl                                              (rx_l0s_count_idl                                              ),
      .cdc_dummy_insert_limit                                        (cdc_dummy_insert_limit                                        ),
      .ei_delay_powerdown_count                                      (ei_delay_powerdown_count                                      ),
      .millisecond_cycle_count                                       (millisecond_cycle_count                                       ),
      .skp_os_schedule_count                                         (skp_os_schedule_count                                         ),
      .fc_init_timer                                                 (fc_init_timer                                                 ),
      .l01_entry_latency                                             (l01_entry_latency                                             ),
      .flow_control_update_count                                     (flow_control_update_count                                     ),
      .flow_control_timeout_count                                    (flow_control_timeout_count                                    ),
      .vc0_rx_flow_ctrl_posted_header                                (vc0_rx_flow_ctrl_posted_header                                ),
      .vc0_rx_flow_ctrl_posted_data                                  (vc0_rx_flow_ctrl_posted_data                                  ),
      .vc0_rx_flow_ctrl_nonposted_header                             (vc0_rx_flow_ctrl_nonposted_header                             ),
      .vc0_rx_flow_ctrl_nonposted_data                               (vc0_rx_flow_ctrl_nonposted_data                               ),
      .vc0_rx_flow_ctrl_compl_header                                 (vc0_rx_flow_ctrl_compl_header                                 ),
      .vc0_rx_flow_ctrl_compl_data                                   (vc0_rx_flow_ctrl_compl_data                                   ),
      .rx_ptr0_posted_dpram_min                                      (rx_ptr0_posted_dpram_min                                      ),
      .rx_ptr0_posted_dpram_max                                      (rx_ptr0_posted_dpram_max                                      ),
      .rx_ptr0_nonposted_dpram_min                                   (rx_ptr0_nonposted_dpram_min                                   ),
      .rx_ptr0_nonposted_dpram_max                                   (rx_ptr0_nonposted_dpram_max                                   ),
      .retry_buffer_last_active_address                              (retry_buffer_last_active_address                              ),
      .retry_buffer_memory_settings                                  (retry_buffer_memory_settings                                  ),
      .vc0_rx_buffer_memory_settings                                 (vc0_rx_buffer_memory_settings                                 ),
      .bist_memory_settings                                          (bist_memory_settings                                          ),
      .credit_buffer_allocation_aux                                  (credit_buffer_allocation_aux                                  ),
      .iei_enable_settings                                           (iei_enable_settings                                           ),
      .rpltim_set                                                    (rpltim_set                                                    ),
      .rpltim_base_data                                              (rpltim_base_data                                              ),
      .acknak_set                                                    (acknak_set                                                    ),
      .acknak_base_data                                              (acknak_base_data                                              ),
      .gen3_skip_ph2_ph3                                             (gen3_skip_ph2_ph3                                             ),
      .gen3_dcbal_en                                                 (gen3_dcbal_en                                                 ),
      .g3_bypass_equlz                                               (g3_bypass_equlz                                               ),
      .vsec_id                                                       (vsec_id                                                       ),
      .cvp_rate_sel                                                  (cvp_rate_sel                                                  ),
      .hard_reset_bypass                                             (hard_reset_bypass                                             ),
      .cvp_data_compressed                                           (cvp_data_compressed                                           ),
      .cvp_data_encrypted                                            (cvp_data_encrypted                                            ),
      .cvp_mode_reset                                                (cvp_mode_reset                                                ),
      .cvp_clk_reset                                                 (cvp_clk_reset                                                 ),
      .in_cvp_mode                                                   (in_cvp_mode                                                   ),
      .use_cvp_update_core_pof                                       (use_cvp_update_core_pof                                       ),
      .core_clk_sel                                                  (core_clk_sel                                                  ),
      .pipe_low_latency_syncronous_mode                              (pipe_low_latency_syncronous_mode                              ),
      .vsec_rev                                                      (vsec_rev                                                      ),
      .jtag_id                                                       (jtag_id                                                       ),
      .user_id                                                       (user_id                                                       ),
      .cseb_extend_pci                                               (cseb_extend_pci                                               ),
      .cseb_extend_pcie                                              (cseb_extend_pcie                                              ),
      .cseb_cpl_status_during_cvp                                    (cseb_cpl_status_during_cvp                                    ),
      .cseb_route_to_avl_rx_st                                       (cseb_route_to_avl_rx_st                                       ),
      .cseb_config_bypass                                            (cseb_config_bypass                                            ),
      .cseb_cpl_tag_checking                                         (cseb_cpl_tag_checking                                         ),
      .cseb_bar_match_checking                                       (cseb_bar_match_checking                                       ),
      .cseb_min_error_checking                                       (cseb_min_error_checking                                       ),
      .cseb_temp_busy_crs                                            (cseb_temp_busy_crs                                            ),
      .cseb_disable_auto_crs                                         (cseb_disable_auto_crs                                         ),
      .gen3_diffclock_nfts_count                                     (gen3_diffclock_nfts_count                                     ),
      .gen3_sameclock_nfts_count                                     (gen3_sameclock_nfts_count                                     ),
      .gen3_coeff_errchk                                             (gen3_coeff_errchk                                             ),
      .gen3_paritychk                                                (gen3_paritychk                                                ),
      .gen3_coeff_delay_count                                        (gen3_coeff_delay_count                                        ),
      .gen3_coeff_1                                                  (gen3_coeff_1                                                  ),
      .gen3_coeff_1_sel                                              (gen3_coeff_1_sel                                              ),
      .gen3_coeff_1_preset_hint                                      (gen3_coeff_1_preset_hint                                      ),
      .gen3_coeff_1_nxtber_more_ptr                                  (gen3_coeff_1_nxtber_more_ptr                                  ),
      .gen3_coeff_1_nxtber_more                                      (gen3_coeff_1_nxtber_more                                      ),
      .gen3_coeff_1_nxtber_less_ptr                                  (gen3_coeff_1_nxtber_less_ptr                                  ),
      .gen3_coeff_1_nxtber_less                                      (gen3_coeff_1_nxtber_less                                      ),
      .gen3_coeff_1_reqber                                           (gen3_coeff_1_reqber                                           ),
      .gen3_coeff_1_ber_meas                                         (gen3_coeff_1_ber_meas                                         ),
      .gen3_coeff_2                                                  (gen3_coeff_2                                                  ),
      .gen3_coeff_2_sel                                              (gen3_coeff_2_sel                                              ),
      .gen3_coeff_2_preset_hint                                      (gen3_coeff_2_preset_hint                                      ),
      .gen3_coeff_2_nxtber_more_ptr                                  (gen3_coeff_2_nxtber_more_ptr                                  ),
      .gen3_coeff_2_nxtber_more                                      (gen3_coeff_2_nxtber_more                                      ),
      .gen3_coeff_2_nxtber_less_ptr                                  (gen3_coeff_2_nxtber_less_ptr                                  ),
      .gen3_coeff_2_nxtber_less                                      (gen3_coeff_2_nxtber_less                                      ),
      .gen3_coeff_2_reqber                                           (gen3_coeff_2_reqber                                           ),
      .gen3_coeff_2_ber_meas                                         (gen3_coeff_2_ber_meas                                         ),
      .gen3_coeff_3                                                  (gen3_coeff_3                                                  ),
      .gen3_coeff_3_sel                                              (gen3_coeff_3_sel                                              ),
      .gen3_coeff_3_preset_hint                                      (gen3_coeff_3_preset_hint                                      ),
      .gen3_coeff_3_nxtber_more_ptr                                  (gen3_coeff_3_nxtber_more_ptr                                  ),
      .gen3_coeff_3_nxtber_more                                      (gen3_coeff_3_nxtber_more                                      ),
      .gen3_coeff_3_nxtber_less_ptr                                  (gen3_coeff_3_nxtber_less_ptr                                  ),
      .gen3_coeff_3_nxtber_less                                      (gen3_coeff_3_nxtber_less                                      ),
      .gen3_coeff_3_reqber                                           (gen3_coeff_3_reqber                                           ),
      .gen3_coeff_3_ber_meas                                         (gen3_coeff_3_ber_meas                                         ),
      .gen3_coeff_4                                                  (gen3_coeff_4                                                  ),
      .gen3_coeff_4_sel                                              (gen3_coeff_4_sel                                              ),
      .gen3_coeff_4_preset_hint                                      (gen3_coeff_4_preset_hint                                      ),
      .gen3_coeff_4_nxtber_more_ptr                                  (gen3_coeff_4_nxtber_more_ptr                                  ),
      .gen3_coeff_4_nxtber_more                                      (gen3_coeff_4_nxtber_more                                      ),
      .gen3_coeff_4_nxtber_less_ptr                                  (gen3_coeff_4_nxtber_less_ptr                                  ),
      .gen3_coeff_4_nxtber_less                                      (gen3_coeff_4_nxtber_less                                      ),
      .gen3_coeff_4_reqber                                           (gen3_coeff_4_reqber                                           ),
      .gen3_coeff_4_ber_meas                                         (gen3_coeff_4_ber_meas                                         ),
      .gen3_coeff_5                                                  (gen3_coeff_5                                                  ),
      .gen3_coeff_5_sel                                              (gen3_coeff_5_sel                                              ),
      .gen3_coeff_5_preset_hint                                      (gen3_coeff_5_preset_hint                                      ),
      .gen3_coeff_5_nxtber_more_ptr                                  (gen3_coeff_5_nxtber_more_ptr                                  ),
      .gen3_coeff_5_nxtber_more                                      (gen3_coeff_5_nxtber_more                                      ),
      .gen3_coeff_5_nxtber_less_ptr                                  (gen3_coeff_5_nxtber_less_ptr                                  ),
      .gen3_coeff_5_nxtber_less                                      (gen3_coeff_5_nxtber_less                                      ),
      .gen3_coeff_5_reqber                                           (gen3_coeff_5_reqber                                           ),
      .gen3_coeff_5_ber_meas                                         (gen3_coeff_5_ber_meas                                         ),
      .gen3_coeff_6                                                  (gen3_coeff_6                                                  ),
      .gen3_coeff_6_sel                                              (gen3_coeff_6_sel                                              ),
      .gen3_coeff_6_preset_hint                                      (gen3_coeff_6_preset_hint                                      ),
      .gen3_coeff_6_nxtber_more_ptr                                  (gen3_coeff_6_nxtber_more_ptr                                  ),
      .gen3_coeff_6_nxtber_more                                      (gen3_coeff_6_nxtber_more                                      ),
      .gen3_coeff_6_nxtber_less_ptr                                  (gen3_coeff_6_nxtber_less_ptr                                  ),
      .gen3_coeff_6_nxtber_less                                      (gen3_coeff_6_nxtber_less                                      ),
      .gen3_coeff_6_reqber                                           (gen3_coeff_6_reqber                                           ),
      .gen3_coeff_6_ber_meas                                         (gen3_coeff_6_ber_meas                                         ),
      .gen3_coeff_7                                                  (gen3_coeff_7                                                  ),
      .gen3_coeff_7_sel                                              (gen3_coeff_7_sel                                              ),
      .gen3_coeff_7_preset_hint                                      (gen3_coeff_7_preset_hint                                      ),
      .gen3_coeff_7_nxtber_more_ptr                                  (gen3_coeff_7_nxtber_more_ptr                                  ),
      .gen3_coeff_7_nxtber_more                                      (gen3_coeff_7_nxtber_more                                      ),
      .gen3_coeff_7_nxtber_less_ptr                                  (gen3_coeff_7_nxtber_less_ptr                                  ),
      .gen3_coeff_7_nxtber_less                                      (gen3_coeff_7_nxtber_less                                      ),
      .gen3_coeff_7_reqber                                           (gen3_coeff_7_reqber                                           ),
      .gen3_coeff_7_ber_meas                                         (gen3_coeff_7_ber_meas                                         ),
      .gen3_coeff_8                                                  (gen3_coeff_8                                                  ),
      .gen3_coeff_8_sel                                              (gen3_coeff_8_sel                                              ),
      .gen3_coeff_8_preset_hint                                      (gen3_coeff_8_preset_hint                                      ),
      .gen3_coeff_8_nxtber_more_ptr                                  (gen3_coeff_8_nxtber_more_ptr                                  ),
      .gen3_coeff_8_nxtber_more                                      (gen3_coeff_8_nxtber_more                                      ),
      .gen3_coeff_8_nxtber_less_ptr                                  (gen3_coeff_8_nxtber_less_ptr                                  ),
      .gen3_coeff_8_nxtber_less                                      (gen3_coeff_8_nxtber_less                                      ),
      .gen3_coeff_8_reqber                                           (gen3_coeff_8_reqber                                           ),
      .gen3_coeff_8_ber_meas                                         (gen3_coeff_8_ber_meas                                         ),
      .gen3_coeff_9                                                  (gen3_coeff_9                                                  ),
      .gen3_coeff_9_sel                                              (gen3_coeff_9_sel                                              ),
      .gen3_coeff_9_preset_hint                                      (gen3_coeff_9_preset_hint                                      ),
      .gen3_coeff_9_nxtber_more_ptr                                  (gen3_coeff_9_nxtber_more_ptr                                  ),
      .gen3_coeff_9_nxtber_more                                      (gen3_coeff_9_nxtber_more                                      ),
      .gen3_coeff_9_nxtber_less_ptr                                  (gen3_coeff_9_nxtber_less_ptr                                  ),
      .gen3_coeff_9_nxtber_less                                      (gen3_coeff_9_nxtber_less                                      ),
      .gen3_coeff_9_reqber                                           (gen3_coeff_9_reqber                                           ),
      .gen3_coeff_9_ber_meas                                         (gen3_coeff_9_ber_meas                                         ),
      .gen3_coeff_10                                                 (gen3_coeff_10                                                 ),
      .gen3_coeff_10_sel                                             (gen3_coeff_10_sel                                             ),
      .gen3_coeff_10_preset_hint                                     (gen3_coeff_10_preset_hint                                     ),
      .gen3_coeff_10_nxtber_more_ptr                                 (gen3_coeff_10_nxtber_more_ptr                                 ),
      .gen3_coeff_10_nxtber_more                                     (gen3_coeff_10_nxtber_more                                     ),
      .gen3_coeff_10_nxtber_less_ptr                                 (gen3_coeff_10_nxtber_less_ptr                                 ),
      .gen3_coeff_10_nxtber_less                                     (gen3_coeff_10_nxtber_less                                     ),
      .gen3_coeff_10_reqber                                          (gen3_coeff_10_reqber                                          ),
      .gen3_coeff_10_ber_meas                                        (gen3_coeff_10_ber_meas                                        ),
      .gen3_coeff_11                                                 (gen3_coeff_11                                                 ),
      .gen3_coeff_11_sel                                             (gen3_coeff_11_sel                                             ),
      .gen3_coeff_11_preset_hint                                     (gen3_coeff_11_preset_hint                                     ),
      .gen3_coeff_11_nxtber_more_ptr                                 (gen3_coeff_11_nxtber_more_ptr                                 ),
      .gen3_coeff_11_nxtber_more                                     (gen3_coeff_11_nxtber_more                                     ),
      .gen3_coeff_11_nxtber_less_ptr                                 (gen3_coeff_11_nxtber_less_ptr                                 ),
      .gen3_coeff_11_nxtber_less                                     (gen3_coeff_11_nxtber_less                                     ),
      .gen3_coeff_11_reqber                                          (gen3_coeff_11_reqber                                          ),
      .gen3_coeff_11_ber_meas                                        (gen3_coeff_11_ber_meas                                        ),
      .gen3_coeff_12                                                 (gen3_coeff_12                                                 ),
      .gen3_coeff_12_sel                                             (gen3_coeff_12_sel                                             ),
      .gen3_coeff_12_preset_hint                                     (gen3_coeff_12_preset_hint                                     ),
      .gen3_coeff_12_nxtber_more_ptr                                 (gen3_coeff_12_nxtber_more_ptr                                 ),
      .gen3_coeff_12_nxtber_more                                     (gen3_coeff_12_nxtber_more                                     ),
      .gen3_coeff_12_nxtber_less_ptr                                 (gen3_coeff_12_nxtber_less_ptr                                 ),
      .gen3_coeff_12_nxtber_less                                     (gen3_coeff_12_nxtber_less                                     ),
      .gen3_coeff_12_reqber                                          (gen3_coeff_12_reqber                                          ),
      .gen3_coeff_12_ber_meas                                        (gen3_coeff_12_ber_meas                                        ),
      .gen3_coeff_13                                                 (gen3_coeff_13                                                 ),
      .gen3_coeff_13_sel                                             (gen3_coeff_13_sel                                             ),
      .gen3_coeff_13_preset_hint                                     (gen3_coeff_13_preset_hint                                     ),
      .gen3_coeff_13_nxtber_more_ptr                                 (gen3_coeff_13_nxtber_more_ptr                                 ),
      .gen3_coeff_13_nxtber_more                                     (gen3_coeff_13_nxtber_more                                     ),
      .gen3_coeff_13_nxtber_less_ptr                                 (gen3_coeff_13_nxtber_less_ptr                                 ),
      .gen3_coeff_13_nxtber_less                                     (gen3_coeff_13_nxtber_less                                     ),
      .gen3_coeff_13_reqber                                          (gen3_coeff_13_reqber                                          ),
      .gen3_coeff_13_ber_meas                                        (gen3_coeff_13_ber_meas                                        ),
      .gen3_coeff_14                                                 (gen3_coeff_14                                                 ),
      .gen3_coeff_14_sel                                             (gen3_coeff_14_sel                                             ),
      .gen3_coeff_14_preset_hint                                     (gen3_coeff_14_preset_hint                                     ),
      .gen3_coeff_14_nxtber_more_ptr                                 (gen3_coeff_14_nxtber_more_ptr                                 ),
      .gen3_coeff_14_nxtber_more                                     (gen3_coeff_14_nxtber_more                                     ),
      .gen3_coeff_14_nxtber_less_ptr                                 (gen3_coeff_14_nxtber_less_ptr                                 ),
      .gen3_coeff_14_nxtber_less                                     (gen3_coeff_14_nxtber_less                                     ),
      .gen3_coeff_14_reqber                                          (gen3_coeff_14_reqber                                          ),
      .gen3_coeff_14_ber_meas                                        (gen3_coeff_14_ber_meas                                        ),
      .gen3_coeff_15                                                 (gen3_coeff_15                                                 ),
      .gen3_coeff_15_sel                                             (gen3_coeff_15_sel                                             ),
      .gen3_coeff_15_preset_hint                                     (gen3_coeff_15_preset_hint                                     ),
      .gen3_coeff_15_nxtber_more_ptr                                 (gen3_coeff_15_nxtber_more_ptr                                 ),
      .gen3_coeff_15_nxtber_more                                     (gen3_coeff_15_nxtber_more                                     ),
      .gen3_coeff_15_nxtber_less_ptr                                 (gen3_coeff_15_nxtber_less_ptr                                 ),
      .gen3_coeff_15_nxtber_less                                     (gen3_coeff_15_nxtber_less                                     ),
      .gen3_coeff_15_reqber                                          (gen3_coeff_15_reqber                                          ),
      .gen3_coeff_15_ber_meas                                        (gen3_coeff_15_ber_meas                                        ),
      .gen3_coeff_16                                                 (gen3_coeff_16                                                 ),
      .gen3_coeff_16_sel                                             (gen3_coeff_16_sel                                             ),
      .gen3_coeff_16_preset_hint                                     (gen3_coeff_16_preset_hint                                     ),
      .gen3_coeff_16_nxtber_more_ptr                                 (gen3_coeff_16_nxtber_more_ptr                                 ),
      .gen3_coeff_16_nxtber_more                                     (gen3_coeff_16_nxtber_more                                     ),
      .gen3_coeff_16_nxtber_less_ptr                                 (gen3_coeff_16_nxtber_less_ptr                                 ),
      .gen3_coeff_16_nxtber_less                                     (gen3_coeff_16_nxtber_less                                     ),
      .gen3_coeff_16_reqber                                          (gen3_coeff_16_reqber                                          ),
      .gen3_coeff_16_ber_meas                                        (gen3_coeff_16_ber_meas                                        ),
      .gen3_coeff_17                                                 (gen3_coeff_17                                                 ),
      .gen3_coeff_17_sel                                             (gen3_coeff_17_sel                                             ),
      .gen3_coeff_17_preset_hint                                     (gen3_coeff_17_preset_hint                                     ),
      .gen3_coeff_17_nxtber_more_ptr                                 (gen3_coeff_17_nxtber_more_ptr                                 ),
      .gen3_coeff_17_nxtber_more                                     (gen3_coeff_17_nxtber_more                                     ),
      .gen3_coeff_17_nxtber_less_ptr                                 (gen3_coeff_17_nxtber_less_ptr                                 ),
      .gen3_coeff_17_nxtber_less                                     (gen3_coeff_17_nxtber_less                                     ),
      .gen3_coeff_17_reqber                                          (gen3_coeff_17_reqber                                          ),
      .gen3_coeff_17_ber_meas                                        (gen3_coeff_17_ber_meas                                        ),
      .gen3_coeff_18                                                 (gen3_coeff_18                                                 ),
      .gen3_coeff_18_sel                                             (gen3_coeff_18_sel                                             ),
      .gen3_coeff_18_preset_hint                                     (gen3_coeff_18_preset_hint                                     ),
      .gen3_coeff_18_nxtber_more_ptr                                 (gen3_coeff_18_nxtber_more_ptr                                 ),
      .gen3_coeff_18_nxtber_more                                     (gen3_coeff_18_nxtber_more                                     ),
      .gen3_coeff_18_nxtber_less_ptr                                 (gen3_coeff_18_nxtber_less_ptr                                 ),
      .gen3_coeff_18_nxtber_less                                     (gen3_coeff_18_nxtber_less                                     ),
      .gen3_coeff_18_reqber                                          (gen3_coeff_18_reqber                                          ),
      .gen3_coeff_18_ber_meas                                        (gen3_coeff_18_ber_meas                                        ),
      .gen3_coeff_19                                                 (gen3_coeff_19                                                 ),
      .gen3_coeff_19_sel                                             (gen3_coeff_19_sel                                             ),
      .gen3_coeff_19_preset_hint                                     (gen3_coeff_19_preset_hint                                     ),
      .gen3_coeff_19_nxtber_more_ptr                                 (gen3_coeff_19_nxtber_more_ptr                                 ),
      .gen3_coeff_19_nxtber_more                                     (gen3_coeff_19_nxtber_more                                     ),
      .gen3_coeff_19_nxtber_less_ptr                                 (gen3_coeff_19_nxtber_less_ptr                                 ),
      .gen3_coeff_19_nxtber_less                                     (gen3_coeff_19_nxtber_less                                     ),
      .gen3_coeff_19_reqber                                          (gen3_coeff_19_reqber                                          ),
      .gen3_coeff_19_ber_meas                                        (gen3_coeff_19_ber_meas                                        ),
      .gen3_coeff_20                                                 (gen3_coeff_20                                                 ),
      .gen3_coeff_20_sel                                             (gen3_coeff_20_sel                                             ),
      .gen3_coeff_20_preset_hint                                     (gen3_coeff_20_preset_hint                                     ),
      .gen3_coeff_20_nxtber_more_ptr                                 (gen3_coeff_20_nxtber_more_ptr                                 ),
      .gen3_coeff_20_nxtber_more                                     (gen3_coeff_20_nxtber_more                                     ),
      .gen3_coeff_20_nxtber_less_ptr                                 (gen3_coeff_20_nxtber_less_ptr                                 ),
      .gen3_coeff_20_nxtber_less                                     (gen3_coeff_20_nxtber_less                                     ),
      .gen3_coeff_20_reqber                                          (gen3_coeff_20_reqber                                          ),
      .gen3_coeff_20_ber_meas                                        (gen3_coeff_20_ber_meas                                        ),
      .gen3_coeff_21                                                 (gen3_coeff_21                                                 ),
      .gen3_coeff_21_sel                                             (gen3_coeff_21_sel                                             ),
      .gen3_coeff_21_preset_hint                                     (gen3_coeff_21_preset_hint                                     ),
      .gen3_coeff_21_nxtber_more_ptr                                 (gen3_coeff_21_nxtber_more_ptr                                 ),
      .gen3_coeff_21_nxtber_more                                     (gen3_coeff_21_nxtber_more                                     ),
      .gen3_coeff_21_nxtber_less_ptr                                 (gen3_coeff_21_nxtber_less_ptr                                 ),
      .gen3_coeff_21_nxtber_less                                     (gen3_coeff_21_nxtber_less                                     ),
      .gen3_coeff_21_reqber                                          (gen3_coeff_21_reqber                                          ),
      .gen3_coeff_21_ber_meas                                        (gen3_coeff_21_ber_meas                                        ),
      .gen3_coeff_22                                                 (gen3_coeff_22                                                 ),
      .gen3_coeff_22_sel                                             (gen3_coeff_22_sel                                             ),
      .gen3_coeff_22_preset_hint                                     (gen3_coeff_22_preset_hint                                     ),
      .gen3_coeff_22_nxtber_more_ptr                                 (gen3_coeff_22_nxtber_more_ptr                                 ),
      .gen3_coeff_22_nxtber_more                                     (gen3_coeff_22_nxtber_more                                     ),
      .gen3_coeff_22_nxtber_less_ptr                                 (gen3_coeff_22_nxtber_less_ptr                                 ),
      .gen3_coeff_22_nxtber_less                                     (gen3_coeff_22_nxtber_less                                     ),
      .gen3_coeff_22_reqber                                          (gen3_coeff_22_reqber                                          ),
      .gen3_coeff_22_ber_meas                                        (gen3_coeff_22_ber_meas                                        ),
      .gen3_coeff_23                                                 (gen3_coeff_23                                                 ),
      .gen3_coeff_23_sel                                             (gen3_coeff_23_sel                                             ),
      .gen3_coeff_23_preset_hint                                     (gen3_coeff_23_preset_hint                                     ),
      .gen3_coeff_23_nxtber_more_ptr                                 (gen3_coeff_23_nxtber_more_ptr                                 ),
      .gen3_coeff_23_nxtber_more                                     (gen3_coeff_23_nxtber_more                                     ),
      .gen3_coeff_23_nxtber_less_ptr                                 (gen3_coeff_23_nxtber_less_ptr                                 ),
      .gen3_coeff_23_nxtber_less                                     (gen3_coeff_23_nxtber_less                                     ),
      .gen3_coeff_23_reqber                                          (gen3_coeff_23_reqber                                          ),
      .gen3_coeff_23_ber_meas                                        (gen3_coeff_23_ber_meas                                        ),
      .gen3_coeff_24                                                 (gen3_coeff_24                                                 ),
      .gen3_coeff_24_sel                                             (gen3_coeff_24_sel                                             ),
      .gen3_coeff_24_preset_hint                                     (gen3_coeff_24_preset_hint                                     ),
      .gen3_coeff_24_nxtber_more_ptr                                 (gen3_coeff_24_nxtber_more_ptr                                 ),
      .gen3_coeff_24_nxtber_more                                     (gen3_coeff_24_nxtber_more                                     ),
      .gen3_coeff_24_nxtber_less_ptr                                 (gen3_coeff_24_nxtber_less_ptr                                 ),
      .gen3_coeff_24_nxtber_less                                     (gen3_coeff_24_nxtber_less                                     ),
      .gen3_coeff_24_reqber                                          (gen3_coeff_24_reqber                                          ),
      .gen3_coeff_24_ber_meas                                        (gen3_coeff_24_ber_meas                                        ),
      .gen3_preset_coeff_1                                           (gen3_preset_coeff_1                                           ),
      .gen3_preset_coeff_2                                           (gen3_preset_coeff_2                                           ),
      .gen3_preset_coeff_3                                           (gen3_preset_coeff_3                                           ),
      .gen3_preset_coeff_4                                           (gen3_preset_coeff_4                                           ),
      .gen3_preset_coeff_5                                           (gen3_preset_coeff_5                                           ),
      .gen3_preset_coeff_6                                           (gen3_preset_coeff_6                                           ),
      .gen3_preset_coeff_7                                           (gen3_preset_coeff_7                                           ),
      .gen3_preset_coeff_8                                           (gen3_preset_coeff_8                                           ),
      .gen3_preset_coeff_9                                           (gen3_preset_coeff_9                                           ),
      .gen3_preset_coeff_10                                          (gen3_preset_coeff_10                                          ),
      .gen3_preset_coeff_11                                          (gen3_preset_coeff_11                                          ),
      .gen3_full_swing                                               (gen3_full_swing                                               ),
      .gen3_low_freq                                                 (gen3_low_freq                                                 ),
      .gen3_rxfreqlock_counter                                       (gen3_rxfreqlock_counter                                       ),
      .rpre_emph_a_val                                               (rpre_emph_a_val                                               ),
      .rpre_emph_b_val                                               (rpre_emph_b_val                                               ),
      .rpre_emph_c_val                                               (rpre_emph_c_val                                               ),
      .rpre_emph_d_val                                               (rpre_emph_d_val                                               ),
      .rpre_emph_e_val                                               (rpre_emph_e_val                                               ),
      .rvod_sel_a_val                                                (rvod_sel_a_val                                                ),
      .rvod_sel_b_val                                                (rvod_sel_b_val                                                ),
      .rvod_sel_c_val                                                (rvod_sel_c_val                                                ),
      .rvod_sel_d_val                                                (rvod_sel_d_val                                                ),
      .rvod_sel_e_val                                                (rvod_sel_e_val                                                ),
      .g3_dis_rx_use_prst                                            (g3_dis_rx_use_prst_hwtcl                                      ),
      .g3_dis_rx_use_prst_ep                                         (g3_dis_rx_use_prst_ep_hwtcl                                   ),
      .TLP_INSPECTOR                                                 (TLP_INSPECTOR                                                 ),
      .TLP_INSPECTOR_USE_SIGNAL_PROBE                                (TLP_INSPECTOR_USE_SIGNAL_PROBE                                ),
      .TLP_INSPECTOR_POWER_UP_TRIGGER                                (TLP_INSPECTOR_POWER_UP_TRIGGER                                ),
      .inspector_enable                                              (pcie_inspector_hwtcl                                          )
      //Serdes related parameters
      ) altpcie_hip_256_pipen1b (
      .tlbfm_in                                                       (tlbfm_in                                                            ),//output
      .tlbfm_out                                                      (tlbfm_out                                                           ),//input
      .pipe8_sim_only                                                 (((ALTPCIE_SV_HIP_AST_HWTCL_SIM_ONLY==0)||(enable_pipe32_sim_hwtcl==1))?
                                                                                                                        1'b0:simu_mode_pipe),//input
      .pin_perst                                                      (pin_perst                                                           ),//input
      .npor                                                           (npor                                                                ),//input
      .reset_status                                                   (reset_status                                                        ),//output
      .serdes_pll_locked                                              (serdes_pll_locked                                                   ),//output
      .pld_clk                                                        (pld_clk                                                             ),//input
      .pclk_in                                                        (sim_pipe_pclk_in                                                    ),//input
      .clk250_out                                                     (sim_pipe_clk250_out                                                 ),//output
      .clk500_out                                                     (sim_pipe_clk500_out                                                 ),//output
      .rate                                                           (sim_pipe_rate                                                       ),//output [1 : 0]
      .pld_clk_inuse                                                  (pld_clk_inuse                                                       ),//output
      .pld_core_ready                                                 (pld_core_ready                                                      ),//input
      .refclk                                                         (refclk                                                              ),//input
      .mode                                                           (mode                                                                ),//input  [1 : 0]
      .hpg_ctrler                                                     ((use_config_bypass_hwtcl==1)?
                                                                          {cfgbp_linkcsr_bit0, cfgbp_tx_req_pm, cfgbp_tx_typ_pm}:hpg_ctrler),//input  [4 : 0]
      .reconfig_rstn                                                  ((hip_reconfig_hwtcl==1)? hip_reconfig_rst_n     : 1'b1              ),//input
      .reconfig_clk                                                   ((hip_reconfig_hwtcl==1)? hip_reconfig_clk       : 1'b0              ),//input
      .reconfig_write                                                 ((hip_reconfig_hwtcl==1)? hip_reconfig_write     : 1'b0              ),//input
      .reconfig_read                                                  ((hip_reconfig_hwtcl==1)? hip_reconfig_read      : 1'b0              ),//input
      .reconfig_byte_en                                               ((hip_reconfig_hwtcl==1)? hip_reconfig_byte_en   : 2'h0              ),//input   [1:0]
      .reconfig_address                                               ((hip_reconfig_hwtcl==1)? hip_reconfig_address   : 10'h0             ),//input   [9:0]
      .reconfig_writedata                                             ((hip_reconfig_hwtcl==1)? hip_reconfig_writedata : 16'h0             ),//input   [15:0]
      .reconfig_readdata                                              (                         hip_reconfig_readdata                      ),//output  [15:0]
      .ser_shift_load                                                 ((hip_reconfig_hwtcl==1)? ser_shift_load         : 1'b1              ),
      .interface_sel                                                  ((hip_reconfig_hwtcl==1)? interface_sel          : 1'b1              ),
      .swctmod                                                        (gnd_swctmod                                                         ),//input  [1 : 0]
      .test_in                                                        ({testin[63:1],(ALTPCIE_SV_HIP_AST_HWTCL_SIM_ONLY==0)?1'b0:testin[0]}),//input  [31 : 0]
      .phystatus0_ext                                                 (phystatus0                                                          ),//input
      .phystatus1_ext                                                 (phystatus1                                                          ),//input
      .phystatus2_ext                                                 (phystatus2                                                          ),//input
      .phystatus3_ext                                                 (phystatus3                                                          ),//input
      .phystatus4_ext                                                 (phystatus4                                                          ),//input
      .phystatus5_ext                                                 (phystatus5                                                          ),//input
      .phystatus6_ext                                                 (phystatus6                                                          ),//input
      .phystatus7_ext                                                 (phystatus7                                                          ),//input
      .rxdata0_ext                                                    (rxdata0                                                             ),//input  [7 : 0]
      .rxdata1_ext                                                    (rxdata1                                                             ),//input  [7 : 0]
      .rxdata2_ext                                                    (rxdata2                                                             ),//input  [7 : 0]
      .rxdata3_ext                                                    (rxdata3                                                             ),//input  [7 : 0]
      .rxdata4_ext                                                    (rxdata4                                                             ),//input  [7 : 0]
      .rxdata5_ext                                                    (rxdata5                                                             ),//input  [7 : 0]
      .rxdata6_ext                                                    (rxdata6                                                             ),//input  [7 : 0]
      .rxdata7_ext                                                    (rxdata7                                                             ),//input  [7 : 0]
      .rxdatak0_ext                                                   (rxdatak0                                                            ),//input
      .rxdatak1_ext                                                   (rxdatak1                                                            ),//input
      .rxdatak2_ext                                                   (rxdatak2                                                            ),//input
      .rxdatak3_ext                                                   (rxdatak3                                                            ),//input
      .rxdatak4_ext                                                   (rxdatak4                                                            ),//input
      .rxdatak5_ext                                                   (rxdatak5                                                            ),//input
      .rxdatak6_ext                                                   (rxdatak6                                                            ),//input
      .rxdatak7_ext                                                   (rxdatak7                                                            ),//input
      .rxelecidle0_ext                                                (rxelecidle0                                                         ),//input
      .rxelecidle1_ext                                                (rxelecidle1                                                         ),//input
      .rxelecidle2_ext                                                (rxelecidle2                                                         ),//input
      .rxelecidle3_ext                                                (rxelecidle3                                                         ),//input
      .rxelecidle4_ext                                                (rxelecidle4                                                         ),//input
      .rxelecidle5_ext                                                (rxelecidle5                                                         ),//input
      .rxelecidle6_ext                                                (rxelecidle6                                                         ),//input
      .rxelecidle7_ext                                                (rxelecidle7                                                         ),//input
      .rxfreqlocked0_ext                                              (rxfreqlocked0                                                       ),//input
      .rxfreqlocked1_ext                                              (rxfreqlocked1                                                       ),//input
      .rxfreqlocked2_ext                                              (rxfreqlocked2                                                       ),//input
      .rxfreqlocked3_ext                                              (rxfreqlocked3                                                       ),//input
      .rxfreqlocked4_ext                                              (rxfreqlocked4                                                       ),//input
      .rxfreqlocked5_ext                                              (rxfreqlocked5                                                       ),//input
      .rxfreqlocked6_ext                                              (rxfreqlocked6                                                       ),//input
      .rxfreqlocked7_ext                                              (rxfreqlocked7                                                       ),//input
      .rxstatus0_ext                                                  (rxstatus0                                                           ),//input  [2 : 0]
      .rxstatus1_ext                                                  (rxstatus1                                                           ),//input  [2 : 0]
      .rxstatus2_ext                                                  (rxstatus2                                                           ),//input  [2 : 0]
      .rxstatus3_ext                                                  (rxstatus3                                                           ),//input  [2 : 0]
      .rxstatus4_ext                                                  (rxstatus4                                                           ),//input  [2 : 0]
      .rxstatus5_ext                                                  (rxstatus5                                                           ),//input  [2 : 0]
      .rxstatus6_ext                                                  (rxstatus6                                                           ),//input  [2 : 0]
      .rxstatus7_ext                                                  (rxstatus7                                                           ),//input  [2 : 0]
      .rxdataskip0_ext                                                (rxdataskip0                                                         ),//input
      .rxdataskip1_ext                                                (rxdataskip1                                                         ),//input
      .rxdataskip2_ext                                                (rxdataskip2                                                         ),//input
      .rxdataskip3_ext                                                (rxdataskip3                                                         ),//input
      .rxdataskip4_ext                                                (rxdataskip4                                                         ),//input
      .rxdataskip5_ext                                                (rxdataskip5                                                         ),//input
      .rxdataskip6_ext                                                (rxdataskip6                                                         ),//input
      .rxdataskip7_ext                                                (rxdataskip7                                                         ),//input
      .rxblkst0_ext                                                   (rxblkst0                                                            ),//input
      .rxblkst1_ext                                                   (rxblkst1                                                            ),//input
      .rxblkst2_ext                                                   (rxblkst2                                                            ),//input
      .rxblkst3_ext                                                   (rxblkst3                                                            ),//input
      .rxblkst4_ext                                                   (rxblkst4                                                            ),//input
      .rxblkst5_ext                                                   (rxblkst5                                                            ),//input
      .rxblkst6_ext                                                   (rxblkst6                                                            ),//input
      .rxblkst7_ext                                                   (rxblkst7                                                            ),//input
      .rxsynchd0_ext                                                  (rxsynchd0                                                           ),//input  [1 : 0]
      .rxsynchd1_ext                                                  (rxsynchd1                                                           ),//input  [1 : 0]
      .rxsynchd2_ext                                                  (rxsynchd2                                                           ),//input  [1 : 0]
      .rxsynchd3_ext                                                  (rxsynchd3                                                           ),//input  [1 : 0]
      .rxsynchd4_ext                                                  (rxsynchd4                                                           ),//input  [1 : 0]
      .rxsynchd5_ext                                                  (rxsynchd5                                                           ),//input  [1 : 0]
      .rxsynchd6_ext                                                  (rxsynchd6                                                           ),//input  [1 : 0]
      .rxsynchd7_ext                                                  (rxsynchd7                                                           ),//input  [1 : 0]
      .rxvalid0_ext                                                   (rxvalid0                                                            ),//input
      .rxvalid1_ext                                                   (rxvalid1                                                            ),//input
      .rxvalid2_ext                                                   (rxvalid2                                                            ),//input
      .rxvalid3_ext                                                   (rxvalid3                                                            ),//input
      .rxvalid4_ext                                                   (rxvalid4                                                            ),//input
      .rxvalid5_ext                                                   (rxvalid5                                                            ),//input
      .rxvalid6_ext                                                   (rxvalid6                                                            ),//input
      .rxvalid7_ext                                                   (rxvalid7                                                            ),//input
      .aer_msi_num                                                    ((use_config_bypass_hwtcl==1)?
                                                                        {cfgbp_inh_dllp, cfgbp_req_phycfg}:(port_type_hwtcl=="Root port")?
                                                                                                                           aer_msi_num:5'h0),//input  [4 : 0]
      .app_int_sts                                                    (app_int_sts                                                         ),//input
      .app_msi_num                                                    ((use_config_bypass_hwtcl==1)?
                                                                        {cfgbp_comclk_reg, cfgbp_extsy_reg, cfgbp_max_pload}:app_msi_num   ),//input  [4 : 0]
      .app_msi_req                                                    ((use_config_bypass_hwtcl==1)?cfgbp_req_wake:app_msi_req     ),//input
      .app_msi_tc                                                     ((use_config_bypass_hwtcl==1)?
                                                                                                {1'b0, cfgbp_link3_ctl}:app_msi_tc),//input  [2 : 0]
      .pex_msi_num                                                    ((use_config_bypass_hwtcl==1)?
                                                                        {cfgbp_inh_tx_tlp, cfgbp_req_phypm}:
                                                                           (port_type_hwtcl=="Root port")?pex_msi_num:5'h0                 ),//input  [4 : 0]
      .lmi_addr                                                       (lmi_addr                                                            ),//input  [11 : 0]
      .lmi_din                                                        (lmi_din                                                             ),//input  [31 : 0]
      .lmi_rden                                                       (lmi_rden                                                            ),//input
      .lmi_wren                                                       (lmi_wren                                                            ),//input
      .pm_auxpwr                                                      ((use_config_bypass_hwtcl==1)?cfgbp_rx_ecrchk:pm_auxpwr      ),//input
      .pm_data                                                        ((use_config_bypass_hwtcl==1)?
                                                                          {2'h0, cfgbp_vc0_tcmap_pld, 1'b0}:pm_data            ),//input  [9 : 0]
      .pme_to_cr                                                      (pme_to_cr                                                           ),//input
      .pm_event                                                       ((use_config_bypass_hwtcl==1)?cfgbp_tx_ecrcgen:pm_event      ),//input
      .rx_st_mask                                                     (rx_st_mask                                                          ),//input
      .rx_st_ready                                                    (rx_st_ready                                                         ),//input
      .tx_st_data                                                     (tx_st_data_int                                                      ),//input  [255 : 0]
      .tx_st_empty                                                    ((ast_width_hwtcl=="Avalon-ST 64-bit")?2'b00:tx_st_empty             ),//input  [1 :0]        t
      .tx_st_eop                                                      (tx_st_eop_int                                                       ),//input  [3 :0]        t
      .tx_st_err                                                      (tx_st_err_int                                                       ),//input  [3 :0]        t
      .tx_st_parity                                                   (tx_st_parity_int                                                    ),//input  [31:0]        t
      .tx_st_sop                                                      (tx_st_sop_int                                                       ),//input  [3 :0]        t
      .tx_st_valid                                                    (tx_st_valid[0]                                                      ),//input                t
      .cfglink2csrpld                                                 ((use_config_bypass_hwtcl==1)?cfgbp_link2csr:13'b0           ),//input  [12:0]        c
      .cpl_err                                                        ((use_config_bypass_hwtcl==1)?cfgbp_secbus[6:0]:cpl_err      ),//input  [6 :0]        c
      .cpl_pending                                                    ((use_config_bypass_hwtcl==1)?cfgbp_secbus[7]:cpl_pending    ),//input                c
      .tl_slotclk_cfg                                                 ((slotclkcfg_hwtcl==1)?1'b1:1'b0                                     ),//input                t
      .reconfig_to_xcvr                                               (reconfig_to_xcvr                                                    ),
      .reconfig_from_xcvr                                             (reconfig_from_xcvr                                                  ),
      .fixedclk_locked                                                (fixedclk_locked                                                     ),
      .frzlogic                                                       (gnd_frzlogic                                                        ),//input
      .frzreg                                                         (gnd_frzreg                                                          ),//input
      .idrcv                                                          (gnd_idrcv                                                           ),//input  [7 : 0]
      .idrpl                                                          (gnd_idrpl                                                           ),//input  [7 : 0]
      .bistenrcv                                                      (gnd_bistenrcv                                                       ),//input
      .bistenrpl                                                      (gnd_bistenrpl                                                       ),//input
      .bistscanen                                                     (gnd_bistscanen                                                      ),//input
      .bistscanin                                                     (gnd_bistscanin                                                      ),//input
      .bisttesten                                                     (gnd_bisttesten                                                      ),//input
      .memhiptestenable                                               (gnd_memhiptestenable                                                ),//input
      .memredenscan                                                   (gnd_memredenscan                                                    ),//input
      .memredscen                                                     (gnd_memredscen                                                      ),//input
      .memredscin                                                     (gnd_memredscin                                                      ),//input
      .memredsclk                                                     (gnd_memredsclk                                                      ),//input
      .memredscrst                                                    (gnd_memredscrst                                                     ),//input
      .memredscsel                                                    (gnd_memredscsel                                                     ),//input
      .memregscanen                                                   (gnd_memregscanen                                                    ),//input
      .memregscanin                                                   (gnd_memregscanin                                                    ),//input
      .scanmoden                                                      (gnd_scanmoden                                                       ),//input
      .usermode                                                       (gnd_usermode                                                        ),//input
      .scanshiftn                                                     (gnd_scanshiftn                                                      ),//input
      .nfrzdrv                                                        (gnd_nfrzdrv                                                         ),//input
      .csebrddata                                                     ((cseb_on==1)?cseb_rddata:gnd_csebrddata                              ),//input  [31 : 0]
      .csebrddataparity                                               ((cseb_on==1)?cseb_rddata_parity:gnd_csebrddataparity                 ),//input  [3 : 0]
      .csebrdresponse                                                 ((cseb_on==1)?cseb_rdresponse:gnd_csebrdresponse                      ),//input  [2 : 0]
      .csebwaitrequest                                                ((cseb_on==1)?cseb_waitrequest:gnd_csebwaitrequest                    ),//input
      .csebwrresponse                                                 ((cseb_on==1)?cseb_wrresponse:gnd_csebwrresponse                      ),//input  [2 : 0]
      .csebwrrespvalid                                                ((cseb_on==1)?cseb_wrresp_valid:gnd_csebwrrespvalid                   ),//input
      .dbgpipex1rx                                                    (gnd_dbgpipex1rx                                                     ),//input  [43 : 0]
      .eidleinfersel0_ext                                             (eidleinfersel0                                                      ),//output [2 : 0]
      .eidleinfersel1_ext                                             (eidleinfersel1                                                      ),//output [2 : 0]
      .eidleinfersel2_ext                                             (eidleinfersel2                                                      ),//output [2 : 0]
      .eidleinfersel3_ext                                             (eidleinfersel3                                                      ),//output [2 : 0]
      .eidleinfersel4_ext                                             (eidleinfersel4                                                      ),//output [2 : 0]
      .eidleinfersel5_ext                                             (eidleinfersel5                                                      ),//output [2 : 0]
      .eidleinfersel6_ext                                             (eidleinfersel6                                                      ),//output [2 : 0]
      .eidleinfersel7_ext                                             (eidleinfersel7                                                      ),//output [2 : 0]
      .powerdown0_ext                                                 (powerdown0                                                          ),//output [1 : 0]
      .powerdown1_ext                                                 (powerdown1                                                          ),//output [1 : 0]
      .powerdown2_ext                                                 (powerdown2                                                          ),//output [1 : 0]
      .powerdown3_ext                                                 (powerdown3                                                          ),//output [1 : 0]
      .powerdown4_ext                                                 (powerdown4                                                          ),//output [1 : 0]
      .powerdown5_ext                                                 (powerdown5                                                          ),//output [1 : 0]
      .powerdown6_ext                                                 (powerdown6                                                          ),//output [1 : 0]
      .powerdown7_ext                                                 (powerdown7                                                          ),//output [1 : 0]
      .rxpolarity0_ext                                                (rxpolarity0                                                         ),//output
      .rxpolarity1_ext                                                (rxpolarity1                                                         ),//output
      .rxpolarity2_ext                                                (rxpolarity2                                                         ),//output
      .rxpolarity3_ext                                                (rxpolarity3                                                         ),//output
      .rxpolarity4_ext                                                (rxpolarity4                                                         ),//output
      .rxpolarity5_ext                                                (rxpolarity5                                                         ),//output
      .rxpolarity6_ext                                                (rxpolarity6                                                         ),//output
      .rxpolarity7_ext                                                (rxpolarity7                                                         ),//output
      .txcompl0_ext                                                   (txcompl0                                                            ),//output
      .txcompl1_ext                                                   (txcompl1                                                            ),//output
      .txcompl2_ext                                                   (txcompl2                                                            ),//output
      .txcompl3_ext                                                   (txcompl3                                                            ),//output
      .txcompl4_ext                                                   (txcompl4                                                            ),//output
      .txcompl5_ext                                                   (txcompl5                                                            ),//output
      .txcompl6_ext                                                   (txcompl6                                                            ),//output
      .txcompl7_ext                                                   (txcompl7                                                            ),//output
      .txdata0_ext                                                    (txdata0                                                             ),//output [7 : 0]
      .txdata1_ext                                                    (txdata1                                                             ),//output [7 : 0]
      .txdata2_ext                                                    (txdata2                                                             ),//output [7 : 0]
      .txdata3_ext                                                    (txdata3                                                             ),//output [7 : 0]
      .txdata4_ext                                                    (txdata4                                                             ),//output [7 : 0]
      .txdata5_ext                                                    (txdata5                                                             ),//output [7 : 0]
      .txdata6_ext                                                    (txdata6                                                             ),//output [7 : 0]
      .txdata7_ext                                                    (txdata7                                                             ),//output [7 : 0]
      .txdatak0_ext                                                   (txdatak0                                                            ),//output
      .txdatak1_ext                                                   (txdatak1                                                            ),//output
      .txdatak2_ext                                                   (txdatak2                                                            ),//output
      .txdatak3_ext                                                   (txdatak3                                                            ),//output
      .txdatak4_ext                                                   (txdatak4                                                            ),//output
      .txdatak5_ext                                                   (txdatak5                                                            ),//output
      .txdatak6_ext                                                   (txdatak6                                                            ),//output
      .txdatak7_ext                                                   (txdatak7                                                            ),//output
      .txdetectrx0_ext                                                (txdetectrx0                                                         ),//output
      .txdetectrx1_ext                                                (txdetectrx1                                                         ),//output
      .txdetectrx2_ext                                                (txdetectrx2                                                         ),//output
      .txdetectrx3_ext                                                (txdetectrx3                                                         ),//output
      .txdetectrx4_ext                                                (txdetectrx4                                                         ),//output
      .txdetectrx5_ext                                                (txdetectrx5                                                         ),//output
      .txdetectrx6_ext                                                (txdetectrx6                                                         ),//output
      .txdetectrx7_ext                                                (txdetectrx7                                                         ),//output
      .txelecidle0_ext                                                (txelecidle0                                                         ),//output
      .txelecidle1_ext                                                (txelecidle1                                                         ),//output
      .txelecidle2_ext                                                (txelecidle2                                                         ),//output
      .txelecidle3_ext                                                (txelecidle3                                                         ),//output
      .txelecidle4_ext                                                (txelecidle4                                                         ),//output
      .txelecidle5_ext                                                (txelecidle5                                                         ),//output
      .txelecidle6_ext                                                (txelecidle6                                                         ),//output
      .txelecidle7_ext                                                (txelecidle7                                                         ),//output
      .txmargin0_ext                                                  (txmargin0                                                           ),//output [2 : 0]
      .txmargin1_ext                                                  (txmargin1                                                           ),//output [2 : 0]
      .txmargin2_ext                                                  (txmargin2                                                           ),//output [2 : 0]
      .txmargin3_ext                                                  (txmargin3                                                           ),//output [2 : 0]
      .txmargin4_ext                                                  (txmargin4                                                           ),//output [2 : 0]
      .txmargin5_ext                                                  (txmargin5                                                           ),//output [2 : 0]
      .txmargin6_ext                                                  (txmargin6                                                           ),//output [2 : 0]
      .txmargin7_ext                                                  (txmargin7                                                           ),//output [2 : 0]
      .txdeemph0_ext                                                  (txdeemph0                                                           ),//output
      .txdeemph1_ext                                                  (txdeemph1                                                           ),//output
      .txdeemph2_ext                                                  (txdeemph2                                                           ),//output
      .txdeemph3_ext                                                  (txdeemph3                                                           ),//output
      .txdeemph4_ext                                                  (txdeemph4                                                           ),//output
      .txdeemph5_ext                                                  (txdeemph5                                                           ),//output
      .txdeemph6_ext                                                  (txdeemph6                                                           ),//output
      .txdeemph7_ext                                                  (txdeemph7                                                           ),//output
      .txswing0_ext                                                   (txswing0                                                            ),//output
      .txswing1_ext                                                   (txswing1                                                            ),//output
      .txswing2_ext                                                   (txswing2                                                            ),//output
      .txswing3_ext                                                   (txswing3                                                            ),//output
      .txswing4_ext                                                   (txswing4                                                            ),//output
      .txswing5_ext                                                   (txswing5                                                            ),//output
      .txswing6_ext                                                   (txswing6                                                            ),//output
      .txswing7_ext                                                   (txswing7                                                            ),//output
      .txblkst0_ext                                                   (txblkst0                                                            ),//output
      .txblkst1_ext                                                   (txblkst1                                                            ),//output
      .txblkst2_ext                                                   (txblkst2                                                            ),//output
      .txblkst3_ext                                                   (txblkst3                                                            ),//output
      .txblkst4_ext                                                   (txblkst4                                                            ),//output
      .txblkst5_ext                                                   (txblkst5                                                            ),//output
      .txblkst6_ext                                                   (txblkst6                                                            ),//output
      .txblkst7_ext                                                   (txblkst7                                                            ),//output
      .txsynchd0_ext                                                  (txsynchd0                                                           ),//output [1 : 0]
      .txsynchd1_ext                                                  (txsynchd1                                                           ),//output [1 : 0]
      .txsynchd2_ext                                                  (txsynchd2                                                           ),//output [1 : 0]
      .txsynchd3_ext                                                  (txsynchd3                                                           ),//output [1 : 0]
      .txsynchd4_ext                                                  (txsynchd4                                                           ),//output [1 : 0]
      .txsynchd5_ext                                                  (txsynchd5                                                           ),//output [1 : 0]
      .txsynchd6_ext                                                  (txsynchd6                                                           ),//output [1 : 0]
      .txsynchd7_ext                                                  (txsynchd7                                                           ),//output [1 : 0]
      .currentcoeff0_ext                                              (currentcoeff0                                                       ),//output [17 : 0]
      .currentcoeff1_ext                                              (currentcoeff1                                                       ),//output [17 : 0]
      .currentcoeff2_ext                                              (currentcoeff2                                                       ),//output [17 : 0]
      .currentcoeff3_ext                                              (currentcoeff3                                                       ),//output [17 : 0]
      .currentcoeff4_ext                                              (currentcoeff4                                                       ),//output [17 : 0]
      .currentcoeff5_ext                                              (currentcoeff5                                                       ),//output [17 : 0]
      .currentcoeff6_ext                                              (currentcoeff6                                                       ),//output [17 : 0]
      .currentcoeff7_ext                                              (currentcoeff7                                                       ),//output [17 : 0]
      .currentrxpreset0_ext                                           (currentrxpreset0                                                    ),//output [2 : 0]
      .currentrxpreset1_ext                                           (currentrxpreset1                                                    ),//output [2 : 0]
      .currentrxpreset2_ext                                           (currentrxpreset2                                                    ),//output [2 : 0]
      .currentrxpreset3_ext                                           (currentrxpreset3                                                    ),//output [2 : 0]
      .currentrxpreset4_ext                                           (currentrxpreset4                                                    ),//output [2 : 0]
      .currentrxpreset5_ext                                           (currentrxpreset5                                                    ),//output [2 : 0]
      .currentrxpreset6_ext                                           (currentrxpreset6                                                    ),//output [2 : 0]
      .currentrxpreset7_ext                                           (currentrxpreset7                                                    ),//output [2 : 0]
      .coreclkout_hip                                                 (coreclkout_hip                                                      ),//output
      .currentspeed                                                   (currentspeed                                                        ),//output [1 : 0]
      .derr_cor_ext_rcv                                               (derr_cor_ext_rcv                                                    ),//output
      .derr_cor_ext_rpl                                               (derr_cor_ext_rpl                                                    ),//output
      .derr_rpl                                                       (derr_rpl                                                            ),//output
      .rx_par_err                                                     (rx_par_err                                                          ),
      .tx_par_err                                                     (tx_par_err                                                          ),
      .cfg_par_err                                                    (cfg_par_err                                                         ),
      .dlup                                                           (dlup                                                                ),//output
      .dlup_exit                                                      (dlup_exit                                                           ),//output
      .ev128ns                                                        (ev128ns                                                             ),//output
      .ev1us                                                          (ev1us                                                               ),//output
      .hotrst_exit                                                    (hotrst_exit                                                         ),//output
      .int_status                                                     (int_status                                                          ),//output [3 : 0]
      .l2_exit                                                        (l2_exit                                                             ),//output
      .lane_act                                                       (lane_act                                                            ),//output [3 : 0]
      .ltssmstate                                                     (ltssmstate                                                          ),//output [4 : 0]
      .test_out                                                       (testout                                                             ),//output [255 : 0]
      .reservedin                                                     (reservedin_int                                                      ),
      .reservedclkin                                                  (reservedclkin                                                       ),
      .reservedout                                                    (reservedout                                                         ),
      .reservedclkout                                                 (reservedclkout                                                      ),
      .app_int_ack                                                    (app_int_ack                                                         ),//output
      .app_msi_ack                                                    (app_msi_ack                                                         ),//output
      .lmi_ack                                                        (lmi_ack                                                             ),//output
      .lmi_dout                                                       (lmi_dout                                                            ),//output [31 : 0]
      .pme_to_sr                                                      (pme_to_sr                                                           ),//output
      .rx_st_bardec1                                                  (rx_st_bardec1                                                       ),//output [7 : 0]
      .rx_st_bardec2                                                  (rx_st_bardec2                                                       ),//output [7 : 0]
      .rx_st_be                                                       (rx_st_be_int                                                        ),//output [31 : 0]
      .rx_st_data                                                     (rx_st_data_int                                                      ),//output [255 : 0]
      .rx_st_empty                                                    (rx_st_empty                                                         ),//output [1 : 0]
      .rx_st_eop                                                      (rx_st_eop_int                                                       ),//output [3 : 0]
      .rx_st_err                                                      (rx_st_err_int                                                       ),//output [3 : 0]
      .rx_st_parity                                                   (rx_st_parity_int                                                    ),//output [31 : 0]
      .rx_st_sop                                                      (rx_st_sop_int                                                       ),//output [3 : 0]
      .rx_st_valid                                                    (rx_st_valid_int                                                     ),//output [3 : 0]
      .serr_out                                                       (serr_out                                                            ),//output
      .tl_cfg_add                                                     (tl_cfg_add                                                          ),//output [3 : 0]
      .tl_cfg_ctl                                                     (tl_cfg_ctl                                                          ),//output [31 : 0]
      .tl_cfg_sts                                                     (tl_cfg_sts                                                          ),//output [52 : 0]
      .tx_cred_datafccp                                               (tx_cred_datafccp                                                    ),//output [11 : 0]
      .tx_cred_datafcnp                                               (tx_cred_datafcnp                                                    ),//output [11 : 0]
      .tx_cred_datafcp                                                (tx_cred_datafcp                                                     ),//output [11 : 0]
      .tx_cred_fchipcons                                              (tx_cred_fchipcons                                                   ),//output [5 : 0]
      .tx_cred_fcinfinite                                             (tx_cred_fcinfinite                                                  ),//output [5 : 0]
      .tx_cred_hdrfccp                                                (tx_cred_hdrfccp                                                     ),//output [7 : 0]
      .tx_cred_hdrfcnp                                                (tx_cred_hdrfcnp                                                     ),//output [7 : 0]
      .tx_cred_hdrfcp                                                 (tx_cred_hdrfcp                                                      ),//output [7 : 0]
      .tx_st_ready                                                    (tx_st_ready                                                         ),//output
      .rx_in0                                                         (rx_in0                                                              ),//input
      .rx_in1                                                         (rx_in1                                                              ),//input
      .rx_in2                                                         (rx_in2                                                              ),//input
      .rx_in3                                                         (rx_in3                                                              ),//input
      .rx_in4                                                         (rx_in4                                                              ),//input
      .rx_in5                                                         (rx_in5                                                              ),//input
      .rx_in6                                                         (rx_in6                                                              ),//input
      .rx_in7                                                         (rx_in7                                                              ),//input
      .tx_out0                                                        (tx_out0                                                             ),//output
      .tx_out1                                                        (tx_out1                                                             ),//output
      .tx_out2                                                        (tx_out2                                                             ),//output
      .tx_out3                                                        (tx_out3                                                             ),//output
      .tx_out4                                                        (tx_out4                                                             ),//output
      .tx_out5                                                        (tx_out5                                                             ),//output
      .tx_out6                                                        (tx_out6                                                             ),//output
      .tx_out7                                                        (tx_out7                                                             ),//output
      .csebaddr                                                       (cseb_addr                                                            ),//output [32 : 0]
      .csebaddrparity                                                 (cseb_addr_parity                                                      ),//output [4 : 0]
      .csebbe                                                         (cseb_be                                                              ),//output [3 : 0]
      .csebisshadow                                                   (cseb_is_shadow                                                        ),//output
      .csebrden                                                       (cseb_rden                                                            ),//output
      .csebwrdata                                                     (cseb_wrdata                                                          ),//output [31 : 0]
      .csebwrdataparity                                               (cseb_wrdata_parity                                                    ),//output [3 : 0]
      .csebwren                                                       (cseb_wren                                                            ),//output
      .csebwrrespreq                                                  (cseb_wrresp_req                                                       ),//output
      .bistdonearcv                                                   (open_bistdonearcv                                                   ),//output
      .bistdonearcv1                                                  (open_bistdonearcv1                                                  ),//output
      .bistdonearpl                                                   (open_bistdonearpl                                                   ),//output
      .bistdonebrcv                                                   (open_bistdonebrcv                                                   ),//output
      .bistdonebrcv1                                                  (open_bistdonebrcv1                                                  ),//output
      .bistdonebrpl                                                   (open_bistdonebrpl                                                   ),//output
      .bistpassrcv                                                    (open_bistpassrcv                                                    ),//output
      .bistpassrcv1                                                   (open_bistpassrcv1                                                   ),//output
      .bistpassrpl                                                    (open_bistpassrpl                                                    ),//output
      .bistscanoutrcv                                                 (open_bistscanoutrcv                                                 ),//output
      .bistscanoutrcv1                                                (open_bistscanoutrcv1                                                ),//output
      .bistscanoutrpl                                                 (open_bistscanoutrpl                                                 ),//output
      .memredscout                                                    (open_memredscout                                                    ),//output
      .memregscanout                                                  (open_memregscanout                                                  ),//output
      .wakeoen                                                        (open_wakeoen                                                        ) //output
      );


//////////////// SIMULATION-ONLY CONTENTS
//synthesis translate_off
assign testin        = {32'h0, test_in[31:0]};
//////////////// END SIMULATION-ONLY CONTENTS
//synthesis translate_on


//////////////// SYNTHESIS-ONLY CONTENTS
// The section bellow is for synthesis only and is not used for simulation
// When reserved_debug_hwtcl=1, set SignalProbe access point to
// reservein and testin pins

//synthesis read_comments_as_HDL on
//generate begin : g_reserved_debug
//   if (reserved_debug_hwtcl==0) begin
//      assign testin     = {32'h0, test_in[31:0]};
//   end
//   else begin
//      sld_mod_ram_rom #(
//              .cvalue            (32'h00000000   ),
//              .is_data_in_ram    (0),
//              .is_readable       (0),
//              .node_name         (1414090288),
//              .numwords          (1),
//              .shift_count_bits  (6),
//              .width_word        (32),
//              .widthad           (1)
//            ) signalprobe_test_in_lsb ( .data_write(testin[31:0]) );
//
//      sld_mod_ram_rom #(
//              .cvalue            (32'h00000000),
//              .is_data_in_ram    (0),
//              .is_readable       (0),
//              .node_name         (1414090289),
//              .numwords          (1),
//              .shift_count_bits  (6),
//              .width_word        (32),
//              .widthad           (1)
//            ) signalprobe_test_in_msb ( .data_write(testin[63:32]));
//   end
//end
//endgenerate
//synthesis read_comments_as_HDL off

//////////////// END SYNTHESIS-ONLY CONTENTS

endmodule
