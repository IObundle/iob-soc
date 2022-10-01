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
// PMA-direct component for Stratix V-style transceiver architectures
//
// $Header$
//
`timescale 1 ps / 1 ps

import altera_xcvr_functions::*;

module  sv_xcvr_low_latency_phy_nr
  #(
    
    //common parameters
    parameter device_family="Stratix V", 
    parameter intended_device_variant ="ANY",
  
    //must have parameters
    parameter data_path_type = "",
    parameter lanes = 1,
    parameter operation_mode = "DUPLEX", //TX, RX, DUPLEX
    parameter phase_comp_fifo_mode = "NONE",//EMBEDDED, NONE 
    parameter serialization_factor = 16,//8,10,16,20,32,40
    parameter pma_width = 32,
    parameter data_rate = "3125 Mbps",
    parameter base_data_rate = "0 Mbps",
    parameter pll_refclk_cnt = 1,
    parameter pll_refclk_freq = "156.25 MHz",
    parameter pll_refclk_select = "0",
    parameter cdr_refclk_select = 0,
    parameter plls = 1,
    parameter pll_type = "AUTO",
    parameter pll_select = 0,
    parameter pll_reconfig = 0, // (0,1) 0-Disable PLL reconfig, 1-Enable PLL reconfig
    parameter pll_feedback_path = "no_compensation",
    parameter enable_fpll_clkdiv33 = 1,
    parameter channel_interface = 0, //legal value: (0,1) 1-Enable channel reconfiguration

  
    //additonal system parameters
    parameter sys_clk_in_mhz = 150,           // used to calculate reset controller delays as system clock cycle counts
    parameter embedded_reset = 1,  // (0,1) 1-Enable embedded reset controller
  
    parameter starting_channel_number = 0,    //0,4,8,12 ...
  
    //Stratix V specific parameter
    parameter bonded_group_size = 1,
    parameter bonded_mode = "xN", // (xN, fb_compensation)        
    parameter tx_use_coreclk = 0,
    parameter rx_use_coreclk = 0,
    // SyncE
    parameter en_synce_support = 0,   //expose CDR ref-clk in this mode
    parameter tx_bitslip_en = 0,
    parameter tx_bitslip_width = 5,
    parameter rx_bitslip_en = 0,
    parameter select_10g_pcs = 0,
    parameter use_double_data_mode = "false",
    parameter ppm_det_threshold = "100"
  
    )
   ( 

     // user data (avalon-MM slave interface) //for all the channel rst, powerdown, rx serilize loopback enable
    input   tri0             rst,
    input   tri0             clk,
    input   tri0 [7:0] 	     ch_mgmt_address,
    input   tri0             ch_mgmt_read,
    output  tri0 [31:0]      ch_mgmt_readdata,
    input   tri0             ch_mgmt_write,
    input   tri0 [31:0]      ch_mgmt_writedata,
    output  tri0             ch_mgmt_waitrequest,

     // avalon-ST interface with PMA controller

     // Following inputs tx_rst_digital and rx_rst_digital to support SOFT XAUI 
    input   tri0 	     gx_pdn,         //sync with clk
    input   tri0 	     tx_rst_digital, // user digital reset, to reset controller
    input   tri0 	     rx_rst_digital, // user digital reset, to reset controller
    input   tri0 	     pll_pdn,        //sync with clk
     // end remove

     // Reset inputs 
    input   wire [plls -1:0] pll_powerdown, 
    input   wire [lanes-1:0] tx_analogreset,
    input   wire [lanes-1:0] tx_digitalreset,
    input   wire [lanes-1:0] rx_analogreset,
    input   wire [lanes-1:0] rx_digitalreset,
     // Calibration busy signals
    output  wire [lanes-1:0] tx_cal_busy,
    output  wire [lanes-1:0] rx_cal_busy,
   
   
    output  tri0 	     tx_pma_ready,   // reset controller status for TX
    output  tri0 	     rx_pma_ready,   // reset controller status for RX

//    output  tri0 	     pll_locked,      //conduit
    output  wire [plls-1:0] pll_locked,      //conduit
     

     //channel related avalon-clock interface
    input  tri0 [pll_refclk_cnt-1:0] pll_ref_clk,
    input  tri0	[pll_refclk_cnt-1:0] cdr_ref_clk,
    input  tri0 [lanes-1:0] 	     tx_coreclk,
    input  tri0 [lanes-1:0] 	     rx_coreclk,

     //channel related avalon-ST interface, tx
     //    input   tri0  [lanes * serialization_factor -1:0]   tx_parallel_data,// sync with tx_clkout_clk
    input   tri0 [(channel_interface? (data_path_type == "10G"? 64 : 44) : serialization_factor) * lanes -1:0] tx_parallel_data,// sync with tx_clkout_clk
   
    output  tri0 [lanes-1:0] tx_serial_data, // conduit 
    output  tri0 [(lanes/bonded_group_size)-1:0] tx_clkout,
    input   tri0 [lanes*tx_bitslip_width-1:0] tx_bitslip,

     //channel related AVALON-st INTERFACE, rx
    input   tri0 [lanes-1:0] rx_serial_data,//conduit
     //    output  tri0  [lanes * serialization_factor -1:0]   rx_parallel_data,// sync with rx_clkout_clk
    output  tri0 [(channel_interface? 64 : serialization_factor) * lanes -1:0] rx_parallel_data,// sync with rx_clkout_clk  
    output  tri0 [lanes-1:0] rx_clkout,
    input   tri0 [lanes-1:0] rx_parallel_data_read,
    input   tri0 [lanes-1:0] rx_bitslip,

    output  tri0 [lanes-1:0] rx_is_lockedtodata,
    output  tri0 [lanes-1:0] rx_is_lockedtoref,

    input   tri0 [lanes-1:0] rx_cdr_reset_disable, //GT specific port
   
    input   wire [altera_xcvr_functions::get_custom_reconfig_to_width  ("Stratix V",operation_mode,lanes,plls,bonded_group_size,data_path_type,bonded_mode)-1:0] reconfig_to_xcvr,
    output  wire [altera_xcvr_functions::get_custom_reconfig_from_width("Stratix V",operation_mode,lanes,plls,bonded_group_size,data_path_type,bonded_mode)-1:0] reconfig_from_xcvr,

     // Following outputs tx_digital_rst and rx_digital_rst to support SOFT XAUI 
    output  wire [lanes-1:0] tx_digital_rst, // output digital reset for soft PCS, this reset can be controlled in AVMM in cahnnel controller
    output  wire [lanes-1:0] rx_digital_rst // output digital reset for soft PCS, this reset can be controlled in AVMM in cahnnel controller
     );


import altera_xcvr_functions::*;

  localparam  TX_ENABLE = (operation_mode != "Rx" && operation_mode != "RX");
  localparam  RX_ENABLE = (operation_mode != "Tx" && operation_mode != "TX");


`define data_rate_int str2hz(data_rate)	// data rate in Hz.  Must use time unit since its a 64-bit unsigned int

   localparam word_aligner_mode    = (rx_bitslip_en == 1)? "bitslip" : "none"; //legal value: bitslip, sync state machine, manual	
   
   localparam ser_base_factor      = (serialization_factor%10==0)? 10 : 8;
   localparam ser_words            = serialization_factor / ser_base_factor;
   
   //wire [lanes-1:0] rx_phase_comp_fifo_error;	// to PCS memory map
   //wire [lanes-1:0] tx_phase_comp_fifo_error;	// to PCS memory map
   wire [lanes-1:0] 	     rx_set_locktodata;
   wire [lanes-1:0] 	     rx_set_locktoref;

