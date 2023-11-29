`timescale 1ns / 1ps
`include "bsp.vh"
`include "iob_soc_conf.vh"

module iob_soc_fpga_wrapper (
   //user clock
   input clk,
   input resetn,

   //uart
   output txd_o,
   input  rxd_i,

`ifdef IOB_SOC_USE_EXTMEM
   output [13:0] ddr3b_a,       //SSTL15  //Address
   output [ 2:0] ddr3b_ba,      //SSTL15  //Bank Address
   output        ddr3b_rasn,    //SSTL15  //Row Address Strobe
   output        ddr3b_casn,    //SSTL15  //Column Address Strobe
   output        ddr3b_wen,     //SSTL15  //Write Enable
   output [ 1:0] ddr3b_dm,      //SSTL15  //Data Write Mask
   inout  [15:0] ddr3b_dq,      //SSTL15  //Data Bus
   output        ddr3b_clk_n,   //SSTL15  //Diff Clock - Neg
   output        ddr3b_clk_p,   //SSTL15  //Diff Clock - Pos
   output        ddr3b_cke,     //SSTL15  //Clock Enable
   output        ddr3b_csn,     //SSTL15  //Chip Select
   inout  [ 1:0] ddr3b_dqs_n,   //SSTL15  //Diff Data Strobe - Neg
   inout  [ 1:0] ddr3b_dqs_p,   //SSTL15  //Diff Data Strobe - Pos
   output        ddr3b_odt,     //SSTL15  //On-Die Termination Enable
   output        ddr3b_resetn,  //SSTL15  //Reset
   input         rzqin,
`endif

`ifdef IOB_SOC_USE_ETHERNET
   output ENET_RESETN,
   input  ENET_RX_CLK,
   output ENET_GTX_CLK,
   input  ENET_RX_D0,
   input  ENET_RX_D1,
   input  ENET_RX_D2,
   input  ENET_RX_D3,
   input  ENET_RX_DV,
   //input  ENET_RX_ERR,
   output ENET_TX_D0,
   output ENET_TX_D1,
   output ENET_TX_D2,
   output ENET_TX_D3,
   output ENET_TX_EN,
   //output ENET_TX_ERR,
`endif
   output trap
);

   //axi4 parameters
   localparam AXI_ID_W = 1;
   localparam AXI_LEN_W = 4;
   localparam AXI_ADDR_W = `DDR_ADDR_W;
   localparam AXI_DATA_W = `DDR_DATA_W;

   `include "iob_soc_wrapper_pwires.vs"

   //-----------------------------------------------------------------
   // Clocking / Reset
   //-----------------------------------------------------------------

   wire arst;

   // 
   // Logic to contatenate data pins and ethernet clock
   //
