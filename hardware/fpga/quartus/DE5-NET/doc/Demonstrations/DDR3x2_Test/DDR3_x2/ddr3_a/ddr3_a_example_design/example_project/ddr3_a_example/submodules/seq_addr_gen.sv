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
// The sequential address generator generates sequential addresses starting
// with a parametrizable address.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module seq_addr_gen(
	clk,
	reset_n,
	enable,
	ready,
	addr,
	burstcount
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// Avalon signal widths
parameter ADDR_WIDTH				= "";
parameter BURSTCOUNT_WIDTH			= "";

// Address generator configuration
parameter POWER_OF_TWO_BURSTS_ONLY	= "";
parameter BURST_ON_BURST_BOUNDARY	= "";
parameter DO_NOT_CROSS_4KB_BOUNDARY	= "";
parameter DATA_WIDTH			= "";

// Burstcount range
parameter MIN_BURSTCOUNT			= "";
parameter MAX_BURSTCOUNT			= "";

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset
input							clk;
input							reset_n;

// Control and status
input							enable;
output							ready;

// Address generator outputs
output 	[ADDR_WIDTH-1:0]		addr;
output	[BURSTCOUNT_WIDTH-1:0]	burstcount;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// Sequential address registers
reg	 	[ADDR_WIDTH-1:0]		seq_addr;


// Sequential address generation
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		seq_addr <= '0;
	else if (enable)
		seq_addr <= addr + burstcount;
end


// Random burstcount generator
rand_burstcount_gen rand_burstcount (
	.clk		(clk),
	.reset_n	(reset_n),
	.enable		(enable),
	.ready		(ready),
	.burstcount	(burstcount));
defparam rand_burstcount.BURSTCOUNT_WIDTH			= BURSTCOUNT_WIDTH;
defparam rand_burstcount.POWER_OF_TWO_BURSTS_ONLY	= POWER_OF_TWO_BURSTS_ONLY;
defparam rand_burstcount.MIN_BURSTCOUNT				= MIN_BURSTCOUNT;
defparam rand_burstcount.MAX_BURSTCOUNT				= MAX_BURSTCOUNT;


// Burst boundary address generator
burst_boundary_addr_gen burst_boundary_addr_gen_inst (
	.burstcount	(burstcount),
	.addr_in	(seq_addr),
	.addr_out	(addr));
defparam burst_boundary_addr_gen_inst.ADDR_WIDTH				= ADDR_WIDTH;
defparam burst_boundary_addr_gen_inst.BURSTCOUNT_WIDTH			= BURSTCOUNT_WIDTH;
defparam burst_boundary_addr_gen_inst.BURST_ON_BURST_BOUNDARY	= BURST_ON_BURST_BOUNDARY;
defparam burst_boundary_addr_gen_inst.DO_NOT_CROSS_4KB_BOUNDARY	= DO_NOT_CROSS_4KB_BOUNDARY;
defparam burst_boundary_addr_gen_inst.DATA_WIDTH		= DATA_WIDTH;


endmodule

