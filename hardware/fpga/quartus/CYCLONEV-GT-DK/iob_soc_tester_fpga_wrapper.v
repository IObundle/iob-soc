`timescale 1ns / 1ps
`include "bsp.vh"
`include "iob_soc_tester_conf.vh"

module iob_soc_tester_fpga_wrapper
  (
   //user clock
   input         clk, 
   input         resetn,
  
   //uart
   output        uart_txd,
   input         uart_rxd,

`ifdef IOB_SOC_TESTER_USE_EXTMEM
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

`ifdef IOB_SOC_TESTER_USE_ETHERNET
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
   localparam AXI_LEN_W = 4;
   localparam AXI_ADDR_W=`DDR_ADDR_W;
   localparam AXI_DATA_W=`DDR_DATA_W;
   
   //-----------------------------------------------------------------
   // Clocking / Reset
   //-----------------------------------------------------------------

   wire 	 rst;

   wire [1:0]                   trap_signals;
   assign trap = trap_signals[0] || trap_signals[1];
    // 
    // Logic to contatenate data pins and ethernet clock
    //
`ifdef IOB_SOC_TESTER_USE_ETHERNET
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
   clk_buf_altclkctrl_0 txclk_buf (
	              .inclk  (ENET_RX_CLK),
	              .outclk (ETH_CLK)
	              );
   

    assign eth_locked = 1'b1; 


   ddio_out_clkbuf ddio_out_clkbuf_inst (
                                         .aclr ( ~ENET_RESETN ),
                                         .datain_h ( 1'b0 ),
                                         .datain_l ( 1'b1 ),
                                         .outclock ( ETH_CLK ),
                                         .dataout ( ENET_GTX_CLK )
                                         );

`endif                  


`ifdef IOB_SOC_TESTER_USE_EXTMEM
   `include "iob_bus_3_axi_wire.vh"
`endif

   //
   // TESTER (includes UUT)
   //
   iob_soc_tester #(
       .AXI_ID_W(AXI_ID_W),
       .AXI_LEN_W(AXI_LEN_W),
       .AXI_ADDR_W(AXI_ADDR_W),
       .AXI_DATA_W(AXI_DATA_W)
       )
   tester (
      .clk_i (clk),
      .arst_i (rst),
      .trap_o (trap_signals),
`ifdef IOB_SOC_TESTER_USE_ETHERNET
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
`ifdef IOB_SOC_TESTER_USE_EXTMEM
      //axi system backend interface
      `include "iob_axi_m_portmap.vh"	
`endif

      //UART
      .portmap_0_txd (uart_txd),
      .portmap_0_rxd (uart_rxd),
      .portmap_0_rts (),
      .portmap_0_cts (1'b1)
      );

`ifdef IOB_SOC_TESTER_USE_EXTMEM
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
      
      .axi_bridge_0_s0_awid       (axi_awid    [3*AXI_ID_W-1:2*AXI_ID_W]),
      .axi_bridge_0_s0_awaddr     (axi_awaddr  [3*AXI_ADDR_W-1:2*AXI_ADDR_W]),
      .axi_bridge_0_s0_awlen      (axi_awlen   [3*(AXI_LEN_W)-1:2*(AXI_LEN_W)]),
      .axi_bridge_0_s0_awsize     (axi_awsize  [3*(2+1)-1:2*(2+1)]),
      .axi_bridge_0_s0_awburst    (axi_awburst [3*(1+1)-1:2*(1+1)]),
      .axi_bridge_0_s0_awlock     (axi_awlock  [4]),
      .axi_bridge_0_s0_awcache    (axi_awcache [3*(3+1)-1:2*(3+1)]),
      .axi_bridge_0_s0_awprot     (axi_awprot  [3*(2+1)-1:2*(2+1)]),
      .axi_bridge_0_s0_awvalid    (axi_awvalid [2]),
      .axi_bridge_0_s0_awready    (axi_awready [2]),
      .axi_bridge_0_s0_wdata      (axi_wdata   [3*(31+1)-1:2*(31+1)]),
      .axi_bridge_0_s0_wstrb      (axi_wstrb   [3*(3+1)-1:2*(3+1)]),
      .axi_bridge_0_s0_wlast      (axi_wlast   [2]),
      .axi_bridge_0_s0_wvalid     (axi_wvalid  [2]),
      .axi_bridge_0_s0_wready     (axi_wready  [2]),
      .axi_bridge_0_s0_bid        (axi_bid     [3*AXI_ID_W-1:2*AXI_ID_W]),
      .axi_bridge_0_s0_bresp      (axi_bresp   [3*(1+1)-1:2*(1+1)]),
      .axi_bridge_0_s0_bvalid     (axi_bvalid  [2]),
      .axi_bridge_0_s0_bready     (axi_bready  [2]),
      .axi_bridge_0_s0_arid       (axi_arid    [3*AXI_ID_W-1:2*AXI_ID_W]),
      .axi_bridge_0_s0_araddr     (axi_araddr  [3*AXI_ADDR_W-1:2*AXI_ADDR_W]),
      .axi_bridge_0_s0_arlen      (axi_arlen   [3*(AXI_LEN_W)-1:2*(AXI_LEN_W)]),
      .axi_bridge_0_s0_arsize     (axi_arsize  [3*(2+1)-1:2*(2+1)]),
      .axi_bridge_0_s0_arburst    (axi_arburst [3*(1+1)-1:2*(1+1)]),
      .axi_bridge_0_s0_arlock     (axi_arlock  [4]),
      .axi_bridge_0_s0_arcache    (axi_arcache [3*(3+1)-1:2*(3+1)]),
      .axi_bridge_0_s0_arprot     (axi_arprot  [3*(2+1)-1:2*(2+1)]),
      .axi_bridge_0_s0_arvalid    (axi_arvalid [2]),
      .axi_bridge_0_s0_arready    (axi_arready [2]),
      .axi_bridge_0_s0_rid        (axi_rid     [3*AXI_ID_W-1:2*AXI_ID_W]),
      .axi_bridge_0_s0_rdata      (axi_rdata   [3*(31+1)-1:2*(31+1)]),
      .axi_bridge_0_s0_rresp      (axi_rresp   [3*(1+1)-1:2*(1+1)]),
      .axi_bridge_0_s0_rlast      (axi_rlast   [2]),
      .axi_bridge_0_s0_rvalid     (axi_rvalid  [2]),
      .axi_bridge_0_s0_rready     (axi_rready  [2]),

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

`ifdef IOB_SOC_TESTER_USE_EXTMEM
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

			`include "iob_bus_0_2_s_axi_portmap.vh"

			`include "iob_bus_2_3_m_axi_portmap.vh"

			//optional signals
			.s_axi_awuser   (2'b00),
			.s_axi_wuser    (2'b00),
			.s_axi_aruser   (2'b00),
			.m_axi_buser    (1'b0),
			.m_axi_ruser    (1'b0)
		);
`endif

endmodule
