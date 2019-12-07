`timescale 1ns / 1ps
`include "system.vh"

module top_system(
	          input 	C0_SYS_CLK_clk_p, 
                  input 	C0_SYS_CLK_clk_n, 
	          input 	reset,

	          //output reg [6:0] led,
	          output 	uart_txd,
	          input 	uart_rxd,
`ifdef USE_DDR
                  input 	sys_rst, 
                  output 	c0_ddr4_act_n,
                  output [16:0] c0_ddr4_adr,
                  output [1:0] 	c0_ddr4_ba,
                  output [0:0] 	c0_ddr4_bg,
                  output [0:0] 	c0_ddr4_cke,
                  output [0:0] 	c0_ddr4_odt,
                  output [0:0] 	c0_ddr4_cs_n,
                  output [0:0] 	c0_ddr4_ck_t,
                  output [0:0] 	c0_ddr4_ck_c,
                  output 	c0_ddr4_reset_n,
                  inout [3:0] 	c0_ddr4_dm_dbi_n,
                  inout [31:0] 	c0_ddr4_dq,
                  inout [3:0] 	c0_ddr4_dqs_c,
                  inout [3:0] 	c0_ddr4_dqs_t, 
`endif                  
		  output 	trap
		  );

   
   //single ended clock
   wire 			sysclk;   
   
`ifndef USE_DDR
 `ifdef CLK_200MHZ
   clock_wizard #(
		  .OUTPUT_PER(5),
		  .INPUT_PER(4)
		  )
   clk_250_to_200_MHz(
		      .clk_in1_p(C0_SYS_CLK_clk_p),
		      .clk_in1_n(C0_SYS_CLK_clk_n),
		      .clk_out1(sysclk)
		      );
 `else
   clock_wizard #(
		  .OUTPUT_PER(10),
		  .INPUT_PER(4)
		  )
   clk_250_to_100_MHz(
		      .clk_in1_p(C0_SYS_CLK_clk_p),
		      .clk_in1_n(C0_SYS_CLK_clk_n),
		      .clk_out1(sysclk)
		      );
 `endif //def CLK_200MHZ
`endif //ndef DDR

`ifdef USE_DDR
   //
   // axi signals between system and interconnect
   //
   wire 			axi_awvalid;
   wire 			axi_awready;
   wire [31:0] 			axi_awaddr;
   wire [ 2:0] 			axi_awprot;
   
   wire 			axi_wvalid;
   wire 			axi_wready;
   wire [31:0] 			axi_wdata;
   wire [ 3:0] 			axi_wstrb;
   
   wire 			axi_bvalid;
   wire 			axi_bready;
   
   wire 			axi_arvalid;
   wire 			axi_arready;
   wire [31:0] 			axi_araddr;
   wire [ 2:0] 			axi_arprot;
   
   wire 			axi_rvalid;
   wire 			axi_rready;
   wire [31:0] 			axi_rdata;
   
   // AXI-full extra wires
   wire 			axi_rlast;
   wire [1:0] 			axi_bresp;
   wire [7:0] 			axi_arlen;
   wire [2:0] 			axi_arsize;
   wire [1:0] 			axi_arburst;
   wire [7:0] 			axi_awlen;
   wire [2:0] 			axi_awsize;
   wire [1:0] 			axi_awburst;


   wire [1:0] 			slave_select;
   wire 			mem_sel;
   wire 			init_calib_complete;
   reg [6:0] 			led_reg;

   // AXI INTERCONNECT DDR SIDE SIGNAlS
   //Write address
   wire [0:0] 			ddr_awid;
   wire [31:0] 			ddr_awaddr;
   wire [7:0] 			ddr_awlen;
   wire [2:0] 			ddr_awsize;
   wire [1:0] 			ddr_awburst;
   wire 			ddr_awlock;
   wire [3:0] 			ddr_awcache;
   wire [2:0] 			ddr_awprot;
   wire [3:0] 			ddr_awqos;
   wire 			ddr_awvalid;
   wire 			ddr_awready;
   //Write data
   wire [31:0] 			ddr_wdata;
   wire [3:0] 			ddr_wstrb;
   wire 			ddr_wlast;
   wire 			ddr_wvalid;
   wire 			ddr_wready;
   //Write response
   wire [0:0] 			ddr_bid;
   wire [1:0] 			ddr_bresp;
   wire 			ddr_bvalid;
   wire 			ddr_bready;
   //Read address
   wire [0:0] 			ddr_arid;
   wire [31:0] 			ddr_araddr;
   wire [7:0] 			ddr_arlen;
   wire [2:0] 			ddr_arsize;
   wire [1:0] 			ddr_arburst;
   wire 			ddr_arlock;
   wire [3:0] 			ddr_arcache;
   wire [2:0] 			ddr_arprot;
   wire [3:0] 			ddr_arqos;
   wire 			ddr_arvalid;
   wire 			ddr_arready;
   //Read data
   wire [0:0] 			ddr_rid;
   wire [31:0] 			ddr_rdata;
   wire [1:0] 			ddr_rresp;
   wire 			ddr_rlast;
   wire 			ddr_rvalid;
   wire 			ddr_rready;
