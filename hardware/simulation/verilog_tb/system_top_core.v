`timescale 1ns / 1ps

`include "tester.vh"
`include "iob_lib.vh"

//PHEADER

module system_top 
  (
   output                             trap,
   //tester uart
   input                              uart_valid,
   input [`iob_uart_swreg_ADDR_W-1:0] uart_addr,
   input [`TESTER_DATA_W-1:0]      uart_wdata,
   input [3:0]              uart_wstrb,
   output [`TESTER_DATA_W-1:0]     uart_rdata,
   output                   uart_ready
   `include "iob_gen_if.vh"
   );
 
   localparam AXI_ID_W = 4;
   localparam AXI_ADDR_W=`TESTER_DDR_ADDR_W;
   localparam AXI_DATA_W=`TESTER_DATA_W;
 
   //PWIRES

   
   /////////////////////////////////////////////
   // TEST PROCEDURE
   //
   initial begin

`ifdef TESTER_VCD
      $dumpfile("system.vcd");
      $dumpvars();
`endif

   end
   
   //
   // INSTANTIATE COMPONENTS
   //

   //DDR AXI interface signals (2 for the two systems + 1 for memory)
`ifdef TESTER_USE_DDR
   //Write address
   wire [1:0]                   m_axi_awid;
   wire [3*`TESTER_DDR_ADDR_W-1:0]     m_axi_awaddr;
   wire [3*(7+1)-1:0]           m_axi_awlen;
   wire [3*(2+1)-1:0]           m_axi_awsize;
   wire [3*(1+1)-1:0]           m_axi_awburst;
   wire [2:0]                   m_axi_awlock;
   wire [3*(3+1)-1:0]           m_axi_awcache;
   wire [3*(2+1)-1:0]           m_axi_awprot;
   wire [3*(3+1)-1:0]           m_axi_awqos;
   wire [2:0]                   m_axi_awvalid;
   wire [2:0]                   m_axi_awready;
   //Write data
   wire [3*(31+1)-1:0]          m_axi_wdata;
   wire [3*(3+1)-1:0]           m_axi_wstrb;
   wire [2:0]                   m_axi_wlast;
   wire [2:0]                   m_axi_wvalid;
   wire [2:0]                   m_axi_wready;
   //Write response
   wire [3*(7+1)-1:0]           m_axi_bid;
   wire [3*(1+1)-1:0]           m_axi_bresp;
   wire [2:0]                   m_axi_bvalid;
   wire [2:0]                   m_axi_bready;
   //Read address
   wire [1:0]                   m_axi_arid;
   wire [3*`TESTER_DDR_ADDR_W-1:0]     m_axi_araddr;
   wire [3*(7+1)-1:0]           m_axi_arlen;
   wire [3*(2+1)-1:0]           m_axi_arsize;
   wire [3*(1+1)-1:0]           m_axi_arburst;
   wire [2:0]                   m_axi_arlock;
   wire [3*(3+1)-1:0]           m_axi_arcache;
   wire [3*(2+1)-1:0]           m_axi_arprot;
   wire [3*(3+1)-1:0]           m_axi_arqos;
   wire [2:0]                   m_axi_arvalid;
   wire [2:0]                   m_axi_arready;
   //Read data
   wire [3*(7+1)-1:0]           m_axi_rid;
   wire [3*(31+1)-1:0]          m_axi_rdata;
   wire [3*(1+1)-1:0]           m_axi_rresp;
   wire [2:0]                   m_axi_rlast;
   wire [2:0]                   m_axi_rvalid;
   wire [2:0]                   m_axi_rready;

	//Signals for connection between interconnect and ram
   wire [7:0]                   memory_ddr_awid; 
   wire [7:0]                   memory_ddr_arid; 
