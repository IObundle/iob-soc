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


`timescale 1 ps/1 ps

import altera_xcvr_functions::*;

module sv_xcvr_10g_custom_native #(
    parameter lanes = 1,
    parameter serialization_factor = 40,
    parameter pma_width = 32,
    parameter data_rate = "10000 Mbps",
    parameter base_data_rate = "0 Mbps",
    parameter plls = 1,
    parameter pll_refclk_cnt = 1,               // Number of reference clocks (per PLL)
    parameter pll_refclk_freq = "125 MHz",      // PLL rerefence clock frequency
    parameter pll_refclk_select = "0",          // Selects the initial reference clock for each PLL
    parameter cdr_refclk_select = 0,            // Selects the initial reference clock for all RX CDR PLLs
    parameter pll_type = "AUTO",                // PLL type for each PLL
    parameter pll_select = 0,                   // Selects the initial PLL
    parameter pll_reconfig = 0,                 // (0,1) 0-Disable PLL reconfig, 1-Enable PLL reconfig
    parameter pll_feedback_path = "no_compensation", 	//no_compensation, tx_clkout
    parameter enable_fpll_clkdiv33 = 1,         // Insert an fPLL to generate the clkdiv33 clock for 66:40 mode
    parameter operation_mode = "Duplex",		//legal value: TX, RX, Duplex
    parameter starting_channel_number = 0,		//legal value: 0+
    parameter bonded_group_size = 1,			//legal values: 1+
    parameter bonded_mode = "xN",                // (xN, fb_compensation)        
    parameter channel_interface = 0, 			//legal value: 0,1
    parameter tx_bitslip_en = 0,		//legal value: false, true
    parameter rx_bitslip_en = 0,		//legal value: false, true

// Adding clkslip feature 
    parameter rx_clkslip_en = 1,		//legal value:0, 1, default needs to 1 (Due to PE request to always enable the bitslip to true to increase the data rate limit in Rx transceiver)
// Adding parameters to put TX and RX Phase comp fifo in register mode
   parameter tx_fifo_mode = "phase_comp",    // register_mode|clk_comp|interlaken_generic|basic_generic|phase_comp|generic
   parameter rx_fifo_mode = "phase_comp",    // register_mode|clk_comp|interlaken_generic|basic_generic|phase_comp|generic
//

    // SyncE
    parameter en_synce_support = 0,   //expose CDR ref-clk in this mode

    //optional coreclks 
    parameter tx_use_coreclk = 0,
    parameter rx_use_coreclk = 0
    
) ( 

    //input from reset controller
    input	tri0	[lanes-1:0]	tx_analogreset, // for tx pma
    input	tri0	[plls - 1 : 0] pll_powerdown, 
    input	tri0	[lanes-1:0]	tx_digitalreset,
    input	tri0	[lanes-1:0]	rx_analogreset, // for rx pma
    input	tri0	[lanes-1:0]	rx_digitalreset, //for rx pcs

    // Calibration busy signals
    output  wire    [lanes-1:0]     tx_cal_busy,
    output  wire    [lanes-1:0]     rx_cal_busy,
    
    //clk signal
    input	tri0	[pll_refclk_cnt - 1 : 0] pll_ref_clk,
    input	tri0	[pll_refclk_cnt - 1 : 0] cdr_ref_clk,
    input	tri0	[lanes - 1 : 0]	tx_coreclk,
    input	tri0	[lanes - 1 : 0]	rx_coreclk,
    
    //data ports
    input 	tri0	[(channel_interface? 64 : serialization_factor) * lanes -1:0]	tx_parallel_data,
	  output	wire  [(channel_interface? 64 : serialization_factor) * lanes -1:0]	rx_parallel_data,
    input 	tri0	[lanes-1:0]	rx_parallel_data_read,
    
    input 	tri0	[lanes-1:0]	rx_serial_data,
    output	wire	[lanes-1:0]	tx_serial_data,
    
    input	tri0	[lanes-1:0]	rx_bitslip,
    input	tri0	[lanes*7-1:0]	tx_bitslip,
// Adding clkslip feature for low latency    
    input tri0 	[lanes-1:0]	    rx_clkslip,
//
    input	tri0	[lanes-1:0]	    rx_seriallpbken,
    input	tri0	[lanes-1:0]	    rx_set_locktodata,
    input	tri0	[lanes-1:0]	    rx_set_locktoref,
    
    //clock outputs
    output	wire	[(lanes/bonded_group_size)-1:0]	tx_clkout,
    output	wire	[lanes-1:0]	rx_clkout,
    
    //control ports
    output	wire	[lanes-1:0]	rx_is_lockedtoref,
    output	wire	[lanes-1:0]	rx_is_lockedtodata,
    output	wire	[plls-1:0] pll_locked,
    
    output	wire	[lanes-1:0]	rx_phase_comp_fifo_error,
    output	wire	[lanes-1:0]	tx_phase_comp_fifo_error,

    
    input   wire  [get_custom_reconfig_to_width  ("Stratix V",operation_mode,lanes,plls,bonded_group_size,"",bonded_mode)-1:0] reconfig_to_xcvr,
    output  wire  [get_custom_reconfig_from_width("Stratix V",operation_mode,lanes,plls,bonded_group_size,"",bonded_mode)-1:0] reconfig_from_xcvr 
);

import altera_xcvr_functions::*;


// Reconfig parameters
localparam w_bundle_to_xcvr     = W_S5_RECONFIG_BUNDLE_TO_XCVR;
localparam w_bundle_from_xcvr   = W_S5_RECONFIG_BUNDLE_FROM_XCVR;
localparam reconfig_interfaces  = altera_xcvr_functions::get_custom_reconfig_interfaces("Stratix V",operation_mode,lanes,plls,bonded_group_size,"",bonded_mode);

localparam PCS_DATA_MAX_WIDTH = 64;
localparam PCS_RX_CONTROL_MAX_WIDTH = 10;
localparam PCS_TX_CONTROL_MAX_WIDTH = 9;
localparam PCS_CONTROL_USED_WIDTH = (serialization_factor == 66)? 2 : 0;

localparam  INT_RX_ENABLE = (operation_mode == "Rx" || operation_mode == "RX"
                          || operation_mode == "Duplex" || operation_mode == "DUPLEX") ? 1 : 0;

localparam  INT_TX_ENABLE = (operation_mode == "Tx" || operation_mode == "TX"
                          || operation_mode == "Duplex" || operation_mode == "DUPLEX") ? 1 : 0;
                          
//localparam pma_pcs_width = ((serialization_factor == 32) || (serialization_factor == 64)) ? 32 :
//                           ((serialization_factor == 40) || (serialization_factor == 50) || (serialization_factor == 66)) ? 40 : 0; //0 for the invalid value

localparam pma_pcs_width = pma_width;

localparam prot_mode = (serialization_factor == 50)? "teng_sdi_mode" : "basic_mode";

localparam TX_IDWIDTH = (serialization_factor == 32)? "width_32" :
                        ((serialization_factor == 40)? "width_40" :
                        ((serialization_factor == 64)? "width_64" :
                        (serialization_factor == 66)? "width_66" : "<auto_single>"));
                        
//localparam TX_ODWIDTH = (serialization_factor == 64 || serialization_factor == 32)? "width_32" : "width_40";

localparam TX_ODWIDTH = (pma_width == 64)? "width_64" :
                        (pma_width == 40)? "width_40" :
                        (pma_width == 32)? "width_32" : "width_40";

//localparam RX_IDWIDTH = (serialization_factor == 64 || serialization_factor == 32)? "width_32" : "width_40";

localparam RX_IDWIDTH = (pma_width == 64)? "width_64" :
                        (pma_width == 40)? "width_40" :
                        (pma_width == 32)? "width_32" : "width_40";
                        
localparam RX_ODWIDTH = (serialization_factor == 32)? "width_32" :
                        ((serialization_factor == 40)? "width_40" :
                        ((serialization_factor == 64)? "width_64" :
                        (serialization_factor == 66)? "width_66" : "<auto_single>"));                        

`define data_rate_int (str2hz(data_rate)/1000000)       // data rate in Hz.  Must use time unit since its a 64-bit unsigned int
                        
