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

(* altera_attribute = "-name IP_TOOL_NAME altera_mem_if_qdrii_phy_core; -name IP_TOOL_VERSION 16.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100" *)
module QDRII_SLAVE_example_if1_p0 (
    global_reset_n,
    soft_reset_n,
	csr_soft_reset_req,
    parallelterminationcontrol,
    seriesterminationcontrol,
	pll_mem_clk,
	pll_write_clk,
	pll_write_clk_pre_phy_clk,
	pll_addr_cmd_clk,
	pll_p2c_read_clk,
	pll_c2p_write_clk,
	pll_avl_clk,
	pll_config_clk,
	pll_locked,
	dll_pll_locked,
	dll_delayctrl,
	dll_clk,
	afi_reset_n,
	afi_reset_export_n,
	afi_clk,
	afi_half_clk,
	afi_addr,
	afi_wps_n,
	afi_rps_n,
	afi_wdata,
	afi_wdata_valid,
	afi_bws_n,
	afi_doff_n,
	afi_rdata,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata_valid,
	afi_cal_success,
	afi_cal_fail,
	mem_d,
	mem_wps_n,
	mem_bws_n,
	mem_a,
	mem_q,
	mem_rps_n,
	mem_k,
	mem_k_n,
	mem_cq,
	mem_cq_n,
	mem_doff_n,
	avl_clk,
	scc_clk,
	avl_reset_n,
	scc_reset_n,
	scc_data,
	scc_dqs_ena,
	scc_dqs_io_ena,
	scc_dq_ena,
	scc_dm_ena,
	scc_upd,
	capture_strobe_tracking,
	phy_clk,
	phy_reset_n,
	phy_read_latency_counter,
	phy_afi_wlat,
	phy_afi_rlat,
	phy_read_increment_vfifo_fr,
	phy_read_increment_vfifo_hr,
	phy_read_increment_vfifo_qr,
	phy_reset_mem_stable,
	phy_cal_debug_info,
	phy_read_fifo_reset,
	phy_vfifo_rd_en_override,
	phy_cal_success,
	phy_cal_fail,
	phy_read_fifo_q,
	calib_skip_steps
);


// ******************************************************************************************************************************** 
// BEGIN PARAMETER SECTION
// All parameters default to "" will have their values passed in from higher level wrapper with the controller and driver. 
parameter DEVICE_FAMILY = "Stratix V";

// choose between abstract (fast) and regular model
`ifndef ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL
  `define ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL 0
`endif

parameter ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL = `ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL;

localparam FAST_SIM_MODEL = ALTERA_ALT_MEM_IF_PHY_FAST_SIM_MODEL;


// On-chip termination
parameter OCT_TERM_CONTROL_WIDTH   = 16;

// PHY-Memory Interface
// Memory device specific parameters, they are set according to the memory spec.
parameter MEM_IF_ADDR_WIDTH		    = 20;
parameter MEM_IF_DM_WIDTH         	= 2;
parameter MEM_IF_CONTROL_WIDTH    	= 1; 
parameter MEM_IF_DQ_WIDTH         	= 18;
parameter MEM_IF_READ_DQS_WIDTH   	= 1; 
parameter MEM_IF_WRITE_DQS_WIDTH  	= 1;
parameter MEM_IF_CS_WIDTH 	        = -1; 

// PHY-Controller (AFI) Interface
// The AFI interface widths are derived from the memory interface widths based on full/half rate operations.
// The calculations are done on higher level wrapper.
parameter AFI_ADDR_WIDTH         = 40; 
parameter AFI_DM_WIDTH       = 8; 
parameter AFI_CONTROL_WIDTH         = 2; 
parameter AFI_DQ_WIDTH            = 72;
parameter AFI_WRITE_DQS_WIDTH       = 2;
parameter AFI_RATE_RATIO			= 2;
parameter AFI_WLAT_WIDTH			= 6;
parameter AFI_RLAT_WIDTH			= 6;

// DLL Interface
parameter DLL_DELAY_CTRL_WIDTH	= 7;

