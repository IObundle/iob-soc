`timescale 1ns / 1ps

module ram #(
	     parameter ADDR_W = 12,
             parameter NAME = "ram"	          
		     )
   (      
          input              clk,
          input [`DATA_W-1:0]  wdata,
          input [ADDR_W-1:0] addr,
          input [3:0]        wstrb,
          output [`DATA_W-1:0] rdata,
          input              valid,
          output reg         ready
	  );
   
   
   // MAIN MEMORY SYSTEM

   // byte 0
   iob_1p_mem  #(
                  .MEM_INIT_FILE({NAME, "_0", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W-2))
   main_mem_byte0
     (
      .data_a   (wdata[7:0]),
      .addr_a   (addr[ADDR_W-1:2]),
      .we_a     (wstrb[0]),
      .q_a      (rdata[7:0]),
      .clk      (clk)
      );

   //byte 1
   iob_1p_mem  #(
                  .MEM_INIT_FILE({NAME, "_1", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W-2))
   main_mem_byte1
     (
      .data_a   (wdata[15:8]),
      .addr_a   (addr[ADDR_W-1:2]),
      .we_a     (wstrb[1]),
      .q_a      (rdata[15:8]),
      .clk      (clk)
      );

   // byte 2
   iob_1p_mem  #(
                  .MEM_INIT_FILE({NAME, "_2", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W-2))
   main_mem_byte2
     (
      .data_a   (wdata[23:16]),
      .addr_a   (addr[ADDR_W-1:2]),
      .we_a     (wstrb[2]),
      .q_a      (rdata[23:16]),
      .clk      (clk)
      );

   //byte 3
   iob_1p_mem  #(
                  .MEM_INIT_FILE({NAME, "_3", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W-2))
   main_mem_byte3
     (
      .data_a   (wdata[31:24]),
      .addr_a   (addr[ADDR_W-1:2]),
      .we_a     (wstrb[3]),
      .q_a      (rdata[31:24]),
      .clk      (clk)
      );

      always @(posedge clk)
        ready <= valid;

endmodule
