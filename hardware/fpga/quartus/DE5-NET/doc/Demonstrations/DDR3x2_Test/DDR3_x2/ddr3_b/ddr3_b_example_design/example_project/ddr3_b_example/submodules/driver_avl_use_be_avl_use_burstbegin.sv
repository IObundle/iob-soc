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
// The Example Driver is a parametrizable Avalon Memory-Mapped Master used to
// test various memory interfaces.  The driver generates pseudo-random traffic
// using a number of different patterns and compare the received data against
// what is expected.
// The Example Driver execute tests in various stages.  There are two test
// stages predefined in this driver, and it can be easily extended to include
// custom stages.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

(* altera_attribute = "-name ALLOW_SYNCH_CTRL_USAGE OFF;-name AUTO_CLOCK_ENABLE_RECOGNITION OFF;-name FITTER_ADJUST_HC_SHORT_PATH_GUARDBAND 200" *)
module driver_avl_use_be_avl_use_burstbegin (
	clk,
	reset_n,
	avl_ready,
	avl_write_req,
	avl_read_req,
	avl_burstbegin,
	avl_addr,
	avl_size,
	avl_be,
	avl_wdata,
	avl_rdata_valid,
	avl_rdata,
	pass,
	fail,
	test_complete,
	pnf_per_bit,
	pnf_per_bit_persist,
	
	csr_address,
	csr_write,
	csr_writedata,
	csr_read,
	csr_readdata,
	csr_waitrequest,
	csr_be
	
);

import driver_definitions::*;

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter DEVICE_FAMILY							= "Stratix V";

// AVALON SIGNAL WIDTHS
parameter TG_AVL_ADDR_WIDTH							= 33;
parameter TG_AVL_WORD_ADDR_WIDTH							= 27;
parameter TG_AVL_SIZE_WIDTH						= 7;
parameter TG_AVL_DATA_WIDTH							= 288;
parameter TG_AVL_BE_WIDTH								= 36;

// DRIVER CONFIGURATION
// If set to "1", the driver generates pseudo-random byte enables
parameter TG_RANDOM_BYTE_ENABLE					= 1;
// If set to "1", the driver generates 'avl_size' which are powers of two
parameter TG_POWER_OF_TWO_BURSTS_ONLY				= 0;
// If set to "1", burst transfers begin at addresses which are multiples of 'avl_size'
parameter TG_BURST_ON_BURST_BOUNDARY				= 0;
// If set to 1, transfers do not cross 4kb boundary as required for axi slaves
parameter TG_DO_NOT_CROSS_4KB_BOUNDARY				= 0;
// If set to "1", per byte address will be generated instead of per word address
parameter TG_GEN_BYTE_ADDR						= 1;
// When read compare is enabled, the write address and
// data are buffered for read operations and data compare.
// When it is disabled, the write address and data are not buffered.
parameter TG_ENABLE_READ_COMPARE					= 1;
// Timeout counter width
// If the test stages are modified, this parameter
// may need adjustment to avoid premature timeouts.
parameter TG_TIMEOUT_COUNTER_WIDTH					= 30;

// TEST STAGES PARAMETERS
// Single write/read stage
parameter TG_SINGLE_RW_SEQ_ADDR_COUNT				= 32;
parameter TG_SINGLE_RW_RAND_ADDR_COUNT				= 32;
parameter TG_SINGLE_RW_RAND_SEQ_ADDR_COUNT			= 32;
// Block write/read stage
parameter TG_BLOCK_RW_SEQ_ADDR_COUNT				= 32;
parameter TG_BLOCK_RW_RAND_ADDR_COUNT				= 32;
parameter TG_BLOCK_RW_RAND_SEQ_ADDR_COUNT			= 32;
parameter TG_BLOCK_RW_BLOCK_SIZE					= 32;
// Template stage
parameter TG_TEMPLATE_STAGE_COUNT					= 32;

// ADDRESS GENERATORS PARAMETERS
// Sequential address generator
parameter TG_SEQ_ADDR_GEN_MIN_BURSTCOUNT			= 1;
parameter TG_SEQ_ADDR_GEN_MAX_BURSTCOUNT			= 64;
// Random address generator
parameter TG_RAND_ADDR_GEN_MIN_BURSTCOUNT			= 1;
parameter TG_RAND_ADDR_GEN_MAX_BURSTCOUNT			= 64;
// Mixed sequential/random address generator
parameter TG_RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT		= 1;
parameter TG_RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT		= 64;
parameter TG_RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT	= 50;