//   wire [lanes-1:0] 	     rx_analog_rst;   
   wire [lanes-1:0] 	     rx_seriallpbken;
   
   wire [lanes-1:0] 	     w_native_rx_is_lockedtodata;
   wire [lanes-1:0] 	     w_native_rx_is_lockedtoref;
   
   wire [lanes-1:0] 	     w_rx_is_lockedtodata;
   wire [lanes-1:0] 	     w_rx_is_lockedtoref;
   
//   wire 		     w_pll_locked;
//   wire 		     w_native_pll_locked;
   wire 		     reconfig_busy;
   
   wire [lanes-1:0] 	     rxqpipulldn; // QPI input port
   wire [lanes-1:0] 	     txqpipulldn; // QPI input port
   wire [lanes-1:0] 	     txqpipullup; // QPI input port    
   
   //////////////////////////////////
   //reset controller outputs
   //////////////////////////////////
   wire              reset_controller_pll_powerdown;
   wire  [lanes-1:0] reset_controller_tx_digitalreset;
   wire  [lanes-1:0] reset_controller_rx_analogreset;
   wire  [lanes-1:0] reset_controller_rx_digitalreset;
   wire  [lanes-1:0] reset_controller_tx_ready;
   wire  [lanes-1:0] reset_controller_rx_ready;

   
   // Final reset signals
   wire  [plls-1:0]  pll_powerdown_fnl;
   wire  [lanes-1:0] tx_analogreset_fnl;
   wire  [lanes-1:0] tx_digitalreset_fnl;
   wire  [lanes-1:0] rx_analogreset_fnl;
   wire  [lanes-1:0] rx_digitalreset_fnl;



   // Control & status register map (CSR) outputs
   wire  csr_reset_tx_digital;	// to reset controller
   wire  csr_reset_rx_digital;	// to reset controller
   wire  csr_reset_all;		// to reset controller
   wire  csr_pll_powerdown;
   wire [lanes - 1 : 0] csr_tx_digitalreset;		// to xcvr instance
   wire [lanes - 1 : 0] csr_rx_analogreset;		// to xcvr instance
   wire [lanes - 1 : 0] csr_rx_digitalreset;		// to xcvr instance
   wire [lanes - 1 : 0] csr_phy_loopback_serial;	// to xcvr instance
   wire [lanes - 1 : 0] csr_rx_set_locktoref;		// to xcvr instance
   wire [lanes - 1 : 0] csr_rx_set_locktodata;		// to xcvr instance

   assign  pll_powerdown_fnl   = (embedded_reset)  ? {plls {csr_pll_powerdown}} : pll_powerdown;
   assign  tx_analogreset_fnl  = (embedded_reset)  ? {lanes{csr_pll_powerdown}} : tx_analogreset;
   assign  tx_digitalreset_fnl = csr_tx_digitalreset | (embedded_reset ? {lanes{1'b0}} : tx_digitalreset);
   assign  rx_analogreset_fnl  = csr_rx_analogreset  | (embedded_reset ? {lanes{1'b0}} : rx_analogreset );
   assign  rx_digitalreset_fnl = csr_rx_digitalreset | (embedded_reset ? {lanes{1'b0}} : rx_digitalreset);

   assign rxqpipulldn = {lanes{1'b0}};  // QPI
   assign txqpipulldn = {lanes{1'b0}};  // QPI
   assign txqpipullup = {lanes{1'b0}};  // QPI     
   
   generate
      if( data_path_type == "ATT" )
	begin
           sv_xcvr_att_custom_native #(
				       .lanes                  (lanes),
				       .data_rate              (data_rate),
				       .plls                   (lanes),
				       .pll_refclk_freq        (pll_refclk_freq),
				       .data_path_type         (data_path_type),
                       .ppm_det_threshold      (ppm_det_threshold),
				       .operation_mode         (operation_mode) 
				       ) 
           sv_xcvr_att_custom_native_inst ( 
					    .tx_analogreset         (tx_analogreset_fnl),
					    .pll_powerdown          (pll_powerdown_fnl),
					    .tx_digitalreset        (tx_digitalreset_fnl),
					    .rx_analogreset         (rx_analogreset_fnl),
					    .rx_digitalreset        (rx_digitalreset_fnl),
					    .pll_ref_clk            (pll_ref_clk),
					    .tx_parallel_data       (tx_parallel_data),
					    .rx_parallel_data       (rx_parallel_data),
					    .rx_serial_data         (rx_serial_data),
					    .tx_serial_data         (tx_serial_data),
					    .tx_clkout              (tx_clkout),
					    .rx_clkout              (rx_clkout),
					    .rx_seriallpbken        (rx_seriallpbken),
					    .rx_set_locktodata      (rx_set_locktodata),
					    .rx_set_locktoref       (rx_set_locktoref),
                        .rx_cdr_reset_disable   (rx_cdr_reset_disable),
					    .rx_is_lockedtoref      (w_native_rx_is_lockedtoref),
					    .rx_signaldetect        (/*unused*/),
					    .rx_is_lockedtodata     (w_native_rx_is_lockedtodata),
					    .pll_locked             (pll_locked),
					    .reconfig_to_xcvr       (reconfig_to_xcvr),
					    .reconfig_from_xcvr     (reconfig_from_xcvr)
					    ); 
           //unused for ATT channels
           assign tx_cal_busy = {lanes{1'b0}};
           assign rx_cal_busy = {lanes{1'b0}};
	end
      else if((((serialization_factor == 40) || (serialization_factor == 32)) && select_10g_pcs == 1) || (serialization_factor == 50)  || (serialization_factor == 66) || (serialization_factor == 64))
	begin
	   
           sv_xcvr_10g_custom_native #(
				       .lanes                  (lanes),
				       .serialization_factor   (serialization_factor),
				       .pma_width              (pma_width),
				       .data_rate              (data_rate),
				       .base_data_rate         (base_data_rate),
				       .plls                   (plls),
				       .pll_refclk_cnt         (pll_refclk_cnt),
				       .pll_refclk_freq        (pll_refclk_freq),
				       .pll_refclk_select      (pll_refclk_select),
				       .cdr_refclk_select      (cdr_refclk_select),
				       .pll_type               (pll_type),
				       .pll_select             (pll_select),
				       .pll_reconfig           (pll_reconfig),
				       .pll_feedback_path      (pll_feedback_path),
               .enable_fpll_clkdiv33   (enable_fpll_clkdiv33),
				       .operation_mode         (operation_mode),
				       .starting_channel_number(starting_channel_number),
				       .bonded_group_size      (bonded_group_size),
				       .bonded_mode            (bonded_mode),
				       .channel_interface      (channel_interface),				    
				       .tx_bitslip_en          (tx_bitslip_en),
				       .rx_bitslip_en          (rx_bitslip_en),
                                       .en_synce_support       (en_synce_support),
				       .tx_use_coreclk         (tx_use_coreclk),
				       .rx_use_coreclk         (rx_use_coreclk)
				       ) 
           sv_xcvr_10g_custom_native_inst (

					   .tx_analogreset         (tx_analogreset_fnl),
					   .pll_powerdown          (pll_powerdown_fnl),
					   .tx_digitalreset        (tx_digitalreset_fnl),
					   .rx_analogreset         (rx_analogreset_fnl),
					   .rx_digitalreset        (rx_digitalreset_fnl),				 
					   .tx_cal_busy            (tx_cal_busy),
					   .rx_cal_busy            (rx_cal_busy),
					   .pll_ref_clk            (pll_ref_clk),
					   .cdr_ref_clk            (cdr_ref_clk),
					   .tx_coreclk             (tx_coreclk),
					   .rx_coreclk             (rx_coreclk),
					   .tx_parallel_data       (tx_parallel_data),
					   .rx_parallel_data       (rx_parallel_data),
					   .rx_parallel_data_read  (rx_parallel_data_read),
					   .rx_serial_data         (rx_serial_data),
					   .tx_serial_data         (tx_serial_data),
					   .rx_bitslip             (rx_bitslip),
					   .tx_bitslip             (tx_bitslip),
					   .rx_seriallpbken        (rx_seriallpbken),
					   .rx_set_locktodata      (rx_set_locktodata),
					   .rx_set_locktoref       (rx_set_locktoref),
					   .tx_clkout              (tx_clkout),
					   .rx_clkout              (rx_clkout),
					   .rx_is_lockedtoref      (w_native_rx_is_lockedtoref),
					   .rx_is_lockedtodata     (w_native_rx_is_lockedtodata),
					   .pll_locked             (pll_locked),
					   .rx_phase_comp_fifo_error(/*unused*/),
					   .tx_phase_comp_fifo_error(/*unused*/),
					   .reconfig_to_xcvr       (reconfig_to_xcvr),
					   .reconfig_from_xcvr     (reconfig_from_xcvr)
					   );
           
	end
      //else if((serialization_factor <= 40) && (`data_rate_int <= 8500000000))
      else
	begin
           sv_xcvr_custom_native #(
				   .device_family              (device_family),
				   .protocol_hint              ("basic"),
				   .operation_mode             (operation_mode),
				   .lanes                      (lanes),
				   .bonded_group_size          (bonded_group_size),
				   .bonded_mode                (bonded_mode),
				   .ser_base_factor            (ser_base_factor),
				   .ser_words                  (ser_words),
				   .data_rate                  (data_rate),
				   .base_data_rate             (base_data_rate),
				   .plls                       (plls),
				   .tx_bitslip_enable          ((tx_bitslip_en == 1)? "true" : "false"),
				   .tx_use_coreclk             ((tx_use_coreclk == 1)? "true" : "false"),
				   .rx_use_coreclk             ((rx_use_coreclk == 1)? "true" : "false"),
				   .en_synce_support           (en_synce_support), //expose CDR ref-clk in this mode
				   .use_8b10b                  ("false"),
				   .use_8b10b_manual_control   ("false"),
				   .word_aligner_mode          (word_aligner_mode),
				   .use_rate_match_fifo        (0),
				   .byte_order_mode            ("None"),
				   .pcs_pma_width              (pma_width),
				   .coreclk_0ppm_enable        ("false"),
				   .pll_refclk_cnt             (pll_refclk_cnt),
				   .pll_refclk_freq            (pll_refclk_freq),
				   .pll_refclk_select          (pll_refclk_select),
				   .cdr_refclk_select          (cdr_refclk_select),
				   .pll_type                   (pll_type),
				   .pll_select                 (pll_select),
				   .pll_reconfig               (pll_reconfig),
				   .pll_feedback_path          (pll_feedback_path),
				   .channel_interface          (channel_interface),				
				   .starting_channel_number    (starting_channel_number),
				   .low_latency_mode           ("true")
				   ) 
           sv_xcvr_custom_inst (
				.tx_analogreset         (tx_analogreset_fnl),
				.pll_powerdown          (pll_powerdown_fnl),
				.tx_digitalreset        (tx_digitalreset_fnl),
				.rx_analogreset         (rx_analogreset_fnl),
				.rx_digitalreset        (rx_digitalreset_fnl),					 
				.tx_cal_busy            (tx_cal_busy),
				.rx_cal_busy            (rx_cal_busy),
				.pll_ref_clk            (pll_ref_clk),
				.cdr_ref_clk            (cdr_ref_clk), // used only in SyncE mode
				.tx_coreclkin           (tx_coreclk),
				.rx_coreclkin           (rx_coreclk),
				.tx_parallel_data       (tx_parallel_data),
				.rx_parallel_data       (rx_parallel_data),
				.tx_datak               ({ser_words*lanes{1'b0}}),
				.rx_datak               (/*unused*/),
				.tx_forcedisp           ({ser_words*lanes{1'b0}}),
				.tx_dispval             ({ser_words*lanes{1'b0}}),
				.rx_enabyteord          ({lanes{1'b0}}),
				.rx_serial_data         (rx_serial_data),
				.tx_serial_data         (tx_serial_data),
				.tx_clkout              (tx_clkout),
				.rx_clkout              (rx_clkout),
				.rx_recovered_clk       (/*unused*/),
				.tx_forceelecidle       ({lanes{1'b0}}),
				.tx_invpolarity         ({lanes{1'b0}}),
				.tx_bitslipboundaryselect(tx_bitslip),
				.rx_invpolarity         ({lanes{1'b0}}),
				.rx_seriallpbken        (rx_seriallpbken),
				.rx_set_locktodata      (rx_set_locktodata),
				.rx_set_locktoref       (rx_set_locktoref),
				.rx_enapatternalign     ({lanes{1'b0}}),
				.rx_bitslip             (rx_bitslip),
				.rx_bitreversalenable   ({lanes{1'b0}}),
				.rx_bytereversalenable  ({lanes{1'b0}}),
				.rx_a1a2size            ({lanes{1'b0}}),
				.rx_rlv                 (/*unused*/),
				.rx_patterndetect       (/*unused*/),
				.rx_syncstatus          (/*unused*/),
				.rx_bitslipboundaryselectout(/*unused*/),
				.rx_errdetect           (/*unused*/),
				.rx_disperr             (/*unused*/),
				.rx_runningdisp         (/*unused*/),
				.rx_rmfifofull          (/*unused*/),
				.rx_rmfifoempty         (/*unused*/),
				.rx_rmfifodatainserted  (/*unused*/),
				.rx_rmfifodatadeleted   (/*unused*/),
				.rx_a1a2sizeout         (/*unused*/),
				.rx_is_lockedtoref      (w_native_rx_is_lockedtoref),
				.rx_signaldetect        (/*unused*/),
				.rx_is_lockedtodata     (w_native_rx_is_lockedtodata),
				.pll_locked             (pll_locked),
				.rx_phase_comp_fifo_error(/*unused*/),
				.tx_phase_comp_fifo_error(/*unused*/),
				.rx_byteordflag          (/*unused*/),
				.reconfig_to_xcvr        (reconfig_to_xcvr),
				.reconfig_from_xcvr      (reconfig_from_xcvr),
                                //QPI ports
				.rxqpipulldn             (rxqpipulldn),
				.txqpipulldn             (txqpipulldn),
				.txqpipullup             (txqpipullup),
				.rx_clk_slip_in          ({lanes{1'b0}})
				);  
	end
      //    else
      //    begin
      // synopsys translate_off
      //        $display("Feature specified is not supported!");
      // synopsys translate_on
      //    end
      
      
   endgenerate


   generate
      if((operation_mode != "TX") && (operation_mode != "Tx") && (operation_mode != "tx"))
	begin
           assign w_rx_is_lockedtodata = w_native_rx_is_lockedtodata;
           assign w_rx_is_lockedtoref = w_native_rx_is_lockedtoref;
	end
      else
	begin
           assign w_rx_is_lockedtodata = {lanes{1'b1}};
           assign w_rx_is_lockedtoref = {lanes{1'b1}};
	end
      
      assign rx_is_lockedtodata = w_rx_is_lockedtodata;
      assign rx_is_lockedtoref = w_rx_is_lockedtoref;

   endgenerate

      /*
      if((operation_mode != "RX") && (operation_mode != "Rx") && (operation_mode != "rx"))
	begin
           assign w_pll_locked = w_native_pll_locked;
	end
      else
	begin
           assign w_pll_locked = 1'b1;
	end
      
      assign pll_locked = w_pll_locked;
       */

   // Removing ch controller and instantiating PMA CSR, wait_gen and reset controller
   // reset controller outputs

   // Assign outputs from CSR to channel control bits
   
   assign rx_set_locktodata = csr_rx_set_locktodata;
   assign rx_set_locktoref = csr_rx_set_locktoref;
   assign rx_seriallpbken = csr_phy_loopback_serial;
   
//   assign rx_analog_rst = csr_rx_analogreset;
   // following for XAUI, SOFT XAUI needs this
   assign tx_digital_rst = csr_tx_digitalreset;
   assign rx_digital_rst = csr_rx_digitalreset;
   

   

   
   // Instantiate memory map logic for given number of lanes & PLL's
   // Includes all except PCS
   alt_xcvr_csr_common #(
			 .lanes  (lanes),
			 .plls   (plls ),
       .rpc    (1    )
			 ) csr (
				.clk                              (clk),
				.reset                            (rst),
				.address                          (ch_mgmt_address),
				.read                             (ch_mgmt_read),
				.write                            (ch_mgmt_write),
				.writedata                        (ch_mgmt_writedata),
				// Transceiver status inputs to CSR
				.pll_locked                       (pll_locked),
				.rx_is_lockedtoref                (rx_is_lockedtoref),
				.rx_is_lockedtodata               (rx_is_lockedtodata),
				.rx_signaldetect                  ({lanes{1'b0}}),
				// from reset controller
				.reset_controller_tx_ready        (tx_pma_ready),
				.reset_controller_rx_ready        (rx_pma_ready),
				.reset_controller_pll_powerdown   (reset_controller_pll_powerdown   ),
				.reset_controller_tx_digitalreset (reset_controller_tx_digitalreset ),
				.reset_controller_rx_analogreset  (reset_controller_rx_analogreset  ),
				.reset_controller_rx_digitalreset (reset_controller_rx_digitalreset ),
				.readdata                         (ch_mgmt_readdata                 ),
				// Read/write control registers
				.csr_reset_tx_digital             (csr_reset_tx_digital             ),
				.csr_reset_rx_digital             (csr_reset_rx_digital             ),
				.csr_reset_all                    (csr_reset_all                    ),
				.csr_pll_powerdown                (csr_pll_powerdown                ),
				.csr_tx_digitalreset              (csr_tx_digitalreset              ),
				.csr_rx_analogreset               (csr_rx_analogreset               ),
				.csr_rx_digitalreset              (csr_rx_digitalreset              ),
				.csr_phy_loopback_serial          (csr_phy_loopback_serial          ),
				.csr_rx_set_locktoref             (csr_rx_set_locktoref             ),
				.csr_rx_set_locktodata            (csr_rx_set_locktodata            )
				);

   // generate waitrequest for 'top' channel
   altera_wait_generate top_wait (
				  .rst            (rst   ),
				  .clk            (clk         ),
				  .launch_signal  (ch_mgmt_read        ),
				  .wait_req       (ch_mgmt_waitrequest )
				  );

   

  // Reset Controller
  generate if (embedded_reset) begin : gen_embedded_reset
    localparam  RX_PER_CHANNEL = (bonded_group_size == 1);
    wire  [lanes-1:0]   rx_manual_mode;

    // Put reset controller into manual mode when we are not in auto lock mode
    assign  rx_manual_mode = (csr_rx_set_locktoref | csr_rx_set_locktodata);
    // We have a single tx_ready, rx_ready output per IP instance
    assign  tx_pma_ready  = &reset_controller_tx_ready;
    assign  rx_pma_ready  = &reset_controller_rx_ready;

    altera_xcvr_reset_control
    #(
        .CHANNELS               (lanes          ),  // Number of CHANNELS
        .SYNCHRONIZE_RESET      (0              ),  // (0,1) Synchronize the reset input
        .SYNCHRONIZE_PLL_RESET  (0              ),  // (0,1) Use synchronized reset input for PLL powerdown
                                                    // !NOTE! Will prevent PLL merging across reset controllers
                                                    // !NOTE! Requires SYNCHRONIZE_RESET == 1
        // Reset timings
        .SYS_CLK_IN_MHZ         (sys_clk_in_mhz ),  // Clock frequency in MHz. Required for reset timers
        .REDUCED_SIM_TIME       (1              ),  // (0,1) 1=Reduced reset timings for simulation
        // PLL options
        .TX_PLL_ENABLE          (TX_ENABLE      ),  // (0,1) Enable TX PLL reset
        .PLLS                   (1              ),  // Number of TX PLLs
        .T_PLL_POWERDOWN        (1000           ),  // pll_powerdown period in ns
        // TX options
        .TX_ENABLE              (TX_ENABLE      ),  // (0,1) Enable TX resets
        .TX_PER_CHANNEL         (0              ),  // (0,1) 1=separate TX reset per channel
        .T_TX_DIGITALRESET      (20             ),  // tx_digitalreset period (after pll_powerdown)
        .T_PLL_LOCK_HYST        (0              ),  // Amount of hysteresis to add to pll_locked status signal
        // RX options
        .RX_ENABLE              (RX_ENABLE      ),  // (0,1) Enable RX resets
        .RX_PER_CHANNEL         (RX_PER_CHANNEL ),  // (0,1) 1=separate RX reset per channel
        .T_RX_ANALOGRESET       (40             ),  // rx_analogreset period
        .T_RX_DIGITALRESET      (4000           )   // rx_digitalreset period (after rx_is_lockedtodata)
    ) reset_controller (
      // User inputs and outputs
      .clock            (clk            ),  // System clock
      .reset            (rst            ),  // Asynchronous reset
      // Reset signals
      .pll_powerdown    (reset_controller_pll_powerdown   ),  // reset TX PLL
      .tx_analogreset   (/*unused*/                       ),  // reset TX PMA
      .tx_digitalreset  (reset_controller_tx_digitalreset ),  // reset TX PCS
      .rx_analogreset   (reset_controller_rx_analogreset  ),  // reset RX PMA
      .rx_digitalreset  (reset_controller_rx_digitalreset ),  // reset RX PCS
      // Status output
      .tx_ready         (reset_controller_tx_ready        ),  // TX is not in reset
      .rx_ready         (reset_controller_rx_ready        ),  // RX is not in reset
      // Digital reset override inputs (must by synchronous with clock)
      .tx_digitalreset_or({lanes{csr_reset_tx_digital}} ), // reset request for tx_digitalreset
      .rx_digitalreset_or({lanes{csr_reset_rx_digital}} ), // reset request for rx_digitalreset
      // TX control inputs
      .pll_locked         (pll_locked[pll_select] ),  // TX PLL is locked status
      .pll_select         (1'b0                   ),  // Select TX PLL locked signal 
      .tx_cal_busy        (tx_cal_busy            ),  // TX channel calibration status
      .tx_manual          ({lanes{1'b1}}          ),  // 1=Manual TX reset mode
      // RX control inputs
      .rx_is_lockedtodata (rx_is_lockedtodata     ),  // RX CDR PLL is locked to data status
      .rx_cal_busy        (rx_cal_busy            ),  // RX channel calibration status
      .rx_manual          (rx_manual_mode         ) // 1=Manual RX reset mode
    );
  end else begin:gen_no_embedded_reset
    assign  reset_controller_pll_powerdown    = 1'b0;
    assign  reset_controller_tx_digitalreset  = {lanes{1'b0}};
    assign  reset_controller_rx_analogreset   = {lanes{1'b0}};
    assign  reset_controller_rx_digitalreset  = {lanes{1'b0}};
    assign  tx_pma_ready = 1'b0;
    assign  rx_pma_ready = 1'b0;
  end
  endgenerate
   
endmodule


`undef data_rate_int
