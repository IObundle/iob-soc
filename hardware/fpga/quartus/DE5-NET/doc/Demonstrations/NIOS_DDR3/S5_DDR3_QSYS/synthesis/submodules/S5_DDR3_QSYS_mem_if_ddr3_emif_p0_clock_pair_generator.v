//altiobuf_out CBX_AUTO_BLACKBOX="ALL" CBX_SINGLE_OUTPUT_FILE="ON" DEVICE_FAMILY="Stratix V" ENABLE_BUS_HOLD="FALSE" NUMBER_OF_CHANNELS=1 OPEN_DRAIN_OUTPUT="FALSE" PSEUDO_DIFFERENTIAL_MODE="TRUE" USE_DIFFERENTIAL_MODE="TRUE" USE_OE="FALSE" USE_OUT_DYNAMIC_DELAY_CHAIN1="FALSE" USE_OUT_DYNAMIC_DELAY_CHAIN2="FALSE" USE_TERMINATION_CONTROL="FALSE" datain dataout dataout_b
//VERSION_BEGIN 16.1 cbx_altiobuf_out 2017:01:18:18:20:37:SJ cbx_mgl 2017:01:18:18:27:06:SJ cbx_stratixiii 2017:01:18:18:20:37:SJ cbx_stratixv 2017:01:18:18:20:37:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 2017  Intel Corporation. All rights reserved.
//  Your use of Intel Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Intel Program License 
//  Subscription Agreement, the Intel Quartus Prime License Agreement,
//  the Intel MegaCore Function License Agreement, or other 
//  applicable license agreement, including, without limitation, 
//  that your use is for the sole purpose of programming logic 
//  devices manufactured by Intel and sold by Intel or its 
//  authorized distributors.  Please refer to the applicable 
//  agreement for further details.



//synthesis_resources = stratixv_io_obuf 2 stratixv_pseudo_diff_out 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  S5_DDR3_QSYS_mem_if_ddr3_emif_p0_clock_pair_generator
	( 
	datain,
	dataout,
	dataout_b) /* synthesis synthesis_clearbox=1 */;
	input   [0:0]  datain;
	output   [0:0]  dataout;
	output   [0:0]  dataout_b;

	wire  [0:0]   wire_obuf_ba_o;
	wire  [0:0]   wire_obuf_ba_oe;
	wire  [0:0]   wire_obufa_o;
	wire  [0:0]   wire_obufa_oe;
	wire  [0:0]   wire_pseudo_diffa_o;
	wire  [0:0]   wire_pseudo_diffa_obar;
	wire  [0:0]   wire_pseudo_diffa_oebout;
	wire  [0:0]   wire_pseudo_diffa_oein;
	wire  [0:0]   wire_pseudo_diffa_oeout;
	wire  [0:0]  oe_w;

	stratixv_io_obuf   obuf_ba_0
	( 
	.i(wire_pseudo_diffa_obar),
	.o(wire_obuf_ba_o[0:0]),
	.obar(),
	.oe(wire_obuf_ba_oe[0:0])
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.dynamicterminationcontrol(1'b0),
	.parallelterminationcontrol({16{1'b0}}),
	.seriesterminationcontrol({16{1'b0}})
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devoe(1'b1)
	// synopsys translate_on
	);
	defparam
		obuf_ba_0.bus_hold = "false",
		obuf_ba_0.open_drain_output = "false",
		obuf_ba_0.lpm_type = "stratixv_io_obuf";
	assign
		wire_obuf_ba_oe = {(~ wire_pseudo_diffa_oebout[0])};
	stratixv_io_obuf   obufa_0
	( 
	.i(wire_pseudo_diffa_o),
	.o(wire_obufa_o[0:0]),
	.obar(),
	.oe(wire_obufa_oe[0:0])
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.dynamicterminationcontrol(1'b0),
	.parallelterminationcontrol({16{1'b0}}),
	.seriesterminationcontrol({16{1'b0}})
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	// synopsys translate_off
	,
	.devoe(1'b1)
	// synopsys translate_on
	);
	defparam
		obufa_0.bus_hold = "false",
		obufa_0.open_drain_output = "false",
		obufa_0.lpm_type = "stratixv_io_obuf";
	assign
		wire_obufa_oe = {(~ wire_pseudo_diffa_oeout[0])};
	stratixv_pseudo_diff_out   pseudo_diffa_0
	( 
	.dtc(),
	.dtcbar(),
	.i(datain),
	.o(wire_pseudo_diffa_o[0:0]),
	.obar(wire_pseudo_diffa_obar[0:0]),
	.oebout(wire_pseudo_diffa_oebout[0:0]),
	.oein(wire_pseudo_diffa_oein[0:0]),
	.oeout(wire_pseudo_diffa_oeout[0:0])
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.dtcin(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	assign
		wire_pseudo_diffa_oein = {(~ oe_w[0])};
	assign
		dataout = wire_obufa_o,
		dataout_b = wire_obuf_ba_o,
		oe_w = 1'b1;
endmodule //S5_DDR3_QSYS_mem_if_ddr3_emif_p0_clock_pair_generator
//VALID FILE