parameter SCC_DATA_WIDTH            = 1;

parameter NUM_SUBGROUP_PER_READ_DQS        = 18;
parameter QVLD_EXTRA_FLOP_STAGES		   = 0;
parameter QVLD_WR_ADDRESS_OFFSET		   = 6;
	
// Read Datapath parameters, the values should not be changed unless the intention is to change the architecture.
// Read valid prediction FIFO
parameter READ_VALID_FIFO_SIZE             = 16;

// Data resynchronization FIFO
parameter READ_FIFO_SIZE                   = 8;

// Latency calibration parameters
parameter MAX_LATENCY_COUNT_WIDTH		   = 4; // calibration finds the best latency by reducing the maximum latency
localparam MAX_READ_LATENCY				   = 2**MAX_LATENCY_COUNT_WIDTH; 

// Write Datapath
// The sequencer uses this value to control write latency during calibration
parameter MAX_WRITE_LATENCY_COUNT_WIDTH = 4;
parameter NUM_WRITE_PATH_FLOP_STAGES    = 0;
parameter NUM_WRITE_FR_CYCLE_SHIFTS = 1;

// Add additional FF stage between core and periphery
parameter REGISTER_C2P = "true";

// Address/Command Datapath
parameter NUM_AC_FR_CYCLE_SHIFTS = 0;

parameter MEM_T_WL								= 1;

localparam MEM_T_RL								= 2.5;

// The sequencer issues back-to-back reads during calibration, NOPs may need to be inserted depending on the burst length
parameter SEQ_BURST_COUNT_WIDTH = 0;

// The DLL offset control width
parameter DLL_OFFSET_CTRL_WIDTH = 6;

parameter AFI_DEBUG_INFO_WIDTH = 32;

parameter CALIB_REG_WIDTH = 8;


parameter TB_PROTOCOL       = "QDRII";
parameter TB_MEM_CLK_FREQ   = "550.0";
parameter TB_RATE           = "HALF";
parameter TB_MEM_DQ_WIDTH   = "18";
parameter TB_MEM_DQS_WIDTH  = "1";
parameter TB_PLL_DLL_MASTER = "true";

parameter FAST_SIM_CALIBRATION = "false";


localparam SIM_FILESET = ("false" == "true");


// END PARAMETER SECTION
// ******************************************************************************************************************************** 


// ******************************************************************************************************************************** 
// BEGIN PORT SECTION


// When the PHY is selected to be a PLL/DLL SLAVE, the PLL and DLL are instantied at the top level of the example design
input	pll_mem_clk;	
input	pll_write_clk;
input	pll_write_clk_pre_phy_clk;
input	pll_addr_cmd_clk;
input	pll_p2c_read_clk;
input	pll_c2p_write_clk;
input	pll_avl_clk;
input	pll_config_clk;
input	pll_locked;




input	[DLL_DELAY_CTRL_WIDTH-1:0]  dll_delayctrl;
output  dll_pll_locked;
output  dll_clk;



// Reset Interface, AFI 2.0
input   global_reset_n;		// Resets (active-low) the whole system (all PHY logic + PLL)
input	soft_reset_n;		// Resets (active-low) PHY logic only, PLL is NOT reset
output	afi_reset_n;		// Asynchronously asserted and synchronously de-asserted on afi_clk domain
output	afi_reset_export_n;		// Asynchronously asserted and synchronously de-asserted on afi_clk domain
							// should be used to reset system level afi_clk domain logic
input csr_soft_reset_req;  // Reset request (active_high) being driven by external debug master

// OCT termination control signals
input [OCT_TERM_CONTROL_WIDTH-1:0] parallelterminationcontrol;
input [OCT_TERM_CONTROL_WIDTH-1:0] seriesterminationcontrol;

// PHY-Controller Interface, AFI 2.0
// Control Interface
input   [AFI_ADDR_WIDTH-1:0] afi_addr;		// address

input	[AFI_CONTROL_WIDTH-1:0] afi_wps_n;		// write command
input   [AFI_CONTROL_WIDTH-1:0] afi_rps_n;		// read command



