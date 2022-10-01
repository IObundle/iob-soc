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


// dfe data control for Stratix 5
//
// This module handles user PHY register read/write requests and 
// it performs offset cancellation and PI calibration. 

// $Header$
`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dfe_sv (
    input wire         reconfig_clk,
    input wire         reset,
    input wire         hold,

    // avalon MM slave
    input  wire  [2:0] dfe_address,
    input  wire [31:0] dfe_writedata,
    input  wire        dfe_write,
    input  wire        dfe_read,
    output reg  [31:0] dfe_readdata,     
    output reg         dfe_waitrequest,
    output wire        dfe_irq,

    // base_reconfig
    input  wire        dfe_irq_from_base,
    input  wire        dfe_waitrequest_from_base,  
    output wire  [2:0] dfe_address_base,   
    output wire [31:0] dfe_writedata_base,  
    output wire        dfe_write_base,      
    output wire        dfe_read_base,    
    input  wire [31:0] dfe_readdata_base,   
    output wire        arb_req,
    input  wire        arb_grant,
    input  wire  [7:0] dfe_testbus
    );
   
   // simmulation model
  `ifdef ALTERA_RESERVED_QIS 
      `define ALTERA_RESERVED_XCVR_FULL_MYCALIP
  `endif    

   parameter number_of_reconfig_interfaces = 1;
  
   localparam device_family = "StratixV";
   import alt_xcvr_reconfig_h::*; 

   wire [31:0] uif_writedata;
   wire [5:0]  uif_addr_offset;
   wire [2:0]  uif_mode;
   wire [9:0]  uif_logical_ch_addr;
   wire        uif_go;
   wire        uif_error;
   wire [31:0] uif_readdata;
   wire        uif_reg_busy;
   wire        ctrl_reg_go;
   wire [2:0]  ctrl_reg_opcode;
   wire        ctrl_reg_lock;
   wire [11:0] ctrl_reg_addr_offset;
   wire [15:0] ctrl_reg_writedata;
   wire        uif_cal_busy;
   wire        ctrl_cal_go;
   wire [2:0]  ctrl_cal_opcode;
   wire        ctrl_cal_lock;
   wire [11:0] ctrl_cal_addr_offset;
   wire        uif_adapt_tap_busy;
   wire        ctrl_adapt_tap_go;
   wire [2:0]  ctrl_adapt_tap_opcode;
   wire        ctrl_adapt_tap_lock;
   wire [11:0] ctrl_adapt_tap_addr_offset;
   wire [15:0] ctrl_adapt_tap_writedata;
   wire        ctrl_go;
   wire [2:0]  ctrl_opcode;
   wire        ctrl_lock;
   wire        ctrl_done;
   wire [11:0] ctrl_addr_offset;
   wire [9:0]  ctrl_cal_chan;
   wire [15:0] ctrl_cal_writedata;
   wire [31:0] ctrl_writedata;
   wire [31:0] ctrl_readdata;
   wire [31:0] ctrl_phread_data;
   wire        ctrl_illegal_phy_ch;
   wire        ctrl_waitrequest;
   wire        uif_busy;
   wire        reset_sync;	

// Preliminary status warning
initial /* synthesis enable_verilog_initial_construct */
begin
    $display("Warning: Decision Feedback Equalizer calibration algorithm is preliminary.");
end

// user interface
alt_xreconf_uif #(
    .RECONFIG_USER_ADDR_WIDTH    (3),
    .RECONFIG_USER_DATA_WIDTH    (32),
    .RECONFIG_USER_OFFSET_WIDTH  (6)
)
inst_alt_xreconf_uif (
    .reconfig_clk              (reconfig_clk),
    .reset                     (reset_sync),

    // user ports
    .user_reconfig_address     (dfe_address),
    .user_reconfig_writedata   (dfe_writedata),
    .user_reconfig_write       (dfe_write),
    .user_reconfig_read        (dfe_read),
    .user_reconfig_readdata    (dfe_readdata),
    .user_reconfig_waitrequest (dfe_waitrequest),
    .user_reconfig_done        (dfe_irq),

    // data control signals
    .uif_writedata             (uif_writedata), 
    .uif_addr_offset           (uif_addr_offset), 
    .uif_mode                  (uif_mode),
    .uif_ctrl                  (), 
    .uif_logical_ch_addr       (uif_logical_ch_addr), 
    .uif_go                    (uif_go), 
    .uif_readdata              (uif_readdata),
    .uif_phreaddata            (ctrl_phread_data), 
    .uif_illegal_pch_error     (ctrl_illegal_phy_ch),
    .uif_illegal_offset_error  (uif_error),
    .uif_busy                  (uif_busy)
);
 
