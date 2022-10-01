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



`timescale 1ns/10ps

import altera_xcvr_functions::*;

module sv_xcvr_custom_native #(
    parameter device_family     = "Stratix V", // (Stratix V, Arria V)
    parameter protocol_hint     = "basic",    // (basic, gige, cpri)
    parameter operation_mode    = "Duplex",   // (TX, RX, Duplex)
    parameter lanes             = 1,          // (1+)
    parameter bonded_group_size = 1,          // (1,lanes)
    parameter bonded_mode       = "xN",       // (xN, fb_compensation)
    parameter pcs_pma_width     = 8,          //legal value: 8,10,16,20
    parameter ser_base_factor   = 8,          // (8,10)
    parameter ser_words         = 1,          // (1,2,4)
    parameter data_rate         = "1250 Mbps",
    parameter base_data_rate    = "0 Mbps",   // (PLL Rate) - must be (data_rate * 1,2,4,or8)

    //tx bitslip
    parameter tx_bitslip_enable = "false",
    
    //optional coreclks 
    parameter tx_use_coreclk = "false",
    parameter rx_use_coreclk = "false",
    // SyncE
    parameter en_synce_support = 0,   //expose CDR ref-clk in this mode
    
    //8B10B
    parameter use_8b10b = "false",            // ("false", "true")
    parameter use_8b10b_manual_control = "false", // ("false", "true")
    
    //Phase compensation FIFO
    parameter std_tx_pcfifo_mode = "low_latency",
    parameter std_rx_pcfifo_mode = "low_latency", 
	
    //Word Aligner
    parameter word_aligner_mode = "bitslip",  // (bitslip, sync state machine, manual, deterministic_latency)
    parameter word_aligner_state_machine_datacnt = 0, // (0 - 256)
    parameter word_aligner_state_machine_errcnt = 0,  // (0 - 256)
    parameter word_aligner_state_machine_patterncnt = 0,  // (0 - 256)
    parameter word_aligner_pattern_length = 7,
    parameter word_align_pattern = "0000000000", 
    parameter run_length_violation_checking = 0, // (0, 1+)
    
    //RM FIFO
    parameter use_rate_match_fifo = 0, // (0,1)
    parameter rate_match_pattern1 = "00000000000000000000",
    parameter rate_match_pattern2 = "00000000000000000000",
    
    //Byte Ordering Block
    parameter byte_order_mode = "None", // (None, Sync state machine, PLD control)
    parameter byte_order_pattern = "0", 
    parameter byte_order_pad_pattern = "0",

    //Hidden parameter to enable 0ppm legality bypass
    parameter coreclk_0ppm_enable = "false",
    
    //PLL
    parameter pll_refclk_cnt    = 1,          // Number of reference clocks
    parameter pll_refclk_freq   = "125 MHz",  // Frequency of each reference clock
    parameter pll_refclk_select = "0",        // Selects the initial reference clock for each PLL
    parameter cdr_refclk_select = 0,          // Selects the initial reference clock for all RX CDR PLLs
    parameter plls              = 1,          // (1+)
    parameter pll_type          = "AUTO",     // PLL type for each PLL
    parameter pll_select        = 0,          // Selects the initial PLL
    parameter pll_reconfig      = 0,          // (0,1) 0-Disable PLL reconfig, 1-Enable PLL reconfig
    parameter pll_feedback_path = "no_compensation", //no_compensation, tx_clkout
	parameter pll_external_enable = 0,         // (0,1) 0-Disable external TX PLL, 1-Enable external TX PLL

    parameter starting_channel_number = 0,    // (0+)
	
	//Channel Interface Reconfiguration
	parameter channel_interface = 0, //legal value: (0,1) 1-Enable channel reconfiguration
    
    //low latency mode - PMA+
    parameter low_latency_mode = "false",
    parameter tx_pc_fifo_mode  = "default",  // Modify value for QPI
    parameter rx_pc_fifo_mode  = "default"   // Modify value for QPI			       
		
  ) ( 
  //input from reset controller
  input   wire    [lanes-1:0]     tx_analogreset,   // for tx pma
  input   wire    [plls -1:0]     pll_powerdown, 
  input   wire    [lanes-1:0]     tx_digitalreset,
  input   wire    [lanes-1:0]     rx_analogreset,   // for rx pma
  input   wire    [lanes-1:0]     rx_digitalreset,  // for rx pcs
  // Calibration busy signals
  output  wire    [lanes-1:0]     tx_cal_busy,
  output  wire    [lanes-1:0]     rx_cal_busy,
  
  //clk signal
  input   wire    [pll_refclk_cnt-1:0] pll_ref_clk,
  input   wire                         cdr_ref_clk, // used only in SyncE mode
  input   tri0    [lanes - 1 : 0] tx_coreclkin,
  input   tri0    [lanes - 1 : 0] rx_coreclkin,
  input   wire    [(plls*lanes)-1:0]   ext_pll_clk,      // clkout from external PLL
  
  //data ports
  input  wire [(channel_interface? 44: ser_base_factor*ser_words)*lanes-1:0] tx_parallel_data,
  output wire [(channel_interface? 64: ser_base_factor*ser_words)*lanes-1:0] rx_parallel_data,
  input   wire    [ser_words*lanes-1:0]   tx_datak,
  output  wire    [ser_words*lanes-1:0]   rx_datak,
  input   tri0    [ser_words*lanes-1:0]   tx_forcedisp,
  input   wire    [ser_words*lanes-1:0]   tx_dispval,
  input   wire    [lanes-1:0]     rx_enabyteord,
  
  input   wire    [lanes-1:0]     rx_serial_data,
  output  wire    [lanes-1:0]     tx_serial_data,
  
  //clock outputs
  output  wire    [(lanes/bonded_group_size)-1:0]     tx_clkout,
  output  wire    [lanes-1:0]     rx_clkout,
  output  wire    [lanes-1:0]     rx_recovered_clk,
        
  //control ports
  input   tri0    [lanes-1:0]     tx_forceelecidle,
  input   tri0    [lanes-1:0]     tx_invpolarity,
  input   tri0    [lanes*5-1:0]   tx_bitslipboundaryselect,
  
  input   tri0    [lanes-1:0]     rx_invpolarity,
  input   tri0    [lanes-1:0]     rx_seriallpbken,
  input   tri0    [lanes-1:0]     rx_set_locktodata,
  input   tri0    [lanes-1:0]     rx_set_locktoref,
  input   tri0    [lanes-1:0]     rx_enapatternalign,
  input   tri0    [lanes-1:0]     rx_bitslip,
  input   tri0    [lanes-1:0]     rx_bitreversalenable,
  input   tri0    [lanes-1:0]     rx_bytereversalenable,
  input   tri0    [lanes-1:0]     rx_a1a2size,
  
  output  wire    [lanes-1:0]     rx_rlv,
  output  wire    [ser_words*lanes-1:0]   rx_patterndetect,
  output  wire    [ser_words*lanes-1:0]   rx_syncstatus,
  output  wire    [lanes*5-1:0]   rx_bitslipboundaryselectout,
  output  wire    [ser_words*lanes-1:0]   rx_errdetect,
  output  wire    [ser_words*lanes-1:0]   rx_disperr,
  output  wire    [ser_words*lanes-1:0]   rx_runningdisp,
  output  wire    [lanes-1:0]     rx_rmfifofull,
  output  wire    [lanes-1:0]     rx_rmfifoempty,
  output  wire    [ser_words*lanes-1:0]   rx_rmfifodatainserted,
  output  wire    [ser_words*lanes-1:0]   rx_rmfifodatadeleted,
  output  wire    [ser_words*lanes-1:0]   rx_a1a2sizeout,
  
  output  wire    [lanes-1:0]     rx_is_lockedtoref,
  output  wire    [lanes-1:0]     rx_signaldetect,
  output  wire    [lanes-1:0]     rx_is_lockedtodata,
  output  wire    [plls -1:0]     pll_locked,
  
  output  wire    [lanes-1:0]     rx_phase_comp_fifo_error,
  output  wire    [lanes-1:0]     tx_phase_comp_fifo_error,

  // per-lane outputs
  output  wire    [lanes-1:0]     rx_byteordflag,

  input   wire  [get_custom_reconfig_to_width  ("Stratix V",operation_mode,lanes,plls,bonded_group_size,"",bonded_mode)-1:0] reconfig_to_xcvr,
  output  wire  [get_custom_reconfig_from_width("Stratix V",operation_mode,lanes,plls,bonded_group_size,"",bonded_mode)-1:0] reconfig_from_xcvr,

  input   wire    [lanes-1:0]     rxqpipulldn,
  input   wire    [lanes-1:0]     txqpipulldn,
  input   wire    [lanes-1:0]     txqpipullup,
  input   wire    [lanes-1:0]     rx_clk_slip_in      
);

import altera_xcvr_functions::*;

// Reconfig parameters
localparam w_bundle_to_xcvr     = W_S5_RECONFIG_BUNDLE_TO_XCVR;
localparam w_bundle_from_xcvr   = W_S5_RECONFIG_BUNDLE_FROM_XCVR;
localparam reconfig_interfaces  = altera_xcvr_functions::get_custom_reconfig_interfaces("Stratix V",operation_mode,lanes,plls,bonded_group_size,"",bonded_mode);

// RBC checks
localparam rbc_all_protocol_hint = "(basic,gige,cpri,srio_2p1)";
localparam fnl_protocol_hint  = (protocol_hint == "basic")  ? "basic" :
                                (protocol_hint == "gige")   ? "gige" :
                                (protocol_hint == "cpri")   ? ((word_aligner_mode=="manual")? "cpri_rx_tx":"cpri") ://cpri_rx_tx is the legacy StratixIV CPRI
                                protocol_hint;

localparam prot_mode = fnl_protocol_hint;


localparam dummy_wa_pd_data = m_str_to_bin(word_align_pattern);
localparam [7:0] dummy_wa_sm_datacnt = word_aligner_state_machine_datacnt [7:0];
localparam [6:0] dummy_wa_sm_errcnt = word_aligner_state_machine_errcnt [6:0];
localparam [7:0] dummy_wa_sm_patterncnt = word_aligner_state_machine_patterncnt [7:0];

localparam tmp_bo_pat = m_str_to_bin(byte_order_pattern);
localparam bo_pat = tmp_bo_pat[19:0];

localparam tmp_bo_pad_pat = m_str_to_bin(byte_order_pad_pattern);
localparam bo_pad_pat = tmp_bo_pad_pat[9:0];

localparam tmp_rm_pat2 = m_str_to_bin(rate_match_pattern2);
localparam rm_pat2 = tmp_rm_pat2[19:0];

localparam tmp_rm_pat1 = m_str_to_bin(rate_match_pattern1);
localparam rm_pat1 = tmp_rm_pat1[19:0];

//localparam time data_rate_int = str2hz(data_rate);    // data rate in Hz.  Must use time unit since its a 64-bit unsigned int
`define data_rate_int (str2hz(data_rate)/1000000)       // data rate in Hz.  Must use time unit since its a 64-bit unsigned int
//`define half_data_rate string'(hz2str(`data_rate_int/2))

