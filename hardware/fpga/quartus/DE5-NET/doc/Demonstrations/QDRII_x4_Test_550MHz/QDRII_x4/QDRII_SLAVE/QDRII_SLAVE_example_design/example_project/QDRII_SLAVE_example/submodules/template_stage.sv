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
// This is an example test stage, which issues write and read commands with
// progressing number of cycles between commands.  This test is to target the
// burst adaptor of the memory controller.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module template_stage(
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

// The total number of write tests
parameter NUM_TESTS						= "";

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// The number of cycles to pause between writes
localparam MAX_T_RC_CYCLES			= 10;
localparam MAX_PAUSE_BETWEEN_WRITES = 11;
localparam MAX_NUM_PAUSE_CYCLES		= max(MAX_T_RC_CYCLES, MAX_PAUSE_BETWEEN_WRITES);

// Counter widths
localparam NUM_TEST_COUNTER_WIDTH	= log2(NUM_TESTS) + 1;
localparam RW_PAUSE_COUNTER_WIDTH	= log2(MAX_NUM_PAUSE_CYCLES) + 1;

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

// Counters
reg [NUM_TEST_COUNTER_WIDTH-1:0]	num_test_counter;
reg	[RW_PAUSE_COUNTER_WIDTH-1:0]	rw_counter;
reg [RW_PAUSE_COUNTER_WIDTH-1:0]	pause_counter;

// Write/read state machine
enum int unsigned {
	INIT,
	WRITE1,
	WRITE2,
	READ1,
	READ2,
	WAIT,
	DONE
} state;


always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		num_test_counter <= '0;
		rw_counter <= '0;
		pause_counter <= '0;
		state <= INIT;
	end
	else
	begin
		case (state)
			INIT:
				// Standby until this stage is signaled to start
				if (stage_enable)
				begin
					pause_counter <= MAX_T_RC_CYCLES[RW_PAUSE_COUNTER_WIDTH-1:0];
					if (num_test_counter == NUM_TESTS)
						state <= DONE;
					else
						state <= WRITE1;
				end

			WRITE1:
				// Issue the first write command when pause_counter expires
				if (pause_counter == 0)
				begin
					if (can_write)
					begin
						pause_counter <= rw_counter;
						state <= WRITE2;
					end
				end
				else
				begin
					pause_counter <= pause_counter - 1'b1;
				end

			WRITE2:
				// Issue the second write command when pause_counter expires
				if (pause_counter == 0)
				begin
					if (can_write)
					begin
						pause_counter <= MAX_T_RC_CYCLES[RW_PAUSE_COUNTER_WIDTH-1:0];
						state <= READ1;
					end
				end
				else
				begin
					pause_counter <= pause_counter - 1'b1;
				end

			READ1:
				// Issue the first read command when pause_counter expires
				if (pause_counter == 0)
				begin
					if (can_read)
					begin
						pause_counter <= rw_counter;
						state <= READ2;
					end
				end
				else
				begin
					pause_counter <= pause_counter - 1'b1;
				end

			READ2:
				// Issue the second read command when pause_counter expires
				if (pause_counter == 0)
				begin
					if (can_read)
					begin
						pause_counter <= MAX_T_RC_CYCLES[RW_PAUSE_COUNTER_WIDTH-1:0];
						if (rw_counter == MAX_PAUSE_BETWEEN_WRITES)
						begin
							rw_counter <= '0;
							num_test_counter <= num_test_counter + 1'b1;
							if (num_test_counter == NUM_TESTS - 1)
								state <= WAIT;
							else
								state <= WRITE1;
						end
						else
						begin
							rw_counter <= rw_counter + 1'b1;
							state <= WRITE1;
						end
					end
				end
				else
				begin
					pause_counter <= pause_counter - 1'b1;
				end

			WAIT:
				if (read_compare_fifo_empty)
					// All read data have returned and verified
					state <= DONE;

			DONE:
			begin
				num_test_counter <= '0;
				rw_counter <= '0;
				pause_counter <= '0;
				state <= INIT;
			end
		endcase
	end
end


// Command outputs
assign do_write = (state == WRITE1 | state == WRITE2) & pause_counter == '0 & can_write;
assign do_read = (state == READ1 | state == READ2) & pause_counter == '0 & can_read;


// Status outputs
assign addr_gen_select = TEMPLATE_ADDR_GEN;
assign stage_complete = (state == DONE);


endmodule

