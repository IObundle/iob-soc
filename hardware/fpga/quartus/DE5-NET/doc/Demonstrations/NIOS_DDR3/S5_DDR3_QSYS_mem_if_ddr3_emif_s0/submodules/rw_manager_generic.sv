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


`timescale 1 ps / 1 ps

module rw_manager_generic (
	avl_clk,
	avl_reset_n,
	avl_address,
	avl_write,
	avl_writedata,
	avl_read,
	avl_readdata,
	avl_waitrequest,

	afi_clk,
	afi_reset_n,
	afi_wdata,
	afi_dm,
	afi_odt,
	afi_rdata,
	afi_rdata_valid,
	afi_wrank,
	afi_rrank,

	ac_masked_bus,
	ac_bus,
	csr_clk,
	csr_ena,
	csr_dout_phy,
	csr_dout

);

	parameter AVL_DATA_WIDTH 			= "";
	parameter AVL_ADDRESS_WIDTH			= "";
	
	parameter MEM_DQ_WIDTH				= "";
	parameter MEM_DM_WIDTH				= "";
	parameter MEM_ODT_WIDTH 			= "";
	parameter MEM_NUMBER_OF_RANKS		= "";
	parameter MASK_WIDTH				= "";
	parameter AC_ODT_BIT				= "";
	parameter AC_BUS_WIDTH				= "";
	parameter AC_MASKED_BUS_WIDTH			= "";
	parameter AFI_RATIO				= "";

	parameter MEM_READ_DQS_WIDTH 			= "";
	parameter MEM_WRITE_DQS_WIDTH			= "";

	parameter DEBUG_READ_DI_WIDTH			= "";
	parameter DEBUG_WRITE_TO_READ_RATIO_2_EXPONENT	= "";
	parameter DEBUG_WRITE_TO_READ_RATIO	= "";
	parameter MAX_DI_BUFFER_WORDS_LOG_2 = "";

	parameter RATE = "";
	parameter HCX_COMPAT_MODE = 0;
	parameter DEVICE_FAMILY = "";
	parameter AC_ROM_INIT_FILE_NAME = "";
	parameter INST_ROM_INIT_FILE_NAME = "";
	
	parameter USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE = 0;

	input avl_clk;
	input avl_reset_n;
	input [AVL_ADDRESS_WIDTH-1:0] avl_address;
	input avl_write;
	input [AVL_DATA_WIDTH-1:0] avl_writedata;
	input avl_read;
	output [AVL_DATA_WIDTH-1:0] avl_readdata;
	output avl_waitrequest;

	input afi_clk;
	input afi_reset_n;
	
	output [AC_MASKED_BUS_WIDTH - 1:0] ac_masked_bus;
	output [AC_BUS_WIDTH - 1:0] ac_bus;
	output [MEM_DQ_WIDTH * 2 * AFI_RATIO - 1:0] afi_wdata;
	output [MEM_DM_WIDTH * 2 * AFI_RATIO - 1:0] afi_dm;
	output [MEM_ODT_WIDTH * AFI_RATIO - 1:0] afi_odt;
	output [MEM_WRITE_DQS_WIDTH * MEM_NUMBER_OF_RANKS * AFI_RATIO - 1:0] afi_wrank;
	output [MEM_READ_DQS_WIDTH * MEM_NUMBER_OF_RANKS * AFI_RATIO - 1:0] afi_rrank;

	input [MEM_DQ_WIDTH * 2 * AFI_RATIO - 1:0] afi_rdata;
	input afi_rdata_valid;

        input                         csr_clk;       
        input                         csr_ena;       
        input                         csr_dout_phy;       
        output  csr_dout;



	reg [AVL_DATA_WIDTH-1:0] avl_readdata;
	reg avl_waitrequest;
	
	wire avl_wr;
	reg cmd_done_avl;

	wire [AC_BUS_WIDTH - 1:0] ac_bus;
	wire [AC_MASKED_BUS_WIDTH - 1:0] ac_masked_bus;

	wire avl_rd;
	wire cmd_read;
	wire cmd_write;
	reg avl_rd_r;
	reg avl_wr_r;


	typedef enum int unsigned {
		STATE_RW_IDLE,
		STATE_RW_EXEC,
		STATE_RW_DONE
	} STATE_RW_T;

	STATE_RW_T state;


	assign avl_wr = avl_write;

	assign avl_rd = avl_read;

	// CMD State Machine


	always_ff @(posedge avl_clk) begin
		if (~avl_reset_n) begin
			state <= STATE_RW_IDLE;
		end else begin
			case (state)
			STATE_RW_IDLE:
				begin
				    if (avl_rd) begin
					    state <= STATE_RW_EXEC;
				    end
				    if (avl_wr) begin
					    state <= STATE_RW_EXEC;
				    end
				end
			STATE_RW_EXEC: 
				if (cmd_done_avl) begin
					state <= STATE_RW_DONE;
				end
			STATE_RW_DONE: 
				begin
				    state <= STATE_RW_IDLE;
				end
			endcase
		end
	end


	reg [AVL_DATA_WIDTH - 1:0] avl_writedata_avl;
	reg [AVL_ADDRESS_WIDTH - 1:0] avl_address_avl;
	wire [AVL_DATA_WIDTH - 1:0] avl_readdata_afi;
	wire cmd_done_afi;

	reg [AVL_DATA_WIDTH - 1:0] avl_readdata_g_avl;

	always @(posedge avl_clk or negedge avl_reset_n)
	begin
		if (~avl_reset_n)
		begin
		    avl_writedata_avl   <= {AVL_DATA_WIDTH{1'b0}};
		    avl_address_avl     <= {AVL_ADDRESS_WIDTH{1'b0}};
		    avl_readdata_g_avl	<= {AVL_DATA_WIDTH{1'b0}};
		    cmd_done_avl	<= 1'b0;
		    avl_rd_r		<= 1'b0;
		    avl_wr_r		<= 1'b0;
		end
		else begin
		    avl_writedata_avl   <= avl_writedata;
		    avl_address_avl     <= avl_address;
		    avl_readdata_g_avl	<= avl_readdata_afi;
		    cmd_done_avl	<= cmd_done_afi;
		    avl_rd_r		<= avl_rd;
		    avl_wr_r		<= avl_wr;
		end
	end

	rw_manager_core rw_mgr_core_inst (
		.avl_reset_n(avl_reset_n),
		.avl_clk(avl_clk),
		.afi_clk(afi_clk),
		.avl_address(avl_address_avl),
		.avl_readdata(avl_readdata_afi),
		.avl_writedata(avl_writedata_avl),
		.afi_reset_n(afi_reset_n),
		.afi_wdata(afi_wdata),
		.afi_dm(afi_dm),
		.afi_odt(afi_odt),
		.afi_rdata(afi_rdata),
		.afi_rdata_valid(afi_rdata_valid),
		.afi_wrank(afi_wrank),
		.afi_rrank(afi_rrank),
		.ac_bus(ac_bus),
		.ac_masked_bus(ac_masked_bus),
		.cmd_read(cmd_read),
		.cmd_write(cmd_write),
		.cmd_done(cmd_done_afi),
		.csr_clk(csr_clk),
		.csr_ena(csr_ena),
		.csr_dout_phy(csr_dout_phy),
		.csr_dout(csr_dout)
	);
	defparam rw_mgr_core_inst.AVL_DATA_WIDTH = AVL_DATA_WIDTH;
	defparam rw_mgr_core_inst.AVL_ADDRESS_WIDTH = AVL_ADDRESS_WIDTH;
	defparam rw_mgr_core_inst.MEM_DQ_WIDTH = MEM_DQ_WIDTH;
	defparam rw_mgr_core_inst.MEM_DM_WIDTH = MEM_DM_WIDTH;
	defparam rw_mgr_core_inst.MEM_ODT_WIDTH = MEM_ODT_WIDTH;
	defparam rw_mgr_core_inst.MEM_NUMBER_OF_RANKS = MEM_NUMBER_OF_RANKS;
	defparam rw_mgr_core_inst.MASK_WIDTH = MASK_WIDTH;
	defparam rw_mgr_core_inst.AC_ODT_BIT = AC_ODT_BIT;
	defparam rw_mgr_core_inst.AC_BUS_WIDTH = AC_BUS_WIDTH;
	defparam rw_mgr_core_inst.AC_MASKED_BUS_WIDTH = AC_MASKED_BUS_WIDTH;
	defparam rw_mgr_core_inst.AFI_RATIO = AFI_RATIO;
	defparam rw_mgr_core_inst.MEM_READ_DQS_WIDTH = MEM_READ_DQS_WIDTH;
	defparam rw_mgr_core_inst.MEM_WRITE_DQS_WIDTH = MEM_WRITE_DQS_WIDTH;
	defparam rw_mgr_core_inst.DEBUG_READ_DI_WIDTH = DEBUG_READ_DI_WIDTH;
	defparam rw_mgr_core_inst.DEBUG_WRITE_TO_READ_RATIO_2_EXPONENT = DEBUG_WRITE_TO_READ_RATIO_2_EXPONENT;
	defparam rw_mgr_core_inst.DEBUG_WRITE_TO_READ_RATIO = DEBUG_WRITE_TO_READ_RATIO;
	defparam rw_mgr_core_inst.RATE = RATE;
	defparam rw_mgr_core_inst.HCX_COMPAT_MODE = HCX_COMPAT_MODE;
	defparam rw_mgr_core_inst.DEVICE_FAMILY = DEVICE_FAMILY;
	defparam rw_mgr_core_inst.AC_ROM_INIT_FILE_NAME = AC_ROM_INIT_FILE_NAME;
	defparam rw_mgr_core_inst.INST_ROM_INIT_FILE_NAME = INST_ROM_INIT_FILE_NAME;
	defparam rw_mgr_core_inst.MAX_DI_BUFFER_WORDS_LOG_2 = MAX_DI_BUFFER_WORDS_LOG_2;
	defparam rw_mgr_core_inst.USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE = USE_ALL_AFI_PHASES_FOR_COMMAND_ISSUE;

	assign cmd_read = avl_rd_r & ~cmd_done_avl & (state == STATE_RW_EXEC);
	assign cmd_write = avl_wr_r & ~cmd_done_avl & (state == STATE_RW_EXEC);


	always_comb
	begin
		if (((avl_wr || avl_rd) && (~cmd_done_avl || state != STATE_RW_EXEC)) || ~avl_reset_n)
			avl_waitrequest = 1;
		else
			avl_waitrequest = 0;
			
		if (avl_rd)
			avl_readdata = avl_readdata_g_avl;
		else
			avl_readdata = '0;
	end
	
    assert property (@(posedge avl_reset_n) AC_MASKED_BUS_WIDTH == MASK_WIDTH*AFI_RATIO)
	    $display("%t, [GENERIC ASSERT] AC_MASKED_BUS_WIDTH PARAMETER is correct", $time);
	else
	    $error("%t, [GENERIC ASSERT] AC_MASKED_BUS_WIDTH PARAMETER is incorrect, AC_MASKED_BUS_WIDTH = %d, MASK_WIDTH*AFI_RATIO = %d", $time, AC_MASKED_BUS_WIDTH, MASK_WIDTH*AFI_RATIO);
	
	assert property (@(posedge avl_clk) !avl_reset_n |-> !cmd_read);
	assert property (@(posedge avl_clk) !avl_reset_n |-> avl_waitrequest);

endmodule