// Default base data rate to data rate if not specified
localparam [MAX_STRS*MAX_CHARS*8-1:0] INT_BASE_DATA_RATE = (get_value_at_index(0, base_data_rate) == "0 Mbps") ? data_rate : base_data_rate;
localparam INT_TX_CLK_DIV = str2hz(get_value_at_index(pll_select, INT_BASE_DATA_RATE)) / str2hz(data_rate);

localparam deser_factor = ser_base_factor * ser_words;

localparam pcs_double_width = (deser_factor == 32 || deser_factor == 40)? "true"
                              : (deser_factor == 8 || deser_factor == 10)? "false"
                              : ((pcs_pma_width == 8 || pcs_pma_width == 10) && deser_factor == 16)? "true"
                              : (pcs_pma_width == 10 && deser_factor == 20)? "true"
                              : "false";

localparam pcs_param_pma_dw = (pcs_pma_width == 8) ? "eight_bit"
                    : (pcs_pma_width == 10) ? "ten_bit"
                    : (pcs_pma_width == 16) ? "sixteen_bit"
                    : (pcs_pma_width == 20) ? "twenty_bit"
                    : "invalid";
                    
localparam run_length_resolution = (pcs_pma_width == 8)? 4
                                    : (pcs_pma_width == 10)? 5
                                    : (pcs_pma_width == 16)? 8
                                    : (pcs_pma_width == 20)? 10 
                                    : -1;

localparam run_length_max = (pcs_pma_width == 8 || pcs_pma_width == 10)? run_length_resolution * 32
                            : run_length_resolution * 64;

localparam INT_RUN_LENGTH = run_length_violation_checking / run_length_resolution;

localparam [5:0] dummy_run_length = (run_length_violation_checking == run_length_max)? 6'b000000 : INT_RUN_LENGTH [5:0];

localparam pma_data_rate = data_rate;
                                          
localparam SKIP_WORD= ((deser_factor == 16 || deser_factor == 20) && pcs_double_width == "true") ? 2 : 1; //for 3G PCS DW mode, skip a word

localparam tx_data_bundle_size = 11; // TX PLD to PCS interface groups data and control in 11-bit bundles
localparam rx_data_bundle_size = 16; // RX PCS to PLD interface groups data and status in 16-bit bundles

localparam INT_IN_PLD_SYNC_SM_EN = (word_aligner_mode == "sync_state_machine") ? 1'b1 : 1'b0;
localparam INT_WA_PATTERN_LENGTH =  (word_aligner_mode == "bitslip" || low_latency_mode == "true" || protocol_hint == "cpri") ? "<auto_single>"
                                  : (word_aligner_pattern_length == 7)   ? ((prot_mode == "gige" || prot_mode == "srio_2p1") ? "wa_pd_fixed_7_k28p5" : "wa_pd_7")
                                  : (word_aligner_pattern_length == 8)   ? ((pcs_pma_width == 8) ? "wa_pd_8_sw" : "wa_pd_8_dw") 
                                  : (word_aligner_pattern_length == 10)  ? ((prot_mode == "gige" || prot_mode == "srio_2p1") ? "wa_pd_fixed_10_k28p5" : "wa_pd_10")
                                  : (word_aligner_pattern_length == 16)  ? ((pcs_pma_width == 8)? "wa_pd_16_sw" : "wa_pd_16_dw")
                                  : (word_aligner_pattern_length == 20)  ? "wa_pd_20"
                                  : (word_aligner_pattern_length == 32)  ? "wa_pd_32"
                                  : "wa_pd_7";

//localparam  INT_PHASE_COMP_FIFO = (prot_mode == "cpri_rx_tx" || prot_mode == "cpri") ? "register_fifo"
//                                : "low_latency";

localparam INT_TX_PHASE_COMP_FIFO = (tx_pc_fifo_mode != "default")? tx_pc_fifo_mode :      // Set tx_pc_fifo_mode != "default" for QPI
				    ((prot_mode == "cpri_rx_tx" || prot_mode == "cpri" || ((prot_mode == "basic" || prot_mode == "gige") && std_tx_pcfifo_mode == "register_fifo"))? "register_fifo":
                                    "low_latency");

localparam INT_RX_PHASE_COMP_FIFO = (rx_pc_fifo_mode != "default")? rx_pc_fifo_mode :      // Set rx_pc_fifo_mode != "default" for QPI
                                    ((prot_mode == "cpri_rx_tx" || prot_mode == "cpri" || ((prot_mode == "basic" || prot_mode == "gige") && std_rx_pcfifo_mode == "register_fifo"))? "register_fifo": 
                                    "low_latency");

