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


// Transceiver Reconfiguration Module placeholder for Stratix V architectures
//
// For transceiver reconfiguration, instantiate the alt_xcvr_reconfig controller

// $Header$

`timescale 1 ns / 1 ns

module alt_xcvr_reconfig_sv (
	input  wire        mgmt_clk_clk,              //             mgmt_clk.clk
	input  wire        mgmt_rst_reset,            //             mgmt_rst.reset

	// user reconfiguration management interface
	input  wire [6:0]  reconfig_mgmt_address,     //        reconfig_mgmt.address
	output wire        reconfig_mgmt_waitrequest, //                     .waitrequest
	input  wire        reconfig_mgmt_read,        //                     .read
	output wire [31:0] reconfig_mgmt_readdata,    //                     .readdata
	input  wire        reconfig_mgmt_write,       //                     .write
	input  wire [31:0] reconfig_mgmt_writedata,   //                     .writedata
	output wire        reconfig_done,             //        reconfig_done.export

	// master interface to basic reconfiguration block inside the transceiver channel
	output wire [4:0]  basic_address,     //   basic.address    // master interface must include 2 lower addr bits
	input  wire        basic_waitrequest, //        .waitrequest
	input  wire        basic_irq,         //        .irq
	output wire        basic_read,        //        .read
	input  wire [31:0] basic_readdata,    //        .readdata
	output wire        basic_write,       //        .write
	output wire [31:0] basic_writedata,   //        .writedata
	
	// native testbus input
	input  wire [15:0] testbus_data
);


	///////////////////////////////////////////
	// Outputs to mgmt interface
	///////////////////////////////////////////
	assign reconfig_mgmt_readdata = ~0;
	assign reconfig_mgmt_waitrequest = 1'b0;

	///////////////////////////////////////////
	// Status to external mgmt interface
	///////////////////////////////////////////
	assign reconfig_done = 1'b1;

	///////////////////////////////////////////
	// Outputs to basic block
	///////////////////////////////////////////
	assign basic_address = 5'd0;
	assign basic_read = 1'b0;
	assign basic_write = 1'b0;
	assign basic_writedata = 32'd0;

endmodule
