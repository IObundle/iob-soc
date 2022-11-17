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
   output        trap
   );
   
   //axi4 parameters
   localparam AXI_ID_W  = 1;
   localparam AXI_LEN_W = 4;
   localparam AXI_ADDR_W=`DDR_ADDR_W;
   localparam AXI_DATA_W=`DDR_DATA_W;
   
   //-----------------------------------------------------------------
   // Clocking / Reset
   //-----------------------------------------------------------------

   wire 	 rst;

`ifdef USE_DDR
   //axi wires between system backend and axi bridge
 `include "m_axi_wire.vh"
`endif

   //
   // SYSTEM
   //
   system
     #(
       .AXI_ID_W(AXI_ID_W),
       .AXI_LEN_W(AXI_LEN_W),
       .AXI_ADDR_W(AXI_ADDR_W),
       .AXI_DATA_W(AXI_DATA_W)
       )
   system 
     (
      .clk (clk),
      .rst (rst),
      .trap (trap),

`ifdef USE_DDR
      `include "m_axi_portmap.vh"	
`endif

      //UART
      .uart_txd      (uart_txd),
      .uart_rxd      (uart_rxd),
      .uart_rts      (),
      .uart_cts      (1'b1)
      );

   
`ifdef USE_DDR
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
      
      .axi_bridge_0_s0_awid (m_axi_awid),
      .axi_bridge_0_s0_awaddr (m_axi_awaddr),
      .axi_bridge_0_s0_awlen (m_axi_awlen),
      .axi_bridge_0_s0_awsize (m_axi_awsize),
      .axi_bridge_0_s0_awburst (m_axi_awburst),
      .axi_bridge_0_s0_awlock (m_axi_awlock),
      .axi_bridge_0_s0_awcache (m_axi_awcache),
      .axi_bridge_0_s0_awprot (m_axi_awprot),
      .axi_bridge_0_s0_awvalid (m_axi_awvalid),
      .axi_bridge_0_s0_awready (m_axi_awready),
      .axi_bridge_0_s0_wdata (m_axi_wdata),
      .axi_bridge_0_s0_wstrb (m_axi_wstrb),
      .axi_bridge_0_s0_wlast (m_axi_wlast),
      .axi_bridge_0_s0_wvalid (m_axi_wvalid),
      .axi_bridge_0_s0_wready (m_axi_wready),
      .axi_bridge_0_s0_bid (m_axi_bid),
      .axi_bridge_0_s0_bresp (m_axi_bresp),
      .axi_bridge_0_s0_bvalid (m_axi_bvalid),
      .axi_bridge_0_s0_bready (m_axi_bready),
      .axi_bridge_0_s0_arid (m_axi_arid),
      .axi_bridge_0_s0_araddr (m_axi_araddr),
      .axi_bridge_0_s0_arlen (m_axi_arlen),
      .axi_bridge_0_s0_arsize (m_axi_arsize),
      .axi_bridge_0_s0_arburst (m_axi_arburst),
      .axi_bridge_0_s0_arlock (m_axi_arlock),
      .axi_bridge_0_s0_arcache (m_axi_arcache),
      .axi_bridge_0_s0_arprot (m_axi_arprot),
      .axi_bridge_0_s0_arvalid (m_axi_arvalid),
      .axi_bridge_0_s0_arready (m_axi_arready),
      .axi_bridge_0_s0_rid (m_axi_rid),
      .axi_bridge_0_s0_rdata (m_axi_rdata),
      .axi_bridge_0_s0_rresp (m_axi_rresp),
      .axi_bridge_0_s0_rlast (m_axi_rlast),
      .axi_bridge_0_s0_rvalid (m_axi_rvalid),
      .axi_bridge_0_s0_rready (m_axi_rready),

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


endmodule
