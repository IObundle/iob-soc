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



//  File Name: alt_xcvr_reset_counter
//
//  Description:  
//
//    A simple counter targeted for a reset controller. The parameters specify the clock domain's
//  clock frequency and the desired reset period specified in nanoseconds. The caller may specify
//  the active level of the internal reset flop.
//
//    The async_req input signal is active high. The reset outputs
//  will remain asserted while async_req is asserted and will not deassert
//  until the specified reset period has expired.
//    The sync_req input behaves similar to the async_req but is sampled
//  synchronously with the clock.
//    The "reset_or" input does not reset the counter but directly asserts the reset output flop.
//  The reset outputs will remain asserted so long as "reset_or" is asserted.
//
//  Revision History: 
//
//  Special notes:
//

`timescale 1ns / 1ns

module  alt_xcvr_reset_counter #(
    parameter CLKS_PER_SEC  = 25000000, // Clock frequency in Hz
    parameter RESET_PER_NS  = 1000000,  // Reset period in ns
    parameter RESET_COUNT   = 0,        // Overrides RESET_PER_NS
    parameter ACTIVE_LEVEL  = 1         //
) (
  input         clk,
  input         async_req,  // asynchronous reset request (restart sequence)
  input         sync_req,   // synchronous reset request
  input         reset_or,   // auxilliary reset override (assert only)

  output        reset,      // synchronous reset out
  output        reset_n,    // negation of reset
  output        reset_stat  // reset status (intended for control logic)
);

// Determine unrounded counter limit based on passed frequency
localparam  [63:0] INITIAL_COUNT  = (CLKS_PER_SEC * RESET_PER_NS) / 1000000000;
// Round counter limit up if needed
localparam  [63:0] ROUND_COUNT    = (((INITIAL_COUNT * 1000000000) / CLKS_PER_SEC) < RESET_PER_NS)
                            ? (INITIAL_COUNT + 1) : INITIAL_COUNT;
// Use given counter limit if provided (RESET_COUNT), otherwise use calculated counter limit
localparam  MAX_CNT = (RESET_COUNT == 0) ? ROUND_COUNT - 1 : RESET_COUNT - 1;
localparam  CNT_WIDTH = altera_xcvr_functions::clogb2(MAX_CNT);
// 1 bit wide active level
localparam  LCL_ACTIVE_LEVEL  = (ACTIVE_LEVEL == 0) ? 1'b0 : 1'b1;

// Counter signals
reg [CNT_WIDTH-1:0] count = {CNT_WIDTH{1'b0}};
wire                count_lim;

// Internal reset signals
(* dont_merge *) 
reg   r_reset;      // Reset output register
reg   r_reset_stat; // Reset status register
wire  reset_cond;   // Condition for reset

// Reset counter
//***************************************************************************
//**************************** Reset counter ********************************
assign  count_lim = (count == MAX_CNT);
always @(posedge clk or posedge async_req)
  if(async_req)       count <= {CNT_WIDTH{1'b0}};
  else if(sync_req)   count <= {CNT_WIDTH{1'b0}};
  else if(~count_lim) count <= count + 1'b1;
//************************** End Reset counter ******************************
//***************************************************************************


//***************************************************************************
//********************** Internal reset register ****************************
// The condition for a reset (other than asynchrnous reset) are:
// 1 - Synchronous reset request
// 2 - Timer has not expired.
// 3 - Reset override is asserted
assign  reset_cond  = (sync_req | ~count_lim | reset_or);

// Reset register
always @(posedge clk or posedge async_req)
  if(async_req)     r_reset <= LCL_ACTIVE_LEVEL;
  else              r_reset <= ~(reset_cond ^ LCL_ACTIVE_LEVEL);

// External reset status generation. We create a status of the reset
// output simply so we can allow the actual reset output to drive resets
// with limited fanout to other logic. This status output is intended
// to be used for reset control logic.
assign  reset_stat  = r_reset_stat;
always @(posedge clk or posedge async_req)
  if(async_req)     r_reset_stat  <= 1'b1;
  else              r_reset_stat  <= reset_cond;
//******************** End Internal reset register **************************
//***************************************************************************


//***************************************************************************
//*********************** Reset output generation ***************************
// External reset generation
generate if (ACTIVE_LEVEL == 0) begin : g_active_low_resets
  assign  reset   = ~r_reset;
  assign  reset_n = r_reset;
end else begin : g_active_high_resets
  assign  reset   = r_reset;
  assign  reset_n = ~r_reset;
end
endgenerate
//********************* End Reset output generation *************************
//***************************************************************************

endmodule

