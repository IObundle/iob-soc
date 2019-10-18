`timescale 1 ns / 1 ps

`include "system.vh"

module system #(

   		parameter SOFT_RESET_ADDR = 32'h6ffffffc,
   		parameter MAIN_MEM_ADDR_W = 14, // 14 = 32 bits (4) * 2**12 (4096) depth
   		parameter BOOT_ADDR_W = 14,
   		parameter N_SLAVES = 5,
   		parameter SLAVE_ADDR_W = 3, //ceil(log2(N_SLAVES))
   		parameter S_ADDR_W = 32,
   		parameter S_WDATA_W = 32,
   		parameter S_WSTRB_W = 4,
   		parameter S_RDATA_W = 32
	)
	(
	       input 	     clk,
               input 	     reset,
               output 	     ser_tx,
               input 	     ser_rx,
	       output 	     trap,
               output 	     resetn_int_sys,
	       output [SLAVE_ADDR_W-1:0]  s_sel,
	       output 	     sys_mem_sel,
	       // Slave signals
               output 	     sys_s_axi_awvalid,
               input 	     sys_s_axi_awready,
               output [31:0] sys_s_axi_awaddr,
               /// Data-Write
               output 	     sys_s_axi_wvalid,
               input 	     sys_s_axi_wready,
               output [31:0] sys_s_axi_wdata,
               output [ 3:0] sys_s_axi_wstrb,
               /// Write-Response
               input 	     sys_s_axi_bvalid,
               output 	     sys_s_axi_bready,
               /// Address-Read
               output 	     sys_s_axi_arvalid,
               input 	     sys_s_axi_arready,
               output [31:0] sys_s_axi_araddr,
               output [7:0]  sys_s_axi_arlen,
               output [2:0]  sys_s_axi_arsize,
               output [1:0]  sys_s_axi_arburst,
               /// Data-Read
               input 	     sys_s_axi_rvalid,
               output 	     sys_s_axi_rready,
               input [31:0]  sys_s_axi_rdata,
               input 	     sys_s_axi_rlast
               );

   //////////////////////////////////
   //// wires //////////////////////
   ////////////////////////////////
   //////// PicoRV32
   //////////////////////////////
   wire [31:0]  		     wire_m_addr;
   wire [31:0] 			     wire_m_wdata;
   wire [3:0] 			     wire_m_wstrb;
   wire [31:0] 			     wire_m_rdata;
   wire 			     wire_m_valid;
   wire 			     wire_m_ready;
   wire 			     wire_m_instr;

   ////////////////////////////////
   //////// Slaves
   ///////////////////////////////
   wire [S_ADDR_W-1:0]      	wire_s_addr [N_SLAVES-1:0];
   wire [S_RDATA_W-1:0]    	wire_s_rdata[N_SLAVES-1:0];
   wire [S_WSTRB_W-1:0]     	wire_s_wstrb[N_SLAVES-1:0];
   wire [S_WDATA_W-1:0]     	wire_s_wdata[N_SLAVES-1:0];

   wire [N_SLAVES*S_ADDR_W-1:0]      wire_s_addr_single;
   wire [N_SLAVES*S_WDATA_W-1:0]     wire_s_wdata_single;
   wire [N_SLAVES*S_WSTRB_W-1:0]     wire_s_wstrb_single;
   wire [N_SLAVES*S_RDATA_W-1:0]     wire_s_rdata_single;

   //Concatenate double array slave signals, because verilog
   //doesn't allow to pass double arrays to others modules
   genvar gi;
   generate
   	for(gi=0; gi<N_SLAVES;gi=gi+1) begin: SINGLESLAVE
		assign wire_s_addr[gi][S_ADDR_W-1 : 0] = wire_s_addr_single[((gi+1)*S_ADDR_W)-1 -: S_ADDR_W];
		assign wire_s_wdata[gi][S_WDATA_W-1:0] = wire_s_wdata_single[((gi+1)*S_WDATA_W)-1 -: S_WDATA_W];
		assign wire_s_wstrb[gi][S_WSTRB_W-1 : 0]= wire_s_wstrb_single[((gi+1)*S_WSTRB_W)-1 -: S_WSTRB_W];
		assign wire_s_rdata_single[((gi+1)*S_RDATA_W)-1 -: S_RDATA_W]=wire_s_rdata[gi][S_RDATA_W-1 : 0];
	end
   endgenerate

   wire [N_SLAVES-1:0] 		     wire_s_valid;
   wire [N_SLAVES-1:0] 		     wire_s_ready;

   wire 			     buffer_clear;

   // reset control counter
   reg [10:0] 			     rst_cnt, rst_cnt_nxt;

   // reset control
   always @(posedge clk, posedge reset) begin
      if(reset) begin
	 rst_cnt <= 11'd0;
	 //resetn_int <=1'b0;
      end else begin
	 if (rst_cnt [10] != 1'b1) begin
	    rst_cnt <= rst_cnt + 1'b1;
	    //resetn_int <= 1'b0;
	 end
	 //rst_cnt <= rst_cnt;
	 //resetn_int <= 1'b1;
      end
   end // always @ (posedge clk)
   wire resetn_int;
   assign resetn_int = (rst_cnt [10]);
   assign resetn_int_sys = resetn_int;

   ///////////////////////////////////////////////
   ////////// Soft Reset Controller ////////////
   ////////////////////////////////////////////
   reg 	mem_sel;
   reg [9:0] soft_reset;


   always @ (posedge clk) begin
      if (~resetn_int)
	begin
	   mem_sel <= 1'b0;
	   soft_reset <= 10'b1111100000;
	end
      else
	begin

`ifdef CACHE
           if ((wire_m_addr == SOFT_RESET_ADDR) && (buffer_clear))
`else
             if ((wire_m_addr == SOFT_RESET_ADDR))
`endif

               begin
		  mem_sel <= 1'b1;
		  soft_reset <= {soft_reset[8:0],soft_reset[9]};
               end
             else
               begin
		  mem_sel <= mem_sel;
		  soft_reset <= 10'b1111100000;
               end
	end
   end

   assign sys_mem_sel = mem_sel;

   reg processor_resetn;
   always @* processor_resetn <= resetn_int && ~(soft_reset[0]);

   picorv32 #(
	      .ENABLE_FAST_MUL(1),
	      .ENABLE_DIV(1)
	      )
   picorv32_core (
		           .clk    (clk       ),
		           .resetn (processor_resetn),
		           .trap   (trap      ),
		           //memory interface
		           .mem_valid     (wire_m_valid),
		           .mem_instr     (wire_m_instr),
		           .mem_ready     (wire_m_ready),
		           .mem_addr      (wire_m_addr ),
		           .mem_wdata     (wire_m_wdata),
		           .mem_wstrb     (wire_m_wstrb),
		           .mem_rdata     (wire_m_rdata)
		           );


   wire [SLAVE_ADDR_W-1:0] slave_sel;
   assign s_sel = slave_sel;


   iob_generic_interconnect #(
			      .N_SLAVES(N_SLAVES),
			      .SLAVE_ADDR_W(SLAVE_ADDR_W)
			      )
     generic_interconnect (
			   .slave_select (slave_sel),
			   .mem_select   (mem_sel),
			   .clk          (clk),
			   .sel          (1'b1),

			   /////////////////////////////////////
			   //// master interface //////////////
			   ///////////////////////////////////
			   .m_addr  (wire_m_addr),
			   .m_wdata (wire_m_wdata),
			   .m_wstrb (wire_m_wstrb),
			   .m_rdata (wire_m_rdata),
			   .m_valid (wire_m_valid),
			   .m_ready (wire_m_ready),
			   ///////////////////////////////////
			   //// N slaves  interface /////////
			   /////////////////////////////////
			   .s_addr  (wire_s_addr_single),
			   .s_wdata (wire_s_wdata_single),
			   .s_wstrb (wire_s_wstrb_single),
			   .s_rdata (wire_s_rdata_single),
			   .s_valid (wire_s_valid),
			   .s_ready (wire_s_ready)
			   );

   /////////////////////////////////////
   ////// iob UART /////////////////
   ///////////////////////////////////
   //slave 2
   iob_uart simpleuart(
		       //cpu interface
		       .clk     (clk               ),
		       .rst     (~resetn_int       ),

		       .address (wire_s_addr[`UART][4:2]),
		       .sel     (wire_s_valid[`UART]    ),
		       .read    (~(|wire_s_wstrb[`UART][S_WSTRB_W-1:0])),
		       .write   (|wire_s_wstrb[`UART][S_WSTRB_W-1:0]),

		       .data_in (wire_s_wdata[`UART][S_WDATA_W-1:0]),
		       .data_out(wire_s_rdata[`UART][S_RDATA_W-1:0]),

		       //serial i/f
		       .ser_tx  (ser_tx            ),
		       .ser_rx  (ser_rx            )
		       );

   reg 	      uart_ready;
   assign wire_s_ready[`UART] = uart_ready;

   always @(posedge clk) begin
      uart_ready <= wire_s_valid[`UART];
   end
   ////////////////////////////////////////////////////////////////////
   ///// Open source RAM with native memory instance ////
   //////////////////////////////////////////////////////////////////

   //////////////////////////////////////////////////////////
   //// Boot ROM ///////////////////////////////////////////
   ////////////////////////////////////////////////////////

   //Boot ROM is always slave 0
   boot_memory  #(
		  .ADDR_W(BOOT_ADDR_W)
		  ) boot_memory (
				 .clk            (clk           ),
				 .boot_write_data(wire_s_wdata[0][S_WDATA_W-1:0]),
				 .boot_addr      (wire_s_addr[0][BOOT_ADDR_W-1:0]),
				 .boot_en        (wire_s_wstrb[0][S_WSTRB_W-1:0]),
				 .boot_read_data (wire_s_rdata[0][S_RDATA_W-1:0])
				 );



   reg 	   boot_mem_ready;
   assign wire_s_ready[0] = boot_mem_ready;

   always @(posedge clk) begin
      boot_mem_ready <= wire_s_valid[0];
   end
   //////////////////////////////////////////////////////
   /////////////////////////////////////////////////////
`ifdef CACHE
   //////////////////////////////////////////////////////////
   //// Memory cache ///////////////////////////////////////
   ////////////////////////////////////////////////////////

   //slaves 1(always cache or main_memory) and 3
   memory_cache cache (
		       .clk                (clk),
		       .reset              (~processor_resetn),
		       .buffer_clear       (buffer_clear),
		       .cache_write_data   (wire_s_wdata[1][S_WDATA_W-1:0]),
		       .cache_addr         (wire_s_addr[1][29:0]), //TODO: This value (29) shouldn't be hard coded
		       .cache_wstrb        (wire_s_wstrb[1][S_WSTRB_W-1:0]),
		       .cache_read_data    (wire_s_rdata[1][S_RDATA_W-1:0]),
		       .cpu_req            (wire_s_valid[1]),
		       .cache_ack          (wire_s_ready[1]),

		       //slave 3
		       //Memory Cache controller signals
		       .cache_controller_address (wire_s_addr[`CACHE_CTRL][5:2]),
		       .cache_controller_requested_data (wire_s_rdata[`CACHE_CTRL][S_RDATA_W-1:0]),
		       .cache_controller_cpu_request (wire_s_valid[`CACHE_CTRL]),
		       .cache_controller_acknowledge (wire_s_ready[`CACHE_CTRL]),
		       .cache_controller_instr_access(wire_m_instr), //instruction signal from master (processor)

		       ///// AXI signals
		       /// Read
		       .AR_ADDR            (sys_s_axi_araddr),
		       .AR_LEN             (sys_s_axi_arlen),
		       .AR_SIZE            (sys_s_axi_arsize),
		       .AR_BURST           (sys_s_axi_arburst),
		       .AR_VALID           (sys_s_axi_arvalid),
		       .AR_READY           (sys_s_axi_arready),
		       //.R_ADDR             (wire_R_ADDR),
		       .R_VALID            (sys_s_axi_rvalid),
		       .R_READY            (sys_s_axi_rready),
		       .R_DATA             (sys_s_axi_rdata),
		       .R_LAST             (sys_s_axi_rlast),
		       /// Write
		       .AW_ADDR            (sys_s_axi_awaddr),
		       .AW_VALID           (sys_s_axi_awvalid),
		       .AW_READY           (sys_s_axi_awready),
		       //.W_ADDR             (wire_W_ADDR),
		       .W_VALID            (sys_s_axi_wvalid),
		       .W_STRB             (sys_s_axi_wstrb),
		       .W_READY            (sys_s_axi_wready),
		       .W_DATA             (sys_s_axi_wdata),
		       .B_VALID            (sys_s_axi_bvalid),
		       .B_READY            (sys_s_axi_bready)
		       /*.mem_write_data     (sys_s_wdata),
			.mem_wstrb          (sys_s_wstrb),
			.mem_read_data      (sys_s_rdata),
			.mem_addr           (sys_s_addr),
			.mem_valid          (sys_s_valid),
			.mem_ack            (sys_s_ready)*/
		       );

`else
   //////////////////////////////////////////////////////////
     //// Open RAM ///////////////////////////////////////////
     ////////////////////////////////////////////////////////

   //slave 1 (always cache or main_memory)
   main_memory  #(
		  .ADDR_W(MAIN_MEM_ADDR_W)
		  ) main_memory (
				 .clk                (clk                              ),
				 .main_mem_write_data(wire_s_wdata[1][S_WDATA_W-1:0]   ),
				 .main_mem_addr      (wire_s_addr[1][MAIN_MEM_ADDR_W-1:0]),
				 .main_mem_en        (wire_s_wstrb[1][S_WSTRB_W-1:0]   ),
				 .main_mem_read_data (wire_s_rdata[1][S_RDATA_W-1:0]   )
				 );


   reg            main_mem_ready;
   assign wire_s_ready[1] = main_mem_ready;

   always @(posedge clk) begin
      main_mem_ready <= wire_s_valid[1];
   end

`endif

//////////////////////////////////////////////////////////
     //// Maxeler IP ///////////////////////////////////////////
     ///////////////VectorConstantMultiply//////////////////////        

   //It will have 3 slave interfaces. Mapped_registers, Input stream and Output stream 
   VectorsConstantMultiplication_maxeler_com_maxeler_techonologies_0_1 vector_scale (
	  	//Mapped Registers Interface (slave 4)
	   		//Inputs
		. mec_clk (clk),
		. mec_rst (~resetn_int)	
		. s_axi_mapped_regs_awid(),  
		. s_axi_mapped_regs_awaddr() 
		. s_axi_mapped_regs_awlen 
		. s_axi_mapped_regs_awvalid
		. s_axi_mapped_regs_wdata 
		. s_axi_mapped_regs_wstrb 
		. s_axi_mapped_regs_wlast 
		. s_axi_mapped_regs_wvalid 
		. s_axi_mapped_regs_bready 
		. s_axi_mapped_regs_arid  
		. s_axi_mapped_regs_araddr 
		. s_axi_mapped_regs_arlen 
		. s_axi_mapped_regs_arvalid
		. s_axi_mapped_regs_rready 






//////////////////////////////////////////////////////////
     //////////////////////////////////////////////
     /////////////////////////////////////        
endmodule