//tx localparam
/// TODO: this parameter should be validated against ser_base_factor. Changed the rule for now to compute it on the fly
localparam INT_TX_PCS_USE_DOUBLE_DATA = (pcs_double_width == "true") ? "en_bs_by_2" : "dis_bs"; 

//localparam for RX
localparam INT_RX_USE_LOCALREFCLK = 0; //temporary setting, 0=false, 1=true

localparam INT_BO_MODE =  (byte_order_mode == "PLD control") ? 
                              ((pcs_pma_width == 8 || pcs_pma_width == 16) ? "en_pld_ctrl_eight_bit_bo"
                            : ((use_8b10b == "true")? "en_pld_ctrl_nine_bit_bo" : "en_pld_ctrl_ten_bit_bo"))
                        : (byte_order_mode == "sync state machine") ?
                              ((pcs_pma_width == 8 || pcs_pma_width == 16) ? "en_pcs_ctrl_eight_bit_bo"
                            : ((use_8b10b == "true")? "en_pcs_ctrl_nine_bit_bo" : "en_pcs_ctrl_ten_bit_bo"))
                        : "dis_bo";                                                                                   

localparam INT_SYMBOL_SWAP = ((prot_mode == "basic")&&(pcs_pma_width == 16 || pcs_pma_width == 20))? "en_symbol_swap" : "dis_symbol_swap";

localparam INT_RUN_LENGTH_EN                = (pcs_param_pma_dw == "eight_bit" || pcs_param_pma_dw == "ten_bit") ? "en_runlength_sw" : "en_runlength_dw";
localparam INT_RX_CLK1_MUX_SELECT           = (prot_mode == "srio_2p1")? "<auto_any>" : "rcvd_clk_clk1"; // srio_2p1 x4_cmu3 uses rcvd_clk_agg_clk1 for ch0,1,2 and rcvd_clk_agg_top_or_bottom_clk1 for ch3
localparam INT_RX_CLK2_MUX_SELECT           = (use_rate_match_fifo == 0) ? "rcvd_clk_clk2" : "tx_pma_clock_clk2"; 
localparam INT_RX_RECOVERED_CLK_MUX_SELECT  = "rcvd_clk_rcvd_clk"; 
localparam INT_RX_RD_CLK_MUX_SELECT         = (protocol_hint == "cpri" ||((prot_mode == "basic" || prot_mode == "gige") && std_rx_pcfifo_mode == "register_fifo"))? "rx_clk":"pld_rx_clk"; 

localparam INT_WA_MODE =  (word_aligner_mode == "manual")             ? "auto_align_pld_ctrl"
                        : (word_aligner_mode == "sync_state_machine")? "sync_sm"
                        : (word_aligner_mode == "deterministic_latency")? "deterministic_latency"
                        : "bit_slip"; //bypass mode need to set to bit_slip

localparam INT_RX_PCS_USE_DOUBLE_DATA = (pcs_double_width == "true") ? "en_bds_by_2" : "dis_bds"; 
localparam INT_WA_PLD_CONTROLLED      = (word_aligner_mode == "sync_state_machine"||word_aligner_mode == "deterministic_latency")? "dis_pld_ctrl"
                                      : (pcs_pma_width == 8 || pcs_pma_width == 10) ? "pld_ctrl_sw"
                                      : "rising_edge_sensitive_dw";

localparam INT_WA_SYNC_SM_CTRL = (prot_mode == "gige") ? "gige_sync_sm" 
                               : (prot_mode == "srio_2p1")? "srio2p1_sync_sm"
                               : (word_aligner_mode == "sync_state_machine") ? ((pcs_pma_width == 20) ? "dw_basic_sync_sm" : "sw_basic_sync_sm")
                               : "gige_sync_sm";

localparam INT_WA_DISP_ERR_FLAG = (use_8b10b == "true") ? "en_disp_err_flag" : "dis_disp_err_flag";

//8B10
localparam INT_EN_8B_10B_ENC    = (use_8b10b == "false") ? "dis_8b10b" : "en_8b10b_ibm";
localparam INT_EN_8B_10B_DEC    = (use_8b10b == "false") ? "dis_8b10b" : "en_8b10b_ibm";
localparam INT_8B_10B_DISP_CTRL = (use_8b10b_manual_control == "false") ? "dis_disp_ctrl" : "en_disp_ctrl";


localparam INT_SYMBOL_BO = (byte_order_mode == "PLD control" || byte_order_mode == "sync state machine") ? 
                                (pcs_double_width == "true") ?
                                    (pcs_pma_width == 16)                        ? "two_symbol_bo_eight_bit"
                                    : (pcs_pma_width == 20 && use_8b10b == "true") ? "two_symbol_bo_nine_bit"
                                    : (pcs_pma_width == 20 && use_8b10b == "false")? "two_symbol_bo_ten_bit"
                                    : "donot_care_one_two_bo"
                              : "donot_care_one_two_bo"
                          : "donot_care_one_two_bo";

//TX BITSLIP
localparam INT_EN_TX_BITSLIP  = (prot_mode == "gige") ? "dis_tx_bitslip"
                              : (tx_bitslip_enable == "true") ? "en_tx_bitslip"
                              : "dis_tx_bitslip";

//RM FIFO
localparam INT_RM_FIFO_MODE = (use_rate_match_fifo == 1) ? 
                                  (prot_mode == "gige") ? "gige_rm"
                                : (prot_mode == "srio_2p1")? "srio_v2p1_rm_0ppm" // TODO: can be both srio_v2p1_rm and srio_v2p1_rm_0ppm
                                : (pcs_pma_width == 20 || pcs_pma_width == 16) ? "dw_basic_rm"
                                : "sw_basic_rm"
                              : "dis_rm";

localparam  INT_RX_ENABLE = (operation_mode == "Rx" || operation_mode == "RX"
                          || operation_mode == "Duplex" || operation_mode == "DUPLEX") ? 1 : 0;
localparam  INT_TX_ENABLE = (operation_mode == "Tx" || operation_mode == "TX"
                          || operation_mode == "Duplex" || operation_mode == "DUPLEX") ? 1 : 0;

localparam  INT_RX_POL_INV = "en_pol_inv";
localparam  INT_TX_POL_INV = "enable_polinv";

localparam  INT_RX_BIT_REV = (prot_mode == "basic") ? "en_bit_reversal" : "dis_bit_reversal";

//case 198618
`ifndef SV_XCVR_CUSTOM_NATIVE_ASSERT_SYNC_STATUS_IMM
`define SV_XCVR_CUSTOM_NATIVE_ASSERT_SYNC_STATUS_IMM "<auto_any>"
`endif

localparam INT_WA_DET_LATENCY_SYNC_STATUS = (prot_mode == "cpri")? `SV_XCVR_CUSTOM_NATIVE_ASSERT_SYNC_STATUS_IMM:"<auto_single>"; //valid setting:assert_sync_status_imm,assert_sync_status_non_imm[default] for CPRI
localparam INT_WA_CLK_SLIP_SPACING = (prot_mode == "cpri")? "<auto_any>":"<auto_single>"; //valid setting:min_clk_slip_spacing[default],user_programmable_clk_slip_spacing
localparam INT_RX_PCS_PMA_IF_PROT_MODE = (prot_mode == "cpri")? "cpri_8g": "other_protocols";
localparam INT_CLKSLIP_SEL = (prot_mode == "cpri")? "slip_eight_g_pcs": "pld"; //legal value: pld|slip_eight_g_pcs
localparam INT_DESER_ENABLE_BIT_SLIP = "true";

// local parameter for pma_bonding_type 
localparam pma_bonding_type = (bonded_mode == "fb_compensation")? "fb_compensation": "default";

//PLD-PCS wires
// used data bundle width is [tx_data_bundle_size * ser_words * lanes - 1: 0], but declare 10G max size (64b/lane)
tri0 [64 * lanes - 1: 0]  tx_datain_from_pld;
//conduit
wire [lanes - 1 : 0]      tx_coreclk_in;

