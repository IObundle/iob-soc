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

module altdq_dqs2_abstract (
	dll_delayctrl_in,
	dll_offsetdelay_in,
	capture_strobe_in,
	capture_strobe_n_in,
	capture_strobe_ena,
	capture_strobe_out,
	
	output_strobe_ena,
	output_strobe_out,
	output_strobe_n_out,
	oct_ena_in,
	strobe_io,
	strobe_n_io,
	
        external_ddio_capture_clock,
        external_fifo_capture_clock,

	reset_n_core_clock_in,
	core_clock_in,
	fr_clock_in,
	fr_data_clock_in,
	fr_strobe_clock_in,
	hr_clock_in,
	dr_clock_in,
	strobe_ena_hr_clock_in,
	strobe_ena_clock_in,
	write_strobe_clock_in,
	parallelterminationcontrol_in,
	seriesterminationcontrol_in,

	corerankselectwritein,
	corerankselectreadin,
	coredqsenabledelayctrlin,
	coredqsdisablendelayctrlin,
	coremultirankdelayctrlin,
	
	read_data_in,
	write_data_out,
	read_write_data_io,
		
	write_oe_in,
	read_data_out,
	write_data_in,
	extra_write_data_in,
	extra_write_data_out,
	capture_strobe_tracking,

	lfifo_rden,
	vfifo_qvld,
	rfifo_reset_n,

	config_data_in,
	config_dqs_ena,
	config_io_ena,
	config_extra_io_ena,
	config_dqs_io_ena,
	config_update,
	config_clock_in

);
	
parameter PIN_WIDTH = 8;
parameter PIN_TYPE = "bidir";

parameter USE_INPUT_PHASE_ALIGNMENT = "false";
parameter USE_OUTPUT_PHASE_ALIGNMENT = "false";
parameter USE_LDC_AS_LOW_SKEW_CLOCK = "false";
parameter OUTPUT_DQS_PHASE_SETTING = 0;
parameter OUTPUT_DQ_PHASE_SETTING = 0;

parameter USE_HALF_RATE_INPUT = "false";
parameter USE_HALF_RATE_OUTPUT = "false";

parameter DIFFERENTIAL_CAPTURE_STROBE = "false";
parameter SEPARATE_CAPTURE_STROBE = "false";

parameter INPUT_FREQ = 0.0;
parameter INPUT_FREQ_PS = "0 ps";
localparam HR_CLOCK_FREQ = (USE_HALF_RATE_OUTPUT == "true") ? INPUT_FREQ / 2 : INPUT_FREQ;
localparam FR_CLOCK_FREQ = INPUT_FREQ;

parameter DLL_USE_2X_CLK = "false";
parameter DELAY_CHAIN_BUFFER_MODE = "high";
parameter DQS_PHASE_SETTING = 3;
parameter DQS_PHASE_SHIFT = 9000;
localparam DEGREES_PER_PHASE_TAP_X100 = (DLL_USE_2X_CLK == "true") ? (DQS_PHASE_SHIFT / DQS_PHASE_SETTING * 2) : (DQS_PHASE_SHIFT / DQS_PHASE_SETTING);
localparam DEGREES_PER_PHASE_TAP = DEGREES_PER_PHASE_TAP_X100 / 100;
parameter DQS_ENABLE_PHASE_SETTING = 2;
parameter USE_DYNAMIC_CONFIG = "true";
parameter INVERT_CAPTURE_STROBE = "false";
parameter SWAP_CAPTURE_STROBE_POLARITY = "false";
parameter EXTRA_OUTPUTS_USE_SEPARATE_GROUP = "false";
parameter USE_TERMINATION_CONTROL = "false";
parameter USE_OCT_ENA_IN_FOR_OCT = "false";
parameter USE_DQS_ENABLE = "false";
parameter USE_IO_CONFIG = "false";
parameter USE_DQS_CONFIG = "false";

parameter USE_OFFSET_CTRL = "false";
parameter HR_DDIO_OUT_HAS_THREE_REGS = "true";

parameter USE_OUTPUT_STROBE = "true";
parameter DIFFERENTIAL_OUTPUT_STROBE = "false";
parameter USE_OUTPUT_STROBE_RESET = "true";
parameter USE_BIDIR_STROBE = "false";
parameter REVERSE_READ_WORDS = "false";

parameter EXTRA_OUTPUT_WIDTH = 0;
parameter PREAMBLE_TYPE = "none";
parameter USE_DATA_OE_FOR_OCT = "false";
parameter DQS_ENABLE_WIDTH = 1;
parameter EMIF_UNALIGNED_PREAMBLE_SUPPORT = "false";
parameter EMIF_BYPASS_OCT_DDIO = "false";

parameter USE_2X_FF = "false";
parameter USE_DQS_TRACKING = "false";
parameter DUAL_WRITE_CLOCK = "false";
parameter USE_HARD_FIFOS = "false";

parameter USE_SHADOW_REGS = "false";