// DFE registers
alt_xcvr_reconfig_dfe_reg_sv inst_alt_xcvr_reconfig_dfe_reg_sv (
    .clk           (reconfig_clk),
    .reset         (reset_sync),
    
    // user interface
    .uif_go        (uif_go),                 // start user cycle  
    .uif_mode      (uif_mode),               // transfer type
    .uif_busy      (uif_reg_busy),           // transfer in process
    .uif_addr      (uif_addr_offset),        // address offset
    .uif_wdata     (uif_writedata[15:0]),    // data in
    .uif_rdata     (uif_readdata[15:0]),     // data out
    .uif_addr_err  (uif_error),              // illegal address
    
    // basic block interface
    .ctrl_go       (ctrl_reg_go),             // start basic block cycle
    .ctrl_opcode   (ctrl_reg_opcode),         // 0=read; 1=write;
    .ctrl_lock     (ctrl_reg_lock),           // multicycle lock 
    .ctrl_done     (ctrl_done),               // transfer-over pulse
    .ctrl_addr     (ctrl_reg_addr_offset),    // address
    .ctrl_chan_err (ctrl_illegal_phy_ch),     // illegal channel
    .ctrl_rdata    (ctrl_readdata[15:0]),     // data in
    .ctrl_wdata    (ctrl_reg_writedata[15:0]) // data out
);

// DFE calibration
`ifdef ALTERA_RESERVED_XCVR_FULL_MYCALIP

alt_xcvr_reconfig_dfe_cal_sv #(
    .NUM_OF_CHANNELS     (number_of_reconfig_interfaces)
)
 inst_alt_xcvr_reconfig_dfe_cal_sv (
    .clk           (reconfig_clk),
    .reset         (reset_sync),
    .hold          (hold),                     // auto mode hold off
	
    // user interface
    .uif_go        (uif_go),                   // start user cycle  
    .uif_mode      (uif_mode),                 // transfer type
    .uif_busy      (uif_cal_busy),             // transfer in process
    .uif_addr      (uif_addr_offset),          // address offset
    .uif_chan      (uif_logical_ch_addr),      // user channel
    .uif_wdata     (uif_writedata[15:0]),      // data in
 
    // basic block control interface
    .ctrl_go       (ctrl_cal_go),              // start basic block cycle
    .ctrl_opcode   (ctrl_cal_opcode),          // cycle type
    .ctrl_lock     (ctrl_cal_lock),            // multicycle lock 
    .ctrl_done     (ctrl_done),                // transfer-over pulse
    .ctrl_addr     (ctrl_cal_addr_offset),     // address
    .ctrl_chan     (ctrl_cal_chan),            // logical channel
    .ctrl_chan_err (ctrl_illegal_phy_ch),      // illegal channel
    .ctrl_rdata    (ctrl_readdata[15:0]),      // data in
    .ctrl_wdata    (ctrl_cal_writedata[15:0]), // data out
  	
    .ctrl_testbus  (dfe_testbus)               // testbus
);

`else

