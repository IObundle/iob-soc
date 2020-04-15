`include "system.vh"
`timescale 1ns / 1ps

module ram #(
	     parameter ADDR_W = 12, //must be lower than ADDR_W-N_SLAVES_W
             parameter FILE = "none"	          
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
   
   // byte memories
   // byte 0
   parameter file_name_0 = (FILE == "none")? "none": {FILE, "_0", ".dat"};
   iob_t2p_mem  #(
                  .MEM_INIT_FILE(file_name_0),
		  .DATA_W(8),
                  .ADDR_W(ADDR_W))
   main_mem_byte0
     (
      .clk           (clk),
      .en_a            (valid),
      .we_a            (wstrb[0]),
      .addr_a          (addr),
      .q_a      (rdata[7:0]),
      .data_a       (wdata[7:0]),
      .en_b             (i_en[0]),
      .addr_b          (i_addr),
      .we_b            (1'b0),
      .data_b           (wdata[7:0]),
      .q_b          (i_data[7:0])
      );

   //byte 1
   parameter file_name_1 = (FILE == "none")? "none": {FILE, "_1", ".dat"};
   iob_t2p_mem  #(
                  .MEM_INIT_FILE(file_name_1),
		  .DATA_W(8),
                  .ADDR_W(ADDR_W))
   main_mem_byte1
     (
      .clk           (clk),
      .en_a            (valid),
      .we_a            (wstrb[1]),
      .addr_a          (addr),
      .q_a      (rdata[15:8]),
      .data_a       (wdata[15:8]),
      .en_b             (i_en[1]),
      .addr_b          (i_addr),
      .we_b            (1'b0),
      .data_b           (wdata[15:8]),
      .q_b          (i_data[15:8])
      );
   
   // byte 2
   parameter file_name_2 = (FILE == "none")? "none": {FILE, "_2", ".dat"};
   iob_t2p_mem  #(
                  .MEM_INIT_FILE(file_name_2),
		  .DATA_W(8),
                  .ADDR_W(ADDR_W))
   main_mem_byte2
     (
      .clk           (clk),
      .en_a            (valid),
      .we_a            (wstrb[2]),
      .addr_a          (addr),
      .q_a      (rdata[23:16]),
      .data_a       (wdata[23:16]),
      .en_b             (i_en[2]),
      .addr_b          (i_addr),
      .we_b            (1'b0),
      .data_b           (wdata[23:16]),
      .q_b          (i_data[23:16])
      );
   
   //byte 3
   parameter file_name_3 = (FILE == "none")? "none": {FILE, "_3", ".dat"};
   iob_t2p_mem  #(
                  .MEM_INIT_FILE(file_name_3),
		  .DATA_W(8),
                  .ADDR_W(ADDR_W))
   main_mem_byte3
     (
      .clk           (clk),
      .en_a            (valid),
      .we_a            (wstrb[3]),
      .addr_a          (addr),
      .q_a      (rdata[31:24]),
      .data_a       (wdata[31:24]),
      .en_b             (i_en[3]),
      .addr_b          (i_addr),
      .we_b            (1'b0),
      .data_b           (wdata[31:24]),
      .q_b          (i_data[31:24])
      );

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