// Write data interface
input   [AFI_DQ_WIDTH-1:0]    afi_wdata;				// write data
input	[AFI_WRITE_DQS_WIDTH-1:0]	afi_wdata_valid;			// write data valid, used to maintain write latency required by protocol spec
input   [AFI_DM_WIDTH-1:0]   afi_bws_n;				// write data mask
input   [AFI_CONTROL_WIDTH-1:0]   afi_doff_n;				// 

// Read data interface
output  [AFI_DQ_WIDTH-1:0]    afi_rdata;           // read data				
input   [AFI_RATE_RATIO-1:0]  afi_rdata_en;        // read enable, used to maintain the read latency calibrated by PHY
input   [AFI_RATE_RATIO-1:0]  afi_rdata_en_full;   // read enable full burst, used to create DQS enable
output  [AFI_RATE_RATIO-1:0]  afi_rdata_valid;     // read data valid

// Status interface
output  afi_cal_success;	// calibration success
output  afi_cal_fail;		// calibration failure



// PHY-Memory Interface

// Port names are according to QDRII spec, refer to spec for details
output	[MEM_IF_DQ_WIDTH-1:0] mem_d;				// write data
output	[MEM_IF_CONTROL_WIDTH-1:0] mem_wps_n;		// write command
output	[MEM_IF_DM_WIDTH-1:0] mem_bws_n;			// byte enable
output	[MEM_IF_ADDR_WIDTH-1:0] mem_a;			// address
output	[MEM_IF_CONTROL_WIDTH-1:0] mem_rps_n;		// read command
output	[MEM_IF_CONTROL_WIDTH-1:0] mem_doff_n;		// 0=QDRI mode, 1=QDRII mode, tied to 1 since only QDRII support is required 
output	[MEM_IF_WRITE_DQS_WIDTH-1:0] mem_k;		// complementary input clocks to memory device
output	[MEM_IF_WRITE_DQS_WIDTH-1:0] mem_k_n;		
input	[MEM_IF_READ_DQS_WIDTH-1:0] mem_cq;		// complementary output clocks from memory device
input	[MEM_IF_READ_DQS_WIDTH-1:0] mem_cq_n;
input	[MEM_IF_DQ_WIDTH-1:0] mem_q;				// read data


// PLL Interface
input	afi_clk;
input	afi_half_clk;


output  avl_clk;
output  scc_clk;
output  avl_reset_n;
output  scc_reset_n;

input           [SCC_DATA_WIDTH-1:0]  scc_data;
input    [MEM_IF_READ_DQS_WIDTH-1:0]  scc_dqs_ena;
input    [MEM_IF_READ_DQS_WIDTH-1:0]  scc_dqs_io_ena;
input          [MEM_IF_DQ_WIDTH-1:0]  scc_dq_ena;
input          [MEM_IF_DM_WIDTH-1:0]  scc_dm_ena;
input                          [0:0]  scc_upd;
output   [MEM_IF_READ_DQS_WIDTH-1:0]  capture_strobe_tracking;

output  phy_clk;
output  phy_reset_n;

input  [MAX_LATENCY_COUNT_WIDTH-1:0]  phy_read_latency_counter;
input           [AFI_WLAT_WIDTH-1:0]  phy_afi_wlat; 
input           [AFI_RLAT_WIDTH-1:0]  phy_afi_rlat; 
input    [MEM_IF_READ_DQS_WIDTH-1:0]  phy_read_increment_vfifo_fr;
input    [MEM_IF_READ_DQS_WIDTH-1:0]  phy_read_increment_vfifo_hr;
input    [MEM_IF_READ_DQS_WIDTH-1:0]  phy_read_increment_vfifo_qr;
input                                 phy_reset_mem_stable;
input   [AFI_DEBUG_INFO_WIDTH - 1:0]  phy_cal_debug_info;
input    [MEM_IF_READ_DQS_WIDTH-1:0]  phy_read_fifo_reset;
input    [MEM_IF_READ_DQS_WIDTH-1:0]  phy_vfifo_rd_en_override;
input                                 phy_cal_success;	// calibration success
input                                 phy_cal_fail;		// calibration failure
output            [AFI_DQ_WIDTH-1:0]  phy_read_fifo_q; 

