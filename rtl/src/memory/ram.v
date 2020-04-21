`include "system.vh"
`timescale 1ns / 1ps

module ram #(
	     parameter ADDR_W = 12, //must be lower than ADDR_W-N_SLAVES_W
             parameter FILE = "none"
		     )
   (      
          input                clk,
          input                rst,

          //native interface
          //intruction bus
	  input                i_valid,
	  output reg           i_ready, 
	  input [ADDR_W-1:0]   i_addr,
	  output [`DATA_W-1:0] i_rdata,
          //data bus
          input                d_valid,
          output reg           d_ready,
          input [`DATA_W-1:0]  d_wdata,
          input [ADDR_W-1:0]   d_addr,
          input [3:0]          d_wstrb,
          output [`DATA_W-1:0] d_rdata
	  );

   parameter file_suffix = {"3","2","1","0"};
   //parameter file_suffix = "3210"
   
  
   genvar 		       i;

   for (i=0;i<4;i=i+1) 
     begin : gen_main_mem_byte
	iob_t2p_mem  
          #(
	    .MEM_INIT_FILE({FILE, "_", file_suffix[8*(i+1)-1 -: 8], ".dat"}),
	    .DATA_W(8),
            .ADDR_W(ADDR_W))
	main_mem_byte
	  (
	   .clk             (clk),
           
	   .en_a            (d_valid),
	   .we_a            (d_wstrb[i]),
	   .addr_a          (d_addr),
	   .q_a             (d_rdata[8*(i+1)-1 -: 8]),
	   .data_a          (d_wdata[8*(i+1)-1 -: 8]),

	   .en_b            (i_valid),
	   .addr_b          (i_addr),
	   .we_b            (1'b0),
	   .data_b          (8'b0),
	   .q_b             (i_rdata[8*(i+1)-1 -: 8])
	   );	
     end


   //reply with ready 
   always @(posedge clk, posedge rst)
     if(rst) begin
	d_ready <= 1'b0;
	i_ready <= 1'b0;
     end
     else begin 
	d_ready <= d_valid;
	i_ready <= i_valid;
     end
endmodule
