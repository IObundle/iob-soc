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
// The random number generator uses the LFSR module to generate random numbers
// within a parametrizable range.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module rand_num_gen(
	clk,
	reset_n,
	enable,
	ready,
	rand_num,
	is_less_than
);

import driver_definitions::*;

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter RAND_NUM_WIDTH	= "";
parameter RAND_NUM_MIN		= "";
parameter RAND_NUM_MAX		= "";
parameter RAND_NUM_IS_LESS_THAN_THRESHOLD = 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// Derive LFSR parameters
localparam LFSR_DATA_RANGE	= RAND_NUM_MAX - RAND_NUM_MIN + 1;
localparam LFSR_DATA_WIDTH	= ceil_log2(LFSR_DATA_RANGE);
localparam LFSR_WIDTH		= max(4, ceil_log2(LFSR_DATA_RANGE + 1));

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

// Random number generator output
output	[RAND_NUM_WIDTH-1:0]	rand_num;
output							is_less_than;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

generate
if (RAND_NUM_MIN == RAND_NUM_MAX)
begin : constant_gen
	// The max and min of the range equal
	// Simply output a constant number

	assign ready = 1'b1;
	assign rand_num = RAND_NUM_MIN;
	assign is_less_than = (RAND_NUM_MIN < RAND_NUM_IS_LESS_THAN_THRESHOLD) ? 1'b1 : 1'b0;
end
else if (RAND_NUM_MIN < RAND_NUM_MAX)
begin : random_gen
	// Instantiate the LFSR which is automatically run
	// until the output is within the specified range

	// Registered random number output
	reg 							rand_num_valid_reg;
	reg		[RAND_NUM_WIDTH-1:0]	rand_num_reg;
	reg								is_less_than_reg;

	// LFSR output
	wire							lfsr_valid;
	wire	[LFSR_WIDTH-1:0]		lfsr_data;

	assign ready = rand_num_valid_reg;
	assign rand_num = rand_num_reg;
	assign is_less_than = is_less_than_reg;

	// The LFSR output is valid if it is in the range of 0 and LFSR_DATA_RANGE
	assign lfsr_valid = lfsr_data[LFSR_DATA_WIDTH-1:0] < LFSR_DATA_RANGE;

	// Output the number within range by adding RAND_NUM_MIN
	always_ff @(posedge clk or negedge reset_n)
	begin
		if (!reset_n)
		begin
			rand_num_valid_reg <= 1'b0;
			rand_num_reg <= '0;
		end
		else if ((!rand_num_valid_reg && lfsr_valid) || enable)
		begin
			rand_num_valid_reg <= lfsr_valid;
			rand_num_reg <= lfsr_data[LFSR_DATA_WIDTH-1:0] + RAND_NUM_MIN[RAND_NUM_WIDTH-1:0];
			is_less_than_reg <= ((lfsr_data[LFSR_DATA_WIDTH-1:0] + RAND_NUM_MIN[RAND_NUM_WIDTH-1:0]) < RAND_NUM_IS_LESS_THAN_THRESHOLD) ? 1'b1 : 1'b0;
		end
	end

	// The LFSR module
	lfsr lfsr_inst (
		.clk		(clk),
		.reset_n	(reset_n),
		.enable		(~lfsr_valid | ~rand_num_valid_reg | enable),
		.data		(lfsr_data));
	defparam lfsr_inst.WIDTH = LFSR_WIDTH;
end
endgenerate


// Simulation assertions
// synthesis translate_off
initial
begin
	assert (RAND_NUM_MAX >= RAND_NUM_MIN) else $error ("Invalid random number range");
	assert (RAND_NUM_MAX < 2**RAND_NUM_WIDTH) else $error ("Invalid random number width");
end
// synthesis translate_on


endmodule

