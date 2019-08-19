`timescale 1 ns / 1 ps

`include "system.vh"

module system (
               input 	     clk, 
               input 	     reset,
               output 	     ser_tx,
               input 	     ser_rx,
	       output 	     trap,
               output 	     resetn_int_sys,
	       output [1:0]  s_sel,
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
   

   
   parameter MAIN_MEM_ADDR_W = 14; // 14 = 32 bits (4) * 2**12 (4096) depth


   parameter BOOT_ADDR_W = 14;
   
   
   //////////////////////////////////
   //// wires //////////////////////   
   ////////////////////////////////
   //////// PicoRV32 
   ////////////////////////////// 
   wire [31:0] 		     wire_m_addr;
   wire [31:0] 		     wire_m_wdata; 
   wire [3:0] 		     wire_m_wstrb;
   wire [31:0] 		     wire_m_rdata;
   wire 		     wire_m_valid;
   wire 		     wire_m_ready;
   ////////////////////////////////
   //////// Slave 0
   /////////////////////////////// 
   wire [31:0] 		     wire_s_addr_0;
   wire [31:0] 		     wire_s_wdata_0; 
   wire [3:0] 		     wire_s_wstrb_0;
   wire [31:0] 		     wire_s_rdata_0;
   wire 		     wire_s_valid_0;
   wire 		     wire_s_ready_0;
   ////////////////////////////////
   //////// Slave 1
   /////////////////////////////// 
   wire [31:0] 		     wire_s_addr_1;
   wire [31:0] 		     wire_s_wdata_1; 
   wire [3:0] 		     wire_s_wstrb_1;
   wire [31:0] 		     wire_s_rdata_1;
   wire 		     wire_s_valid_1;
   wire 		     wire_s_ready_1;
   ////////////////////////////////
   //////// Slave 2
   /////////////////////////////// 
   wire [31:0] 		     wire_s_addr_2;
   wire [31:0] 		     wire_s_wdata_2; 
   wire [3:0] 		     wire_s_wstrb_2;
   wire [31:0] 		     wire_s_rdata_2;
   wire 		     wire_s_valid_2;
   wire 		     wire_s_ready_2;
   ////////////////////////////////
   //////// Slave 3
   /////////////////////////////// 
   wire [31:0] 		     wire_s_addr_3;
   wire [31:0] 		     wire_s_wdata_3; 
   wire [3:0] 		     wire_s_wstrb_3;
   wire [31:0] 		     wire_s_rdata_3;
   wire 		     wire_s_valid_3;
   wire 		     wire_s_ready_3;
   /////////////////////////////////////////////
   
   // reset control counter 
   reg [10:0] 		     rst_cnt, rst_cnt_nxt;

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
   reg [4:0] soft_reset;

   
   always @ (posedge clk) begin
      if (~resetn_int)
	begin
	   mem_sel <= 1'b0;
	   soft_reset <= 5'b10000;
	end
      else 
	begin

`ifdef CACHE
           if ((wire_m_addr == 32'hfffffffc) && (buffer_clear))
`else       
             if ((wire_m_addr == 32'hfffffffc))
`endif        
            
               begin
		  mem_sel <= 1'b1;
		  soft_reset <= {soft_reset[3:0],soft_reset[4]};
               end
             else
               begin
		  mem_sel <= mem_sel;
		  soft_reset <= 5'b10000;
               end
	end
   end

   assign sys_mem_sel = mem_sel;
   /////////////////////////////////////////////////////////////////////////////////
   ///////////////REMEMBER/////////////////////////////////////////////////////////
   //////////// in picorv32_axi_adapter///////////////////////////////////////////
   /////assign mem_ready = mem_axi_bvalid || mem_axi_rvalid;/////////////////////
   /////////////////////////////////////////////////////////////////////////////
   /////assign mem_axi_awvalid = mem_valid && |mem_wstrb && !ack_awvalid;//////
   /////assign mem_axi_arvalid = mem_valid && !mem_wstrb && !ack_arvalid;/////
   /////assign mem_axi_wvalid = mem_valid && |mem_wstrb && !ack_wvalid;//////
   /////assign mem_axi_bready = mem_valid && |mem_wstrb;////////////////////
   /////assign mem_axi_rready = mem_valid && !mem_wstrb;///////////////////
   ///////////////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////
   
   reg processor_resetn;
   always @* processor_resetn <= resetn_int && ~(soft_reset[0]);
   
   picorv32 #(
	      .ENABLE_PCPI(1),
	      .ENABLE_MUL(1),
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
   
   
   wire [1:0] slave_sel;
   assign s_sel = slave_sel;
   //  assign sys_mem_sel = mem_sel;
   
   
   iob_generic_interconnect generic_interconnect (
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
						  .s_addr  ({wire_s_addr_3,wire_s_addr_2,wire_s_addr_1,wire_s_addr_0}),
						  .s_wdata ({wire_s_wdata_3, wire_s_wdata_2, wire_s_wdata_1, wire_s_wdata_0}),	       
						  .s_wstrb ({wire_s_wstrb_3, wire_s_wstrb_2, wire_s_wstrb_1, wire_s_wstrb_0}),
						  .s_rdata ({wire_s_rdata_3, wire_s_rdata_2, wire_s_rdata_1, wire_s_rdata_0}),
						  .s_valid ({wire_s_valid_3, wire_s_valid_2,wire_s_valid_1, wire_s_valid_0}),
						  .s_ready ({wire_s_ready_3, wire_s_ready_2, wire_s_ready_1, wire_s_ready_0})
						  );


`ifndef PICOSOC_UART
   
   ///////////////////////////////////// 
   ////// iob UART /////////////////
   ///////////////////////////////////

   iob_uart simpleuart(
		       //cpu interface
		       .clk     (clk               ),
		       .rst     (~resetn_int       ),

		       .address (wire_s_addr_2[4:2]),
		       .sel     (wire_s_valid_2    ),
		       .read    (~(|wire_s_wstrb_2)),
		       .write   (|wire_s_wstrb_2   ),

		       .data_in (wire_s_wdata_2    ),
		       .data_out(wire_s_rdata_2    ),

		       //serial i/f
		       .ser_tx  (ser_tx            ),
		       .ser_rx  (ser_rx            ) 
		       );

   reg 	      uart_ready;
   assign wire_s_ready_2 = uart_ready;
   
   always @(posedge clk) begin
      uart_ready <= wire_s_valid_2;
   end  
   ////////////////////////////////////
     ///////////////////////////////////	       
      
`else   
   ///////////////////////////////////// 
     ////// Simple UART Picosoc//////////
     ///////////////////////////////////
     wire       simpleuart_wait;
   wire [31:0] 	simpleuart_reg_div_do, simpleuart_reg_dat_do;

   
   picosoc_uart simpleuart (
			    //serial i/f
			    .ser_tx      (ser_tx          ),
			    .ser_rx      (ser_rx          ),
			    //data bus
			    .clk         (clk             ),
			    .resetn      (resetn_int      ),
			    //				 .address     (wire_s_addr_2[3:2]),
			    //				 .sel         (wire_s_valid_2    ),	
			    //				 .we          (|wire_s_wstrb_2   ),
			    //				 .dat_di      (wire_s_wdata_2    ),
			    //				 .dat_do      (wire_s_rdata_2    )
			    //	                  );
			    .reg_div_we  ((wire_s_valid_2 && wire_s_addr_2 [2])? wire_s_wstrb_2 : 4'b 0000),
			    .reg_div_di  (wire_s_wdata_2),
			    .reg_div_do  (simpleuart_reg_div_do),
      
			    .reg_dat_we  ((wire_s_valid_2 && wire_s_addr_2 [3])? wire_s_wstrb_2[0] : 1'b 0),
			    .reg_dat_re  ((wire_s_valid_2 && wire_s_addr_2 [3]) && !wire_s_wstrb_2),
			    .reg_dat_di  (wire_s_wdata_2),
			    .reg_dat_do  (simpleuart_reg_dat_do),
			    .reg_dat_wait(simpleuart_wait)
			    );
   

   wire 	simpleuart_reg_div_sel = wire_s_valid_2 && wire_s_addr_2 [2]; // addr = ...0004
   wire 	simpleuart_reg_dat_sel = wire_s_valid_2 && wire_s_addr_2 [3]; // addr = ...0008


   assign wire_s_ready_2 = (wire_s_valid_2 && wire_s_addr_2 [2]) || ((wire_s_valid_2 && wire_s_addr_2 [3]) && !simpleuart_wait);
   assign wire_s_rdata_2 = simpleuart_reg_div_sel ? simpleuart_reg_div_do : simpleuart_reg_dat_sel ? simpleuart_reg_dat_do : 32'h 0000_0000;
   //////////////////////////////////
   /////////////////////////////////	       
   
`endif  
   
   
   
   //   ////////////////////////////////////////////////////////////////////
   //   ///// Open source RAM and Boot ROM with native memory instance ////
   //   //////////////////////////////////////////////////////////////////
   //   //////////////////////////////////////////////////////////
   //   //// Open RAM ///////////////////////////////////////////
   //   ////////////////////////////////////////////////////////  	  
`ifdef AUX_MEM
   main_memory  #(
		  .ADDR_W(MAIN_MEM_ADDR_W-2) 
		  ) auxiliary_memory (
				      .clk                (clk                                  ),
				      .main_mem_write_data(wire_s_wdata_3                       ),
				      .main_mem_addr      (wire_s_addr_3 [MAIN_MEM_ADDR_W-1:2]),
				      .main_mem_en        (wire_s_wstrb_3                       ),
				      .main_mem_read_data (wire_s_rdata_3                       )                       
				      );

   
   reg 		aux_mem_ready;
   assign wire_s_ready_3 = aux_mem_ready;
   
   always @(posedge clk) begin
      aux_mem_ready <= wire_s_valid_3; 
   end  
   
`endif  
   
   ////////////////////////////////////////////////////////////////////
   ///// Open source RAM with native memory instance ////
   //////////////////////////////////////////////////////////////////
   
   //////////////////////////////////////////////////////////
   //// Boot ROM ///////////////////////////////////////////
   ////////////////////////////////////////////////////////  
   
   boot_memory  #(
		  .ADDR_W(BOOT_ADDR_W-2) 
		  ) boot_memory (
				 .clk            (clk           ),
				 .boot_write_data(wire_s_wdata_0),
				 .boot_addr      (wire_s_addr_0 [BOOT_ADDR_W-1:2]),
				 .boot_en        (wire_s_wstrb_0),
				 .boot_read_data (wire_s_rdata_0)                            
				 );
   

   
   reg 	   boot_mem_ready;
   assign wire_s_ready_0 = boot_mem_ready;
   
   always @(posedge clk) begin
      boot_mem_ready <= wire_s_valid_0; 
   end   
   //////////////////////////////////////////////////////
   /////////////////////////////////////////////////////
`ifdef CACHE
   //////////////////////////////////////////////////////////
   //// Memory cache ///////////////////////////////////////
   ////////////////////////////////////////////////////////
   
   memory_cache cache (
		       .clk                (clk),
		       .reset              (~processor_resetn),
		       .buffer_clear       (buffer_clear),
		       .cache_write_data   (wire_s_wdata_1),
		       .cache_addr         (wire_s_addr_1 [29:0]),
		       .cache_wstrb        (wire_s_wstrb_1),
		       .cache_read_data    (wire_s_rdata_1),
		       .cpu_ack            (wire_s_valid_1),
		       .cache_ack          (wire_s_ready_1),
 `ifndef AUX_MEM
		       //Memory Cache controller signals
		       .cache_controller_address (wire_s_addr_3 [3:2]),
		       .cache_controller_requested_data (wire_s_rdata_3),
		       .cache_controller_cpu_request (wire_s_valid_3),
		       .cache_controller_acknowledge (wire_s_ready_3),	       
 `else	       
		       .cache_controller_address (2'b00),
		       .cache_controller_requested_data (),
		       .cache_controller_cpu_request (1 'b0),
		       .cache_controller_acknowledge (),  
 `endif              
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

   main_memory  #(
		  .ADDR_W(MAIN_MEM_ADDR_W-2) 
		  ) main_memory (
				 .clk                (clk                                  ),
				 .main_mem_write_data(wire_s_wdata_1                       ),
				 .main_mem_addr      (wire_s_addr_1 [MAIN_MEM_ADDR_W-1:2]),
				 .main_mem_en        (wire_s_wstrb_1                       ),
				 .main_mem_read_data (wire_s_rdata_1                       )                       
				 );

   
   reg            main_mem_ready;
   assign wire_s_ready_1 = main_mem_ready;
   
   always @(posedge clk) begin
      main_mem_ready <= wire_s_valid_1; 
   end 
   
`endif
   
endmodule
