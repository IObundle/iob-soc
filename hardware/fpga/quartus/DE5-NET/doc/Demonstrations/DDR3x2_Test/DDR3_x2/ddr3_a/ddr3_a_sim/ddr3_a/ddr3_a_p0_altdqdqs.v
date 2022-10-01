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

module ddr3_a_p0_altdqdqs (
	core_clock_in,
	reset_n_core_clock_in,
	fr_data_clock_in,
	fr_strobe_clock_in,
	hr_clock_in,
	write_strobe_clock_in,
	strobe_ena_hr_clock_in,
	strobe_ena_clock_in,
	capture_strobe_ena,
	capture_strobe_tracking,
	read_write_data_io,
	write_oe_in,
	strobe_io,
	output_strobe_ena,
	strobe_n_io,


	oct_ena_in,
	read_data_out,
	capture_strobe_out,
	write_data_in,
	extra_write_data_in,
	extra_write_data_out,
	parallelterminationcontrol_in,
	seriesterminationcontrol_in,
	config_data_in,
	config_update,
	config_dqs_ena,
	config_io_ena,
	config_extra_io_ena,
	config_dqs_io_ena,
	config_clock_in,


	dll_delayctrl_in
);


input [7-1:0] dll_delayctrl_in;

input core_clock_in;
input reset_n_core_clock_in;
input fr_data_clock_in;
input fr_strobe_clock_in;
input hr_clock_in;

input write_strobe_clock_in;
input strobe_ena_hr_clock_in;
input strobe_ena_clock_in;
	input [2-1:0] capture_strobe_ena;
output capture_strobe_tracking;
inout [8-1:0] read_write_data_io;
input [2*8-1:0] write_oe_in;
inout strobe_io;
input [2-1:0] output_strobe_ena;
inout strobe_n_io;
input [2-1:0] oct_ena_in;
output [2 * 2 * 8-1:0] read_data_out;
output capture_strobe_out;
input [2 * 2 * 8-1:0] write_data_in;
input [2 * 2 * 1-1:0] extra_write_data_in;
output [1-1:0] extra_write_data_out;
input	[16-1:0] parallelterminationcontrol_in;
input	[16-1:0] seriesterminationcontrol_in;
input config_data_in;
input config_update;
input config_dqs_ena;
input [8-1:0] config_io_ena;
input [1-1:0] config_extra_io_ena;
input config_dqs_io_ena;
input config_clock_in;





`ifndef ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL
  `define ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL 1
`endif

parameter ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL = `ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL;