localparam rate_mult_in = (USE_HALF_RATE_INPUT == "true") ? 4 : 2;
localparam rate_mult_out = (USE_HALF_RATE_OUTPUT == "true") ? 4 : 2;
localparam fpga_width_in = PIN_WIDTH * rate_mult_in;
localparam fpga_width_out = PIN_WIDTH * rate_mult_out;
localparam extra_fpga_width_out = EXTRA_OUTPUT_WIDTH * rate_mult_out;
localparam OS_ENA_WIDTH =  rate_mult_out / 2;
localparam WRITE_OE_WIDTH = PIN_WIDTH * rate_mult_out / 2;
parameter  DQS_ENABLE_PHASECTRL = "true";

parameter DYNAMIC_MODE = "dynamic";

parameter OCT_SERIES_TERM_CONTROL_WIDTH   = 16; 
parameter OCT_PARALLEL_TERM_CONTROL_WIDTH = 16; 
parameter DLL_WIDTH = 6;

parameter CALIBRATION_SUPPORT = "false";

parameter ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL = 0;

parameter DELAY_CHAIN_WIDTH = 0;

	 
parameter DQS_ENABLE_AFTER_T7 = "true";

parameter USE_CAPTURE_REG_EXTERNAL_CLOCKING = "false";
parameter USE_READ_FIFO_EXTERNAL_CLOCKING = "false";

input [DLL_WIDTH-1:0] dll_delayctrl_in;
input [DLL_WIDTH-1:0] dll_offsetdelay_in;

input reset_n_core_clock_in;
input core_clock_in;
input fr_clock_in;
input fr_data_clock_in;
input fr_strobe_clock_in;

input hr_clock_in;
input strobe_ena_hr_clock_in;
input strobe_ena_clock_in;
input write_strobe_clock_in;

input [PIN_WIDTH-1:0] read_data_in;
output [PIN_WIDTH-1:0] write_data_out;
inout [PIN_WIDTH-1:0] read_write_data_io;

input capture_strobe_in;
input capture_strobe_n_in;
input [DQS_ENABLE_WIDTH-1:0] capture_strobe_ena;

input [OS_ENA_WIDTH-1:0] output_strobe_ena;
output output_strobe_out;
output output_strobe_n_out;
input [1:0] oct_ena_in;
inout strobe_io;
inout strobe_n_io;

input external_ddio_capture_clock;
input external_fifo_capture_clock;

input corerankselectreadin;
input [1:0] corerankselectwritein;
input [DELAY_CHAIN_WIDTH-1:0] coredqsenabledelayctrlin;
input [DELAY_CHAIN_WIDTH-1:0] coredqsdisablendelayctrlin;
input [DELAY_CHAIN_WIDTH-1:0] coremultirankdelayctrlin;

output [fpga_width_out-1:0] read_data_out;
input [fpga_width_out-1:0] write_data_in;

input [WRITE_OE_WIDTH-1:0] write_oe_in;
output capture_strobe_out;

input [extra_fpga_width_out-1:0] extra_write_data_in;
output [EXTRA_OUTPUT_WIDTH-1:0] extra_write_data_out;

output capture_strobe_tracking;

input dr_clock_in;

input [OCT_PARALLEL_TERM_CONTROL_WIDTH-1:0] parallelterminationcontrol_in;
input [OCT_SERIES_TERM_CONTROL_WIDTH-1:0] seriesterminationcontrol_in;

input config_data_in;
input config_update;
input config_dqs_ena;
input [PIN_WIDTH-1:0] config_io_ena;
input [EXTRA_OUTPUT_WIDTH-1:0] config_extra_io_ena;
input config_dqs_io_ena;
input config_clock_in;

input lfifo_rden;
input vfifo_qvld;
input rfifo_reset_n;

function int phase_to_ps;
	input int clk_rate;
	input int deg;
	phase_to_ps = deg * (1000000) / clk_rate / 360;
endfunction

function int phasetap_to_ps;
	input int clk_rate;
	input int tap;
	begin
		phasetap_to_ps = phase_to_ps(clk_rate, tap * DEGREES_PER_PHASE_TAP);
	end
endfunction

const int shift_180_hr = phase_to_ps(HR_CLOCK_FREQ, 180);
const int shift_360_hr = phase_to_ps(HR_CLOCK_FREQ, 360);
const int shift_180_fr = phase_to_ps(FR_CLOCK_FREQ, 180);
const int shift_90_fr = phase_to_ps(FR_CLOCK_FREQ, 90);

localparam DELAY_WIDTH = 32;

wire [DELAY_WIDTH-1:0] opa_clock_delay;
wire [DELAY_WIDTH-1:0] dqs_in_busout_delay;
wire [DELAY_WIDTH-1:0] dqs_in_enable_on_delay;
wire [DELAY_WIDTH-1:0] dqs_in_enable_off_delay;
wire [DELAY_WIDTH-1:0] dqs_out_ptap_delay;
wire [DELAY_WIDTH-1:0] dqs_out_dtap_delay;
wire [DELAY_WIDTH-1:0] dq_out_ptap_delay;
wire [(PIN_WIDTH*DELAY_WIDTH)-1:0] dq_out_dtap_delay;
wire [(PIN_WIDTH*DELAY_WIDTH)-1:0] dq_in_dtap_delay;
wire [(PIN_WIDTH*DELAY_WIDTH)-1:0] extra_out_dtap_delay;