// MEMORY INTERFACE PROPERTY
// The maximum read latency seen by the driver
// This parameter is used to determine buffer sizes, test stages may fail
// if the actual read latency is larger than specified by this parameter.
parameter TG_MAX_READ_LATENCY						= 20;

// NUM_DRIVER_LOOP
// Specifies the maximum number of loops through the driver patterns
// before asserting test complete. A setting of 0 will cause the driver to
// loop infinitely.
parameter TG_NUM_DRIVER_LOOP   = 1;

parameter TG_ENABLE_UNIX_ID                         = 0;
parameter TG_USE_UNIX_ID                            = 3'b000;

parameter DRIVER_SIGNATURE = 0;

// Random seed for data generator
parameter TG_LFSR_SEED = 36'b000000111110000011110000111000110010;

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// Determine the size of various FIFOs
localparam AVALON_TRAFFIC_BUFFER_SIZE	= 8;
localparam ADDR_BURSTCOUNT_FIFO_SIZE	= TG_BLOCK_RW_BLOCK_SIZE;
localparam WRITTEN_DATA_FIFO_SIZE		= max(TG_BLOCK_RW_BLOCK_SIZE*(1<<<(TG_AVL_SIZE_WIDTH-1)),TG_MAX_READ_LATENCY)+AVALON_TRAFFIC_BUFFER_SIZE;

// The number of resynchronized resets to create at this level
localparam NUM_DRIVER_RESET = 8;

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset
input							clk;
input							reset_n;

// Avalon master signals
input							avl_ready;
output							avl_write_req;
output							avl_read_req;
output							avl_burstbegin;
output	[TG_AVL_ADDR_WIDTH-1:0]		avl_addr;
output	[TG_AVL_SIZE_WIDTH-1:0]	avl_size;
output	[TG_AVL_BE_WIDTH-1:0]			avl_be;
output	[TG_AVL_DATA_WIDTH-1:0]		avl_wdata;
input							avl_rdata_valid;
input 	[TG_AVL_DATA_WIDTH-1:0]		avl_rdata;

// Driver status signals
output							pass;
output							fail;
output							test_complete;
output	[TG_AVL_DATA_WIDTH-1:0]		pnf_per_bit;
output	[TG_AVL_DATA_WIDTH-1:0]		pnf_per_bit_persist;



// Driver CSR port
input [13 - 1:0] csr_address;
input csr_write;
input [32 - 1:0] csr_writedata;
input [4 - 1:0] csr_be;
input csr_read;
output [32 - 1:0] csr_readdata;
output csr_waitrequest;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// Resynchronized reset
wire	[NUM_DRIVER_RESET-1:0]	resync_reset_n;

// Driver status
reg		[TG_AVL_DATA_WIDTH-1:0]		pnf_per_bit_persist;

// State machine signals
wire							do_write;
wire							do_read;
logic							can_write;
logic							can_read;
wire							timeout;
wire [31:0]                     loop_counter;
reg [31:0]                      loop_counter_persist;

// Address generator signals
addr_gen_select_t				addr_gen_select;
logic							addr_gen_enable;
wire							addr_gen_ready;
wire	[TG_AVL_ADDR_WIDTH-1:0]		addr_gen_addr;
wire	[TG_AVL_SIZE_WIDTH-1:0]	addr_gen_burstcount;

// Address/burstcount FIFO signals
logic							addr_fifo_write_req;
logic							addr_fifo_read_req;
wire	[TG_AVL_ADDR_WIDTH-1:0]		addr_fifo_addr;
wire	[TG_AVL_SIZE_WIDTH-1:0]	addr_fifo_burstcount;
// Avalon traffic generator signals
wire							traffic_gen_ready;

// Read compare signals
wire							read_compare_fifo_full;
wire							read_compare_fifo_empty;

// Address/data signals
logic	[TG_AVL_ADDR_WIDTH-1:0]		read_addr;
logic	[TG_AVL_SIZE_WIDTH-1:0]	read_burstcount;
wire							wdata_req;
wire	[TG_AVL_DATA_WIDTH-1:0]		wdata;
wire	[TG_AVL_BE_WIDTH-1:0]			be;
wire							addr_burstcount_fifo_empty;

