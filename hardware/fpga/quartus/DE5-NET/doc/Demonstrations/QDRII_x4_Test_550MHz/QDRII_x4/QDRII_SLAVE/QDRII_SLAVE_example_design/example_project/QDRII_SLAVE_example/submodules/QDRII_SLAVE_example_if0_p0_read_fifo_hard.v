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
// File name: read_fifo_hard.v
// The read fifo is responsible for read data resynchronization from the memory clock domain to the internal clock domain.
// The file instantiates family-specific hard read FIFO blocks that are located in the I/O periphery.
// Each read_fifo_hard instantiation handles a DQS group.
// This module is only used by UniPHY if the device family supports read FIFO at the I/O periphery.
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

module QDRII_SLAVE_example_if0_p0_read_fifo_hard(
	write_clk,
	write_enable,
	write_enable_clk,
	reset_n_write_enable_clk,
	read_clk,
	read_enable,
	reset_n,
	datain,
	dataout
);

// ******************************************************************************************************************************** 
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from higher level wrapper with the controller and driver 

parameter DQ_GROUP_WIDTH = "";

localparam RATE_MULT = 2;

localparam WRITE_ENABLE_WIDTH = RATE_MULT;

// END PARAMETER SECTION
// ******************************************************************************************************************************** 

input	write_clk;
input	[WRITE_ENABLE_WIDTH-1:0] write_enable;
input	write_enable_clk;
input	reset_n_write_enable_clk;	
input	read_clk;
input	read_enable;
input	reset_n;
input	[DQ_GROUP_WIDTH*2-1:0] datain;
output	[RATE_MULT*DQ_GROUP_WIDTH*2-1:0] dataout;


// ******************************************************************************************************************************** 
// Instantiate write-enable circuitry inside the DQS logic block
// ******************************************************************************************************************************** 

// The read_clk is always running, so wren is used to make sure
// that only valid data is written into the data fifo. The wren ddio_out
// is per-dqs-group, and will be packed into the DQS logic block of the
// respective DQS group by the fitter.	
wire wren;
QDRII_SLAVE_example_if0_p0_simple_ddio_out hr_to_fr_wren (
	.reset_n(reset_n_write_enable_clk),
	.clk(write_enable_clk),
	.datain(write_enable),
	.dataout({wren})
);
defparam
	hr_to_fr_wren.DATA_WIDTH = 1,
	hr_to_fr_wren.OUTPUT_FULL_DATA_WIDTH = 1,
	hr_to_fr_wren.USE_CORE_LOGIC = "false",
	hr_to_fr_wren.HALF_RATE_MODE = "true",
	hr_to_fr_wren.REG_POST_RESET_HIGH = "false";

// ******************************************************************************************************************************** 
// Instantiate read-enable circuitry inside the DQS logic block
// ******************************************************************************************************************************** 
wire read_enable_tmp;
wire plus2_tmp;
stratixv_read_fifo_read_enable fifo_read_enable (
	.re(read_enable),
	.rclk(),
	.plus2(1'b0), 
	.areset(),
	.reout (read_enable_tmp),
	.plus2out (plus2_tmp)
);
defparam fifo_read_enable.use_stalled_read_enable = "false";

// ******************************************************************************************************************************** 
// Instantiate hard read-fifo. 
// ******************************************************************************************************************************** 
generate
genvar dq_count;
	for (dq_count=0; dq_count<DQ_GROUP_WIDTH; dq_count=dq_count+1)
	begin:read_fifos
		// The datain bus is the read data for the current DQS group
		// coming out of the DDIO. Its width is 2x of each DQS group on the
		// memory interface. The bus is ordered by time slot:
		//
		// D0_T1, D0_T0
		//
		// The dataout bus is the read data going out of the FIFO. In FR, it has
		// the same width as datain. In HR, it 2x the datain width. The bus is
		// ordered by time slot.
		//
		// FR: D0_T1, D0_T0
		// HR: D0_T3, D0_T2, D0_T1, D0_T0
		stratixv_read_fifo fifo (
			.wclk(write_clk),
			.we(wren),
			.rclk(read_clk),
			.re(read_enable_tmp),
			.areset(~reset_n),
			.plus2(plus2_tmp),
			.datain({datain[dq_count], datain[dq_count + DQ_GROUP_WIDTH]}),
			.dataout({
					dataout[dq_count + (DQ_GROUP_WIDTH * 0)],
					dataout[dq_count + (DQ_GROUP_WIDTH * 1)],
					dataout[dq_count + (DQ_GROUP_WIDTH * 2)],
					dataout[dq_count + (DQ_GROUP_WIDTH * 3)]
								})
		);
		defparam fifo.use_half_rate_read = "true";
		defparam fifo.sim_wclk_pre_delay = 100;
	end
endgenerate

endmodule
