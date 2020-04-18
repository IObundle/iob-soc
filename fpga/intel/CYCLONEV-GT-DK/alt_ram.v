`include "system.vh"
`timescale 1ns / 1ps

module ram #(
	     parameter ADDR_W = 12, //must be lower than ADDR_W-N_SLAVES_W
             parameter FILE = "none",
	     parameter FILE_NAME_SIZE = 8
		     )
   (      
          input 	       clk,
          input 	       rst,

          //native interface 
	  input [ADDR_W-1:0]   i_addr,
	  input [3:0] 	       i_en,
	  output [`DATA_W-1:0] i_data,
	  output reg 	       i_ready, 

          input [`DATA_W-1:0]  wdata,
          input [ADDR_W-1:0]   addr,
          input [3:0] 	       wstrb,
          output [`DATA_W-1:0] rdata,
          input 	       valid,
          output reg 	       ready
	  );

   parameter file_name = (FILE == "none")? "none" : {FILE, "_0"};
   parameter init_ram = (FILE == "none")? 0 : 1;
   parameter sufix = (FILE == "none")? "" : ".dat";
   
   genvar 		       i;
   generate
      for (i=0;i<4;i=i+1) 
	begin : gen_main_mem_byte
	   iob_t2p_mem  #(
			  .MEM_INIT_FILE({file_name + i[3:0]*init_ram, sufix}),
			  .DATA_W(8),
			  .ADDR_W(ADDR_W))
	   main_mem_byte
	     (
	      .clk           (clk),
	      .en_a            (valid),
	      .we_a            (wstrb[i]),
	      .addr_a          (addr),
	      .q_a      (rdata[8*(i+1)-1 -: 8]),
	      .data_a       (wdata[8*(i+1)-1 -: 8]),
	      .en_b             (i_en[i]),
	      .addr_b          (i_addr),
	      .we_b            (1'b0),
	      .data_b           (wdata[8*(i+1)-1 -: 8]),
	      .q_b          (i_data[8*(i+1)-1 -: 8])
	      );	
	end
   endgenerate

   //reply with ready 
   always @(posedge clk, posedge rst)
     if(rst) begin
	ready <= 1'b0;
	i_ready <= 1'b0;
     end
     else begin 
	ready <= valid;
	i_ready <= |i_en;
     end
endmodule
