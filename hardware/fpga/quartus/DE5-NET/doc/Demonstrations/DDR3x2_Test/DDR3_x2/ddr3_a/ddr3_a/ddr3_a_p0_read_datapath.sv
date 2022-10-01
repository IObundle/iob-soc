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
// File name: read_datapath.sv
// The read datapath is responsible for read data resynchronization from the memory clock domain to the AFI clock domain.
// It contains 1 FIFO per DQS group for read valid prediction and 1 FIFO per DQS group for read data synchronization.
// ******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

(* altera_attribute = "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF" *)

// altera message_off 10036 10030 10858
module ddr3_a_p0_read_datapath(
	reset_n_afi_clk,
	seq_read_fifo_reset,
	reset_n_resync_clk,
	pll_dqs_ena_clk,
	read_capture_clk,
	ddio_phy_dq,
	pll_afi_clk,
	pll_hr_clk,
	reset_n_hr_clk,
	pll_p2c_read_clk,
	reset_n_p2c_read_clk,
	seq_read_latency_counter,
	seq_read_increment_vfifo_fr,
	seq_read_increment_vfifo_hr,
	seq_read_increment_vfifo_qr,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata,
	phy_mux_read_fifo_q,
	force_oct_off,
	dqs_enable_ctrl,
	afi_rdata_valid,
	seq_calib_init
);

// ********************************************************************************************************************************
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from higher level wrapper with the controller and driver

parameter DEVICE_FAMILY = "";

// PHY-Memory Interface
parameter MEM_ADDRESS_WIDTH     = "";
parameter MEM_DM_WIDTH          = "";
parameter MEM_CONTROL_WIDTH     = "";
parameter MEM_DQ_WIDTH          = "";
parameter MEM_READ_DQS_WIDTH    = "";
parameter MEM_WRITE_DQS_WIDTH   = "";

// PHY-Controller (AFI) Interface
parameter AFI_ADDRESS_WIDTH         = "";
parameter AFI_DATA_MASK_WIDTH       = "";
parameter AFI_CONTROL_WIDTH         = "";
parameter AFI_DATA_WIDTH            = "";
parameter AFI_DQS_WIDTH             = "";
parameter AFI_RATE_RATIO            = "";

// Read Datapath
parameter MAX_LATENCY_COUNT_WIDTH          = "";
parameter MAX_READ_LATENCY                 = "";
parameter READ_FIFO_READ_MEM_DEPTH         = "";
parameter READ_FIFO_READ_ADDR_WIDTH        = "";
parameter READ_FIFO_WRITE_MEM_DEPTH        = "";
parameter READ_FIFO_WRITE_ADDR_WIDTH       = "";
parameter READ_VALID_FIFO_SIZE             = "";
parameter READ_VALID_FIFO_READ_MEM_DEPTH   = "";
parameter READ_VALID_FIFO_READ_ADDR_WIDTH  = "";
parameter READ_VALID_FIFO_WRITE_MEM_DEPTH  = "";
parameter READ_VALID_FIFO_WRITE_ADDR_WIDTH = "";
parameter READ_VALID_FIFO_PER_DQS_WIDTH    = "";
parameter NUM_SUBGROUP_PER_READ_DQS        = "";
parameter MEM_T_RL                         = "";
parameter QVLD_EXTRA_FLOP_STAGES           = "";
parameter QVLD_WR_ADDRESS_OFFSET           = "";
parameter REGISTER_C2P                     = "";
parameter VFIFO_C2P_PIPELINE_DEPTH         = 1;

// Width of the calibration status register used to control calibration skipping.
parameter CALIB_REG_WIDTH                  = "";
parameter FAST_SIM_MODEL                   = "";

parameter EXTRA_VFIFO_SHIFT                = 0;

localparam EXTRA_VFIFO_SHIFT_INT		   = EXTRA_VFIFO_SHIFT;

// Local parameters
localparam MAKE_FIFOS_IN_ALTDQDQS = "false";

localparam DOUBLE_MEM_DQ_WIDTH = MEM_DQ_WIDTH * 2;
localparam DDIO_PHY_DQ_WIDTH = DOUBLE_MEM_DQ_WIDTH;
localparam DQ_GROUP_WIDTH = MEM_DQ_WIDTH / MEM_READ_DQS_WIDTH;
localparam USE_NUM_SUBGROUP_PER_READ_DQS = FAST_SIM_MODEL ? 1 : NUM_SUBGROUP_PER_READ_DQS;
localparam AFI_DQ_GROUP_DATA_WIDTH = AFI_DATA_WIDTH / MEM_READ_DQS_WIDTH;
localparam DDIO_DQ_GROUP_DATA_WIDTH = DDIO_PHY_DQ_WIDTH / MEM_READ_DQS_WIDTH;
localparam DDIO_DQ_GROUP_DATA_WIDTH_SUBGROUP = DDIO_PHY_DQ_WIDTH / (MEM_READ_DQS_WIDTH * USE_NUM_SUBGROUP_PER_READ_DQS);
localparam QVLD_SHIFTER_LENGTH = (2 ** READ_VALID_FIFO_WRITE_ADDR_WIDTH) + QVLD_EXTRA_FLOP_STAGES;

