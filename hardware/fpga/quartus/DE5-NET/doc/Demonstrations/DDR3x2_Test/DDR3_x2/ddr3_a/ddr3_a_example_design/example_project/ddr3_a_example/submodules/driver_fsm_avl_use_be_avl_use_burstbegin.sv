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
// The driver state machine controls the test stages modules, and multiplexes
// the signals into and out of the active stage module.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module driver_fsm_avl_use_be_avl_use_burstbegin (
	clk,
	reset_n,
	can_write,
	can_read,
	read_compare_fifo_full,
	read_compare_fifo_empty,
	addr_gen_select,
	do_write,
	do_read,
	test_complete,
	loop_counter,
	timeout
);

import driver_definitions::*;

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// Single write/read stage
parameter SINGLE_RW_SEQ_ADDR_COUNT		= "";
parameter SINGLE_RW_RAND_ADDR_COUNT		= "";
parameter SINGLE_RW_RAND_SEQ_ADDR_COUNT	= "";

// Block write/read stage
parameter BLOCK_RW_SEQ_ADDR_COUNT		= "";
parameter BLOCK_RW_RAND_ADDR_COUNT		= "";
parameter BLOCK_RW_RAND_SEQ_ADDR_COUNT	= "";
parameter BLOCK_RW_BLOCK_SIZE			= "";

// Template stage
parameter TEMPLATE_STAGE_COUNT			= "";

// Timeout counter width
// If the test stages are modified, this parameter
// may need adjustment to avoid premature timeouts.
parameter TIMEOUT_COUNTER_WIDTH			= "";

// NUM_DRIVER_LOOP
// Specifies the maximum number of loops through the driver patterns
// before asserting test complete. A setting of 0 will cause the driver to
// loop infinitely.
parameter NUM_DRIVER_LOOP               = "";

// Should the stage wait for all read data to come back before switching
// address generators? This is typically used for protocols such as QDR II.
parameter USE_BLOCKING_ADDRESS_GENERATION = 0;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset
input							clk;
input							reset_n;

// can_write and can_read indicates whether a do_write or do_read can be issued
input							can_write;
input							can_read;

// Read compare status
input							read_compare_fifo_full;
input							read_compare_fifo_empty;

// Address generator selector
output	addr_gen_select_t		addr_gen_select;

// Command outputs
output							do_write;
output							do_read;

// Driver status
output							test_complete;
output							timeout;
output reg [31:0]               loop_counter;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// Test stages definition
typedef enum int unsigned {
	INIT,
	SINGLE_RW,
	BLOCK_RW,
	TEMPLATE_STAGE,
	DONE,
	TEST_COMPLETE,
	TIMEOUT
} test_stage_t;

// Command outputs
logic							do_write;
logic							do_read;

// Single write/read stage signals
addr_gen_select_t				single_rw_addr_gen_select;
wire							single_rw_do_write;
wire							single_rw_do_read;
wire							single_rw_complete;

// Block write/read stage signals
addr_gen_select_t				block_rw_addr_gen_select;
wire							block_rw_do_write;
wire							block_rw_do_read;
wire							block_rw_complete;

// Template stage signals
addr_gen_select_t				template_stage_addr_gen_select;
wire							template_stage_do_write;
wire							template_stage_do_read;
wire							template_stage_complete;

// Timeout counter
reg	[TIMEOUT_COUNTER_WIDTH:0]	timeout_counter;

// Test stages
test_stage_t					stage;

// Generate status signals
assign test_complete = (stage == TEST_COMPLETE) | (stage == TIMEOUT);
assign timeout = (stage == TIMEOUT);


// Test stages signals mux
always_comb
begin
	case (stage)
		SINGLE_RW:
		begin
			addr_gen_select <= single_rw_addr_gen_select;
			do_write <= single_rw_do_write;
			do_read <= single_rw_do_read;
		end

		BLOCK_RW:
		begin
			addr_gen_select <= block_rw_addr_gen_select;
			do_write <= block_rw_do_write;
			do_read <= block_rw_do_read;
		end

		TEMPLATE_STAGE:
		begin
			addr_gen_select <= template_stage_addr_gen_select;
			do_write <= template_stage_do_write;
			do_read <= template_stage_do_read;
		end

		default:
		begin
			addr_gen_select <= addr_gen_select.first();
			do_write <= 1'b0;
			do_read <= 1'b0;
		end
	endcase
end


