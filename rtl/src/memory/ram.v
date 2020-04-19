`include "system.vh"
`timescale 1ns / 1ps

module ram #(
	     parameter ADDR_W = 12, //must be lower than ADDR_W-N_SLAVES_W
             parameter FILE = "none",
	     parameter FILE_NAME_SIZE = 8
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
      
   // FILE is a string with N chars + 6 for the "_x.dat" sufix , each chat takes 8 bits
   parameter STRLEN = (FILE_NAME_SIZE+6)*8;
   parameter [STRLEN-1:0] file_name_0 = (FILE == "none")? "none": {FILE, "_0", ".dat"};
   parameter [STRLEN-1:0] file_name_1 = (FILE == "none")? "none": {FILE, "_1", ".dat"};
   parameter [STRLEN-1:0] file_name_2 = (FILE == "none")? "none": {FILE, "_2", ".dat"};
   parameter [STRLEN-1:0] file_name_3 = (FILE == "none")? "none": {FILE, "_3", ".dat"};
   //concatenate all file_names into a single parameter
   parameter [4*(STRLEN)-1:0] file_name = {file_name_3, file_name_2, file_name_1, file_name_0};

   genvar 		       i;

   for (i=0;i<4;i=i+1) 
     begin : gen_main_mem_byte
	iob_t2p_mem  #(
		       .MEM_INIT_FILE(file_name[STRLEN*(i+1)-1 -: STRLEN]),
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
