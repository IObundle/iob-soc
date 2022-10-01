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


// local reset
//
// This module create a local synchronous reset

// $Header$
`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dfe_local_reset_sv
 (
    input   wire       clk,
    input   wire       reset,
    output  wire       reset_sync
);

reg [5:0]  reset_ff;  
  
// shiftreg
// preset to all 1's by reset
// 0 shfted in
always @(posedge clk)
begin   
    if (reset)
       reset_ff <= 6'h3f;
    else
       reset_ff <= {reset_ff[4:0], 1'b0};
end

assign reset_sync = reset_ff[5];

endmodule
          