generate
if (ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL)
begin

	altdq_dqs2_abstract altdq_dqs2_inst (
		.core_clock_in( core_clock_in),
		.reset_n_core_clock_in (reset_n_core_clock_in),
		.fr_data_clock_in (fr_data_clock_in),
		.fr_strobe_clock_in (fr_strobe_clock_in),
		.fr_clock_in( ),
		.hr_clock_in( hr_clock_in),
		.dr_clock_in( ),
		.write_strobe_clock_in (write_strobe_clock_in),
		.strobe_ena_hr_clock_in( strobe_ena_hr_clock_in),
		.strobe_ena_clock_in( strobe_ena_clock_in),
		.capture_strobe_ena( capture_strobe_ena),
		.capture_strobe_tracking (capture_strobe_tracking),
		.read_write_data_io( read_write_data_io),
		.write_oe_in( write_oe_in),
		.read_data_in( ),
		.write_data_out( ),
		.strobe_io( strobe_io),
		.output_strobe_ena( output_strobe_ena),
    .output_strobe_out(),
    .output_strobe_n_out(),
    .capture_strobe_in(),
    .capture_strobe_n_in(),
		.strobe_n_io( strobe_n_io),


		.corerankselectwritein(),
		.corerankselectreadin(),
		.coredqsenabledelayctrlin(),
		.coredqsdisablendelayctrlin(),
		.coremultirankdelayctrlin(),
		.oct_ena_in( oct_ena_in),
		.read_data_out( read_data_out),
		.capture_strobe_out( capture_strobe_out),
		.write_data_in( write_data_in),
		.extra_write_data_in( extra_write_data_in),
		.extra_write_data_out( extra_write_data_out),
		.parallelterminationcontrol_in( parallelterminationcontrol_in),
		.seriesterminationcontrol_in( seriesterminationcontrol_in),
		.config_data_in( config_data_in),
		.config_update( config_update),
		.config_dqs_ena( config_dqs_ena),
		.config_io_ena( config_io_ena),
		.config_extra_io_ena( config_extra_io_ena),
		.config_dqs_io_ena( config_dqs_io_ena),
		.config_clock_in( config_clock_in),
		.dll_offsetdelay_in (),

		.lfifo_rden(1'b0),
		.vfifo_qvld(1'b0),
		.rfifo_reset_n(1'b0),

		.dll_delayctrl_in(dll_delayctrl_in)

	);
	defparam altdq_dqs2_inst.PIN_WIDTH = 8;
	defparam altdq_dqs2_inst.PIN_TYPE = "bidir";
	defparam altdq_dqs2_inst.USE_INPUT_PHASE_ALIGNMENT = "false";
	defparam altdq_dqs2_inst.USE_OUTPUT_PHASE_ALIGNMENT = "true";
	defparam altdq_dqs2_inst.USE_LDC_AS_LOW_SKEW_CLOCK = "false";
	defparam altdq_dqs2_inst.OUTPUT_DQS_PHASE_SETTING = 0;
	defparam altdq_dqs2_inst.OUTPUT_DQ_PHASE_SETTING = 0;
	defparam altdq_dqs2_inst.USE_HALF_RATE_INPUT = "false";
	defparam altdq_dqs2_inst.USE_HALF_RATE_OUTPUT = "true";
	defparam altdq_dqs2_inst.DIFFERENTIAL_CAPTURE_STROBE = "true";
	defparam altdq_dqs2_inst.SEPARATE_CAPTURE_STROBE = "false";
	defparam altdq_dqs2_inst.INPUT_FREQ = 800.0;
	defparam altdq_dqs2_inst.INPUT_FREQ_PS = "1250 ps";
	defparam altdq_dqs2_inst.DELAY_CHAIN_BUFFER_MODE = "high";
	defparam altdq_dqs2_inst.DQS_PHASE_SETTING = 2;
	defparam altdq_dqs2_inst.DQS_PHASE_SHIFT = 9000;
	defparam altdq_dqs2_inst.DQS_ENABLE_PHASE_SETTING = 0;
	defparam altdq_dqs2_inst.USE_DYNAMIC_CONFIG = "true";
	defparam altdq_dqs2_inst.INVERT_CAPTURE_STROBE = "true";
	defparam altdq_dqs2_inst.SWAP_CAPTURE_STROBE_POLARITY = "false";
	defparam altdq_dqs2_inst.EXTRA_OUTPUTS_USE_SEPARATE_GROUP = "false";
	defparam altdq_dqs2_inst.USE_TERMINATION_CONTROL = "true";
	defparam altdq_dqs2_inst.USE_DQS_ENABLE = "true";
	defparam altdq_dqs2_inst.USE_OUTPUT_STROBE = "true";
	defparam altdq_dqs2_inst.USE_OUTPUT_STROBE_RESET = "false";
	defparam altdq_dqs2_inst.DIFFERENTIAL_OUTPUT_STROBE = "true";
	defparam altdq_dqs2_inst.USE_BIDIR_STROBE = "true";
	defparam altdq_dqs2_inst.REVERSE_READ_WORDS = "false";
	defparam altdq_dqs2_inst.EXTRA_OUTPUT_WIDTH = 1;
	defparam altdq_dqs2_inst.DYNAMIC_MODE = "dynamic";
	defparam altdq_dqs2_inst.OCT_SERIES_TERM_CONTROL_WIDTH   = 16; 
	defparam altdq_dqs2_inst.OCT_PARALLEL_TERM_CONTROL_WIDTH = 16; 
	defparam altdq_dqs2_inst.DLL_WIDTH = 7;
	defparam altdq_dqs2_inst.USE_DATA_OE_FOR_OCT = "false";
	defparam altdq_dqs2_inst.DQS_ENABLE_WIDTH = 2;
	defparam altdq_dqs2_inst.USE_OCT_ENA_IN_FOR_OCT = "true";
	defparam altdq_dqs2_inst.PREAMBLE_TYPE = "high";
	defparam altdq_dqs2_inst.EMIF_UNALIGNED_PREAMBLE_SUPPORT = "false";
	defparam altdq_dqs2_inst.EMIF_BYPASS_OCT_DDIO = "false";
	defparam altdq_dqs2_inst.USE_OFFSET_CTRL = "false";
	defparam altdq_dqs2_inst.HR_DDIO_OUT_HAS_THREE_REGS = "false";
	defparam altdq_dqs2_inst.DQS_ENABLE_PHASECTRL = "true";
	defparam altdq_dqs2_inst.USE_2X_FF = "false";
	defparam altdq_dqs2_inst.DLL_USE_2X_CLK = "false";
	defparam altdq_dqs2_inst.USE_DQS_TRACKING = "true";
	defparam altdq_dqs2_inst.USE_HARD_FIFOS = "false";
	defparam altdq_dqs2_inst.CALIBRATION_SUPPORT = "false";
	defparam altdq_dqs2_inst.DQS_ENABLE_AFTER_T7 = "false";
	defparam altdq_dqs2_inst.DELAY_CHAIN_WIDTH = 8;	 
	defparam altdq_dqs2_inst.USE_SHADOW_REGS = "false";
	defparam altdq_dqs2_inst.DUAL_WRITE_CLOCK = "true";

   
end
else 
begin


	altdq_dqs2_stratixv altdq_dqs2_inst (
		.reset_n_core_clock_in(reset_n_core_clock_in),
		.core_clock_in( core_clock_in),
		.fr_data_clock_in (fr_data_clock_in),
		.fr_strobe_clock_in (fr_strobe_clock_in),
		.fr_clock_in( ),
		.hr_clock_in( hr_clock_in),
		.dr_clock_in( ),
		.write_strobe_clock_in (write_strobe_clock_in),
		.strobe_ena_hr_clock_in( strobe_ena_hr_clock_in),
		.strobe_ena_clock_in( strobe_ena_clock_in),
		.capture_strobe_ena( capture_strobe_ena),
		.capture_strobe_tracking (capture_strobe_tracking),
		.read_write_data_io( read_write_data_io),
		.write_oe_in( write_oe_in),
		.read_data_in( ),
		.write_data_out( ),
		.strobe_io( strobe_io),
		.output_strobe_ena( output_strobe_ena),
    .output_strobe_out(),
    .output_strobe_n_out(),
    .capture_strobe_in(),
    .capture_strobe_n_in(),
		.strobe_n_io( strobe_n_io),


		.corerankselectwritein(),
		.corerankselectreadin(),
		.coredqsenabledelayctrlin(),
		.coredqsdisablendelayctrlin(),
		.coremultirankdelayctrlin(),
		.oct_ena_in( oct_ena_in),
		.read_data_out( read_data_out),
		.capture_strobe_out( capture_strobe_out),
		.write_data_in( write_data_in),
		.extra_write_data_in( extra_write_data_in),
		.extra_write_data_out( extra_write_data_out),
		.parallelterminationcontrol_in( parallelterminationcontrol_in),
		.seriesterminationcontrol_in( seriesterminationcontrol_in),
		.config_data_in( config_data_in),
		.config_update( config_update),
		.config_dqs_ena( config_dqs_ena),
		.config_io_ena( config_io_ena),
		.config_extra_io_ena( config_extra_io_ena),
		.config_dqs_io_ena( config_dqs_io_ena),
		.config_clock_in( config_clock_in),
		.dll_offsetdelay_in (),

		.lfifo_rden(1'b0),
		.vfifo_qvld(1'b0),
		.rfifo_reset_n(1'b0),

		.dll_delayctrl_in(dll_delayctrl_in)

	);
	defparam altdq_dqs2_inst.PIN_WIDTH = 8;
	defparam altdq_dqs2_inst.PIN_TYPE = "bidir";
	defparam altdq_dqs2_inst.USE_INPUT_PHASE_ALIGNMENT = "false";
	defparam altdq_dqs2_inst.USE_OUTPUT_PHASE_ALIGNMENT = "true";
	defparam altdq_dqs2_inst.USE_LDC_AS_LOW_SKEW_CLOCK = "false";
	defparam altdq_dqs2_inst.OUTPUT_DQS_PHASE_SETTING = 0;
	defparam altdq_dqs2_inst.OUTPUT_DQ_PHASE_SETTING = 0;
	defparam altdq_dqs2_inst.USE_HALF_RATE_INPUT = "false";
	defparam altdq_dqs2_inst.USE_HALF_RATE_OUTPUT = "true";
	defparam altdq_dqs2_inst.DIFFERENTIAL_CAPTURE_STROBE = "true";
	defparam altdq_dqs2_inst.SEPARATE_CAPTURE_STROBE = "false";
	defparam altdq_dqs2_inst.INPUT_FREQ = 800.0;
	defparam altdq_dqs2_inst.INPUT_FREQ_PS = "1250 ps";
	defparam altdq_dqs2_inst.DELAY_CHAIN_BUFFER_MODE = "high";
	defparam altdq_dqs2_inst.DQS_PHASE_SETTING = 2;
	defparam altdq_dqs2_inst.DQS_PHASE_SHIFT = 9000;
	defparam altdq_dqs2_inst.DQS_ENABLE_PHASE_SETTING = 0;
	defparam altdq_dqs2_inst.USE_DYNAMIC_CONFIG = "true";
	defparam altdq_dqs2_inst.INVERT_CAPTURE_STROBE = "true";
	defparam altdq_dqs2_inst.SWAP_CAPTURE_STROBE_POLARITY = "false";
	defparam altdq_dqs2_inst.EXTRA_OUTPUTS_USE_SEPARATE_GROUP = "false";
	defparam altdq_dqs2_inst.USE_TERMINATION_CONTROL = "true";
	defparam altdq_dqs2_inst.USE_DQS_ENABLE = "true";
	defparam altdq_dqs2_inst.USE_OUTPUT_STROBE = "true";
	defparam altdq_dqs2_inst.USE_OUTPUT_STROBE_RESET = "false";
	defparam altdq_dqs2_inst.DIFFERENTIAL_OUTPUT_STROBE = "true";
	defparam altdq_dqs2_inst.USE_BIDIR_STROBE = "true";
	defparam altdq_dqs2_inst.REVERSE_READ_WORDS = "false";
	defparam altdq_dqs2_inst.EXTRA_OUTPUT_WIDTH = 1;
	defparam altdq_dqs2_inst.DYNAMIC_MODE = "dynamic";
	defparam altdq_dqs2_inst.OCT_SERIES_TERM_CONTROL_WIDTH   = 16; 
	defparam altdq_dqs2_inst.OCT_PARALLEL_TERM_CONTROL_WIDTH = 16; 
	defparam altdq_dqs2_inst.DLL_WIDTH = 7;
	defparam altdq_dqs2_inst.USE_DATA_OE_FOR_OCT = "false";
	defparam altdq_dqs2_inst.DQS_ENABLE_WIDTH = 2;
	defparam altdq_dqs2_inst.USE_OCT_ENA_IN_FOR_OCT = "true";
	defparam altdq_dqs2_inst.PREAMBLE_TYPE = "high";
	defparam altdq_dqs2_inst.EMIF_UNALIGNED_PREAMBLE_SUPPORT = "false";
	defparam altdq_dqs2_inst.EMIF_BYPASS_OCT_DDIO = "false";
	defparam altdq_dqs2_inst.USE_OFFSET_CTRL = "false";
	defparam altdq_dqs2_inst.HR_DDIO_OUT_HAS_THREE_REGS = "false";
	defparam altdq_dqs2_inst.REGULAR_WRITE_BUS_ORDERING = "true";
	defparam altdq_dqs2_inst.DQS_ENABLE_PHASECTRL = "true";
	defparam altdq_dqs2_inst.USE_2X_FF = "false";
	defparam altdq_dqs2_inst.DLL_USE_2X_CLK = "false";
	defparam altdq_dqs2_inst.USE_DQS_TRACKING = "true";
	defparam altdq_dqs2_inst.CALIBRATION_SUPPORT = "false";
	defparam altdq_dqs2_inst.DQS_ENABLE_AFTER_T7 = "false";
	defparam altdq_dqs2_inst.DELAY_CHAIN_WIDTH = 8;	 
	defparam altdq_dqs2_inst.USE_HARD_FIFOS = "false";
	defparam altdq_dqs2_inst.USE_SHADOW_REGS = "false";
	defparam altdq_dqs2_inst.DUAL_WRITE_CLOCK = "true";

end
endgenerate


endmodule
