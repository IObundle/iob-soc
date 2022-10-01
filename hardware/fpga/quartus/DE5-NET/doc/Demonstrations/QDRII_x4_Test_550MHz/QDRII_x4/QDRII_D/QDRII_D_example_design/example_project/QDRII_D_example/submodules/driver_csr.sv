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

module driver_csr (
	// Avalon Interface
	
	avl_clk,
	avl_reset_n,
	avl_address,
	avl_write,
	avl_writedata,
	avl_read,
	avl_readdata,
	avl_waitrequest,
	avl_be,
	
	drv_pass,
	drv_fail,
	drv_timeout,
	drv_test_complete,
	loop_counter,
	pnf_per_bit_persist
);
parameter PNF_PER_BIT_WIDTH = 288;
parameter DRIVER_SIGNATURE = 0;
localparam AVL_DATA_WIDTH = 32;
localparam AVL_ADDR_WIDTH = 13;
localparam AVL_NUM_SYMBOLS = 4;
localparam AVL_SYMBOL_WIDTH = 8;
localparam REGISTER_RDATA   = 0;
localparam NUM_REGFILE_WORDS = 80;

input avl_clk;
input avl_reset_n;
input [AVL_ADDR_WIDTH - 1:0] avl_address;
input avl_write;
input [AVL_DATA_WIDTH - 1:0] avl_writedata;
input [AVL_NUM_SYMBOLS - 1:0] avl_be;
input avl_read;
output [AVL_DATA_WIDTH - 1:0] avl_readdata;
output avl_waitrequest;

input drv_pass;
input drv_fail;
input drv_timeout;
input drv_test_complete;
input [31:0] loop_counter;
input [PNF_PER_BIT_WIDTH-1:0] pnf_per_bit_persist;


reg [AVL_ADDR_WIDTH-1 : 0] int_addr;
reg [AVL_NUM_SYMBOLS - 1 : 0] int_be;
reg [AVL_DATA_WIDTH - 1 : 0] int_rdata;
reg [AVL_DATA_WIDTH - 1 : 0] int_rdata_reg;
logic int_waitrequest;
reg [AVL_DATA_WIDTH - 1 : 0] int_wdata;
logic [AVL_DATA_WIDTH - 1 : 0] int_wdata_wire;

reg [AVL_DATA_WIDTH-1 : 0] reg_file [0 : NUM_REGFILE_WORDS-1] /* synthesis syn_ramstyle = "logic" */;

integer b, x, y;

typedef enum int unsigned {
	INIT,
	IDLE,
	WRITE2,
	READ2,
	READ3,
	READ4
} avalon_state_t;

avalon_state_t state;

always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
	if (~avl_reset_n)
		state <= INIT;
	else begin
		if (state == READ2)
			state <= READ3;
		else if ((state == READ3) && (REGISTER_RDATA)) 
			state <= READ4;
		else if (state == IDLE) 
			if (avl_read)
				state <= READ2;
			else if (avl_write)
				state <= WRITE2;
			else
				state <= IDLE;
		else 
			state <= IDLE;
	end
end

assign int_waitrequest = (state == IDLE) || (state == WRITE2) || ((state == READ4) && (REGISTER_RDATA)) || ((state == READ3) && (REGISTER_RDATA == 0)) ? 1'b0 : 1'b1;

always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
	if (~avl_reset_n) begin
		int_addr <= 0;
		int_wdata <= 0;
		int_be <= 0;
	end
	else if (int_waitrequest == 0) begin
		int_addr  <= avl_address;
		int_wdata <= avl_writedata;
		int_be    <= avl_be;
	end
end

always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
	if (~avl_reset_n) begin
		int_rdata <= 0;
	end
	else begin
		if (state == READ2) 
			if (int_addr < NUM_REGFILE_WORDS) begin
				int_rdata <= reg_file[int_addr];
			end
			else begin
				int_rdata <= 0;
			end
		else
			int_rdata <= 0;
	end
end
// synthesis translate_off
property p_illegal_read_addr;
	@(posedge avl_clk)
	disable iff (!avl_reset_n)
	(state == READ2) |-> (int_addr < NUM_REGFILE_WORDS);
endproperty

a_illegal_read_addr : assert property (p_illegal_read_addr);
// synthesis translate_on


always_comb begin
	int_wdata_wire <= reg_file[int_addr];
	for (b=0; b < AVL_NUM_SYMBOLS; b++)
		if (int_be[b])
			int_wdata_wire[(b+1)*AVL_SYMBOL_WIDTH-1-:AVL_SYMBOL_WIDTH] <= int_wdata[(b+1)*AVL_SYMBOL_WIDTH-1-:AVL_SYMBOL_WIDTH];
end

always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
	if (~avl_reset_n) begin
	end
	else begin
		if (state == WRITE2) begin
		end
	end
end

generate
	if (REGISTER_RDATA) begin
		
		always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
			if (~avl_reset_n)
				int_rdata_reg <= 0;
			else
				int_rdata_reg <= int_rdata;
		end

		assign avl_readdata = int_rdata_reg;
	end
	else
		assign avl_readdata = int_rdata;
endgenerate

assign avl_waitrequest = ((state == IDLE) && ((avl_read == 1) || (avl_write == 1))) ? 1'b1 : int_waitrequest;


always_ff @ (posedge avl_clk or negedge avl_reset_n) begin
	if (~avl_reset_n) begin
		for (x=0; x < NUM_REGFILE_WORDS; x++)
			reg_file[x] <= 0;
	end
	else begin
		for (x=0; x < NUM_REGFILE_WORDS; x++)
			reg_file[x] <= 0;
			
		
		reg_file[0] <= DRIVER_SIGNATURE;
		reg_file[1][0] <= drv_pass;	
		reg_file[1][1] <= drv_fail;	
		reg_file[1][2] <= drv_timeout;	
		reg_file[1][3] <= drv_test_complete;
		reg_file[1][31:16] <= PNF_PER_BIT_WIDTH[15:0];
		
		reg_file[2] <= loop_counter;
		
		for (x=16; x < NUM_REGFILE_WORDS; x++) begin
			for (y = 0; y < 32; y++) begin
				if ((x-16)*32 + y < PNF_PER_BIT_WIDTH)
					reg_file[x][y] <= pnf_per_bit_persist[(x-16)*32 + y];
			end
		end
	end
end



endmodule
