`timescale 1ns / 1ps

module main_memory #(
		     parameter ADDR_W = 12	          
		     )
   (      
          input              clk,
          input [`DATA_W:0]  main_mem_write_data,
          input [ADDR_W-1:0] main_mem_addr,
          input [3:0]        main_mem_wstrb,
          output [`DATA_W:0] main_mem_read_data,
          input              main_mem_valid,
          output reg         main_mem_ready
	  );
   
   
   // MAIN MEMORY SYSTEM

   // byte 0
   iob_1p_mem  #(
                  .MEM_INIT_FILE({"firmware", "_0", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W-2))
   main_mem_byte0
     (
      .data_a   (main_mem_write_data[7:0]),
      .addr_a   (main_mem_addr[ADDR_W-1:2]),
      .we_a     (main_mem_wstrb[0]),
      .q_a      (main_mem_read_data[7:0]),
      .clk      (clk)
      );

   //byte 1
   iob_1p_mem  #(
                  .MEM_INIT_FILE({"firmware", "_1", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W-2))
   main_mem_byte1
     (
      .data_a   (main_mem_write_data[15:8]),
      .addr_a   (main_mem_addr[ADDR_W-1:2]),
      .we_a     (main_mem_wstrb[1]),
      .q_a      (main_mem_read_data[15:8]),
      .clk      (clk)
      );

   // byte 2
   iob_1p_mem  #(
                  .MEM_INIT_FILE({"firmware", "_2", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W-2))
   main_mem_byte2
     (
      .data_a   (main_mem_write_data[23:16]),
      .addr_a   (main_mem_addr[ADDR_W-1:2]),
      .we_a     (main_mem_wstrb[2]),
      .q_a      (main_mem_read_data[23:16]),
      .clk      (clk)
      );

   //byte 3
   iob_1p_mem  #(
                  .MEM_INIT_FILE({"firmware", "_3", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W-2))
   main_mem_byte3
     (
      .data_a   (main_mem_write_data[31:24]),
      .addr_a   (main_mem_addr[ADDR_W-1:2]),
      .we_a     (main_mem_wstrb[3]),
      .q_a      (main_mem_read_data[31:24]),
      .clk      (clk)
      );

      always @(posedge clk)
        main_mem_ready <= main_mem_valid;

endmodule
