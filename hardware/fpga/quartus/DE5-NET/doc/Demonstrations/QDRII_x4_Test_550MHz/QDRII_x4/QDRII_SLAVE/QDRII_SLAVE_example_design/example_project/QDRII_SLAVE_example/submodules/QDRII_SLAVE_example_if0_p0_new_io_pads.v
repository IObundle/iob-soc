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

// altera message_off 10036
module QDRII_SLAVE_example_if0_p0_new_io_pads(
	reset_n_addr_cmd_clk,
	reset_n_afi_clk,
	phy_reset_mem_stable,
	oct_ctl_rs_value,
	oct_ctl_rt_value,
	phy_ddio_addr_cmd_clk,
	phy_ddio_address,
	phy_ddio_wps_n,
	phy_ddio_rps_n,
	phy_ddio_doff_n,
	phy_mem_address,
	phy_mem_wps_n,
	phy_mem_rps_n,
	phy_mem_doff_n,


	pll_afi_clk,
	pll_mem_clk,
	pll_write_clk,
	pll_c2p_write_clk,
	phy_ddio_dq,
	phy_ddio_wrdata_en,
	phy_ddio_wrdata_mask,
	phy_mem_d,
	phy_mem_bws_n,
	phy_mem_k,
	phy_mem_k_n,
	dll_phy_delayctrl,
	mem_phy_cq,
	mem_phy_cq_n,
	mem_phy_q,
	ddio_phy_dq,
	read_capture_clk, 
	scc_clk,
	scc_data,
	scc_dqs_ena,
	scc_dqs_io_ena,
	scc_dq_ena,
	scc_dm_ena,
	scc_sr_dqsenable_delayctrl,
	scc_sr_dqsdisablen_delayctrl,
	scc_sr_multirank_delayctrl,
	scc_upd,
    enable_mem_clk,
	capture_strobe_tracking
);


parameter DEVICE_FAMILY = "";
parameter REGISTER_C2P = "";
parameter LDC_MEM_CK_CPS_PHASE = "";

parameter OCT_SERIES_TERM_CONTROL_WIDTH = "";  
parameter OCT_PARALLEL_TERM_CONTROL_WIDTH = ""; 
parameter MEM_ADDRESS_WIDTH     = ""; 
localparam MEM_CK_WIDTH 			= 1; 
parameter MEM_DM_WIDTH          = ""; 
parameter MEM_CONTROL_WIDTH     = ""; 
parameter MEM_DQ_WIDTH          = ""; 
parameter MEM_READ_DQS_WIDTH    = ""; 
parameter MEM_WRITE_DQS_WIDTH   = ""; 

parameter AFI_ADDRESS_WIDTH         = ""; 
parameter AFI_DATA_MASK_WIDTH       = ""; 
parameter AFI_CONTROL_WIDTH         = ""; 
parameter AFI_DATA_WIDTH            = ""; 
parameter AFI_DQS_WIDTH             = ""; 
parameter AFI_RATE_RATIO            = ""; 

parameter DLL_DELAY_CTRL_WIDTH  = "";

parameter SCC_DATA_WIDTH        = "";


parameter FAST_SIM_MODEL            = "";


parameter IS_HHP_HPS = "";

localparam DOUBLE_MEM_DQ_WIDTH = MEM_DQ_WIDTH * 2;
localparam HALF_AFI_DATA_WIDTH = AFI_DATA_WIDTH / 2;
localparam HALF_AFI_DQS_WIDTH = AFI_DQS_WIDTH / 2;



input	reset_n_afi_clk;
input	reset_n_addr_cmd_clk;
input   phy_reset_mem_stable;

input   [OCT_SERIES_TERM_CONTROL_WIDTH-1:0] oct_ctl_rs_value;
input   [OCT_PARALLEL_TERM_CONTROL_WIDTH-1:0] oct_ctl_rt_value;

input	phy_ddio_addr_cmd_clk;
input	[AFI_ADDRESS_WIDTH-1:0]	phy_ddio_address;
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_wps_n;
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_rps_n;
input	[AFI_CONTROL_WIDTH-1:0] phy_ddio_doff_n;

output  [MEM_ADDRESS_WIDTH-1:0] phy_mem_address;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_wps_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_rps_n;
output  [MEM_CONTROL_WIDTH-1:0] phy_mem_doff_n;



