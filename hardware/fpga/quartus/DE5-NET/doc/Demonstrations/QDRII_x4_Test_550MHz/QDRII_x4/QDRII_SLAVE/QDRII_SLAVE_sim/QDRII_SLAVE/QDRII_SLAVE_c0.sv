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


(* altera_attribute = "-name IP_TOOL_NAME altera_mem_if_qdrii_controller; -name IP_TOOL_VERSION 11.1; -name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 100" *)
module QDRII_SLAVE_c0 (
	afi_clk,
	afi_reset_n,
	avl_w_ready,
	avl_w_write_req,
	avl_w_addr,
	avl_w_size,
	avl_w_wdata,
	avl_r_ready,
	avl_r_read_req,
	avl_r_addr,
	avl_r_size,
	avl_r_rdata_valid,
	avl_r_rdata,
	afi_addr,
	afi_wps_n,
	afi_rps_n,
	afi_wdata_valid,
	afi_wdata,
	afi_bws_n,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata,
	afi_rdata_valid,
	afi_cal_success,
	afi_cal_fail,
	local_init_done,
	local_cal_success,
	local_cal_fail
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter DEVICE_FAMILY		= "Stratix V";

// MEMORY TIMING PARAMETERS
// Write latency in memory cycles
parameter MEM_T_WL			= 1;

// AFI 2.0 INTERFACE PARAMETERS
parameter AFI_ADDR_WIDTH	= 40;
parameter AFI_CS_WIDTH		= 2;
parameter AFI_DM_WIDTH		= 8;
parameter AFI_DQ_WIDTH		= 72;
parameter AFI_CONTROL_WIDTH = 2;
parameter AFI_RATE_RATIO    = 2;

// CONTROLLER PARAMETERS
parameter CTL_ADDR_WIDTH	= 20;
parameter CTL_CS_WIDTH		= 1;

// AVALON INTERFACE PARAMETERS
parameter AVL_ADDR_WIDTH	= 20;
parameter AVL_SIZE_WIDTH	= 3;
parameter AVL_BE_WIDTH		= 8;
parameter AVL_DATA_WIDTH		= 72;
parameter AFI_WRITE_DQS_WIDTH = 2;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input							afi_clk;
input							afi_reset_n;

// Avalon data slave write interface
output							avl_w_ready;
input							avl_w_write_req;
input	[AVL_ADDR_WIDTH-1:0]	avl_w_addr;
input	[AVL_SIZE_WIDTH-1:0]	avl_w_size;
input	[AVL_DATA_WIDTH-1:0]		avl_w_wdata;

// Avalon data slave read interface
output							avl_r_ready;
input							avl_r_read_req;
input	[AVL_ADDR_WIDTH-1:0]	avl_r_addr;
input	[AVL_SIZE_WIDTH-1:0]	avl_r_size;
output							avl_r_rdata_valid;
output	[AVL_DATA_WIDTH-1:0]		avl_r_rdata;

// AFI 2.0 interface
output	[AFI_ADDR_WIDTH-1:0]	afi_addr;
output	[AFI_CONTROL_WIDTH-1:0]		afi_wps_n;
output	[AFI_CONTROL_WIDTH-1:0]		afi_rps_n;
output	[AFI_WRITE_DQS_WIDTH-1:0] afi_wdata_valid;
output	[AFI_DQ_WIDTH-1:0]		afi_wdata;
output	[AFI_DM_WIDTH-1:0]		afi_bws_n;

output	[AFI_RATE_RATIO-1:0]	afi_rdata_en;
output	[AFI_RATE_RATIO-1:0]	afi_rdata_en_full;

input	[AFI_DQ_WIDTH-1:0]		afi_rdata;
input	[AFI_RATE_RATIO-1:0]	afi_rdata_valid;
input							afi_cal_success;
input							afi_cal_fail;
output							local_init_done;
output							local_cal_success;
output							local_cal_fail;

QDRII_SLAVE_c0_alt_qdr_controller # (
	.DEVICE_FAMILY(DEVICE_FAMILY),
	.MEM_T_WL(MEM_T_WL),
	.AFI_ADDR_WIDTH(AFI_ADDR_WIDTH),
	.AFI_CONTROL_WIDTH(AFI_CONTROL_WIDTH),
	.AFI_CS_WIDTH(AFI_CS_WIDTH),
	.AFI_DM_WIDTH(AFI_DM_WIDTH),
	.AFI_DQ_WIDTH(AFI_DQ_WIDTH),
	.CTL_ADDR_WIDTH(CTL_ADDR_WIDTH),
	.CTL_CS_WIDTH(CTL_CS_WIDTH),
	.AVL_ADDR_WIDTH(AVL_ADDR_WIDTH),
	.AVL_SIZE_WIDTH(AVL_SIZE_WIDTH),
	.AVL_BE_WIDTH(AVL_BE_WIDTH),
	.AVL_DATA_WIDTH(AVL_DATA_WIDTH),
	.AFI_WRITE_DQS_WIDTH(AFI_WRITE_DQS_WIDTH)
) controller_inst (
	.afi_clk(afi_clk),
	.afi_reset_n(afi_reset_n),
	.avl_w_ready(avl_w_ready),
	.avl_w_write_req(avl_w_write_req),
	.avl_w_addr(avl_w_addr),
	.avl_w_size(avl_w_size),
	.avl_w_wdata(avl_w_wdata),
	.avl_r_ready(avl_r_ready),
	.avl_r_read_req(avl_r_read_req),
	.avl_r_addr(avl_r_addr),
	.avl_r_size(avl_r_size),
	.avl_r_rdata_valid(avl_r_rdata_valid),
	.avl_r_rdata(avl_r_rdata),
	.afi_addr(afi_addr),
	.afi_wps_n(afi_wps_n),
	.afi_rps_n(afi_rps_n),
	.afi_wdata_valid(afi_wdata_valid),
	.afi_wdata(afi_wdata),
	.afi_bws_n(afi_bws_n),
	.afi_rdata_en(afi_rdata_en),
	.afi_rdata_en_full(afi_rdata_en_full),
	.afi_rdata(afi_rdata),
	.afi_rdata_valid(afi_rdata_valid),
	.afi_cal_success(afi_cal_success),
	.afi_cal_fail(afi_cal_fail),
	.local_init_done(local_init_done)
);

assign local_cal_success = afi_cal_success;
assign local_cal_fail = afi_cal_fail;


endmodule

