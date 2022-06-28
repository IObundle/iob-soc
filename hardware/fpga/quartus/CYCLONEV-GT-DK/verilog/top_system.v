`timescale 1ns / 1ps
`include "system.vh"
`include "iob_lib.vh"

module top_system
  (
   input         clk, 
   input         resetn,
  
   //uart
   output        uart_txd,
   input         uart_rxd,

`ifdef USE_DDR
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
`endif
   output        trap
   );
   
   //-----------------------------------------------------------------
   // Clocking / Reset
   //-----------------------------------------------------------------

   //pll input reset
   wire 	 rst;
   iob_reset_sync rst_sync (clk, (~resetn), rst);

   
`ifdef USE_DDR
   
   wire 	 axi4_awready_w;
   wire 	 axi4_arready_w;
   wire [  7:0]  axi4_arlen_w;
   wire 	 axi4_wvalid_w;
   wire [`DDR_ADDR_W-1:0] axi4_araddr_w;
   wire [  1:0]           axi4_bresp_w;
   wire [ 31:0]           axi4_wdata_w;
   wire 		  axi4_rlast_w;
   wire 		  axi4_awvalid_w;
   wire 		  axi4_rid_w;
   wire [  1:0]           axi4_rresp_w;
   wire 		  axi4_bvalid_w;
   wire [  3:0]           axi4_wstrb_w;
   wire [  1:0]           axi4_arburst_w;
   wire 		  axi4_arvalid_w;
   wire 		  axi4_awid_w;
   wire 		  axi4_bid_w;
   wire 		  axi4_arid_w;
   wire 		  axi4_rready_w;
   wire [  7:0]           axi4_awlen_w;
   wire 		  axi4_wlast_w;
   wire [ 31:0]           axi4_rdata_w;
   wire 		  axi4_bready_w;
   wire [`DDR_ADDR_W-1:0] axi4_awaddr_w;
   wire 		  axi4_wready_w;
   wire [  1:0]           axi4_awburst_w;
   wire 		  axi4_rvalid_w;

   wire [2:0]             axi4_awsize_w;
   wire 		  axi4_awlock_w;
   wire [3:0]             axi4_awcache_w;
   wire [2:0]             axi4_awprot_w;
   wire [2:0]             axi4_arsize_w;
   wire [3:0]             axi4_awqos_w;
   wire 		  axi4_arlock_w;
   wire [3:0]             axi4_arcache_w;
   wire [2:0]             axi4_arprot_w;
   wire [3:0]             axi4_arqos_w;


   alt_ddr3 ddr30 
     (
      .memory_mem_a                                             (ddr3b_a),
      .memory_mem_ba                                            (ddr3b_ba),
      .memory_mem_ck                                            (ddr3b_ck),
      .memory_mem_ck_n                                          (ddr3b_ck_n),
      .memory_mem_cke                                           (ddr3b_cke),
      .memory_mem_cs_n                                          (ddr3b_cs_n),
      .memory_mem_dm                                            (ddr3b_dm),
      .memory_mem_ras_n                                         (ddr3b_ras_n),
      .memory_mem_cas_n                                         (ddr3b_cas_n),
      .memory_mem_we_n                                          (ddr3b_we_n),
      .memory_mem_reset_n                                       (ddr3b_reset_n),
      .memory_mem_dq                                            (ddr3b_dq),
      .memory_mem_dqs                                           (ddr3b_dqs),
      .memory_mem_dqs_n                                         (ddr3b_dqs_n),
      .memory_mem_odt                                           (ddr3b_odt),
      .oct_rzqin                                                (),
      .clk_clk                                                  (clk),
      .reset_reset_n                                            (~rst),
      .axi2axi_0_altera_axi_slave_awid                          (axi4_awid),
      .axi2axi_0_altera_axi_slave_awaddr                        (axi4_awaddr),
      .axi2axi_0_altera_axi_slave_awlen                         (axi4_awlen),
      .axi2axi_0_altera_axi_slave_awsize                        (axi4_awsize),
      .axi2axi_0_altera_axi_slave_awburst                       (axi4_awburst),
      .axi2axi_0_altera_axi_slave_awlock                        (axi4_awlock),
      .axi2axi_0_altera_axi_slave_awcache                       (axi4_awcache),
      .axi2axi_0_altera_axi_slave_awprot                        (axi4_awprot),
      .axi2axi_0_altera_axi_slave_awvalid                       (axi4_awvalid),
      .axi2axi_0_altera_axi_slave_awready                       (axi4_awready),
      .axi2axi_0_altera_axi_slave_wid                           (axi4_wid),
      .axi2axi_0_altera_axi_slave_wdata                         (axi4_wdata),
      .axi2axi_0_altera_axi_slave_wstrb                         (axi4_wstrb),
      .axi2axi_0_altera_axi_slave_wlast                         (axi4_wlast),
      .axi2axi_0_altera_axi_slave_wvalid                        (axi4_wvalid),
      .axi2axi_0_altera_axi_slave_wready                        (axi4_wready),
      .axi2axi_0_altera_axi_slave_bid                           (axi4_bid),
      .axi2axi_0_altera_axi_slave_bresp                         (axi4_bresp),
      .axi2axi_0_altera_axi_slave_bvalid                        (axi4_bvalid),
      .axi2axi_0_altera_axi_slave_bready                        (axi4_bready),
      .axi2axi_0_altera_axi_slave_arid                          (axi4_arid),
      .axi2axi_0_altera_axi_slave_araddr                        (axi4_araddr),
      .axi2axi_0_altera_axi_slave_arlen                         (axi4_arlen),
      .axi2axi_0_altera_axi_slave_arsize                        (axi4_arsize),
      .axi2axi_0_altera_axi_slave_arburst                       (axi4_arburst),
      .axi2axi_0_altera_axi_slave_arlock                        (axi4_arlock),
      .axi2axi_0_altera_axi_slave_arcache                       (axi4_arcache),
      .axi2axi_0_altera_axi_slave_arprot                        (axi4_arprot),
      .axi2axi_0_altera_axi_slave_arvalid                       (axi4_arvalid),
      .axi2axi_0_altera_axi_slave_arready                       (axi4_arready),
      .axi2axi_0_altera_axi_slave_rid                           (axi4_rid),
      .axi2axi_0_altera_axi_slave_rdata                         (axi4_rdata),
      .axi2axi_0_altera_axi_slave_rresp                         (axi4_rresp),
      .axi2axi_0_altera_axi_slave_rlast                         (axi4_rlast),
      .axi2axi_0_altera_axi_slave_rvalid                        (axi4_rvalid),
      .axi2axi_0_altera_axi_slave_rready                        (axi4_rready),
      .mem_if_ddr3_emif_0_afi_clk_clk                           (),
      .mem_if_ddr3_emif_0_afi_half_clk_clk                      (),
      .mem_if_ddr3_emif_0_afi_reset_reset_n                     (),
      .mem_if_ddr3_emif_0_afi_reset_export_reset_n              (),
      .mem_if_ddr3_emif_0_status_local_init_done                (),
      .mem_if_ddr3_emif_0_status_local_cal_success              (),
      .mem_if_ddr3_emif_0_status_local_cal_fail                 (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_mem_clk               (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_write_clk             (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_locked                (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_write_clk_pre_phy_clk (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_addr_cmd_clk          (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_avl_clk               (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_config_clk            (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_mem_phy_clk           (),
      .mem_if_ddr3_emif_0_pll_sharing_afi_phy_clk               (),
      .mem_if_ddr3_emif_0_pll_sharing_pll_avl_phy_clk           ()
      );


`endif

   //UART
   .uart_txd      (uart_txd),
  .uart_rxd      (uart_rxd),
  .uart_rts      (),
  .uart_cts      (1'b1)
    );

endmodule
