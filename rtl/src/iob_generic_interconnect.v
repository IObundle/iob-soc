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


module iob_generic_interconnect #(
				 parameter N_SLAVES = 4,
				 parameter SLAVE_ADDR_W = 2, //must be ceil[log2(N_SLAVES)]
				 parameter ADDR_W = 32,
				 parameter RDATA_W = 32,
				 parameter WDATA_W = 32,
				 parameter STRB_W = 4
				 ) 
   (
    output [SLAVE_ADDR_W-1:0] 	    slave_select, 
    input 			    mem_select,
    input 			    clk,
    input 			    sel, //selects the interconnect itself 
    /////////////////////////////////////  
    //// master AXI interface //////////
    ///////////////////////////////////
    input [ADDR_W-1:0] 		    m_addr,

    input [WDATA_W-1:0] 	    m_wdata,
    input [STRB_W-1:0] 		    m_wstrb,
    output [RDATA_W-1:0] 	    m_rdata,

    input 			    m_valid,
    output 			    m_ready,
    ///////////////////////////////////
    //// N Slaves AXI interface //////
    /////////////////////////////////  

    output [(N_SLAVES*ADDR_W)-1:0]  s_addr,

    output [(N_SLAVES*WDATA_W)-1:0] s_wdata,

    output [(N_SLAVES*STRB_W)-1:0]  s_wstrb,
    input [(N_SLAVES*RDATA_W)-1:0]  s_rdata,

    output [N_SLAVES-1:0] 	    s_valid,
    input [N_SLAVES-1:0] 	    s_ready
    );
   
   
   wire [SLAVE_ADDR_W-1:0] 		s_sel_r;
   wire [N_SLAVES-1 : 0] 		s_sel_wr;
   
   assign slave_select = s_sel_r;

   //Decode the addressed memory
   iob_native_memory_mapped_decoder #(
				      .SLAVES_ADDR_W(SLAVE_ADDR_W),
				      .N_SLAVES(N_SLAVES),
				      .ADDR_W(ADDR_W)
				      )
   native_mm_dec (
		  .mem_addr   (m_addr),
		  .mem_sel    (mem_select),
		  .s_sel_wr   (s_sel_wr),
		  .s_sel_r    (s_sel_r)
		  );
   
   //
   genvar 				gi;
   generate
      for(gi=0; gi<N_SLAVES;gi=gi+1) begin: SLAVESEL
	 //contatenate master value for all outputs to the slaves
	 assign s_addr[((gi+1)*ADDR_W)-1 -: ADDR_W] = m_addr; //m_addr
	 assign s_wdata[((gi+1)*WDATA_W)-1 -: WDATA_W] = m_wdata; //m_wdata
	 assign s_wstrb[((gi+1)*STRB_W)-1 -: STRB_W] = m_wstrb & {STRB_W{s_sel_wr[gi]}}; //m_wstrb

	 //mask ready with one hot output from decoder
	 assign s_valid[gi] = m_valid & s_sel_wr[gi];
	 
      end
   endgenerate

    //select inputs from slave being read
   assign m_rdata = s_rdata[((s_sel_r+1)*RDATA_W)-1 -: RDATA_W];

   assign m_ready = s_ready[s_sel_r];
                      
endmodule
