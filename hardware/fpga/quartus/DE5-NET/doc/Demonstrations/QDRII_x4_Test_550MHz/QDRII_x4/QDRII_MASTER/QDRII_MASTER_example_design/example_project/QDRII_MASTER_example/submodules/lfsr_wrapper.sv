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
// This module is a wrapper for the Linear feedback shift registers (LFSR)
// module.  Since the LFSR module has a maximum width (32), this wrapper is
// used to instantiates multiple LFSR modules for an arbitrary width.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module lfsr_wrapper(
	clk,
	reset_n,
	enable,
	data
);

import driver_definitions::*;

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter DATA_WIDTH	= "";
parameter SEED = 36'b000000111110000011110000111000110010;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// The maximum width of a single LFSR
localparam MAX_LFSR_WIDTH	= 36;

// Number of LFSR modules required
localparam NUM_LFSR			= num_lfsr(DATA_WIDTH);

// The width of each LFSR
localparam LFSR_WIDTH		= max(4, (DATA_WIDTH + NUM_LFSR - 1) / NUM_LFSR);

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset
input								clk;
input								reset_n;

// Control and output
input								enable;
output 	[DATA_WIDTH-1:0]			data;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// LFSR outputs
wire	[NUM_LFSR*LFSR_WIDTH-1:0]	lfsr_data;


// Connect output data
assign data = lfsr_data[DATA_WIDTH-1:0];


// Instantiate LFSR modules
generate
genvar i;
for (i = 0; i < NUM_LFSR; i++)
begin : lfsr_gen
	lfsr lfsr_inst (
		.clk		(clk),
		.reset_n	(reset_n),
		.enable		(enable),
		.data		(lfsr_data[((i+1)*LFSR_WIDTH-1):(i*LFSR_WIDTH)]));
	defparam lfsr_inst.WIDTH	= LFSR_WIDTH;
	defparam lfsr_inst.SEED		= SEED * (i + 1) + i;
end
endgenerate


// Calculate the number of LFSR modules needed for the specified width
function integer num_lfsr;
	input integer data_width;
	begin
		num_lfsr = 1;
		while ((data_width + num_lfsr - 1) / num_lfsr > MAX_LFSR_WIDTH)
			num_lfsr = num_lfsr * 2;
	end
endfunction


// Simulation assertions
// synthesis translate_off
initial
begin
	assert (NUM_LFSR * LFSR_WIDTH >= DATA_WIDTH) else $error ("Invalid LSFR width");
end
// synthesis translate_on


endmodule