input	pll_afi_clk;
input	pll_mem_clk;
input	pll_write_clk;
input	pll_c2p_write_clk;
input	[AFI_DATA_WIDTH-1:0]  phy_ddio_dq;
input	[AFI_DQS_WIDTH-1:0] phy_ddio_wrdata_en;
input	[AFI_DATA_MASK_WIDTH-1:0]	phy_ddio_wrdata_mask;	

output  [MEM_DQ_WIDTH-1:0] phy_mem_d;
output  [MEM_DM_WIDTH-1:0] phy_mem_bws_n;
output  [MEM_WRITE_DQS_WIDTH-1:0] phy_mem_k;
output  [MEM_WRITE_DQS_WIDTH-1:0] phy_mem_k_n;


input   [DLL_DELAY_CTRL_WIDTH-1:0]  dll_phy_delayctrl;
input   [MEM_READ_DQS_WIDTH-1:0] mem_phy_cq;
input   [MEM_READ_DQS_WIDTH-1:0] mem_phy_cq_n;
input   [MEM_DQ_WIDTH-1:0] mem_phy_q;
localparam DDIO_PHY_DQ_WIDTH = DOUBLE_MEM_DQ_WIDTH;
output	[DDIO_PHY_DQ_WIDTH-1:0] ddio_phy_dq;	
output	[MEM_READ_DQS_WIDTH-1:0] read_capture_clk;	

input	scc_clk;
input	[SCC_DATA_WIDTH - 1:0] scc_data;
input	[MEM_READ_DQS_WIDTH - 1:0] scc_dqs_ena;
input	[MEM_READ_DQS_WIDTH - 1:0] scc_dqs_io_ena;
input	[MEM_DQ_WIDTH - 1:0] scc_dq_ena;
input	[MEM_DM_WIDTH - 1:0] scc_dm_ena;
input   [7:0] scc_sr_dqsenable_delayctrl;
input   [7:0] scc_sr_dqsdisablen_delayctrl;
input   [7:0] scc_sr_multirank_delayctrl;

input [0:0] scc_upd;
input   [MEM_CK_WIDTH-1:0] enable_mem_clk;
output	[MEM_READ_DQS_WIDTH - 1:0] capture_strobe_tracking;

assign capture_strobe_tracking = 1'd0;


wire	hr_clk = pll_afi_clk;
wire	core_clk = pll_afi_clk;
wire	reset_n_core_clk = reset_n_afi_clk;

reg [AFI_DATA_WIDTH-1:0] phy_ddio_dq_int;
reg [AFI_DQS_WIDTH-1:0] phy_ddio_wrdata_en_int;
reg [AFI_DATA_MASK_WIDTH-1:0] phy_ddio_wrdata_mask_int;
	
generate
if (REGISTER_C2P == "false") begin
	always @(*) begin	
		phy_ddio_dq_int = phy_ddio_dq;
		phy_ddio_wrdata_en_int = phy_ddio_wrdata_en;
		phy_ddio_wrdata_mask_int = phy_ddio_wrdata_mask;	
	end
	
end else begin

	always @(posedge pll_afi_clk) begin
		phy_ddio_dq_int <= phy_ddio_dq;
		phy_ddio_wrdata_en_int <= phy_ddio_wrdata_en;
		phy_ddio_wrdata_mask_int <= phy_ddio_wrdata_mask;	
	end