generate
if (USE_DYNAMIC_CONFIG == "true")
begin
	altdq_dqs2_cal_delays #(
		.CLOCK_FREQ(FR_CLOCK_FREQ),
		.PIN_WIDTH(PIN_WIDTH),
		.EXTRA_OUTPUT_WIDTH(EXTRA_OUTPUT_WIDTH),
		.DEGREES_PER_PHASE_TAP(DEGREES_PER_PHASE_TAP),
		.DELAY_WIDTH(DELAY_WIDTH),
		.DLL_USE_2X_CLK(DLL_USE_2X_CLK)
	) cal_delays_inst (
		.config_data_in(config_data_in),
		.config_update(config_update),
		.config_dqs_ena(config_dqs_ena),
		.config_io_ena(config_io_ena),
		.config_extra_io_ena(config_extra_io_ena),
		.config_dqs_io_ena(config_dqs_io_ena),
		.config_clock_in(config_clock_in),
	
		.opa_clock_delay(opa_clock_delay),
		.dqs_in_busout_delay(dqs_in_busout_delay),
		.dqs_in_enable_on_delay(dqs_in_enable_on_delay),
		.dqs_in_enable_off_delay(dqs_in_enable_off_delay),
		.dqs_out_ptap_delay(dqs_out_ptap_delay),
		.dqs_out_dtap_delay(dqs_out_dtap_delay),
		.dq_out_ptap_delay(dq_out_ptap_delay),
		.dq_out_dtap_delay(dq_out_dtap_delay),
		.dq_in_dtap_delay(dq_in_dtap_delay),
		.extra_out_dtap_delay(extra_out_dtap_delay)
	);
end
else
begin
	assign opa_clock_delay = 0;
	assign dqs_in_busout_delay = phase_to_ps(FR_CLOCK_FREQ, 90);
	assign dqs_in_enable_on_delay = phase_to_ps(FR_CLOCK_FREQ, 630);
	assign dqs_in_enable_off_delay = phase_to_ps(FR_CLOCK_FREQ, 630 - 180);
	assign dqs_out_ptap_delay = phase_to_ps(FR_CLOCK_FREQ, 420);
	assign dqs_out_dtap_delay = 0;
	assign dq_out_ptap_delay = phase_to_ps(FR_CLOCK_FREQ, 360);

	assign dq_out_dtap_delay = '0;
	assign dq_in_dtap_delay = '0;
	assign extra_out_dtap_delay = '0;
end				    
endgenerate

wire dqsbusout;
wire dqsnbusout;

generate
if (USE_BIDIR_STROBE == "true")
begin
	assign output_strobe_out = 1'b0;
	assign output_strobe_n_out = 1'b1;	
end
else
begin
	assign strobe_io = 1'b0;
	assign strobe_n_io = 1'b1;	
end
	
if (PIN_TYPE == "bidir")
	assign write_data_out = '0;
else
	assign read_write_data_io = '0;
endgenerate




