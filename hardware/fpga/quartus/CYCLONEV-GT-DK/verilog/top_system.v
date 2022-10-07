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

`ifdef TESTER_USE_DDR
   //axi wires between system backend and axi bridge
	`IOB_WIRE(m_axi_awid, 2*AXI_ID_W) //Address write channel ID
	`IOB_WIRE(m_axi_awaddr, 2*AXI_ADDR_W) //Address write channel address
	`IOB_WIRE(m_axi_awlen, 2*8) //Address write channel burst length
	`IOB_WIRE(m_axi_awsize, 2*3) //Address write channel burst size. This signal indicates the size of each transfer in the burst
	`IOB_WIRE(m_axi_awburst, 2*2) //Address write channel burst type
	`IOB_WIRE(m_axi_awlock, 2*2) //Address write channel lock type
	`IOB_WIRE(m_axi_awcache, 2*4) //Address write channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
	`IOB_WIRE(m_axi_awprot, 2*3) //Address write channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
	`IOB_WIRE(m_axi_awqos, 2*4) //Address write channel quality of service
	`IOB_WIRE(m_axi_awvalid, 2*1) //Address write channel valid
	`IOB_WIRE(m_axi_awready, 2*1) //Address write channel ready
	`IOB_WIRE(m_axi_wdata, 2*AXI_DATA_W) //Write channel data
	`IOB_WIRE(m_axi_wstrb, 2*(AXI_DATA_W/8)) //Write channel write strobe
	`IOB_WIRE(m_axi_wlast, 2*1) //Write channel last word flag
	`IOB_WIRE(m_axi_wvalid, 2*1) //Write channel valid
	`IOB_WIRE(m_axi_wready, 2*1) //Write channel ready
	`IOB_WIRE(m_axi_bid, 2*AXI_ID_W) //Write response channel ID
	`IOB_WIRE(m_axi_bresp, 2*2) //Write response channel response
	`IOB_WIRE(m_axi_bvalid, 2*1) //Write response channel valid
	`IOB_WIRE(m_axi_bready, 2*1) //Write response channel ready
	`IOB_WIRE(m_axi_arid, 2*AXI_ID_W) //Address read channel ID
	`IOB_WIRE(m_axi_araddr, 2*AXI_ADDR_W) //Address read channel address
	`IOB_WIRE(m_axi_arlen, 2*8) //Address read channel burst length
	`IOB_WIRE(m_axi_arsize, 2*3) //Address read channel burst size. This signal indicates the size of each transfer in the burst
	`IOB_WIRE(m_axi_arburst, 2*2) //Address read channel burst type
	`IOB_WIRE(m_axi_arlock, 2*2) //Address read channel lock type
	`IOB_WIRE(m_axi_arcache, 2*4) //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
	`IOB_WIRE(m_axi_arprot, 2*3) //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
	`IOB_WIRE(m_axi_arqos, 2*4) //Address read channel quality of service
	`IOB_WIRE(m_axi_arvalid, 2*1) //Address read channel valid
	`IOB_WIRE(m_axi_arready, 2*1) //Address read channel ready
	`IOB_WIRE(m_axi_rid, 2*AXI_ID_W) //Read channel ID
	`IOB_WIRE(m_axi_rdata, 2*AXI_DATA_W) //Read channel data
	`IOB_WIRE(m_axi_rresp, 2*2) //Read channel response
	`IOB_WIRE(m_axi_rlast, 2*1) //Read channel last word
	`IOB_WIRE(m_axi_rvalid, 2*1) //Read channel valid
	`IOB_WIRE(m_axi_rready, 2*1) //Read channel ready
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
   wire [1:0]                   rstn;

   //determine system reset
   wire          rst_int = ~resetn | ~locked | ~init_done | ~rstn[0] | ~rstn[1];
