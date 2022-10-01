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


//////////////////////////////////////////////////////////////////////////////
// This module is a wrapper for the scfifo.  Some scfifo parameters are
// derived here.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module scfifo_wrapper(
	clk,
	reset_n,
	write_req,
	read_req,
	data_in,
	data_out,
	full,
	empty
);

import driver_definitions::*;

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter DEVICE_FAMILY		= "";
parameter FIFO_WIDTH		= "";
parameter FIFO_SIZE			= "";
parameter SHOW_AHEAD		= "";
parameter ENABLE_PIPELINE   = 1;


// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// FIFO address width
localparam FIFO_WIDTHU			= ceil_log2(FIFO_SIZE);

// Actual FIFO size
localparam FIFO_NUMWORDS		= 2 ** FIFO_WIDTHU;

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset
input						clk;
input						reset_n;

// Controls
input						write_req;
input						read_req;

// Data
input	[FIFO_WIDTH-1:0]	data_in;
output	[FIFO_WIDTH-1:0]	data_out;

// Status
output						full;
output						empty;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

wire	[FIFO_WIDTH-1:0]	data_in_wire;
wire                     write_req_wire;
wire almost_full;
wire total_full;

generate
	if (ENABLE_PIPELINE == 1) begin
		reg	[FIFO_WIDTH-1:0]	data_in_reg;
		reg                     write_req_reg;
		
		always_ff @ (posedge clk or negedge reset_n)
			if (~reset_n) begin
				write_req_reg <= 1'b0;
			end
			else begin
				data_in_reg <= data_in;
				write_req_reg <= write_req;
			end
		
		assign write_req_wire = write_req_reg;
		assign data_in_wire = data_in_reg;
		assign full = almost_full;
	end
	else begin
		assign write_req_wire = write_req;
		assign data_in_wire = data_in;
		assign full = total_full;
	end



    if (FIFO_SIZE > 0)
    begin
        scfifo #
        	(
        		.intended_device_family(DEVICE_FAMILY),
        		.lpm_width(FIFO_WIDTH),
        		.lpm_widthu(FIFO_WIDTHU),
        		.lpm_numwords(FIFO_NUMWORDS),
        		.lpm_showahead(SHOW_AHEAD),
        		.almost_full_value(FIFO_NUMWORDS > 2 ? FIFO_NUMWORDS-2 : 1), 
        		.use_eab("ON"),
        		.overflow_checking("OFF"),
        		.underflow_checking("OFF")
        	)
        	scfifo_inst 
        	(
        	.rdreq			(read_req),
        	.aclr			(!reset_n),
        	.clock			(clk),
        	.wrreq			(write_req_wire),
        	.data			(data_in_wire),
        	.full			(total_full),
        	.q				(data_out),
        	.sclr			(1'b0),
        	.usedw			(),
        	.empty			(empty),
        	.almost_full	(almost_full),
        	.almost_empty	());
    end
    else
    begin
        assign total_full = 1'b0;
        assign data_out = '0;
        assign empty    = 1'b1;
        assign almost_full = 1'b0;
    end

endgenerate
endmodule

