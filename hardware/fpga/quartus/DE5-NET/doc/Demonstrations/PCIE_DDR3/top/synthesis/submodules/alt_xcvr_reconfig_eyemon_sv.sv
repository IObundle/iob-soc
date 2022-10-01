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


// eyemon data control for Stratix 5
//
// This module handles remapping and rearranging eyemon hardware registers to a
// nicer format for the user. 
//
// It receives user indirect registers from ALT_XRECONF_UIF and
// it generates write and read cycles to the ALT_XRECONF_BASIC.

// Mapping data is stored in look up tables and controlled by a state machine.

// $Header$

`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_eyemon_sv #(
    parameter number_of_reconfig_interfaces = 1,
    parameter enable_ber_counter = 0
)
   (
    input wire         reconfig_clk,
    input wire         reset,

    // avalon MM slave
    input  wire [2:0]  eyemon_address,
    input  wire [31:0] eyemon_writedata,
    input  wire        eyemon_write,
    input  wire        eyemon_read,
    output reg  [31:0] eyemon_readdata,     
    output reg         eyemon_waitrequest,
    output wire        eyemon_irq,

    // base_reconfig
    input  wire        eyemon_irq_from_base,
    input  wire        eyemon_waitrequest_from_base,  
    output wire [2:0]  eyemon_address_base,   
    output wire [31:0] eyemon_writedata_base,  
    output wire        eyemon_write_base,      
    output wire        eyemon_read_base,    
    input  wire [31:0] eyemon_readdata_base,   
    output wire        arb_req,
    input  wire        arb_grant,

    //testbus
    input  wire [7:0]  eyemon_testbus
    );
   
   localparam device_family = "StratixV";
   import alt_xcvr_reconfig_h::*; //alt_xcvr_reconfig/alt_xcvr_reconfig/alt_xcvr_reconfig_h.sv


   wire [31:0] master_readdata;
   wire [2:0]  opcode;
   wire [31:0] rmw_writedata;
   wire [10:0] ch_offset_add;
   wire        waitrequest_from_fsm;
   wire [31:0] uif_writedata;
   wire [5:0]  uif_addr_offset;
   wire [2:0]  uif_mode;
   wire [9:0]  uif_logical_ch_addr;
   wire        uif_go;
   wire [31:0] uif_readdata;
   wire        uif_error;
   wire        ctrl_go;
   wire [2:0]  ctrl_opcode;
   wire        ctrl_lock;
   wire [10:0] ctrl_addr_offset;
   wire [31:0] ctrl_writedata;
   wire [31:0] ctrl_readdata;
   wire [31:0] ctrl_phread_data;
   wire        ctrl_illegal_phy_ch;
   wire        ctrl_waitrequest;
   wire        uif_busy;


// user interface
alt_xreconf_uif #(
   .RECONFIG_USER_ADDR_WIDTH    (3),
   .RECONFIG_USER_DATA_WIDTH    (32),
   .RECONFIG_USER_OFFSET_WIDTH  (6)
)
inst_xreconf_uif  (
   .reconfig_clk              (reconfig_clk),
   .reset                     (reset),

   // User ports
   .user_reconfig_address     (eyemon_address),
   .user_reconfig_writedata   (eyemon_writedata),
   .user_reconfig_write       (eyemon_write),
   .user_reconfig_read        (eyemon_read),
   .user_reconfig_readdata    (eyemon_readdata),
   .user_reconfig_waitrequest (eyemon_waitrequest),
   .user_reconfig_done        (eyemon_irq),

   // data control signals
   .uif_writedata             (uif_writedata), 
   .uif_addr_offset           (uif_addr_offset), 
   .uif_mode                  (uif_mode), 
   .uif_logical_ch_addr       (uif_logical_ch_addr), 
   .uif_go                    (uif_go),
   .uif_ctrl                  ( ), //unused 
   .uif_readdata              (uif_readdata),
   .uif_phreaddata            (ctrl_phread_data), 
   .uif_illegal_pch_error     (ctrl_illegal_phy_ch),
   .uif_illegal_offset_error  (uif_error),
   .uif_busy                  (uif_busy)
);

  // eye monitor control
  alt_xcvr_reconfig_eyemon_ctrl_sv  #(
      .UIF_ADDR_WIDTH  (6),
      .UIF_DATA_WIDTH  (32),
      .CTRL_ADDR_WIDTH (11),
      .CTRL_DATA_WIDTH (32),
      .BER_COUNTER_EN  (enable_ber_counter)
  )
  inst_xreconfig_ctrl (
      .clk           (reconfig_clk),
      .reset         (reset),
      
       // user interface
      .uif_go        (uif_go),              // start user cycle  
      .uif_mode      (uif_mode),            // 0=read; 1=write;
      .uif_busy      (uif_busy),            // transfer in process
      .uif_addr      (uif_addr_offset),     // address offset
      .uif_wdata     (uif_writedata),       // data in
      .uif_rdata     (uif_readdata),        // data out
      .uif_chan_err  (ctrl_illegal_phy_ch), // illegal channel
      .uif_addr_err  (uif_error),           // illegal address
       
      // basic block interface
      .ctrl_go       (ctrl_go),             // start basic block cycle
      .ctrl_opcode   (ctrl_opcode),         // 0=read; 1=write;
      .ctrl_lock     (ctrl_lock),           // multicycle lock 
      .ctrl_wait     (ctrl_waitrequest),    // transfer in process
      .ctrl_addr     (ctrl_addr_offset),    // address
      .ctrl_rdata    (ctrl_readdata),       // data in
      .ctrl_wdata    (ctrl_writedata),      // data out

      //testbus
      .eyemon_testbus(eyemon_testbus)
  );

// Basic Block interface 
alt_xreconf_cif  #(
    .CIF_RECONFIG_ADDR_WIDTH      (3),
    .CIF_RECONFIG_DATA_WIDTH      (32),
    .CIF_OFFSET_ADDR_WIDTH        (11),
    .CIF_MASTER_ADDR_WIDTH        (3),
    .CIF_RECONFIG_OFFSET_WIDTH    (6)
)
inst_xreconf_cif (
   .reconfig_clk                   (reconfig_clk),
   .reset                          (reset),

   // data control signals
   .ctrl_go                        (ctrl_go),  
   .ctrl_opcode                    (ctrl_opcode),
   .ctrl_lock                      (ctrl_lock), 
   .ctrl_addr_offset               (ctrl_addr_offset), 
   .ctrl_writedata                 (ctrl_writedata),
   .uif_logical_ch_addr            (uif_logical_ch_addr), 
   .ctrl_readdata                  (ctrl_readdata), 
   .ctrl_phreaddata                (ctrl_phread_data),  
   .ctrl_illegal_phy_ch            (ctrl_illegal_phy_ch), 
   .ctrl_waitrequest               (ctrl_waitrequest), 

   // basic block ports                    
   .reconfig_address_base          (eyemon_address_base),
   .reconfig_writedata_base        (eyemon_writedata_base),
   .reconfig_write_base            (eyemon_write_base),
   .reconfig_read_base             (eyemon_read_base),
   .reconfig_readdata_base         (eyemon_readdata_base),
   .reconfig_irq_from_base         (eyemon_irq_from_base),
   .reconfig_waitrequest_from_base (eyemon_waitrequest_from_base),
   .arb_grant                      (arb_grant),
   .arb_req                        (arb_req)
);
  
endmodule
          
