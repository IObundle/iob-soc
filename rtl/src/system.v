`timescale 1 ns / 1 ps

`include "system.vh"

module system (
               input                clk,
               input                reset,
               output               trap,

`ifdef USE_DDR //AXI MASTER INTERFACE

               //address write
               output [0:0]         m_axi_awid, 
               output [`ADDR_W-1:0] m_axi_awaddr,
               output [7:0]         m_axi_awlen,
               output [2:0]         m_axi_awsize,
               output [1:0]         m_axi_awburst,
               output [0:0]         m_axi_awlock,
               output [3:0]         m_axi_awcache,
               output [2:0]         m_axi_awprot,
               output [3:0]         m_axi_awqos,
               output               m_axi_awvalid,
               input                m_axi_awready,

               //write
               output [`DATA_W-1:0] m_axi_wdata,
               output [3:0]         m_axi_wstrb,
               output               m_axi_wlast,
               output               m_axi_wvalid, 
               input                m_axi_wready,

               //write response
               input [0:0]          m_axi_bid,
               input [1:0]          m_axi_bresp,
               input                m_axi_bvalid,
               output               m_axi_bready,

               //address read
               output [0:0]         m_axi_arid,
               output [`ADDR_W-1:0] m_axi_araddr, 
               output [7:0]         m_axi_arlen,
               output [2:0]         m_axi_arsize,
               output [1:0]         m_axi_arburst,
               output [0:0]         m_axi_arlock,
               output [3:0]         m_axi_arcache,
               output [2:0]         m_axi_arprot,
               output [3:0]         m_axi_arqos,
               output               m_axi_arvalid, 
               input                m_axi_arready,

               //read
               input [0:0]          m_axi_rid,
               input [`DATA_W-1:0]  m_axi_rdata,
               input [1:0]          m_axi_rresp,
               input                m_axi_rlast, 
               input                m_axi_rvalid, 
               output               m_axi_rready,
`endif
               //UART
               output               uart_txd,
               input                uart_rxd,
               output               uart_rts,
               input                uart_cts
               );

   //
   // RESET
   //
   wire                             soft_reset;   
   wire                             reset_int = reset | soft_reset;
   
   //
   //  CPU
   //
   wire [`ADDR_W-1:0]               m_addr;
   wire [`DATA_W-1:0]               m_wdata;
   wire [3:0]                       m_wstrb;
   wire [`DATA_W-1:0]               m_rdata;
   wire                             m_valid;
   wire                             m_ready;
   wire                             m_instr;
   
   picorv32 #(
              .ENABLE_PCPI(1), //enables the following 2 parameters
	      .ENABLE_FAST_MUL(1),
	      .ENABLE_DIV(1)
	      )
   picorv32_core (
		  .clk           (clk),
		  .resetn        (~reset_int),
		  .trap          (trap),
		  //memory interface
		  .mem_valid     (m_valid),
		  .mem_instr     (m_instr),
		  .mem_ready     (m_ready),
		  .mem_addr      (m_addr),
		  .mem_wdata     (m_wdata),
		  .mem_wstrb     (m_wstrb),
		  .mem_rdata     (m_rdata),
                  // Look-Ahead
                  .mem_la_read   (),
                  .mem_la_write  (),
                  .mem_la_addr   (),
                  .mem_la_wdata  (),
                  .mem_la_wstrb  (),
                  // Pico Co-Processor PCPI
                  .pcpi_valid    (),
                  .pcpi_insn     (),
                  .pcpi_rs1      (),
                  .pcpi_rs2      (),
                  .pcpi_wr       (1'b0),
                  .pcpi_rd       (32'd0),
                  .pcpi_wait     (1'b0),
                  .pcpi_ready    (1'b0),
                  // IRQ
                  .irq           (32'd0),
                  .eoi           (),
                  .trace_valid   (),
                  .trace_data    ()
		  );

   //
   //ADDRESS PREFIX TRANSLATOR
   //
   //choose main memory according to boot status
   reg [`N_SLAVES_W-1 : 0]          m_addr_int;
   reg                              boot ;   

   always @*
     //if main memory is being addressed and system not booting
     if (!m_addr[`ADDR_W-1 -: `N_SLAVES_W] && !boot)
       //if DDR being used point to cache
