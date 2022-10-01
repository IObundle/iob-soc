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


//////////////////////////////////////////////////////////////////////////////
// This is the top level module of the QDR II/II+ Memory Controller.
//////////////////////////////////////////////////////////////////////////////

module QDRII_D_c0_alt_qdr_controller(
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
	local_init_done
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter DEVICE_FAMILY		= "";

// MEMORY TIMING PARAMETERS
// Write latency in memory cycles
parameter MEM_T_WL			= "";

// AFI 2.0 INTERFACE PARAMETERS
parameter AFI_ADDR_WIDTH	= "";
parameter AFI_CS_WIDTH		= "";
parameter AFI_DM_WIDTH		= "";
parameter AFI_DQ_WIDTH		= "";
parameter AFI_WRITE_DQS_WIDTH = "";
parameter AFI_CONTROL_WIDTH = "";

// CONTROLLER PARAMETERS
parameter CTL_ADDR_WIDTH	= "";
parameter CTL_CS_WIDTH		= "";

// AVALON INTERFACE PARAMETERS
parameter AVL_ADDR_WIDTH	= "";
parameter AVL_SIZE_WIDTH	= "";
parameter AVL_BE_WIDTH		= "";
parameter AVL_DATA_WIDTH		= "";

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// Timing properties in controller cycles
localparam CTL_T_WL			= MEM_T_WL / 2;

// END LOCALPARAM SECTION

// The number of resynchronized resets to create at this level
localparam NUM_CONTROLLER_RESET = 6;


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

output							afi_rdata_en;
output							afi_rdata_en_full;

input	[AFI_DQ_WIDTH-1:0]		afi_rdata;
input							afi_rdata_valid;
input							afi_cal_success;
input							afi_cal_fail;
output							local_init_done;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// Resynchronized reset signal
wire	[NUM_CONTROLLER_RESET-1:0]	resync_afi_reset_n;

// User interface module signals
wire							data_if_write_req;
wire							data_if_read_req;
wire	[CTL_ADDR_WIDTH-1:0]	data_if_write_addr;
wire	[CTL_ADDR_WIDTH-1:0]	data_if_read_addr;
wire	[AVL_DATA_WIDTH-1:0]		data_if_wdata;
wire							data_if_rdata_valid;
wire	[AVL_DATA_WIDTH-1:0]		data_if_rdata;

// State machine command outputs
wire							do_write;
wire							do_read;
wire							pop_req;

// Create a synchronized version of the reset against the controller clock
QDRII_D_c0_reset_sync	ureset_afi_clk(
	.reset_n		(afi_reset_n),
	.clk			(afi_clk),
	.reset_n_sync	(resync_afi_reset_n)
);
defparam ureset_afi_clk.NUM_RESET_OUTPUT = NUM_CONTROLLER_RESET;


// Avalon read interface module
QDRII_D_c0_memctl_data_if data_if_r (
	.clk					(afi_clk),
	.reset_n				(resync_afi_reset_n[0]),
	.init_complete			(afi_cal_success),
	.init_fail				(afi_cal_fail),
    .local_init_done        (),
	.avl_ready				(avl_r_ready),
	.avl_write_req			(1'b0),
	.avl_read_req			(avl_r_read_req),
	.avl_addr				(avl_r_addr),
	.avl_size				(avl_r_size),
	.avl_wdata				({AVL_DATA_WIDTH{1'b0}}),
	.avl_rdata_valid		(avl_r_rdata_valid),
	.avl_rdata				(avl_r_rdata),
	.cmd1_write_req			(),
	.cmd1_read_req			(data_if_read_req),
	.cmd1_addr				(data_if_read_addr),
	.cmd1_addr_can_merge	(),
	.cmd1_wdata				(),
	.rdata_valid			(data_if_rdata_valid),
	.rdata					(data_if_rdata),
	.pop_req				(pop_req));
defparam data_if_r.AVL_ADDR_WIDTH	= AVL_ADDR_WIDTH;
defparam data_if_r.AVL_SIZE_WIDTH	= AVL_SIZE_WIDTH;
defparam data_if_r.AVL_DWIDTH		= AVL_DATA_WIDTH;
defparam data_if_r.BEATADDR_WIDTH	= 0;


// Avalon write interface module
QDRII_D_c0_memctl_data_if data_if_w (
	.clk					(afi_clk),
	.reset_n				(resync_afi_reset_n[1]),
	.init_complete			(afi_cal_success),
	.init_fail				(afi_cal_fail),
    .local_init_done        (local_init_done),
	.avl_ready				(avl_w_ready),
	.avl_write_req			(avl_w_write_req),
	.avl_read_req			(1'b0),
	.avl_addr				(avl_w_addr),
	.avl_size				(avl_w_size),
	.avl_wdata				(avl_w_wdata),
	.avl_rdata_valid		(),
	.avl_rdata				(),
	.cmd1_write_req			(data_if_write_req),
	.cmd1_read_req			(),
	.cmd1_addr				(data_if_write_addr),
	.cmd1_addr_can_merge	(),
	.cmd1_wdata				(data_if_wdata),
	.rdata_valid			(1'b0),
	.rdata					({AVL_DATA_WIDTH{1'b0}}),
	.pop_req				(do_write));
defparam data_if_w.AVL_ADDR_WIDTH	= AVL_ADDR_WIDTH;
defparam data_if_w.AVL_SIZE_WIDTH	= AVL_SIZE_WIDTH;
defparam data_if_w.AVL_DWIDTH		= AVL_DATA_WIDTH;
defparam data_if_w.BEATADDR_WIDTH	= 0;


// Main state machine
QDRII_D_c0_alt_qdr_fsm fsm_r (
	.clk			(afi_clk),
	.reset_n		(resync_afi_reset_n[2]),
	.init_complete	(afi_cal_success),
	.init_fail		(afi_cal_fail),
	.write_req		(data_if_write_req),
	.read_req		(data_if_read_req),
	.do_read		(do_read));

QDRII_D_c0_alt_qdr_fsm fsm_pop_req (
	.clk			(afi_clk),
	.reset_n		(resync_afi_reset_n[3]),
	.init_complete	(afi_cal_success),
	.init_fail		(afi_cal_fail),
	.write_req		(data_if_write_req),
	.read_req		(data_if_read_req),
	.do_read		(pop_req));
	
QDRII_D_c0_alt_qdr_fsm fsm_w (
	.clk			(afi_clk),
	.reset_n		(resync_afi_reset_n[4]),
	.init_complete	(afi_cal_success),
	.init_fail		(afi_cal_fail),
	.write_req		(data_if_write_req),
	.read_req		(data_if_read_req),
	.do_write		(do_write));	

// AFI 2.0 interface module
QDRII_D_c0_alt_qdr_afi afi (
	.clk				(afi_clk),
	.reset_n			(resync_afi_reset_n[5]),
	.do_write			(do_write),
	.do_read			(do_read),
	.write_addr			(data_if_write_addr),
	.read_addr			(data_if_read_addr),
	.wdata				(data_if_wdata),
	.rdata_valid		(data_if_rdata_valid),
	.rdata				(data_if_rdata),
	.afi_addr			(afi_addr),
	.afi_wps_n			(afi_wps_n),
	.afi_rps_n			(afi_rps_n),
	.afi_wdata_valid	(afi_wdata_valid),
	.afi_wdata			(afi_wdata),
	.afi_bws_n				(afi_bws_n),
	.afi_rdata_en		(afi_rdata_en),
	.afi_rdata_en_full		(afi_rdata_en_full),
	.afi_rdata			(afi_rdata),
	.afi_rdata_valid	(afi_rdata_valid));
defparam afi.CTL_ADDR_WIDTH	= CTL_ADDR_WIDTH;
defparam afi.CTL_CS_WIDTH	= CTL_CS_WIDTH;
defparam afi.CTL_DWIDTH		= AVL_DATA_WIDTH;
defparam afi.CTL_T_WL		= CTL_T_WL;
defparam afi.AFI_ADDR_WIDTH	= AFI_ADDR_WIDTH;
defparam afi.AFI_CS_WIDTH	= AFI_CS_WIDTH;
defparam afi.AFI_DM_WIDTH	= AFI_DM_WIDTH;
defparam afi.AFI_DWIDTH		= AFI_DQ_WIDTH;
defparam afi.AFI_WRITE_DQS_WIDTH = AFI_WRITE_DQS_WIDTH;
defparam afi.AFI_CONTROL_WIDTH = AFI_CONTROL_WIDTH;




endmodule

