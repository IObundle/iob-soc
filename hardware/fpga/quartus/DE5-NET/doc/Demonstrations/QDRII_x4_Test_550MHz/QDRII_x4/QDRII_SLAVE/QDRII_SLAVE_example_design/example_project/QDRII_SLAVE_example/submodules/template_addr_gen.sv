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
// This is an example address generator, which simply alternate between 0x0
// and 0x1.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module template_addr_gen(
	clk,
	reset_n,
	enable,
	ready,
	addr,
	burstcount
);

import driver_definitions::*;

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// Avalon signal widths
parameter ADDR_WIDTH		= "";
parameter BURSTCOUNT_WIDTH	= "";

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

// Address bit 0 register
reg								addr0;


// Always ready
assign ready = 1'b1;

// Always issue single burst commands
assign burstcount = {'0,1'b1};


// Alternate address 0x0 and 0x1
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		addr0 <= 1'b0;
	else if (enable)
		addr0 <= ~addr0;
end

assign addr = {'0, addr0};


endmodule

