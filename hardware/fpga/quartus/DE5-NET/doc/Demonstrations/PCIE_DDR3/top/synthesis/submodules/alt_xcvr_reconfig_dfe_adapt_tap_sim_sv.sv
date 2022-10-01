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


// dfe tap adaptation simulation model
//
// This module is a simulation model for tap adaptation.
// It generates uif_busy after a write to start the IP.

// $Header$
`timescale 1 ns / 1 ns

module alt_xcvr_reconfig_dfe_adapt_tap_sim_sv (
    input  wire        clk,
    input  wire        reset,
       
    // user interface
    input  wire        uif_go, 
    input  wire  [2:0] uif_mode, 
    output reg         uif_busy, 
    input  wire  [5:0] uif_addr, 
    input  wire [15:0] uif_wdata,
         
    // basic block control interface
    output wire        ctrl_go, 
    output wire  [2:0] ctrl_opcode,
    output wire        ctrl_lock,     // multicycle lock 
    input  wire        ctrl_done,     // end of transfer 
    output wire [11:0] ctrl_addr,
    input  wire        ctrl_chan_err, // channel not legal
    input  wire [15:0] ctrl_rdata,
    output wire [15:0] ctrl_wdata,
        
    input  wire  [7:0] ctrl_testbus 
);

localparam       COUNT_WIDTH = 8;
localparam [2:0] UIF_MODE_WR = 3'b001;

// register addresses
import alt_xcvr_reconfig_h::*; 

 // unused outputs
 assign ctrl_go     = 1'b0;
 assign ctrl_opcode = 3'b000;
 assign ctrl_lock   = 1'b0; 
 assign ctrl_addr   = 12'h000;
 assign ctrl_wdata  = 16'h0000;

wire                    user_start;
reg  [COUNT_WIDTH-1 :0] count;

assign user_start = uif_go & (uif_mode == UIF_MODE_WR) &
                             (uif_addr == XR_DFE_OFFSET_TAP_ADAPT);
                                                                        
// delay
always @(posedge clk)
begin
    if (reset)
        count <= 0;
    else if (user_start)
        count <= (2**COUNT_WIDTH) -1;
    else if (count != 0)
        count <= count - 1'b1;
end

// busy
assign uif_busy = (count != 0);

endmodule
 