`endif

   //'Or' between trap signals of Tester and SUT
   wire [1:0]                   trap_signals;
   assign trap = trap_signals[0] || trap_signals[1];

   //
   // Tester (also includes Unit Under Test)
   //
   tester 
     #(
       .AXI_ID_W(AXI_ID_W),
       .AXI_ADDR_W(AXI_ADDR_W),
       .AXI_DATA_W(AXI_DATA_W)
       )
	tester0 (
               //PORTS
`ifdef TESTER_USE_DDR
               //address write
	       .m_axi_awid    (m_axi_awid[1:0]),
	       .m_axi_awaddr  (m_axi_awaddr[2*`TESTER_DDR_ADDR_W-1:0]),
	       .m_axi_awlen   (m_axi_awlen[2*(7+1)-1:0]),
	       .m_axi_awsize  (m_axi_awsize[2*(2+1)-1:0]),
	       .m_axi_awburst (m_axi_awburst[2*(1+1)-1:0]),
	       .m_axi_awlock  (m_axi_awlock[1:0]),
	       .m_axi_awcache (m_axi_awcache[2*(3+1)-1:0]),
	       .m_axi_awprot  (m_axi_awprot[2*(2+1)-1:0]),
	       .m_axi_awqos   (m_axi_awqos[2*(3+1)-1:0]),
	       .m_axi_awvalid (m_axi_awvalid[1:0]),
	       .m_axi_awready (m_axi_awready[1:0]),
               
	       //write  
	       .m_axi_wdata   (m_axi_wdata[2*(31+1)-1:0]),
	       .m_axi_wstrb   (m_axi_wstrb[2*(3+1)-1:0]),
	       .m_axi_wlast   (m_axi_wlast[1:0]),
	       .m_axi_wvalid  (m_axi_wvalid[1:0]),
	       .m_axi_wready  (m_axi_wready[1:0]),
               
	       //write response
	       .m_axi_bid     ({m_axi_bid[(7+1)],m_axi_bid[0]}),
	       .m_axi_bresp   (m_axi_bresp[2*(1+1)-1:0]),
	       .m_axi_bvalid  (m_axi_bvalid[1:0]),
	       .m_axi_bready  (m_axi_bready[1:0]),
               
	       //address read
	       .m_axi_arid    (m_axi_arid[1:0]),
	       .m_axi_araddr  (m_axi_araddr[2*`TESTER_DDR_ADDR_W-1:0]),
	       .m_axi_arlen   (m_axi_arlen[2*(7+1)-1:0]),
	       .m_axi_arsize  (m_axi_arsize[2*(2+1)-1:0]),
	       .m_axi_arburst (m_axi_arburst[2*(1+1)-1:0]),
	       .m_axi_arlock  (m_axi_arlock[1:0]),
	       .m_axi_arcache (m_axi_arcache[2*(3+1)-1:0]),
	       .m_axi_arprot  (m_axi_arprot[2*(2+1)-1:0]),
	       .m_axi_arqos   (m_axi_arqos[2*(3+1)-1:0]),
	       .m_axi_arvalid (m_axi_arvalid[1:0]),
	       .m_axi_arready (m_axi_arready[1:0]),
               
	       //read   
	       .m_axi_rid     ({m_axi_rid[7+1],m_axi_rid[0]}),
	       .m_axi_rdata   (m_axi_rdata[2*(31+1)-1:0]),
	       .m_axi_rresp   (m_axi_rresp[2*(1+1)-1:0]),
	       .m_axi_rlast   (m_axi_rlast[1:0]),
	       .m_axi_rvalid  (m_axi_rvalid[1:0]),
	       .m_axi_rready  (m_axi_rready[1:0]),	
