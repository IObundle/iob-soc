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
// The burst latency shifter has two functions.  First, when the input goes
// high, it is prolonged for 'BURST_LENGTH' cycles.  Second, the prolonged
// signal is delayed by shift registers.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module memctl_burst_latency_shifter_ctl_bl_is_one (
	clk,
	reset_n,
	d,
	q
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter MAX_LATENCY	= 0;
parameter BURST_LENGTH	= 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

input					clk;
input					reset_n;
input					d;
output	[MAX_LATENCY:0]	q;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

wire					burst_shifter_out;


// The signal is not prolonged, which is equivalent to a simple wire
assign burst_shifter_out = d;


// Latency shifter
generate
if (MAX_LATENCY == 0)
begin : latency_shifter_gen_0
	// The signal is not delayed, which is equivalent to a simple wire
	assign q = burst_shifter_out;
end
else
begin : latency_shifter_gen_n
	reg		[MAX_LATENCY:1]	latency_shifter;
	logic	[MAX_LATENCY:0]	latency_shifter_out;

	assign q = latency_shifter_out;


	// Connect shift register outputs
	always_comb
	begin
		latency_shifter_out[0] <= burst_shifter_out;
		for (int i = 1; i <= MAX_LATENCY; i++)
			latency_shifter_out[i] <= latency_shifter[i];
	end


	// Shift register logic
	always_ff @(posedge clk or negedge reset_n)
	begin
		if (!reset_n)
			latency_shifter <= '0;
		else
		begin
			latency_shifter[1] <= burst_shifter_out;
			for (int i = 2; i <= MAX_LATENCY; i++)
				latency_shifter[i] <= latency_shifter[i-1];
		end
	end
end
endgenerate


endmodule

