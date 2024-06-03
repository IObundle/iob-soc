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

   assign ENET_RESETN = ETH0_phy_rstn_o;

   assign ETH0_MColl = 1'b0;
   assign ETH0_MCrS = 1'b0;
`endif

   //
   // IOb-SoC (may include UUT)
   //
   iob_soc_mwrap #(
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

      `include "iob_soc_cyclonev_interconnect_s_portmap.vs"

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

endmodule