// calibration simulation model
alt_xcvr_reconfig_dfe_cal_sim_sv 
 inst_alt_xcvr_reconfig_dfe_cal_sim_sv (
    .clk           (reconfig_clk),
    .reset         (reset_sync),
    .hold          (hold),                     // auto mode hold off
	
    // user interface
    .uif_go        (uif_go),                   // start user cycle  
    .uif_mode      (uif_mode),                 // transfer type
    .uif_busy      (uif_cal_busy),             // transfer in process
    .uif_addr      (uif_addr_offset),          // address offset
    .uif_chan      (uif_logical_ch_addr),      // user channel
    .uif_wdata     (uif_writedata[15:0]),      // data in
 
    // basic block control interface
    .ctrl_go       (ctrl_cal_go),              // start basic block cycle
    .ctrl_opcode   (ctrl_cal_opcode),          // cycle type
    .ctrl_lock     (ctrl_cal_lock),            // multicycle lock 
    .ctrl_done     (ctrl_done),                // transfer-over pulse
    .ctrl_addr     (ctrl_cal_addr_offset),     // address
    .ctrl_chan     (ctrl_cal_chan),            // logical channel
    .ctrl_chan_err (ctrl_illegal_phy_ch),      // illegal channel
    .ctrl_rdata    (ctrl_readdata[15:0]),      // data in
    .ctrl_wdata    (ctrl_cal_writedata[15:0]), // data out
  	
    .ctrl_testbus  (dfe_testbus)               // testbus
);

`endif

//DFE tap adaptation

`ifdef ALTERA_RESERVED_XCVR_FULL_MYCALIP

alt_xcvr_reconfig_dfe_adapt_tap_sv
inst_alt_xcvr_reconfig_dfe_adapt_tap_sv (
    .clk           (reconfig_clk),
    .reset         (reset_sync),

    // user interface
    .uif_go        (uif_go),                   // start user cycle  
    .uif_mode      (uif_mode),                 // transfer type
    .uif_busy      (uif_adapt_tap_busy),       // transfer in process
    .uif_addr      (uif_addr_offset),          // address offset
    .uif_wdata     (uif_writedata[15:0]),      // data in
 
    // basic block control interface
    .ctrl_go       (ctrl_adapt_tap_go),        // start basic block cycle
    .ctrl_opcode   (ctrl_adapt_tap_opcode),    // cycle type
    .ctrl_lock     (ctrl_adapt_tap_lock),      // multicycle lock 
    .ctrl_done     (ctrl_done),                // transfer-over pulse
    .ctrl_addr     (ctrl_adapt_tap_addr_offset), // address
    .ctrl_chan_err (ctrl_illegal_phy_ch),      // illegal channel
    .ctrl_rdata    (ctrl_readdata[15:0]),      // data in
    .ctrl_wdata    (ctrl_adapt_tap_writedata[15:0]), // data out
  	
    .ctrl_testbus  (dfe_testbus)                 // testbus
);

`else

// tap adaptation simulatiom model
alt_xcvr_reconfig_dfe_adapt_tap_sim_sv 
inst_alt_xcvr_reconfig_dfe_adapt_tap_sim_sv (
    .clk           (reconfig_clk),
    .reset         (reset_sync),

    // user interface
    .uif_go        (uif_go),                   // start user cycle  
    .uif_mode      (uif_mode),                 // transfer type
    .uif_busy      (uif_adapt_tap_busy),       // transfer in process
    .uif_addr      (uif_addr_offset),          // address offset
    .uif_wdata     (uif_writedata[15:0]),      // data in
 
    // basic block control interface
    .ctrl_go       (ctrl_adapt_tap_go),        // start basic block cycle
    .ctrl_opcode   (ctrl_adapt_tap_opcode),    // cycle type
    .ctrl_lock     (ctrl_adapt_tap_lock),      // multicycle lock 
    .ctrl_done     (ctrl_done),                // transfer-over pulse
    .ctrl_addr     (ctrl_adapt_tap_addr_offset), // address
    .ctrl_chan_err (ctrl_illegal_phy_ch),      // illegal channel
    .ctrl_rdata    (ctrl_readdata[15:0]),      // data in
    .ctrl_wdata    (ctrl_adapt_tap_writedata[15:0]), // data out
  	
    .ctrl_testbus  (dfe_testbus)                 // testbus
);

`endif

