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
// This module rounds up the input address to the next burst boundary.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module burst_boundary_addr_gen(
	burstcount,
	addr_in,
	addr_out
);

import driver_definitions::*;

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// Avalon signal widths
parameter ADDR_WIDTH				= "";
parameter BURSTCOUNT_WIDTH			= "";

// Address generator configuration
parameter BURST_ON_BURST_BOUNDARY	= "";
parameter DO_NOT_CROSS_4KB_BOUNDARY	= "";
parameter DATA_WIDTH			= "";

localparam LOG_4KB = 12 - log2(DATA_WIDTH);

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

input	[BURSTCOUNT_WIDTH-1:0]	burstcount;
input	[ADDR_WIDTH-1:0]		addr_in;
output 	[ADDR_WIDTH-1:0]		addr_out;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

wire 	[ADDR_WIDTH-1:0]		addr_out_1;

generate
if (BURST_ON_BURST_BOUNDARY == 1)
begin : burst_boundary_true
	// Burst on burst boundary is enabled

	// Set the lower address bits to 0's
	logic	[ADDR_WIDTH-1:0]	addr_tmp;
	logic	[ADDR_WIDTH-1:0]	addr_tmp_incr;

	always_comb
	begin
		for (int i = 0; i < ADDR_WIDTH; i++)
		begin
			if (burstcount > 2**i)
				addr_tmp[i] <= 1'b0;
			else
				addr_tmp[i] <= addr_in[i];

			if (burstcount == 2**i)
				addr_tmp_incr[i] <= 1'b1;
			else
				addr_tmp_incr[i] <= 1'b0;
		end
	end

	assign addr_out_1 = addr_tmp + addr_tmp_incr;
end
else
begin : burst_boundary_false
	// Burst on burst boundary is disabled, leave the address as is
	assign addr_out_1 = addr_in;
end
endgenerate

generate
if (DO_NOT_CROSS_4KB_BOUNDARY == 1)
begin: dont_cross_4kb_boundary_true
	wire [ADDR_WIDTH-1:0] last_addr;
	assign last_addr = addr_out_1 + burstcount - 1;
	assign addr_out = (addr_out_1[ADDR_WIDTH-1:LOG_4KB] != last_addr[ADDR_WIDTH-1:LOG_4KB]) ? addr_out_1 + burstcount : addr_out_1;
end
else
begin: dont_cross_4kb_boundary_false
	assign addr_out = addr_out_1;
end
endgenerate


endmodule

