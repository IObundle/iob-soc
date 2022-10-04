`timescale 1ns / 1ps
`include "tester.vh"

module top_system
  (

   //differential clock input and reset
   input         c0_sys_clk_clk_p, 
   input         c0_sys_clk_clk_n,
   input         reset,

   //uart
   output        uart_txd,
   input         uart_rxd,

`ifdef TESTER_USE_DDR
   output        c0_ddr4_act_n,
   output [16:0] c0_ddr4_adr,
   output [1:0]  c0_ddr4_ba,
   output [0:0]  c0_ddr4_bg,
   output [0:0]  c0_ddr4_cke,
   output [0:0]  c0_ddr4_odt,
   output [0:0]  c0_ddr4_cs_n,
   output [0:0]  c0_ddr4_ck_t,
   output [0:0]  c0_ddr4_ck_c,
   output        c0_ddr4_reset_n,
   inout [3:0]   c0_ddr4_dm_dbi_n,
   inout [31:0]  c0_ddr4_dq,
   inout [3:0]   c0_ddr4_dqs_c,
   inout [3:0]   c0_ddr4_dqs_t,
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

   localparam AXI_ID_W = 4;
   localparam AXI_ADDR_W=`TESTER_DDR_ADDR_W;
   localparam AXI_DATA_W=`TESTER_DDR_DATA_W;

   wire          clk;
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
    wire            locked;

    //MII
    wire [3:0]      TX_DATA;   
    wire [3:0]      RX_DATA;

    assign {ENET_TX_D3, ENET_TX_D2, ENET_TX_D1, ENET_TX_D0} = TX_DATA;
    assign RX_DATA = {ENET_RX_D3, ENET_RX_D2, ENET_RX_D1, ENET_RX_D0};

    //eth clock
    IBUFG rxclk_buf (
          .I (ENET_RX_CLK),
          .O (ETH_CLK)
          );
    ODDRE1 ODDRE1_inst (
             .Q  (ENET_GTX_CLK),
             .C  (ETH_CLK),
             .D1 (1'b1),
             .D2 (1'b0),
             .SR (~ENET_RESETN)
             );

    assign locked = 1'b1; 
`endif                  

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
`ifdef TESTER_USE_ETHERNET
            //ETHERNET
            //PHY
            .ETHERNET0_ETH_PHY_RESETN(ENET_RESETN),
            //PLL
            .ETHERNET0_PLL_LOCKED(locked),
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
   ddr4_0 ddr4_ctrl 
     (
      .sys_rst                (reset),
      .c0_sys_clk_p           (c0_sys_clk_clk_p),
      .c0_sys_clk_n           (c0_sys_clk_clk_n),

      .dbg_clk                (),
      .dbg_bus                (),

      //USER LOGIC CLOCK AND RESET      
      .c0_ddr4_ui_clk_sync_rst(c0_ddr4_ui_clk_sync_rst), //to axi intercon
      .addn_ui_clkout1 (clk), //to user logic 

      //AXI INTERFACE (slave)
      .c0_ddr4_ui_clk (c0_ddr4_ui_clk), //to axi intercon general and master clocks
      .c0_ddr4_aresetn (ddr4_axi_arstn),//from interconnect axi master

      //address write 
      .c0_ddr4_s_axi_awid (ddr4_axi_awid),
      .c0_ddr4_s_axi_awaddr (ddr4_axi_awaddr),
      .c0_ddr4_s_axi_awlen (ddr4_axi_awlen),
      .c0_ddr4_s_axi_awsize (ddr4_axi_awsize),
      .c0_ddr4_s_axi_awburst (ddr4_axi_awburst),
      .c0_ddr4_s_axi_awlock (ddr4_axi_awlock[0]),
      .c0_ddr4_s_axi_awprot (ddr4_axi_awprot),
      .c0_ddr4_s_axi_awcache (ddr4_axi_awcache),
      .c0_ddr4_s_axi_awqos (ddr4_axi_awqos),
      .c0_ddr4_s_axi_awvalid (ddr4_axi_awvalid),
      .c0_ddr4_s_axi_awready (ddr4_axi_awready),

      //write  
      .c0_ddr4_s_axi_wvalid (ddr4_axi_wvalid),
      .c0_ddr4_s_axi_wready (ddr4_axi_wready),
      .c0_ddr4_s_axi_wdata (ddr4_axi_wdata),
      .c0_ddr4_s_axi_wstrb (ddr4_axi_wstrb),
      .c0_ddr4_s_axi_wlast (ddr4_axi_wlast),

      //write response
      .c0_ddr4_s_axi_bready (ddr4_axi_bready),
      .c0_ddr4_s_axi_bid (ddr4_axi_bid),
      .c0_ddr4_s_axi_bresp (ddr4_axi_bresp),
      .c0_ddr4_s_axi_bvalid (ddr4_axi_bvalid),

      //address read
      .c0_ddr4_s_axi_arid (ddr4_axi_arid),
      .c0_ddr4_s_axi_araddr (ddr4_axi_araddr),
      .c0_ddr4_s_axi_arlen (ddr4_axi_arlen), 
      .c0_ddr4_s_axi_arsize (ddr4_axi_arsize),    
      .c0_ddr4_s_axi_arburst (ddr4_axi_arburst),
      .c0_ddr4_s_axi_arlock (ddr4_axi_arlock[0]),
      .c0_ddr4_s_axi_arcache (ddr4_axi_arcache),
      .c0_ddr4_s_axi_arprot (ddr4_axi_arprot),
      .c0_ddr4_s_axi_arqos (ddr4_axi_arqos),
      .c0_ddr4_s_axi_arvalid (ddr4_axi_arvalid),
      .c0_ddr4_s_axi_arready (ddr4_axi_arready),
      
      //read   
      .c0_ddr4_s_axi_rready (ddr4_axi_rready),
      .c0_ddr4_s_axi_rid (ddr4_axi_rid),
      .c0_ddr4_s_axi_rdata (ddr4_axi_rdata),
      .c0_ddr4_s_axi_rresp (ddr4_axi_rresp),
      .c0_ddr4_s_axi_rlast (ddr4_axi_rlast),
      .c0_ddr4_s_axi_rvalid (ddr4_axi_rvalid),

      //DDR4 INTERFACE (master of external DDR4 module)
      .c0_ddr4_act_n (c0_ddr4_act_n),
      .c0_ddr4_adr (c0_ddr4_adr),
      .c0_ddr4_ba (c0_ddr4_ba),
      .c0_ddr4_bg (c0_ddr4_bg),
      .c0_ddr4_cke (c0_ddr4_cke),
      .c0_ddr4_odt (c0_ddr4_odt),
      .c0_ddr4_cs_n (c0_ddr4_cs_n),
      .c0_ddr4_ck_t (c0_ddr4_ck_t),
      .c0_ddr4_ck_c (c0_ddr4_ck_c),
      .c0_ddr4_reset_n (c0_ddr4_reset_n),
      .c0_ddr4_dm_dbi_n (c0_ddr4_dm_dbi_n),
      .c0_ddr4_dq (c0_ddr4_dq),
      .c0_ddr4_dqs_c (c0_ddr4_dqs_c),
      .c0_ddr4_dqs_t (c0_ddr4_dqs_t),
      .c0_init_calib_complete (calib_done)
      );


`else
   //if DDR not used use PLL to generate system clock
   clock_wizard 
     #(
       .OUTPUT_PER(10),
       .INPUT_PER(4)
       )
   clk_250_to_100_MHz
     (
      .clk_in1_p(c0_sys_clk_clk_p),
      .clk_in1_n(c0_sys_clk_clk_n),
      .clk_out1(clk)
      );

   //create reset pulse as reset is never activated manually
   //also, during bitstream loading, the reset pin is not pulled high
   iob_pulse_gen
     #(
       .START(5),
       .DURATION(10)
       ) 
   reset_pulse
     (
      .clk(clk),
      .rst(reset),
      .restart(1'b0),
      .pulse_out(rst)
      );
`endif


   //
   // DDR4 CONTROLLER
   //
                 
`ifdef TESTER_USE_DDR

   //axi wires between ddr4 contrl and axi interconnect
 `include "ddr4_axi_wire.vh"

   //DDR4 controller axi side clocks and resets
   wire          c0_ddr4_ui_clk;//controller output clock 200MHz
   wire          ddr4_axi_arstn;//controller input
   
   wire          c0_ddr4_ui_clk_sync_rst; 
   wire   [1:0]  rstn;
   
   wire          calib_done;
   
   //assign rst = ~rstn & ~calib_done;
   assign rst = ~rstn[0] || ~rstn[1];
   
   
   //
   // ASYNC AXI BRIDGE (between user logic (clk) and DDR controller (c0_ddr4_ui_clk)
   //
   axi_interconnect_0 axi_async_bridge 
     (
      .INTERCONNECT_ACLK    (c0_ddr4_ui_clk), //from ddr4 controller 
      .INTERCONNECT_ARESETN (~c0_ddr4_ui_clk_sync_rst), //from ddr4 controller
      
      //
      // SYSTEM SIDE (slave)
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

      .M00_AXI_ARESET_OUT_N  (ddr4_axi_arstn), //to ddr controller axi slave port
      .M00_AXI_ACLK          (c0_ddr4_ui_clk), //from ddr4 controller 200MHz clock
      
      //Write address
      .M00_AXI_AWID          (ddr4_axi_awid),
      .M00_AXI_AWADDR        (ddr4_axi_awaddr),
      .M00_AXI_AWLEN         (ddr4_axi_awlen),
      .M00_AXI_AWSIZE        (ddr4_axi_awsize),
      .M00_AXI_AWBURST       (ddr4_axi_awburst),
      .M00_AXI_AWLOCK        (ddr4_axi_awlock[0]),
      .M00_AXI_AWCACHE       (ddr4_axi_awcache),
      .M00_AXI_AWPROT        (ddr4_axi_awprot),
      .M00_AXI_AWQOS         (ddr4_axi_awqos),
      .M00_AXI_AWVALID       (ddr4_axi_awvalid),
      .M00_AXI_AWREADY       (ddr4_axi_awready),
      
      //Write data
      .M00_AXI_WDATA         (ddr4_axi_wdata),
      .M00_AXI_WSTRB         (ddr4_axi_wstrb),
      .M00_AXI_WLAST         (ddr4_axi_wlast),
      .M00_AXI_WVALID        (ddr4_axi_wvalid),
      .M00_AXI_WREADY        (ddr4_axi_wready),
      
      //Write response
      .M00_AXI_BID           (ddr4_axi_bid),
      .M00_AXI_BRESP         (ddr4_axi_bresp),
      .M00_AXI_BVALID        (ddr4_axi_bvalid),
      .M00_AXI_BREADY        (ddr4_axi_bready),
      
      //Read address
      .M00_AXI_ARID         (ddr4_axi_arid),
      .M00_AXI_ARADDR       (ddr4_axi_araddr),
      .M00_AXI_ARLEN        (ddr4_axi_arlen),
      .M00_AXI_ARSIZE       (ddr4_axi_arsize),
      .M00_AXI_ARBURST      (ddr4_axi_arburst),
      .M00_AXI_ARLOCK       (ddr4_axi_arlock[0]),
      .M00_AXI_ARCACHE      (ddr4_axi_arcache),
      .M00_AXI_ARPROT       (ddr4_axi_arprot),
      .M00_AXI_ARQOS        (ddr4_axi_arqos),
      .M00_AXI_ARVALID      (ddr4_axi_arvalid),
      .M00_AXI_ARREADY      (ddr4_axi_arready),
      
      //Read data
      .M00_AXI_RID          (ddr4_axi_rid),
      .M00_AXI_RDATA        (ddr4_axi_rdata),
      .M00_AXI_RRESP        (ddr4_axi_rresp),
      .M00_AXI_RLAST        (ddr4_axi_rlast),
      .M00_AXI_RVALID       (ddr4_axi_rvalid),
      .M00_AXI_RREADY       (ddr4_axi_rready)
      );

`endif

endmodule
