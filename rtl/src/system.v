`timescale 1 ns / 1 ps

`include "system.vh"

module system (
               input 		    clk,
               input 		    reset,
               output 		    trap,

               //UART
               output 		    uart_txd,
               input 		    uart_rxd,
               output 		    uart_rts,
               input 		    uart_cts
	       
`ifdef USE_DDR //AXI MASTER INTERFACE
	       // Address-Write
	       , output m_axi_awvalid,
               input 		    m_axi_awready,
               output [`ADDR_W-1:0] m_axi_awaddr,
               /// Data-Write
               output 		    m_axi_wvalid,
               input 		    m_axi_wready,
               output [`DATA_W-1:0] m_axi_wdata,
               output [ 3:0] 	    m_axi_wstrb,
               // Write-Response
               input 		    m_axi_bvalid,
               output 		    m_axi_bready,
               // Address-Read
               output 		    m_axi_arvalid,
               input 		    m_axi_arready,
               output [`ADDR_W-1:0] m_axi_araddr,
               output [7:0] 	    m_axi_arlen,
               output [2:0] 	    m_axi_arsize,
               output [1:0] 	    m_axi_arburst,
               // Data-Read
               input 		    m_axi_rvalid,
               output 		    m_axi_rready,
               input [`DATA_W-1:0]  m_axi_rdata,
               input 		    m_axi_rlast
`endif
               );

   //
   // RESET
   //
   reg 				    soft_reset;   
   wire 			    reset_int = reset | soft_reset;
   reg 				    boot ;   
   
   //
   //  CPU
   //
   wire [`ADDR_W-1:0] 		    m_addr;
   wire [`DATA_W-1:0] 		    m_wdata;
   wire [3:0] 			    m_wstrb;
   wire [`DATA_W-1:0] 		    m_rdata;
   wire 			    m_valid;
   wire 			    m_ready;
   wire 			    m_instr;
   
   picorv32 #(
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
		  .mem_addr      (m_addr ),
		  .mem_wdata     (m_wdata),
		  .mem_wstrb     (m_wstrb),
		  .mem_rdata     (m_rdata)
		  );


   //
   // INTERCONNECT
   //
   
   wire [`DATA_W-1:0] 		    s_rdata[`N_SLAVES-1:0];
   reg [`N_SLAVES*`DATA_W-1:0] 	    s_rdata_concat;
   wire [`N_SLAVES-1:0] 	    s_valid;
   wire [`N_SLAVES-1:0] 	    s_ready;
   

   
   //choose program memory according to reset condition
   reg [`N_SLAVES_W-1 : 0] 	    m_addr_int;

   always @*
     if (!boot && !m_addr[`DATA_W-1 -: `N_SLAVES_W])
				    `ifdef USE_DDR
       m_addr_int = `N_SLAVES_W'd`CACHE_BASE;
				    `else
   m_addr_int = `N_SLAVES_W'd`RAM_BASE;
				    `endif
     else
       m_addr_int = m_addr[`ADDR_W-1 -:`N_SLAVES_W];


   
   //concatenate slave read data signals to input in interconnect
   always @* begin : concat_slave_reads
      integer i;
      for(i=0; i<`N_SLAVES; i=i+1)
	s_rdata_concat[((i+1)*`DATA_W)-1 -: `DATA_W] =s_rdata[i];
   end
   

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
   // BOOT RAM
   //

   ram  #(
	  .ADDR_W(`BOOT_ADDR_W-2),
          .NAME("boot")
	  )
   boot_mem (
	     .clk           (clk ),
             .rst           (reset),
	     .wdata         (m_wdata),
	     .addr          (m_addr[`BOOT_ADDR_W-1:2]),
	     .wstrb         (m_wstrb),
	     .rdata         (s_rdata[`BOOT_BASE]),
             .valid         (s_valid[`BOOT_BASE]),
             .ready         (s_ready[`BOOT_BASE])
	     );


   //
   // UART
   //
   iob_uart uart(
		 //cpu interface
		 .clk       (clk),
		 .rst       (reset),
                 
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
   // RESET CONTROLLER
   //
   reg        rst_ctrl_rdy;
   always @(posedge clk, posedge reset)
     if(reset)  begin
        boot <= 1'b1;
        soft_reset <= 1'b0;
        rst_ctrl_rdy <= 1'b0;
     end else if( s_valid[`SOFT_RESET_BASE] && m_wstrb ) begin
        soft_reset <= m_wdata[0];
        boot <=  m_wdata[1];
        rst_ctrl_rdy <= 1'b1;
     end else begin
        soft_reset <= 1'b0;
        rst_ctrl_rdy <= 1'b0;
     end 
   assign s_ready[`SOFT_RESET_BASE] = rst_ctrl_rdy;
   assign s_rdata[`SOFT_RESET_BASE] = 0;
   

   //
   // MAIN MEMORY
   //

				    `ifdef USE_DDR
   memory_cache cache (
		       .clk                (clk),
		       .reset              (reset),
                       //data interface 
		       .cache_write_data   (m_wdata),
		       .cache_addr         ({{`N_SLAVES_W{1'b0}},m_addr[`ADDR_W - `N_SLAVES_W-1:0]}),
		       .cache_wstrb        (m_wstrb),
		       .cache_read_data    (s_rdata[`CACHE_BASE]),
		       .cpu_req            (s_valid[`CACHE_BASE]),
		       .cache_ack          (s_ready[`CACHE_BASE]),

                       //control interface
		       .cache_ctrl_address (m_addr[5:2]),
		       .cache_ctrl_requested_data (s_rdata[`CACHE_CTRL_BASE]),
		       .cache_ctrl_cpu_request (s_valid[`CACHE_CTRL_BASE]),
		       .cache_ctrl_acknowledge (s_ready[`CACHE_CTRL_BASE]),
		       .cache_ctrl_instr_access(m_instr),

                       //
		       // AXI MASTER INTERFACE TO MAIN MEMORY
                       //
		       // Address Read
		       .AR_ADDR            (m_axi_araddr),
		       .AR_LEN             (m_axi_arlen),
		       .AR_SIZE            (m_axi_arsize),
		       .AR_BURST           (m_axi_arburst),
		       .AR_VALID           (m_axi_arvalid),
		       .AR_READY           (m_axi_arready),

                       //Data Read
		       .R_VALID            (m_axi_rvalid),
		       .R_READY            (m_axi_rready),
		       .R_DATA             (m_axi_rdata),
		       .R_LAST             (m_axi_rlast),

		       // Address Write
		       .AW_ADDR            (m_axi_awaddr),
		       .AW_VALID           (m_axi_awvalid),
		       .AW_READY           (m_axi_awready),

                       // Data Write
		       .W_VALID            (m_axi_wvalid),
		       .W_STRB             (m_axi_wstrb),
		       .W_READY            (m_axi_wready),
		       .W_DATA             (m_axi_wdata),
		       .B_VALID            (m_axi_bvalid),
		       .B_READY            (m_axi_bready)
		       );
				    `endif

				    `ifdef USE_RAM
   ram  #(
	  .ADDR_W(`RAM_ADDR_W-2),
          .NAME("firmware")
	  ) 
   ram (
	.clk          (clk),
        .rst          (reset),
	.wdata        (m_wdata[`DATA_W-1:0]),
	.addr         (m_addr[`RAM_ADDR_W-1:2]),
	.wstrb        (m_wstrb),
	.rdata        (s_rdata[`RAM_BASE]),
        .valid        (s_valid[`RAM_BASE]),
        .ready        (s_ready[`RAM_BASE])
	);
				    `endif
   

   
endmodule