// Register the LFIFO outputs on a per-group basis to help setup
// from core to hard read fifos. These transfers are half-rate
// and so can run at 400MHz+ in quarter rate PHYs.
localparam REGISTER_LFIFO_OUTPUTS_PER_GROUP = "true";

// To help timing we ensure the launch and latch clock to be
// the same (same PLL, same clock network, etc to maximize common
// clock path). At quarter-rate this requires registering the
// read fifo output using the same half-rate clock as the launch
// clock, before transferring to the AFI domain.
localparam REGISTER_P2C = "true";

localparam VFIFO_RATE_MULT = 4;

localparam READ_FIFO_DQ_GROUP_OUTPUT_WIDTH = 4 * DQ_GROUP_WIDTH;

localparam RD_VALID_LFIFO_WIDTH = AFI_RATE_RATIO;
localparam RD_ENABLE_LFIFO_WIDTH = 2;



localparam OCT_ON_DELAY = (MEM_T_RL > 4) ? ((MEM_T_RL - 4) / 4) : 0;
localparam OCT_OFF_DELAY = (MEM_T_RL + 8) / 4;

// END PARAMETER SECTION
// ******************************************************************************************************************************** 

input	reset_n_afi_clk;
input	[MEM_READ_DQS_WIDTH-1:0] seq_read_fifo_reset; // reset from sequencer to read and write pointers of the data resynchronization FIFO
input	[MEM_READ_DQS_WIDTH-1:0] read_capture_clk;
input	reset_n_resync_clk;
input	pll_dqs_ena_clk;
input	[DDIO_PHY_DQ_WIDTH-1:0] ddio_phy_dq;
input	pll_afi_clk;
input	pll_hr_clk;
input	reset_n_hr_clk;
input	pll_p2c_read_clk;
input	reset_n_p2c_read_clk;
input	[MAX_LATENCY_COUNT_WIDTH-1:0] seq_read_latency_counter;
input	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_fr;	// increment valid prediction FIFO write pointer by an extra full rate cycle
input	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_hr;	// increment valid prediction FIFO write pointer by an extra half rate cycle
																// in full rate core, both will mean an extra full rate cycle
input	[MEM_READ_DQS_WIDTH-1:0] seq_read_increment_vfifo_qr;	// increment valid prediction FIFO write pointer by an extra quarter rate cycle.
																// not used in full/half rate core

input	[AFI_RATE_RATIO-1:0] afi_rdata_en;
input	[AFI_RATE_RATIO-1:0] afi_rdata_en_full;


output	[AFI_DATA_WIDTH-1:0] afi_rdata;
output	[AFI_RATE_RATIO-1:0] afi_rdata_valid;

// read data (no reordering) for indepedently FIFO calibrations (multiple FIFOs for multiple DQS groups)
output	[AFI_DATA_WIDTH-1:0] phy_mux_read_fifo_q;

output	[AFI_DQS_WIDTH-1:0] force_oct_off;
output  [MEM_READ_DQS_WIDTH*READ_VALID_FIFO_PER_DQS_WIDTH-1:0] dqs_enable_ctrl;


input	[CALIB_REG_WIDTH-1:0] seq_calib_init;


// Mark the following register as a keeper because the pin_map.tcl
// script uses it as anchor for finding the AFI clock
reg		[AFI_RATE_RATIO-1:0] afi_rdata_valid /* synthesis dont_merge syn_noprune syn_preserve = 1 */;

reg [1:0] qvld_num_fr_cycle_shift [MEM_READ_DQS_WIDTH-1:0];

wire    [MEM_READ_DQS_WIDTH*READ_VALID_FIFO_PER_DQS_WIDTH-1:0] qvld;
wire	[MEM_READ_DQS_WIDTH-1:0] read_valid [RD_VALID_LFIFO_WIDTH-1:0];
wire	[MEM_READ_DQS_WIDTH-1:0] read_enable;
wire	[MEM_READ_DQS_WIDTH-1:0] valid_predict_clk;
wire	[MEM_READ_DQS_WIDTH-1:0] reset_n_valid_predict_clk;
reg		[MEM_READ_DQS_WIDTH-1:0] reset_n_fifo_write_side /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
reg		[MEM_READ_DQS_WIDTH-1:0] reset_n_fifo_wraddress /* synthesis dont_merge syn_noprune syn_preserve = 1 */;

wire	[MEM_READ_DQS_WIDTH-1:0] read_capture_clk_pos;


wire	[(AFI_DATA_WIDTH/2)-1:0] read_fifo_output;
wire	read_fifo_read_clk = pll_p2c_read_clk;	
wire	reset_n_read_fifo_read_clk = reset_n_p2c_read_clk;

wire seq_calib_skip_vfifo = seq_calib_init[3];

wire [AFI_RATE_RATIO-1:0] afi_rdata_en_int;
wire [AFI_RATE_RATIO-1:0] afi_rdata_en_full_int;

