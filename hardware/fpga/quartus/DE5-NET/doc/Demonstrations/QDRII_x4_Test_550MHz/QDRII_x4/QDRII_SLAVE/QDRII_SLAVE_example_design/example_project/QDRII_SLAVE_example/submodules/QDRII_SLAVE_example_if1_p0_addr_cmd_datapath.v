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



`timescale 1 ps / 1 ps

module QDRII_SLAVE_example_if1_p0_addr_cmd_datapath(
	clk,
	reset_n,
	afi_address,
	afi_wps_n,
	afi_rps_n,
	afi_doff_n,
	phy_ddio_address,
	phy_ddio_wps_n,
	phy_ddio_rps_n,
	phy_ddio_doff_n
);


parameter MEM_ADDRESS_WIDTH     = "";
parameter MEM_DM_WIDTH          = "";
parameter MEM_CONTROL_WIDTH     = "";
parameter MEM_DQ_WIDTH          = "";
parameter MEM_READ_DQS_WIDTH    = "";
parameter MEM_WRITE_DQS_WIDTH   = "";

parameter AFI_ADDRESS_WIDTH         = "";
parameter AFI_DATA_MASK_WIDTH       = "";
parameter AFI_CONTROL_WIDTH         = "";
parameter AFI_DATA_WIDTH            = "";

parameter NUM_AC_FR_CYCLE_SHIFTS    = "";

localparam RATE_MULT = 2;


input	reset_n;
input	clk;
input	[AFI_ADDRESS_WIDTH-1:0]	afi_address;
input	[AFI_CONTROL_WIDTH-1:0] afi_wps_n;
input	[AFI_CONTROL_WIDTH-1:0] afi_rps_n;
input	[AFI_CONTROL_WIDTH-1:0] afi_doff_n;

output	[AFI_ADDRESS_WIDTH-1:0]	phy_ddio_address;
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_wps_n;
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_rps_n;
output	[AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n;

	wire [AFI_ADDRESS_WIDTH-1:0] afi_address_r = afi_address;
	wire [AFI_CONTROL_WIDTH-1:0] afi_wps_n_r = afi_wps_n;
	wire [AFI_CONTROL_WIDTH-1:0] afi_rps_n_r = afi_rps_n;
	wire [AFI_CONTROL_WIDTH-1:0] afi_doff_n_r = afi_doff_n;


	wire [1:0] shift_fr_cycle =
		(NUM_AC_FR_CYCLE_SHIFTS == 0) ? 	2'b00 : (
		(NUM_AC_FR_CYCLE_SHIFTS == 1) ? 	2'b01 : (
		(NUM_AC_FR_CYCLE_SHIFTS == 2) ? 	2'b10 : (
											2'b11 )));

	QDRII_SLAVE_example_if1_p0_fr_cycle_shifter uaddr_cmd_shift_address(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_address_r),
		.dataout (phy_ddio_address)
	);
	defparam uaddr_cmd_shift_address.DATA_WIDTH = MEM_ADDRESS_WIDTH;
	defparam uaddr_cmd_shift_address.REG_POST_RESET_HIGH = "false";


	QDRII_SLAVE_example_if1_p0_fr_cycle_shifter uaddr_cmd_shift_wps_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_wps_n_r),
		.dataout (phy_ddio_wps_n)
	);
	defparam uaddr_cmd_shift_wps_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_shift_wps_n.REG_POST_RESET_HIGH = "true";

	QDRII_SLAVE_example_if1_p0_fr_cycle_shifter uaddr_cmd_shift_rps_n(
		.clk (clk),
		.reset_n (reset_n),
		.shift_by (shift_fr_cycle),
		.datain (afi_rps_n_r),
		.dataout (phy_ddio_rps_n)
	);
	defparam uaddr_cmd_shift_rps_n.DATA_WIDTH = MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_shift_rps_n.REG_POST_RESET_HIGH = "true";

	assign phy_ddio_doff_n = afi_doff_n_r;




endmodule
