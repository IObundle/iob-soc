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


// *****************************************************************
// File name: simple_ddio_out.v
//
// This module can be used to double the data rate of the datain
// bus. Outputs at the dataout. Conversion is either done in soft
// logic or using hard ddio blocks in I/O periphery. 
//
// Example 1:
//
// datain = {T1, T0} at clk cycle x, where each Ty is a data item
// with width DATA_WIDTH
//
// dataout = {T0} at positive phase of clk cycle x
// dataout = {T1} at negative phase of clk cycle x
//
// In this case, set OUTPUT_FULL_DATA_WIDTH == DATA_WIDTH.
//
//
// Example 2:
//
// datain = {T3, T2, T1, T0} at clk cycle x, where each Ty is a data
// item with width DATA_WIDTH
//
// dataout = {T1, T0} at positive phase of clk cycle x
// dataout = {T3, T2} at negative phase of clk cycle x
//
// dataout can then be fed into another ddio_out stage for further
// rate doubling, as in example 1.
//
// Note that in this case, OUTPUT_FULL_DATA_WIDTH == 2 * DATA_WIDTH
//
// 
// Parameter Descriptions:
// =======================
//
// DATA_WIDTH - see examples above
//
// OUTPUT_FULL_DATA_WIDTH - see examples above
//
// USE_CORE_LOGIC   - specifies whether to use core logic, or to
// ("true"|"false")   use hard ddio_out blocks in the I/O periphery.
//
// HALF_RATE_MODE   - specifies whether the hard ddio_out is in 
// ("true"|"false")   "half-rate" mode or not. Only applicable
//                    when USE_CORE_LOGIC is "false".
// 
// REG_POST_RESET_HIGH  - specifies whether the ddio registers
// ("true"|"false")       should come out as logic-1 or logic-0 
//                        after reset.
//                                        
// REGISTER_OUTPUT   - Specifies whether the output is registered.
// ("true"|"false")    If "true", an extra FF (clocked by dr_clk
//                     and reset by dr_reset_n) is synthesized at
//                     the output. Only applicable when
//                     USE_CORE_LOGIC is "true".
//
// USE_EXTRA_OUTPUT_REG   - Specifies whether the soft logic structure
//                     generated resembles the Stratix IV 3 register
//                     structure. Only applicable when 
//                     USE_CORE_LOGIC is "true".
//
// *****************************************************************