//wires for RX
// used data bundle width is [rx_data_bundle_size * ser_words * lanes - 1: 0], but declare max size
tri0 [rx_data_bundle_size * 4 * lanes - 1: 0] rx_dataout_to_pld;
wire [lanes - 1 : 0] rx_coreclk_in;
wire [lanes - 1 : 0] dataout_from_pma;
wire [lanes - 1 : 0] int_pcfifoempty;
wire [lanes - 1 : 0] int_pcfifofull;

//wires for TX
wire [lanes - 1 : 0] int_phfifounderflow;
wire [lanes - 1 : 0] int_phfifooverflow;
wire [lanes - 1 : 0] tx_clkout_to_pld;
wire [lanes - 1 : 0] tx_clkdivtx;
wire [(plls*lanes)-1:0] pll_out_clk;

//wire for PLL
wire [plls  - 1 : 0] pll_locked_wire [lanes-1:0];
wire [lanes - 1 : 0] pll_locked_xpos [plls-1:0];

//wires for QPI
//wire [lanes - 1 : 0] rxqpipulldn;   // QPI input port
//wire [lanes - 1 : 0] txqpipulldn;   // QPI input port
//wire [lanes - 1 : 0] txqpipullup;   // QPI input port

// Declare local merged versions of reconfig buses 
wire  [get_custom_reconfig_to_width  ("Stratix V",operation_mode,lanes,plls,bonded_group_size,"",bonded_mode)-1:0] rcfg_to_xcvr;
wire  [get_custom_reconfig_from_width("Stratix V",operation_mode,lanes,plls,bonded_group_size,"",bonded_mode)-1:0] rcfg_from_xcvr;

// SYNCE
wire  [bonded_group_size*pll_refclk_cnt-1:0] cdr_clock ;
// Parameter validation
initial begin
  if(!is_in_legal_set(protocol_hint, rbc_all_protocol_hint)) begin
    $display("Critical Warning: Parameter 'protocol_hint' of instance '%m' has illegal value '%s' assigned to it. Valid parameter values are: '%s'.  Using value '%s'", protocol_hint, rbc_all_protocol_hint, fnl_protocol_hint);
  end

  if((bonded_group_size != lanes) && (bonded_group_size != 1)) begin
    $display("Error: Parameter 'bonded_group_size' of instance '%m' has illegal value '%d' assigned to it.  Valid parameter values are: '1' and '%d'.", bonded_group_size, lanes);
  end
end
// End parameter validation

genvar ig;  // Iterator for generated loops
genvar jg;
genvar num_word;

