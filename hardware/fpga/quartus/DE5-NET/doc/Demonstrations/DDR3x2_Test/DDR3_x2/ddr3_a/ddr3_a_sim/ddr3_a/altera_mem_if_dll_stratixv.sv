// (C) 2001-2012 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// ******************************************************************************************************************************** 
// This file instantiates the DLL.
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

(* altera_attribute = "-name IP_TOOL_NAME altera_mem_if_dll; -name IP_TOOL_VERSION 12.0; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100; -name ALLOW_SYNCH_CTRL_USAGE OFF; -name AUTO_CLOCK_ENABLE_RECOGNITION OFF; -name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)


module altera_mem_if_dll_stratixv (
	clk,
	dll_delayctrl
);


parameter DLL_DELAY_CTRL_WIDTH	= 0;
parameter DELAY_BUFFER_MODE = "";
parameter DELAY_CHAIN_LENGTH = 0;
parameter DLL_INPUT_FREQUENCY_PS_STR = "";
parameter DLL_OFFSET_CTRL_WIDTH = 0;


input                                clk;  // DLL input clock
output  [DLL_DELAY_CTRL_WIDTH-1:0]   dll_delayctrl;


wire  wire_dll_wys_m_offsetdelayctrlclkout;
wire  [DLL_DELAY_CTRL_WIDTH-1:0]   wire_dll_wys_m_offsetdelayctrlout;


	
	stratixv_dll dll_wys_m(
		.clk(clk),
		.delayctrlout(dll_delayctrl),
		.dqsupdate(),
		.locked(),
		.offsetdelayctrlclkout(wire_dll_wys_m_offsetdelayctrlclkout),
		.offsetdelayctrlout(wire_dll_wys_m_offsetdelayctrlout),
		.upndnout()
		`ifndef FORMAL_VERIFICATION
		// synopsys translate_off
		`endif
		,
		.aload(1'b0),
		.upndnin(1'b1),
		.upndninclkena(1'b1)
		`ifndef FORMAL_VERIFICATION
		// synopsys translate_on
		`endif
		// synopsys translate_off
		,
		.dffin()
		// synopsys translate_on
	);
	defparam dll_wys_m.input_frequency = DLL_INPUT_FREQUENCY_PS_STR;
	defparam dll_wys_m.jitter_reduction = "true";
	defparam dll_wys_m.static_delay_ctrl = DELAY_CHAIN_LENGTH;
	defparam dll_wys_m.lpm_type = "stratixv_dll";


 


endmodule

