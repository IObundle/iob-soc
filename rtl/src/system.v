`timescale 1 ns / 1 ps

`include "system.vh"

module system (
               input              clk,
               input              reset,
               output             uart_txd,
               input              uart_rxd,
               output             trap
`ifdef DDR //AXI MASTER INTERFACE
               // Address-Write
               , output m_axi_awvalid,
               input              m_axi_awready,
               output [`ADDR_W:0] m_axi_awaddr,
    /// Data-Write
               output             m_axi_wvalid,
               input              m_axi_wready,
               output [`DATA_W:0] m_axi_wdata,
               output [ 3:0]      m_axi_wstrb,
    /// Write-Response
               input              m_axi_bvalid,
               output             m_axi_bready,
    /// Address-Read
               output             m_axi_arvalid,
               input              m_axi_arready,
               output [`ADDR_W:0] m_axi_araddr,
               output [7:0]       m_axi_arlen,
               output [2:0]       m_axi_arsize,
               output [1:0]       m_axi_arburst,
    /// Data-Read
               input              m_axi_rvalid,
               output             m_axi_rready,
               input [`DATA_W:0]  m_axi_rdata,
               input              m_axi_rlast
`endif
               );

   //
   // RESET
   //
   wire                           reset_int = reset | soft_reset;
   reg                            choose_rom;   

   
   //
   //  CPU
   //
   wire [`ADDR_W:0]               m_addr;
   wire [`DATA_W:0]               m_wdata;
   wire [3:0]                     m_wstrb;
   wire [`DATA_W:0]               m_rdata;
   wire                           m_valid;
   wire                           m_ready;
   wire                           m_instr;
  
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
   
   wire [`DATA_W-1:0]             s_rdata[N_SLAVES-1:0];
   reg [N_SLAVES*`DATA_W-1:0]     s_rdata_concat;
   wire [N_SLAVES-1:0]            s_valid;
   wire [N_SLAVES-1:0]            s_ready;
   
   //choose program memory according to reset condition
   assign s_rdata[0] = choose_rom? 
                       boot_read_data: 
`ifdef USE_DDR
                       cache_read_data;
`else
                       main_mem_read_data;
`endif

      
   //concatenate slave read data signals to input in interconnect
   always @* begin
      int i;   
      for(i=0; i<N_SLAVES; i=i+1)
	 s_rdata_concat[((i+1)*`DATA_W)-1 -: `DATA_W] =s_rdata[i];
   end
   

   iob_generic_interconnect 
     generic_interconnect (
			   // master interface
			   .m_addr  (m_addr[`ADDR_W-1 -: N_SLAVES_W]),
			   .m_rdata (m_rdata),
			   .m_valid (m_valid),
			   .m_ready (m_ready),

                           // slaves interface
			   .s_rdata (s_rdata_concat),
			   .s_valid (s_valid),
			   .s_ready (s_ready)
			   );

    
   //
   // BOOT ROM
   //

   boot_memory  #(
	          .ADDR_W(`ROM_ADDR_W)
	          )
   boot_memory (
		.clk                (clk ),
		.boot_write_data    (s_wdata[0][`DATA_W-1:0]),
		.boot_addr          (s_addr[0][`BOOT_ADDR_W-1:0]),
		.boot_en            (s_wstrb[0][STRB_W-1:0]),
		.boot_read_data     (s_rdata[0][`DATA_W-1:0])
		);


   //
   // MAIN MEMORY
   //

`ifdef USE_DDR
   memory_cache cache (
		       .clk                (clk),
		       .reset              (reset),

                       //data interface 
		       .cache_write_data   (s_wdata[`MAIN_MEM_BASE][`DATA_W-1:0]),
		       .cache_addr         (s_addr[`MAIN_MEM_BASE][`CACHE_ADDR_W-1:0]),
		       .cache_wstrb        (s_wstrb[`MAIN_MEM_BASE][STRB_W-1:0]),
		       .cache_read_data    (s_rdata[`MAIN_MEM_BASE][`DATA_W-1:0]),
		       .cpu_req            (s_valid[`MAIN_MEM_BASE]),
		       .cache_ack          (s_ready[`MAIN_MEM_BASE]),

                       //control interface
		       .cache_controller_address (s_addr[`CACHE_CTRL_BASE][5:2]),
		       .cache_controller_requested_data (s_rdata[`CACHE_CTRLL_BASE][`DATA_W-1:0]),
		       .cache_controller_cpu_request (s_valid[`CACHE_CTRLL_BASE]),
		       .cache_controller_acknowledge (s_ready[`CACHE_CTRLL_BASE]),
		       .cache_controller_instr_access(m_instr), //instruction signal from master (processor)

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

   //cache controller responds in next cycle
   reg                     cache_ctr_ready;
   assign s_ready[`CACHE_CTRL_BASE] = cache_ctr_ready;

   always @(posedge clk)
     cache_ctr_ready <= s_valid[`CACHE_CTRL_BASE];


`else
   //ROM/RAM respond in next cycle
   reg                     mem_ready;
   assign s_ready[0] = mem_ready;

   always @(posedge clk)
     mem_ready <= s_valid[0];
`endif

`ifdef USE_RAM
   main_memory  #(
		  .ADDR_W(`MEM_ADDR_W)
		  ) 
   main_memory (
		.clk                   (clk),
		.main_mem_write_data   (s_wdata[1][`DATA_W-1:0]),
		.main_mem_addr         (s_addr[1][`MEM_ADDR_W-1:0]),
		.main_mem_en           (s_wstrb[1][STRB_W-1:0]),
		.main_mem_read_data    (s_rdata[1][`DATA_W-1:0])
		);
`endif
 
   //
   // UART
   //
   iob_uart uart(
		 //cpu interface
		 .clk       (clk),
		 .rst       (~resetn_int),
                 
		 //cpu i/f
		 .address   (s_addr[`UART][4:2]),
		 .sel       (s_valid[`UART]),
		 .read      (~(|s_wstrb[`UART][STRB_W-1:0])),
		 .write     (|s_wstrb[`UART][STRB_W-1:0]),
                 
		 .data_in   (s_wdata[`UART][`DATA_W-1:0]),
		 .data_out  (s_rdata[`UART][`DATA_W-1:0]),
                 
		 //serial i/f
		 .txd       (uart_txd),
		 .rxd       (uart_rxd),
                 .rts       (uart_rts),
                 .cts       (uart_cts)
		 );
   
   //UART responds in next cycle
   reg                     uart_ready;
   assign s_ready[`UART_BASE] = uart_ready;
   
   always @(posedge clk) begin
      uart_ready <= s_valid[`UART_BASE];
   end


   //
   // RESET CONTROLLER
   //
   always @(posedge clk, posedge reset)
     if(reset)  begin
        choose_rom <= 1'b1;
        soft_reset <= 1'b0;
     end else if(s_sel[`SOFT_RESET_ADDR]) && m_wstrb) begin
        soft_reset <= 1'b1;
        choose_rom <= 1'b0;
     end else
       soft_reset <= 1'b0;
   
endmodule