output         [CALIB_REG_WIDTH-1:0]  calib_skip_steps;



// END PORT SECTION


initial $display("Using %0s core emif simulation models", FAST_SIM_MODEL ? "Fast" : "Regular");


assign afi_cal_success = phy_cal_success;
assign afi_cal_fail = phy_cal_fail;


assign avl_clk = pll_avl_clk;
assign scc_clk = pll_config_clk;




QDRII_SLAVE_example_if1_p0_memphy #(
	.DEVICE_FAMILY(DEVICE_FAMILY),
	.OCT_SERIES_TERM_CONTROL_WIDTH(OCT_TERM_CONTROL_WIDTH),
	.OCT_PARALLEL_TERM_CONTROL_WIDTH(OCT_TERM_CONTROL_WIDTH),
	.MEM_ADDRESS_WIDTH(MEM_IF_ADDR_WIDTH),
	.MEM_CHIP_SELECT_WIDTH(MEM_IF_CS_WIDTH),
	.MEM_DM_WIDTH(MEM_IF_DM_WIDTH),
	.MEM_CONTROL_WIDTH(MEM_IF_CONTROL_WIDTH),
	.MEM_DQ_WIDTH(MEM_IF_DQ_WIDTH),
	.MEM_READ_DQS_WIDTH(MEM_IF_READ_DQS_WIDTH),
	.MEM_WRITE_DQS_WIDTH(MEM_IF_WRITE_DQS_WIDTH),
	.AFI_ADDRESS_WIDTH(AFI_ADDR_WIDTH),
	.AFI_DATA_MASK_WIDTH(AFI_DM_WIDTH),
	.AFI_DQS_WIDTH(AFI_WRITE_DQS_WIDTH),
	.AFI_CONTROL_WIDTH(AFI_CONTROL_WIDTH),
	.AFI_DATA_WIDTH(AFI_DQ_WIDTH),
	.AFI_RATE_RATIO(AFI_RATE_RATIO),
	.DLL_DELAY_CTRL_WIDTH(DLL_DELAY_CTRL_WIDTH),
	.MEM_T_RL(MEM_T_RL),
	.MAX_LATENCY_COUNT_WIDTH(MAX_LATENCY_COUNT_WIDTH),
	.MAX_READ_LATENCY(MAX_READ_LATENCY),
	.READ_VALID_FIFO_SIZE(READ_VALID_FIFO_SIZE),
	.READ_FIFO_SIZE(READ_FIFO_SIZE),
	.MAX_WRITE_LATENCY_COUNT_WIDTH(MAX_WRITE_LATENCY_COUNT_WIDTH),
	.NUM_WRITE_PATH_FLOP_STAGES(NUM_WRITE_PATH_FLOP_STAGES),
	.NUM_WRITE_FR_CYCLE_SHIFTS(NUM_WRITE_FR_CYCLE_SHIFTS),
	.REGISTER_C2P(REGISTER_C2P),	
	.NUM_SUBGROUP_PER_READ_DQS(NUM_SUBGROUP_PER_READ_DQS),
	.QVLD_EXTRA_FLOP_STAGES(QVLD_EXTRA_FLOP_STAGES),
	.QVLD_WR_ADDRESS_OFFSET(QVLD_WR_ADDRESS_OFFSET),
	.NUM_AC_FR_CYCLE_SHIFTS(NUM_AC_FR_CYCLE_SHIFTS),
	.CALIB_REG_WIDTH(CALIB_REG_WIDTH),
	.AFI_DEBUG_INFO_WIDTH(AFI_DEBUG_INFO_WIDTH),
	.TB_PROTOCOL(TB_PROTOCOL),
	.TB_MEM_CLK_FREQ(TB_MEM_CLK_FREQ),
	.TB_RATE(TB_RATE),
	.TB_MEM_DQ_WIDTH(TB_MEM_DQ_WIDTH),
	.TB_MEM_DQS_WIDTH(TB_MEM_DQS_WIDTH),
	.TB_PLL_DLL_MASTER(TB_PLL_DLL_MASTER),
	.FAST_SIM_MODEL(FAST_SIM_MODEL),
	.FAST_SIM_CALIBRATION(FAST_SIM_CALIBRATION),
	.SCC_DATA_WIDTH(SCC_DATA_WIDTH)
) umemphy (
	.global_reset_n(global_reset_n),
	.soft_reset_n(soft_reset_n & ~csr_soft_reset_req),
	.ctl_reset_n(afi_reset_n),
	.ctl_reset_export_n(afi_reset_export_n),
	.pll_locked(pll_locked),
	.oct_ctl_rt_value(parallelterminationcontrol),
	.oct_ctl_rs_value(seriesterminationcontrol),
	.afi_addr(afi_addr),
	.afi_wps_n(afi_wps_n),
	.afi_rps_n(afi_rps_n),
	.afi_doff_n(afi_doff_n),
	.afi_wdata(afi_wdata),
	.afi_wdata_valid(afi_wdata_valid),
	.afi_dm(afi_bws_n),
	.afi_rdata(afi_rdata),
	.afi_rdata_en(afi_rdata_en),
	.afi_rdata_en_full(afi_rdata_en_full),
	.afi_rdata_valid(afi_rdata_valid),
	.afi_cal_success(afi_cal_success),
	.afi_cal_fail(afi_cal_fail),
	.mem_d(mem_d),
	.mem_wps_n(mem_wps_n),
	.mem_bws_n(mem_bws_n),
	.mem_a(mem_a),
	.mem_rps_n(mem_rps_n),
	.mem_doff_n(mem_doff_n),
	.mem_k(mem_k),
	.mem_k_n(mem_k_n),
	.mem_cq(mem_cq),
	.mem_cq_n(mem_cq_n),
	.mem_q(mem_q),
	.pll_afi_clk(afi_clk),
	.pll_mem_clk(pll_mem_clk),
	.pll_write_clk(pll_write_clk),
	.pll_write_clk_pre_phy_clk(pll_write_clk_pre_phy_clk),
	.pll_addr_cmd_clk(pll_addr_cmd_clk),
	.pll_afi_half_clk(afi_half_clk),
	.pll_p2c_read_clk(pll_p2c_read_clk),
	.pll_c2p_write_clk(pll_c2p_write_clk),
	.seq_clk(afi_clk), 
	.reset_n_avl_clk(avl_reset_n),
	.reset_n_scc_clk(scc_reset_n),
	.scc_data(scc_data),
	.scc_dqs_ena(scc_dqs_ena),
	.scc_dqs_io_ena(scc_dqs_io_ena),
	.scc_dq_ena(scc_dq_ena),
	.scc_dm_ena(scc_dm_ena),
	.scc_upd(scc_upd),
	.capture_strobe_tracking(capture_strobe_tracking),
	.phy_clk(phy_clk),
	.phy_reset_n(phy_reset_n),
	.phy_read_latency_counter(phy_read_latency_counter),
	.phy_read_increment_vfifo_fr(phy_read_increment_vfifo_fr),
	.phy_read_increment_vfifo_hr(phy_read_increment_vfifo_hr),
	.phy_read_increment_vfifo_qr(phy_read_increment_vfifo_qr),
	.phy_reset_mem_stable(phy_reset_mem_stable),
	.phy_cal_debug_info(phy_cal_debug_info),
	.phy_read_fifo_reset(phy_read_fifo_reset),
	.phy_vfifo_rd_en_override(phy_vfifo_rd_en_override),
	.phy_read_fifo_q(phy_read_fifo_q),
	.calib_skip_steps(calib_skip_steps),
	.pll_avl_clk(pll_avl_clk),
	.pll_config_clk(pll_config_clk),

	.dll_clk(dll_clk),
	.dll_pll_locked(dll_pll_locked),
	.dll_phy_delayctrl(dll_delayctrl)
);


endmodule