generate 
	if (PIN_TYPE == "input" || PIN_TYPE == "bidir")
	begin: input_strobe

		wire capture_strobe_ena_fr;

		if (DQS_ENABLE_WIDTH > 1)
		begin
			reg capture_strobe_ena_fr_lo_reg = 0;
			reg capture_strobe_ena_fr_hi_reg = 0;
			
			always @(posedge strobe_ena_hr_clock_in)
			begin
				if (HR_DDIO_OUT_HAS_THREE_REGS == "true")
				begin
					capture_strobe_ena_fr_lo_reg <= #(shift_180_hr) capture_strobe_ena[1];
					capture_strobe_ena_fr_hi_reg <= capture_strobe_ena[0];
				end
				else
				begin
					capture_strobe_ena_fr_lo_reg <= capture_strobe_ena[0];
					capture_strobe_ena_fr_hi_reg <= capture_strobe_ena[1];
				end
			end
			assign capture_strobe_ena_fr = strobe_ena_hr_clock_in ? 
							capture_strobe_ena_fr_lo_reg : capture_strobe_ena_fr_hi_reg;
		end	
		else
		begin
			assign capture_strobe_ena_fr = capture_strobe_ena;
		end

		wire dqsin;

		if (USE_BIDIR_STROBE == "true") begin
			if (SWAP_CAPTURE_STROBE_POLARITY == "true") begin
				assign dqsin = strobe_n_io;
			end else begin
				assign dqsin = strobe_io;
			end
		end else begin
			if (SWAP_CAPTURE_STROBE_POLARITY == "true") begin
				assign dqsin = capture_strobe_n_in;
			end else begin
				assign dqsin = capture_strobe_in;				
			end
		end

		wire dqsin_shifted_preena;

		if (DQS_ENABLE_AFTER_T7 == "true")
		begin
			reg dqsin_shifted_preena_r = '0;
			always @(dqsin)
			begin
				dqsin_shifted_preena_r <= #(dqs_in_busout_delay) dqsin;
			end
			assign dqsin_shifted_preena = dqsin_shifted_preena_r;
		end
		else
		begin
			assign dqsin_shifted_preena = dqsin;
		end

		wire dqsbusout_preshift;

		if (USE_DQS_ENABLE == "true")
		begin

			wire dqs_enable;
			reg dqs_enable_on = 0;
			reg dqs_enable_off = 0;


			always @(posedge strobe_ena_clock_in)
			begin
				dqs_enable_on <= #(dqs_in_enable_on_delay) capture_strobe_ena_fr;
				dqs_enable_off <= #(dqs_in_enable_off_delay) capture_strobe_ena_fr;
			end

			assign dqs_enable = dqs_enable_on & dqs_enable_off;

			reg ena_reg = 1'b0;

			assign dqsbusout_preshift = ena_reg & dqsin_shifted_preena;

			always @(negedge dqsbusout_preshift or posedge dqs_enable)
			begin
				if (dqs_enable === 1'b1)
					ena_reg <= 1'b1;
				else
					ena_reg <= 1'b0;
			end

			if (USE_DQS_TRACKING == "true")
			begin
				reg dqs_ff;
				always @(negedge dqs_enable_off)
					dqs_ff <= dqsin;

				assign capture_strobe_tracking = dqs_ff;
			end
			
		end
		else
		begin
			assign dqsbusout_preshift = dqsin_shifted_preena;
		end
		
		if (DQS_ENABLE_AFTER_T7 != "true")
		begin
			reg dqsbusout_r;
			
			always @(dqsbusout_preshift)
			begin
				dqsbusout_r <= #(dqs_in_busout_delay) dqsbusout_preshift;
			end
			assign dqsbusout = dqsbusout_r;
		end
		else
		begin
			assign dqsbusout = dqsbusout_preshift;
		end

		if (SEPARATE_CAPTURE_STROBE == "true")
		begin
			assign dqsnbusout = dqsbusout;
		end

		assign capture_strobe_out = dqsbusout;
	end
endgenerate

generate
if (USE_OUTPUT_STROBE == "true")
begin: output_strobe
	wire os;
	wire os_bar;
	wire os_delayed1;
	wire os_delayed2;

	wire fr_os_oe;
	wire aligned_os_oe;
	wire aligned_strobe;
	
	wire fr_os_hi;
	wire fr_os_lo;


	if (USE_HALF_RATE_OUTPUT == "true")
	begin
		if (USE_BIDIR_STROBE == "true")
		begin		
			wire clk_gate;
			wire clk_gate_hi;
			wire clk_gate_lo;
			if (PREAMBLE_TYPE == "low")
			begin
				if (EMIF_UNALIGNED_PREAMBLE_SUPPORT != "true")
					begin 
						assign clk_gate = output_strobe_ena[0];
					end 
					else
					begin 
						reg [1:0] os_ena_reg;
						reg [1:0] os_ena_preamble;

						always @(posedge core_clock_in)  
						begin
							os_ena_reg[1:0] <= output_strobe_ena[1:0];
						end

						always @(*)
						begin
							case ({os_ena_reg[0], os_ena_reg[1],
										 output_strobe_ena[0], output_strobe_ena[1]}) 
									4'b00_00: os_ena_preamble[1:0] <= 2'b00;
									4'b00_01: os_ena_preamble[1:0] <= 2'b00; 
									4'b00_10: os_ena_preamble[1:0] <= 2'b00; 
									4'b00_11: os_ena_preamble[1:0] <= 2'b01; 

									4'b01_00: os_ena_preamble[1:0] <= 2'b00;
									4'b01_01: os_ena_preamble[1:0] <= 2'b00; 
									4'b01_10: os_ena_preamble[1:0] <= 2'b10;
									4'b01_11: os_ena_preamble[1:0] <= 2'b11;

									4'b10_00: os_ena_preamble[1:0] <= 2'b00;
									4'b10_01: os_ena_preamble[1:0] <= 2'b00; 
									4'b10_10: os_ena_preamble[1:0] <= 2'b00; 
									4'b10_11: os_ena_preamble[1:0] <= 2'b01; 

									4'b11_00: os_ena_preamble[1:0] <= 2'b00;
									4'b11_01: os_ena_preamble[1:0] <= 2'b00; 
									4'b11_10: os_ena_preamble[1:0] <= 2'b10;
									4'b11_11: os_ena_preamble[1:0] <= 2'b11;

									default:  os_ena_preamble[1:0] <= 2'b00;
							endcase
						end

						assign clk_gate_hi = os_ena_preamble[0];
						assign clk_gate_lo = os_ena_preamble[1];
					end 
			end
			else
			begin
				assign clk_gate = 1'b1;
			end

			reg fr_os_hi_reg = 0;
			reg fr_os_hi_hi_reg = 0;
			reg fr_os_hi_lo_reg = 0;
			reg fr_os_oe_lo_reg = 0;
			reg fr_os_oe_hi_reg = 0;

			always @(posedge hr_clock_in)
			begin
				if (HR_DDIO_OUT_HAS_THREE_REGS == "true")
				begin
					fr_os_hi_reg <= #(shift_180_hr) clk_gate;
					fr_os_oe_lo_reg <= ~output_strobe_ena[0];
					fr_os_oe_hi_reg <= #(shift_180_hr) ~output_strobe_ena[1];
					fr_os_hi_lo_reg <= clk_gate_lo;
					fr_os_hi_hi_reg <= #(shift_180_hr) clk_gate_hi;
				end
				else
				begin
					fr_os_oe_lo_reg <= ~output_strobe_ena[1];
					fr_os_oe_hi_reg <= ~output_strobe_ena[0];
					fr_os_hi_reg <= clk_gate;
					fr_os_hi_hi_reg <= clk_gate_lo;          
					fr_os_hi_lo_reg <= clk_gate_hi;
				end
			end
			assign fr_os_lo = 1'b0;
			assign fr_os_oe = hr_clock_in ? fr_os_oe_hi_reg : fr_os_oe_lo_reg;
			if (EMIF_UNALIGNED_PREAMBLE_SUPPORT == "true")      
			begin
				assign fr_os_hi = hr_clock_in ? fr_os_hi_hi_reg : fr_os_hi_lo_reg;
			end
			else
			begin
				assign fr_os_hi = fr_os_hi_reg;
			end
		end
		else 
		begin
			assign fr_os_lo = 1'b0;
			if (USE_OUTPUT_STROBE_RESET == "true") 
			begin
				reg clk_h /* synthesis dont_merge */;
				always @(posedge core_clock_in or negedge reset_n_core_clock_in)
				begin
					if (~reset_n_core_clock_in)
						clk_h <= #(shift_360_hr) 1'b0;
					else
						clk_h <= #(shift_360_hr) 1'b1;
				end
				assign fr_os_hi = clk_h;
			end
			else
			begin
				assign fr_os_hi = 1'b1;
			end
		end

	end
	else 
	begin
		if (USE_BIDIR_STROBE == "true")
		begin
			assign fr_os_oe = ~output_strobe_ena[0];
			assign fr_os_lo = 1'b0;
			

			if (PREAMBLE_TYPE == "low")
			begin
				reg os_ena_reg1 = 0;
				always @(posedge core_clock_in)
					os_ena_reg1 <= output_strobe_ena[0];
				
				assign fr_os_hi = os_ena_reg1 & output_strobe_ena[0];
			end
			else
			begin
				assign fr_os_hi = 1'b1;
			end
		end
		else 
		begin
			assign fr_os_lo = 1'b0;
			if (USE_OUTPUT_STROBE_RESET == "true") 
			begin
				reg clk_h /* synthesis dont_merge */;
				always @(posedge core_clock_in or negedge reset_n_core_clock_in)
				begin
					if (~reset_n_core_clock_in)
						clk_h <= 1'b0;
					else
						clk_h <= 1'b1;
				end			
				assign fr_os_hi = clk_h;
			end
			else
			begin
				assign fr_os_hi = 1'b1;
			end
		end 
	end 

	if (USE_OUTPUT_PHASE_ALIGNMENT == "true")
	begin
		reg aligned_strobe_hi_reg = 0;
		reg aligned_strobe_lo_reg = 0;
		reg aligned_os_oe_reg = 0;

		wire dqs_delayed_clock;
		reg dqs_delayed_clock2 = '0;

		if (DUAL_WRITE_CLOCK == "true")
		begin
			assign #(opa_clock_delay) dqs_delayed_clock = fr_strobe_clock_in;
		end
		else
		begin
			assign #(opa_clock_delay) dqs_delayed_clock = fr_clock_in;		
		end

		always @(dqs_delayed_clock)
		begin
			dqs_delayed_clock2 <= #(dqs_out_ptap_delay) dqs_delayed_clock;
		end

		always @(posedge dqs_delayed_clock)
		begin
  			aligned_strobe_hi_reg <= #(dqs_out_ptap_delay) fr_os_hi;
  			aligned_strobe_lo_reg <= #(dqs_out_ptap_delay) fr_os_lo;
			aligned_os_oe_reg <= #(dqs_out_ptap_delay) fr_os_oe;
		end
		assign aligned_strobe = dqs_delayed_clock2 ? aligned_strobe_hi_reg : aligned_strobe_lo_reg;
		assign aligned_os_oe = aligned_os_oe_reg;
		
	end
	else
	begin
		reg os_oe_reg = 0;
		reg os_reg = 0;
		wire write_strobe_clock;

		if (USE_LDC_AS_LOW_SKEW_CLOCK == "true")
		begin
			if (OUTPUT_DQS_PHASE_SETTING == 0)
				assign write_strobe_clock = fr_clock_in;
			else if (OUTPUT_DQS_PHASE_SETTING == 2 || OUTPUT_DQS_PHASE_SETTING == 3)
				assign #(shift_90_fr) write_strobe_clock = fr_clock_in;
			else if (OUTPUT_DQS_PHASE_SETTING == 4)
				assign write_strobe_clock = ~fr_clock_in;
		end
		else
		begin
			assign write_strobe_clock = write_strobe_clock_in;
		end

		always @( posedge write_strobe_clock)
		begin
			os_oe_reg <= fr_os_oe;
			os_reg <= fr_os_hi;
		end
		
		assign aligned_os_oe = os_oe_reg;
		assign aligned_strobe = write_strobe_clock ? os_reg : fr_os_lo;
	end


	if (USE_BIDIR_STROBE == "true")
	begin
		reg strobe_r = 1'b0;
		reg strobe_n_r = 1'b0;
		always @(aligned_os_oe or aligned_strobe)
		begin
			strobe_r <= #(dqs_out_dtap_delay) ~aligned_os_oe ? aligned_strobe : 1'bz;
			if (DIFFERENTIAL_OUTPUT_STROBE=="true")
				strobe_n_r <= #(dqs_out_dtap_delay) ~aligned_os_oe ? ~aligned_strobe : 1'bz;
		end
		assign strobe_io = strobe_r;
		if (DIFFERENTIAL_OUTPUT_STROBE=="true")
			assign strobe_n_io = strobe_n_r;
	end
	else
	begin
		reg strobe_r = 1'b0;
		reg strobe_n_r = 1'b0;
		always @(aligned_strobe)
		begin
			strobe_r <= #(dqs_out_dtap_delay) aligned_strobe;
			if (DIFFERENTIAL_OUTPUT_STROBE=="true")
				strobe_n_r <= #(dqs_out_dtap_delay) ~aligned_strobe;
		end
		assign output_strobe_out = strobe_r;
		if (DIFFERENTIAL_OUTPUT_STROBE=="true")
			assign output_strobe_n_out = strobe_n_r;
	end

end 
endgenerate


wire aligned_oe;		
wire [PIN_WIDTH-1:0] aligned_data;
wire [PIN_WIDTH-1:0] ddr_data;

generate
if (PIN_TYPE == "output" || PIN_TYPE == "bidir")
begin: output_data
	genvar pin;
	
	reg [PIN_WIDTH-1:0] hr_data_lo_lo = '0;
	reg [PIN_WIDTH-1:0] hr_data_lo_hi = '0;
	reg [PIN_WIDTH-1:0] hr_data_hi_lo = '0;
	reg [PIN_WIDTH-1:0] hr_data_hi_hi = '0;

	reg [PIN_WIDTH-1:0] fr_data_lo;
	reg [PIN_WIDTH-1:0] fr_data_hi;

	reg [PIN_WIDTH-1:0] data_lo_reg = '0;
	reg [PIN_WIDTH-1:0] data_hi_reg = '0;
	reg [PIN_WIDTH-1:0] data_reg = '0;

	reg hr_oe_lo = 0;
	reg hr_oe_hi = 0;
	reg fr_oe;
	reg oe_reg = 0;

	reg [EXTRA_OUTPUT_WIDTH-1:0] ex_hr_data_hi_lo_reg = '0;
	reg [EXTRA_OUTPUT_WIDTH-1:0] ex_hr_data_hi_hi_reg = '0;
	reg [EXTRA_OUTPUT_WIDTH-1:0] ex_hr_data_lo_lo_reg = '0;
	reg [EXTRA_OUTPUT_WIDTH-1:0] ex_hr_data_lo_hi_reg = '0;

	reg [EXTRA_OUTPUT_WIDTH-1:0] ex_fr_data_hi;
	reg [EXTRA_OUTPUT_WIDTH-1:0] ex_fr_data_lo;

	reg [EXTRA_OUTPUT_WIDTH-1:0] ex_fr_data_lo_reg = '0;
	reg [EXTRA_OUTPUT_WIDTH-1:0] ex_fr_data_hi_reg = '0;
	reg [EXTRA_OUTPUT_WIDTH-1:0] ex_data_reg = '0;

	wire [EXTRA_OUTPUT_WIDTH-1:0] ex_aligned_data;
	
	
	if (USE_HALF_RATE_OUTPUT == "true")
	begin
		always @(posedge hr_clock_in)
		begin
			if (HR_DDIO_OUT_HAS_THREE_REGS == "true")
			begin
				hr_data_hi_lo <= write_data_in [(0+1)*PIN_WIDTH-1:(0+0)*PIN_WIDTH];
				hr_data_hi_hi <= #(shift_180_hr) write_data_in [(2+1)*PIN_WIDTH-1:(2+0)*PIN_WIDTH];
				hr_data_lo_lo <= write_data_in [(1+1)*PIN_WIDTH-1:(1+0)*PIN_WIDTH];
				hr_data_lo_hi <= #(shift_180_hr) write_data_in [(3+1)*PIN_WIDTH-1:(3+0)*PIN_WIDTH];

				hr_oe_lo <= ~write_oe_in[0];
				hr_oe_hi <= #(shift_180_hr) ~write_oe_in[PIN_WIDTH];

				ex_hr_data_hi_lo_reg <= extra_write_data_in[(0+1)*EXTRA_OUTPUT_WIDTH-1:(0+0)*EXTRA_OUTPUT_WIDTH];
				ex_hr_data_hi_hi_reg <= #(shift_180_hr) 
							extra_write_data_in[(2+1)*EXTRA_OUTPUT_WIDTH-1:(2+0)*EXTRA_OUTPUT_WIDTH];
				ex_hr_data_lo_lo_reg <= extra_write_data_in[(1+1)*EXTRA_OUTPUT_WIDTH-1:(1+0)*EXTRA_OUTPUT_WIDTH];
				ex_hr_data_lo_hi_reg <= #(shift_180_hr)
							extra_write_data_in[(3+1)*EXTRA_OUTPUT_WIDTH-1:(3+0)*EXTRA_OUTPUT_WIDTH];
			end
			else
			begin
				hr_data_hi_lo <= write_data_in [(2+1)*PIN_WIDTH-1:(2+0)*PIN_WIDTH];
				hr_data_hi_hi <= write_data_in [(0+1)*PIN_WIDTH-1:(0+0)*PIN_WIDTH];
				hr_data_lo_lo <= write_data_in [(3+1)*PIN_WIDTH-1:(3+0)*PIN_WIDTH];
				hr_data_lo_hi <= write_data_in [(1+1)*PIN_WIDTH-1:(1+0)*PIN_WIDTH];

				hr_oe_lo <= ~write_oe_in[PIN_WIDTH];
				hr_oe_hi <= ~write_oe_in[0];

				ex_hr_data_hi_lo_reg <= extra_write_data_in[(2+1)*EXTRA_OUTPUT_WIDTH-1:(2+0)*EXTRA_OUTPUT_WIDTH];
				ex_hr_data_hi_hi_reg <= extra_write_data_in[(0+1)*EXTRA_OUTPUT_WIDTH-1:(0+0)*EXTRA_OUTPUT_WIDTH];
				ex_hr_data_lo_lo_reg <= extra_write_data_in[(3+1)*EXTRA_OUTPUT_WIDTH-1:(3+0)*EXTRA_OUTPUT_WIDTH];
				ex_hr_data_lo_hi_reg <= extra_write_data_in[(1+1)*EXTRA_OUTPUT_WIDTH-1:(1+0)*EXTRA_OUTPUT_WIDTH];
			end
		end

		assign fr_data_hi = hr_clock_in ? hr_data_hi_hi : hr_data_hi_lo;
		assign fr_data_lo = hr_clock_in ? hr_data_lo_hi : hr_data_lo_lo;

		assign fr_oe = hr_clock_in ? hr_oe_hi : hr_oe_lo;

		assign ex_fr_data_hi = hr_clock_in ? ex_hr_data_hi_hi_reg : ex_hr_data_hi_lo_reg;
		assign ex_fr_data_lo = hr_clock_in ? ex_hr_data_lo_hi_reg : ex_hr_data_lo_lo_reg;
	end
	else
	begin
		assign fr_data_lo = write_data_in[2*PIN_WIDTH-1:PIN_WIDTH];
		assign fr_data_hi = write_data_in[PIN_WIDTH-1:0];

		assign fr_oe = ~write_oe_in[0];

		assign ex_fr_data_lo = extra_write_data_in [2*EXTRA_OUTPUT_WIDTH-1:EXTRA_OUTPUT_WIDTH];
		assign ex_fr_data_hi = extra_write_data_in [EXTRA_OUTPUT_WIDTH-1:0];
	end

		
	if (USE_OUTPUT_PHASE_ALIGNMENT == "true")
	begin

		wire dq_delayed_clock;
		reg dq_delayed_clock2 = '0;

		if (DUAL_WRITE_CLOCK == "true")
		begin
			assign #(opa_clock_delay) dq_delayed_clock = fr_data_clock_in;
		end
		else
		begin
			assign #(opa_clock_delay) dq_delayed_clock = fr_clock_in;
		end		

		always @(dq_delayed_clock)
		begin
			dq_delayed_clock2 <= #(dq_out_ptap_delay) dq_delayed_clock;
		end

		always @(posedge dq_delayed_clock)
		begin
			data_hi_reg <= #(dq_out_ptap_delay) fr_data_hi;
			data_lo_reg <= #(dq_out_ptap_delay) fr_data_lo;

			oe_reg      <= #(dq_out_ptap_delay) fr_oe;

			ex_fr_data_hi_reg <= #(dq_out_ptap_delay) ex_fr_data_hi;
			ex_fr_data_lo_reg <= #(dq_out_ptap_delay) ex_fr_data_lo;
		end
		assign aligned_data = dq_delayed_clock2 ? data_hi_reg : data_lo_reg;
		assign aligned_oe = oe_reg;
		assign ex_aligned_data = dq_delayed_clock2 ? ex_fr_data_hi_reg : ex_fr_data_lo_reg;
	end
	else
	begin
		wire dq_delayed_clock;
		
		if (USE_LDC_AS_LOW_SKEW_CLOCK == "true")
		begin
			if (OUTPUT_DQ_PHASE_SETTING == 0)
				assign dq_delayed_clock = fr_clock_in;
			else if (OUTPUT_DQ_PHASE_SETTING == 2 || OUTPUT_DQ_PHASE_SETTING == 3)
				assign #(shift_90_fr) dq_delayed_clock = fr_clock_in;
			else if (OUTPUT_DQ_PHASE_SETTING == 4)
				assign dq_delayed_clock = ~fr_clock_in;
		end
		else
		begin
			assign dq_delayed_clock = fr_clock_in;
		end
			
		always @(posedge dq_delayed_clock)
		begin
			data_lo_reg <= fr_data_lo;
			data_hi_reg <= fr_data_hi;

			oe_reg <= fr_oe;

			ex_fr_data_lo_reg <= ex_fr_data_lo;
			ex_fr_data_hi_reg <= ex_fr_data_hi;
		end

		assign aligned_data = dq_delayed_clock ? data_hi_reg : data_lo_reg;
		assign aligned_oe = oe_reg;
		assign ex_aligned_data = dq_delayed_clock ? ex_fr_data_hi_reg : ex_fr_data_lo_reg;
	end


	if (CALIBRATION_SUPPORT == "true")
	begin
		reg [PIN_WIDTH-1:0] data_out = '0;
		reg [EXTRA_OUTPUT_WIDTH-1:0] ex_out = '0;
		
		for (pin = 0; pin < PIN_WIDTH; pin++)
		begin: output_data_bits
			always @(aligned_oe or aligned_data[pin])
				data_out[pin] <= #(dq_out_dtap_delay[((pin+1)*DELAY_WIDTH)-1:pin*DELAY_WIDTH]) ~aligned_oe ? aligned_data[pin] : 'z;
		end
		if (PIN_TYPE == "bidir")
			assign read_write_data_io = data_out;
		else
			assign write_data_out = data_out;

		for (pin = 0; pin < EXTRA_OUTPUT_WIDTH; pin++)
		begin: output_extra_bits
			always @(ex_aligned_data[pin])
				ex_out <= #(extra_out_dtap_delay[((pin+1)*DELAY_WIDTH)-1:pin*DELAY_WIDTH]) ex_aligned_data[pin];
		end
		assign extra_write_data_out = ex_out;
	end
	else
	begin
		if (PIN_TYPE == "bidir")
			assign read_write_data_io = ~aligned_oe ? aligned_data : 'z;
		else
			assign write_data_out = ~aligned_oe ? aligned_data : 'z;
		assign extra_write_data_out = ex_aligned_data;
	end
end
endgenerate


generate
	genvar pin;
	if (PIN_TYPE == "input" || PIN_TYPE == "bidir")
	begin: input_data
		wire dqsbusout_to_ddio_in;
		reg [PIN_WIDTH-1:0] sdr_data_lo_reg = '0;
		reg [PIN_WIDTH-1:0] sdr_data_hi_reg = '0;
			
		if (INVERT_CAPTURE_STROBE == "true") 
			assign dqsbusout_to_ddio_in = ~dqsbusout;
		else
			assign dqsbusout_to_ddio_in = dqsbusout;

		if (CALIBRATION_SUPPORT == "true")
		begin
			reg [PIN_WIDTH-1:0] ddr_data_r;
			for (pin = 0; pin < PIN_WIDTH; pin++)
			begin: input_data_bits
				if (PIN_TYPE == "bidir")
				begin
					always @(read_write_data_io[pin])
						ddr_data_r[pin] <= #(dq_in_dtap_delay[((pin+1)*DELAY_WIDTH)-1:pin*DELAY_WIDTH]) read_write_data_io[pin];
				end
				else
				begin
					always @(read_data_in[pin])
						ddr_data_r[pin] <= #(dq_in_dtap_delay[((pin+1)*DELAY_WIDTH)-1:pin*DELAY_WIDTH]) read_data_in[pin];
				end
			end
			assign ddr_data = ddr_data_r;
		end
		else
		begin
			if (PIN_TYPE == "bidir")
				assign ddr_data = read_write_data_io;
			else
				assign ddr_data = read_data_in;
		end
			

		always @(dqsbusout_to_ddio_in)
		begin
			if (dqsbusout_to_ddio_in)
				sdr_data_hi_reg <= ddr_data;
			else
				sdr_data_lo_reg <= #(shift_180_fr) ddr_data;
		end

		assign read_data_out[PIN_WIDTH-1:0] = sdr_data_lo_reg;
		assign read_data_out[fpga_width_in-1:PIN_WIDTH] = sdr_data_hi_reg;

	end
endgenerate


endmodule


