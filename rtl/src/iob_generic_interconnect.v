`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IOBundle
// Engineer: 
// 
// Create Date: 19/08/2019 09:52:41 PM
// Design Name: 
// Module Name: iob_generic_interconnect, memory_mapped_decoder
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


module iob_generic_interconnect#(
				 parameter N_SLAVES = 4,
				 parameter SLAVE_ADDR_W = 2, //must be ceil[log2(N_SLAVES)]
				 parameter ADDR_W = 32,
				 parameter RDATA_W = 32,
				 parameter WDATA_W = 32,
				 parameter STRB_W = 4
			       ) (
			       output [N_SLAVES-1:0] 		   slave_select, 
			       input 				   mem_select,
			       input 				   clk,
			       input 				   sel, //selects the interconnect itself 
			       /////////////////////////////////////  
			       //// master AXI interface //////////
			       ///////////////////////////////////

			       input [ADDR_W-1:0] 		   m_addr,

			       input [WDATA_W-1:0] 		   m_wdata,
			       input [STRB_W-1:0] 		   m_wstrb,
			       output reg [RDATA_W-1:0] 	   m_rdata,

			       input 				   m_valid,
			       output reg 			   m_ready,

			       ///////////////////////////////////
			       //// slave N AXI interface ///////
			       /////////////////////////////////  

			       output reg [(N_SLAVES*ADDR_W)-1:0]  s_addr,

			       output reg [(N_SLAVES*WDATA_W)-1:0] s_wdata,
			       output reg [(N_SLAVES*STRB_W)-1:0]  s_wstrb,
			       input [(N_SLAVES*RDATA_W)-1:0] 	   s_rdata,

			       output reg [N_SLAVES-1:0] 	   s_valid,
			       input [N_SLAVES-1:0] 		   s_ready,
                               );


   wire [SLAVE_ADDR_W-1:0] 					 s_sel;
   assign slave_select = s_sel;


   //Decode the addressed memory
   iob_native_memory_mapped_decoder native_mm_dec (
						   .mem_addr (m_addr),
						   .s_sel    (s_sel )
						   );

   //
   genvar 							 gi;
   generate
      for(gi=0; gi<N_SLAVES;gi=gi+1) begin
	 //contatenate master value for all outputs to the slaves
	 assign s_addr[((gi+1)*ADDR_W)-1:(gi*ADDR_W)] = m_addr; //m_addr
	 assign s_wdata[((gi+1)*ADDR_W)-1:(gi*ADDR_W)] = m_wdata; //m_wdata
	 assign s_wstrb[((gi+1)*ADDR_W)-1:(gi*ADDR_W)] = m_wstrb; //m_wstrb

	 //mask ready with one hot output from decoder
	 assign s_valid[gi] = m_valid && s_sel[gi];

	 //select inputs fr
      end
   endgenerate
   
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
