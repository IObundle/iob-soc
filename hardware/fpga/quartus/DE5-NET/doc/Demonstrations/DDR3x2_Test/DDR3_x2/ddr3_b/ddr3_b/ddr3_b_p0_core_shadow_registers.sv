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


// ********************************************************************************************************************************
// File name: core_shadow_register.v
// The core shadow registers are responsible for storing T11 settings for two different ranks in the core to support multi-rank interfaces.
// ********************************************************************************************************************************

`timescale 1 ps / 1 ps

module ddr3_b_p0_core_shadow_registers(
	rank_select,
	scc_clk,
	scc_reset_n,
	scc_update,
	scc_rank,
	scc_settings_in,
	settings_out
);


parameter SETTINGS_WIDTH   = "";

input rank_select;
input scc_reset_n;
input scc_clk;
input scc_update;
input scc_rank;
input [SETTINGS_WIDTH-1:0] scc_settings_in;
output [SETTINGS_WIDTH-1:0] settings_out;


reg [SETTINGS_WIDTH-1:0] rank_0_settings;

always @(posedge scc_clk or negedge scc_reset_n)
begin
	if (~scc_reset_n)
	begin
		rank_0_settings <= 0;
	end
	else begin
		if (scc_update)
			rank_0_settings <= scc_settings_in;
			
			/*
			if (scc_rank)
				rank_1_settings <= scc_settings_in;
			else
				rank_0_settings <= scc_settings_in;
			*/
	end
end	 

assign settings_out = rank_0_settings;

endmodule

