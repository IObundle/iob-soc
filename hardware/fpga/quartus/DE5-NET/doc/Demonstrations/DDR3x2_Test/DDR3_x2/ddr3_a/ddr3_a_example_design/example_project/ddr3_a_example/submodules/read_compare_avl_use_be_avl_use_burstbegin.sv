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
// When enabled, the read compare module buffers the write data and compares
// it with the returned read data.  If the write and read data do not match,
// the corresponding bits of pnf_per_bit is deasserted.
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module read_compare_avl_use_be_avl_use_burstbegin (
	clk,
	reset_n,
	enable,
	wdata_req,
	wdata,
	be,
	rdata_valid,
	rdata,
	read_compare_fifo_full,
	read_compare_fifo_empty,
	pnf_per_bit
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

parameter DEVICE_FAMILY				= "";

// Avalon signal widths
parameter DATA_WIDTH				= "";
parameter BE_WIDTH					= "";

parameter WRITTEN_DATA_FIFO_SIZE	= "";

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN LOCALPARAM SECTION

// Byte size derived from dividing data width by byte enable width
//Round up so that compile fails if DATA_WIDTH is not a multiple of BE_WIDTH
localparam BYTE_SIZE					= (DATA_WIDTH + BE_WIDTH - 1) / BE_WIDTH;

// the width of the local data counter
localparam DATACOUNTER_WIDTH			= 8;

// Should the driver force errors?
localparam UNIPHY_DRIVER_FORCE_ERROR	= 1'b0;

// END LOCALPARAM SECTION
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset
input						clk;
input						reset_n;

// Control signals
input						enable;
input						wdata_req;

// Write data
input 	[DATA_WIDTH-1:0]	wdata;
input 	[BE_WIDTH-1:0]		be;

// Avalon read data
input						rdata_valid;
input 	[DATA_WIDTH-1:0]	rdata;

// Read compare status
output						read_compare_fifo_full;
output						read_compare_fifo_empty;
output 	[DATA_WIDTH-1:0]	pnf_per_bit;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

// Per bit compare result
reg 	[DATA_WIDTH-1:0]	pnf_per_bit;

// Write data FIFO output
wire 	[DATA_WIDTH-1:0]	written_data;
wire 	[DATA_WIDTH-1:0]	written_data_fifo_out;

// Read/write data registers
reg							rdata_valid_reg;
reg 	[DATA_WIDTH-1:0]	rdata_reg;
reg							wdata_req_reg;
reg 	[DATA_WIDTH-1:0]	wdata_reg;
reg 	[BE_WIDTH-1:0]		be_reg;

// Data Counter
reg [DATACOUNTER_WIDTH-1:0] data_counter;

// Should errors be forced?
logic force_error;

wire 	[BE_WIDTH-1:0]		written_be;


// Per bit comparison
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		pnf_per_bit <= {DATA_WIDTH{1'b1}};
	end
	else
	begin
		for (int byte_num = 0; byte_num < BE_WIDTH; byte_num++)
		begin
			for (int bit_num = byte_num*BYTE_SIZE; bit_num < (byte_num+1)*BYTE_SIZE; bit_num++)
			begin
				if (enable && rdata_valid_reg && written_be[byte_num])
					pnf_per_bit[bit_num] <= (rdata_reg[bit_num] === written_data[bit_num]);
				else
					pnf_per_bit[bit_num] <= 1'b1;
			end
		end
	end
end


always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		rdata_valid_reg <= 1'b0;
		rdata_reg <= '0;
		wdata_req_reg <= 1'b0;
		wdata_reg <= '0;
		be_reg <= '0;
	end
	else
	begin
		rdata_valid_reg <= rdata_valid;
		rdata_reg <= rdata;
		wdata_req_reg <= wdata_req;
		wdata_reg <= wdata;
		be_reg <= be;
	end
end


// The data is used as a small counter to count data coming back. It is
// used by the UNIPHY_DRIVER_FORCE_ERROR mode to introduce errors.
always_ff @(posedge clk or negedge reset_n)
begin
	if (!reset_n)
		data_counter <= '0;
	else
		if (rdata_valid_reg)
			data_counter <= data_counter + 1'b1;
end


// Display a message to the user of there is an error
// synthesis translate_off
reg 	[DATA_WIDTH-1:0]	rdata_rr;
reg 	[DATA_WIDTH-1:0]	written_data_rr;
reg 	[DATA_WIDTH-1:0]	written_be_full_rr;

wire 	[DATA_WIDTH-1:0]	written_be_full;
generate
genvar byte_num;
	for (byte_num = 0; byte_num < BE_WIDTH; byte_num = byte_num + 1)
	begin
		assign written_be_full [((byte_num+1) * BYTE_SIZE) - 1 : byte_num * BYTE_SIZE] = {BYTE_SIZE{written_be[byte_num]}};
	end
endgenerate

always_ff @(posedge clk)
begin
	rdata_rr <= rdata_reg;
	written_data_rr <= written_data;
	written_be_full_rr <= written_be_full;
	
	if (~(&pnf_per_bit))
	begin
		$display("[%0t] ERROR: Expected %h/%h but read %h in module %m", $time, written_data_rr, written_be_full_rr, rdata_rr);
		$display("            wrote bits: %h", written_data_rr & written_be_full_rr);
		$display("             read bits: %h", rdata_rr & written_be_full_rr);
	end
end
// synthesis translate_on

`ifdef ENABLE_ISS_PROBES
iss_source #(
	.WIDTH(1)
) iss_driver_force_error (
	.source(force_error)
);
`else
assign force_error = UNIPHY_DRIVER_FORCE_ERROR;
`endif

assign written_data = (force_error) ?
	((data_counter > 10) ? {written_data_fifo_out[DATA_WIDTH-1:1],~written_data_fifo_out[0]} : written_data_fifo_out) :
	written_data_fifo_out;


// Write data FIFO
scfifo_wrapper written_data_fifo(
	.clk		(clk),
	.reset_n	(reset_n),
	.write_req	(enable & wdata_req_reg),
	.read_req	(enable & rdata_valid),
	.data_in	({wdata_reg,be_reg}),
	.data_out	({written_data_fifo_out,written_be}),
	.full		(read_compare_fifo_full),
	.empty		(read_compare_fifo_empty));
defparam written_data_fifo.DEVICE_FAMILY	= DEVICE_FAMILY;
defparam written_data_fifo.FIFO_WIDTH		= DATA_WIDTH + BE_WIDTH;
defparam written_data_fifo.FIFO_SIZE		= WRITTEN_DATA_FIFO_SIZE;
defparam written_data_fifo.SHOW_AHEAD		= "OFF";


endmodule

