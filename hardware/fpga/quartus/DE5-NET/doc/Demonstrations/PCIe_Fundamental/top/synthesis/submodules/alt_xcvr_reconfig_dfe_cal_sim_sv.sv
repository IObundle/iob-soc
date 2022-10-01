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


// dfe calibration
//
// This module is a simulation model for calibration.
// It generates a a uif_busy after hold negates or
// for a write to start calibration.

// $Header$
`timescale 1 ns / 1 ns

module alt_xcvr_reconfig_dfe_cal_sim_sv (
    input  wire        clk,
    input  wire        reset,
    input  wire        hold,          // stops after current channel while asserted
   
    // user interface
    input  wire        uif_go, 
    input  wire  [2:0] uif_mode, 
    output reg         uif_busy, 
    input  wire  [5:0] uif_addr, 
    input  wire  [9:0] uif_chan,
    input  wire [15:0] uif_wdata,
         
    // basic block control interface
    output wire        ctrl_go, 
    output wire  [2:0] ctrl_opcode,
    output wire        ctrl_lock,     // multicycle lock 
    input  wire        ctrl_done,     // end of transfer 
    output wire [11:0] ctrl_addr,
    output wire  [9:0] ctrl_chan,
    input  wire        ctrl_chan_err, // channel not legal
    input  wire [15:0] ctrl_rdata,
    output wire [15:0] ctrl_wdata,
        
    input  wire  [7:0] ctrl_testbus 
);

localparam       BUSY_DELAY  = 256;
localparam [2:0] UIF_MODE_WR = 3'b001;

// register addresses
import alt_xcvr_reconfig_h::*; 

 // unused outputs
 assign ctrl_go     = 1'b0;
 assign ctrl_opcode = 3'b000;
 assign ctrl_lock   = 1'b0; 
 assign ctrl_addr   = 12'h000;
 assign ctrl_chan   = 10'h000;
 assign ctrl_wdata  = 16'h0000;

function integer log2;
input [31:0] value;
for (log2=0; value>0; log2=log2+1)
    value = value>>1;
endfunction

wire                            user_start;
reg                             run;
reg  [log2(BUSY_DELAY) +1-1 :0] count;

assign user_start = uif_go & (uif_mode == UIF_MODE_WR) &
                             (uif_addr == XR_DFE_OFFSET_RUN);
                                                                        
// single transition of hold
always @(posedge clk)
begin
    if (reset)
        run <= 1'b0;
    else if (!hold)
        run <= 1'h1;
end

// delay
always @(posedge clk)
begin
    if (!run || user_start)
         count <= 'h0;
    else if (count < BUSY_DELAY)
         count <= count + 1'b1;
end

// busy
assign uif_busy = (count < BUSY_DELAY);

endmodule
 
