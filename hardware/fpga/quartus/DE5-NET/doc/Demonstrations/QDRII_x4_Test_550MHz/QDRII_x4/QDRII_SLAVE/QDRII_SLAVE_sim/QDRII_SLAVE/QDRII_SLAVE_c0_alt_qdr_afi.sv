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


//////////////////////////////////////////////////////////////////////////////
// The AFI module serves two purposes.  First, it translates the main state
// machine commands into the AFI 2.0 protocol.  Second, it delays the write
// data to satisfy the write latency requirement.
//////////////////////////////////////////////////////////////////////////////

module QDRII_SLAVE_c0_alt_qdr_afi (
	clk,
	reset_n,
	do_write,
	do_read,
	write_addr,
	read_addr,
	wdata,
	rdata_valid,
	rdata,
	afi_addr,
	afi_wps_n,
	afi_rps_n,
	afi_wdata_valid,
	afi_wdata,
	afi_bws_n,
	afi_rdata_en,
	afi_rdata_en_full,
	afi_rdata,
	afi_rdata_valid
);

//////////////////////////////////////////////////////////////////////////////
// BEGIN PARAMETER SECTION

// CONTROLLER PARAMETERS
// Maximum write latency in controller cycles
parameter CTL_ADDR_WIDTH		= "";
parameter CTL_CS_WIDTH			= "";
parameter CTL_DWIDTH			= "";
parameter CTL_T_WL				= "";

// AFI 2.0 INTERFACE PARAMETERS
parameter AFI_ADDR_WIDTH		= "";
parameter AFI_CS_WIDTH			= "";
parameter AFI_DM_WIDTH			= "";
parameter AFI_DWIDTH			= "";
parameter AFI_WRITE_DQS_WIDTH = "";
parameter AFI_CONTROL_WIDTH = "";

// END PARAMETER SECTION
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////
// BEGIN PORT SECTION

// Clock and reset interface
input							clk;
input							reset_n;

// Commands from main state machine
input							do_write;
input							do_read;

input	[CTL_ADDR_WIDTH-1:0]	write_addr;
input	[CTL_ADDR_WIDTH-1:0]	read_addr;
input	[CTL_DWIDTH-1:0]		wdata;
output							rdata_valid;
output	[CTL_DWIDTH-1:0]		rdata;

// AFI 2.0 PHY-Controller Interface
// Address and command
output	[AFI_ADDR_WIDTH-1:0]	afi_addr;
output	[AFI_CONTROL_WIDTH-1:0]		afi_wps_n;
output	[AFI_CONTROL_WIDTH-1:0]		afi_rps_n;
// Write data
output	[AFI_WRITE_DQS_WIDTH-1:0]						afi_wdata_valid;
output	[AFI_DWIDTH-1:0]		afi_wdata;
output	[AFI_DM_WIDTH-1:0]		afi_bws_n;
// Read data
output							afi_rdata_en;
output							afi_rdata_en_full;
input	[AFI_DWIDTH-1:0]		afi_rdata;
input							afi_rdata_valid;

// END PORT SECTION
//////////////////////////////////////////////////////////////////////////////

wire							wdata_valid_wire;
wire	[AFI_DWIDTH-1:0]		wdata_wire;

wire	[CTL_T_WL:0]			wdata_valid_shifter;
wire	[CTL_T_WL:0]			wdata_shifter [AFI_DWIDTH-1:0];

logic	[CTL_ADDR_WIDTH-1:0]	afi_addr_h;
logic	[AFI_CONTROL_WIDTH/2-1:0]		afi_wps_n_h;
logic	[AFI_CONTROL_WIDTH/2-1:0]		afi_rps_n_h;

logic	[CTL_ADDR_WIDTH-1:0]	afi_addr_l;
logic	[AFI_CONTROL_WIDTH/2-1:0]		afi_wps_n_l;
logic	[AFI_CONTROL_WIDTH/2-1:0]		afi_rps_n_l;


assign afi_addr = {afi_addr_h,afi_addr_l};
assign afi_wps_n = {afi_wps_n_h,afi_wps_n_l};
assign afi_rps_n = {afi_rps_n_h,afi_rps_n_l};

assign wdata_valid_wire = do_write;
assign wdata_wire = wdata;
assign afi_rdata_en = do_read;
assign afi_rdata_en_full = do_read;
assign rdata = afi_rdata;
assign rdata_valid = afi_rdata_valid;


// Delay 'afi_wdata_valid', 'afi_wdata', and 'afi_bws_n' by CTL_T_WL cycles
QDRII_SLAVE_c0_memctl_burst_latency_shifter write_latency_shifter_for_wdata_valid (
	.clk		(clk),
	.reset_n	(reset_n),
	.d			(wdata_valid_wire),
	.q			(wdata_valid_shifter));
defparam write_latency_shifter_for_wdata_valid.MAX_LATENCY	= CTL_T_WL;
defparam write_latency_shifter_for_wdata_valid.BURST_LENGTH	= 1;

// Don't differentiate between DQS groups and enable all data
assign afi_wdata_valid = {AFI_WRITE_DQS_WIDTH{wdata_valid_shifter[CTL_T_WL]}};

genvar i;
generate
for (i = 0; i < AFI_DWIDTH; i++)
begin : wdata_shifter_gen
	QDRII_SLAVE_c0_memctl_burst_latency_shifter write_latency_shifter_for_wdata (
		.clk		(clk),
		.reset_n	(reset_n),
		.d			(wdata_wire[i]),
		.q			(wdata_shifter[i]));
	defparam write_latency_shifter_for_wdata.MAX_LATENCY	= CTL_T_WL;
	defparam write_latency_shifter_for_wdata.BURST_LENGTH	= 1;

	assign afi_wdata[i] = wdata_shifter[i][CTL_T_WL];
end
endgenerate

assign afi_bws_n = '0;


// AFI 2.0 command translation
always_comb
begin
	afi_addr_h <= read_addr;

	if (do_read)
	begin
		afi_wps_n_h <= 1'b1;
		afi_rps_n_h <= 1'b0;
	end
	else
	begin
		afi_wps_n_h <= 1'b1;
		afi_rps_n_h <= 1'b1;
	end
	
	afi_addr_l <= write_addr;

	if (do_write)
	begin
		afi_wps_n_l <= 1'b0;
		afi_rps_n_l <= 1'b1;
	end
	else
	begin
		afi_wps_n_l <= 1'b1;
		afi_rps_n_l <= 1'b1;
	end
end


endmodule

