`timescale 1 ns / 1 ps



module system (
                     input 	   clk, 
                     input 	   reset,
                     //output reg led,
                     output 	   ser_tx,
                     input         ser_rx,
                     output 	   trap,
                     output 	   resetn_int_sys,
		     output [1:0]  s_sel,
	             // Slave signals
	             output [31:0] sys_s_addr,
	             output [31:0] sys_s_wdata,
	             output [3:0]  sys_s_wstrb,
	             input  [31:0] sys_s_rdata,
	             output        sys_s_valid,
	             input         sys_s_ready
               );
               
   parameter MAIN_MEM_ADDR_W = 14; // 14 = 32 bits (4) * 2**12 (4096) depth


   parameter DDR_ADDR_W = 14;
   
   
//////////////////////////////////
//// wires //////////////////////   
////////////////////////////////
//////// PicoRV32 
////////////////////////////// 
   wire [31:0] wire_m_addr;
   wire [31:0] wire_m_wdata; 
   wire [3:0]  wire_m_wstrb;
   wire [31:0] wire_m_rdata;
   wire        wire_m_valid;
   wire        wire_m_ready;
////////////////////////////////
//////// Slave 0
/////////////////////////////// 
   wire [31:0] wire_s_addr_0;
   wire [31:0] wire_s_wdata_0; 
   wire [3:0]  wire_s_wstrb_0;
   wire [31:0] wire_s_rdata_0;
   wire        wire_s_valid_0;
   wire        wire_s_ready_0;
////////////////////////////////
//////// Slave 1
/////////////////////////////// 
   wire [31:0] wire_s_addr_1;
   wire [31:0] wire_s_wdata_1; 
   wire [3:0]  wire_s_wstrb_1;
   wire [31:0] wire_s_rdata_1;
   wire        wire_s_valid_1;
   wire        wire_s_ready_1;
////////////////////////////////
//////// Slave 2
/////////////////////////////// 
   wire [31:0] wire_s_addr_2;
   wire [31:0] wire_s_wdata_2; 
   wire [3:0]  wire_s_wstrb_2;
   wire [31:0] wire_s_rdata_2;
   wire        wire_s_valid_2;
   wire        wire_s_ready_2;
////////////////////////////////
//////// Slave 3
/////////////////////////////// 
   wire [31:0] wire_s_addr_3;
   wire [31:0] wire_s_wdata_3; 
   wire [3:0]  wire_s_wstrb_3;
   wire [31:0] wire_s_rdata_3;
   wire        wire_s_valid_3;
   wire        wire_s_ready_3;
/////////////////////////////////////////////
      
   // reset control counter 
   reg [10:0]     rst_cnt, rst_cnt_nxt;
   reg 		  resetn_int;
		  

   // reset control
   always @(posedge clk) begin
     if(~reset) begin
	rst_cnt <= 11'd0;
	rst_cnt_nxt <=11'd0;
	resetn_int <=1'b0;
     end else begin
	if (rst_cnt [10] != 1'b1) begin  
	   rst_cnt <= rst_cnt_nxt + 1'b1;
	   rst_cnt_nxt <= rst_cnt;
	   resetn_int <= 1'b0;
	end
	rst_cnt <= 11'b10000000000;
	rst_cnt_nxt <= 11'b10000000000;
	resetn_int <= 1'b1;
     end
   end // always @ (posedge clk)
   
   assign resetn_int_sys = resetn_int; 



   reg mem_sel;
   reg [4:0] soft_reset;

   
   always @ (posedge clk) begin
      if (~resetn_int)
	   begin
	       mem_sel <= 1'b0;
	       soft_reset <= 5'b10000;
	   end
      else 
	   begin
	   
	   if (wire_m_addr == 32'hfffffffc )
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
    
   picorv32 picorv32_core (
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
   

					   
   iob_native_interconnect native_interconnect (
						.slave_select (slave_sel),
						.mem_select   (mem_sel),
						.clk          (clk),				
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
						//// slave 0  interface //////////
						/////////////////////////////////
						.s_addr_0  (wire_s_addr_0),
						.s_wdata_0 (wire_s_wdata_0),	       
						.s_wstrb_0 (wire_s_wstrb_0),
						.s_rdata_0 (wire_s_rdata_0),
						.s_valid_0 (wire_s_valid_0),
						.s_ready_0 (wire_s_ready_0),
						///////////////////////////////////
						//// slave 1 interface ///////////
						/////////////////////////////////
						.s_addr_1  (wire_s_addr_1),
						.s_wdata_1 (wire_s_wdata_1),	       
						.s_wstrb_1 (wire_s_wstrb_1),
						.s_rdata_1 (wire_s_rdata_1),
						.s_valid_1 (wire_s_valid_1),
						.s_ready_1 (wire_s_ready_1),
						///////////////////////////////////
						//// slave 2 interface ///////////
						/////////////////////////////////
					    .s_addr_2  (wire_s_addr_2),
						.s_wdata_2 (wire_s_wdata_2),	       
						.s_wstrb_2 (wire_s_wstrb_2),
						.s_rdata_2 (wire_s_rdata_2),
						.s_valid_2 (wire_s_valid_2),
						.s_ready_2 (wire_s_ready_2),
						///////////////////////////////////
						//// slave 3 interface ///////////
						/////////////////////////////////
					        .s_addr_3  (wire_s_addr_3),
						.s_wdata_3 (wire_s_wdata_3),	       
						.s_wstrb_3 (wire_s_wstrb_3),
						.s_rdata_3 (wire_s_rdata_3),
						.s_valid_3 (wire_s_valid_3),
						.s_ready_3 (wire_s_ready_3)
						);



   assign sys_s_addr  = wire_s_addr_1;
   assign sys_s_wdata = wire_s_wdata_1;
   assign sys_s_wstrb = wire_s_wstrb_1;
   assign wire_s_rdata_1 = sys_s_rdata;
   assign sys_s_valid = wire_s_valid_1;
   assign wire_s_ready_1 = sys_s_ready;
   
   
   
///////////////////////////////////// 
////// Simple UART /////////////////
///////////////////////////////////
	                   
//          simpleuart simpleuart (
//				 //serial i/f
//				 .ser_tx      (ser_tx          ),
//				 .ser_rx      (ser_rx          ),
//				 //data bus
//				 .clk         (clk             ),
//				 .resetn      (resetn_int      ),
//				 .address     (wire_s_addr_2[3:2]),
//				 .sel         (wire_s_valid_2    ),	
//				 .we          (|wire_s_wstrb_2   ),
//				 .dat_di      (wire_s_wdata_2    ),
//				 .dat_do      (wire_s_rdata_2    )
//	                  );
 
//   reg 	   uart_ready;
//   assign wire_s_ready_2 = wire_s_valid_2;
   
////   always @(posedge clk) begin
////      uart_ready <= wire_s_valid_2;
////   end  
////////////////////////////////////
///////////////////////////////////	       
  
   
///////////////////////////////////// 
////// Simple UART Picosoc//////////
///////////////////////////////////
wire simpleuart_wait;
wire [31:0] simpleuart_reg_div_do, simpleuart_reg_dat_do;

	                   
          simpleuart simpleuart (
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
                
                
                
//                .reg_div_we  (simpleuart_reg_div_sel ? mem_wstrb : 4'b 0000),
//                .reg_div_di  (mem_wdata),
//                .reg_div_do  (simpleuart_reg_div_do),
        
//                .reg_dat_we  (simpleuart_reg_dat_sel ? mem_wstrb[0] : 1'b 0),
//                .reg_dat_re  (simpleuart_reg_dat_sel && !mem_wstrb),
//                .reg_dat_di  (mem_wdata),
//                .reg_dat_do  (simpleuart_reg_dat_do),
//                .reg_dat_wait(simpleuart_reg_dat_wait)

wire        simpleuart_reg_div_sel = wire_s_valid_2 && wire_s_addr_2 [2]; // addr = ...0004
wire        simpleuart_reg_dat_sel = wire_s_valid_2 && wire_s_addr_2 [3]; // addr = ...0008
//	assign mem_rdata = (iomem_valid && iomem_ready) ? iomem_rdata : spimem_ready ? spimem_rdata : ram_ready ? ram_rdata :
//        spimemio_cfgreg_sel ? spimemio_cfgreg_do : simpleuart_reg_div_sel ? simpleuart_reg_div_do :
//        simpleuart_reg_dat_sel ? simpleuart_reg_dat_do : 32'h 0000_0000;

assign wire_s_ready_2 = (wire_s_valid_2 && wire_s_addr_2 [2]) || ((wire_s_valid_2 && wire_s_addr_2 [3]) && !simpleuart_wait);
assign wire_s_rdata_2 = simpleuart_reg_div_sel ? simpleuart_reg_div_do : simpleuart_reg_dat_sel ? simpleuart_reg_dat_do : 32'h 0000_0000;
//   reg 	   uart_ready;
//   assign wire_s_ready_2 = uart_ready;
      
//   always @(posedge clk) begin
//      uart_ready <= wire_s_valid_2;
//   end  
////////////////////////////////////
///////////////////////////////////	       
  
 
 
 
 
////////////////////////////////////////////////////////////////////
///// Open source RAM and Boot ROM with native memory instance ////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//// Open RAM ///////////////////////////////////////////
////////////////////////////////////////////////////////  	  

        main_memory  #(.ADDR_W(MAIN_MEM_ADDR_W-2) ) main_memory (
                    .clk                (clk                                  ),
                    .main_mem_write_data(wire_s_wdata_3                       ),
                    .main_mem_addr      (wire_s_addr_3 [MAIN_MEM_ADDR_W-1:2]),
                    .main_mem_en        (wire_s_wstrb_3                       ),
                    .main_mem_read_data (wire_s_rdata_3                       )                       
                        );

      
   reg 	  main_mem_ready;
   assign wire_s_ready_3 = main_mem_ready;
   
   always @(posedge clk) begin
      main_mem_ready <= wire_s_valid_3; 
   end   
//////////////////////////////////////////////////////////
//// Boot ROM ///////////////////////////////////////////
////////////////////////////////////////////////////////  
  
        boot_memory  #(.ADDR_W(MAIN_MEM_ADDR_W-2) ) boot_memory (
                    .clk            (clk           ),
                    .boot_write_data(wire_s_wdata_0),
                    .boot_addr      (wire_s_addr_0 [MAIN_MEM_ADDR_W-1:2]),
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


   
endmodule