`endif
   

   //initial reset
   reg [15:0] 			reset_cnt;
   wire 			reset_int = (reset_cnt != 16'hFFFF);

   always @(posedge clk, posedge reset)
`ifdef USE_DDR
     if(reset | ~(init_calib_complete))
`else   
       if(reset)
`endif    
	 reset_cnt <= 16'b0;
       else if (reset_cnt != 16'hFFFF)
	 reset_cnt <= reset_cnt+1'b1;
   

   



   
   
   system system (
        	  .clk               (sysclk),
		  .reset             (reset_int),
		  .uart_txd          (uart_txd),
		  .uart_rxd          (uart_rxd),
		  .uart_cts          (1'b1),

`ifdef USE_DDR
		  //// Address-Write
		  .m_axi_awvalid (axi_awvalid),
		  .m_axi_awready (axi_awready),
		  .m_axi_awaddr  (axi_awaddr ),
		  //// Data-Write  
		  .m_axi_wvalid  (axi_wvalid ),
		  .m_axi_wready  (axi_wready ),
		  .m_axi_wdata   (axi_wdata  ),
		  .m_axi_wstrb   (axi_wstrb  ),
		  //// Response    
		  .m_axi_bvalid  (axi_bvalid ),
		  .m_axi_bready  (axi_bready ),
		  //// Address-Read
		  .m_axi_arvalid (axi_arvalid),
		  .m_axi_arready (axi_arready),
		  .m_axi_araddr  (axi_araddr ),
		  .m_axi_arlen   (axi_arlen),
		  .m_axi_arburst (axi_arburst),
		  .m_axi_arsize  (axi_arsize),
		  //// Data-Read   
		  .m_axi_rvalid  (axi_rvalid ),
		  .m_axi_rready  (axi_rready ),
		  .m_axi_rdata   (axi_rdata  ),
		  .m_axi_rlast   (axi_rlast),
`endif		  
		  .trap              (trap)
		  );


`ifdef USE_DDR   
   ddr4_0 ddr4_ram (
                    .c0_sys_clk_p        (C0_SYS_CLK_clk_p),
                    .c0_sys_clk_n        (C0_SYS_CLK_clk_n),
                    .c0_ddr4_ui_clk      (clk),    // 200MHz - MIG's clock
		    //.c0_sys_clk_i      (clk), 
                    .addn_ui_clkout1     (sysclk), // 100MHz - System's clock
                    .c0_init_calib_complete (init_calib_complete),                  
                    .c0_ddr4_aresetn       (~reset_int),
     		    .c0_ddr4_s_axi_awvalid (ddr_awvalid),
		    .c0_ddr4_s_axi_awready (ddr_awready),
		    .c0_ddr4_s_axi_awaddr  (ddr_awaddr[29:0]),
		    .c0_ddr4_s_axi_awcache (4'b0011), //recommended value
		    //// Data-Write  
		    .c0_ddr4_s_axi_wvalid  (ddr_wvalid ),
		    .c0_ddr4_s_axi_wready  (ddr_wready ),
		    .c0_ddr4_s_axi_wdata   (ddr_wdata  ),
		    .c0_ddr4_s_axi_wstrb   (ddr_wstrb  ),
		    //// Response   
		    .c0_ddr4_s_axi_bvalid  (ddr_bvalid ),
		    .c0_ddr4_s_axi_bready  (ddr_bready ),
		    //// Address-Read
		    .c0_ddr4_s_axi_arvalid (ddr_arvalid),
		    .c0_ddr4_s_axi_arready (ddr_arready),
		    .c0_ddr4_s_axi_araddr  (ddr_araddr[29:0]),
		    .c0_ddr4_s_axi_arcache (4'b0011), //recommended value
		    //// Data-Read   
		    .c0_ddr4_s_axi_rvalid  (ddr_rvalid ),
		    .c0_ddr4_s_axi_rready  (ddr_rready ),
		    .c0_ddr4_s_axi_rdata   (ddr_rdata  ),
		    ///////// AXI_Full signals
		    //// Read         
		    .c0_ddr4_s_axi_arlen   (ddr_arlen  ), 
		    .c0_ddr4_s_axi_arsize  (ddr_arsize ),    
                    .c0_ddr4_s_axi_arburst (ddr_arburst),
                    .c0_ddr4_s_axi_rlast   (ddr_rlast  ),
                    // Write        
                    .c0_ddr4_s_axi_awlen   (8'd0            ),
                    .c0_ddr4_s_axi_awsize  (3'b010          ),
                    .c0_ddr4_s_axi_awburst (2'b00           ),
                    .c0_ddr4_s_axi_wlast   (|ddr_wstrb ),
                    .c0_ddr4_s_axi_bresp   (ddr_bresp  ),
                    //unused 
                    .c0_ddr4_s_axi_awlock                (1'b0),
                    .c0_ddr4_s_axi_awqos                 (4'b0),
                    .c0_ddr4_s_axi_arlock                (1'b0),
                    .c0_ddr4_s_axi_arprot                (3'b0),
                    .c0_ddr4_s_axi_arqos                 (4'b0),
                    // Constraints of the DDR4 
                    .sys_rst             (sys_rst),
                    .c0_ddr4_act_n       (c0_ddr4_act_n),
                    .c0_ddr4_adr         (c0_ddr4_adr),
                    .c0_ddr4_ba          (c0_ddr4_ba),
                    .c0_ddr4_bg          (c0_ddr4_bg),
                    .c0_ddr4_cke         (c0_ddr4_cke),
                    .c0_ddr4_odt         (c0_ddr4_odt),
                    .c0_ddr4_cs_n        (c0_ddr4_cs_n),
                    .c0_ddr4_ck_t        (c0_ddr4_ck_t),
                    .c0_ddr4_ck_c        (c0_ddr4_ck_c),
                    .c0_ddr4_reset_n     (c0_ddr4_reset_n),
                    .c0_ddr4_dm_dbi_n    (c0_ddr4_dm_dbi_n),
                    .c0_ddr4_dq          (c0_ddr4_dq),
                    .c0_ddr4_dqs_c       (c0_ddr4_dqs_c),
                    .c0_ddr4_dqs_t       (c0_ddr4_dqs_t)
                    );   
   
   axi_interconnect_0 cache2ddr (
				 .INTERCONNECT_ACLK     (clk), // 200 MHz
				 .INTERCONNECT_ARESETN  (~reset_int),
      
				 ///////////////
				 // DDR SIDE //
				 /////////////
				 .M00_AXI_ARESET_OUT_N  (),
				 .M00_AXI_ACLK          (clk), // 200 MHz
      
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
				 .M00_AXI_RREADY       (ddr_rready),
      
      
				 //////////////////
				 // System Side //
				 ////////////////
				 .S00_AXI_ARESET_OUT_N (),
				 .S00_AXI_ACLK         (sysclk), // 100 MHz

				 //Write address
				 .S00_AXI_AWID         (),
				 .S00_AXI_AWADDR       (axi_awaddr),
				 .S00_AXI_AWLEN        (8'd0),
				 .S00_AXI_AWSIZE       (3'b010),
				 .S00_AXI_AWBURST      (2'b00),
				 .S00_AXI_AWLOCK       (1'b0),
				 .S00_AXI_AWCACHE      (4'b0011),
				 .S00_AXI_AWPROT       (),
				 .S00_AXI_AWQOS        (),
				 .S00_AXI_AWVALID      (axi_awvalid),
				 .S00_AXI_AWREADY      (axi_awready),

				 //Write data
				 .S00_AXI_WDATA        (axi_wdata),
				 .S00_AXI_WSTRB        (axi_wstrb),
				 .S00_AXI_WLAST        (|axi_wstrb),
				 .S00_AXI_WVALID       (axi_wvalid),
				 .S00_AXI_WREADY       (axi_wready),
      
				 //Write response
				 .S00_AXI_BID           (),
				 .S00_AXI_BRESP         (),
				 .S00_AXI_BVALID        (axi_bvalid),
				 .S00_AXI_BREADY        (axi_bready),
      
				 //Read address
				 .S00_AXI_ARID         (),
				 .S00_AXI_ARADDR       (axi_araddr),
				 .S00_AXI_ARLEN        (axi_arlen),
				 .S00_AXI_ARSIZE       (axi_arsize),
				 .S00_AXI_ARBURST      (axi_arburst),
				 .S00_AXI_ARLOCK       (1'b0),
				 .S00_AXI_ARCACHE      (4'b0011),
				 .S00_AXI_ARPROT       (3'b0),
				 .S00_AXI_ARQOS        (4'b0),
				 .S00_AXI_ARVALID      (axi_arvalid),
				 .S00_AXI_ARREADY      (axi_arready),
      
				 //Read data
				 .S00_AXI_RID          (),
				 .S00_AXI_RDATA        (axi_rdata),
				 .S00_AXI_RRESP        (),
				 .S00_AXI_RLAST        (axi_rlast),
				 .S00_AXI_RVALID       (axi_rvalid),
				 .S00_AXI_RREADY       (axi_rready)
				 );
`endif
endmodule
