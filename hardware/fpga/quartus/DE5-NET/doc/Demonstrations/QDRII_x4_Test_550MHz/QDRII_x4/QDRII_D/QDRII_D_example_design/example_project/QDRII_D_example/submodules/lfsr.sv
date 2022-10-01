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


//////////////////////////////////////////////////////////////////////////////
// The Pseudo-Random Shift Registers (LFSR) generates 2^n-1 pseudo random
// numbers where n is the width of the LFSR.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module lfsr(
	clk,
	reset_n,
	enable,
	data
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter WIDTH	= "";
parameter SEED	= 36'b000000111110000011110000111000110010;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset
input				clk;
input				reset_n;

// Control
input				enable;

// LFSR output
output	[WIDTH-1:0]	data;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// Shift registers
reg		[WIDTH-1:0]	data;

// LFSR taps
wire	[WIDTH-1:0]	taps;


// The taps are referenced from
// http://www.physics.otago.ac.nz/px/research/electronics/papers/technical-reports/lfsr_table.pdf
generate
case (WIDTH)
	4:	assign taps =  4'b1100;
	5:	assign taps =  5'b10100;
	6:	assign taps =  6'b110000;
	7:	assign taps =  7'b1100000;
	8:	assign taps =  8'b10111000;
	9:	assign taps =  9'b100010000;
	10:	assign taps = 10'b1001000000;
	11:	assign taps = 11'b10100000000;
	12:	assign taps = 12'b110010100000;
	13:	assign taps = 13'b1101100000000;
	14:	assign taps = 14'b11010100000000;
	15:	assign taps = 15'b110000000000000;
	16:	assign taps = 16'b1011010000000000;
	17:	assign taps = 17'b10010000000000000;
	18:	assign taps = 18'b100000010000000000;
	19:	assign taps = 19'b1110010000000000000;
	20:	assign taps = 20'b10010000000000000000;
	21:	assign taps = 21'b101000000000000000000;
	22:	assign taps = 22'b1100000000000000000000;
	23:	assign taps = 23'b10000100000000000000000;
	24:	assign taps = 24'b110110000000000000000000;
	25:	assign taps = 25'b1001000000000000000000000;
	26:	assign taps = 26'b11100010000000000000000000;
	27:	assign taps = 27'b111001000000000000000000000;
	28:	assign taps = 28'b1001000000000000000000000000;
	29:	assign taps = 29'b10100000000000000000000000000;
	30:	assign taps = 30'b110010100000000000000000000000;
	31:	assign taps = 31'b1001000000000000000000000000000;
	32:	assign taps = 32'b10100011000000000000000000000000;
	33:	assign taps = 33'b100000000000010000000000000000000;
	34:	assign taps = 34'b1001100010000000000000000000000000;
	35:	assign taps = 35'b10100000000000000000000000000000000;
	36:	assign taps = 36'b100000000001000000000000000000000000;
endcase
endgenerate


always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		data <= SEED[WIDTH-1:0];
	end
	else if (enable)
	begin
		data[WIDTH-1] <= data[0];
		data[WIDTH-2:0] <= data[WIDTH-1:1] ~^ (~taps[WIDTH-2:0] | {WIDTH-1{data[0]}});
	end
end


// Simulation assertions
// synthesis translate_off
initial
begin
	assert (WIDTH >= 4 && WIDTH <= 36) else $error ("Invalid LSFR width");
end
// synthesis translate_on


endmodule

