`timescale 1ns / 1ps
`include "tester.vh"
`include "iob_lib.vh"

module top_system
  (
   //user clock
   input         clk, 
   input         resetn,
  
   //uart
   output        uart_txd,
   input         uart_rxd,

`ifdef TESTER_USE_DDR
   output [13:0] ddr3b_a, //SSTL15  //Address
   output [2:0]  ddr3b_ba, //SSTL15  //Bank Address
   output        ddr3b_rasn, //SSTL15  //Row Address Strobe
   output        ddr3b_casn, //SSTL15  //Column Address Strobe
   output        ddr3b_wen, //SSTL15  //Write Enable
   output [1:0]  ddr3b_dm, //SSTL15  //Data Write Mask
   inout [15:0]  ddr3b_dq, //SSTL15  //Data Bus
   output        ddr3b_clk_n, //SSTL15  //Diff Clock - Neg
   output        ddr3b_clk_p, //SSTL15  //Diff Clock - Pos
   output        ddr3b_cke, //SSTL15  //Clock Enable
   output        ddr3b_csn, //SSTL15  //Chip Select
   inout [1:0]   ddr3b_dqs_n, //SSTL15  //Diff Data Strobe - Neg
   inout [1:0]   ddr3b_dqs_p, //SSTL15  //Diff Data Strobe - Pos
   output        ddr3b_odt, //SSTL15  //On-Die Termination Enable
   output        ddr3b_resetn, //SSTL15  //Reset
   input         rzqin,
`endif

`ifdef TESTER_USE_ETHERNET
        output ENET_RESETN,
        input  ENET_RX_CLK,
        output ENET_GTX_CLK,
        input  ENET_RX_D0,
        input  ENET_RX_D1,
        input  ENET_RX_D2,
        input  ENET_RX_D3,
        input  ENET_RX_DV,
        output ENET_TX_D0,
        output ENET_TX_D1,
        output ENET_TX_D2,
        output ENET_TX_D3,
        output ENET_TX_EN,
`endif                  
   output        trap
   );
   
   //axi4 parameters
   localparam AXI_ID_W = 1;
   localparam AXI_ADDR_W=`TESTER_DDR_ADDR_W;
   localparam AXI_DATA_W=`TESTER_DDR_DATA_W;
   
   //-----------------------------------------------------------------
   // Clocking / Reset
   //-----------------------------------------------------------------

   wire 	 rst;

   wire [1:0]                   trap_signals;
   assign trap = trap_signals[0] || trap_signals[1];
    // 
    // Logic to contatenate data pins and ethernet clock
    //
`ifdef TESTER_USE_ETHERNET
    //buffered eth clock
    wire            ETH_CLK;

    //PLL
    wire            eth_locked;

    //MII
    wire [3:0]      TX_DATA;   
    wire [3:0]      RX_DATA;

    assign {ENET_TX_D3, ENET_TX_D2, ENET_TX_D1, ENET_TX_D0} = TX_DATA;
    assign RX_DATA = {ENET_RX_D3, ENET_RX_D2, ENET_RX_D1, ENET_RX_D0};

    //eth clock
   clk_buf txclk_buf (
	              .inclk  (ENET_RX_CLK),
	              .outclk (ETH_CLK)
	              );
   
   
