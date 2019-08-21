`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2019 11:36:02 AM
// Design Name: 
// Module Name: ddr_memory
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

module ddr_memory #(
		    parameter ADDR_W = 30	          
		    )
   (      
          input 	     clk,
          input [31:0] 	     main_mem_write_data,
          input [ADDR_W-1:0] main_mem_addr,
          input [3:0] 	     main_mem_en,
          output [31:0]      main_mem_read_data

	  );
   
   

   
   
   // MAIN MEMORY SYSTEM

   // byte 0
   xalt_1p_mem_no_initialization  #(
				    .DATA_W(8),
				    .ADDR_W(ADDR_W))
   ddr_mem_byte0
     (
      .data_a   (main_mem_write_data[7:0]),
      .addr_a   (main_mem_addr[ADDR_W-1:0]),
      .we_a     (main_mem_en[0]),
      .q_a      (main_mem_read_data[7:0]),
      .clk      (clk)
      );

   //byte 1
   xalt_1p_mem_no_initialization  #(
				    .DATA_W(8),
				    .ADDR_W(ADDR_W))
   ddr_mem_byte1
     (
      .data_a   (main_mem_write_data[15:8]),
      .addr_a   (main_mem_addr[ADDR_W-1:0]),
      .we_a     (main_mem_en[1]),
      .q_a      (main_mem_read_data[15:8]),
      .clk      (clk)
      );

   // byte 2
   xalt_1p_mem_no_initialization  #(
				    .DATA_W(8),
				    .ADDR_W(ADDR_W))
   ddr_mem_byte2
     (
      .data_a   (main_mem_write_data[23:16]),
      .addr_a   (main_mem_addr[ADDR_W-1:0]),
      .we_a     (main_mem_en[2]),
      .q_a      (main_mem_read_data[23:16]),
      .clk      (clk)
      );

   //byte 3
   xalt_1p_mem_no_initialization  #(
				    .DATA_W(8),
				    .ADDR_W(ADDR_W))
   ddr_mem_byte3
     (
      .data_a   (main_mem_write_data[31:24]),
      .addr_a   (main_mem_addr[ADDR_W-1:0]),
      .we_a     (main_mem_en[3]),
      .q_a      (main_mem_read_data[31:24]),
      .clk      (clk)
      );
endmodule
