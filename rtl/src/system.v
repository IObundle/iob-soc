`timescale 1 ns / 1 ps
`include "system.vh"
`include "int_mem.vh"

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
   reg [`DATA_W-1:0]                m_rdata;
   wire                             m_valid;
   reg                              m_ready;
   wire                             m_instr;

   wire                             la_read, la_write;
   wire [3:0]                       la_wstrb;

   wire                             int_mem_busy;
   
   
   picorv32 #(
              //.ENABLE_PCPI(1), //enables the following 2 parameters
	      .BARREL_SHIFTER(1),
	      .ENABLE_FAST_MUL(1),
	      .ENABLE_DIV(1)
	      )
   picorv32_core (
		  .clk           (clk),
		  .resetn        (~reset_int & ~int_mem_busy),
		  .trap          (trap),
		  //memory interface
		  .mem_instr     (m_instr),
		  .mem_rdata     (m_rdata),
`ifndef USE_LA_IF
		  .mem_valid     (m_valid),
		  .mem_addr      (m_addr),
		  .mem_wdata     (m_wdata),
		  .mem_wstrb     (m_wstrb),
`else
                  .mem_la_read   (la_read),
                  .mem_la_write  (la_write),                  
                  .mem_la_addr   (m_addr),
                  .mem_la_wdata  (m_wdata),
                  .mem_la_wstrb  (la_wstrb),
`endif
		  .mem_ready     (m_ready)
                  // Pico Co-Processor PCPI
                  /*                  .pcpi_valid    (),
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
                   */		  
                  );

`ifdef USE_LA_IF
   assign m_valid = la_read | la_write;
   assign m_wstrb = la_wstrb & {4{la_write}};
`endif
   
   //select memory  according to addr msb, boot status and ddr use

   reg                              int_mem_valid;
   reg                              int_mem_ready;
   reg [`DATA_W-1:0]                int_mem_rdata;
   
   reg                              ext_mem_valid;
   reg                              ext_mem_ready;
   reg [`DATA_W-1:0]                ext_mem_rdata;
   
   reg                              p_valid;
   reg                              p_ready;
   reg [`DATA_W-1:0]                p_rdata;
   
   wire                             boot;
   
   always @* begin
      //assume internal memory is being addressed
      int_mem_valid = m_valid;
      ext_mem_valid = 1'b0;
      p_valid = 1'b0;

      m_rdata = int_mem_rdata;
      m_ready = int_mem_ready;

      if(m_addr[`ADDR_W-1]) begin
         //peripherals are being addressed
         p_valid = m_valid;
         int_mem_valid = 1'b0;
         m_rdata = p_rdata;
         m_ready = p_ready;
      end
`ifdef USE_DDR
      //ddr is being addressed
      else if(!boot) begin
         ext_mem_valid = m_valid;
         int_mem_valid = 1'b0;
         m_rdata = ext_mem_rdata;
         m_ready = ext_mem_ready;
      end
`endif
   end
   
   
   //
   // INTERNAL SRAM MEMORY
   //
   
   int_mem int_mem0 (
	             .clk                (clk ),
                     .rst                (reset_int),
                     .busy               (int_mem_busy),
                     .boot               (boot),
      
                     //cpu interface
	             .addr               (m_addr[`BOOTRAM_ADDR_W-1:2]),
                     .rdata              (int_mem_rdata),
	             .wdata              (m_wdata),
	             .wstrb              (m_wstrb),
                     .valid              (int_mem_valid | s_valid[`SRAM_BASE]),
                     .ready              (int_mem_ready)
	             );
   
   assign s_ready[`SRAM_BASE] = int_mem_ready;
   assign s_rdata[`SRAM_BASE] = int_mem_rdata;

   
   //
   // EXTERNAL DDR MAIN MEMORY
   //

`ifdef USE_DDR
   iob_cache #(
               .ADDR_W(`MAINRAM_ADDR_W),
               .DATA_W(`DATA_W)
               )
   cache (
	  .clk (clk),
	  .reset (reset_int),

          //data interface 
	  .wdata (m_wdata),
	  .addr  (m_addr[`MAINRAM_ADDR_W : 2]),
	  .wstrb (m_wstrb),
	  .rdata (ext_mem_rdata),
	  .valid (ext_mem_valid | s_valid[`DDR_BASE]),
	  .ready (ext_mem_ready),
	  .instr (m_instr),

          //
	  // AXI MASTER INTERFACE TO MAIN MEMORY
          //

          //address write
          .AW_ID(m_axi_awid), 
          .AW_ADDR(m_axi_awaddr[`MAINRAM_ADDR_W-1:0]), 
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
          .AR_ADDR(m_axi_araddr[`MAINRAM_ADDR_W-1:0]), 
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

   assign m_axi_araddr[`ADDR_W-1:`MAINRAM_ADDR_W] = {(`ADDR_W-`MAINRAM_ADDR_W){1'b0}};
   assign m_axi_awaddr[`ADDR_W-1:`MAINRAM_ADDR_W] = {(`ADDR_W-`MAINRAM_ADDR_W){1'b0}};

   assign s_ready[`DDR_BASE] = ext_mem_ready;
   assign s_rdata[`DDR_BASE] = ext_mem_rdata;
   
`endif



   //
   // PERIPHERALS
   //

   
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



   iob_interconnect intercon
     (
      // master interface
      .m_addr  (m_addr[`ADDR_W-2 -: `N_SLAVES_W]),
      .m_rdata (p_rdata),
      .m_valid (p_valid),
      .m_ready (p_ready),
      
      // slaves interface
      .s_rdata (s_rdata_concat),
      .s_valid (s_valid),
      .s_ready (s_ready)
      );

   

   //
   // UART
   //
   iob_uart uart(
		 //cpu interface
		 .clk       (clk),
		 .rst       (reset_int),
                 
		 //cpu i/f
		 .valid     (s_valid[`UART_BASE]),
		 .ready     (s_ready[`UART_BASE]),
		 .address   (m_addr[4:2]),
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
   // RESET CONTROLLER
   //
   rst_ctr rst_ctr0 (
                     .clk(clk),
                     .rst(reset),
                     .soft_rst(soft_reset),
                     .boot(boot),
      
                     .wdata(m_wdata[0]),
                     .write(m_wstrb != 4'd0),
                     .rdata(s_rdata[`SOFT_RESET_BASE]),
                     .valid(s_valid[`SOFT_RESET_BASE]),
                     .ready(s_ready[`SOFT_RESET_BASE])
                     );
   

endmodule
