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
     // DDR/MASTER SIDE
   //Write address
   wire [3:0] 			axi4_awid;
   wire [`DDR_ADDR_W-1:0]       axi4_awaddr;
   wire [7:0] 			axi4_awlen;
   wire [2:0] 			axi4_awsize;
   wire [1:0] 			axi4_awburst;
   wire 			axi4_awlock;
   wire [3:0] 			axi4_awcache;
   wire [2:0] 			axi4_awprot;
   wire [3:0] 			axi4_awqos;
   wire 			axi4_awvalid;
   wire 			axi4_awready;
   //Write data
   wire [31:0] 			axi4_wdata;
   wire [3:0] 			axi4_wstrb;
   wire 			axi4_wlast;
   wire 			axi4_wvalid;
   wire 			axi4_wready;
   //Write response
   wire [3:0]                   axi4_bid;
   wire [1:0] 			axi4_bresp;
   wire 			axi4_bvalid;
   wire 			axi4_bready;
   //Read address
   wire [3:0] 			axi4_arid;
   wire [`DDR_ADDR_W-1:0]       axi4_araddr;
   wire [7:0] 			axi4_arlen;
   wire [2:0] 			axi4_arsize;
   wire [1:0] 			axi4_arburst;
   wire 			axi4_arlock;
   wire [3:0] 			axi4_arcache;
   wire [2:0] 			axi4_arprot;
   wire [3:0] 			axi4_arqos;
   wire 			axi4_arvalid;
   wire 			axi4_arready;
   //Read data
   wire [3:0]			axi4_rid;
   wire [31:0] 			axi4_rdata;
   wire [1:0] 			axi4_rresp;
   wire 			axi4_rlast;
   wire 			axi4_rvalid;
   wire 			axi4_rready;
   
  


   alt_ddr3 ddr30 
     (
      .memory_mem_a                                             (ddr3b_a),
      .memory_mem_ba                                            (ddr3b_ba),
      .memory_mem_ck                                            (ddr3b_clk_p),
      .memory_mem_ck_n                                          (ddr3b_clk_n),
      .memory_mem_cke                                           (ddr3b_cke),
      .memory_mem_cs_n                                          (ddr3b_cs_n),
      .memory_mem_dm                                            (ddr3b_dm),
      .memory_mem_ras_n                                         (ddr3b_rasn),
      .memory_mem_cas_n                                         (ddr3b_casn),
      .memory_mem_we_n                                          (ddr3b_wen),
      .memory_mem_reset_n                                       (ddr3b_resetn),
      .memory_mem_dq                                            (ddr3b_dq),
      .memory_mem_dqs                                           (ddr3b_dqs_p),
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

   //
   // SYSTEM
   //
   system system 
     (
      .clk           (sys_clk),
      .reset         (sys_rst),
      .trap          (trap),

`ifdef USE_DDR
      //address write
      .m_axi_awid    (axi4_awid),
      .m_axi_awaddr  (axi4_awaddr),
      .m_axi_awlen   (axi4_awlen),
      .m_axi_awsize  (axi4_awsize),
      .m_axi_awburst (axi4_awburst),
      .m_axi_awlock  (axi4_awlock),
      .m_axi_awcache (axi4_awcache),
      .m_axi_awprot  (axi4_awprot),
      .m_axi_awqos   (axi4_awqos),
      .m_axi_awvalid (axi4_awvalid),
      .m_axi_awready (axi4_awready),
      
		  //write  
      .m_axi_wdata   (axi4_wdata),
      .m_axi_wstrb   (axi4_wstrb),
      .m_axi_wlast   (axi4_wlast),
      .m_axi_wvalid  (axi4_wvalid),
      .m_axi_wready  (axi4_wready),
      
		  //write response
      .m_axi_bid     (axi4_bid),
      .m_axi_bresp   (axi4_bresp),
      .m_axi_bvalid  (axi4_bvalid),
      .m_axi_bready  (axi4_bready),

		  //address read
      .m_axi_arid    (axi4_arid),
      .m_axi_araddr  (axi4_araddr),
      .m_axi_arlen   (axi4_arlen),
      .m_axi_arsize  (axi4_arsize),
      .m_axi_arburst (axi4_arburst),
      .m_axi_arlock  (axi4_arlock),
      .m_axi_arcache (axi4_arcache),
      .m_axi_arprot  (axi4_arprot),
      .m_axi_arqos   (axi4_arqos),
      .m_axi_arvalid (axi4_arvalid),
      .m_axi_arready (axi4_arready),

		  //read   
      .m_axi_rid     (axi4_rid),
      .m_axi_rdata   (axi4_rdata),
      .m_axi_rresp   (axi4_rresp),
      .m_axi_rlast   (axi4_rlast),
      .m_axi_rvalid  (axi4_rvalid),
      .m_axi_rready  (axi4_rready),	
`endif

      //UART
      .uart_txd      (uart_txd),
      .uart_rxd      (uart_rxd),
      .uart_rts      (),
      .uart_cts      (1'b1)
      );

endmodule
