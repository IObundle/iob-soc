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
               input [31:0]  sys_s_axi_rinstr,
               input 	     sys_s_axi_rlast
               );
   

   
   parameter MAIN_MEM_ADDR_W = 19; // 14 = 32 bits (4) * 2**12 (4096) depth


   parameter BOOT_ADDR_W = 14;
   
   
   //////////////////////////////////
   //// wires //////////////////////
   /////////////////////////////////
			
   ////////////////////////////////
   //////// PicoRV32 
   //////////////////////////////
   wire [31:0] 		     wire_m_daddr;
   wire [31:0] 		     wire_m_iaddr;
   wire [31:0] 		     wire_m_wdata; 
   wire [3:0] 		     wire_m_wstrb;
   wire [31:0] 		     wire_m_rdata;
   wire [31:0] 		     wire_m_rinstr;
   wire 		     wire_m_valid;
   wire 		     wire_m_ready;

   ////////////////////////////////
   //////// Slave 0
   /////////////////////////////// 
   wire [31:0] 		     wire_s_daddr_0;
   wire [31:0] 		     wire_s_iaddr_0;
   wire [31:0] 		     wire_s_wdata_0; 
   wire [3:0] 		     wire_s_wstrb_0;
   wire [31:0] 		     wire_s_rdata_0;
   wire [31:0] 		     wire_s_rinstr_0;
   wire 		     wire_s_valid_0;
   wire 		     wire_s_ready_0;
   ////////////////////////////////
   //////// Slave 1
   /////////////////////////////// 
   wire [31:0] 		     wire_s_daddr_1;
   wire [31:0] 		     wire_s_iaddr_1;
   wire [31:0] 		     wire_s_wdata_1; 
   wire [3:0] 		     wire_s_wstrb_1;
   wire [31:0] 		     wire_s_rdata_1;
   wire [31:0] 		     wire_s_rinstr_1;
   wire 		     wire_s_valid_1;
   wire 		     wire_s_ready_1;
   ////////////////////////////////
   //////// Slave 2
   /////////////////////////////// 
   wire [31:0] 		     wire_s_daddr_2;
   wire [31:0] 		     wire_s_iaddr_2;
   wire [31:0] 		     wire_s_wdata_2; 
   wire [3:0] 		     wire_s_wstrb_2;
   wire [31:0] 		     wire_s_rdata_2;
   wire [31:0] 		     wire_s_rinstr_2;
   wire 		     wire_s_valid_2;
   wire 		     wire_s_ready_2;
   ////////////////////////////////
   //////// Slave 3
   /////////////////////////////// 
   wire [31:0] 		     wire_s_daddr_3;
   wire [31:0] 		     wire_s_iaddr_3;
   wire [31:0] 		     wire_s_wdata_3; 
   wire [3:0] 		     wire_s_wstrb_3;
   wire [31:0] 		     wire_s_rdata_3;
   wire [31:0] 		     wire_s_rinstr_3;
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
           if ((wire_m_daddr == 32'hfffffffc) && (buffer_clear))
`else 
	       if ((wire_m_daddr == 32'hfffffffc))      
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

   wrapper_cpu core0 (
		      .clk(clk),
		      .processor_resetn(processor_resetn),
		      .resetn_int(resetn_int),

		      //cpu
		      .m_iaddr(wire_m_iaddr),
		      .m_daddr(wire_m_daddr),
		      .m_wdata(wire_wdata),
		      .m_wstrb(wire_m_wstrb),
		      .m_rdata(wire_m_rdata),
		      .m_rinstr(wire_m_rinstr),
		      .m_valid(wire_m_valid),
		      .m_ready(wire_m_ready),
		      .trap(trap)
		      );
   

   
   
   wire [1:0] slave_sel;
   assign s_sel = slave_sel;
   //  assign sys_mem_sel = mem_sel;

   
   iob_native_interconnect native_interconnect (
						.slave_select (slave_sel),
						.mem_select   (mem_sel),
						.clk          (clk),				
						/////////////////////////////////////
						//// master interface //////////////
						///////////////////////////////////					
						.m_daddr  (wire_m_daddr),
						.m_iaddr  (wire_m_iaddr),
						.m_wdata (wire_m_wdata),	       
						.m_wstrb (wire_m_wstrb),
						.m_rdata (wire_m_rdata),
						.m_rinstr (wire_m_rinstr),
						.m_valid (wire_m_valid),
						.m_ready (wire_m_ready),
						///////////////////////////////////
						//// slave 0  interface //////////
						/////////////////////////////////
						.s_daddr_0  (wire_s_daddr_0),
						.s_iaddr_0  (wire_s_iaddr_0),
						.s_wdata_0 (wire_s_wdata_0),	       
						.s_wstrb_0 (wire_s_wstrb_0),
						.s_rdata_0 (wire_s_rdata_0),
						.s_rinstr_0 (wire_s_rinstr_0),
						.s_valid_0 (wire_s_valid_0),
						.s_ready_0 (wire_s_ready_0),
						///////////////////////////////////
						//// slave 1 interface ///////////
						/////////////////////////////////
						.s_daddr_1  (wire_s_daddr_1),
						.s_iaddr_1  (wire_s_iaddr_1),
						.s_wdata_1 (wire_s_wdata_1),	       
						.s_wstrb_1 (wire_s_wstrb_1),
						.s_rdata_1 (wire_s_rdata_1),
						.s_rinstr_1 (wire_s_rinstr_1),
						.s_valid_1 (wire_s_valid_1),
						.s_ready_1 (wire_s_ready_1),
						///////////////////////////////////
						//// slave 2 interface ///////////
						/////////////////////////////////
						.s_daddr_2  (wire_s_daddr_2),
						.s_iaddr_2  (wire_s_iaddr_2),
						.s_wdata_2 (wire_s_wdata_2),	       
						.s_wstrb_2 (wire_s_wstrb_2),
						.s_rdata_2 (wire_s_rdata_2),
						.s_rinstr_2 (wire_s_rinstr_2),
						.s_valid_2 (wire_s_valid_2),
						.s_ready_2 (wire_s_ready_2),
						///////////////////////////////////
						//// slave 3 interface ///////////
						/////////////////////////////////
						.s_daddr_3  (wire_s_daddr_3),
						.s_iaddr_3  (wire_s_iaddr_3),
						.s_wdata_3 (wire_s_wdata_3),	       
						.s_wstrb_3 (wire_s_wstrb_3),
						.s_rdata_3 (wire_s_rdata_3),
						.s_rinstr_3 (wire_s_rinstr_3),
						.s_valid_3 (wire_s_valid_3),
						.s_ready_3 (wire_s_ready_3)
						);


`ifndef PICOSOC_UART
   
   ///////////////////////////////////// 
   ////// Simple UART /////////////////
   ///////////////////////////////////
   
   simpleuart simpleuart (
   			  //serial i/f
   			  .ser_tx      (ser_tx          ),
   			  .ser_rx      (ser_rx          ),
   			  //data bus
   			  .clk         (clk             ),
   			  .resetn      (resetn_int      ),
   			  .address     (wire_s_daddr_2[4:2]),
   			  .sel         (wire_s_valid_2    ),	
   			  .we          (|wire_s_wstrb_2   ),
   			  .dat_di      (wire_s_wdata_2    ),
   			  .dat_do      (wire_s_rdata_2    )
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

			    .reg_div_we  ((wire_s_valid_2 && wire_s_daddr_2 [2])? wire_s_wstrb_2 : 4'b 0000),
			    .reg_div_di  (wire_s_wdata_2),
			    .reg_div_do  (simpleuart_reg_div_do),
      
			    .reg_dat_we  ((wire_s_valid_2 && wire_s_daddr_2 [3])? wire_s_wstrb_2[0] : 1'b 0),
			    .reg_dat_re  ((wire_s_valid_2 && wire_s_daddr_2 [3]) && !wire_s_wstrb_2),
			    .reg_dat_di  (wire_s_wdata_2),
			    .reg_dat_do  (simpleuart_reg_dat_do),
			    .reg_dat_wait(simpleuart_wait)
			    );
   

   wire 	simpleuart_reg_div_sel = wire_s_valid_2 && wire_s_daddr_2 [2]; // addr = ...0004
   wire 	simpleuart_reg_dat_sel = wire_s_valid_2 && wire_s_daddr_2 [3]; // addr = ...0008


   assign wire_s_ready_2 = (wire_s_valid_2 && wire_s_daddr_2 [2]) || ((wire_s_valid_2 && wire_s_daddr_2 [3]) && !simpleuart_wait);
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
				      .main_mem_daddr     (wire_s_daddr_3 [MAIN_MEM_ADDR_W-1:2] ),
				      .main_mem_en        (wire_s_wstrb_3                       ),
				      .main_mem_read_data (wire_s_rdata_3                       ),
				      .main_mem_iaddr     (wire_s_iaddr_3 [MAIN_MEM_ADDR_W-1:2] ),
				      .main_mem_read_instr(wire_s_rinstr_3                      )
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
				 .boot_en        (wire_s_wstrb_0),
				 .boot_addr      (wire_s_iaddr_0 [BOOT_ADDR_W-1:2]),
				 .boot_read_data (wire_s_rinstr_0)                            
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
   
   memory_cache D_cache (
		       .clk                (clk),
		       .reset              (~processor_resetn),
		       .buffer_clear       (buffer_clear),
		       .cache_write_data   (wire_s_wdata_1),
		       .cache_addr         (wire_s_daddr_1 [29:0]),
		       .cache_wstrb        (wire_s_wstrb_1),
		       .cache_read_data    (wire_s_rdata_1),
		       .cpu_ack            (wire_s_valid_1),
		       .cache_ack          (wire_s_ready_1),
 `ifndef AUX_MEM
		       //Memory Cache controller signals
		       .cache_controller_address (wire_s_daddr_3 [3:2]),
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

     memory_cache I_cache (
		       .clk                (clk),
		       .reset              (~processor_resetn),
		       .buffer_clear       (buffer_clear),
		       .cache_write_data   (wire_s_wdata_1),
		       .cache_addr         (wire_s_iaddr_1 [29:0]),
		       .cache_wstrb        (wire_s_wstrb_1),
		       .cache_read_data    (wire_s_rinstr_1),
		       .cpu_ack            (wire_s_valid_1),
		       .cache_ack          (wire_s_ready_1),
 `ifndef AUX_MEM
		       //Memory Cache controller signals
		       .cache_controller_address (wire_s_iaddr_3 [3:2]),
		       .cache_controller_requested_data (wire_s_rinstr_3),
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
		       .R_DATA             (sys_s_axi_rinstr),
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
				 .main_mem_daddr     (wire_s_daddr_1 [MAIN_MEM_ADDR_W-1:2] ),
				 .main_mem_en        (wire_s_wstrb_1                       ),
				 .main_mem_read_data (wire_s_rdata_1                       ),
				 .main_mem_iaddr     (wire_s_iaddr_1 [MAIN_MEM_ADDR_W-1:2] ),
				 .main_mem_read_instr(wire_s_rinstr_1                      )
				 );

   
   reg            main_mem_ready;
   assign wire_s_ready_1 = main_mem_ready;
   
   always @(posedge clk) begin
      main_mem_ready <= wire_s_valid_1; 
   end 
   
`endif
   
endmodule
