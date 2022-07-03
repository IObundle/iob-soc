`timescale 1ns / 1ps
`include "system.vh"
`include "iob_lib.vh"

module top_system
  (
   //user clock
   input         clk, 
   input         resetn,
  
   //uart
   output        uart_txd,
   input         uart_rxd,

`ifdef USE_DDR
   input         clk_ddrpll_p,
   output [13:0] ddr3b_a, //SSTL15  //Address
   output [2:0]  ddr3b_ba, //SSTL15  //Bank Address
   output        ddr3b_rasn, //SSTL15  //Row Address Strobe
   output        ddr3b_casn, //SSTL15  //Column Address Strobe
   output        ddr3b_wen, //SSTL15  //Write Enable
   output [7:0]  ddr3b_dm, //SSTL15  //Data Write Mask
   inout [63:0]  ddr3b_dq, //SSTL15  //Data Bus
   output        ddr3b_clk_n, //SSTL15  //Diff Clock - Neg
   output        ddr3b_clk_p, //SSTL15  //Diff Clock - Pos
   output        ddr3b_cke, //SSTL15  //Clock Enable
   output        ddr3b_csn, //SSTL15  //Chip Select
   inout [7:0]   ddr3b_dqs_n, //SSTL15  //Diff Data Strobe - Neg
   inout [7:0]   ddr3b_dqs_p, //SSTL15  //Diff Data Strobe - Pos
   output        ddr3b_odt, //SSTL15  //On-Die Termination Enable
   output        ddr3b_resetn, //SSTL15  //Reset

   input         rzqin,
