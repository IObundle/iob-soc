`timescale 1ns / 1ps

`include "system.vh"


//PHEADER

module top_system
	(
`ifdef USE_DDR //AXI MASTER INTERFACE OF TESTER AND SUT

   //address write
   output [1:0][0:0]             m_axi_awid, 
   output [1:0][`DDR_ADDR_W-1:0] m_axi_awaddr,
   output [1:0][7:0]             m_axi_awlen,
   output [1:0][2:0]             m_axi_awsize,
   output [1:0][1:0]             m_axi_awburst,
   output [1:0][0:0]             m_axi_awlock,
   output [1:0][3:0]             m_axi_awcache,
   output [1:0][2:0]             m_axi_awprot,
   output [1:0][3:0]             m_axi_awqos,
   output [1:0]                  m_axi_awvalid,
   input [1:0]                   m_axi_awready,

   //write
   output [1:0][`DATA_W-1:0]     m_axi_wdata,
   output [1:0][`DATA_W/8-1:0]   m_axi_wstrb,
   output [1:0]                  m_axi_wlast,
   output [1:0]                  m_axi_wvalid, 
   input [1:0]                   m_axi_wready,

   //write response
   input [1:0][0:0]              m_axi_bid,
   input [1:0][1:0]              m_axi_bresp,
   input [1:0]                   m_axi_bvalid,
   output [1:0]                  m_axi_bready,
  
   //address read
   output [1:0][0:0]             m_axi_arid,
   output [1:0][`DDR_ADDR_W-1:0] m_axi_araddr, 
   output [1:0][7:0]             m_axi_arlen,
   output [1:0][2:0]             m_axi_arsize,
   output [1:0][1:0]             m_axi_arburst,
   output [1:0][0:0]             m_axi_arlock,
   output [1:0][3:0]             m_axi_arcache,
   output [1:0][2:0]             m_axi_arprot,
   output [1:0][3:0]             m_axi_arqos,
   output [1:0]                  m_axi_arvalid, 
   input [1:0]                   m_axi_arready,

   //read
   input [1:0][0:0]              m_axi_rid,
   input [1:0][`DATA_W-1:0]      m_axi_rdata,
   input [1:0][1:0]              m_axi_rresp,
   input [1:0]                   m_axi_rlast, 
   input [1:0]                   m_axi_rvalid, 
   output [1:0]                  m_axi_rready,