`endif               
	       .clk           (clk),
	       .reset         (rst),
	       .trap          (trap_signals)
	       );

`ifdef TESTER_USE_DDR
	//instantiate axi interconnect
	//This connects Tester+SUT to the same memory
	axi_interconnect
		#(
		.DATA_WIDTH (`TESTER_DATA_W),
		.ADDR_WIDTH (`TESTER_DDR_ADDR_W),
		.M_ADDR_WIDTH (32'd`TESTER_DDR_ADDR_W),
		.S_COUNT (2),
		.M_COUNT (1)
		)
		system_axi_interconnect(
			.clk            (clk),
			.rst            (rst),

			.s_axi_awid     ({{8{m_axi_awid[1]}},{8{m_axi_awid[0]}}}),
			.s_axi_awaddr   (m_axi_awaddr[2*`TESTER_DDR_ADDR_W-1:0]),
			.s_axi_awlen    (m_axi_awlen[2*(7+1)-1:0]),
			.s_axi_awsize   (m_axi_awsize[2*(2+1)-1:0]),
			.s_axi_awburst  (m_axi_awburst[2*(1+1)-1:0]),
			.s_axi_awlock   (m_axi_awlock[1:0]),
			.s_axi_awprot   (m_axi_awprot[2*(2+1)-1:0]),
			.s_axi_awqos    (m_axi_awqos[2*(3+1)-1:0]),
			.s_axi_awcache  (m_axi_awcache[2*(3+1)-1:0]),
			.s_axi_awvalid  (m_axi_awvalid[1:0]),
			.s_axi_awready  (m_axi_awready[1:0]),

			//write  
			.s_axi_wvalid   (m_axi_wvalid[1:0]),
			.s_axi_wready   (m_axi_wready[1:0]),
			.s_axi_wdata    (m_axi_wdata[2*(31+1)-1:0]),
			.s_axi_wstrb    (m_axi_wstrb[2*(3+1)-1:0]),
			.s_axi_wlast    (m_axi_wlast[1:0]),

			//write response
			.s_axi_bready   (m_axi_bready[1:0]),
			.s_axi_bid      (m_axi_bid[2*(7+1)-1:0]),
			.s_axi_bresp    (m_axi_bresp[2*(1+1)-1:0]),
			.s_axi_bvalid   (m_axi_bvalid[1:0]),

			//address read
			.s_axi_arid     ({{8{m_axi_arid[1]}},{8{m_axi_arid[0]}}}),
			.s_axi_araddr   (m_axi_araddr[2*`TESTER_DDR_ADDR_W-1:0]),
			.s_axi_arlen    (m_axi_arlen[2*(7+1)-1:0]), 
			.s_axi_arsize   (m_axi_arsize[2*(2+1)-1:0]),    
			.s_axi_arburst  (m_axi_arburst[2*(1+1)-1:0]),
			.s_axi_arlock   (m_axi_arlock[1:0]),
			.s_axi_arcache  (m_axi_arcache[2*(3+1)-1:0]),
			.s_axi_arprot   (m_axi_arprot[2*(2+1)-1:0]),
			.s_axi_arqos    (m_axi_arqos[2*(3+1)-1:0]),
			.s_axi_arvalid  (m_axi_arvalid[1:0]),
			.s_axi_arready  (m_axi_arready[1:0]),

			//read   
			.s_axi_rready   (m_axi_rready[1:0]),
			.s_axi_rid      (m_axi_rid[2*(7+1)-1:0]),
			.s_axi_rdata    (m_axi_rdata[2*(31+1)-1:0]),
			.s_axi_rresp    (m_axi_rresp[2*(1+1)-1:0]),
			.s_axi_rlast    (m_axi_rlast[1:0]),
			.s_axi_rvalid   (m_axi_rvalid[1:0]),

			.m_axi_awid     (memory_ddr_awid),
			.m_axi_awaddr   (m_axi_awaddr[3*`TESTER_DDR_ADDR_W-1:2*`TESTER_DDR_ADDR_W]),
			.m_axi_awlen    (m_axi_awlen[3*(7+1)-1:2*(7+1)]),
			.m_axi_awsize   (m_axi_awsize[3*(2+1)-1:2*(2+1)]),
			.m_axi_awburst  (m_axi_awburst[3*(1+1)-1:2*(1+1)]),
			.m_axi_awlock   (m_axi_awlock[2]),
			.m_axi_awprot   (m_axi_awprot[3*(2+1)-1:2*(2+1)]),
			.m_axi_awqos    (m_axi_awqos[3*(3+1)-1:2*(3+1)]),
			.m_axi_awcache  (m_axi_awcache[3*(3+1)-1:2*(3+1)]),
			.m_axi_awvalid  (m_axi_awvalid[2]),
			.m_axi_awready  (m_axi_awready[2]),

			//write  
			.m_axi_wvalid   (m_axi_wvalid[2]),
			.m_axi_wready   (m_axi_wready[2]),
			.m_axi_wdata    (m_axi_wdata[3*(31+1)-1:2*(31+1)]),
			.m_axi_wstrb    (m_axi_wstrb[3*(3+1)-1:2*(3+1)]),
			.m_axi_wlast    (m_axi_wlast[2]),

			//write response
			.m_axi_bready   (m_axi_bready[2]),
			.m_axi_bid      (m_axi_bid[3*(7+1)-1:2*(7+1)]),
			.m_axi_bresp    (m_axi_bresp[3*(1+1)-1:2*(1+1)]),
			.m_axi_bvalid   (m_axi_bvalid[2]),

			//address read
			.m_axi_arid     (memory_ddr_arid),
			.m_axi_araddr   (m_axi_araddr[3*`TESTER_DDR_ADDR_W-1:2*`TESTER_DDR_ADDR_W]),
			.m_axi_arlen    (m_axi_arlen[3*(7+1)-1:2*(7+1)]), 
			.m_axi_arsize   (m_axi_arsize[3*(2+1)-1:2*(2+1)]),    
			.m_axi_arburst  (m_axi_arburst[3*(1+1)-1:2*(1+1)]),
			.m_axi_arlock   (m_axi_arlock[2]),
			.m_axi_arcache  (m_axi_arcache[3*(3+1)-1:2*(3+1)]),
			.m_axi_arprot   (m_axi_arprot[3*(2+1)-1:2*(2+1)]),
			.m_axi_arqos    (m_axi_arqos[3*(3+1)-1:2*(3+1)]),
			.m_axi_arvalid  (m_axi_arvalid[2]),
			.m_axi_arready  (m_axi_arready[2]),

			//read   
			.m_axi_rready   (m_axi_rready[2]),
			.m_axi_rid      (m_axi_rid[3*(7+1)-1:2*(7+1)]),
			.m_axi_rdata    (m_axi_rdata[3*(31+1)-1:2*(31+1)]),
			.m_axi_rresp    (m_axi_rresp[3*(1+1)-1:2*(1+1)]),
			.m_axi_rlast    (m_axi_rlast[2]),
			.m_axi_rvalid   (m_axi_rvalid[2]),

			//optional signals
			.s_axi_awuser   (2'b00),
			.s_axi_wuser    (2'b00),
			.s_axi_aruser   (2'b00),
			.m_axi_buser    (1'b0),
			.m_axi_ruser    (1'b0)
		);


   //instantiate the axi memory 
	//Tester and SUT access the same memory.
	axi_ram 
		#(
		`ifdef TESTER_DDR_INIT
		.FILE("init_ddr_contents.hex"), //This file contains firmware for both systems
		.FILE_SIZE(2**(`TESTER_DDR_ADDR_W-2)),
		`endif
		.ID_WIDTH (AXI_ID_W),
		.DATA_WIDTH (`TESTER_DATA_W),
		.ADDR_WIDTH (`TESTER_DDR_ADDR_W)
		)
		ddr_model_mem(
			//address write
			.clk            (clk),
			.rst            (rst),

			.s_axi_awid     (memory_ddr_awid),
			.s_axi_awaddr   (m_axi_awaddr[3*`TESTER_DDR_ADDR_W-1:2*`TESTER_DDR_ADDR_W]),
			.s_axi_awlen    (m_axi_awlen[3*(7+1)-1:2*(7+1)]),
			.s_axi_awsize   (m_axi_awsize[3*(2+1)-1:2*(2+1)]),
			.s_axi_awburst  (m_axi_awburst[3*(1+1)-1:2*(1+1)]),
			.s_axi_awlock   (m_axi_awlock[2]),
			.s_axi_awprot   (m_axi_awprot[3*(2+1)-1:2*(2+1)]),
			.s_axi_awcache  (m_axi_awcache[3*(3+1)-1:2*(3+1)]),
			.s_axi_awvalid  (m_axi_awvalid[2]),
			.s_axi_awready  (m_axi_awready[2]),

			//write  
			.s_axi_wvalid   (m_axi_wvalid[2]),
			.s_axi_wready   (m_axi_wready[2]),
			.s_axi_wdata    (m_axi_wdata[3*(31+1)-1:2*(31+1)]),
			.s_axi_wstrb    (m_axi_wstrb[3*(3+1)-1:2*(3+1)]),
			.s_axi_wlast    (m_axi_wlast[2]),

			//write response
			.s_axi_bready   (m_axi_bready[2]),
			.s_axi_bid      (m_axi_bid[3*(7+1)-1:2*(7+1)]),
			.s_axi_bresp    (m_axi_bresp[3*(1+1)-1:2*(1+1)]),
			.s_axi_bvalid   (m_axi_bvalid[2]),

			//address read
			.s_axi_arid     (memory_ddr_arid),
			.s_axi_araddr   (m_axi_araddr[3*`TESTER_DDR_ADDR_W-1:2*`TESTER_DDR_ADDR_W]),
			.s_axi_arlen    (m_axi_arlen[3*(7+1)-1:2*(7+1)]), 
			.s_axi_arsize   (m_axi_arsize[3*(2+1)-1:2*(2+1)]),    
			.s_axi_arburst  (m_axi_arburst[3*(1+1)-1:2*(1+1)]),
			.s_axi_arlock   (m_axi_arlock[2]),
			.s_axi_arcache  (m_axi_arcache[3*(3+1)-1:2*(3+1)]),
			.s_axi_arprot   (m_axi_arprot[3*(2+1)-1:2*(2+1)]),
			.s_axi_arvalid  (m_axi_arvalid[2]),
			.s_axi_arready  (m_axi_arready[2]),

			//read   
			.s_axi_rready   (m_axi_rready[2]),
			.s_axi_rid      (m_axi_rid[3*(7+1)-1:2*(7+1)]),
			.s_axi_rdata    (m_axi_rdata[3*(31+1)-1:2*(31+1)]),
			.s_axi_rresp    (m_axi_rresp[3*(1+1)-1:2*(1+1)]),
			.s_axi_rlast    (m_axi_rlast[2]),
			.s_axi_rvalid   (m_axi_rvalid[2])
		);   
`endif


//finish simulation on trap
/* //Sut
always @(posedge trap[0]) begin
	#10 $display("Found SUT CPU trap condition");
	$finish;
   end
//Tester
always @(posedge trap[1]) begin
	#10 $display("Found Tester CPU trap condition");
	$finish;
   end */

   //sram monitor - use for debugging programs
   /*
    wire [`SRAM_ADDR_W-1:0] sram_daddr = uut.int_mem0.int_sram.d_addr;
    wire sram_dwstrb = |uut.int_mem0.int_sram.d_wstrb & uut.int_mem0.int_sram.d_valid;
    wire sram_drdstrb = !uut.int_mem0.int_sram.d_wstrb & uut.int_mem0.int_sram.d_valid;
    wire [`DATA_W-1:0] sram_dwdata = uut.int_mem0.int_sram.d_wdata;


    wire sram_iwstrb = |uut.int_mem0.int_sram.i_wstrb & uut.int_mem0.int_sram.i_valid;
    wire sram_irdstrb = !uut.int_mem0.int_sram.i_wstrb & uut.int_mem0.int_sram.i_valid;
    wire [`SRAM_ADDR_W-1:0] sram_iaddr = uut.int_mem0.int_sram.i_addr;
    wire [`DATA_W-1:0] sram_irdata = uut.int_mem0.int_sram.i_rdata;

    
    always @(posedge sram_dwstrb)
    if(sram_daddr == 13'h090d)  begin
    #10 $display("Found CPU memory condition at %f : %x : %x", $time, sram_daddr, sram_dwdata );
    //$finish;
      end
    */

	//Manually added testbench uart core. RS232 pins attached to the same pins
	//of the Tester UART0 instance to communicate with it
   iob_uart uart_tb
     (
      .clk       (clk),
      .rst       (rst),
      
      .valid     (uart_valid),
      .address   (uart_addr),
      .wdata     (uart_wdata),
      .wstrb     (uart_wstrb),
      .rdata     (uart_rdata),
      .ready     (uart_ready),
      
      .txd       (UART0_rxd),
      .rxd       (UART0_txd),
      .rts       (UART0_cts),
      .cts       (UART0_rts)
      );
   
	//Ethernet
`ifdef TESTER_USE_ETHERNET
   //ethernet clock: 4x slower than system clock
   reg [1:0] eth_cnt = 2'b0;
   reg eth_clk;

   always @(posedge clk) begin
       eth_cnt <= eth_cnt + 1'b1;
       eth_clk <= eth_cnt[1];
   end

   // Ethernet Interface signals
   assign ETHERNET0_RX_CLK = eth_clk;
   assign ETHERNET0_TX_CLK = eth_clk;
   assign ETHERNET0_PLL_LOCKED = 1'b1;

//add core test module in testbench
iob_eth_tb_gen eth_tb(
      .clk      (clk),
      .reset    (rst),

      // This module acts like a loopback
      .RX_CLK(ETHERNET0_TX_CLK),
      .RX_DATA(ETHERNET0_TX_DATA),
      .RX_DV(ETHERNET0_TX_EN),

      // The wires are thus reversed
      .TX_CLK(ETHERNET0_RX_CLK),
      .TX_DATA(ETHERNET0_RX_DATA),
      .TX_EN(ETHERNET0_RX_DV)
);
`endif

endmodule
