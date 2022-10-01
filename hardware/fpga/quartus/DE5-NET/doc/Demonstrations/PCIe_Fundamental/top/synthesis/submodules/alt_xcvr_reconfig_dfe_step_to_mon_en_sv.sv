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


// step_to_mon_en
//
// This module converts the user step data to reye monitor 
// encoded values.

// $Header$
`timescale 1 ns / 1 ps

module alt_xcvr_reconfig_dfe_step_to_mon_en_sv (
input  wire       clk,
input  wire       enable,
input  wire [5:0] step,
output reg  [5:0] monitor
);

always@(posedge clk)
begin
    if (enable)
     case (step)
        6'h00 : monitor <= 6'b11_1000;
        6'h01 : monitor <= 6'b11_1001;
        6'h02 : monitor <= 6'b11_1011;
        6'h03 : monitor <= 6'b11_1010;
        6'h04 : monitor <= 6'b11_1110;
        6'h05 : monitor <= 6'b11_1111;
        6'h06 : monitor <= 6'b11_1101;
        6'h07 : monitor <= 6'b11_1100;
        6'h08 : monitor <= 6'b11_0100;
        6'h09 : monitor <= 6'b11_0101;
        6'h0a : monitor <= 6'b11_0111;
        6'h0b : monitor <= 6'b11_0110;
        6'h0c : monitor <= 6'b11_0010;
        6'h0d : monitor <= 6'b11_0011;
        6'h0e : monitor <= 6'b11_0001;
        6'h0f : monitor <= 6'b11_0000;
		  
        6'h10 : monitor <= 6'b01_0000;
        6'h11 : monitor <= 6'b01_0001;
        6'h12 : monitor <= 6'b01_0011;
        6'h13 : monitor <= 6'b01_0010;
        6'h14 : monitor <= 6'b01_0110;
        6'h15 : monitor <= 6'b01_0111;
        6'h16 : monitor <= 6'b01_0101;
        6'h17 : monitor <= 6'b01_0100;
        6'h18 : monitor <= 6'b01_1100;
        6'h19 : monitor <= 6'b01_1101;
        6'h1a : monitor <= 6'b01_1111;
        6'h1b : monitor <= 6'b01_1110;
        6'h1c : monitor <= 6'b01_1010;
        6'h1d : monitor <= 6'b01_1011;
        6'h1e : monitor <= 6'b01_1001;
        6'h1f : monitor <= 6'b01_1000;
		  
        6'h20 : monitor <= 6'b00_1000;
        6'h21 : monitor <= 6'b00_1001;
        6'h22 : monitor <= 6'b00_1011;
        6'h23 : monitor <= 6'b00_1010;
        6'h24 : monitor <= 6'b00_1110;
        6'h25 : monitor <= 6'b00_1111;
        6'h26 : monitor <= 6'b00_1101;
        6'h27 : monitor <= 6'b00_1100;
        6'h28 : monitor <= 6'b00_0100;
        6'h29 : monitor <= 6'b00_0101;
        6'h2a : monitor <= 6'b00_0111;
        6'h2b : monitor <= 6'b00_0110;
        6'h2c : monitor <= 6'b00_0010;
        6'h2d : monitor <= 6'b00_0011;
        6'h2e : monitor <= 6'b00_0001;
        6'h2f : monitor <= 6'b00_0000;
		  
        6'h30 : monitor <= 6'b10_0000;
        6'h31 : monitor <= 6'b10_0001;
        6'h32 : monitor <= 6'b10_0011;
        6'h33 : monitor <= 6'b10_0010;
        6'h34 : monitor <= 6'b10_0110;
        6'h35 : monitor <= 6'b10_0111;
        6'h36 : monitor <= 6'b10_0101;
        6'h37 : monitor <= 6'b10_0100;
        6'h38 : monitor <= 6'b10_1100;
        6'h39 : monitor <= 6'b10_1101;
        6'h3a : monitor <= 6'b10_1111;
        6'h3b : monitor <= 6'b10_1110;
        6'h3c : monitor <= 6'b10_1010;
        6'h3d : monitor <= 6'b10_1011;
        6'h3e : monitor <= 6'b10_1001;
        6'h3f : monitor <= 6'b10_1000;
	endcase
end

	endmodule
