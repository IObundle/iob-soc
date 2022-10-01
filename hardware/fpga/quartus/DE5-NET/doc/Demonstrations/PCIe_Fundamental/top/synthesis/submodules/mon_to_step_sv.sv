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


// mon_to_step
//
// This module converts the reye monitor data to a binary
// step value for the user.

module mon_to_step_sv (
input  wire       clk,
input  wire [5:0] monitor,
output reg  [5:0] step
);

always@(posedge clk)
begin
     case (monitor)
        6'b11_1000:  step <= 6'h00;
        6'b11_1001:  step <= 6'h01;
        6'b11_1011:  step <= 6'h02;
        6'b11_1010:  step <= 6'h03;
        6'b11_1110:  step <= 6'h04;
        6'b11_1111:  step <= 6'h05;
        6'b11_1101:  step <= 6'h06;
        6'b11_1100:  step <= 6'h07;
        6'b11_0100:  step <= 6'h08;
        6'b11_0101:  step <= 6'h09;
        6'b11_0111:  step <= 6'h0a;
        6'b11_0110:  step <= 6'h0b;
        6'b11_0010:  step <= 6'h0c;
        6'b11_0011:  step <= 6'h0d;
        6'b11_0001:  step <= 6'h0e;
        6'b11_0000:  step <= 6'h0f;
		  
        6'b01_0000:  step <= 6'h10;
        6'b01_0001:  step <= 6'h11;
        6'b01_0011:  step <= 6'h12;
        6'b01_0010:  step <= 6'h13;
        6'b01_0110:  step <= 6'h14;
        6'b01_0111:  step <= 6'h15;
        6'b01_0101:  step <= 6'h16;
        6'b01_0100:  step <= 6'h17;
        6'b01_1100:  step <= 6'h18;
        6'b01_1101:  step <= 6'h19;
        6'b01_1111:  step <= 6'h1a;
        6'b01_1110:  step <= 6'h1b;
        6'b01_1010:  step <= 6'h1c;
        6'b01_1011:  step <= 6'h1d;
        6'b01_1001:  step <= 6'h1e;
        6'b01_1000:  step <= 6'h1f;
		  
        6'b00_1000:  step <= 6'h20;
        6'b00_1001:  step <= 6'h21;
        6'b00_1011:  step <= 6'h22;
        6'b00_1010:  step <= 6'h23;
        6'b00_1110:  step <= 6'h24;
        6'b00_1111:  step <= 6'h25;
        6'b00_1101:  step <= 6'h26;
        6'b00_1100:  step <= 6'h27;
        6'b00_0100:  step <= 6'h28;
        6'b00_0101:  step <= 6'h29;
        6'b00_0111:  step <= 6'h2a;
        6'b00_0110:  step <= 6'h2b;
        6'b00_0010:  step <= 6'h2c;
        6'b00_0011:  step <= 6'h2d;
        6'b00_0001:  step <= 6'h2e;
        6'b00_0000:  step <= 6'h2f;
		  
        6'b10_0000:  step <= 6'h30;
        6'b10_0001:  step <= 6'h31;
        6'b10_0011:  step <= 6'h32;
        6'b10_0010:  step <= 6'h33;
        6'b10_0110:  step <= 6'h34;
        6'b10_0111:  step <= 6'h35;
        6'b10_0101:  step <= 6'h36;
        6'b10_0100:  step <= 6'h37;
        6'b10_1100:  step <= 6'h38;
        6'b10_1101:  step <= 6'h39;
        6'b10_1111:  step <= 6'h3a;
        6'b10_1110:  step <= 6'h3b;
        6'b10_1010:  step <= 6'h3c;
        6'b10_1011:  step <= 6'h3d;
        6'b10_1001:  step <= 6'h3e;
        6'b10_1000:  step <= 6'h3f;
	endcase
end

	endmodule
