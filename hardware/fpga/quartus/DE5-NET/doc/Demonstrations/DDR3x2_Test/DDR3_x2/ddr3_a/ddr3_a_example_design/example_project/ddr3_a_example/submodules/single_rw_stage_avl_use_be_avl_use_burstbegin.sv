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
// The single write/read test stage performs a parametrizable number of
// interleaving write and read operation.  The number of write/read cycles
// that various address generators are used are parametrizable.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module single_rw_stage_avl_use_be_avl_use_burstbegin (
	clk,
	reset_n,
	can_write,
	can_read,
	read_compare_fifo_empty,
	addr_gen_select,
	do_write,
	do_read,
	stage_enable,
	stage_complete
);

import driver_definitions::*;

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// The number of write/read cycles that each address generator is used
parameter SEQ_ADDR_COUNT				= "";
parameter RAND_ADDR_COUNT				= "";
parameter RAND_SEQ_ADDR_COUNT			= "";

// Should the stage wait for all read data to come back before switching
// address generators? This is typically used for protocols such as QDR II.
parameter USE_BLOCKING_ADDRESS_GENERATION = 0;
// END PARAMETER SECTION

//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// The total number of write/read cycles
localparam NUM_SINGLE_WRITES			= SEQ_ADDR_COUNT + RAND_ADDR_COUNT + RAND_SEQ_ADDR_COUNT;

// Counter width
localparam SINGLE_WRITE_COUNTER_WIDTH	= log2(NUM_SINGLE_WRITES) + 1;

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset
input						clk;
input						reset_n;

// can_write and can_read indicates whether a do_write or do_read can be issued
input						can_write;
input						can_read;

// Read compare status
input						read_compare_fifo_empty;

// Address generator selector
output	addr_gen_select_t	addr_gen_select;

// Command outputs
output						do_write;
output						do_read;

// Control and status
input						stage_enable;
output						stage_complete;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// Command outputs
logic	do_write;
logic	do_read;

// Counters
reg	[SINGLE_WRITE_COUNTER_WIDTH-1:0]	single_write_counter;

// Block write/read state machine
enum int unsigned {
	INIT,
	SINGLE_WRITE,
	SINGLE_READ,
	WAIT,
	DONE
} state;


always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		single_write_counter <= '0;
		if (SEQ_ADDR_COUNT > 0)
			addr_gen_select <= SEQ;
		else if (SEQ_ADDR_COUNT + RAND_ADDR_COUNT > 0)
			addr_gen_select <= RAND;
		else
			addr_gen_select <= RAND_SEQ;
		state <= INIT;
	end
	else
	begin
		case (state)
			INIT:
				// Standby until this stage is signaled to start
				if (NUM_SINGLE_WRITES <= 0)
					state <= DONE;
				else if (stage_enable)
					state <= SINGLE_WRITE;

			SINGLE_WRITE:
				// Issue a single write command in this state
				if (can_write)
				begin
					single_write_counter <= single_write_counter + 1'b1;
					if (single_write_counter + 1'b1 < SEQ_ADDR_COUNT)
						addr_gen_select <= SEQ;
					else if (single_write_counter + 1'b1 < SEQ_ADDR_COUNT + RAND_ADDR_COUNT)
						addr_gen_select <= RAND;
					else
						addr_gen_select <= RAND_SEQ;
					state <= SINGLE_READ;
				end

			SINGLE_READ:
			begin
				// Issue a single read command in this state
				if (can_read)
				begin
					if (single_write_counter == NUM_SINGLE_WRITES)
						// All commands have been issued
						state <= WAIT;
					else
						state <= SINGLE_WRITE;
				end
			end

			WAIT:
			begin
				if (read_compare_fifo_empty)
					// All read data have returned
					state <= DONE;
			end

			DONE:
			begin
				single_write_counter <= '0;
				if (SEQ_ADDR_COUNT > 0)
					addr_gen_select <= SEQ;
				else if (SEQ_ADDR_COUNT + RAND_ADDR_COUNT > 0)
					addr_gen_select <= RAND;
				else
					addr_gen_select <= RAND_SEQ;
				state <= INIT;
			end
		endcase
	end
end


// Command outputs
always_comb
begin
	do_write <= 1'b0;
	do_read <= 1'b0;
	case (state)
		SINGLE_WRITE:	if (can_write) do_write <= 1'b1;
		SINGLE_READ:	if (can_read) do_read <= 1'b1;
		default:		; 
	endcase
end


// Status outputs
assign stage_complete = (state == DONE);


endmodule