// DFE register/calibration CTRL multiplexer
alt_xcvr_reconfig_dfe_ctrl_mux_sv
 inst_alt_xcvr_reconfig_dfe_ctrl_mux_sv
   (
    .clk                   (reconfig_clk),
    .reset                 (reset_sync),
    
    // register block
    .ctrl_reg_go           (ctrl_reg_go),     
    .ctrl_reg_opcode       (ctrl_reg_opcode),
    .ctrl_reg_lock         (ctrl_reg_lock), 
    .ctrl_reg_addr         (ctrl_reg_addr_offset), 
    .ctrl_reg_wdata        (ctrl_reg_writedata),

     // calibration block
    .ctrl_cal_go           (ctrl_cal_go),     
    .ctrl_cal_opcode       (ctrl_cal_opcode),
    .ctrl_cal_lock         (ctrl_cal_lock), 
    .ctrl_cal_addr         (ctrl_cal_addr_offset), 
    .ctrl_cal_wdata        (ctrl_cal_writedata),
	 	 
	 // tap adaptation block
    .ctrl_adapt_tap_go     (ctrl_adapt_tap_go),     
    .ctrl_adapt_tap_opcode (ctrl_adapt_tap_opcode),
    .ctrl_adapt_tap_lock   (ctrl_adapt_tap_lock), 
    .ctrl_adapt_tap_addr   (ctrl_adapt_tap_addr_offset), 
    .ctrl_adapt_tap_wdata  (ctrl_adapt_tap_writedata),
	 
	 // multiplexer control 
    .uif_reg_busy          (uif_reg_busy),
	  .uif_cal_busy          (uif_cal_busy),
	  .uif_adapt_tap_busy    (uif_adapt_tap_busy),
	 
	 // ctrl block interface
    .ctrl_go               (ctrl_go),     
    .ctrl_opcode           (ctrl_opcode),
    .ctrl_lock             (ctrl_lock), 
    .ctrl_wait             (ctrl_waitrequest),
    .ctrl_done             (ctrl_done),   
    .ctrl_addr             (ctrl_addr_offset), 
    .ctrl_wdata            (ctrl_writedata[15:0]),
	 
	  .uif_busy              (uif_busy)
 );

// unused signals
assign uif_readdata[31:16]   = 16'h0000;
assign ctrl_writedata[31:16] = 16'h0000;

// Basic Block interface 
alt_xreconf_cif  #(
    .CIF_RECONFIG_ADDR_WIDTH      (3),
    .CIF_RECONFIG_DATA_WIDTH      (32),
    .CIF_OFFSET_ADDR_WIDTH        (12),
    .CIF_MASTER_ADDR_WIDTH        (3),
    .CIF_RECONFIG_OFFSET_WIDTH    (6)
)
inst_xreconf_cif (
   .reconfig_clk                   (reconfig_clk),
   .reset                          (reset_sync),

   // data control signals
   .ctrl_go                        (ctrl_go),  
   .ctrl_opcode                    (ctrl_opcode),
   .ctrl_lock                      (ctrl_lock), 
   .ctrl_addr_offset               (ctrl_addr_offset), 
   .ctrl_writedata                 (ctrl_writedata),
   .uif_logical_ch_addr            (ctrl_cal_chan), 
   .ctrl_readdata                  (ctrl_readdata), 
   .ctrl_phreaddata                (ctrl_phread_data),  
   .ctrl_illegal_phy_ch            (ctrl_illegal_phy_ch), 
   .ctrl_waitrequest               (ctrl_waitrequest), 

   // basic block ports                    
   .reconfig_address_base          (dfe_address_base),
   .reconfig_writedata_base        (dfe_writedata_base),
   .reconfig_write_base            (dfe_write_base),
   .reconfig_read_base             (dfe_read_base),
   .reconfig_readdata_base         (dfe_readdata_base),
   .reconfig_irq_from_base         (dfe_irq_from_base),
   .reconfig_waitrequest_from_base (dfe_waitrequest_from_base),
   .arb_grant                      (arb_grant),
   .arb_req                        (arb_req)
);
 
// local reset 
alt_xcvr_reconfig_dfe_local_reset_sv 
inst_alt_xcvr_reconfig_dfe_local_reset_sv
 (
    .clk        (reconfig_clk),
    .reset      (reset),
    .reset_sync (reset_sync)
);
 
endmodule
          