/*   
   pll25_multi_out pll25_inst (
		               .refclk   (TX_CLK_int),
		               .rst      (~ENET_RESETN),
		               .outclk_0 (), //0 degrees
		               .outclk_1 (), //45 degrees
		               .outclk_2 (TX_CLK), //90 degrees
		               .outclk_3 (), //135 degrees
		               .outclk_4 (), //180 degrees
		               .outclk_5 (), //225 degrees: mutes sys
		               .outclk_6 (), //270 degrees
		               .outclk_7 (), //315 degrees
		               .locked   (eth_pll_locked)
	                       );
  
*/

    assign eth_locked = 1'b1; 


   ddio_out_clkbuf ddio_out_clkbuf_inst (
                                         .aclr ( ~ENET_RESETN ),
                                         .datain_h ( 1'b0 ),
                                         .datain_l ( 1'b1 ),
                                         .outclock ( ETH_CLK ),
                                         .dataout ( ENET_GTX_CLK )
                                         );

`endif                  


`ifdef TESTER_USE_DDR
   //axi wires between system backend and axi bridge
	`IOB_WIRE(m_axi_awid, 3*AXI_ID_W) //Address write channel ID
	`IOB_WIRE(m_axi_awaddr, 3*AXI_ADDR_W) //Address write channel address
	`IOB_WIRE(m_axi_awlen, 3*8) //Address write channel burst length
	`IOB_WIRE(m_axi_awsize, 3*3) //Address write channel burst size. This signal indicates the size of each transfer in the burst
	`IOB_WIRE(m_axi_awburst, 3*2) //Address write channel burst type
	`IOB_WIRE(m_axi_awlock, 3*2) //Address write channel lock type
	`IOB_WIRE(m_axi_awcache, 3*4) //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
	`IOB_WIRE(m_axi_awprot, 3*3) //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
	`IOB_WIRE(m_axi_awqos, 3*4) //Address write channel quality of service
	`IOB_WIRE(m_axi_awvalid, 3*1) //Address write channel valid
	`IOB_WIRE(m_axi_awready, 3*1) //Address write channel ready
	`IOB_WIRE(m_axi_wdata, 3*AXI_DATA_W) //Write channel data
	`IOB_WIRE(m_axi_wstrb, 3*(AXI_DATA_W/8)) //Write channel write strobe
	`IOB_WIRE(m_axi_wlast, 3*1) //Write channel last word flag
	`IOB_WIRE(m_axi_wvalid, 3*1) //Write channel valid
	`IOB_WIRE(m_axi_wready, 3*1) //Write channel ready
	`IOB_WIRE(m_axi_bid, 3*AXI_ID_W) //Write response channel ID
	`IOB_WIRE(m_axi_bresp, 3*2) //Write response channel response
	`IOB_WIRE(m_axi_bvalid, 3*1) //Write response channel valid
	`IOB_WIRE(m_axi_bready, 3*1) //Write response channel ready
	`IOB_WIRE(m_axi_arid, 3*AXI_ID_W) //Address read channel ID
	`IOB_WIRE(m_axi_araddr, 3*AXI_ADDR_W) //Address read channel address
	`IOB_WIRE(m_axi_arlen, 3*8) //Address read channel burst length
	`IOB_WIRE(m_axi_arsize, 3*3) //Address read channel burst size. This signal indicates the size of each transfer in the burst
	`IOB_WIRE(m_axi_arburst, 3*2) //Address read channel burst type
	`IOB_WIRE(m_axi_arlock, 3*2) //Address read channel lock type
	`IOB_WIRE(m_axi_arcache, 3*4) //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
	`IOB_WIRE(m_axi_arprot, 3*3) //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
	`IOB_WIRE(m_axi_arqos, 3*4) //Address read channel quality of service
	`IOB_WIRE(m_axi_arvalid, 3*1) //Address read channel valid
	`IOB_WIRE(m_axi_arready, 3*1) //Address read channel ready
	`IOB_WIRE(m_axi_rid, 3*AXI_ID_W) //Read channel ID
	`IOB_WIRE(m_axi_rdata, 3*AXI_DATA_W) //Read channel data
	`IOB_WIRE(m_axi_rresp, 3*2) //Read channel response
	`IOB_WIRE(m_axi_rlast, 3*1) //Read channel last word
	`IOB_WIRE(m_axi_rvalid, 3*1) //Read channel valid
	`IOB_WIRE(m_axi_rready, 3*1) //Read channel ready
`endif


   //
   // TESTER (includes UUT)
   //

   tester
     #(
       .AXI_ID_W(AXI_ID_W),
       .AXI_ADDR_W(AXI_ADDR_W),
       .AXI_DATA_W(AXI_DATA_W)
       )
   tester 
     (
      .clk (clk),
      .rst (rst),
      .trap (trap_signals),
`ifdef TESTER_USE_ETHERNET
            //ETHERNET
            //PHY
            .ETHERNET0_ETH_PHY_RESETN(ENET_RESETN),
            //PLL
            .ETHERNET0_PLL_LOCKED(eth_locked),
            //MII
            .ETHERNET0_RX_CLK(ETH_CLK),
            .ETHERNET0_RX_DATA(RX_DATA),
            .ETHERNET0_RX_DV(ENET_RX_DV),
            .ETHERNET0_TX_CLK(ETH_CLK),
            .ETHERNET0_TX_DATA(TX_DATA),
            .ETHERNET0_TX_EN(ENET_TX_EN),
`endif
`ifdef TESTER_USE_DDR
      //axi system backend interface
 `include "m_axi_portmap.vh"	
`endif

      //UART
      .UART0_txd (uart_txd),
      .UART0_rxd (uart_rxd),
      .UART0_rts (),
      .UART0_cts (1'b1)
      );

`ifdef TESTER_USE_DDR
   //user reset
   wire          locked;
   wire          init_done;

   //determine system reset
   wire          rst_int = ~resetn | ~locked | ~init_done;
//   wire          rst_int = ~resetn | ~locked;
   
   iob_reset_sync rst_sync (clk, rst_int, rst);

   alt_ddr3 ddr3_ctrl 
     (
      .clk_clk (clk),
      .reset_reset_n (resetn),
      .oct_rzqin (rzqin),

      .memory_mem_a (ddr3b_a),
      .memory_mem_ba (ddr3b_ba),
      .memory_mem_ck (ddr3b_clk_p),
      .memory_mem_ck_n (ddr3b_clk_n),
      .memory_mem_cke (ddr3b_cke),
      .memory_mem_cs_n (ddr3b_csn),
      .memory_mem_dm (ddr3b_dm),
      .memory_mem_ras_n (ddr3b_rasn),
      .memory_mem_cas_n (ddr3b_casn),
      .memory_mem_we_n (ddr3b_wen),
      .memory_mem_reset_n (ddr3b_resetn),
      .memory_mem_dq (ddr3b_dq),
      .memory_mem_dqs (ddr3b_dqs_p),
      .memory_mem_dqs_n (ddr3b_dqs_n),
      .memory_mem_odt (ddr3b_odt),
      
      .axi_bridge_0_s0_awid (m_axi_awid[3*AXI_ID_W-1:2*AXI_ID_W]),
      .axi_bridge_0_s0_awaddr (m_axi_awaddr[3*AXI_ADDR_W-1:2*AXI_ADDR_W]),
      .axi_bridge_0_s0_awlen (m_axi_awlen[3*(7+1)-1:2*(7+1)]),
      .axi_bridge_0_s0_awsize (m_axi_awsize[3*(2+1)-1:2*(2+1)]),
      .axi_bridge_0_s0_awburst (m_axi_awburst[3*(1+1)-1:2*(1+1)]),
      .axi_bridge_0_s0_awlock (m_axi_awlock[4]),
      .axi_bridge_0_s0_awcache (m_axi_awcache[3*(3+1)-1:2*(3+1)]),
      .axi_bridge_0_s0_awprot (m_axi_awprot[3*(2+1)-1:2*(2+1)]),
      .axi_bridge_0_s0_awvalid (m_axi_awvalid[2]),
      .axi_bridge_0_s0_awready (m_axi_awready[2]),
      .axi_bridge_0_s0_wdata (m_axi_wdata[3*(31+1)-1:2*(31+1)]),
      .axi_bridge_0_s0_wstrb (m_axi_wstrb[3*(3+1)-1:2*(3+1)]),
      .axi_bridge_0_s0_wlast (m_axi_wlast[2]),
      .axi_bridge_0_s0_wvalid (m_axi_wvalid[2]),
      .axi_bridge_0_s0_wready (m_axi_wready[2]),
      .axi_bridge_0_s0_bid (m_axi_bid[3*AXI_ID_W-1:2*AXI_ID_W]),
      .axi_bridge_0_s0_bresp (m_axi_bresp[3*(1+1)-1:2*(1+1)]),
      .axi_bridge_0_s0_bvalid (m_axi_bvalid[2]),
      .axi_bridge_0_s0_bready (m_axi_bready[2]),
      .axi_bridge_0_s0_arid (m_axi_arid[3*AXI_ID_W-1:2*AXI_ID_W]),
      .axi_bridge_0_s0_araddr (m_axi_araddr[3*AXI_ADDR_W-1:2*AXI_ADDR_W]),
      .axi_bridge_0_s0_arlen (m_axi_arlen[3*(7+1)-1:2*(7+1)]),
      .axi_bridge_0_s0_arsize (m_axi_arsize[3*(2+1)-1:2*(2+1)]),
      .axi_bridge_0_s0_arburst (m_axi_arburst[3*(1+1)-1:2*(1+1)]),
      .axi_bridge_0_s0_arlock (m_axi_arlock[4]),
      .axi_bridge_0_s0_arcache (m_axi_arcache[3*(3+1)-1:2*(3+1)]),
      .axi_bridge_0_s0_arprot (m_axi_arprot[3*(2+1)-1:2*(2+1)]),
      .axi_bridge_0_s0_arvalid (m_axi_arvalid[2]),
      .axi_bridge_0_s0_arready (m_axi_arready[2]),
      .axi_bridge_0_s0_rid (m_axi_rid[3*AXI_ID_W-1:2*AXI_ID_W]),
      .axi_bridge_0_s0_rdata (m_axi_rdata[3*(31+1)-1:2*(31+1)]),
      .axi_bridge_0_s0_rresp (m_axi_rresp[3*(1+1)-1:2*(1+1)]),
      .axi_bridge_0_s0_rlast (m_axi_rlast[2]),
      .axi_bridge_0_s0_rvalid (m_axi_rvalid[2]),
      .axi_bridge_0_s0_rready (m_axi_rready[2]),

      .mem_if_ddr3_emif_0_pll_sharing_pll_mem_clk (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_write_clk (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_locked (locked),
      .mem_if_ddr3_emif_0_pll_sharing_pll_write_clk_pre_phy_clk (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_addr_cmd_clk (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_avl_clk (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_config_clk (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_mem_phy_clk (),
      .mem_if_ddr3_emif_0_pll_sharing_afi_phy_clk (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_avl_phy_clk (),
      .mem_if_ddr3_emif_0_status_local_init_done (init_done),
      .mem_if_ddr3_emif_0_status_local_cal_success (),
      .mem_if_ddr3_emif_0_status_local_cal_fail ()
      );

`else
   iob_reset_sync rst_sync (clk, (~resetn), rst);   
`endif

`ifdef TESTER_USE_DDR
	//instantiate axi interconnect
	//This connects Tester+SUT to the same memory
	axi_interconnect
		#(
		.ID_WIDTH(AXI_ID_W),
		.DATA_WIDTH (AXI_DATA_W),
		.ADDR_WIDTH (AXI_ADDR_W),
		.M_ADDR_WIDTH (AXI_ADDR_W),
		.S_COUNT (2),
		.M_COUNT (1)
		)
		system_axi_interconnect(
			.clk            (clk),
			.rst            (rst),

			.s_axi_awid     (m_axi_awid[2*AXI_ID_W-1:0]),
			.s_axi_awaddr   (m_axi_awaddr[2*AXI_ADDR_W-1:0]),
			.s_axi_awlen    (m_axi_awlen[2*(7+1)-1:0]),
			.s_axi_awsize   (m_axi_awsize[2*(2+1)-1:0]),
			.s_axi_awburst  (m_axi_awburst[2*(1+1)-1:0]),
			.s_axi_awlock   ({m_axi_awlock[2],m_axi_awlock[0]}),
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
			.s_axi_bid      (m_axi_bid[2*AXI_ID_W-1:0]),
			.s_axi_bresp    (m_axi_bresp[2*(1+1)-1:0]),
			.s_axi_bvalid   (m_axi_bvalid[1:0]),

			//address read
			.s_axi_arid     (m_axi_arid[2*AXI_ID_W-1:0]),
			.s_axi_araddr   (m_axi_araddr[2*AXI_ADDR_W-1:0]),
			.s_axi_arlen    (m_axi_arlen[2*(7+1)-1:0]), 
			.s_axi_arsize   (m_axi_arsize[2*(2+1)-1:0]),    
			.s_axi_arburst  (m_axi_arburst[2*(1+1)-1:0]),
			.s_axi_arlock   ({m_axi_arlock[2],m_axi_arlock[0]}),
			.s_axi_arcache  (m_axi_arcache[2*(3+1)-1:0]),
			.s_axi_arprot   (m_axi_arprot[2*(2+1)-1:0]),
			.s_axi_arqos    (m_axi_arqos[2*(3+1)-1:0]),
			.s_axi_arvalid  (m_axi_arvalid[1:0]),
			.s_axi_arready  (m_axi_arready[1:0]),

			//read   
			.s_axi_rready   (m_axi_rready[1:0]),
			.s_axi_rid      (m_axi_rid[2*AXI_ID_W-1:0]),
			.s_axi_rdata    (m_axi_rdata[2*(31+1)-1:0]),
			.s_axi_rresp    (m_axi_rresp[2*(1+1)-1:0]),
			.s_axi_rlast    (m_axi_rlast[1:0]),
			.s_axi_rvalid   (m_axi_rvalid[1:0]),

			.m_axi_awid     (m_axi_awid[3*AXI_ID_W-1:2*AXI_ID_W]),
			.m_axi_awaddr   (m_axi_awaddr[3*AXI_ADDR_W-1:2*AXI_ADDR_W]),
			.m_axi_awlen    (m_axi_awlen[3*(7+1)-1:2*(7+1)]),
			.m_axi_awsize   (m_axi_awsize[3*(2+1)-1:2*(2+1)]),
			.m_axi_awburst  (m_axi_awburst[3*(1+1)-1:2*(1+1)]),
			.m_axi_awlock   (m_axi_awlock[4]),
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
			.m_axi_bid      (m_axi_bid[3*AXI_ID_W-1:2*AXI_ID_W]),
			.m_axi_bresp    (m_axi_bresp[3*(1+1)-1:2*(1+1)]),
			.m_axi_bvalid   (m_axi_bvalid[2]),

			//address read
			.m_axi_arid     (m_axi_arid[3*AXI_ID_W-1:2*AXI_ID_W]),
			.m_axi_araddr   (m_axi_araddr[3*AXI_ADDR_W-1:2*AXI_ADDR_W]),
			.m_axi_arlen    (m_axi_arlen[3*(7+1)-1:2*(7+1)]), 
			.m_axi_arsize   (m_axi_arsize[3*(2+1)-1:2*(2+1)]),    
			.m_axi_arburst  (m_axi_arburst[3*(1+1)-1:2*(1+1)]),
			.m_axi_arlock   (m_axi_arlock[4]),
			.m_axi_arcache  (m_axi_arcache[3*(3+1)-1:2*(3+1)]),
			.m_axi_arprot   (m_axi_arprot[3*(2+1)-1:2*(2+1)]),
			.m_axi_arqos    (m_axi_arqos[3*(3+1)-1:2*(3+1)]),
			.m_axi_arvalid  (m_axi_arvalid[2]),
			.m_axi_arready  (m_axi_arready[2]),

			//read   
			.m_axi_rready   (m_axi_rready[2]),
			.m_axi_rid      (m_axi_rid[3*AXI_ID_W-1:2*AXI_ID_W]),
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
`endif

endmodule
