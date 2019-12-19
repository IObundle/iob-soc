`include "system.vh"
`timescale 1ns / 1ps

module ram #(
	     parameter ADDR_W = 12, //must be lower than ADDR_W-N_SLAVES_W
             parameter NAME = "ram"	          
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
   

   // byte memories
   // byte 0
   iob_1p_mem  #(
                  .MEM_INIT_FILE({NAME, "_0", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W))
   main_mem_byte0
     (
      .clk           (clk),
      .en            (valid),
      .we            (wstrb[0]),
      .addr          (addr),
      .data_out      (rdata[7:0]),
      .data_in       (wdata[7:0])
      );

   //byte 1
   iob_1p_mem  #(
                  .MEM_INIT_FILE({NAME, "_1", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W))
   main_mem_byte1 (
                   .clk           (clk),
                   .en            (valid),
                   .we            (wstrb[1]),
                   .addr          (addr),
                   .data_out      (rdata[15:8]),
                   .data_in       (wdata[15:8])
                   );

   // byte 2
   iob_1p_mem  #(
                  .MEM_INIT_FILE({NAME, "_2", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W))
   main_mem_byte2 (
                   .clk           (clk),
                   .en            (valid),
                   .we            (wstrb[2]),
                   .addr          (addr),
                   .data_out      (rdata[23:16]),
                   .data_in       (wdata[23:16])
                   );

   //byte 3
   iob_1p_mem  #(
                  .MEM_INIT_FILE({NAME, "_3", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W))
   main_mem_byte3 (
                   .clk           (clk),
                   .en            (valid),
                   .we            (wstrb[3]),
                   .addr          (addr),
                   .data_out      (rdata[31:24]),
                   .data_in       (wdata[31:24])
                   );

   //reply with ready 
   always @(posedge clk, posedge rst)
     if(rst)
       ready <= 1'b0;
     else 
       ready <= valid;

endmodule