// Test stages state machine
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		timeout_counter <= '0;
		stage <= INIT;
		loop_counter <= '0;
	end
	else
	begin
		// Always increment timeout counter
		timeout_counter <= timeout_counter + 1'b1;
		
		if (timeout_counter[TIMEOUT_COUNTER_WIDTH])
		begin
			// All test stages fail to complete within 2**TIMEOUT_COUNTER_WIDTH+1 cycles
			stage <= TIMEOUT;
		end
		else if (read_compare_fifo_full)
		begin
			// The read compare FIFO should not fill up
			// Try increasing the FIFO size and test again
			stage <= TIMEOUT;
		end
		else
		begin
			case (stage)
				INIT:
				begin
					// Start test immediately after reset_n is deasserted
					timeout_counter <= '0;
					stage <= SINGLE_RW;

					// Increment the loop counter
					loop_counter <= loop_counter + 1'b1;
				end

				SINGLE_RW:
					// Perform single write/read test
					if (single_rw_complete)
						stage <= BLOCK_RW;

				BLOCK_RW:
					// Perform block write/read test
					if (block_rw_complete)
						stage <= TEMPLATE_STAGE;

				TEMPLATE_STAGE:
					// Perform block write/read test
					if (template_stage_complete)
						stage <= DONE;

				DONE:
					begin
					if (NUM_DRIVER_LOOP == 0) begin
						// A setting of 0 means loop forever
						stage <= INIT;
					end
					else if (loop_counter < NUM_DRIVER_LOOP) begin
						// The loop limit has not yet been reached
						stage <= INIT;
					end
					else begin
						// The loop limit has been reached. 
						stage <= TEST_COMPLETE;
					end
					end

				TEST_COMPLETE:
					begin
					timeout_counter <= '0;
					stage <= TEST_COMPLETE;
					end

				TIMEOUT:
					begin
					timeout_counter <= '0;
					stage <= TIMEOUT;
					end
			endcase
		end
	end
end


// TEST STAGE MODULE INSTANTIATIONS
// These modules should comply with the following protocol:
// - when 'reset_n' is deasserted, it should idle and listen to 'stage_enable'
// - it should proceed with the test operations when 'stage_enable' is asserted
// - when the test completes, it should assert either 'stage_complete' or 'stage_timeout'


// Single write/read test stage
//AVL_USE_BE,AVL_USE_BURSTBEGIN
single_rw_stage_avl_use_be_avl_use_burstbegin single_rw_stage_inst (

.clk						(clk),
	.reset_n					(reset_n),
	.can_write					(can_write),
	.can_read					(can_read),
	.read_compare_fifo_empty	(read_compare_fifo_empty),
	.addr_gen_select			(single_rw_addr_gen_select),
	.do_write					(single_rw_do_write),
	.do_read					(single_rw_do_read),
	.stage_enable				((stage == SINGLE_RW)),
	.stage_complete				(single_rw_complete));
defparam single_rw_stage_inst.SEQ_ADDR_COUNT		= SINGLE_RW_SEQ_ADDR_COUNT;
defparam single_rw_stage_inst.RAND_ADDR_COUNT		= SINGLE_RW_RAND_ADDR_COUNT;
defparam single_rw_stage_inst.RAND_SEQ_ADDR_COUNT	= SINGLE_RW_RAND_SEQ_ADDR_COUNT;
defparam single_rw_stage_inst.USE_BLOCKING_ADDRESS_GENERATION	= USE_BLOCKING_ADDRESS_GENERATION;

// Block write/read test stage
//AVL_USE_BE,AVL_USE_BURSTBEGIN
block_rw_stage_avl_use_be_avl_use_burstbegin block_rw_stage_inst (

	.clk						(clk),
	.reset_n					(reset_n),
	.can_write					(can_write),
	.can_read					(can_read),
	.read_compare_fifo_empty	(read_compare_fifo_empty),
	.addr_gen_select			(block_rw_addr_gen_select),
	.do_write					(block_rw_do_write),
	.do_read					(block_rw_do_read),
	.stage_enable				((stage == BLOCK_RW)),
	.stage_complete				(block_rw_complete));
defparam block_rw_stage_inst.SEQ_ADDR_COUNT			= BLOCK_RW_SEQ_ADDR_COUNT;
defparam block_rw_stage_inst.RAND_ADDR_COUNT		= BLOCK_RW_RAND_ADDR_COUNT;
defparam block_rw_stage_inst.RAND_SEQ_ADDR_COUNT	= BLOCK_RW_RAND_SEQ_ADDR_COUNT;
defparam block_rw_stage_inst.BLOCK_SIZE				= BLOCK_RW_BLOCK_SIZE;
defparam block_rw_stage_inst.USE_BLOCKING_ADDRESS_GENERATION = USE_BLOCKING_ADDRESS_GENERATION;

// Test stage template
template_stage template_stage_inst (
	.clk						(clk),
	.reset_n					(reset_n),
	.can_write					(can_write),
	.can_read					(can_read),
	.read_compare_fifo_empty	(read_compare_fifo_empty),
	.addr_gen_select			(template_stage_addr_gen_select),
	.do_write					(template_stage_do_write),
	.do_read					(template_stage_do_read),
	.stage_enable				((stage == TEMPLATE_STAGE)),
	.stage_complete				(template_stage_complete));
defparam template_stage_inst.NUM_TESTS				= TEMPLATE_STAGE_COUNT;


// Simulation assertions
// synthesis translate_off
always_ff @(posedge clk)
begin
	if (reset_n)
	begin
		if (!can_write)
			assert (!do_write) else $error ("Write command cannot be issued");
		if (!can_read)
			assert (!do_read) else $error ("Read command cannot be issued");
	end
end
// synthesis translate_on


endmodule