`timescale 1 ps / 1 ps

module QDRII_SLAVE_p0_simple_ddio_out(
	clk,
	reset_n,
	dr_clk,
	dr_reset_n,
	datain,
	dataout
);

// *****************************************************************
// BEGIN PARAMETER SECTION

parameter DATA_WIDTH = ""; 
parameter OUTPUT_FULL_DATA_WIDTH = "";
parameter USE_CORE_LOGIC = "";
parameter REG_POST_RESET_HIGH = "false";
parameter HALF_RATE_MODE = "";             //only applicable when USE_CORE_LOGIC is "false"
parameter REGISTER_OUTPUT = "false";       //only applicable when USE_CORE_LOGIC is "true"
parameter USE_EXTRA_OUTPUT_REG = "false"; //only applicable when USE_CORE_LOGIC is "true"

localparam OUTPUT_WIDTH_MULT = OUTPUT_FULL_DATA_WIDTH / DATA_WIDTH;
localparam INPUT_WIDTH_MULT = OUTPUT_WIDTH_MULT * 2;
localparam INPUT_FULL_DATA_WIDTH = DATA_WIDTH * INPUT_WIDTH_MULT; 
localparam HARD_DDIO_ASYNC_MODE = (REG_POST_RESET_HIGH == "true") ? "preset" : "clear";
localparam HARD_DDIO_POWER_UP = (REG_POST_RESET_HIGH == "true") ? "high" : "low";

// END PARAMETER SECTION
// *****************************************************************

input	clk;
input	reset_n;
input	[INPUT_FULL_DATA_WIDTH-1:0] datain;
output	[OUTPUT_FULL_DATA_WIDTH-1:0] dataout;

input	dr_clk;     //only used when USE_CORE_LOGIC and REGISTER_OUTPUT are "true"
input	dr_reset_n; //only used when USE_CORE_LOGIC and REGISTER_OUTPUT are "true"

generate
genvar i, j, k;
if (USE_CORE_LOGIC == "true") begin
	//Use core logic to implement ddio_out.
	//This is always the 2-flop implementation regardless of HALF_RATE_MODE setting
	reg [INPUT_FULL_DATA_WIDTH-1:0] datain_r;
	reg [INPUT_FULL_DATA_WIDTH-1:0] datain_rr;
	always @(posedge clk or negedge reset_n)
	begin
		if (~reset_n) begin
			if (REG_POST_RESET_HIGH == "true")
				datain_r <= {INPUT_FULL_DATA_WIDTH{1'b1}};
			else
				datain_r <= {INPUT_FULL_DATA_WIDTH{1'b0}};
		end else begin
			datain_r <= datain;
		end
	end

	if (USE_EXTRA_OUTPUT_REG == "true") begin
		always @(negedge clk or negedge reset_n)
		begin
			if (~reset_n) begin
				if (REG_POST_RESET_HIGH == "true") begin
					datain_rr <= {INPUT_FULL_DATA_WIDTH{1'b1}};
				end
				else begin
					datain_rr <= {INPUT_FULL_DATA_WIDTH{1'b0}};
				end
			end else begin
				datain_rr <= datain_r;
			end
		end
	end

	wire [OUTPUT_FULL_DATA_WIDTH-1:0] dataout_wire;
	for (i=0; i<OUTPUT_WIDTH_MULT; i=i+1)
	begin: ddio_group
		for (j=0; j<DATA_WIDTH; j=j+1)
		begin: sig
			if (USE_EXTRA_OUTPUT_REG == "true") begin
				//wire delay is to avoid glitch during sim which makes things harder to see.
				//in reality glitches are unimportant as long as paths between output 
				//and next flop meet timing.		
				wire t0 = datain_r[i*DATA_WIDTH+j];
				wire #1 t1 = datain_rr[(i+OUTPUT_WIDTH_MULT)*DATA_WIDTH+j];
				wire #1 muxsel = clk; 
				
				//There's a timing path from from muxsel to the target FF fed by dataout.
				//If the clock signal driving muxsel is a global signal (which is likely),
				//he router won't try to insert delay to fix hold. We therefore insert
				//lcell buffers to help hold timing.
				
				wire muxsel_buff_out /* synthesis syn_noprune syn_preserve = 1 */;
				lcell muxsel_buff(.in(muxsel), .out(muxsel_buff_out)) /* synthesis syn_noprune syn_preserve = 1 */;
				assign dataout_wire[i*DATA_WIDTH+j] = (muxsel_buff_out == 1'b0) ? t0 : t1;
			end
			else begin
				//wire delay is to avoid glitch during sim which makes things harder to see.
				//in reality glitches are unimportant as long as paths between output 
				//and next flop meet timing.		
				wire t0 = datain_r[i*DATA_WIDTH+j];
				wire #1 t1 = datain_r[(i+OUTPUT_WIDTH_MULT)*DATA_WIDTH+j];
				wire #1 muxsel = clk; 
				
				//There's a timing path from from muxsel to the target FF fed by dataout.
				//If the clock signal driving muxsel is a global signal (which is likely),
				//he router won't try to insert delay to fix hold. We therefore insert
				//lcell buffers to help hold timing.
				
				wire muxsel_buff_out /* synthesis syn_noprune syn_preserve = 1 */;
				lcell muxsel_buff(.in(muxsel), .out(muxsel_buff_out)) /* synthesis syn_noprune syn_preserve = 1 */;
				assign dataout_wire[i*DATA_WIDTH+j] = (muxsel_buff_out == 1'b1) ? t0 : t1;
			end
		end
	end
	
	//register output if needed
	if (REGISTER_OUTPUT == "false") begin
		assign dataout = dataout_wire;
	end else begin
		reg [OUTPUT_FULL_DATA_WIDTH-1:0] dataout_r /* synthesis dont_merge syn_noprune syn_preserve = 1 */;
		always @(posedge dr_clk or negedge dr_reset_n)
		begin
			if (~dr_reset_n) begin
				if (REG_POST_RESET_HIGH == "true")
					dataout_r <= {OUTPUT_FULL_DATA_WIDTH{1'b1}};
				else
					dataout_r <= {OUTPUT_FULL_DATA_WIDTH{1'b0}};
			end else begin
				dataout_r <= dataout_wire;
			end
		end
		assign dataout = dataout_r;
	end
	
end else begin
	//Use ddio_out at the I/O periphery of the device
	for (i=0; i<OUTPUT_WIDTH_MULT; i=i+1)
	begin: ddio_group
		for (j=0; j<DATA_WIDTH; j=j+1)
		begin: sig				
			wire t0;
			wire t1;
			
			if (HALF_RATE_MODE == "true") begin
				assign t0 = datain[i*DATA_WIDTH+j];
				assign t1 = datain[(i+OUTPUT_WIDTH_MULT)*DATA_WIDTH+j];
			end else begin
				//hi lo inversion due to mux selection inversion
				assign t0 = datain[(i+OUTPUT_WIDTH_MULT)*DATA_WIDTH+j];
				assign t1 = datain[i*DATA_WIDTH+j];
			end
		
//NOTE that arriaiigx doesn't support half-rate ddio_out (arriaiigz does).
			stratixv_ddio_out ddio_o (
				.areset(~reset_n),
				.datainhi(t0),
				.datainlo(t1),
				.dataout(dataout[i*DATA_WIDTH+j]),
				.clkhi (clk),
				.clklo (clk),
				.muxsel (clk)
			);
			defparam
				ddio_o.use_new_clocking_model = "true",
				ddio_o.half_rate_mode = HALF_RATE_MODE,
				ddio_o.power_up = HARD_DDIO_POWER_UP,
				ddio_o.async_mode = HARD_DDIO_ASYNC_MODE;
		end
	end
end
endgenerate
endmodule

