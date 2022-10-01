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
// The random burstcount generator generates random burstcounts within
// parametrizable ranges.  In addition, an option can be enabled to only
// generate burstcounts that are powers of two.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module rand_burstcount_gen(
	clk,
	reset_n,
	enable,
	ready,
	burstcount
);

import driver_definitions::*;

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// Avalon signal widths
parameter BURSTCOUNT_WIDTH			= "";

// Burstcount generator configuration
parameter POWER_OF_TWO_BURSTS_ONLY	= "";

// Burstcount range
parameter MIN_BURSTCOUNT			= "";
parameter MAX_BURSTCOUNT			= "";

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

localparam MIN_EXPONENT		= ceil_log2(MIN_BURSTCOUNT);
localparam MAX_EXPONENT		= log2(MAX_BURSTCOUNT);
localparam EXPONENT_WIDTH	= ceil_log2(MAX_EXPONENT + 1);

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset
input							clk;
input							reset_n;

// Control and status
input							enable;
output							ready;

// Burstcount generator output
output	[BURSTCOUNT_WIDTH-1:0]	burstcount;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

generate
if (POWER_OF_TWO_BURSTS_ONLY == 1)
begin : power_of_two_true
	// POWER_OF_TWO_BURSTS_ONLY is enabled
	// Use the random number generator to generate the exponent

	wire	[EXPONENT_WIDTH-1:0]	rand_exponent_out;

	rand_num_gen rand_exponent (
		.clk		(clk),
		.reset_n	(reset_n),
		.enable		(enable),
		.ready		(ready),
		.rand_num	(rand_exponent_out),
		.is_less_than());
	defparam rand_exponent.RAND_NUM_WIDTH	= EXPONENT_WIDTH;
	defparam rand_exponent.RAND_NUM_MIN		= MIN_EXPONENT;
	defparam rand_exponent.RAND_NUM_MAX		= MAX_EXPONENT;

	assign burstcount = 1 << rand_exponent_out;
end
else
begin : power_of_two_false
	// POWER_OF_TWO_BURSTS_ONLY is disabled
	// Simply generate the burstcount using a random number generator

	rand_num_gen rand_burstcount (
		.clk		(clk),
		.reset_n	(reset_n),
		.enable		(enable),
		.ready		(ready),
		.rand_num	(burstcount),
    .is_less_than());
	defparam rand_burstcount.RAND_NUM_WIDTH	= BURSTCOUNT_WIDTH;
	defparam rand_burstcount.RAND_NUM_MIN	= MIN_BURSTCOUNT;
	defparam rand_burstcount.RAND_NUM_MAX	= MAX_BURSTCOUNT;
end
endgenerate


endmodule