generate begin:gen

  // 1 bit of tx_clkout per lane when non-bonded, 1 bit of tx_clkout per instance when bonded
  assign tx_clkout  = tx_clkout_to_pld[(lanes/bonded_group_size) - 1 : 0];

  // One pll_locked output per logical PLL
  for (ig=0; ig<plls; ig=ig+1) begin:assign_pll_locked
    assign  pll_locked[ig] = &pll_locked_xpos[ig];
  end
  //******************* End pll_locked assignments ********************
  //*******************************************************************

  for(ig=0; ig<lanes; ig = ig + 1) begin: sv_xcvr_native_insts
    // bonding size for bonded channel instantiations
    // bonded_group_size must be equal to 1 or the number of lanes
    localparam num_bonded = bonded_group_size; 

    localparam  [MAX_CHARS*8-1:0] INT_FEEDBACK_CLK  = (bonded_mode       == "fb_compensation") ? "external" :
                                                      (pll_feedback_path == "no_compensation") ? "internal" :
                                                      "external";

    // Transpose PLL locked from [lanes][plls]->[plls][lanes]
    for(jg=0; jg<plls; jg=jg+1) begin:gen_pll_locked_xpos
      assign  pll_locked_xpos[jg][ig] = pll_locked_wire[ig][jg];
    end

    if( ((ig % bonded_group_size) == 0) || (bonded_mode == "fb_compensation") ) begin:gen_tx_plls

      if(INT_TX_ENABLE == 1  && pll_external_enable == 0) begin:gen_tx_plls
        wire  tx_fbclk;
        // Use PMA clock for feedback compensation bonding, otherwise PCS clock compensation
        assign  tx_fbclk = (bonded_mode == "fb_compensation") ? tx_clkdivtx[ig] : tx_clkout[ig / bonded_group_size];  

        sv_xcvr_plls #(
          .plls                     (plls               ),
          .pll_type                 (pll_type           ),
          .pll_reconfig             (pll_reconfig       ),
          .refclks                  (pll_refclk_cnt     ),
          .reference_clock_frequency(pll_refclk_freq    ),
          .reference_clock_select   (pll_refclk_select  ),
          .output_clock_datarate    (INT_BASE_DATA_RATE ),
          .feedback_clk             (INT_FEEDBACK_CLK   )

        ) tx_plls (
          .refclk     (pll_ref_clk                    ),
          .rst        (pll_powerdown                  ),
          .fbclk      ({plls{tx_fbclk}}               ),
          .outclk     (pll_out_clk    [ig*plls+:plls] ),
          .locked     (pll_locked_wire[ig]            ),
          .fboutclk   (/*unused*/                     ),
    
          // avalon MM native reconfiguration interfaces
          .reconfig_to_xcvr   (rcfg_to_xcvr   [(lanes+(plls*ig))*w_bundle_to_xcvr+:plls*w_bundle_to_xcvr]     ),
          .reconfig_from_xcvr (rcfg_from_xcvr [(lanes+(plls*ig))*w_bundle_from_xcvr+:plls*w_bundle_from_xcvr] ),

          .hclk       (/*unused*/ ),
          .pll_fb_sw  (/*unused*/ )
        );
	  end
      else if (INT_TX_ENABLE == 1 && pll_external_enable == 1) begin:gen_tx_plls
		assign pll_out_clk[ig*plls+:plls] = ext_pll_clk[ig*plls+:plls];
		assign  pll_locked_wire[ig]       = {plls{1'b0}};
      end 
	  else begin:gen_no_tx // TX disabled
        assign  pll_out_clk[ig*plls+:plls]  = {plls{1'b0}};
        assign  pll_locked_wire[ig]         = {plls{1'b0}};
      end

    end else begin:gen_pll_fanout
        assign pll_out_clk[ig*plls+:plls] = pll_out_clk[0+:plls]; // Fanout pll_out_clk for xN bonding
        assign pll_locked_wire[ig]        = pll_locked_wire[0];   // Fanout pll_locked for xN bonded mode
    end
       
// use cdr_ref_clk for syncE mode and pll_ref_clk otherwise
  if (en_synce_support) begin : SYNCE
   assign cdr_clock = {num_bonded{cdr_ref_clk}};	
  end else begin : NO_SYNCE
   assign cdr_clock = {num_bonded{pll_ref_clk}}; 
  end

    if((ig % bonded_group_size) == 0) begin:gen_bonded_group
      // Create native transceiver interface
      sv_xcvr_native #(
          // PMA
          .rx_enable                      (INT_RX_ENABLE          ),
          .tx_enable                      (INT_TX_ENABLE          ),
          .pma_bonding_type               (pma_bonding_type       ),
          .bonded_lanes                   (num_bonded             ),
          .pma_prot_mode                  (prot_mode              ),
          .pma_mode                       (pcs_pma_width          ),  // (8,10,16,20,32,40,64,80) Serialization factor
          .pma_data_rate                  (pma_data_rate          ),  // Serial data rate in bits-per-second
          .cdr_reference_clock_frequency  (pll_refclk_freq        ),
          .cdr_refclk_cnt                 (pll_refclk_cnt         ),
          .cdr_refclk_sel                 (cdr_refclk_select      ),
          .cdr_reconfig                   (pll_reconfig           ),
          .tx_clk_div                     (INT_TX_CLK_DIV         ),
          .plls                           (plls                   ),
          .pll_sel                        (pll_select             ),
          .deser_enable_bit_slip          (INT_DESER_ENABLE_BIT_SLIP  ),

          // PCS 
          .enable_8g_rx                   (INT_RX_ENABLE ? "true" : "false"),
          .enable_8g_tx                   (INT_TX_ENABLE ? "true" : "false"),
          .enable_10g_rx                  ("false"),
          .enable_10g_tx                  ("false"),
          .enable_dyn_reconfig            ("false"),
          .enable_gen12_pipe              ("false"),
          .enable_gen3_pipe               ("false"),
          .enable_gen3_rx                 ("false"),
          .enable_gen3_tx                 ("false"),
          
          // parameters for stratixv_hssi_8g_rx_pcs
          //.pcs8g_rx_auto_deassert_pc_rst_cnt_data (5'b01000              ),
          .pcs8g_rx_auto_error_replacement("<auto_any>"           ),
          .pcs8g_rx_bit_reversal          (INT_RX_BIT_REV         ),
          .pcs8g_rx_bo_pad                (bo_pad_pat             ),
          .pcs8g_rx_bo_pattern            (bo_pat                 ),
          .pcs8g_rx_byte_deserializer     (INT_RX_PCS_USE_DOUBLE_DATA ),
          .pcs8g_rx_byte_order            (INT_BO_MODE            ),
          .pcs8g_rx_clkcmp_pattern_n      (rm_pat2    ),
          .pcs8g_rx_clkcmp_pattern_p      (rm_pat1    ),
          .pcs8g_rx_deskew_prog_pattern_only("dis_deskew_prog_pat_only"), // TODO - had to add
          .pcs8g_rx_dw_one_or_two_symbol_bo (INT_SYMBOL_BO        ),
          .pcs8g_rx_eightb_tenb_decoder   (INT_EN_8B_10B_DEC      ),
          .pcs8g_rx_err_flags_sel         ("<auto_any>"           ),
          .pcs8g_rx_mask_cnt              (10'h320                ),
          .pcs8g_rx_pcs_bypass            ((low_latency_mode == "true")? "en_pcs_bypass" : "dis_pcs_bypass"),
          .pcs8g_rx_phase_compensation_fifo(INT_RX_PHASE_COMP_FIFO),      // modified for QPI
          .pcs8g_rx_pma_dw                (pcs_param_pma_dw       ),
          .pcs8g_rx_polarity_inversion    (INT_RX_POL_INV         ),
//        .pcs8g_rx_polinv_8b10b_dec      ("en_polinv_8b10b_dec"  ),
          .pcs8g_rx_prot_mode             (prot_mode              ),
          .pcs8g_rx_rate_match            (INT_RM_FIFO_MODE       ),
//        .pcs8g_rx_re_bo_on_wa (I),
          .pcs8g_rx_runlength_check       (INT_RUN_LENGTH_EN      ),
          .pcs8g_rx_runlength_val         (dummy_run_length  ),
          .pcs8g_rx_rx_clk1               (INT_RX_CLK1_MUX_SELECT ),
          .pcs8g_rx_rx_clk2               (INT_RX_CLK2_MUX_SELECT ),
          .pcs8g_rx_rx_rcvd_clk           (INT_RX_RECOVERED_CLK_MUX_SELECT  ),
          .pcs8g_rx_rx_rd_clk             (INT_RX_RD_CLK_MUX_SELECT ),
          .pcs8g_rx_sup_mode              ("user_mode"            ),
          .pcs8g_rx_symbol_swap           (INT_SYMBOL_SWAP        ),
          .pcs8g_rx_wa_boundary_lock_ctrl (INT_WA_MODE            ),
          .pcs8g_rx_wa_disp_err_flag      (INT_WA_DISP_ERR_FLAG   ),
          .pcs8g_rx_wa_pd                 (INT_WA_PATTERN_LENGTH  ),
          .pcs8g_rx_wa_pd_data            (dummy_wa_pd_data       ),
          .pcs8g_rx_wa_pld_controlled     (INT_WA_PLD_CONTROLLED  ),
          .pcs8g_rx_wa_renumber_data (dummy_wa_sm_errcnt),
          .pcs8g_rx_wa_rgnumber_data (dummy_wa_sm_datacnt),
          .pcs8g_rx_wa_rknumber_data (dummy_wa_sm_patterncnt),
          .pcs8g_rx_wa_sync_sm_ctrl       (INT_WA_SYNC_SM_CTRL    ),
          .pcs8g_rx_wa_det_latency_sync_status_beh ( INT_WA_DET_LATENCY_SYNC_STATUS ),
          .pcs8g_rx_wa_clk_slip_spacing   ( INT_WA_CLK_SLIP_SPACING ),

          .rx_pld_pcs_if_is_8g_0ppm       (coreclk_0ppm_enable    ),
          
          // parameters for stratixv_hssi_8g_tx_pcs
          .pcs8g_tx_bit_reversal          ("dis_bit_reversal"     ),
          .pcs8g_tx_byte_serializer       (INT_TX_PCS_USE_DOUBLE_DATA ),
          .pcs8g_tx_eightb_tenb_disp_ctrl (INT_8B_10B_DISP_CTRL   ),
          .pcs8g_tx_eightb_tenb_encoder   (INT_EN_8B_10B_ENC      ),
          .pcs8g_tx_pcs_bypass            ((low_latency_mode == "true")? "en_pcs_bypass" : "dis_pcs_bypass"),
          .pcs8g_tx_phase_compensation_fifo(INT_TX_PHASE_COMP_FIFO),  // modified for QPI
          .pcs8g_tx_pma_dw                (pcs_param_pma_dw       ),
          .pcs8g_tx_polarity_inversion    (INT_TX_POL_INV         ),
          .pcs8g_tx_prot_mode             (prot_mode              ),
          .pcs8g_tx_sup_mode              ("user_mode"            ),
          .pcs8g_tx_symbol_swap           ("dis_symbol_swap"      ),
          .pcs8g_tx_tx_bitslip            (INT_EN_TX_BITSLIP      ),
//        .pcs8g_tx_tx_compliance_controlled_disparity(),
           
          .tx_pld_pcs_if_is_8g_0ppm       (coreclk_0ppm_enable    ),

          .rx_pcs_pma_if_prot_mode        (INT_RX_PCS_PMA_IF_PROT_MODE ),
          .rx_pcs_pma_if_selectpcs        ("eight_g_pcs"          ),
          .rx_pcs_pma_if_clkslip_sel      (INT_CLKSLIP_SEL        ),


//        .com_pld_pcs_if_hrdrstctrl_en_cfgusr  ("hrst_en_cfgusr" ), // hrst_dis_cfgusr|hrst_en_cfgusr
          // parameters for stratixv_hssi_common_pcs_pma_interface
          .com_pcs_pma_if_func_mode         ("eightg_only_pld"    ),
          .com_pcs_pma_if_prot_mode         ("other_protocols"    ),
          .com_pcs_pma_if_sup_mode          ("user_mode"          ),
          .com_pcs_pma_if_selectpcs         ("eight_g_pcs"        ),
          .com_pcs_pma_if_force_freqdet     ("force_freqdet_dis"  ),
          .com_pcs_pma_if_ppmsel            ("ppmsel_1000"          ),
          .com_pcs_pma_if_auto_speed_ena    ("dis_auto_speed_ena" ) 
      ) sv_xcvr_native_inst(
        // PMA ports
        // TX/RX ports
        .seriallpbken   (rx_seriallpbken      [ig +: num_bonded]  ),  // 1 = enable serial loopback
        // RX ports
        .rx_crurstn     (~rx_analogreset      [ig +: num_bonded]  ),  // TODO - investigate resets
        .rx_datain      (rx_serial_data       [ig +: num_bonded]  ),  // RX serial data input
        .rx_cdr_ref_clk (cdr_clock                                ),  // Reference clock for CDR
        .rx_ltd         (rx_set_locktodata    [ig +: num_bonded]  ),  // Force lock-to-data stream (TODO - active low)
        .rx_is_lockedtoref(rx_is_lockedtoref  [ig +: num_bonded]  ),  // Indicates lock to reference clock
        .rx_is_lockedtodata(rx_is_lockedtodata[ig +: num_bonded]  ),
        .rx_clkdivrx    (rx_recovered_clk     [ig +: num_bonded]  ),
        .rxqpipulldn    (rxqpipulldn          [ig +: num_bonded]  ),  // QPI input port
			    
        // TX ports
        .tx_rxdetclk    (/*TODO*/ ),  // Clock for detection of downstream receiver (125MHz ?)
        .tx_dataout     (tx_serial_data       [ig +: num_bonded]  ),  // TX serial data output
        .tx_rstn        (~tx_analogreset      [ig +: num_bonded]  ),  // TX CGB/SER reset
        .tx_clkdivtx    (tx_clkdivtx          [ig +: num_bonded]  ),
        .tx_ser_clk     (pll_out_clk          [ig*plls+:(num_bonded*plls)]),  // High-speed serial clocks from PLL
        .tx_cal_busy    (tx_cal_busy          [ig +: num_bonded]  ),
        .rx_cal_busy    (rx_cal_busy          [ig +: num_bonded]  ),
        .txqpipulldn    (txqpipulldn          [ig +: num_bonded]  ),  // QPI input port
	.txqpipullup    (txqpipullup          [ig +: num_bonded]  ),  // QPI input port
        //output ports for cgb

        //PCS ports
        .in_agg_align_status                  (/*unused*/ ),
        .in_agg_align_status_sync_0           (/*unused*/ ),
        .in_agg_align_status_sync_0_top_or_bot(/*unused*/ ),
        .in_agg_align_status_top_or_bot       (/*unused*/ ),
        .in_agg_cg_comp_rd_d_all              (/*unused*/ ),
        .in_agg_cg_comp_rd_d_all_top_or_bot   (/*unused*/ ),
        .in_agg_cg_comp_wr_all                (/*unused*/ ),
        .in_agg_cg_comp_wr_all_top_or_bot     (/*unused*/ ),
        .in_agg_del_cond_met_0                (/*unused*/ ),
        .in_agg_del_cond_met_0_top_or_bot     (/*unused*/ ),
        .in_agg_en_dskw_qd                    (/*unused*/ ),
        .in_agg_en_dskw_qd_top_or_bot         (/*unused*/ ),
        .in_agg_en_dskw_rd_ptrs               (/*unused*/ ),
        .in_agg_en_dskw_rd_ptrs_top_or_bot    (/*unused*/ ),
        .in_agg_fifo_ovr_0                    (/*unused*/ ),
        .in_agg_fifo_ovr_0_top_or_bot         (/*unused*/ ),
        .in_agg_fifo_rd_in_comp_0             (/*unused*/ ),
        .in_agg_fifo_rd_in_comp_0_top_or_bot  (/*unused*/ ),
        .in_agg_fifo_rst_rd_qd                (/*unused*/ ),
        .in_agg_fifo_rst_rd_qd_top_or_bot     (/*unused*/ ),
        .in_agg_insert_incomplete_0           (/*unused*/ ),
        .in_agg_insert_incomplete_0_top_or_bot(/*unused*/ ),
        .in_agg_latency_comp_0                (/*unused*/ ),
        .in_agg_latency_comp_0_top_or_bot     (/*unused*/ ),
        .in_agg_rcvd_clk_agg                  (/*unused*/ ),
        .in_agg_rcvd_clk_agg_top_or_bot       (/*unused*/ ),
        .in_agg_rx_control_rs                 (/*unused*/ ),
        .in_agg_rx_control_rs_top_or_bot      (/*unused*/ ),
        .in_agg_rx_data_rs                    (/*unused*/ ),
        .in_agg_rx_data_rs_top_or_bot         (/*unused*/ ),
        .in_agg_test_so_to_pld_in             (/*unused*/ ),
        .in_agg_testbus                       (/*unused*/ ),
        .in_agg_tx_ctl_ts                     (/*unused*/ ),
        .in_agg_tx_ctl_ts_top_or_bot          (/*unused*/ ),
        .in_agg_tx_data_ts                    (/*unused*/ ),
        .in_agg_tx_data_ts_top_or_bot         (/*unused*/ ),

        .in_emsip_com_in                      (/*unused*/ ),
        .in_emsip_com_special_in              (/*unused*/ ),
        .in_emsip_rx_clk_in                   (/*unused*/ ),
        .in_emsip_rx_in                       (/*unused*/ ),
        .in_emsip_rx_special_in               (/*unused*/ ),
        .in_emsip_tx_clk_in                   (/*unused*/ ),
        .in_emsip_tx_in                       (/*unused*/ ),
        .in_emsip_tx_special_in               (/*unused*/ ),

        .in_pld_10g_refclk_dig                (/*unused*/ ),
        .in_pld_10g_rx_align_clr              (/*unused*/ ),
        .in_pld_10g_rx_align_en               (/*unused*/ ),
        .in_pld_10g_rx_bitslip                (/*unused*/ ),
        .in_pld_10g_rx_clr_ber_count          (/*unused*/ ),
        .in_pld_10g_rx_clr_errblk_cnt         (/*unused*/ ),
        .in_pld_10g_rx_disp_clr               (/*unused*/ ),
        .in_pld_10g_rx_pld_clk                (/*unused*/ ),
        .in_pld_10g_rx_prbs_err_clr           (/*unused*/ ),
        .in_pld_10g_rx_rd_en                  (/*unused*/ ),
        .in_pld_10g_rx_rst_n                  (/*unused*/ ),
        .in_pld_10g_tx_bitslip                (/*unused*/ ),
        .in_pld_10g_tx_burst_en               (/*unused*/ ),
        .in_pld_10g_tx_control                (/*unused*/ ),
        .in_pld_10g_tx_data_valid             (/*unused*/ ),
        .in_pld_10g_tx_diag_status            (/*unused*/ ),
        .in_pld_10g_tx_pld_clk                (/*unused*/ ),
        .in_pld_10g_tx_rst_n                  (/*unused*/ ),
        .in_pld_10g_tx_wordslip               (/*unused*/ ),

        .in_pld_8g_a1a2_size                  (rx_a1a2size          [ig +: num_bonded]  ),
        .in_pld_8g_bitloc_rev_en              (rx_bitreversalenable [ig +: num_bonded]  ),
        .in_pld_8g_bitslip                    (rx_bitslip           [ig +: num_bonded]  ),
        .in_pld_8g_byte_rev_en                (rx_bytereversalenable[ig +: num_bonded]  ),
        .in_pld_8g_bytordpld                  (rx_enabyteord        [ig +: num_bonded]  ),
        .in_pld_8g_cmpfifourst_n              (/*unused*/ ),  // TODO
        .in_pld_8g_encdt                      (rx_enapatternalign   [ig +: num_bonded]  ),
        .in_pld_8g_phfifourst_rx_n            (/*unused*/ ),  // TODO
        .in_pld_8g_phfifourst_tx_n            (/*unused*/ ),  // TODO
        .in_pld_8g_pld_rx_clk                 (rx_coreclk_in        [ig +: num_bonded]  ),
        .in_pld_8g_pld_tx_clk                 (tx_coreclk_in        [ig +: num_bonded]  ),
        .in_pld_8g_polinv_rx                  (rx_invpolarity       [ig +: num_bonded]  ),
        .in_pld_8g_polinv_tx                  (tx_invpolarity       [ig +: num_bonded]  ),
        .in_pld_8g_powerdown                  (/*unused*/ ),
        .in_pld_8g_prbs_cid_en                (/*unused*/ ),
        .in_pld_8g_rddisable_tx               ({num_bonded{1'b0}} ),
        .in_pld_8g_rdenable_rmf               ({num_bonded{1'b0}} ),
        .in_pld_8g_rdenable_rx                (/*unused*/ ),
        .in_pld_8g_refclk_dig                 (/*unused*/ ),
        .in_pld_8g_refclk_dig2                (/*unused*/ ),
        .in_pld_8g_rev_loopbk                 ({num_bonded{1'b0}} ),
        .in_pld_8g_rxpolarity                 (/*unused*/ ),
        .in_pld_8g_rxurstpcs_n                (~rx_digitalreset      [ig +: num_bonded] ),
        .in_pld_8g_tx_blk_start               ({num_bonded{4'b0000}}                    ),
        .in_pld_8g_tx_boundary_sel            (tx_bitslipboundaryselect [(ig*5) +: (num_bonded*5)]  ),
        .in_pld_8g_tx_data_valid              ({num_bonded{4'b0000}}                    ),
        .in_pld_8g_tx_sync_hdr                ({num_bonded{2'b00}}                      ),
        .in_pld_8g_txdeemph                   (/*unused*/ ),
        .in_pld_8g_txdetectrxloopback         (/*unused*/ ),
        .in_pld_8g_txelecidle                 (tx_forceelecidle     [ig +: num_bonded]  ),
        .in_pld_8g_txmargin                   (/*unused*/ ),
        .in_pld_8g_txswing                    (/*unused*/ ),
        .in_pld_8g_txurstpcs_n                (~tx_digitalreset      [ig +: num_bonded] ),
        .in_pld_8g_wrdisable_rx               ({num_bonded{1'b0}} ),
        .in_pld_8g_wrenable_rmf               ({num_bonded{1'b0}} ),
        .in_pld_8g_wrenable_tx                ({num_bonded{1'b0}} ),

        .in_pld_agg_refclk_dig                (/*unused*/ ),

        .in_pld_eidleinfersel                 (/*unused*/ ),

        .in_pld_gen3_current_coeff            (/*unused*/ ),
        .in_pld_gen3_current_rxpreset         (/*unused*/ ),
        .in_pld_gen3_rx_rstn                  (/*unused*/ ),
        .in_pld_gen3_tx_rstn                  (/*unused*/ ),

        .in_pld_ltr                           (rx_set_locktoref     [ig +: num_bonded]  ),
        .in_pld_partial_reconfig_in           ({num_bonded{1'b1}} ),
        .in_pld_pcs_pma_if_refclk_dig         (/*unused*/ ),
        .in_pld_rate                          (/*unused*/ ),
        .in_pld_reserved_in                   (/*unused*/ ),
//      .in_pld_rx_clk_slip_in                ({num_bonded{1'b0}} ),
	.in_pld_rx_clk_slip_in                (rx_clk_slip_in), // modified for QPI
        .in_pld_rxpma_rstb_in                 (~rx_analogreset    [ig +: num_bonded]  ),
        .in_pld_scan_mode_n                   ({num_bonded{1'b1}} ),   /// NOTE: active high
        .in_pld_scan_shift_n                  ({num_bonded{1'b1}} ),
        .in_pld_sync_sm_en                    ({num_bonded{INT_IN_PLD_SYNC_SM_EN}} ),
        .in_pld_tx_data                       (tx_datain_from_pld[64*ig +: num_bonded*64]),

        .in_pma_clkdiv33_lc_in                ({num_bonded{1'b0}} ),
        .in_pma_eye_monitor_in                (/*unused*/ ),  // new port
        .in_pma_hclk                          (/*unused*/ ),
        .in_pma_reserved_in                   (/*unused*/ ),
        .in_pma_rx_freq_tx_cmu_pll_lock_in    ({num_bonded{1'b0}} ),
        .in_pma_tx_lc_pll_lock_in             ({num_bonded{1'b0}} ),

        .out_agg_align_det_sync               (/*unused*/ ),
        .out_agg_align_status_sync            (/*unused*/ ),
        .out_agg_cg_comp_rd_d_out             (/*unused*/ ),
        .out_agg_cg_comp_wr_out               (/*unused*/ ),
        .out_agg_dec_ctl                      (/*unused*/ ),
        .out_agg_dec_data                     (/*unused*/ ),
        .out_agg_dec_data_valid               (/*unused*/ ),
        .out_agg_del_cond_met_out             (/*unused*/ ),
        .out_agg_fifo_ovr_out                 (/*unused*/ ),
        .out_agg_fifo_rd_out_comp             (/*unused*/ ),
        .out_agg_insert_incomplete_out        (/*unused*/ ),
        .out_agg_latency_comp_out             (/*unused*/ ),
        .out_agg_rd_align                     (/*unused*/ ),
        .out_agg_rd_enable_sync               (/*unused*/ ),
        .out_agg_refclk_dig                   (/*unused*/ ),
        .out_agg_running_disp                 (/*unused*/ ),
        .out_agg_rxpcs_rst                    (/*unused*/ ),
        .out_agg_scan_mode_n                  (/*unused*/ ),
        .out_agg_scan_shift_n                 (/*unused*/ ),
        .out_agg_sync_status                  (/*unused*/ ),
        .out_agg_tx_ctl_tc                    (/*unused*/ ),
        .out_agg_tx_data_tc                   (/*unused*/ ),
        .out_agg_txpcs_rst                    (/*unused*/ ),

        .out_emsip_com_clk_out                (/*unused*/ ),
        .out_emsip_com_out                    (/*unused*/ ),
        .out_emsip_com_special_out            (/*unused*/ ),
        .out_emsip_rx_clk_out                 (/*unused*/ ),
        .out_emsip_rx_out                     (/*unused*/ ),
        .out_emsip_rx_special_out             (/*unused*/ ),
        .out_emsip_tx_clk_out                 (/*unused*/ ),
        .out_emsip_tx_out                     (/*unused*/ ),
        .out_emsip_tx_special_out             (/*unused*/ ),

        .out_pld_10g_rx_align_val             (/*unused*/ ),
        .out_pld_10g_rx_blk_lock              (/*unused*/ ),
        .out_pld_10g_rx_clk_out               (/*unused*/ ),
        .out_pld_10g_rx_control               (/*unused*/ ),
        .out_pld_10g_rx_crc32_err             (/*unused*/ ),
        .out_pld_10g_rx_data_valid            (/*unused*/ ),
        .out_pld_10g_rx_diag_err              (/*unused*/ ),
        .out_pld_10g_rx_diag_status           (/*unused*/ ),
        .out_pld_10g_rx_empty                 (/*unused*/ ),
        .out_pld_10g_rx_fifo_del              (/*unused*/ ),
        .out_pld_10g_rx_fifo_insert           (/*unused*/ ),
        .out_pld_10g_rx_frame_lock            (/*unused*/ ),
        .out_pld_10g_rx_hi_ber                (/*unused*/ ),
        .out_pld_10g_rx_mfrm_err              (/*unused*/ ),
        .out_pld_10g_rx_oflw_err              (/*unused*/ ),
        .out_pld_10g_rx_pempty                (/*unused*/ ),
        .out_pld_10g_rx_pfull                 (/*unused*/ ),
        .out_pld_10g_rx_prbs_err              (/*unused*/ ),
        .out_pld_10g_rx_pyld_ins              (/*unused*/ ),
        .out_pld_10g_rx_rdneg_sts             (/*unused*/ ),
        .out_pld_10g_rx_rdpos_sts             (/*unused*/ ),
        .out_pld_10g_rx_rx_frame              (/*unused*/ ),
        .out_pld_10g_rx_scrm_err              (/*unused*/ ),
        .out_pld_10g_rx_sh_err                (/*unused*/ ),
        .out_pld_10g_rx_skip_err              (/*unused*/ ),
        .out_pld_10g_rx_skip_ins              (/*unused*/ ),
        .out_pld_10g_rx_sync_err              (/*unused*/ ),
        .out_pld_10g_tx_burst_en_exe          (/*unused*/ ),
        .out_pld_10g_tx_clk_out               (/*unused*/ ),
        .out_pld_10g_tx_empty                 (/*unused*/ ),
        .out_pld_10g_tx_fifo_del              (/*unused*/ ),
        .out_pld_10g_tx_fifo_insert           (/*unused*/ ),
        .out_pld_10g_tx_frame                 (/*unused*/ ),
        .out_pld_10g_tx_full                  (/*unused*/ ),
        .out_pld_10g_tx_pempty                (/*unused*/ ),
        .out_pld_10g_tx_pfull                 (/*unused*/ ),
        .out_pld_10g_tx_wordslip_exe          (/*unused*/ ),

        .out_pld_8g_a1a2_k1k2_flag            (/*unused*/ ),
        .out_pld_8g_align_status              (/*unused*/ ),
        .out_pld_8g_bistdone                  (/*unused*/ ),
        .out_pld_8g_bisterr                   (/*unused*/ ),
        .out_pld_8g_byteord_flag              (rx_byteordflag       [ig +: num_bonded]  ),
        .out_pld_8g_empty_rmf                 (rx_rmfifoempty       [ig +: num_bonded]  ),
        .out_pld_8g_empty_rx                  (int_pcfifoempty      [ig +: num_bonded]  ),
        .out_pld_8g_empty_tx                  (int_phfifounderflow  [ig +: num_bonded]  ),
        .out_pld_8g_full_rmf                  (rx_rmfifofull        [ig +: num_bonded]  ),
        .out_pld_8g_full_rx                   (int_pcfifofull       [ig +: num_bonded]  ),
        .out_pld_8g_full_tx                   (int_phfifooverflow   [ig +: num_bonded]  ),
        .out_pld_8g_phystatus                 (/*unused*/ ),
        .out_pld_8g_rlv_lt                    (rx_rlv               [ig +: num_bonded]  ),
        .out_pld_8g_rx_blk_start              (/*unused*/ ),
        .out_pld_8g_rx_clk_out                (rx_clkout            [ig +: num_bonded]  ),
        .out_pld_8g_rx_data_valid             (/*unused*/ ),
        .out_pld_8g_rx_sync_hdr               (/*unused*/ ),
        .out_pld_8g_rxelecidle                (/*unused*/ ),
        .out_pld_8g_rxstatus                  (/*unused*/ ),
        .out_pld_8g_rxvalid                   (/*unused*/ ),
        .out_pld_8g_signal_detect_out         (rx_signaldetect      [ig +: num_bonded]  ),
        .out_pld_8g_tx_clk_out                (tx_clkout_to_pld     [ig +: num_bonded]  ),
        .out_pld_8g_wa_boundary               (rx_bitslipboundaryselectout[5*ig +: 5*num_bonded]  ),

        .out_pld_clkdiv33_lc                  (/*unused*/ ),
        .out_pld_clkdiv33_txorrx              (/*unused*/ ),
        .out_pld_clklow                       (/*unused*/ ),
        .out_pld_fref                         (/*unused*/ ),
        .out_pld_gen3_mask_tx_pll             (/*unused*/ ),
        .out_pld_gen3_rx_eq_ctrl              (/*unused*/ ),
        .out_pld_gen3_rxdeemph                (/*unused*/ ),
        .out_pld_reserved_out                 (/*unused*/ ),
        .out_pld_rx_data                      (rx_dataout_to_pld  [4*rx_data_bundle_size*ig +: num_bonded*4*rx_data_bundle_size]),
        .out_pld_test_data                    (/*unused*/ ),
        .out_pld_test_si_to_agg_out           (/*unused*/ ),

        .out_pma_current_rxpreset             (/*unused*/ ),
        .out_pma_eye_monitor_out              (/*unused*/ ),
        .out_pma_lc_cmu_rstb                  (/*unused*/ ),
        .out_pma_nfrzdrv                      (/*unused*/ ),
        .out_pma_partial_reconfig             (/*unused*/ ),
        .out_pma_reserved_out                 (/*unused*/ ),
        .out_pma_rx_clk_out                   (/*unused*/ ),
        .out_pma_tx_clk_out                   (/*unused*/ ),
        .out_pma_tx_pma_syncp_fbkp            (/*unused*/ ),

        // sv_xcvr_avmm ports
        .reconfig_to_xcvr                     (rcfg_to_xcvr   [ig*w_bundle_to_xcvr+:num_bonded*w_bundle_to_xcvr]    ),
        .reconfig_from_xcvr                   (rcfg_from_xcvr [ig*w_bundle_from_xcvr+:num_bonded*w_bundle_from_xcvr]),


        .in_pld_tx_pma_data                   (/*unused*/ ),
        .out_pld_rx_pma_data                  (/*unused*/ ),
        .pcs_rst_n                            (/*unused*/ ),
        .rx_sd                                (/*unused*/ ),
        .tx_pcie_fb_clk                       (/*unused*/ ),
        .tx_pll_fb_sw                         (/*unused*/ )
      );
    end // if((ig % bonded_group_size) == 0)

    //*****************************************************************
    //*********************** TX assignments **************************
    assign tx_coreclk_in  [ig] = (tx_use_coreclk == "true") ? tx_coreclkin[ig] : (bonded_group_size == 1)? tx_clkout_to_pld[ig] : tx_clkout_to_pld[ig/bonded_group_size];
    assign tx_phase_comp_fifo_error[ig] = int_phfifooverflow[ig] | int_phfifounderflow[ig];
    //********************* End TX assignments ************************
    //*****************************************************************

    //*****************************************************************
    //*********************** RX assignments **************************
    assign rx_coreclk_in[ig]  = (rx_use_coreclk == "true") ? rx_coreclkin[ig]
                              : (use_rate_match_fifo == 1) ? ((bonded_group_size == 1)? tx_clkout_to_pld[ig] : tx_clkout_to_pld[ig/bonded_group_size]) : rx_clkout[ig];
    assign rx_phase_comp_fifo_error[ig] = int_pcfifoempty[ig] | int_pcfifofull[ig];
    //********************* End TX assignments ************************
    //*****************************************************************
  end // ig
end
endgenerate

// Merge critical reconfig signals
sv_reconfig_bundle_merger #(
    .reconfig_interfaces(reconfig_interfaces)
) sv_reconfig_bundle_merger_inst (
   // Reconfig buses to/from reconfig controller
  .rcfg_reconfig_to_xcvr  (reconfig_to_xcvr   ),
  .rcfg_reconfig_from_xcvr(reconfig_from_xcvr ),

  // Reconfig buses to/from native xcvr
  .xcvr_reconfig_to_xcvr  (rcfg_to_xcvr   ),
  .xcvr_reconfig_from_xcvr(rcfg_from_xcvr )
);

sv_xcvr_data_adapter #(
    .lanes             (lanes           ),  //Number of lanes chosen by user. legal value: 1+
	.channel_interface (channel_interface), //legal value: (0,1) 1-Enable channel reconfiguration
    .ser_base_factor   (ser_base_factor ),  // (8,10)
    .ser_words         (ser_words       ),  // (1,2,4)
    .skip_word         (SKIP_WORD       )   // (1,2)
) sv_xcvr_data_adapter_inst( 
  .tx_parallel_data     (tx_parallel_data     ),
  .tx_datak             (tx_datak             ),
  .tx_forcedisp         (tx_forcedisp         ),
  .tx_dispval           (tx_dispval           ),
  
  .tx_datain_from_pld   (tx_datain_from_pld   ),
  .rx_dataout_to_pld    (rx_dataout_to_pld    ),
  
  .rx_parallel_data     (rx_parallel_data     ),
  .rx_datak             (rx_datak             ),
  .rx_errdetect         (rx_errdetect         ),
  .rx_syncstatus        (rx_syncstatus        ),
  .rx_disperr           (rx_disperr           ),
  .rx_patterndetect     (rx_patterndetect     ),
  .rx_rmfifodatainserted(rx_rmfifodatainserted),
  .rx_rmfifodatadeleted (rx_rmfifodatadeleted ),
  .rx_runningdisp       (rx_runningdisp       ),
  .rx_a1a2sizeout       (rx_a1a2sizeout       )
);

`undef data_rate_int    
endmodule
