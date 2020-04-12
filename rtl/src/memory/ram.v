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
          input [`DATA_W-1:0]  wdata,
          input [ADDR_W-1:0]   addr,
          input [3:0]          wstrb,
          output [`DATA_W-1:0] rdata,
          input                valid,
          output reg           ready
	  );
   
   parameter file_name = (FILE == "none")? "none": {FILE, ".dat"};

   iob_sp_mem_be  #(
                  .FILE(file_name),
                  .ADDR_WIDTH(ADDR_W))
   main_mem
     (
      .clk           (clk),
      .en            (valid),
      .we            (wstrb),
      .addr          (addr),
      .dout          (rdata),
      .din           (wdata)
      );

   //reply with ready 
   always @(posedge clk, posedge rst)
     if(rst)
       ready <= 1'b0;
     else 
       ready <= valid;

endmodule