`ifdef USE_DDR
       m_addr_int = `N_SLAVES_W'd`CACHE_BASE;
`else
       //if DDR  not being used point to RAM
       m_addr_int = `N_SLAVES_W'd`MAINRAM_BASE;
`endif
     else
       //do not modify address prefix 
       m_addr_int = m_addr[`ADDR_W-1 -:`N_SLAVES_W];

   
   //
   // INTERCONNECT
   //
   
   wire [`DATA_W-1:0]                     s_rdata[`N_SLAVES-1:0];
   wire [`N_SLAVES*`DATA_W-1:0]           s_rdata_concat;
   wire [`N_SLAVES-1:0]                   s_valid;
   wire [`N_SLAVES-1:0]                   s_ready;
   
   //concatenate slave read data signals to input in interconnect
   genvar                                 i;
   generate 
         for(i=0; i<`N_SLAVES; i=i+1)
           begin : rdata_concat
	      assign s_rdata_concat[((i+1)*`DATA_W)-1 -: `DATA_W] = s_rdata[i];
           end
   endgenerate

   iob_generic_interconnect 
     #(.N_SLAVES(`N_SLAVES),
       .N_SLAVES_W(`N_SLAVES_W)
       )
   generic_interconnect
     (
      // master interface
      .m_addr  (m_addr_int),
      .m_rdata (m_rdata),
      .m_valid (m_valid),
      .m_ready (m_ready),
      
      // slaves interface
      .s_rdata (s_rdata_concat),
      .s_valid (s_valid),
      .s_ready (s_ready)
      );

   
   //
   // INTERNAL MEMORY SUBSYSTEM
   //

   int_mem int_mem0 (
	             .clk                (clk ),
                     .rst                (reset_int),
                     
                     //boot mem interface
	             .boot_rdata         (s_rdata[`BOOT_BASE]),
                     .boot_valid         (s_valid[`BOOT_BASE]),
                     .boot_ready         (s_ready[`BOOT_BASE]),

                     //main mem interface
	             .main_rdata         (s_rdata[`MAINRAM_BASE]),
                     .main_valid         (s_valid[`MAINRAM_BASE]),
                     .main_ready         (s_ready[`MAINRAM_BASE]),

                     //common
	             .addr               (m_addr[`MAINRAM_ADDR_W-1:2]),
	             .wdata              (m_wdata),
	             .wstrb              (m_wstrb)
	             );
   

   //
   // UART
   //
   iob_uart uart(
		 //cpu interface
		 .clk       (clk),
		 .rst       (reset_int),
                 
		 //cpu i/f
		 .sel       (s_valid[`UART_BASE]),
		 .ready     (s_ready[`UART_BASE]),
		 .address   (m_addr[4:2]),
		 .read      (m_wstrb == 0),
		 .write     (m_wstrb != 0),
                 
		 .data_in   (m_wdata),
		 .data_out  (s_rdata[`UART_BASE]),
                 
		 //serial i/f
		 .txd       (uart_txd),
		 .rxd       (uart_rxd),
                 .rts       (uart_rts),
                 .cts       (uart_cts)
		 );
   
   //
   // RESTART CONTROLLER
   //
   reg        rst_ctrl_rdy;
   reg [15:0] soft_reset_cnt;
   
   always @(posedge clk, posedge reset)
     if(reset) begin
`ifdef USE_BOOT
        boot <= 1'b1;
`else
        boot <= 1'b0;        
`endif
        soft_reset_cnt <= 16'h0;
        rst_ctrl_rdy <= 1'b0;
     end else if( s_valid[`SOFT_RESET_BASE] && m_wstrb ) begin
        soft_reset_cnt <= 16'hFFFF;
        boot <=  m_wdata[0];
        rst_ctrl_rdy <= 1'b1;
     end else if (soft_reset_cnt) begin
        soft_reset_cnt <= soft_reset_cnt - 1'b1;
        rst_ctrl_rdy <= 1'b0;
     end

   assign soft_reset = (soft_reset_cnt != 16'h0); 
   assign s_ready[`SOFT_RESET_BASE] = rst_ctrl_rdy;
   assign s_rdata[`SOFT_RESET_BASE] = 0;
   

   //
   // DDR MAIN MEMORY
   //

`ifdef USE_DDR
   iob_cache #(
               .ADDR_W(`ADDR_W),
               .DATA_W(`DATA_W)
               )
   cache (
	  .clk                (clk),
	  .reset              (reset_int),

          //data interface 
	  .cache_write_data   (m_wdata),
	  .cache_addr         ({{`N_SLAVES_W{1'b0}},m_addr[`ADDR_W-`N_SLAVES_W-1:2]}),
	  .cache_wstrb        (m_wstrb),
	  .cache_read_data    (s_rdata[`CACHE_BASE]),
	  .cpu_req            (s_valid[`CACHE_BASE]),
	  .cache_ack          (s_ready[`CACHE_BASE]),

          //control interface
	  .cache_ctrl_address (m_addr[6:2]),
	  .cache_ctrl_requested_data (s_rdata[`CACHE_CTRL_BASE]),
	  .cache_ctrl_cpu_request (s_valid[`CACHE_CTRL_BASE]),
	  .cache_ctrl_acknowledge (s_ready[`CACHE_CTRL_BASE]),
	  .cache_ctrl_instr_access(m_instr),

          //
	  // AXI MASTER INTERFACE TO MAIN MEMORY
          //

          //address write
          .AW_ID(m_axi_awid), 
          .AW_ADDR(m_axi_awaddr), 
          .AW_LEN(m_axi_awlen), 
          .AW_SIZE(m_axi_awsize), 
          .AW_BURST(m_axi_awburst), 
          .AW_LOCK(m_axi_awlock), 
          .AW_CACHE(m_axi_awcache), 
          .AW_PROT(m_axi_awprot),
          .AW_QOS(m_axi_awqos), 
          .AW_VALID(m_axi_awvalid), 
          .AW_READY(m_axi_awready), 

          //write
          .W_DATA(m_axi_wdata), 
          .W_STRB(m_axi_wstrb), 
          .W_LAST(m_axi_wlast), 
          .W_VALID(m_axi_wvalid), 
          .W_READY(m_axi_wready), 

          //write response
          .B_ID(m_axi_bid), 
          .B_RESP(m_axi_bresp), 
          .B_VALID(m_axi_bvalid), 
          .B_READY(m_axi_bready), 

          //address read
          .AR_ID(m_axi_arid), 
          .AR_ADDR(m_axi_araddr), 
          .AR_LEN(m_axi_arlen), 
          .AR_SIZE(m_axi_arsize), 
          .AR_BURST(m_axi_arburst), 
          .AR_LOCK(m_axi_arlock), 
          .AR_CACHE(m_axi_arcache), 
          .AR_PROT(m_axi_arprot), 
          .AR_QOS(m_axi_arqos), 
          .AR_VALID(m_axi_arvalid), 
          .AR_READY(m_axi_arready), 

          //read 
          .R_ID(m_axi_rid), 
          .R_DATA(m_axi_rdata), 
          .R_RESP(m_axi_rresp), 
          .R_LAST(m_axi_rlast), 
          .R_VALID(m_axi_rvalid),  
          .R_READY(m_axi_rready)  
	  );
`endif

endmodule