// Default base data rate to data rate if not specified
localparam INT_BASE_DATA_RATE = (base_data_rate == "0 Mbps") ? data_rate : base_data_rate;
localparam INT_TX_CLK_DIV = str2hz(get_value_at_index(pll_select, INT_BASE_DATA_RATE)) / str2hz(data_rate);

// Adding clkslip feature for 10G low latency
localparam INT_CLKSLIP_SEL = (prot_mode == "cpri")? "slip_eight_g_pcs": "pld"; //legal value: pld|slip_eight_g_pcs
localparam INT_CLKSLIP_EN = rx_clkslip_en ? "true": "false"; 


// local parameter for pma_bonding_type 
localparam pma_bonding_type = (bonded_mode == "fb_compensation")? "fb_compensation" : "default" ;

// SYNCE
wire  [bonded_group_size*pll_refclk_cnt-1:0] cdr_clock ;

//wires for TX
//PLD-PCS wires
tri0 [PCS_DATA_MAX_WIDTH * lanes - 1: 0] tx_datain_from_pld;
tri0 [PCS_TX_CONTROL_MAX_WIDTH * lanes - 1: 0] tx_control_from_pld;
wire [lanes - 1 : 0] tx_clkdivtx; 
wire [(plls*lanes) -1 : 0] pll_out_clk; 

//conduit
wire [lanes - 1 : 0] tx_coreclk_in;
wire [lanes - 1 : 0] rx_coreclk_in;

wire [plls  - 1 : 0] pll_locked_wire [lanes-1:0];
wire [lanes - 1 : 0] pll_locked_xpos [plls-1:0];

//wire for RX
wire [PCS_DATA_MAX_WIDTH * lanes - 1: 0] rx_dataout_to_pld;
wire [PCS_RX_CONTROL_MAX_WIDTH * lanes - 1: 0] rx_control_to_pld;

// Declare local merged versions of reconfig buses 
wire  [get_custom_reconfig_to_width  ("Stratix V",operation_mode,lanes,plls,bonded_group_size,"",bonded_mode)-1:0] rcfg_to_xcvr;
wire  [get_custom_reconfig_from_width("Stratix V",operation_mode,lanes,plls,bonded_group_size,"",bonded_mode)-1:0] rcfg_from_xcvr;

//divide-by-33 clock connection
wire [lanes - 1 : 0] wire_pld_clkdiv33_txorrx;
wire [lanes - 1 : 0] wire_rx_clkout_pld;
wire [lanes - 1 : 0] wire_tx_clkout_pld;

genvar ig;  // Iterator for generated loops
genvar jg;


generate
    
    wire [plls  - 1 : 0] pll_locked_tx;
    wire pll_locked_clkdiv33;
    
    // One pll_locked output per logical PLL
    for (ig=0; ig<plls; ig=ig+1) begin:assign_tx_pll_locked
        assign  pll_locked_tx[ig] = &pll_locked_xpos[ig];
    end
    
    // AND all clkdiv33 PLL locked