generate
	genvar afi_phase;
	for (afi_phase=0; afi_phase<AFI_RATE_RATIO; ++afi_phase)
	begin : rdata_en
		wire curr_afi_rdata_en = afi_rdata_en[afi_phase];
		assign afi_rdata_en_full_int[afi_phase] = afi_rdata_en_full[afi_phase];

		if (EXTRA_VFIFO_SHIFT_INT >= 1) begin
			reg [EXTRA_VFIFO_SHIFT_INT-1:0] extra_vfifo_shift;
			wire [EXTRA_VFIFO_SHIFT_INT:0] 	extra_vfifo_shift_tmp = {extra_vfifo_shift, curr_afi_rdata_en};
			always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
			begin
				if (~reset_n_afi_clk) begin
					extra_vfifo_shift <= {EXTRA_VFIFO_SHIFT_INT{1'b0}};
				end
				else begin
					extra_vfifo_shift <= extra_vfifo_shift_tmp[EXTRA_VFIFO_SHIFT_INT-1:0];
				end
			end
			assign afi_rdata_en_int[afi_phase] = extra_vfifo_shift[EXTRA_VFIFO_SHIFT_INT-1];
		end else begin
			assign afi_rdata_en_int[afi_phase] = curr_afi_rdata_en;
		end
	end
endgenerate




wire [AFI_RATE_RATIO-1:0] afi_rdata_en_full_vfifo_int = afi_rdata_en_full_int;
wire [RD_ENABLE_LFIFO_WIDTH-1:0] afi_rdata_en_full_lfifo_int = {
	afi_rdata_en_full_int[2], 
	afi_rdata_en_full_int[0]
	};
wire [RD_VALID_LFIFO_WIDTH-1:0] afi_rdata_en_lfifo_int = {
	afi_rdata_en_int[2], 
	afi_rdata_en_int[2], 
	afi_rdata_en_int[0], 
	afi_rdata_en_int[0]
	};




// *******************************************************************************************************************
// VALID PREDICTION
// Read request (afi_rdata_en) is generated on the AFI clock domain (pll_afi_clk).
// Read data is captured on the read_capture_clk domain (output clock from I/O). 
// The purpose of valid prediction is to determine which read_capture_clk cycle valid data will be returned to the core
// after the request is issued on pll_afi_clk; this is essentially the latency between read request seen on 
// AFI interface and valid data available at the output of ALTDQ_DQS.
// The clock domain crossing between pll_afi_clk and read_capture_clk is handled by a FIFO (uread_valid_fifo).
// The pll_afi_clk controls the write side of the FIFO and the read_capture_clk controls the read side.
// The pll_afi_clk writes into the FIFO on every clock cycle.  When there is no read request, it writes a 0;
// when there is a read request, it writes a 1 (refer to as a token) into the FIFO.
// The read_capture_clk reads from the FIFO every clock cycle, whenever it reads a token, it means that valid data
// is available during that cycle.  Each token represents 1 cycle of valid data.
// In full rate, BL=2, 1 read results in 1 AFI cycle of valid data, controller asserts afi_rdata_en for 1 cycle
// In full rate, BL=4, 1 read results in 2 AFI cycles of valid data, controller asserts afi_rdata_en for 2 cycles
// In full rate, BL=8, 1 read results in 4 AFI cycles of valid data, controller asserts afi_rdata_en for 4 cycles
// In half rate, BL=2, not supported
// In half rate, BL=4, 1 read results in 1 AFI cycle of valid data, controller asserts afi_rdata_en for 1 cycle
// In half rate, BL=8, 1 read results in 2 AFI cycle of valid data, controller asserts afi_rdata_en for 2 cycles
// In full rate, 1 afi_rdata_en cycle = 1 token
// In half rate, 1 afi_rdata_en cycle = 2 tokens
//
// After reset is released, the relationship between the read and write pointers can be arbitrary.
// During calibration, the sequencer keeps incrementing the write pointer (both the sequencer and write pointer operates
// on pll_afi_clk) until the correct latency has been tuned.
// *******************************************************************************************************************

assign valid_predict_clk = {MEM_READ_DQS_WIDTH{pll_dqs_ena_clk}};
assign reset_n_valid_predict_clk = {MEM_READ_DQS_WIDTH{reset_n_resync_clk}};

generate
if (MAKE_FIFOS_IN_ALTDQDQS != "true")
begin
genvar dqsgroup, vfifo_i;
	for (dqsgroup=0; dqsgroup<MEM_READ_DQS_WIDTH; dqsgroup=dqsgroup+1)
	begin: read_valid_predict
	
		wire [VFIFO_RATE_MULT-1:0] vfifo_out_per_dqs;
		reg [READ_VALID_FIFO_WRITE_ADDR_WIDTH-1:0] qvld_wr_address;

`ifndef SYNTH_FOR_SIM
 		// synthesis translate_off
`endif
		wire [ceil_log2(READ_VALID_FIFO_SIZE)-1:0] qvld_wr_address_offset;
		assign qvld_wr_address_offset = QVLD_WR_ADDRESS_OFFSET;
`ifndef SYNTH_FOR_SIM
 		// synthesis translate_on
`endif
		
		wire qvld_increment_wr_address = seq_read_increment_vfifo_qr[dqsgroup];
		
		// In half rate, 1 afi_rdata_en_full cycle = 2 tokens, qvld_in[0] and qvld_in[1]
		// In 1/4 rate, 1 afi_rdata_en_full cycle = 4 tokens, qvld_in[0..3]
		// etc.
		// Tokens are written at AFI clock rate but read at full rate.
		// During calibration the latency needs to be tuned at full rate granularity.
		// For example, in half rate, in the base case, 1 afi_rdata_en_full will result
		// in two tokens in write address 0, that means read address 0 and read address 1
		// will both have tokens. If the sequencer request to increase the latency by
		// full rate cycle, the write side first writes 10 into write address 0, then
		// it writes 01 into write address 1; this means there are tokens in read
		// address 1 and read address 2.
		always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
		begin
			if (~reset_n_afi_clk) begin
	`ifndef SYNTH_FOR_SIM
				// synthesis translate_off
	`endif
				qvld_num_fr_cycle_shift[dqsgroup] <= (seq_calib_skip_vfifo) ? qvld_wr_address_offset[1:0] : 2'b00;
	`ifndef SYNTH_FOR_SIM
				// synthesis translate_on
				// synthesis read_comments_as_HDL on
				// qvld_num_fr_cycle_shift[dqsgroup] <= 2'b00;
				// synthesis read_comments_as_HDL off
	`endif
			end else begin
				if (seq_read_increment_vfifo_hr[dqsgroup] || seq_read_increment_vfifo_fr[dqsgroup]) begin
					qvld_num_fr_cycle_shift[dqsgroup] <= {seq_read_increment_vfifo_hr[dqsgroup], seq_read_increment_vfifo_fr[dqsgroup]};
				end else if (seq_read_increment_vfifo_qr[dqsgroup]) begin
					qvld_num_fr_cycle_shift[dqsgroup] <= 2'b00;
				end
			end
		end	

		wire [AFI_RATE_RATIO-1:0] qvld_in;



		ddr3_a_p0_fr_cycle_shifter uread_fr_cycle_shifter(
			.clk (pll_afi_clk),
			.reset_n (reset_n_afi_clk),
			.shift_by (qvld_num_fr_cycle_shift[dqsgroup]),
			.datain (afi_rdata_en_full_vfifo_int),
			.dataout (qvld_in));
		defparam uread_fr_cycle_shifter.DATA_WIDTH = 1;

		wire [AFI_RATE_RATIO-1:0] rank_in = '0;


		always @(posedge pll_afi_clk)
		begin
`ifndef SYNTH_FOR_SIM
			// synthesis translate_off
`endif
			if (~reset_n_afi_clk) begin
				qvld_wr_address <= (seq_calib_skip_vfifo) ? (qvld_wr_address_offset >> ceil_log2(AFI_RATE_RATIO)) : {READ_VALID_FIFO_WRITE_ADDR_WIDTH{1'b0}};
`ifndef SYNTH_FOR_SIM
			// synthesis translate_on
			// synthesis read_comments_as_HDL on
			// if (~reset_n_afi_clk) begin
			// 	qvld_wr_address <= {READ_VALID_FIFO_WRITE_ADDR_WIDTH{1'b0}};
			// synthesis read_comments_as_HDL off
`endif
			end else begin
				qvld_wr_address <= qvld_increment_wr_address ? (qvld_wr_address + 2'd1) : qvld_wr_address;
			end
		end

		// The valid-prediction FIFO is implemented as a shift-register
		for (vfifo_i=0; vfifo_i<VFIFO_RATE_MULT; vfifo_i=vfifo_i+1)
		begin: qvld_shifter_gen
			reg [QVLD_SHIFTER_LENGTH-1:0] qvld_shifter;

			always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
			begin
				if (~reset_n_afi_clk) begin
					qvld_shifter <= {QVLD_SHIFTER_LENGTH{1'b0}};
				end	else begin
					qvld_shifter <= {1'b0, qvld_shifter[QVLD_SHIFTER_LENGTH-1:1]};
					qvld_shifter[qvld_wr_address + QVLD_EXTRA_FLOP_STAGES] <= qvld_in[vfifo_i];
				end
		 	end
			
			assign vfifo_out_per_dqs[vfifo_i] = qvld_shifter[0];
		end

		// Convert QR valid-prediction signal into HR using soft logic
		wire [READ_VALID_FIFO_PER_DQS_WIDTH-1:0] qvld_per_dqs;
		
		wire vfifo_out_qr_to_hr_clk = pll_afi_clk;
		wire vfifo_out_qr_to_hr_reset_n = reset_n_afi_clk;
		wire vfifo_out_qr_to_hr_dr_clk = pll_hr_clk;
		wire vfifo_out_qr_to_hr_dr_reset_n = reset_n_hr_clk;
		
		ddr3_a_p0_simple_ddio_out	vfifo_out_qr_to_hr(
			.reset_n    (vfifo_out_qr_to_hr_reset_n),
			.clk        (vfifo_out_qr_to_hr_clk),
			.dr_clk     (vfifo_out_qr_to_hr_dr_clk),
			.dr_reset_n (vfifo_out_qr_to_hr_dr_reset_n),
			.datain     (vfifo_out_per_dqs),
			.dataout    (qvld_per_dqs)
			);
		defparam
			vfifo_out_qr_to_hr.REGISTER_OUTPUT = REGISTER_C2P,
			vfifo_out_qr_to_hr.OUTPUT_REGISTER_STAGES = VFIFO_C2P_PIPELINE_DEPTH,
			vfifo_out_qr_to_hr.DATA_WIDTH = 1,
			vfifo_out_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 2,
			vfifo_out_qr_to_hr.USE_CORE_LOGIC = "true",
			vfifo_out_qr_to_hr.REG_POST_RESET_HIGH = "false";		

		
		// Map per-dqs vfifo output bus to the per-interface vfifo output bus.
		for (vfifo_i=0; vfifo_i<READ_VALID_FIFO_PER_DQS_WIDTH; vfifo_i=vfifo_i+1)
		begin: map_qvld_per_dqs_to_qvld
			assign qvld[dqsgroup+(vfifo_i*MEM_READ_DQS_WIDTH)] = qvld_per_dqs[vfifo_i];
		end
	end
end
endgenerate

assign dqs_enable_ctrl = qvld;

reg [MAX_READ_LATENCY-1:0] latency_shifter [RD_VALID_LFIFO_WIDTH-1:0];
reg [MAX_READ_LATENCY-1:0] full_latency_shifter [RD_ENABLE_LFIFO_WIDTH-1:0];

generate
genvar rd_valid_lfifo_i, rd_enable_lfifo_i;
	for (rd_valid_lfifo_i=0; rd_valid_lfifo_i<RD_VALID_LFIFO_WIDTH; ++rd_valid_lfifo_i)
	begin : rd_valid_lfifo_gen
		always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
		begin

			if (~reset_n_afi_clk) begin
				latency_shifter[rd_valid_lfifo_i] <= {MAX_READ_LATENCY{1'b0}};
			
			end
			else begin
				latency_shifter[rd_valid_lfifo_i] <= {
					latency_shifter[rd_valid_lfifo_i][MAX_READ_LATENCY-2:0], 
					afi_rdata_en_lfifo_int[rd_valid_lfifo_i]};
			end
		end
	end
	
	for (rd_enable_lfifo_i=0; rd_enable_lfifo_i<RD_ENABLE_LFIFO_WIDTH; ++rd_enable_lfifo_i)
	begin : rd_enable_lfifo_gen
		always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
		begin

			if (~reset_n_afi_clk) begin
				full_latency_shifter[rd_enable_lfifo_i] <= {MAX_READ_LATENCY{1'b0}};
			end
			else begin
				full_latency_shifter[rd_enable_lfifo_i] <= {
					full_latency_shifter[rd_enable_lfifo_i][MAX_READ_LATENCY-2:0], 
					afi_rdata_en_full_lfifo_int[rd_enable_lfifo_i]};
			end
		end

	end
endgenerate

generate
if (MAKE_FIFOS_IN_ALTDQDQS != "true")
begin
	genvar dqs_count, subgroup, dq_count, timeslot, rd_valid_sel_count, rd_enable_sel_count;
	
	for (dqs_count=0; dqs_count<MEM_READ_DQS_WIDTH; dqs_count=dqs_count+1)
	begin: read_buffering


		always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
		begin
			if (~reset_n_afi_clk) begin
				reset_n_fifo_write_side[dqs_count] <= 1'b0;
				reset_n_fifo_wraddress[dqs_count] <= 1'b0;
			end
			else begin
				reset_n_fifo_write_side[dqs_count] <= ~seq_read_fifo_reset[dqs_count];
				reset_n_fifo_wraddress[dqs_count] <= ~seq_read_fifo_reset[dqs_count];
			end
		end

		wire [RD_ENABLE_LFIFO_WIDTH-1:0] read_enable_from_lfifo;
		wire [READ_FIFO_DQ_GROUP_OUTPUT_WIDTH-1:0] read_fifo_output_per_dqs;
		
		// Perform read data mapping from ddio_phy_dq to ddio_phy_dq_per_dqs.
		//
		// The ddio_phy_dq bus is the read data coming out of the DDIO, and so
		// is 2x the interface data width. The bus is ordered by DQS group
		// and sub-ordered by time slot:
		// 
		// D1_T1, D1_T0, D0_T1, D0_T0
		//
		// The ddio_phy_dq_per_dqs bus is a subset of the ddio_phy_dq bus that
		// is specific to the current DQS group. Like ddio_phy_dq, it's ordered
		// by time slot:
		//
		// D0_T1, D0_T0
		wire	[DDIO_DQ_GROUP_DATA_WIDTH-1:0] ddio_phy_dq_per_dqs;
		assign ddio_phy_dq_per_dqs = ddio_phy_dq[(DDIO_DQ_GROUP_DATA_WIDTH*(dqs_count+1)-1) : (DDIO_DQ_GROUP_DATA_WIDTH*dqs_count)];
		

		for (rd_valid_sel_count=0; rd_valid_sel_count<RD_VALID_LFIFO_WIDTH; ++rd_valid_sel_count)
		begin : rd_valid_lfifo_sel
			wire read_valid_from_lfifo;
			ddr3_a_p0_read_valid_selector uread_valid_selector(
				.reset_n		(reset_n_afi_clk),
				.pll_afi_clk		(pll_afi_clk),
				
				.latency_shifter	(latency_shifter[rd_valid_sel_count]),
				.latency_counter	(seq_read_latency_counter),
				.read_enable		(),
				.read_valid		(read_valid_from_lfifo)
			);
			defparam uread_valid_selector.MAX_LATENCY_COUNT_WIDTH = MAX_LATENCY_COUNT_WIDTH;
			
			if (REGISTER_LFIFO_OUTPUTS_PER_GROUP == "true") begin
				if (RD_ENABLE_LFIFO_WIDTH == 1) begin
					reg read_valid_r /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
					
					always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
					begin
						if (~reset_n_afi_clk)
							read_valid_r <= '0;
						else
							read_valid_r <= read_valid_from_lfifo;
					end
					assign read_valid[rd_valid_sel_count][dqs_count] = read_valid_r;
					
				end else begin
					
					reg read_valid_r /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
					reg read_valid_rr /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
					
					always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
					begin
						if (~reset_n_afi_clk) begin
							read_valid_r <= '0;
							read_valid_rr <= '0;
						end else begin
							read_valid_r <= read_valid_from_lfifo;
							read_valid_rr <= read_valid_r;
						end
					end
					assign read_valid[rd_valid_sel_count][dqs_count] = read_valid_rr;
				end
			end else begin
				assign read_valid[rd_valid_sel_count][dqs_count] = read_valid_from_lfifo;
			end			
		end
		
		for (rd_enable_sel_count=0; rd_enable_sel_count<RD_ENABLE_LFIFO_WIDTH; ++rd_enable_sel_count)
		begin : rd_enable_lfifo_sel
			ddr3_a_p0_read_valid_selector uread_valid_full_selector(
				.reset_n		(reset_n_afi_clk),
				.pll_afi_clk		(pll_afi_clk),
				.latency_shifter	(full_latency_shifter[rd_enable_sel_count]),
				.latency_counter	(seq_read_latency_counter),
				.read_enable		(read_enable_from_lfifo[rd_enable_sel_count]),
				.read_valid		()
			);
			defparam uread_valid_full_selector.MAX_LATENCY_COUNT_WIDTH = MAX_LATENCY_COUNT_WIDTH;
		end
		
		wire read_enable_one_bit;
		
		if (RD_ENABLE_LFIFO_WIDTH == 1) begin
			assign read_enable_one_bit = read_enable_from_lfifo[0];

		end else if (RD_ENABLE_LFIFO_WIDTH == 2) begin
			ddr3_a_p0_simple_ddio_out	read_enable_from_lfifo_qr_to_hr(
				.reset_n    (reset_n_afi_clk),
				.clk        (pll_afi_clk),
				.dr_clk     (1'b1),
				.dr_reset_n (1'b1),
				.datain     (read_enable_from_lfifo),
				.dataout    (read_enable_one_bit)
				);
			defparam
				read_enable_from_lfifo_qr_to_hr.REGISTER_OUTPUT = "false",
				read_enable_from_lfifo_qr_to_hr.DATA_WIDTH = 1,
				read_enable_from_lfifo_qr_to_hr.OUTPUT_FULL_DATA_WIDTH = 1,
				read_enable_from_lfifo_qr_to_hr.USE_CORE_LOGIC = "true",
				read_enable_from_lfifo_qr_to_hr.REG_POST_RESET_HIGH = "false";		
		end

		if (REGISTER_LFIFO_OUTPUTS_PER_GROUP == "true") begin
			reg read_enable_rr /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
			reg read_enable_r /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
		
			always @(posedge read_fifo_read_clk or negedge reset_n_read_fifo_read_clk)
			begin
				if (~reset_n_read_fifo_read_clk) begin
					read_enable_r <= '0;
					read_enable_rr <= '0;
				end else begin
					read_enable_r <= read_enable_one_bit;
					read_enable_rr <= read_enable_r;
				end
			end
		
			assign read_enable[dqs_count] = read_enable_rr;
		end else begin
			assign read_enable[dqs_count] = read_enable_one_bit;
		end

		wire [READ_FIFO_DQ_GROUP_OUTPUT_WIDTH-1:0] read_fifo_output_per_dqs_pr;

		assign read_capture_clk_pos[dqs_count] = read_capture_clk[dqs_count];
	

if (FAST_SIM_MODEL)
begin
		read_fifo_hard_abstract_ddrx_lpddrx uread_read_fifo_hard (
			.write_clk (~read_capture_clk_pos[dqs_count]),
			.read_clk(read_fifo_read_clk),
			.read_enable(read_enable[dqs_count]),
			.reset_n(reset_n_fifo_wraddress[dqs_count]),
			.datain(ddio_phy_dq_per_dqs),
			.dataout(read_fifo_output_per_dqs_pr)
		);
		defparam uread_read_fifo_hard.DQ_GROUP_WIDTH = DQ_GROUP_WIDTH;
end
else
begin
		ddr3_a_p0_read_fifo_hard uread_read_fifo_hard (
			.write_clk (~read_capture_clk_pos[dqs_count]),
			.read_clk(read_fifo_read_clk),
			.read_enable(read_enable[dqs_count]),
			.reset_n(reset_n_fifo_wraddress[dqs_count]),
			.datain(ddio_phy_dq_per_dqs),
			.dataout(read_fifo_output_per_dqs_pr)
		);
		defparam uread_read_fifo_hard.DQ_GROUP_WIDTH = DQ_GROUP_WIDTH;
end

	if (REGISTER_P2C == "true") begin
		reg [READ_FIFO_DQ_GROUP_OUTPUT_WIDTH-1:0] read_fifo_output_per_dqs_r;
		always @(posedge read_fifo_read_clk) begin
			read_fifo_output_per_dqs_r <= read_fifo_output_per_dqs_pr;
		end
		assign read_fifo_output_per_dqs = read_fifo_output_per_dqs_r;
	end else begin
		assign read_fifo_output_per_dqs = read_fifo_output_per_dqs_pr;
	end

		// Perform mapping from read_fifo_output_per_dqs to read_fifo_output
		//
		// The read_fifo_output_per_dqs bus is the read data coming out of the read FIFO.
		// It has the read data for the current dqs group. In FR, it has 2x the
		// width of a dqs group on the interface. In HR, it has 4x the width of
		// a dqs group on the interface. The bus is ordered by time slot:
		//
		// FR: D0_T1, D0_T0
		// HR: D0_T3, D0_T2, D0_T1, D0_T0
		//
		// The read_fifo_output bus is the read data from read fifo. In FR, it has
		// the same width as ddio_phy_dq (i.e. 2x interface width). In HR, it has
		// 4x the interface width. The bus is ordered by time slot and
		// sub-ordered by DQS group:
		//
		// FR: D1_T1, D0_T1, D1_T0, D0_T0
		// HR: D1_T3, D0_T3, D1_T2, D0_T2, D1_T1, D0_T1, D1_T0, D0_T0
		//
		for (timeslot=0; timeslot<4; timeslot=timeslot+1)
		begin: read_mapping_timeslot
			wire [DQ_GROUP_WIDTH-1:0] rdata = read_fifo_output_per_dqs[DQ_GROUP_WIDTH * (timeslot + 1) - 1 : DQ_GROUP_WIDTH * timeslot];
			assign read_fifo_output[DQ_GROUP_WIDTH * (dqs_count + 1) + MEM_DQ_WIDTH * timeslot - 1 : DQ_GROUP_WIDTH * dqs_count + MEM_DQ_WIDTH * timeslot] = rdata;
		end
	end
	end else begin
	// Read FIFOS are instantiated in ALTDQDQS. Just pass through to afi_rdata.
		genvar dqs_count, timeslot, vsel_count;
		for (dqs_count=0; dqs_count<MEM_READ_DQS_WIDTH; dqs_count=dqs_count+1)
		begin: read_mapping_dqsgroup
			wire [DDIO_DQ_GROUP_DATA_WIDTH-1:0] ddio_phy_dq_per_dqs;
			assign ddio_phy_dq_per_dqs = ddio_phy_dq[(DDIO_DQ_GROUP_DATA_WIDTH*(dqs_count+1)-1) : (DDIO_DQ_GROUP_DATA_WIDTH*dqs_count)];
			for (timeslot=0; timeslot<4; timeslot=timeslot+1)
			begin: read_mapping_timeslot
				wire [DQ_GROUP_WIDTH-1:0] rdata = ddio_phy_dq_per_dqs[DQ_GROUP_WIDTH * (timeslot + 1) - 1 : DQ_GROUP_WIDTH * timeslot];
				assign read_fifo_output[MEM_DQ_WIDTH * timeslot + DQ_GROUP_WIDTH * (dqs_count + 1) - 1 : MEM_DQ_WIDTH * timeslot + DQ_GROUP_WIDTH * dqs_count] = rdata;
			end
		end
		
		for (vsel_count=0; vsel_count < RD_VALID_LFIFO_WIDTH; ++vsel_count)
		begin: vsel_gen
			for (dqs_count=0; dqs_count<MEM_READ_DQS_WIDTH; dqs_count=dqs_count+1)
				begin: read_buffering
					ddr3_a_p0_read_valid_selector uread_valid_selector(
						.reset_n		(reset_n_afi_clk),
						.pll_afi_clk		(pll_afi_clk),
						.latency_shifter	(latency_shifter[vsel_count]),
						.latency_counter	(seq_read_latency_counter),
						.read_enable		(),
						.read_valid		(read_valid[vsel_count][dqs_count])
					);
					defparam uread_valid_selector.MAX_LATENCY_COUNT_WIDTH = MAX_LATENCY_COUNT_WIDTH;
			end
		end
	end
endgenerate

// Perform HR-SDR to QR-SDR conversion using soft logic. The QR-SDR data is
// synchronous to the AFI clock and is sent directly to the afi_rdata bus.
// No need to reset the flops since data validity is communicated via the
// signal.

reg [(AFI_DATA_WIDTH/2)-1:0] read_fifo_output_h_r;
reg [(AFI_DATA_WIDTH/2)-1:0] read_fifo_output_l_r;
reg [(AFI_DATA_WIDTH/2)-1:0] read_fifo_output_l_rr;

always @(posedge pll_afi_clk) 
begin
	read_fifo_output_h_r <= read_fifo_output;
	read_fifo_output_l_rr <= read_fifo_output_l_r;
end

always @(negedge pll_afi_clk)
begin
	read_fifo_output_l_r <= read_fifo_output;
end

assign afi_rdata = {read_fifo_output_h_r, read_fifo_output_l_rr};



// Perform data re-mapping from afi_rdata to phy_mux_read_fifo_q
//
// The afi_rdata bus is the read data going out to the AFI. In FR, it has
// the same width as ddio_phy_dq (i.e. 2x interface width). In HR, it has
// 4x the interface width. The bus is ordered by time slot and
// sub-ordered by DQS group:
//
// FR: D1_T1, D0_T1, D1_T0, D0_T0
// HR: D1_T3, D0_T3, D1_T2, D0_T2, D1_T1, D0_T1, D1_T0, D0_T0
//
// The phy_mux_read_fifo_q bus is the read data going into the sequencer
// for calibration. It has the same width as afi_rdata. The bus is ordered
// by DQS group, and sub-ordered by time slot:
//
// FR: D1_T1, D1_T0, D0_T1, D0_T0
// HR: D1_T3, D1_T2, D1_T1, D1_T0, D0_T3, D0_T2, D0_T1, D0_T0
//
//As of Nov 1 2010, the NIOS sequencer doesn't use the phy_mux_read_fifo_q signal.
generate 
genvar k, t;
	for (k=0; k<MEM_READ_DQS_WIDTH; k=k+1)
	begin: read_mapping_for_seq
		wire [AFI_DQ_GROUP_DATA_WIDTH-1:0] rdata_per_dqs_group;

		for (t=0; t<AFI_RATE_RATIO*2; t=t+1)
		begin: build_rdata_per_dqs_group
			wire [DQ_GROUP_WIDTH-1:0] rdata_t = afi_rdata[DQ_GROUP_WIDTH * (k+1) + MEM_DQ_WIDTH * t - 1 : DQ_GROUP_WIDTH * k + MEM_DQ_WIDTH * t];
			assign rdata_per_dqs_group[(t+1)*DQ_GROUP_WIDTH-1:t*DQ_GROUP_WIDTH] = rdata_t;
		end
		assign phy_mux_read_fifo_q[(k+1)*AFI_DQ_GROUP_DATA_WIDTH-1 : k*AFI_DQ_GROUP_DATA_WIDTH] = rdata_per_dqs_group;
	end
endgenerate

// Generate an AFI read valid signal from all the read valid signals from all FIFOs

generate
	genvar afi_phase_i;
	for (afi_phase_i = 0; afi_phase_i < AFI_RATE_RATIO; ++afi_phase_i)
	begin : afi_rdata_valid_gen
		wire read_valid_all_groups = &(read_valid[afi_phase_i]);
		
		if (REGISTER_P2C == "true") begin
			reg rdata_valid_r;
			always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
			begin
				if (~reset_n_afi_clk) begin
					rdata_valid_r <= 1'b0;
					afi_rdata_valid[afi_phase_i] <= 1'b0;
				end else begin
					rdata_valid_r <= read_valid_all_groups;
					afi_rdata_valid[afi_phase_i] <= rdata_valid_r;
				end
			end
		end else begin
			always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
			begin
				if (~reset_n_afi_clk) begin
					afi_rdata_valid[afi_phase_i] <= 1'b0;
				end else begin
					afi_rdata_valid[afi_phase_i] <= read_valid_all_groups;
				end
			end
		end
	end
endgenerate

reg		[AFI_DQS_WIDTH-1:0] force_oct_off;

generate
genvar oct_num;
for (oct_num = 0; oct_num < AFI_DQS_WIDTH; oct_num = oct_num + 1)
begin : oct_gen
	reg		[OCT_OFF_DELAY-1:0] rdata_en_r /* synthesis dont_merge */;
	wire [OCT_OFF_DELAY:0] rdata_en_shifter;

	assign rdata_en_shifter = {rdata_en_r,|afi_rdata_en_full_lfifo_int};
	always @(posedge pll_afi_clk or negedge reset_n_afi_clk)
	begin
		if (~reset_n_afi_clk)
		begin
			rdata_en_r <= {OCT_OFF_DELAY{1'b0}};
			force_oct_off[oct_num] <= 1'b0;
		end
		else
		begin
			rdata_en_r <= {rdata_en_r[OCT_OFF_DELAY-2:0],|afi_rdata_en_full_lfifo_int};
			force_oct_off[oct_num] <= ~(|rdata_en_shifter[OCT_OFF_DELAY:OCT_ON_DELAY]);
		end
	end
end
endgenerate


// Calculate the ceiling of log_2 of the input value
function integer ceil_log2;
	input integer value;
	begin
		value = value - 1;
		for (ceil_log2 = 0; value > 0; ceil_log2 = ceil_log2 + 1)
			value = value >> 1;
	end
endfunction

endmodule
