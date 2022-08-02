
module pcie (
	clk_clk,
	reset_reset_n,
	axi_bridge_0_s0_awid,
	axi_bridge_0_s0_awaddr,
	axi_bridge_0_s0_awlen,
	axi_bridge_0_s0_awsize,
	axi_bridge_0_s0_awburst,
	axi_bridge_0_s0_awlock,
	axi_bridge_0_s0_awcache,
	axi_bridge_0_s0_awprot,
	axi_bridge_0_s0_awvalid,
	axi_bridge_0_s0_awready,
	axi_bridge_0_s0_wid,
	axi_bridge_0_s0_wdata,
	axi_bridge_0_s0_wstrb,
	axi_bridge_0_s0_wlast,
	axi_bridge_0_s0_wvalid,
	axi_bridge_0_s0_wready,
	axi_bridge_0_s0_bid,
	axi_bridge_0_s0_bresp,
	axi_bridge_0_s0_bvalid,
	axi_bridge_0_s0_bready,
	axi_bridge_0_s0_arid,
	axi_bridge_0_s0_araddr,
	axi_bridge_0_s0_arlen,
	axi_bridge_0_s0_arsize,
	axi_bridge_0_s0_arburst,
	axi_bridge_0_s0_arlock,
	axi_bridge_0_s0_arcache,
	axi_bridge_0_s0_arprot,
	axi_bridge_0_s0_arvalid,
	axi_bridge_0_s0_arready,
	axi_bridge_0_s0_rid,
	axi_bridge_0_s0_rdata,
	axi_bridge_0_s0_rresp,
	axi_bridge_0_s0_rlast,
	axi_bridge_0_s0_rvalid,
	axi_bridge_0_s0_rready);	

	input		clk_clk;
	input		reset_reset_n;
	input	[7:0]	axi_bridge_0_s0_awid;
	input	[10:0]	axi_bridge_0_s0_awaddr;
	input	[3:0]	axi_bridge_0_s0_awlen;
	input	[2:0]	axi_bridge_0_s0_awsize;
	input	[1:0]	axi_bridge_0_s0_awburst;
	input	[1:0]	axi_bridge_0_s0_awlock;
	input	[3:0]	axi_bridge_0_s0_awcache;
	input	[2:0]	axi_bridge_0_s0_awprot;
	input		axi_bridge_0_s0_awvalid;
	output		axi_bridge_0_s0_awready;
	input	[7:0]	axi_bridge_0_s0_wid;
	input	[31:0]	axi_bridge_0_s0_wdata;
	input	[3:0]	axi_bridge_0_s0_wstrb;
	input		axi_bridge_0_s0_wlast;
	input		axi_bridge_0_s0_wvalid;
	output		axi_bridge_0_s0_wready;
	output	[7:0]	axi_bridge_0_s0_bid;
	output	[1:0]	axi_bridge_0_s0_bresp;
	output		axi_bridge_0_s0_bvalid;
	input		axi_bridge_0_s0_bready;
	input	[7:0]	axi_bridge_0_s0_arid;
	input	[10:0]	axi_bridge_0_s0_araddr;
	input	[3:0]	axi_bridge_0_s0_arlen;
	input	[2:0]	axi_bridge_0_s0_arsize;
	input	[1:0]	axi_bridge_0_s0_arburst;
	input	[1:0]	axi_bridge_0_s0_arlock;
	input	[3:0]	axi_bridge_0_s0_arcache;
	input	[2:0]	axi_bridge_0_s0_arprot;
	input		axi_bridge_0_s0_arvalid;
	output		axi_bridge_0_s0_arready;
	output	[7:0]	axi_bridge_0_s0_rid;
	output	[31:0]	axi_bridge_0_s0_rdata;
	output	[1:0]	axi_bridge_0_s0_rresp;
	output		axi_bridge_0_s0_rlast;
	output		axi_bridge_0_s0_rvalid;
	input		axi_bridge_0_s0_rready;
endmodule
