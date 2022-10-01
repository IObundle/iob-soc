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


`timescale 1ns/10ps
module alt_pma_controller_tgx #(
	parameter number_of_plls = 1,// One controller only control the possible merged pll. If more pll is needed, user can use multiplier controller for none share plls.
	parameter tx_pll_reset_hold_time = 0,// ignored - now calculated according to system clock
	parameter sync_depth = 2,
	parameter sys_clk_in_mhz = 50	// needed for 1us and 4us delay timers
)
(
	input              rst, // controller logic reset
	output             tx_pll_ready,
	
	// user data (avalon-MM formatted) 
	input    wire        clk,
	input    wire [1:0]  pma_mgmt_address,
	input    wire        pma_mgmt_read,
	output   reg  [31:0] pma_mgmt_readdata,
	input    wire        pma_mgmt_write,
	input    wire [31:0] pma_mgmt_writedata,
	output   wire        pma_mgmt_waitrequest,
	
	// user data (avalon-clock formatted) 
	input   wire	cal_blk_clk,
	
	// user data: pll control (avalon-ST formatted)
	output   wire	cal_blk_pdn,//sync with cal_blk_clk
	output   wire	gx_pdn,//sync with clk
	output   wire	[number_of_plls-1:0]	pll_pdn, //sync with clk 
	input    wire	[number_of_plls-1:0]	pll_locked //
);

localparam clk_in_mhz =
`ifdef QUARTUS__SIMGEN
	2;	// simulation-only value
`elsif ALTERA_RESERVED_QIS
	sys_clk_in_mhz;	// use real counter lengths for normal Quartus synthesis
`else
	2;	// simulation-only value
`endif
localparam t_pll_powerdown = clk_in_mhz; // 1 us minimum
localparam t_ltd_auto = clk_in_mhz*4; // 4 us minimum

wire [number_of_plls-1:0]  pll_locked_sync;
reg  	cal_blk_pdn_reg;
reg read_delay;
reg gx_pdn_reg;
reg   pll_pdn_resetall_avmm;
wire pll_pdn_int;
reg   pll_pdn_reg;

wire gx_pdn_int;
wire gx_pdn_done;

altera_wait_generate wait_gen(
 .rst(rst),
.clk(clk),
.launch_signal(pma_mgmt_read),
.wait_req(pma_mgmt_waitrequest)
 );
      
alt_reset_ctrl_lego
#(
.reset_hold_cycles (t_pll_powerdown)	// reset pulse length in clock cycles
) pll_pdn_rst
(
.clock(clk),
.start(1'b1 ),
.reset(pll_pdn_int),
.rdone(pll_locked),	// reset done signal
.aclr(rst),
.sdone(tx_pll_ready)	// sequence done for this lego
);

alt_reset_ctrl_lego
#(
.reset_hold_cycles (2)	// reset pulse length in clock cycles
) gx_pdn_rst
(
.clock(clk),
.start(1'b1 ),
.reset(gx_pdn_int),
.rdone(1'b1),	// reset done signal
.aclr(rst),
.sdone(gx_pdn_done)	// sequence done for this lego
);

assign pll_pdn= pll_pdn_reg | {number_of_plls{pll_pdn_int}} ;

initial
begin
	pll_pdn_reg <= 0;
end
always @ (posedge clk, posedge rst)
begin 
	if(rst) begin
		pll_pdn_reg <= 1'b0;
	end
	else if (pma_mgmt_write==1'b1 & pma_mgmt_address==2'b00) begin
		pll_pdn_reg <= pma_mgmt_writedata[number_of_plls -1 :0];
	end
end

initial
begin
	pma_mgmt_readdata <= 0;
end
always @ (posedge clk, posedge rst)
begin 
	if(rst) begin
		pma_mgmt_readdata <= 0;
	end
	else if (pma_mgmt_read==1'b1 & pma_mgmt_address==2'b00) begin
		pma_mgmt_readdata[number_of_plls -1 :0] <= pll_pdn;
	end
	else if (pma_mgmt_read==1'b1 & pma_mgmt_address==2'b01) begin
		pma_mgmt_readdata[0] <= cal_blk_pdn_reg;
		pma_mgmt_readdata[1] <= gx_pdn;
	end
	else if (pma_mgmt_read==1'b1 & pma_mgmt_address==2'b10) begin
		pma_mgmt_readdata[number_of_plls -1 :0] <= pll_locked_sync;
	end
	else
		pma_mgmt_readdata <= 0;
end

generate
genvar i;
for (i=0; i<number_of_plls; i=i+1) 
begin: lock_sync
	altera_std_synchronizer
	#(
	.depth (sync_depth)	// reset pulse length in clock cycles
	)stdsync
	( 
		.clk(clk),
		.din(pll_locked[i]),
		.dout(pll_locked_sync[i]),
		.reset_n((~ rst))
	);
end 
endgenerate

initial
begin
	cal_blk_pdn_reg <= 0;
end
always @ (posedge clk, posedge rst)
begin 
	if(rst) begin
		cal_blk_pdn_reg <= 0;
	end
	else if (pma_mgmt_write==1'b1 & pma_mgmt_address==2'b01) begin
		cal_blk_pdn_reg <= pma_mgmt_writedata[0];
	end
end
altera_std_synchronizer   	
#(
	.depth (sync_depth)	// reset pulse length in clock cycles
)stdsync
( 
	.clk(cal_blk_clk),
	.din(cal_blk_pdn_reg),
	.dout(cal_blk_pdn),
	.reset_n((~ rst))
);

assign gx_pdn = gx_pdn_reg | gx_pdn_int;
initial
begin
	gx_pdn_reg <= 0;
end
always @ (posedge clk, posedge rst)
begin 
	if(rst) begin
		gx_pdn_reg <= 0;
	end
	else if (pma_mgmt_write==1'b1 & pma_mgmt_address==2'b01) begin
		gx_pdn_reg <= pma_mgmt_writedata[1];
	end
	else begin
		gx_pdn_reg <= gx_pdn_reg;
	end
		
end
endmodule