//   wire          rst_int = ~resetn | ~locked | ~init_done;
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
      
      .axi_bridge_0_s0_awid (ddr_awid),
      .axi_bridge_0_s0_awaddr (ddr_awaddr),
      .axi_bridge_0_s0_awlen (ddr_awlen),
      .axi_bridge_0_s0_awsize (ddr_awsize),
      .axi_bridge_0_s0_awburst (ddr_awburst),
      .axi_bridge_0_s0_awlock (ddr_awlock),
      .axi_bridge_0_s0_awcache (ddr_awcache),
      .axi_bridge_0_s0_awprot (ddr_awprot),
      .axi_bridge_0_s0_awvalid (ddr_awvalid),
      .axi_bridge_0_s0_awready (ddr_awready),
      .axi_bridge_0_s0_wdata (ddr_wdata),
      .axi_bridge_0_s0_wstrb (ddr_wstrb),
      .axi_bridge_0_s0_wlast (ddr_wlast),
      .axi_bridge_0_s0_wvalid (ddr_wvalid),
      .axi_bridge_0_s0_wready (ddr_wready),
      .axi_bridge_0_s0_bid (ddr_bid),
      .axi_bridge_0_s0_bresp (ddr_bresp),
      .axi_bridge_0_s0_bvalid (ddr_bvalid),
      .axi_bridge_0_s0_bready (ddr_bready),
      .axi_bridge_0_s0_arid (ddr_arid),
      .axi_bridge_0_s0_araddr (ddr_araddr),
      .axi_bridge_0_s0_arlen (ddr_arlen),
      .axi_bridge_0_s0_arsize (ddr_arsize),
      .axi_bridge_0_s0_arburst (ddr_arburst),
      .axi_bridge_0_s0_arlock (ddr_arlock),
      .axi_bridge_0_s0_arcache (ddr_arcache),
      .axi_bridge_0_s0_arprot (ddr_arprot),
      .axi_bridge_0_s0_arvalid (ddr_arvalid),
      .axi_bridge_0_s0_arready (ddr_arready),
      .axi_bridge_0_s0_rid (ddr_rid),
      .axi_bridge_0_s0_rdata (ddr_rdata),
      .axi_bridge_0_s0_rresp (ddr_rresp),
      .axi_bridge_0_s0_rlast (ddr_rlast),
      .axi_bridge_0_s0_rvalid (ddr_rvalid),
      .axi_bridge_0_s0_rready (ddr_rready),

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
   axi_interconnect_0 cache2ddr 
     (
      .INTERCONNECT_ACLK     (ddr_ui_clk),
      .INTERCONNECT_ARESETN  (~(ddr_ui_rst | ~init_calib_complete)),

      //
      // SYSTEM SUT SIDE
      //
      .S00_AXI_ARESET_OUT_N (rstn[0]), //to system reset
      .S00_AXI_ACLK         (clk), //from ddr4 controller PLL to be used by system
      
      //Write address
      .S00_AXI_AWID         (m_axi_awid[0+:AXI_ID_W]),
      .S00_AXI_AWADDR       (m_axi_awaddr[0*AXI_ADDR_W+:AXI_ADDR_W]),
      .S00_AXI_AWLEN        (m_axi_awlen[7:0]),
      .S00_AXI_AWSIZE       (m_axi_awsize[2:0]),
      .S00_AXI_AWBURST      (m_axi_awburst[1:0]),
      .S00_AXI_AWLOCK       (m_axi_awlock[0]),
      .S00_AXI_AWCACHE      (m_axi_awcache[3:0]),
      .S00_AXI_AWPROT       (m_axi_awprot[2:0]),
      .S00_AXI_AWQOS        (m_axi_awqos[3:0]),
      .S00_AXI_AWVALID      (m_axi_awvalid[0]),
      .S00_AXI_AWREADY      (m_axi_awready[0]),

      //Write data
      .S00_AXI_WDATA        (m_axi_wdata[0*AXI_DATA_W+:AXI_DATA_W]),
      .S00_AXI_WSTRB        (m_axi_wstrb[0*(AXI_DATA_W/8)+:(AXI_DATA_W/8)]),
      .S00_AXI_WLAST        (m_axi_wlast[0]),
      .S00_AXI_WVALID       (m_axi_wvalid[0]),
      .S00_AXI_WREADY       (m_axi_wready[0]),
      
      //Write response
      .S00_AXI_BID           (m_axi_bid[0+:AXI_ID_W]),
      .S00_AXI_BRESP         (m_axi_bresp[1:0]),
      .S00_AXI_BVALID        (m_axi_bvalid[0]),
      .S00_AXI_BREADY        (m_axi_bready[0]),
      
      //Read address
      .S00_AXI_ARID         (m_axi_arid[0+:AXI_ID_W]),
      .S00_AXI_ARADDR       (m_axi_araddr[0*AXI_ADDR_W+:AXI_ADDR_W]),
      .S00_AXI_ARLEN        (m_axi_arlen[7:0]),
      .S00_AXI_ARSIZE       (m_axi_arsize[2:0]),
      .S00_AXI_ARBURST      (m_axi_arburst[1:0]),
      .S00_AXI_ARLOCK       (m_axi_arlock[0]),
      .S00_AXI_ARCACHE      (m_axi_arcache[3:0]),
      .S00_AXI_ARPROT       (m_axi_arprot[2:0]),
      .S00_AXI_ARQOS        (m_axi_arqos[3:0]),
      .S00_AXI_ARVALID      (m_axi_arvalid[0]),
      .S00_AXI_ARREADY      (m_axi_arready[0]),
      
      //Read data
      .S00_AXI_RID          (m_axi_rid[0+:AXI_ID_W]),
      .S00_AXI_RDATA        (m_axi_rdata[31:0]),
      .S00_AXI_RRESP        (m_axi_rresp[1:0]),
      .S00_AXI_RLAST        (m_axi_rlast[0]),
      .S00_AXI_RVALID       (m_axi_rvalid[0]),
      .S00_AXI_RREADY       (m_axi_rready[0]),


      //
      // SYSTEM TESTER SIDE
      //
      .S01_AXI_ARESET_OUT_N (rstn[1]),
      .S01_AXI_ACLK         (clk),
      
      //Write address
      .S01_AXI_AWID         (m_axi_awid[AXI_ID_W+:AXI_ID_W]),
      .S01_AXI_AWADDR       (m_axi_awaddr[1*AXI_ADDR_W+:AXI_ADDR_W]),
      .S01_AXI_AWLEN        (m_axi_awlen[15:8]),
      .S01_AXI_AWSIZE       (m_axi_awsize[5:3]),
      .S01_AXI_AWBURST      (m_axi_awburst[3:2]),
      .S01_AXI_AWLOCK       (m_axi_awlock[1]),
      .S01_AXI_AWCACHE      (m_axi_awcache[7:4]),
      .S01_AXI_AWPROT       (m_axi_awprot[5:3]),
      .S01_AXI_AWQOS        (m_axi_awqos[7:4]),
      .S01_AXI_AWVALID      (m_axi_awvalid[1]),
      .S01_AXI_AWREADY      (m_axi_awready[1]),

      //Write data
      .S01_AXI_WDATA        (m_axi_wdata[1*AXI_DATA_W+:AXI_DATA_W]),
      .S01_AXI_WSTRB        (m_axi_wstrb[1*(AXI_DATA_W/8)+:(AXI_DATA_W/8)]),
      .S01_AXI_WLAST        (m_axi_wlast[1]),
      .S01_AXI_WVALID       (m_axi_wvalid[1]),
      .S01_AXI_WREADY       (m_axi_wready[1]),
      
      //Write response
      .S01_AXI_BID           (m_axi_bid[AXI_ID_W+:AXI_ID_W]),
      .S01_AXI_BRESP         (m_axi_bresp[3:2]),
      .S01_AXI_BVALID        (m_axi_bvalid[1]),
      .S01_AXI_BREADY        (m_axi_bready[1]),
      
      //Read address
      .S01_AXI_ARID         (m_axi_arid[AXI_ID_W+:AXI_ID_W]),
      .S01_AXI_ARADDR       (m_axi_araddr[1*AXI_ADDR_W+:AXI_ADDR_W]),
      .S01_AXI_ARLEN        (m_axi_arlen[15:8]),
      .S01_AXI_ARSIZE       (m_axi_arsize[5:3]),
      .S01_AXI_ARBURST      (m_axi_arburst[3:2]),
      .S01_AXI_ARLOCK       (m_axi_arlock[1]),
      .S01_AXI_ARCACHE      (m_axi_arcache[7:4]),
      .S01_AXI_ARPROT       (m_axi_arprot[5:3]),
      .S01_AXI_ARQOS        (m_axi_arqos[7:4]),
      .S01_AXI_ARVALID      (m_axi_arvalid[1]),
      .S01_AXI_ARREADY      (m_axi_arready[1]),
      
      //Read data
      .S01_AXI_RID          (m_axi_rid[AXI_ID_W+:AXI_ID_W]),
      .S01_AXI_RDATA        (m_axi_rdata[63:32]),
      .S01_AXI_RRESP        (m_axi_rresp[3:2]),
      .S01_AXI_RLAST        (m_axi_rlast[1]),
      .S01_AXI_RVALID       (m_axi_rvalid[1]),
      .S01_AXI_RREADY       (m_axi_rready[1]),


      //
      // DDR CONTROLLER SIDE (master)
      //

      .M00_AXI_ARESET_OUT_N  (ddr_arstn),
      .M00_AXI_ACLK          (ddr_ui_clk),
      
      //Write address
      .M00_AXI_AWID          (ddr_awid),
      .M00_AXI_AWADDR        (ddr_awaddr),
      .M00_AXI_AWLEN         (ddr_awlen),
      .M00_AXI_AWSIZE        (ddr_awsize),
      .M00_AXI_AWBURST       (ddr_awburst),
      .M00_AXI_AWLOCK        (ddr_awlock),
      .M00_AXI_AWCACHE       (ddr_awcache),
      .M00_AXI_AWPROT        (ddr_awprot),
      .M00_AXI_AWQOS         (ddr_awqos),
      .M00_AXI_AWVALID       (ddr_awvalid),
      .M00_AXI_AWREADY       (ddr_awready),
      
      //Write data
      .M00_AXI_WDATA         (ddr_wdata),
      .M00_AXI_WSTRB         (ddr_wstrb),
      .M00_AXI_WLAST         (ddr_wlast),
      .M00_AXI_WVALID        (ddr_wvalid),
      .M00_AXI_WREADY        (ddr_wready),
      
      //Write response
      .M00_AXI_BID           (ddr_bid),
      .M00_AXI_BRESP         (ddr_bresp),
      .M00_AXI_BVALID        (ddr_bvalid),
      .M00_AXI_BREADY        (ddr_bready),
      
      //Read address
      .M00_AXI_ARID         (ddr_arid),
      .M00_AXI_ARADDR       (ddr_araddr),
      .M00_AXI_ARLEN        (ddr_arlen),
      .M00_AXI_ARSIZE       (ddr_arsize),
      .M00_AXI_ARBURST      (ddr_arburst),
      .M00_AXI_ARLOCK       (ddr_arlock),
      .M00_AXI_ARCACHE      (ddr_arcache),
      .M00_AXI_ARPROT       (ddr_arprot),
      .M00_AXI_ARQOS        (ddr_arqos),
      .M00_AXI_ARVALID      (ddr_arvalid),
      .M00_AXI_ARREADY      (ddr_arready),
      
      //Read data
      .M00_AXI_RID          (ddr_rid),
      .M00_AXI_RDATA        (ddr_rdata),
      .M00_AXI_RRESP        (ddr_rresp),
      .M00_AXI_RLAST        (ddr_rlast),
      .M00_AXI_RVALID       (ddr_rvalid),
      .M00_AXI_RREADY       (ddr_rready)
      );

`endif

endmodule
