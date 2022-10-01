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
// The Avalon traffic generator translates the commands issued by the state
// machine into Avalon signals.  This module is responsible for transmitting
// the entire burst of write data once the state machine issues a write
// command.  The Avalon signals are generated as per the Avalon-MM protocol.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

// altera message_off 10036
module avalon_traffic_gen_avl_use_burstbegin_qdrii (
	clk,
	reset_n,
	avl_ready,
	avl_ready_w,
	avl_write_req,
	avl_read_req,
	avl_burstbegin,
	avl_burstbegin_w,
	avl_addr,
	avl_size,
	avl_addr_w,
	avl_size_w,
	avl_wdata,
	do_write,
	do_read,
	write_addr,
	write_burstcount,
	wdata,
	read_addr,
	read_burstcount,
	ready_w,
	ready_r,
	wdata_req
);

import driver_definitions::*;

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// Avalon signal widths
parameter DEVICE_FAMILY		= "";
parameter ADDR_WIDTH		= "";
parameter BURSTCOUNT_WIDTH	= "";
parameter DATA_WIDTH		= "";
parameter BUFFER_SIZE		= "";
parameter RANDOM_BYTE_ENABLE = "";

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset
input							clk;
input							reset_n;

// Avalon master signals
// QDR II/II+ memory interface uses two Avalon interfaces, one for write and one for read
input							avl_ready;
input							avl_ready_w;
output							avl_write_req;
output							avl_read_req;
output							avl_burstbegin;
output							avl_burstbegin_w;
output	[ADDR_WIDTH-1:0]		avl_addr;
output	[BURSTCOUNT_WIDTH-1:0]	avl_size;
output	[ADDR_WIDTH-1:0]		avl_addr_w;
output	[BURSTCOUNT_WIDTH-1:0]	avl_size_w;
output	[DATA_WIDTH-1:0]		avl_wdata;

// State machine commands
input							do_write;
input							do_read;

// Write address from the address generator
input	[ADDR_WIDTH-1:0]		write_addr;
input	[BURSTCOUNT_WIDTH-1:0]	write_burstcount;

// Write data
input	[DATA_WIDTH-1:0]		wdata;

// Read address from the address/burstcount FIFO
input	[ADDR_WIDTH-1:0]		read_addr;
input	[BURSTCOUNT_WIDTH-1:0]	read_burstcount;

// Avalon traffic generator status signals
output							ready_w;
output							ready_r;

// Write data request
output							wdata_req;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// Avalon traffic generator state machine
enum int unsigned {
	IDLE,
	WRITE_BURST
} state;

// Avalon master output registers
reg								avl_write_req;
reg								avl_read_req;
reg								avl_burstbegin;
reg								avl_burstbegin_w;
reg		[ADDR_WIDTH-1:0]		avl_addr;
reg		[BURSTCOUNT_WIDTH-1:0]	avl_size;
reg		[ADDR_WIDTH-1:0]		avl_addr_w;
reg		[BURSTCOUNT_WIDTH-1:0]	avl_size_w;
reg		[DATA_WIDTH-1:0]		avl_wdata;

// Avalon traffic generator status signals
logic							ready_w;
logic							ready_r;

// Write data request
logic							wdata_req;

// Register inputs
reg								do_write_reg;
reg								do_read_reg;
reg		[ADDR_WIDTH-1:0]		write_addr_reg;
reg		[BURSTCOUNT_WIDTH-1:0]	write_burstcount_reg;
reg		[ADDR_WIDTH-1:0]		read_addr_reg;
reg		[BURSTCOUNT_WIDTH-1:0]	read_burstcount_reg;
reg		[ADDR_WIDTH-1:0]		last_write_addr_reg;
reg		[BURSTCOUNT_WIDTH-1:0]	last_write_burstcount_reg;

// Counter for transmitting burst write data
reg		[BURSTCOUNT_WIDTH-1:0]	burst_counter;

// Avalon traffic FIFO signals
wire							fifo_w_full;
wire							fifo_w_empty;
wire							can_issue_avl_w_cmd;
wire							fifo_r_full;
wire							fifo_r_empty;
wire							can_issue_avl_r_cmd;

logic							fifo_write_req_in;
logic							fifo_read_req_in;
logic							fifo_burstbegin_in;
logic	[ADDR_WIDTH-1:0]		fifo_addr_in;
logic	[BURSTCOUNT_WIDTH-1:0]	fifo_size_in;
logic							fifo_burstbegin_w_in;
logic	[ADDR_WIDTH-1:0]		fifo_addr_w_in;
logic	[BURSTCOUNT_WIDTH-1:0]	fifo_size_w_in;
logic	[DATA_WIDTH-1:0]		fifo_wdata_in;

