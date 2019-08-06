`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IOBundle
// Engineer: 
// 
// Create Date: 24/05/2019 16:30:41 PM
// Design Name: 
// Module Name: iob_native_interconnect, memory_mapped_decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Native Memory interface interconnect, so you can connect to multiple peripherals using Picorv32's native memory interface
//      slave_0 -> Ideally for Program RAM, since PicoRV32 starts at the address 0 to read the program
//          
//
//
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//
// WARNING: Separate processes (always@*) because Verilator doesn't like it
//////////////////////////////////////////////////////////////////////////////////


module iob_native_interconnect(
			       
			       output [1:0] 	 slave_select, 
			       input 		 mem_select,
			       input 		 clk,
			       /////////////////////////////////////  
			       //// master AXI interface //////////
			       ///////////////////////////////////

			       input [31:0] 	 m_addr,

			       input [31:0] 	 m_wdata,
			       input [ 3:0] 	 m_wstrb,
			       output reg [31:0] m_rdata,

			       input 		 m_valid,
			       output reg 	 m_ready,

			       ///////////////////////////////////
			       //// slave 0 AXI interface ///////
			       /////////////////////////////////  

			       output reg [31:0] s_addr_0,

			       output reg [31:0] s_wdata_0,
			       output reg [ 3:0] s_wstrb_0,
			       input [31:0] 	 s_rdata_0,

			       output reg 	 s_valid_0,
			       input 		 s_ready_0,

			       ///////////////////////////////////
			       //// slave 1 AXI interface ///////
			       ///////////////////////////////// 
			       
			       output reg [31:0] s_addr_1,

			       output reg [31:0] s_wdata_1,
			       output reg [ 3:0] s_wstrb_1,
			       input [31:0] 	 s_rdata_1,

			       output reg 	 s_valid_1,
			       input 		 s_ready_1,

	                       ///////////////////////////////////
	                       //// slave 2 AXI interface ///////
	                       /////////////////////////////////  

			       output reg [31:0] s_addr_2,

			       output reg [31:0] s_wdata_2,
			       output reg [ 3:0] s_wstrb_2,
			       input [31:0] 	 s_rdata_2,

			       output reg 	 s_valid_2,
			       input 		 s_ready_2,


	                       ///////////////////////////////////
	                       //// slave 3 AXI interface ///////
	                       /////////////////////////////////
			       
			       output reg [31:0] s_addr_3,

			       output reg [31:0] s_wdata_3,
			       output reg [ 3:0] s_wstrb_3,
			       input [31:0] 	 s_rdata_3,

			       output reg 	 s_valid_3,
			       input 		 s_ready_3

                               );


   wire [1:0] 					 s_sel;
   assign slave_select = s_sel;



   iob_native_memory_mapped_decoder native_mm_dec (
						   .mem_addr (m_addr),
						   .s_sel    (s_sel )
						   );

   
   always @*
     begin: IOBundle_Native_interconnect
        case (s_sel)
          default: begin
	     if (mem_select == 0) begin 
		// address
		s_addr_0 <= m_addr;		  
		s_addr_1 <= 32'd0;
		s_addr_2 <= 32'd0;
		s_addr_3 <= 32'd0;
		// write data
		s_wdata_0 <= m_wdata; 
		s_wdata_1 <= 32'd0;
		s_wdata_2 <= 32'd0;
		s_wdata_3 <= 32'd0;
                // write strub
		s_wstrb_0 <= m_wstrb;
		s_wstrb_1 <= 4'd0;
		s_wstrb_2 <= 4'd0;
		s_wstrb_3 <= 4'd0;
		// read data
		m_rdata <= s_rdata_0;
		// valid
		s_valid_0 <= m_valid;
		s_valid_1 <= 1'b0;
		s_valid_2 <= 1'b0;
		s_valid_3 <= 1'b0;
		// ready
		m_ready <= s_ready_0;
             end else begin // if (mem_select == 1)
		// address
		s_addr_0 <= 32'd0;		  
		s_addr_1 <= m_addr;
		s_addr_2 <= 32'd0;
		s_addr_3 <= 32'd0;
		// write data
		s_wdata_0 <= 32'd0; 
		s_wdata_1 <= m_wdata;
		s_wdata_2 <= 32'd0;
		s_wdata_3 <= 32'd0;
                // write strub
		s_wstrb_0 <= 4'd0;
		s_wstrb_1 <= m_wstrb;
		s_wstrb_2 <= 4'd0;
		s_wstrb_3 <= 4'd0;
		// read data
		m_rdata <= s_rdata_1;
		// valid
		s_valid_0 <= 1'b0;
		s_valid_1 <= m_valid;
		s_valid_2 <= 1'b0;
		s_valid_3 <= 1'b0;
		// ready
		m_ready <= s_ready_1;   
             end // else: !if(mem_select == 0)
	  end // case: default

	  
          2'b01: begin
	     if (mem_select == 0) begin
                // address
		s_addr_0 <= 32'd0;		  
		s_addr_1 <= m_addr;
		s_addr_2 <= 32'd0;
		s_addr_3 <= 32'd0;
		// write data
		s_wdata_0 <= 32'd0; 
		s_wdata_1 <= m_wdata;
		s_wdata_2 <= 32'd0;
		s_wdata_3 <= 32'd0;
                // write strub
		s_wstrb_0 <= 4'd0;
		s_wstrb_1 <= m_wstrb;
		s_wstrb_2 <= 4'd0;
		s_wstrb_3 <= 4'd0;
		// read data
		m_rdata <= s_rdata_1;
		// valid
		s_valid_0 <= 1'b0;
		s_valid_1 <= m_valid;
		s_valid_2 <= 1'b0;
		s_valid_3 <= 1'b0;
		// ready
		m_ready <= s_ready_1;                       
             end // if (mem_select == 0)
	     else begin
		// address
		s_addr_0 <= m_addr;		  
		s_addr_1 <= 32'd0;
		s_addr_2 <= 32'd0;
		s_addr_3 <= 32'd0;
		// write data
		s_wdata_0 <= m_wdata; 
		s_wdata_1 <= 32'd0;
		s_wdata_2 <= 32'd0;
		s_wdata_3 <= 32'd0;
                // write strub
		s_wstrb_0 <= m_wstrb;
		s_wstrb_1 <= 4'd0;
		s_wstrb_2 <= 4'd0;
		s_wstrb_3 <= 4'd0;
		// read data
		m_rdata <= s_rdata_0;
		// valid
		s_valid_0 <= m_valid;
		s_valid_1 <= 1'b0;
		s_valid_2 <= 1'b0;
		s_valid_3 <= 1'b0;
		// ready
		m_ready <= s_ready_0;
	     end // else: !if(mem_select == 0)
	  end // case: 2'b01
	  

          2'b10: begin
             // address
	     s_addr_0 <= 32'd0;		  
	     s_addr_1 <= 32'd0;
	     s_addr_2 <= m_addr;
	     s_addr_3 <= 32'd0;
	     // write data
	     s_wdata_0 <= 32'd0; 
	     s_wdata_1 <= 32'd0;
	     s_wdata_2 <= m_wdata;
	     s_wdata_3 <= 32'd0;
             // write strub
	     s_wstrb_0 <= 4'd0;
	     s_wstrb_1 <= 4'd0;
	     s_wstrb_2 <= m_wstrb;
	     s_wstrb_3 <= 4'd0;
	     // read data
	     m_rdata <= s_rdata_2;
	     // valid
	     s_valid_0 <= 1'b0;
	     s_valid_1 <= 1'b0;
	     s_valid_2 <= m_valid;
	     s_valid_3 <= 1'b0;
	     // ready
	     m_ready <= s_ready_2;
          end // case: 2'b10  
          
          2'b11: begin
             // address
	     s_addr_0 <= 32'd0;		  
	     s_addr_1 <= 32'd0;
	     s_addr_2 <= 32'd0;
	     s_addr_3 <= m_addr;
	     // write data
	     s_wdata_0 <= 32'd0; 
	     s_wdata_1 <= 32'd0;
	     s_wdata_2 <= 32'd0;
	     s_wdata_3 <= m_wdata;
             // write strub
	     s_wstrb_0 <= 4'd0;
	     s_wstrb_1 <= 4'd0;
	     s_wstrb_2 <= 4'd0;
	     s_wstrb_3 <= m_wstrb;
	     // read data
	     m_rdata <= s_rdata_3;
	     // valid
	     s_valid_0 <= 1'b0;
	     s_valid_1 <= 1'b0;
	     s_valid_2 <= 1'b0;
	     s_valid_3 <= m_valid;
	     // ready
	     m_ready <= s_ready_3;
          end // case: 2'b11         
        endcase
     end                                          
endmodule