`endif
   output        trap
   );
   
   //-----------------------------------------------------------------
   // Clocking / Reset
   //-----------------------------------------------------------------

   wire 	 rst;
   
`ifdef USE_DDR
   parameter AXI_ID_W = 4;
   localparam AXI_ADDR_W=`DDR_ADDR_W;
   localparam AXI_DATA_W=`DATA_W;
   
   //user reset
   wire          locked;
   iob_reset_sync rst_sync (clk, (~locked), rst);

   
 `include "m_axi_wire.vh"

   alt_ddr3 ddr30 
     (
      //ddr pll clock 
      .clk_clk                                                  (clk_ddrpll_p),
      .reset_reset_n                                            (resetn),

      //user logic clock
      .clk_0_clk                                                (clk),   
      .reset_0_reset_n                                          (rst),
      

      .memory_0_mem_a                                           (ddr3b_a),
      .memory_0_mem_ba                                          (ddr3b_ba),
      .memory_0_mem_ck                                          (ddr3b_clk_p),
      .memory_0_mem_ck_n                                        (ddr3b_clk_n),
      .memory_0_mem_cke                                         (ddr3b_cke),
      .memory_0_mem_cs_n                                        (ddr3b_csn),
      .memory_0_mem_dm                                          (ddr3b_dm),
      .memory_0_mem_ras_n                                       (ddr3b_rasn),
      .memory_0_mem_cas_n                                       (ddr3b_casn),
      .memory_0_mem_we_n                                        (ddr3b_wen),
      .memory_0_mem_reset_n                                     (ddr3b_resetn),
      .memory_0_mem_dq                                          (ddr3b_dq),
      .memory_0_mem_dqs                                         (ddr3b_dqs_p),
      .memory_0_mem_dqs_n                                       (ddr3b_dqs_n),
      .memory_0_mem_odt                                         (ddr3b_odt),

      .oct_0_rzqin                                              (rzqin),
      .axi2axi_0_altera_axi_slave_awid                          (m_axi_awid),
      .axi2axi_0_altera_axi_slave_awaddr                        (m_axi_awaddr),
      .axi2axi_0_altera_axi_slave_awlen                         (m_axi_awlen),
      .axi2axi_0_altera_axi_slave_awsize                        (m_axi_awsize),
      .axi2axi_0_altera_axi_slave_awburst                       (m_axi_awburst),
      .axi2axi_0_altera_axi_slave_awlock                        (m_axi_awlock),
      .axi2axi_0_altera_axi_slave_awcache                       (m_axi_awcache),
      .axi2axi_0_altera_axi_slave_awprot                        (m_axi_awprot),
      .axi2axi_0_altera_axi_slave_awvalid                       (m_axi_awvalid),
      .axi2axi_0_altera_axi_slave_awready                       (m_axi_awready),
      .axi2axi_0_altera_axi_slave_wid                           (m_axi_wid),
      .axi2axi_0_altera_axi_slave_wdata                         (m_axi_wdata),
      .axi2axi_0_altera_axi_slave_wstrb                         (m_axi_wstrb),
      .axi2axi_0_altera_axi_slave_wlast                         (m_axi_wlast),
      .axi2axi_0_altera_axi_slave_wvalid                        (m_axi_wvalid),
      .axi2axi_0_altera_axi_slave_wready                        (m_axi_wready),
      .axi2axi_0_altera_axi_slave_bid                           (m_axi_bid),
      .axi2axi_0_altera_axi_slave_bresp                         (m_axi_bresp),
      .axi2axi_0_altera_axi_slave_bvalid                        (m_axi_bvalid),
      .axi2axi_0_altera_axi_slave_bready                        (m_axi_bready),
      .axi2axi_0_altera_axi_slave_arid                          (m_axi_arid),
      .axi2axi_0_altera_axi_slave_araddr                        (m_axi_araddr),
      .axi2axi_0_altera_axi_slave_arlen                         (m_axi_arlen),
      .axi2axi_0_altera_axi_slave_arsize                        (m_axi_arsize),
      .axi2axi_0_altera_axi_slave_arburst                       (m_axi_arburst),
      .axi2axi_0_altera_axi_slave_arlock                        (m_axi_arlock),
      .axi2axi_0_altera_axi_slave_arcache                       (m_axi_arcache),
      .axi2axi_0_altera_axi_slave_arprot                        (m_axi_arprot),
      .axi2axi_0_altera_axi_slave_arvalid                       (m_axi_arvalid),
      .axi2axi_0_altera_axi_slave_arready                       (m_axi_arready),
      .axi2axi_0_altera_axi_slave_rid                           (m_axi_rid),
      .axi2axi_0_altera_axi_slave_rdata                         (m_axi_rdata),
      .axi2axi_0_altera_axi_slave_rresp                         (m_axi_rresp),
      .axi2axi_0_altera_axi_slave_rlast                         (m_axi_rlast),
      .axi2axi_0_altera_axi_slave_rvalid                        (m_axi_rvalid),
      .axi2axi_0_altera_axi_slave_rready                        (m_axi_rready),

      .mem_if_ddr3_emif_1_pll_sharing_pll_mem_clk               (),
      .mem_if_ddr3_emif_1_pll_sharing_pll_write_clk             (),
      .mem_if_ddr3_emif_1_pll_sharing_pll_locked                (locked),
      .mem_if_ddr3_emif_1_pll_sharing_pll_write_clk_pre_phy_clk (),
      .mem_if_ddr3_emif_1_pll_sharing_pll_addr_cmd_clk          (),
      .mem_if_ddr3_emif_1_pll_sharing_pll_avl_clk               (),
      .mem_if_ddr3_emif_1_pll_sharing_pll_config_clk            (),
      .mem_if_ddr3_emif_1_pll_sharing_pll_mem_phy_clk           (),
      .mem_if_ddr3_emif_1_pll_sharing_afi_phy_clk               (),
      .mem_if_ddr3_emif_1_pll_sharing_pll_avl_phy_clk           (),
      .mem_if_ddr3_emif_1_status_local_init_done                (),
      .mem_if_ddr3_emif_1_status_local_cal_success              (),
      .mem_if_ddr3_emif_1_status_local_cal_fail                 ()
      );

`else
   iob_reset_sync rst_sync (clk, (~resetn), rst);   
`endif

   //
   // SYSTEM
   //
   system
     #(
       .AXI_ID_W(AXI_ID_W),
       .AXI_ADDR_W(AXI_ADDR_W),
       .AXI_DATA_W(AXI_DATA_W)
       )
   system 
     (
      .clk(clk),
      .rst(rst),
      .trap          (trap),

`ifdef USE_DDR
      `include "m_axi_portmap.vh"	
`endif

      //UART
      .uart_txd      (uart_txd),
      .uart_rxd      (uart_rxd),
      .uart_rts      (),
      .uart_cts      (1'b1)
      );

endmodule