wire							fifo_write_req_out;
wire							fifo_read_req_out;
wire							fifo_burstbegin_out;
wire	[ADDR_WIDTH-1:0]		fifo_addr_out;
wire	[BURSTCOUNT_WIDTH-1:0]	fifo_size_out;
wire							fifo_burstbegin_w_out;
wire	[ADDR_WIDTH-1:0]		fifo_addr_w_out;
wire	[BURSTCOUNT_WIDTH-1:0]	fifo_size_w_out;
wire	[DATA_WIDTH-1:0]		fifo_wdata_out;


assign can_issue_avl_w_cmd = avl_ready_w | ~avl_write_req;
assign can_issue_avl_r_cmd = avl_ready | ~avl_read_req;


// Buffer for Avalon write interface
scfifo_wrapper avalon_traffic_fifo_w (
	.clk		(clk),
	.reset_n	(reset_n),
	.write_req	(fifo_write_req_in),
	.read_req	(can_issue_avl_w_cmd & ~fifo_w_empty),
	.data_in	({fifo_write_req_in,fifo_burstbegin_w_in,fifo_addr_w_in,fifo_size_w_in,fifo_wdata_in}),
	.data_out	({fifo_write_req_out,fifo_burstbegin_w_out,fifo_addr_w_out,fifo_size_w_out,fifo_wdata_out}),
	.full		(fifo_w_full),
	.empty		(fifo_w_empty)
);
defparam avalon_traffic_fifo_w.DEVICE_FAMILY	= DEVICE_FAMILY;
defparam avalon_traffic_fifo_w.FIFO_WIDTH		= 1 + 1 + ADDR_WIDTH + BURSTCOUNT_WIDTH + DATA_WIDTH;
defparam avalon_traffic_fifo_w.FIFO_SIZE		= BUFFER_SIZE;
defparam avalon_traffic_fifo_w.SHOW_AHEAD		= "ON";
defparam avalon_traffic_fifo_w.ENABLE_PIPELINE  = 0;



// Avalon traffic generator state machine
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		burst_counter <= '0;
		state <= IDLE;
	end
	else if (!fifo_w_full)
	begin
		case (state)
			IDLE:
				// A write request can be issued only in the IDLE state
				if (do_write_reg)
				begin
					// Set the number of remaining beats in the burst counter
					burst_counter <= write_burstcount_reg - 1'b1;

					// Transition to the WRITE_BURST state if the write burst is greater than 1
					if (write_burstcount_reg > 1) state <= WRITE_BURST;
				end

			WRITE_BURST:
			begin
				burst_counter <= burst_counter - 1'b1;

				// Transition to the IDLE state when the write burst is complete
				if (burst_counter == 1) state <= IDLE;
			end
		endcase
	end
end


always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		do_write_reg <= 1'b0;
		do_read_reg <= 1'b0;
		write_addr_reg <= '0;
		write_burstcount_reg <= '0;
		read_addr_reg <= '0;
		read_burstcount_reg <= '0;
		last_write_addr_reg <= '0;
		last_write_burstcount_reg <= '0;
	end
	else
	begin
		if (ready_w)
		begin
			do_write_reg <= do_write;
			write_addr_reg <= write_addr;
			write_burstcount_reg <= write_burstcount;
		end
		if (ready_r)
		begin
			do_read_reg <= do_read;
			read_addr_reg <= read_addr;
			read_burstcount_reg <= read_burstcount;
		end
		if (!fifo_w_full && state == IDLE && do_write_reg)
		begin
			last_write_addr_reg <= write_addr_reg;
			last_write_burstcount_reg <= write_burstcount_reg;
		end
	end
end


