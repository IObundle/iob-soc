`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20/05/2019 16:35:20 PM
// Design Name: 
// Module Name: boot memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module boot_memory #(
		     parameter ADDR_W = 12	          
		     )
   (      
          input 	     clk,
          input [31:0] 	     boot_write_data,
          input [ADDR_W-1:0] boot_addr,
          input [3:0] 	     boot_en,
          output [31:0]      boot_read_data

	  );
   
   

   
   
   // BOOT ROM SYSTEM

   // byte 0
   xalt_1p_mem  #(
                  .MEM_INIT_FILE({"boot", "_0", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W-2))
   boot_byte0
     (
      .data_a   (boot_write_data[7:0]),
      .addr_a   (boot_addr[ADDR_W-1:2]),
      .we_a     (boot_en[0]),
      .q_a      (boot_read_data[7:0]),
      .clk      (clk)
      );

   //byte 1
   xalt_1p_mem  #(
                  .MEM_INIT_FILE({"boot", "_1", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W-2))
   boot_byte1
     (
      .data_a   (boot_write_data[15:8]),
      .addr_a   (boot_addr[ADDR_W-1:2]),
      .we_a     (boot_en[1]),
      .q_a      (boot_read_data[15:8]),
      .clk      (clk)
      );

   // byte 2
   xalt_1p_mem  #(
                  .MEM_INIT_FILE({"boot", "_2", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W-2))
   boot_byte2
     (
      .data_a   (boot_write_data[23:16]),
      .addr_a   (boot_addr[ADDR_W-1:2]),
      .we_a     (boot_en[2]),
      .q_a      (boot_read_data[23:16]),
      .clk      (clk)
      );

   //byte 3
   xalt_1p_mem  #(
                  .MEM_INIT_FILE({"boot", "_3", ".dat"}),
                  .DATA_W(8),
                  .ADDR_W(ADDR_W-2))
   boot_byte3
     (
      .data_a   (boot_write_data[31:24]),
      .addr_a   (boot_addr[ADDR_W-1:2]),
      .we_a     (boot_en[3]),
      .q_a      (boot_read_data[31:24]),
      .clk      (clk)
      );
endmodule