//    assign pll_locked_clkdiv33 = &pll_locked_clkdiv33_wire;
    
    for (ig=0; ig<plls; ig=ig+1) begin:assign_pll_locked
        assign  pll_locked[ig] = pll_locked_tx[ig] & pll_locked_clkdiv33;
    end
    
    wire [0:0] pll_out_clkdiv33;
    
    // one bit of tx_clkout when bonded and 1 bit per instance when non-bonded 
    assign tx_clkout = (serialization_factor == 66 && enable_fpll_clkdiv33 == 1)? {(lanes/bonded_group_size){pll_out_clkdiv33}} : wire_tx_clkout_pld[(lanes/bonded_group_size) - 1 : 0];
    
    for(ig=0; ig<lanes; ig = ig + 1) begin: sv_xcvr_native_insts
    
    // bonding size for bonded channel instantiations
    localparam num_bonded = bonded_group_size;
    
    localparam  [MAX_CHARS*8-1:0] INT_FEEDBACK_CLK  = (bonded_mode       == "fb_compensation") ? "external" : 
                                                      (pll_feedback_path == "no_compensation") ? "internal" : 
                                                      "external";

    if((ig % bonded_group_size) == 0 || (bonded_mode == "fb_compensation")) 
    begin:gen_bonded_group_plls
        
            
        if(INT_TX_ENABLE == 1) 
        begin:gen_tx_plls
            wire  [plls-1:0]  tx_fbclk;
            assign tx_fbclk = (bonded_mode == "fb_compensation") ? tx_clkdivtx [ig] : tx_clkout [ig / bonded_group_size] ; 
        
            sv_xcvr_plls #(
                .plls                     (plls                     ),
                .pll_type                 (pll_type                 ),
                .pll_reconfig             (pll_reconfig             ),
                .refclks                  (pll_refclk_cnt           ),
                .reference_clock_frequency(pll_refclk_freq          ),
                .reference_clock_select   (pll_refclk_select        ),
                .output_clock_datarate    (INT_BASE_DATA_RATE       ),
                .feedback_clk             (INT_FEEDBACK_CLK         )
            ) tx_plls (
                .refclk     (pll_ref_clk               ),
                .rst        (pll_powerdown             ),
                .fbclk      ({plls{tx_fbclk}}          ),
                .outclk     (pll_out_clk[ig*plls+:plls]),
                .locked     (pll_locked_wire[ig]       ),
                .fboutclk   (/*unused*/                ),
                
                // avalon MM native reconfiguration interfaces
                .reconfig_to_xcvr   (rcfg_to_xcvr   [(lanes+(plls*ig))*w_bundle_to_xcvr+:plls*w_bundle_to_xcvr]     ),
                .reconfig_from_xcvr (rcfg_from_xcvr [(lanes+(plls*ig))*w_bundle_from_xcvr+:plls*w_bundle_from_xcvr] )
            );
        end 
        else begin // no tx 
          assign pll_out_clk[ig*plls+:plls]   = {plls{1'b0}}; 
          assign pll_locked_wire[ig]          = {plls{1'b0}};
        end

    end 
    else begin: gen_pll_fanout
      assign pll_out_clk[ig*plls+:plls] = pll_out_clk[0+:plls]; // fanout for pll_out_clk for xN bonding 
      assign pll_locked_wire[ig]        = pll_locked_wire[0]  ; 
    end

    if (ig == 0) begin: generic_pll_inst_div
    
      if (INT_TX_ENABLE == 1) begin: generic_pll_inst_div
        wire  [plls-1:0]  pll_fb_clk_clkdi33;
      
        if(serialization_factor == 66 && enable_fpll_clkdiv33 == 1) begin
          localparam  [MAX_CHARS*8-1:0] refclk_sel_sel  = get_value_at_index(pll_select,pll_refclk_select);
          localparam  [MAX_CHARS*8-1:0] refclk_sel_fnl  = str2int(refclk_sel_sel); 
          localparam  [MAX_CHARS*8-1:0] refclk_freq_fnl = get_value_at_index(refclk_sel_fnl,pll_refclk_freq);

        (* altera_attribute = "-name MERGE_TX_PLL_DRIVEN_BY_REGISTERS_WITH_SAME_CLEAR ON" *)
          generic_pll #(
            .reference_clock_frequency  (refclk_freq_fnl            ),
            .output_clock_frequency     (hz2str(str2hz(data_rate)/66))
          ) tx_clkdiv33_plls (
              .outclk                 (pll_out_clkdiv33   ),
              .fboutclk               (pll_fb_clk_clkdi33 ),
              .rst                    (pll_powerdown      ),
              .refclk                 (pll_ref_clk[refclk_sel_fnl]),
              .fbclk                  (pll_fb_clk_clkdi33 ),
              .locked                 (pll_locked_clkdiv33),
              
              .writerefclkdata        (/*unused*/  ),
              .writeoutclkdata        (/*unused*/  ),
              .writephaseshiftdata    (/*unused*/  ),
              .writedutycycledata     (/*unused*/  ),
              .readrefclkdata         (/*unused*/  ),
              .readoutclkdata         (/*unused*/  ),
              .readphaseshiftdata     (/*unused*/  ),
              .readdutycycledata      (/*unused*/  )
          );
        end
        else begin // if serialization factor is not 66 
          assign  pll_out_clkdiv33 = {1'b0};
          assign  pll_locked_clkdiv33 = 1'b1;
        end 
      end 
      else begin:gen_no_tx // TX disabled
        assign  pll_out_clkdiv33 = {1'b0};
        assign  pll_locked_clkdiv33 = 1'b1;
      end
    end 
        
    // Transpose PLL locked from [lanes][plls]->[plls][lanes]
    for(jg=0; jg<plls; jg=jg+1) begin:gen_pll_locked_xpos
      assign  pll_locked_xpos[jg][ig] = pll_locked_wire[ig][jg];
    end
    
    // use cdr_ref_clk for syncE mode and pll_ref_clk otherwise
    if (en_synce_support) begin : SYNCE
      assign cdr_clock = {num_bonded{cdr_ref_clk}};
    end else begin : NO_SYNCE
      assign cdr_clock = {num_bonded{pll_ref_clk}};
    end


    if ((ig % bonded_group_size) == 0) begin: gen_bonded_group_native
    // create native transceiver interface
      sv_xcvr_native 
      #(
       // Common parameters
       .tx_clk_div          (INT_TX_CLK_DIV),
       .plls (plls),
       .pll_sel(pll_select),
       
       // PMA Parameters
       .rx_enable           (INT_RX_ENABLE),
       .tx_enable           (INT_TX_ENABLE),
       .pma_bonding_type    (pma_bonding_type),
       .enable_10g_rx       (INT_RX_ENABLE ? "true" : "false"),
       .enable_10g_tx       (INT_TX_ENABLE ? "true" : "false"),
       .enable_8g_rx        ("false"),
       .enable_8g_tx        ("false"),
       .enable_dyn_reconfig ("false"),
       .enable_gen12_pipe   ("false"),
       .enable_gen3_pipe    ("false"),
       .enable_gen3_rx      ("false"),
       .enable_gen3_tx      ("false"),
       
       // Interface specific parameters
       .rx_pcs_pma_if_selectpcs         ("ten_g_pcs"),
       .rx_pld_pcs_if_selectpcs         ("ten_g_pcs"),
       .tx_pcs_pma_if_selectpcs         ("ten_g_pcs"),
       .rx_pcs_pma_if_prot_mode         ("other_protocols"),
       .com_pcs_pma_if_func_mode        ("teng_only"),
       .com_pcs_pma_if_prot_mode        ("other_protocols"),
       .com_pcs_pma_if_sup_mode         ("user_mode"),
       .com_pcs_pma_if_force_freqdet    ("force_freqdet_dis"),
       .com_pcs_pma_if_ppmsel           ("ppmsel_1000"),
       .pcs10g_tx_tx_polarity_inv       ("invert_disable"),
// Adding clkslip feature for 10G low latency
       .rx_pcs_pma_if_clkslip_sel      (INT_CLKSLIP_SEL),
       .deser_enable_bit_slip          (INT_CLKSLIP_EN),
//   

       
       .bonded_lanes                    (num_bonded),
       .pma_mode                        (pma_pcs_width),
       .pma_data_rate                   (data_rate),
       .auto_negotiation                ("false"),
       
       // TX PCS parameters

       .pcs10g_tx_gb_tx_idwidth             (TX_IDWIDTH),
       .pcs10g_tx_gb_tx_odwidth             (TX_ODWIDTH),
       .pcs10g_tx_prot_mode                 (prot_mode),
       .pcs10g_tx_txfifo_mode               (tx_fifo_mode),
       .pcs10g_tx_txfifo_pempty             (2),
       .pcs10g_tx_sup_mode                  ("user_mode"),
       //.pcs10g_tx_frmgen_mfrm_length      ("frmgen_mfrm_length_user_setting"),
       //.pcs10g_tx_frmgen_mfrm_length_user (METALEN),
       .pcs10g_tx_enc_64b66b_txsm_bypass    ("enc_64b66b_txsm_bypass_en"),
       .pcs10g_tx_tx_sm_bypass              ("tx_sm_bypass_en"),
       //.pcs10g_tx_scrm_seed               ("scram_seed_user_setting"),
       //.pcs10g_tx_scrm_seed_user          (58'h123456789abcde + (24'h826a73 * (CH_INDEX+lanenum))),
       .pcs10g_tx_test_mode                 ("test_off"),
       .pcs10g_tx_pseudo_random             ("all_0"),
       .pcs10g_tx_sq_wave                   ("sq_wave_4"),
       .pcs10g_tx_bit_reverse               ("bit_reverse_dis"),
       //.pcs10g_tx_data_bit_reverse          ("data_bit_reverse_dis"),
       //.pcs10g_tx_ctrl_bit_reverse          ("ctrl_bit_reverse_dis"), // Akrzesin: Temporarily letting the generic layer set this parameter.
       .pcs10g_tx_bitslip_en                ((tx_bitslip_en == 1)? "bitslip_en" : "bitslip_dis"),
       .pcs10g_tx_tx_testbus_sel            ("<auto_any>"),
       .pcs10g_tx_pmagate_en                ("pmagate_dis"),

       // RX PMA Parameters
       .cdr_reference_clock_frequency       (pll_refclk_freq),
       .cdr_refclk_cnt                      (pll_refclk_cnt),
       .cdr_refclk_sel                      (cdr_refclk_select),
       .cdr_reconfig                        (pll_reconfig),
       //.cdr_output_clock_frequency        (hz2str(str2hz(data_rate)/2)),

       // RX PCS Parameters
       .pcs10g_rx_gb_rx_idwidth             (RX_IDWIDTH),
       .pcs10g_rx_gb_rx_odwidth             (RX_ODWIDTH),
       .pcs10g_rx_prot_mode                 (prot_mode),

       .pcs10g_rx_gb_sel_mode               ("internal"),
       //.gearbox_lpbk_mode_en ("false"), ??Q?? Where is this parameter?
       .pcs10g_rx_blksync_bypass            ("blksync_bypass_en"),
       //.pcs10g_rx_frmsync_mfrm_length     ("frmsync_mfrm_length_user_setting"),			  
       //.pcs10g_rx_frmsync_mfrm_length_user(METALEN),
       .pcs10g_rx_dis_signal_ok             ("dis_signal_ok_dis"),
       .pcs10g_rx_bit_reverse               ("bit_reverse_dis"),
      // .pcs10g_rx_data_bit_reverse          ("data_bit_reverse_dis"),
      // .pcs10g_rx_ctrl_bit_reverse          ("ctrl_bit_reverse_dis"), // Akrzesin: Temporarily letting the generic layer set this parameter.
// enabling rx_bitslip_mode
       .pcs10g_rx_bitslip_mode              ((rx_bitslip_en == 1) ? "bitslip_en" : "bitslip_dis"),
       .pcs10g_rx_rx_testbus_sel            ("<auto_any>"),
       .pcs10g_rx_rx_polarity_inv           ("invert_disable"),
       .pcs10g_rx_rx_sm_hiber               ("rx_sm_hiber_en"), 
       .pcs10g_rx_rxfifo_mode               (rx_fifo_mode),
       .pcs10g_rx_rxfifo_pempty             (2),
       .pcs10g_rx_sup_mode                  ("user_mode"),
       .pcs10g_rx_align_del                 ("align_del_dis"), 
       .pcs10g_rx_control_del               ("control_del_none"),
`ifdef ALTERA_RESERVED_QIS_ES
       .pcs10g_tx_tx_sh_location            ("msb"),
       .pcs10g_rx_rx_sh_location            ("msb"),
`endif	
       .pcs10g_rx_test_mode                 ("test_off")
      // .pcs10g_tx_tx_sh_location            ("lsb"),
      // .pcs10g_rx_rx_sh_location            ("lsb")
       
      ) 
      sv_xcvr_native_inst 
      (
        // TX/RX ports
        .seriallpbken        (rx_seriallpbken[ig +: num_bonded]),   // 1 = enable serial loopback                    
        
        // RX Ports                                                                 
        .rx_crurstn          (~rx_analogreset[ig +: num_bonded]),  
        .rx_datain           (rx_serial_data[ig +: num_bonded]),      // RX serial data input                          
        .rx_cdr_ref_clk      (cdr_clock                       ),      // Reference clock for CDR                       
        .rx_ltd              (rx_set_locktodata[ig +: num_bonded]),   // Force lock-to-data stream
        .rx_clkdivrx         (/*unused*/),
        .rx_is_lockedtoref   (rx_is_lockedtoref[ig +: num_bonded]),  // Indicates lock to reference clock
        
        // TX Ports
        .tx_rxdetclk         (1'b0),    // Clock for detection of downstream receiver
        .tx_dataout          (tx_serial_data[ig +: num_bonded]),     // TX serial data output
        .tx_rstn             (~tx_analogreset[ig +: num_bonded]),        
        .tx_clkdivtx         (tx_clkdivtx    [ig +: num_bonded]), 
        .tx_ser_clk          (pll_out_clk    [ig*plls +: (num_bonded*plls)]),     // High-speed serial clock from PLL              
        .tx_cal_busy         (tx_cal_busy[ig +: num_bonded]  ),
        .rx_cal_busy         (rx_cal_busy[ig +: num_bonded]  ),
        
        // PCS Ports
        .in_agg_align_status                 (/*unused*/),
        .in_agg_align_status_sync_0          (/*unused*/),
        .in_agg_align_status_sync_0_top_or_bot(/*unused*/),
        .in_agg_align_status_top_or_bot      (/*unused*/),
        .in_agg_cg_comp_rd_d_all             (/*unused*/),
        .in_agg_cg_comp_rd_d_all_top_or_bot  (/*unused*/),
        .in_agg_cg_comp_wr_all               (/*unused*/),
        .in_agg_cg_comp_wr_all_top_or_bot    (/*unused*/),
        .in_agg_del_cond_met_0               (/*unused*/),
        .in_agg_del_cond_met_0_top_or_bot    (/*unused*/),
        .in_agg_en_dskw_qd                   (/*unused*/),
        .in_agg_en_dskw_qd_top_or_bot        (/*unused*/),
        .in_agg_en_dskw_rd_ptrs              (/*unused*/),
        .in_agg_en_dskw_rd_ptrs_top_or_bot   (/*unused*/),
        .in_agg_fifo_ovr_0                   (/*unused*/),
        .in_agg_fifo_ovr_0_top_or_bot        (/*unused*/),
        .in_agg_fifo_rd_in_comp_0            (/*unused*/),
        .in_agg_fifo_rd_in_comp_0_top_or_bot (/*unused*/),
        .in_agg_fifo_rst_rd_qd               (/*unused*/),
        .in_agg_fifo_rst_rd_qd_top_or_bot    (/*unused*/),
        .in_agg_insert_incomplete_0          (/*unused*/),
        .in_agg_insert_incomplete_0_top_or_bot(/*unused*/),
        .in_agg_latency_comp_0               (/*unused*/),
        .in_agg_latency_comp_0_top_or_bot    (/*unused*/),
        .in_agg_rcvd_clk_agg                 (/*unused*/),
        .in_agg_rcvd_clk_agg_top_or_bot      (/*unused*/),
        .in_agg_rx_control_rs                (/*unused*/),
        .in_agg_rx_control_rs_top_or_bot     (/*unused*/),
        .in_agg_rx_data_rs                   (/*unused*/),
        .in_agg_rx_data_rs_top_or_bot        (/*unused*/),
        .in_agg_test_so_to_pld_in            (/*unused*/),
        .in_agg_testbus                      (/*unused*/),
        .in_agg_tx_ctl_ts                    (/*unused*/),
        .in_agg_tx_ctl_ts_top_or_bot         (/*unused*/),
        .in_agg_tx_data_ts                   (/*unused*/),
        .in_agg_tx_data_ts_top_or_bot        (/*unused*/),
        .in_emsip_com_in                     (/*unused*/),
        .in_emsip_com_special_in             (/*unused*/),
        .in_emsip_rx_clk_in                  (/*unused*/),
        .in_emsip_rx_in                      (/*unused*/),
        .in_emsip_rx_special_in              (/*unused*/),
        .in_emsip_tx_clk_in                  (/*unused*/),
        .in_emsip_tx_in                      (/*unused*/),
        .in_emsip_tx_special_in              (/*unused*/),
        
        .in_pld_10g_refclk_dig       ({num_bonded{1'b0}}),
        .in_pld_10g_rx_align_clr     (/*unused*/),
        .in_pld_10g_rx_align_en      ({num_bonded{1'b1}}),
        .in_pld_10g_rx_bitslip       (rx_bitslip[ig +: num_bonded]),
        .in_pld_10g_rx_clr_ber_count ({num_bonded{1'b0}}),
        .in_pld_10g_rx_clr_errblk_cnt({num_bonded{1'b0}}),
        .in_pld_10g_rx_disp_clr      ({num_bonded{1'b0}}),
        .in_pld_10g_rx_pld_clk       (rx_coreclk_in[ig +: num_bonded]),
        .in_pld_10g_rx_prbs_err_clr  ({num_bonded{1'b0}}),
        .in_pld_10g_rx_rd_en         (rx_parallel_data_read[ig +: num_bonded]),
        .in_pld_10g_rx_rst_n         (~rx_digitalreset[ig +: num_bonded]),
	// Adding clkslip feature for low latency
       	 .in_pld_rx_clk_slip_in (rx_clkslip[ig +: num_bonded]),
       //     

        
        .in_pld_tx_data              (tx_datain_from_pld[PCS_DATA_MAX_WIDTH*ig +: num_bonded*PCS_DATA_MAX_WIDTH]),
        .in_pld_10g_tx_bitslip       (tx_bitslip[7*ig +: num_bonded*7]),
        .in_pld_10g_tx_burst_en      ({num_bonded{1'b1}}),
        .in_pld_10g_tx_control       (tx_control_from_pld[PCS_TX_CONTROL_MAX_WIDTH*ig +: num_bonded*PCS_TX_CONTROL_MAX_WIDTH]),
        .in_pld_10g_tx_data_valid    (/*unused*/),
        .in_pld_10g_tx_diag_status   ({num_bonded{2'b00}}),
        .in_pld_10g_tx_pld_clk       (tx_coreclk_in[ig +: num_bonded]),
        .in_pld_10g_tx_rst_n         (~tx_digitalreset[ig +: num_bonded]),
        .in_pld_10g_tx_wordslip      ({num_bonded{1'b0}}),

        .in_pld_8g_a1a2_size             (/*unused*/),
        .in_pld_8g_bitloc_rev_en         (/*unused*/),
        .in_pld_8g_bitslip               (/*unused*/),
        .in_pld_8g_byte_rev_en           (/*unused*/),
        .in_pld_8g_bytordpld             (/*unused*/),
        .in_pld_8g_cmpfifourst_n         (/*unused*/),
        .in_pld_8g_encdt                 (/*unused*/),
        .in_pld_8g_phfifourst_rx_n       (/*unused*/),
        .in_pld_8g_phfifourst_tx_n       (/*unused*/),
        .in_pld_8g_pld_rx_clk            (/*unused*/),
        .in_pld_8g_pld_tx_clk            (/*unused*/),
        .in_pld_8g_polinv_rx             (/*unused*/),
        .in_pld_8g_polinv_tx             (/*unused*/),
        .in_pld_8g_powerdown             (/*unused*/),
        .in_pld_8g_prbs_cid_en           (/*unused*/),
        .in_pld_8g_rddisable_tx          (/*unused*/),
        .in_pld_8g_rdenable_rmf          (/*unused*/),
        .in_pld_8g_rdenable_rx           (/*unused*/),
        .in_pld_8g_refclk_dig            (/*unused*/),
        .in_pld_8g_refclk_dig2           (/*unused*/),
        .in_pld_8g_rev_loopbk            (/*unused*/),
        .in_pld_8g_rxpolarity            (/*unused*/),
        .in_pld_8g_rxurstpcs_n           (/*unused*/),
        .in_pld_8g_tx_blk_start          (/*unused*/),
        .in_pld_8g_tx_boundary_sel       (/*unused*/),
        .in_pld_8g_tx_data_valid         (/*unused*/),
        .in_pld_8g_tx_sync_hdr           (/*unused*/),
        .in_pld_8g_txdeemph              (/*unused*/),
        .in_pld_8g_txdetectrxloopback    (/*unused*/),
        .in_pld_8g_txelecidle            (/*unused*/),
        .in_pld_8g_txmargin              (/*unused*/),
        .in_pld_8g_txswing               (/*unused*/),
        .in_pld_8g_txurstpcs_n           (/*unused*/),
        .in_pld_8g_wrdisable_rx          (/*unused*/),
        .in_pld_8g_wrenable_rmf          (/*unused*/),
        .in_pld_8g_wrenable_tx           (/*unused*/),
        .in_pld_agg_refclk_dig           (/*unused*/),
        .in_pld_eidleinfersel            (/*unused*/),
        .in_pld_gen3_current_coeff       (/*unused*/),
        .in_pld_gen3_current_rxpreset    (/*unused*/),
        .in_pld_gen3_rx_rstn             (/*unused*/),
        .in_pld_gen3_tx_rstn             (/*unused*/),
        .in_pld_ltr                      (rx_set_locktoref [ig +: num_bonded]  ),
        .in_pld_partial_reconfig_in      ({num_bonded{1'b1}}),
        .in_pld_pcs_pma_if_refclk_dig    (/*unused*/),
        .in_pld_rate                     (/*unused*/),
        .in_pld_reserved_in              (/*unused*/),
        .in_pld_rxpma_rstb_in            (~rx_analogreset[ig +: num_bonded]),
        .in_pld_scan_mode_n              ({num_bonded{1'b1}}),
        .in_pld_scan_shift_n             ({num_bonded{1'b1}}),
        .in_pld_sync_sm_en               (/*unused*/),
        .in_pma_clkdiv33_lc_in           ({num_bonded{1'b0}}),
        .in_pma_eye_monitor_in           (/*unused*/),
        .in_pma_hclk                     (/*unused*/),
        .in_pma_reserved_in              (/*unused*/),
        .in_pma_rx_freq_tx_cmu_pll_lock_in({num_bonded{1'b0}}),
        .in_pma_tx_lc_pll_lock_in        ({num_bonded{1'b0}}),
        
        .out_agg_align_det_sync      (/*unused*/),
        .out_agg_align_status_sync   (/*unused*/),
        .out_agg_cg_comp_rd_d_out    (/*unused*/),
        .out_agg_cg_comp_wr_out      (/*unused*/),
        .out_agg_dec_ctl             (/*unused*/),
        .out_agg_dec_data            (/*unused*/),
        .out_agg_dec_data_valid      (/*unused*/),
        .out_agg_del_cond_met_out    (/*unused*/),
        .out_agg_fifo_ovr_out        (/*unused*/),
        .out_agg_fifo_rd_out_comp    (/*unused*/),
        .out_agg_insert_incomplete_out(/*unused*/),
        .out_agg_latency_comp_out    (/*unused*/),
        .out_agg_rd_align            (/*unused*/),
        .out_agg_rd_enable_sync      (/*unused*/),
        .out_agg_refclk_dig          (/*unused*/),
        .out_agg_running_disp        (/*unused*/),
        .out_agg_rxpcs_rst           (/*unused*/),
        .out_agg_scan_mode_n         (/*unused*/),
        .out_agg_scan_shift_n        (/*unused*/),
        .out_agg_sync_status         (/*unused*/),
        .out_agg_tx_ctl_tc           (/*unused*/),
        .out_agg_tx_data_tc          (/*unused*/),
        .out_agg_txpcs_rst           (/*unused*/),
        .out_emsip_com_clk_out       (/*unused*/),
        .out_emsip_com_out           (/*unused*/),
        .out_emsip_com_special_out   (/*unused*/),
        .out_emsip_rx_clk_out        (/*unused*/),
        .out_emsip_rx_out            (/*unused*/),
        .out_emsip_rx_special_out    (/*unused*/),
        .out_emsip_tx_clk_out        (/*unused*/),
        .out_emsip_tx_out            (/*unused*/),
        .out_emsip_tx_special_out    (/*unused*/),
        
        .out_pld_rx_data             (rx_dataout_to_pld[PCS_DATA_MAX_WIDTH*ig +: num_bonded*PCS_DATA_MAX_WIDTH]),
        .out_pld_10g_rx_align_val    (/*unused*/),
        .out_pld_10g_rx_blk_lock     (/*unused*/),
        .out_pld_10g_rx_clk_out      (wire_rx_clkout_pld[ig +: num_bonded]),
        .out_pld_10g_rx_control      (rx_control_to_pld[PCS_RX_CONTROL_MAX_WIDTH*ig +: num_bonded*PCS_RX_CONTROL_MAX_WIDTH]),
        .out_pld_10g_rx_crc32_err    (/*unused*/),
        .out_pld_10g_rx_data_valid   (/*unused*/),
        .out_pld_10g_rx_diag_err     (/*unused*/),
        .out_pld_10g_rx_diag_status  (/*unused*/),
        .out_pld_10g_rx_empty        (/*unused*/),
        .out_pld_10g_rx_fifo_del     (/*unused*/),
        .out_pld_10g_rx_fifo_insert  (/*unused*/),
        .out_pld_10g_rx_frame_lock   (/*unused*/),
        .out_pld_10g_rx_hi_ber       (/*unused*/),
        .out_pld_10g_rx_mfrm_err     (/*unused*/),
        .out_pld_10g_rx_oflw_err     (/*unused*/),
        .out_pld_10g_rx_pempty       (/*unused*/),
        .out_pld_10g_rx_pfull        (/*unused*/),
        .out_pld_10g_rx_prbs_err     (/*unused*/),
        .out_pld_10g_rx_pyld_ins     (/*unused*/),
        .out_pld_10g_rx_rdneg_sts    (/*unused*/),
        .out_pld_10g_rx_rdpos_sts    (/*unused*/),
        .out_pld_10g_rx_rx_frame     (/*unused*/),
        .out_pld_10g_rx_scrm_err     (/*unused*/),
        .out_pld_10g_rx_sh_err       (/*unused*/),
        .out_pld_10g_rx_skip_err     (/*unused*/),
        .out_pld_10g_rx_skip_ins     (/*unused*/),
        .out_pld_10g_rx_sync_err     (/*unused*/),
        
        .out_pld_10g_tx_burst_en_exe (/*unused*/),
        .out_pld_10g_tx_clk_out      (wire_tx_clkout_pld[ig +: num_bonded]),
        .out_pld_10g_tx_empty        (/*unused*/),
        .out_pld_10g_tx_fifo_del     (/*unused*/),
        .out_pld_10g_tx_fifo_insert  (/*unused*/),
        .out_pld_10g_tx_frame        (/*unused*/),
        .out_pld_10g_tx_full         (/*unused*/),
        .out_pld_10g_tx_pempty       (/*unused*/),
        .out_pld_10g_tx_pfull        (/*unused*/),
        .out_pld_10g_tx_wordslip_exe (/*unused*/),
        
        .out_pld_8g_a1a2_k1k2_flag   (/*unused*/),
        .out_pld_8g_align_status     (/*unused*/),
        .out_pld_8g_bistdone         (/*unused*/),
        .out_pld_8g_bisterr          (/*unused*/),
        .out_pld_8g_byteord_flag     (/*unused*/),
        .out_pld_8g_empty_rmf        (/*unused*/),
        .out_pld_8g_empty_rx         (/*unused*/),
        .out_pld_8g_empty_tx         (/*unused*/),
        .out_pld_8g_full_rmf         (/*unused*/),
        .out_pld_8g_full_rx          (/*unused*/),
        .out_pld_8g_full_tx          (/*unused*/),
        .out_pld_8g_phystatus        (/*unused*/),
        .out_pld_8g_rlv_lt           (/*unused*/),
        .out_pld_8g_rx_blk_start     (/*unused*/),
        .out_pld_8g_rx_clk_out       (/*unused*/),
        .out_pld_8g_rx_data_valid    (/*unused*/),
        .out_pld_8g_rx_sync_hdr      (/*unused*/),
        .out_pld_8g_rxelecidle       (/*unused*/),
        .out_pld_8g_rxstatus         (/*unused*/),
        .out_pld_8g_rxvalid          (/*unused*/),
        .out_pld_8g_signal_detect_out(/*unused*/),
        .out_pld_8g_tx_clk_out       (/*unused*/),
        .out_pld_8g_wa_boundary      (/*unused*/),
        
        .out_pld_clkdiv33_lc         (/*unused*/),
        .out_pld_clkdiv33_txorrx     (wire_pld_clkdiv33_txorrx[ig +: num_bonded]),
        .out_pld_clklow              (/*unused*/),
        .out_pld_fref                (/*unused*/),
        .out_pld_gen3_mask_tx_pll    (/*unused*/),
        .out_pld_gen3_rx_eq_ctrl     (/*unused*/),
        .out_pld_gen3_rxdeemph       (/*unused*/),
        .out_pld_reserved_out        (/*unused*/),
        .out_pld_test_data           (/*unused*/),
        .out_pld_test_si_to_agg_out  (/*unused*/),
        .out_pma_current_rxpreset    (/*unused*/),
        .out_pma_eye_monitor_out     (/*unused*/),
        .out_pma_lc_cmu_rstb         (/*unused*/),
        .out_pma_nfrzdrv             (/*unused*/),
        .out_pma_partial_reconfig    (/*unused*/),
        .out_pma_reserved_out        (/*unused*/),
        .out_pma_rx_clk_out          (/*unused*/),
        //.out_pma_rxpma_rstb        (/*unused*/),
        .out_pma_tx_clk_out          (/*unused*/),
        .out_pma_tx_pma_syncp_fbkp   (/*unused*/),
        
        .rx_is_lockedtodata          (rx_is_lockedtodata[ig +: num_bonded]),
        
        // sv_xcvr_avmm ports
        .reconfig_to_xcvr           (rcfg_to_xcvr   [ig*w_bundle_to_xcvr+:num_bonded*w_bundle_to_xcvr]    ),
        .reconfig_from_xcvr         (rcfg_from_xcvr [ig*w_bundle_from_xcvr+:num_bonded*w_bundle_from_xcvr])
       );
       
    end // if((ig % bonded_group_size) == 0)

    assign tx_coreclk_in[ig] = (tx_use_coreclk == 1)? tx_coreclk[ig] :
                               ((tx_use_coreclk == 0) && (serialization_factor == 66)) ? pll_out_clkdiv33 : 
                               (bonded_group_size == 1)? wire_tx_clkout_pld[ig] : wire_tx_clkout_pld[ig/bonded_group_size];
    assign rx_coreclk_in[ig] = (rx_use_coreclk == 1)? rx_coreclk[ig] : 
                               ((bonded_group_size > 0) && (serialization_factor == 66))? wire_pld_clkdiv33_txorrx[ig] : 
                               ((bonded_group_size == 0) && (serialization_factor == 66))? wire_pld_clkdiv33_txorrx[ig/bonded_group_size]:
                               (bonded_group_size > 0)? wire_rx_clkout_pld[ig] : wire_rx_clkout_pld[ig/bonded_group_size];
    
    assign rx_clkout[ig] = (serialization_factor == 66)? wire_pld_clkdiv33_txorrx[ig] : wire_rx_clkout_pld[ig];
    
                               
                               
    //*********************** parallel input/output rewiring ************************

    //QII10.0: only support 32, 40, 64 and 66 bit PCS-PLD width    
    if(serialization_factor <= PCS_DATA_MAX_WIDTH)
    begin
	    
		if (channel_interface == 1) begin
		    assign tx_datain_from_pld[ig*64 +: 64] = tx_parallel_data[ig*64 +: 64] ;
		end
		else begin
            assign tx_datain_from_pld[ig*PCS_DATA_MAX_WIDTH +: serialization_factor]
            = tx_parallel_data[ig*serialization_factor +: serialization_factor];
                
			if(serialization_factor != PCS_DATA_MAX_WIDTH)
			begin
                assign tx_datain_from_pld[(ig*PCS_DATA_MAX_WIDTH + serialization_factor) +: (PCS_DATA_MAX_WIDTH - serialization_factor)] = 0;
            end
		end
				
        

		if (channel_interface == 1) begin
		    assign rx_parallel_data[ig*64 +: 64]  = rx_dataout_to_pld[ig*64 +: 64] ;
		end 
		else begin
            assign rx_parallel_data[ig*serialization_factor +: serialization_factor]
                = rx_dataout_to_pld[ig*PCS_DATA_MAX_WIDTH +: serialization_factor];
		end
       
    end
    else if(serialization_factor == 66) // serialization_factor exceeds max data width
    begin
`ifdef ALTERA_RESERVED_QIS_ES 
        //------------------------------------------------------------------
        //- SV ES and production silicon have different data/control connectivity and ordering
        //- with the upper 2-bits in 66-bit gearbox mode
        //- In ES, tx_parallel_data[63:0] -> tx_datain_from_pld[63:0] and tx_parallel_data[65:64] -> tx_control_from_pld[1:0] 
        //- In Prod, tx_parallel_data[65:2] -> tx_datain_from_pld[63:0] and tx_parallel_data[0:1] (bit reversed) -> tx_control_from_pld[1:0] 
        //- similar connectivity with the Rx path
        //------------------------------------------------------------------
        assign tx_datain_from_pld[ig*PCS_DATA_MAX_WIDTH +: PCS_DATA_MAX_WIDTH]
                = tx_parallel_data[ig*serialization_factor +: PCS_DATA_MAX_WIDTH]; //connect lower 64-bits to the data bus
        assign tx_control_from_pld[ig*PCS_TX_CONTROL_MAX_WIDTH +: PCS_CONTROL_USED_WIDTH]
                = tx_parallel_data[(ig*serialization_factor + PCS_DATA_MAX_WIDTH) +: PCS_CONTROL_USED_WIDTH]; //use the upper two data bits to drive the tx_control[1:0]
        assign tx_control_from_pld[(ig*PCS_TX_CONTROL_MAX_WIDTH + PCS_CONTROL_USED_WIDTH) +: (PCS_TX_CONTROL_MAX_WIDTH - PCS_CONTROL_USED_WIDTH)] = 0; //padding
        
        assign rx_parallel_data[ig*serialization_factor +: PCS_DATA_MAX_WIDTH]
                = rx_dataout_to_pld[ig*PCS_DATA_MAX_WIDTH +: PCS_DATA_MAX_WIDTH];
        assign rx_parallel_data[(ig*serialization_factor + PCS_DATA_MAX_WIDTH) +: PCS_CONTROL_USED_WIDTH]
                = rx_control_to_pld[ig*PCS_RX_CONTROL_MAX_WIDTH +: PCS_CONTROL_USED_WIDTH];
`else 
        //production changes
        assign tx_datain_from_pld[ig*PCS_DATA_MAX_WIDTH +: PCS_DATA_MAX_WIDTH]
                = tx_parallel_data[ig*serialization_factor + PCS_CONTROL_USED_WIDTH +: PCS_DATA_MAX_WIDTH]; //Use the upper 64-bits [66:2]
        assign tx_control_from_pld[ig*PCS_TX_CONTROL_MAX_WIDTH +: PCS_CONTROL_USED_WIDTH]
                = {tx_parallel_data[(ig*serialization_factor)], tx_parallel_data[(ig*serialization_factor+1)]}; //Use the lower two data bits and bit reverse to drive the tx_control
        assign tx_control_from_pld[(ig*PCS_TX_CONTROL_MAX_WIDTH + PCS_CONTROL_USED_WIDTH) +: (PCS_TX_CONTROL_MAX_WIDTH - PCS_CONTROL_USED_WIDTH)] = 0; //padding
        
        assign rx_parallel_data[ig*serialization_factor + PCS_CONTROL_USED_WIDTH +: PCS_DATA_MAX_WIDTH]
                = rx_dataout_to_pld[ig*PCS_DATA_MAX_WIDTH +: PCS_DATA_MAX_WIDTH];
        assign rx_parallel_data[(ig*serialization_factor) +: PCS_CONTROL_USED_WIDTH]
                = {rx_control_to_pld[(ig*PCS_RX_CONTROL_MAX_WIDTH)], rx_control_to_pld[(ig*PCS_RX_CONTROL_MAX_WIDTH)+1]};
`endif

    end

    end // ig
 
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


endmodule