`ifdef IOB_SOC_USE_ETHERNET
   //buffered eth clock
   wire       ETH_Clk;

   //eth clock
   clk_buf_altclkctrl_0 txclk_buf (
      .inclk (ENET_RX_CLK),
      .outclk(ETH_Clk)
   );


   ddio_out_clkbuf ddio_out_clkbuf_inst (
      .aclr    (~ENET_RESETN),
      .datain_h(1'b0),
      .datain_l(1'b1),
      .outclock(ETH_Clk),
      .dataout (ENET_GTX_CLK)
   );

   //MII
   assign ETH0_MRxClk = ETH_Clk;
   assign ETH0_MRxD = {ENET_RX_D3, ENET_RX_D2, ENET_RX_D1, ENET_RX_D0};
   assign ETH0_MRxDv = ENET_RX_DV;
   //assign ETH0_MRxErr = ENET_RX_ERR;
   assign ETH0_MRxErr = 1'b0;

   assign ETH0_MTxClk = ETH_Clk;
   assign {ENET_TX_D3, ENET_TX_D2, ENET_TX_D1, ENET_TX_D0} = ETH0_MTxD;
   assign ENET_TX_EN = ETH0_MTxEn;
   //assign ENET_TX_ERR = ETH0_MTxErr;

   assign ETH0_MColl = 1'b0;
   assign ETH0_MCrS = 1'b0;

   //
   //  PHY RESET
   //
   // TODO: Reset PHY using `MDIO` commands, instead of a dedicated reset
   // signal.
   reg [20-1:0] phy_rst_cnt;
   reg ETH_PHY_RESETN;

   localparam PHY_RST_CNT = 20'hFFFFF;

   always @(posedge clk, posedge arst)
      if (arst) begin
         phy_rst_cnt    <= 0;
         ETH_PHY_RESETN <= 0;
      end else if (phy_rst_cnt != PHY_RST_CNT) phy_rst_cnt <= phy_rst_cnt + 1'b1;
      else ETH_PHY_RESETN <= 1;

   assign ENET_RESETN = ETH_PHY_RESETN;
`endif

   //
   // IOb-SoC (may include UUT)
   //
   iob_soc #(
      .AXI_ID_W  (AXI_ID_W),
      .AXI_LEN_W (AXI_LEN_W),
      .AXI_ADDR_W(AXI_ADDR_W),
      .AXI_DATA_W(AXI_DATA_W)
   ) iob_soc (
      `include "iob_soc_pportmaps.vs"
      .clk_i (clk),
      .cke_i (1'b1),
      .arst_i(arst),
      .trap_o(trap)
   );

   //
   // UART
   //
   assign txd_o = uart_txd_o;
   assign uart_rxd_i = rxd_i;
   assign uart_cts_i = 1'b1;
   // uart_rts_i unconnected

   
`ifdef IOB_SOC_USE_EXTMEM
   //user reset
   wire                                           locked;
   wire                                           init_done;

   //determine system reset
   wire rst_int = ~resetn | ~locked | ~init_done;
   //   wire          rst_int = ~resetn | ~locked;

   iob_reset_sync rst_sync (
      .clk_i (clk),
      .arst_i(rst_int),
      .arst_o(arst)
   );

   alt_ddr3 ddr3_ctrl (
      .clk_clk      (clk),
      .reset_reset_n(resetn),
      .oct_rzqin    (rzqin),

      .memory_mem_a      (ddr3b_a),
      .memory_mem_ba     (ddr3b_ba),
      .memory_mem_ck     (ddr3b_clk_p),
      .memory_mem_ck_n   (ddr3b_clk_n),
      .memory_mem_cke    (ddr3b_cke),
      .memory_mem_cs_n   (ddr3b_csn),
      .memory_mem_dm     (ddr3b_dm),
      .memory_mem_ras_n  (ddr3b_rasn),
      .memory_mem_cas_n  (ddr3b_casn),
      .memory_mem_we_n   (ddr3b_wen),
      .memory_mem_reset_n(ddr3b_resetn),
      .memory_mem_dq     (ddr3b_dq),
      .memory_mem_dqs    (ddr3b_dqs_p),
      .memory_mem_dqs_n  (ddr3b_dqs_n),
      .memory_mem_odt    (ddr3b_odt),

      .axi_bridge_0_s0_awid   (memory_axi_awid),
      .axi_bridge_0_s0_awaddr (memory_axi_awaddr),
      .axi_bridge_0_s0_awlen  (memory_axi_awlen),
      .axi_bridge_0_s0_awsize (memory_axi_awsize),
      .axi_bridge_0_s0_awburst(memory_axi_awburst),
      .axi_bridge_0_s0_awlock (memory_axi_awlock),
      .axi_bridge_0_s0_awcache(memory_axi_awcache),
      .axi_bridge_0_s0_awprot (memory_axi_awprot),
      .axi_bridge_0_s0_awvalid(memory_axi_awvalid),
      .axi_bridge_0_s0_awready(memory_axi_awready),
      .axi_bridge_0_s0_wdata  (memory_axi_wdata),
      .axi_bridge_0_s0_wstrb  (memory_axi_wstrb),
      .axi_bridge_0_s0_wlast  (memory_axi_wlast),
      .axi_bridge_0_s0_wvalid (memory_axi_wvalid),
      .axi_bridge_0_s0_wready (memory_axi_wready),
      .axi_bridge_0_s0_bid    (memory_axi_bid),
      .axi_bridge_0_s0_bresp  (memory_axi_bresp),
      .axi_bridge_0_s0_bvalid (memory_axi_bvalid),
      .axi_bridge_0_s0_bready (memory_axi_bready),
      .axi_bridge_0_s0_arid   (memory_axi_arid),
      .axi_bridge_0_s0_araddr (memory_axi_araddr),
      .axi_bridge_0_s0_arlen  (memory_axi_arlen),
      .axi_bridge_0_s0_arsize (memory_axi_arsize),
      .axi_bridge_0_s0_arburst(memory_axi_arburst),
      .axi_bridge_0_s0_arlock (memory_axi_arlock),
      .axi_bridge_0_s0_arcache(memory_axi_arcache),
      .axi_bridge_0_s0_arprot (memory_axi_arprot),
      .axi_bridge_0_s0_arvalid(memory_axi_arvalid),
      .axi_bridge_0_s0_arready(memory_axi_arready),
      .axi_bridge_0_s0_rid    (memory_axi_rid),
      .axi_bridge_0_s0_rdata  (memory_axi_rdata),
      .axi_bridge_0_s0_rresp  (memory_axi_rresp),
      .axi_bridge_0_s0_rlast  (memory_axi_rlast),
      .axi_bridge_0_s0_rvalid (memory_axi_rvalid),
      .axi_bridge_0_s0_rready (memory_axi_rready),

      .mem_if_ddr3_emif_0_pll_sharing_pll_mem_clk              (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_write_clk            (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_locked               (locked),
      .mem_if_ddr3_emif_0_pll_sharing_pll_write_clk_pre_phy_clk(),
      .mem_if_ddr3_emif_0_pll_sharing_pll_addr_cmd_clk         (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_avl_clk              (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_config_clk           (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_mem_phy_clk          (),
      .mem_if_ddr3_emif_0_pll_sharing_afi_phy_clk              (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_avl_phy_clk          (),
      .mem_if_ddr3_emif_0_status_local_init_done               (init_done),
      .mem_if_ddr3_emif_0_status_local_cal_success             (),
      .mem_if_ddr3_emif_0_status_local_cal_fail                ()
   );

`else
   iob_reset_sync rst_sync (
      .clk_i (clk),
      .arst_i(~resetn),
      .arst_o(arst)
   );
`endif

   `include "iob_soc_interconnect.vs"

endmodule