// Avalon traffic generator status and FIFO inputs for write interface
always_comb
begin
	ready_w <= 1'b0;
	wdata_req <= 1'b0;

	// Default FIFO inputs
	fifo_write_req_in <= 1'b0;
	fifo_burstbegin_w_in <= 1'b0;
	fifo_addr_w_in <= last_write_addr_reg;
	fifo_size_w_in <= last_write_burstcount_reg;
	fifo_wdata_in <= wdata;

	if (!fifo_w_full)
	begin
		case (state)
			IDLE:
			begin
				ready_w <= 1'b1;

				// A write request can be issued only in the IDLE state
				if (do_write_reg)
				begin
					wdata_req <= 1'b1;

					// Issue a write request and forward the
					// address, burstcount and data to Avalon
					fifo_write_req_in <= 1'b1;
					fifo_burstbegin_w_in <= 1'b1;
					fifo_addr_w_in <= write_addr_reg;
					fifo_size_w_in <= write_burstcount_reg;
				end
			end

			WRITE_BURST:
			begin
				if (!do_write_reg)
					ready_w <= 1'b1;

				wdata_req <= 1'b1;

				// All remaining data of a write burst is transmitted in this state
				fifo_write_req_in <= 1'b1;
			end
		endcase
	end
	else
	begin
		if (!do_write_reg)
			ready_w <= 1'b1;
	end
end


// Avalon write interface signals generation
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		avl_write_req <= 1'b0;
		avl_burstbegin_w <= 1'b0;
	end
	else if (can_issue_avl_w_cmd)
	begin
		// Avalon signals can be toggled only when the interface is ready
		// (avl_ready_w is high) or idle (avl_write_req deasserted).
		// Otherwise, all Avalon signals should be held constant.
		if (fifo_w_empty)
		begin
			avl_write_req <= 1'b0;
			avl_burstbegin_w <= 1'b0;
		end
		else
		begin
			avl_write_req <= fifo_write_req_out;
			avl_burstbegin_w <= fifo_burstbegin_w_out;
			avl_addr_w <= fifo_addr_w_out;
			avl_size_w <= fifo_size_w_out;
			avl_wdata <= fifo_wdata_out;
		end
	end
	else
	begin
		// Reset avl_burstbegin regardless of avl_ready
		avl_burstbegin_w <= 1'b0;
	end
end


// Buffer for Avalon read interface
scfifo_wrapper avalon_traffic_fifo_r (
	.clk		(clk),
	.reset_n	(reset_n),
	.write_req	(fifo_read_req_in),
	.read_req	(can_issue_avl_r_cmd & ~fifo_r_empty),
	.data_in	({fifo_read_req_in,fifo_burstbegin_in,fifo_addr_in,fifo_size_in}),
	.data_out	({fifo_read_req_out,fifo_burstbegin_out,fifo_addr_out,fifo_size_out}),
	.full		(fifo_r_full),
	.empty		(fifo_r_empty)
);
defparam avalon_traffic_fifo_r.DEVICE_FAMILY	= DEVICE_FAMILY;
defparam avalon_traffic_fifo_r.FIFO_WIDTH		= 1 + 1 + ADDR_WIDTH + BURSTCOUNT_WIDTH;
defparam avalon_traffic_fifo_r.FIFO_SIZE		= BUFFER_SIZE;
defparam avalon_traffic_fifo_r.SHOW_AHEAD		= "ON";

// Avalon traffic generator status and FIFO inputs for read interface
always_comb
begin
	ready_r <= 1'b0;

	// Default Avalon output values
	fifo_read_req_in <= 1'b0;
	fifo_burstbegin_in <= 1'b0;
	fifo_addr_in <= read_addr_reg;
	fifo_size_in <= read_burstcount_reg;

	if (!fifo_r_full)
	begin
		ready_r <= 1'b1;

		if (do_read_reg)
		begin
			// Issue a read request and forward the address and burstcount to Avalon
			fifo_read_req_in <= 1'b1;
			fifo_burstbegin_in <= 1'b1;
		end
	end
	else
	begin
		if (!do_read_reg)
			ready_r <= 1'b1;
	end
end


// Avalon read interface signals generation
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		avl_read_req <= 1'b0;
		avl_burstbegin <= 1'b0;
		avl_addr <= '0;
		avl_size <= '0;
	end
	else if (can_issue_avl_r_cmd)
	begin
		// Avalon signals can be toggled only when the interface is ready
		// (avl_ready_r is high) or idle (avl_read_req deasserted).
		// Otherwise, all Avalon signals should be held constant.
		if (fifo_r_empty)
		begin
			avl_read_req <= 1'b0;
			avl_burstbegin <= 1'b0;
		end
		else
		begin
			avl_read_req <= fifo_read_req_out;
			avl_burstbegin <= fifo_burstbegin_out;
			avl_addr <= fifo_addr_out;
			avl_size <= fifo_size_out;
		end
	end
	else
	begin
		// Reset avl_burstbegin regardless of avl_ready
		avl_burstbegin <= 1'b0;
	end
end


endmodule