// Delayed versions of avl_rdata and avl_rdata_valid to resolve issue
// with VHDL simgen model
logic							avl_rdata_valid_delay;
logic 	[TG_AVL_DATA_WIDTH-1:0]		avl_rdata_delay;



// Create a synchronized version of the reset against the driver clock
reset_sync	ureset_driver_clk(
	.reset_n		(reset_n),
	.clk			(clk),
	.reset_n_sync	(resync_reset_n)
);
defparam ureset_driver_clk.NUM_RESET_OUTPUT = NUM_DRIVER_RESET;


// Delay the signals to ensure they are always after the clock
//SPR:367726 details this issue
always @(avl_rdata_valid)
	avl_rdata_valid_delay <= avl_rdata_valid;

always @(avl_rdata)
	avl_rdata_delay <= avl_rdata;
	
	
// Sticky per bit pnf
always_ff @(posedge clk or negedge resync_reset_n[0])
begin
	if (!resync_reset_n[0])
		pnf_per_bit_persist <= {TG_AVL_DATA_WIDTH{1'b1}};
	else
		pnf_per_bit_persist <= pnf_per_bit_persist & pnf_per_bit;
end


// Generate status signals
assign pass = ~timeout && ((&pnf_per_bit_persist) & test_complete);
assign fail = timeout || (~(&pnf_per_bit_persist));


// Read address/burstcount select
// can_write and can_read indicates to the state machine whether
// other components are ready for issuing a write or read command
always_comb
begin
	if (TG_ENABLE_READ_COMPARE == 1)
	begin
		addr_gen_enable <= do_write;
		addr_fifo_write_req <= do_write;
		addr_fifo_read_req <= do_read;
		read_addr <= addr_fifo_addr;
		read_burstcount <= addr_fifo_burstcount;

		can_write <= traffic_gen_ready & addr_gen_ready;
		can_read <= traffic_gen_ready & ~addr_burstcount_fifo_empty;
	end
	else
	begin
		addr_gen_enable <= do_write | do_read;
		addr_fifo_write_req <= 1'b0;
		addr_fifo_read_req <= 1'b0;
		read_addr <= addr_gen_addr;
		read_burstcount <= addr_gen_burstcount;

		can_write <= traffic_gen_ready & addr_gen_ready;
		can_read <= traffic_gen_ready & addr_gen_ready;
	end
end


// Address generators
addr_gen addr_gen_inst (
	.clk				(clk),
	.reset_n			(resync_reset_n[1]),
	.addr_gen_select	(addr_gen_select),
	.enable				(addr_gen_enable),
	.ready				(addr_gen_ready),
	.addr				(addr_gen_addr),
	.burstcount			(addr_gen_burstcount));
defparam addr_gen_inst.ADDR_WIDTH							= TG_AVL_ADDR_WIDTH;
defparam addr_gen_inst.AVL_WORD_ADDR_WIDTH							= TG_AVL_WORD_ADDR_WIDTH;
defparam addr_gen_inst.DATA_WIDTH							= TG_AVL_DATA_WIDTH;
defparam addr_gen_inst.BURSTCOUNT_WIDTH						= TG_AVL_SIZE_WIDTH;
defparam addr_gen_inst.POWER_OF_TWO_BURSTS_ONLY				= TG_POWER_OF_TWO_BURSTS_ONLY;
defparam addr_gen_inst.BURST_ON_BURST_BOUNDARY				= TG_BURST_ON_BURST_BOUNDARY;
defparam addr_gen_inst.DO_NOT_CROSS_4KB_BOUNDARY			= TG_DO_NOT_CROSS_4KB_BOUNDARY;
defparam addr_gen_inst.GEN_BYTE_ADDR					= TG_GEN_BYTE_ADDR;
defparam addr_gen_inst.SEQ_ADDR_GEN_MIN_BURSTCOUNT			= TG_SEQ_ADDR_GEN_MIN_BURSTCOUNT;
defparam addr_gen_inst.SEQ_ADDR_GEN_MAX_BURSTCOUNT			= TG_SEQ_ADDR_GEN_MAX_BURSTCOUNT;
defparam addr_gen_inst.RAND_ADDR_GEN_MIN_BURSTCOUNT			= TG_RAND_ADDR_GEN_MIN_BURSTCOUNT;
defparam addr_gen_inst.RAND_ADDR_GEN_MAX_BURSTCOUNT			= TG_RAND_ADDR_GEN_MAX_BURSTCOUNT;
defparam addr_gen_inst.RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT		= TG_RAND_SEQ_ADDR_GEN_MIN_BURSTCOUNT;
defparam addr_gen_inst.RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT		= TG_RAND_SEQ_ADDR_GEN_MAX_BURSTCOUNT;
defparam addr_gen_inst.RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT	= TG_RAND_SEQ_ADDR_GEN_RAND_ADDR_PERCENT;
defparam addr_gen_inst.ENABLE_UNIX_ID                       	= TG_ENABLE_UNIX_ID;
defparam addr_gen_inst.USE_UNIX_ID                          	= TG_USE_UNIX_ID;


// Pseudo-random data generator
lfsr_wrapper data_gen_inst (
	.clk		(clk),
	.reset_n	(resync_reset_n[2]),
	.enable		(wdata_req),
	.data		(wdata));
defparam data_gen_inst.DATA_WIDTH	= TG_AVL_DATA_WIDTH;
defparam data_gen_inst.SEED	= TG_LFSR_SEED;

// Byte enable generator
generate
if (TG_RANDOM_BYTE_ENABLE == 1)
begin : be_gen
	lfsr_wrapper be_gen_inst (
		.clk		(clk),
		.reset_n	(resync_reset_n[3]),
		.enable		(wdata_req),
		.data		(be));
	defparam be_gen_inst.DATA_WIDTH	= TG_AVL_BE_WIDTH;
end
else
begin : be_const
	assign be = {TG_AVL_BE_WIDTH{1'b1}};
end
endgenerate


// The address/burstcount FIFO buffers the write addresses
// and burstcounts which are later used in read operations
scfifo_wrapper addr_burstcount_fifo (
	.clk		(clk),
	.reset_n	(resync_reset_n[4]),
	.write_req	(addr_fifo_write_req),
	.read_req	(addr_fifo_read_req),
	.data_in	({addr_gen_addr,addr_gen_burstcount}),
	.data_out	({addr_fifo_addr,addr_fifo_burstcount}),
	.full		(),
	.empty		(addr_burstcount_fifo_empty));
defparam addr_burstcount_fifo.DEVICE_FAMILY	= DEVICE_FAMILY;
defparam addr_burstcount_fifo.FIFO_WIDTH	= TG_AVL_ADDR_WIDTH + TG_AVL_SIZE_WIDTH;
defparam addr_burstcount_fifo.FIFO_SIZE		= ADDR_BURSTCOUNT_FIFO_SIZE;
defparam addr_burstcount_fifo.SHOW_AHEAD	= "ON";


generate
if (TG_NUM_DRIVER_LOOP == -1)
begin : skip_driver
	assign test_complete = avl_ready;	
	assign timeout = 1'b0;
end
else
begin : real_driver





// The main state machine of the example driver,
// which contains sub-modules for various test stages
driver_fsm_avl_use_be_avl_use_burstbegin driver_fsm_inst (

	.clk						(clk),
	.reset_n					(resync_reset_n[5]),
	.can_write					(can_write),
	.can_read					(can_read),
	.read_compare_fifo_full		(read_compare_fifo_full),
	.read_compare_fifo_empty	(read_compare_fifo_empty),
	.addr_gen_select			(addr_gen_select),
	.do_write					(do_write),
	.do_read					(do_read),
	.test_complete				(test_complete),
	.loop_counter               (loop_counter),
	.timeout					(timeout));
defparam driver_fsm_inst.SINGLE_RW_SEQ_ADDR_COUNT		= TG_SINGLE_RW_SEQ_ADDR_COUNT;
defparam driver_fsm_inst.SINGLE_RW_RAND_ADDR_COUNT		= TG_SINGLE_RW_RAND_ADDR_COUNT;
defparam driver_fsm_inst.SINGLE_RW_RAND_SEQ_ADDR_COUNT	= TG_SINGLE_RW_RAND_SEQ_ADDR_COUNT;
defparam driver_fsm_inst.BLOCK_RW_SEQ_ADDR_COUNT		= TG_BLOCK_RW_SEQ_ADDR_COUNT;
defparam driver_fsm_inst.BLOCK_RW_RAND_ADDR_COUNT		= TG_BLOCK_RW_RAND_ADDR_COUNT;
defparam driver_fsm_inst.BLOCK_RW_RAND_SEQ_ADDR_COUNT	= TG_BLOCK_RW_RAND_SEQ_ADDR_COUNT;
defparam driver_fsm_inst.BLOCK_RW_BLOCK_SIZE			= TG_BLOCK_RW_BLOCK_SIZE;
defparam driver_fsm_inst.TEMPLATE_STAGE_COUNT			= TG_TEMPLATE_STAGE_COUNT;
defparam driver_fsm_inst.TIMEOUT_COUNTER_WIDTH			= TG_TIMEOUT_COUNTER_WIDTH;
defparam driver_fsm_inst.NUM_DRIVER_LOOP                = TG_NUM_DRIVER_LOOP;
defparam driver_fsm_inst.USE_BLOCKING_ADDRESS_GENERATION = 0;


end

endgenerate



// The Avalon traffic generator translates the commands
// issued by the state machine into Avalon signals
avalon_traffic_gen_avl_use_be_avl_use_burstbegin avalon_traffic_gen_inst (

	.clk				(clk),
	.reset_n			(resync_reset_n[6]),
	.avl_ready			(avl_ready),
	.avl_write_req		(avl_write_req),
	.avl_read_req		(avl_read_req),
	.avl_burstbegin		(avl_burstbegin),
	.avl_addr			(avl_addr),
	.avl_size			(avl_size),
	.avl_wdata			(avl_wdata),
	.avl_be				(avl_be),
	.do_write			(do_write),
	.do_read			(do_read),
	.write_addr			(addr_gen_addr),
	.write_burstcount	(addr_gen_burstcount),
	.wdata				(wdata),
	.be					(be),
	.read_addr			(read_addr),
	.read_burstcount	(read_burstcount),
	.ready				(traffic_gen_ready),
	.wdata_req			(wdata_req));
defparam avalon_traffic_gen_inst.DEVICE_FAMILY		= DEVICE_FAMILY;
defparam avalon_traffic_gen_inst.ADDR_WIDTH			= TG_AVL_ADDR_WIDTH;
defparam avalon_traffic_gen_inst.BURSTCOUNT_WIDTH	= TG_AVL_SIZE_WIDTH;
defparam avalon_traffic_gen_inst.DATA_WIDTH			= TG_AVL_DATA_WIDTH;
defparam avalon_traffic_gen_inst.BE_WIDTH			= TG_AVL_BE_WIDTH;
defparam avalon_traffic_gen_inst.BUFFER_SIZE		= AVALON_TRAFFIC_BUFFER_SIZE;
defparam avalon_traffic_gen_inst.RANDOM_BYTE_ENABLE = TG_RANDOM_BYTE_ENABLE;

// Read compare module
//AVL_USE_BE,AVL_USE_BURSTBEGIN
read_compare_avl_use_be_avl_use_burstbegin read_compare_inst (

	.clk						(clk),
	.reset_n					(resync_reset_n[7]),
	.enable						((TG_ENABLE_READ_COMPARE == 1)),
	.wdata_req					(wdata_req),
	.wdata						(wdata),
	.be							(be),
	.rdata_valid				(avl_rdata_valid_delay),
	.rdata						(avl_rdata_delay),
	.read_compare_fifo_full		(read_compare_fifo_full),
	.read_compare_fifo_empty	(read_compare_fifo_empty),
	.pnf_per_bit				(pnf_per_bit));
defparam read_compare_inst.DATA_WIDTH				= TG_AVL_DATA_WIDTH;
defparam read_compare_inst.BE_WIDTH					= TG_AVL_BE_WIDTH;
defparam read_compare_inst.WRITTEN_DATA_FIFO_SIZE	= WRITTEN_DATA_FIFO_SIZE;
defparam read_compare_inst.DEVICE_FAMILY			= DEVICE_FAMILY;


`ifdef ENABLE_ISS_PROBES
reg [TG_AVL_DATA_WIDTH-1:0] pnf_per_bit_r;
reg [TG_AVL_DATA_WIDTH-1:0] pnf_per_bit_persist_r;
reg pass_r;
reg fail_r;
reg timeout_r;
reg test_complete_r;
reg [31:0] loop_counter_r;
reg [31:0] loop_counter_persist_r;

always_ff @(posedge clk)
begin
	pass_r <= pass;
	fail_r <= fail;
	timeout_r <= timeout;
	test_complete_r <= test_complete;
	loop_counter_r <= loop_counter;
	pnf_per_bit_r <= pnf_per_bit;
	pnf_per_bit_persist_r <= pnf_per_bit_persist;
	loop_counter_persist_r <= loop_counter_persist;

	// Loop counter stopping on failure
	if (~fail_r) begin
		loop_counter_persist <= loop_counter_r;
	end
end

iss_probe #(
	.WIDTH((TG_AVL_DATA_WIDTH > 511) ? 511 : TG_AVL_DATA_WIDTH)
) pnf_per_bit_probe (
	.probe_input(pnf_per_bit_r[((TG_AVL_DATA_WIDTH > 511) ? 511 : TG_AVL_DATA_WIDTH) - 1 : 0])
);

iss_probe #(
	.WIDTH((TG_AVL_DATA_WIDTH > 511) ? 511 : TG_AVL_DATA_WIDTH)
) pnf_per_bit_persist_probe (
	.probe_input(pnf_per_bit_persist_r[((TG_AVL_DATA_WIDTH > 511) ? 511 : TG_AVL_DATA_WIDTH) - 1: 0])
);

iss_probe #(
	.WIDTH(1)
) driver_pass_probe (
	.probe_input(pass_r)
);

iss_probe #(
	.WIDTH(1)
) driver_fail_probe (
	.probe_input(fail_r)
);

iss_probe #(
	.WIDTH(1)
) driver_timeout_probe (
	.probe_input(timeout_r)
);

iss_probe #(
	.WIDTH(1)
) driver_test_complete_probe (
	.probe_input(test_complete_r)
);

iss_probe #(
	.WIDTH(32)
) driver_loop_counter_probe (
	.probe_input(loop_counter_persist_r)
);


driver_csr #(
	.PNF_PER_BIT_WIDTH(TG_AVL_DATA_WIDTH),
	.DRIVER_SIGNATURE(DRIVER_SIGNATURE)
) csr (
	.avl_clk(clk),
	.avl_reset_n(resync_reset_n[0]),
	.avl_address(csr_address),
	.avl_write(csr_write),
	.avl_writedata(csr_writedata),
	.avl_read(csr_read),
	.avl_readdata(csr_readdata),
	.avl_waitrequest(csr_waitrequest),
	.avl_be(csr_be),
	.drv_pass(pass_r),
	.drv_fail(fail_r),
	.drv_timeout(timeout_r),
	.drv_test_complete(test_complete_r),
	.loop_counter(loop_counter_persist_r),
	.pnf_per_bit_persist(pnf_per_bit_persist_r)
);
`else
	assign csr_readdata = '0;
	assign csr_waitrequest = '0;
`endif

// Simulation assertions
// synthesis translate_off
initial
begin
	assert (TG_POWER_OF_TWO_BURSTS_ONLY == 1 || TG_POWER_OF_TWO_BURSTS_ONLY == 0)
		else $error ("TG_POWER_OF_TWO_BURSTS_ONLY must be 1 or 0");
	assert (TG_BURST_ON_BURST_BOUNDARY == 1 || TG_BURST_ON_BURST_BOUNDARY == 0)
		else $error ("TG_BURST_ON_BURST_BOUNDARY must be 1 or 0");
	assert (TG_DO_NOT_CROSS_4KB_BOUNDARY == 1 || TG_DO_NOT_CROSS_4KB_BOUNDARY == 0)
		else $error ("TG_DO_NOT_CROSS_4KB_BOUNDARY must be 1 or 0");
	assert (TG_RANDOM_BYTE_ENABLE == 1 || TG_RANDOM_BYTE_ENABLE == 0)
		else $error ("TG_RANDOM_BYTE_ENABLE must be 1 or 0");
end
`ifdef ENABLE_DRIVER_SIM_STATUS

always @(posedge test_complete)
begin
	if (pass)
	begin
		$display("          --- EXAMPLE DRIVER SIMULATION PASSED --- ");
		$finish;
	end
	else
	begin
		$display("          --- EXAMPLE DRIVER SIMULATION FAILED --- ");
		$finish;
	end
end
`endif
// synthesis translate_on


endmodule