end
endgenerate	



	QDRII_SLAVE_example_if0_p0_addr_cmd_ldc_pads uaddr_cmd_pads(
		.reset_n				(reset_n_addr_cmd_clk),
		.reset_n_afi_clk		(reset_n_afi_clk),
		.pll_afi_clk            (pll_afi_clk),
		.pll_mem_clk            (pll_mem_clk),
		.pll_write_clk          (pll_write_clk),
		.pll_c2p_write_clk      (pll_c2p_write_clk),
		.phy_ddio_addr_cmd_clk  (phy_ddio_addr_cmd_clk),
		.dll_delayctrl_in       (dll_phy_delayctrl),
		.enable_mem_clk         (enable_mem_clk),
		.phy_ddio_address 		(phy_ddio_address),
		.phy_ddio_wps_n         (phy_ddio_wps_n), 
		.phy_ddio_rps_n         (phy_ddio_rps_n), 
		.phy_ddio_doff_n        (phy_ddio_doff_n),
		
		.phy_mem_address        (phy_mem_address),
		.phy_mem_wps_n          (phy_mem_wps_n),
		.phy_mem_rps_n          (phy_mem_rps_n),
		.phy_mem_doff_n         (phy_mem_doff_n)
	);
	defparam uaddr_cmd_pads.DEVICE_FAMILY			= DEVICE_FAMILY;
	defparam uaddr_cmd_pads.MEM_ADDRESS_WIDTH		= MEM_ADDRESS_WIDTH;
	defparam uaddr_cmd_pads.MEM_CONTROL_WIDTH		= MEM_CONTROL_WIDTH;
	defparam uaddr_cmd_pads.AFI_ADDRESS_WIDTH       = AFI_ADDRESS_WIDTH; 
	defparam uaddr_cmd_pads.AFI_CONTROL_WIDTH       = AFI_CONTROL_WIDTH; 
	defparam uaddr_cmd_pads.DLL_WIDTH               = DLL_DELAY_CTRL_WIDTH; 
	defparam uaddr_cmd_pads.REGISTER_C2P            = REGISTER_C2P;
	defparam uaddr_cmd_pads.LDC_MEM_CK_CPS_PHASE    = LDC_MEM_CK_CPS_PHASE;
		
	localparam NUM_OF_DQDQS = MEM_WRITE_DQS_WIDTH;
	localparam DQDQS_DATA_WIDTH = MEM_DQ_WIDTH / NUM_OF_DQDQS;
	localparam DQDQS_DDIO_PHY_DQ_WIDTH = DDIO_PHY_DQ_WIDTH / NUM_OF_DQDQS;
	
	localparam DQDQS_DM_WIDTH = MEM_DM_WIDTH / MEM_WRITE_DQS_WIDTH;
		
	localparam NUM_OF_DQDQS_WITH_DM = MEM_WRITE_DQS_WIDTH;		

	generate
	genvar i;
	for (i=0; i<NUM_OF_DQDQS; i=i+1)
	begin: dq_ddio
		wire dqs_busout;

		// The phy_ddio_dq_int bus is the write data for all DQS groups in one
		// AFI cycle. The bus is ordered by time slot and subordered by DQS group:
		//
		// FR: D1_T1, D0_T1, D1_T0, D0_T0
		// HR: D1_T3, D0_T3, D1_T2, D0_T2, D1_T1, D0_T1, D1_T0, D0_T0
		//
		// Extract the write data targeting the current DQS group
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_dq_t0 = phy_ddio_dq_int [DQDQS_DATA_WIDTH*(i+1+0*NUM_OF_DQDQS)-1 : DQDQS_DATA_WIDTH*(i+0*NUM_OF_DQDQS)];
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_dq_t1 = phy_ddio_dq_int [DQDQS_DATA_WIDTH*(i+1+1*NUM_OF_DQDQS)-1 : DQDQS_DATA_WIDTH*(i+1*NUM_OF_DQDQS)];
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_dq_t2 = phy_ddio_dq_int [DQDQS_DATA_WIDTH*(i+1+2*NUM_OF_DQDQS)-1 : DQDQS_DATA_WIDTH*(i+2*NUM_OF_DQDQS)];
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_dq_t3 = phy_ddio_dq_int [DQDQS_DATA_WIDTH*(i+1+3*NUM_OF_DQDQS)-1 : DQDQS_DATA_WIDTH*(i+3*NUM_OF_DQDQS)];

		// Extract the OE signal targeting the current DQS group
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_wrdata_en_t0 = {DQDQS_DATA_WIDTH{phy_ddio_wrdata_en_int[i]}};
		wire [DQDQS_DATA_WIDTH-1:0] phy_ddio_wrdata_en_t1 = {DQDQS_DATA_WIDTH{phy_ddio_wrdata_en_int[i+MEM_WRITE_DQS_WIDTH]}};


		// Extract the write data mask signal targeting the current DQS group
		wire [DQDQS_DM_WIDTH-1:0] phy_ddio_wrdata_mask_t0;
		wire [DQDQS_DM_WIDTH-1:0] phy_ddio_wrdata_mask_t1;
		wire [DQDQS_DM_WIDTH-1:0] phy_ddio_wrdata_mask_t2;
		wire [DQDQS_DM_WIDTH-1:0] phy_ddio_wrdata_mask_t3;
		assign phy_ddio_wrdata_mask_t0 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(i+1+0*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(i+0*NUM_OF_DQDQS_WITH_DM)];
		assign phy_ddio_wrdata_mask_t1 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(i+1+1*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(i+1*NUM_OF_DQDQS_WITH_DM)];
		assign phy_ddio_wrdata_mask_t2 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(i+1+2*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(i+2*NUM_OF_DQDQS_WITH_DM)];
		assign phy_ddio_wrdata_mask_t3 = phy_ddio_wrdata_mask_int [DQDQS_DM_WIDTH*(i+1+3*NUM_OF_DQDQS_WITH_DM)-1 : DQDQS_DM_WIDTH*(i+3*NUM_OF_DQDQS_WITH_DM)];



			QDRII_SLAVE_example_if0_p0_altdqdqs uwrite (
				.write_strobe_clock_in (1'b0),
				.reset_n_core_clock_in (reset_n_core_clk),
				.core_clock_in (core_clk),
				.fr_clock_in (pll_write_clk),

				.hr_clock_in (pll_c2p_write_clk),
				.parallelterminationcontrol_in(oct_ctl_rt_value),
				.seriesterminationcontrol_in(oct_ctl_rs_value),
				.write_data_out (phy_mem_d [(DQDQS_DATA_WIDTH*(i+1)-1) : DQDQS_DATA_WIDTH*i]),
				
				.extra_write_data_in ({phy_ddio_wrdata_mask_t3, phy_ddio_wrdata_mask_t2, phy_ddio_wrdata_mask_t1, phy_ddio_wrdata_mask_t0}),
				.write_oe_in ({phy_ddio_wrdata_en_t1, phy_ddio_wrdata_en_t0}),
				
				.write_data_in ({phy_ddio_dq_t3, phy_ddio_dq_t2, phy_ddio_dq_t1, phy_ddio_dq_t0}),


				.output_strobe_out (phy_mem_k[i]),
				.output_strobe_n_out (phy_mem_k_n[i]),
				.extra_write_data_out (phy_mem_bws_n[DQDQS_DM_WIDTH*(i+1)-1:DQDQS_DM_WIDTH*i]),
				.config_data_in (scc_data),
				.config_dqs_ena (scc_dqs_ena[i]),
				.config_io_ena (scc_dq_ena[(DQDQS_DATA_WIDTH*(i+1)-1) : DQDQS_DATA_WIDTH*i]),
				.config_dqs_io_ena (scc_dqs_io_ena[i]),
				.config_update (scc_upd[0]),
				.config_clock_in (scc_clk),
				.config_extra_io_ena (scc_dm_ena[DQDQS_DM_WIDTH*(i+1)-1:DQDQS_DM_WIDTH*i]),

				.dll_delayctrl_in (dll_phy_delayctrl)	
				);
			defparam uwrite.ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL = FAST_SIM_MODEL;
						
			
	end
	endgenerate

	localparam DQDQS_READ_DATA_WIDTH = MEM_DQ_WIDTH / MEM_READ_DQS_WIDTH;
	localparam DQDQS_READ_DDIO_PHY_DQ_WIDTH = DDIO_PHY_DQ_WIDTH / MEM_READ_DQS_WIDTH;
	
	generate
	genvar c;
		for (c=0; c<MEM_READ_DQS_WIDTH; c=c+1)
		begin: read_capture
			wire dqs_busout;
			
		
			QDRII_SLAVE_example_if0_p0_altdqdqs_in uread (
				.hr_clock_in (1'b0),
				.read_data_in (mem_phy_q[(DQDQS_READ_DATA_WIDTH*(c+1)-1) : DQDQS_READ_DATA_WIDTH*c]),	
				.read_data_out (ddio_phy_dq[(DQDQS_READ_DDIO_PHY_DQ_WIDTH*(c+1)-1) : DQDQS_READ_DDIO_PHY_DQ_WIDTH*c]),
				.config_data_in (scc_data),
				.config_dqs_ena (scc_dqs_ena[c]),
				.config_io_ena (scc_dq_ena[(DQDQS_READ_DATA_WIDTH*(c+1)-1) : DQDQS_READ_DATA_WIDTH*c]),
				.config_dqs_io_ena (scc_dqs_io_ena[c]),
				.config_update (scc_upd[0]),
				.config_clock_in (scc_clk),
				.dll_delayctrl_in (dll_phy_delayctrl),
				.capture_strobe_in (mem_phy_cq[c]),
				.capture_strobe_n_in (mem_phy_cq_n[c]),
				.capture_strobe_out (dqs_busout)
			);
			defparam uread.ALTERA_ALTDQ_DQS2_FAST_SIM_MODEL = FAST_SIM_MODEL;

		assign read_capture_clk[c] = dqs_busout;
		end
	endgenerate

endmodule
