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


// DCD calibration
//
// DCD calibration top module.
// 
// dcd_control.v perform self calibration with VCO data and
// DCD calibration with test data.
//
// dcd_align_clk.v handles aligning clocks to counter A and counter B.  
// These counters are in the PHY.

// $Header$
//
`ifdef ALTERA_RESERVED_QIS 
  `define ALTERA_RESERVED_XCVR_FULL_MYCALIP
`endif 

`ifndef ALTERA_RESERVED_XCVR_FULL_MYCALIP

`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dcd_cal_sim_model (
    input  wire        clk,
    input  wire        reset,
    input  wire        hold,
    
    output wire        ctrl_go,
    output wire        ctrl_lock,
    input  wire        ctrl_wait,
    output wire [6:0]  ctrl_chan,
    input  wire        ctrl_chan_err,
    output wire [11:0] ctrl_addr,
    output wire [2:0]  ctrl_opcode,
    output wire [15:0] ctrl_wdata,
    input  wire [15:0] ctrl_rdata,
    
    output reg        user_busy
    );  

parameter  [6:0] NUM_OF_CHANNELS = 66;  //number_of_reconfig_interfaces <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

// done state machine

localparam [10:0] BUSY_CYCLES = 32;

integer i;
wire reset_hold_ored ;
reg busy_asserted_once ;
assign reset_hold_ored = reset | (hold & ~busy_asserted_once) ;

always 
begin
@ (posedge reset) ;
busy_asserted_once =0 ;
@ (posedge user_busy);
@ (negedge user_busy);
busy_asserted_once =1 ;
end

always
begin
@ (posedge reset) ;
#0 busy_asserted_once =0 ;
end

always 
begin
user_busy=0;
@ (posedge reset_hold_ored) ;
user_busy=1;
@ (negedge reset_hold_ored) ;
for (i=0;i<BUSY_CYCLES;i=i+1) begin
@ (posedge clk) ;
 if (hold | reset)
 i=-1;
end
user_busy=0;
end

assign ctrl_go     =0;
assign ctrl_lock   =0;
assign ctrl_chan   =0;
assign ctrl_addr   =0;
assign ctrl_opcode =0;
assign ctrl_wdata  =0;

endmodule

`endif