`endif //  `ifdef USE_DDR

	//Top system peripheral external interface
   //PIO
	

   input                    clk,
   input                    reset,
   output [1:0]             trap
	);

   //PWIRES

	//Wires to interconnect default REGFILEIF for communication between SUT and Tester
   wire                           REGFILEIF_MERGE_valid;
   wire [`REGFILEIF_ADDR_W-1:0]   REGFILEIF_MERGE_address;
   wire [`REGFILEIF_DATA_W-1:0]   REGFILEIF_MERGE_wdata;
   wire [`REGFILEIF_DATA_W/8-1:0] REGFILEIF_MERGE_wstrb;
   wire [`REGFILEIF_DATA_W-1:0]   REGFILEIF_MERGE_rdata;
   wire                           REGFILEIF_MERGE_ready;
   
   //
   // INSTANTIATE COMPONENTS
   //
   system sut (
		//SUTPORTS

		//Default REGFILEIF for communication between SUT and Tester
		.REGFILEIF_SUT_valid(REGFILEIF_MERGE_valid),
		.REGFILEIF_SUT_address(REGFILEIF_MERGE_address),
		.REGFILEIF_SUT_wdata(REGFILEIF_MERGE_wdata),
		.REGFILEIF_SUT_wstrb(REGFILEIF_MERGE_wstrb),
		.REGFILEIF_SUT_rdata(REGFILEIF_MERGE_rdata),
		.REGFILEIF_SUT_ready(REGFILEIF_MERGE_ready),
`ifdef USE_DDR
		//address write
		.axi_awid(m_axi_awid[0]), 
		.axi_awaddr(m_axi_awaddr[0]), 
		.axi_awlen(m_axi_awlen[0]), 
		.axi_awsize(m_axi_awsize[0]), 
		.axi_awburst(m_axi_awburst[0]), 
		.axi_awlock(m_axi_awlock[0]), 
		.axi_awcache(m_axi_awcache[0]), 
		.axi_awprot(m_axi_awprot[0]),
		.axi_awqos(m_axi_awqos[0]), 
		.axi_awvalid(m_axi_awvalid[0]), 
		.axi_awready(m_axi_awready[0]), 
		//write
		.axi_wdata(m_axi_wdata[0]), 
		.axi_wstrb(m_axi_wstrb[0]), 
		.axi_wlast(m_axi_wlast[0]), 
		.axi_wvalid(m_axi_wvalid[0]), 
		.axi_wready(m_axi_wready[0]), 
		//write response
		.axi_bid(m_axi_bid[0]),
		.axi_bresp(m_axi_bresp[0]), 
		.axi_bvalid(m_axi_bvalid[0]), 
		.axi_bready(m_axi_bready[0]), 
		//address read
		.axi_arid(m_axi_arid[0]), 
		.axi_araddr(m_axi_araddr[0]), 
		.axi_arlen(m_axi_arlen[0]), 
		.axi_arsize(m_axi_arsize[0]), 
		.axi_arburst(m_axi_arburst[0]), 
		.axi_arlock(m_axi_arlock[0]), 
		.axi_arcache(m_axi_arcache[0]), 
		.axi_arprot(m_axi_arprot[0]), 
		.axi_arqos(m_axi_arqos[0]), 
		.axi_arvalid(m_axi_arvalid[0]), 
		.axi_arready(m_axi_arready[0]), 
		//read 
		.axi_rid(m_axi_rid[0]),
		.axi_rdata(m_axi_rdata[0]), 
		.axi_rresp(m_axi_rresp[0]), 
		.axi_rlast(m_axi_rlast[0]), 
		.axi_rvalid(m_axi_rvalid[0]),  
		.axi_rready(m_axi_rready[0])
`endif               
		.clk           (clk),
		.reset         (reset),
		.trap          (trap[0])
	);

   tester tester0 (
		//TESTERPORTS

		//Default REGFILEIF for communication between SUT and Tester
		.REGFILEIF_TESTER_valid(REGFILEIF_MERGE_valid),
		.REGFILEIF_TESTER_address(REGFILEIF_MERGE_address),
		.REGFILEIF_TESTER_wdata(REGFILEIF_MERGE_wdata),
		.REGFILEIF_TESTER_wstrb(REGFILEIF_MERGE_wstrb),
		.REGFILEIF_TESTER_rdata(REGFILEIF_MERGE_rdata),
		.REGFILEIF_TESTER_ready(REGFILEIF_MERGE_ready),
`ifdef USE_DDR
		//address write
		.axi_awid(m_axi_awid[1]), 
		.axi_awaddr(m_axi_awaddr[1]), 
		.axi_awlen(m_axi_awlen[1]), 
		.axi_awsize(m_axi_awsize[1]), 
		.axi_awburst(m_axi_awburst[1]), 
		.axi_awlock(m_axi_awlock[1]), 
		.axi_awcache(m_axi_awcache[1]), 
		.axi_awprot(m_axi_awprot[1]),
		.axi_awqos(m_axi_awqos[1]), 
		.axi_awvalid(m_axi_awvalid[1]), 
		.axi_awready(m_axi_awready[1]), 
		//write
		.axi_wdata(m_axi_wdata[1]), 
		.axi_wstrb(m_axi_wstrb[1]), 
		.axi_wlast(m_axi_wlast[1]), 
		.axi_wvalid(m_axi_wvalid[1]), 
		.axi_wready(m_axi_wready[1]), 
		//write response
		.axi_bid(m_axi_bid[1]),
		.axi_bresp(m_axi_bresp[1]), 
		.axi_bvalid(m_axi_bvalid[1]), 
		.axi_bready(m_axi_bready[1]), 
		//address read
		.axi_arid(m_axi_arid[1]), 
		.axi_araddr(m_axi_araddr[1]), 
		.axi_arlen(m_axi_arlen[1]), 
		.axi_arsize(m_axi_arsize[1]), 
		.axi_arburst(m_axi_arburst[1]), 
		.axi_arlock(m_axi_arlock[1]), 
		.axi_arcache(m_axi_arcache[1]), 
		.axi_arprot(m_axi_arprot[1]), 
		.axi_arqos(m_axi_arqos[1]), 
		.axi_arvalid(m_axi_arvalid[1]), 
		.axi_arready(m_axi_arready[1]), 
		//read 
		.axi_rid(m_axi_rid[1]),
		.axi_rdata(m_axi_rdata[1]), 
		.axi_rresp(m_axi_rresp[1]), 
		.axi_rlast(m_axi_rlast[1]), 
		.axi_rvalid(m_axi_rvalid[1]),  
		.axi_rready(m_axi_rready[1])
`endif               
		.clk           (clk),
		.reset         (reset),
		.trap          (trap[1])
	);
   
endmodule
