commit 62a5e83cb9026f96f7e13e4e65fc54e49a3ebcf6
Author: Jose T. de Sousa <jose.t.de.sousa@gmail.com>
Date:   Sun Apr 19 13:19:53 2020 +0100

    towards complete modularity

diff --git a/fpga/intel/CYCLONEV-GT-DK/alt_ram.v b/fpga/intel/CYCLONEV-GT-DK/alt_ram.v
deleted file mode 100644
index a46bc56..0000000
--- a/fpga/intel/CYCLONEV-GT-DK/alt_ram.v
+++ /dev/null
@@ -1,71 +0,0 @@
-`include "system.vh"
-`timescale 1ns / 1ps
-
-module ram #(
-	     parameter ADDR_W = 12, //must be lower than ADDR_W-N_SLAVES_W
-             parameter FILE = "none",
-	     parameter FILE_NAME_SIZE = 8
-		     )
-   (      
-          input 	       clk,
-          input 	       rst,
-
-          //native interface 
-	  input [ADDR_W-1:0]   i_addr,
-	  input [3:0] 	       i_en,
-	  output [`DATA_W-1:0] i_data,
-	  output reg 	       i_ready, 
-
-          input [`DATA_W-1:0]  wdata,
-          input [ADDR_W-1:0]   addr,
-          input [3:0] 	       wstrb,
-          output [`DATA_W-1:0] rdata,
-          input 	       valid,
-          output reg 	       ready
-	  );
-      
-   // FILE is a string with N chars + 6 for the "_x.dat" sufix , each chat takes 8 bits
-   parameter STRLEN = (FILE_NAME_SIZE+6)*8;
-   parameter [STRLEN-1:0] file_name_0 = (FILE == "none")? "none": {FILE, "_0", ".dat"};
-   parameter [STRLEN-1:0] file_name_1 = (FILE == "none")? "none": {FILE, "_1", ".dat"};
-   parameter [STRLEN-1:0] file_name_2 = (FILE == "none")? "none": {FILE, "_2", ".dat"};
-   parameter [STRLEN-1:0] file_name_3 = (FILE == "none")? "none": {FILE, "_3", ".dat"};
-   //concatenate all file_names into a single parameter
-   parameter [4*(STRLEN)-1:0] file_name = {file_name_3, file_name_2, file_name_1, file_name_0};
-
-   genvar 		       i;
-
-   for (i=0;i<4;i=i+1) 
-     begin : gen_main_mem_byte
-	iob_t2p_mem  #(
-		       .MEM_INIT_FILE(file_name[STRLEN*(i+1)-1 -: STRLEN]),
-		       .DATA_W(8),
-                       .ADDR_W(ADDR_W))
-	main_mem_byte
-	  (
-	   .clk           (clk),
-	   .en_a            (valid),
-	   .we_a            (wstrb[i]),
-	   .addr_a          (addr),
-	   .q_a      (rdata[8*(i+1)-1 -: 8]),
-	   .data_a       (wdata[8*(i+1)-1 -: 8]),
-	   .en_b             (i_en[i]),
-	   .addr_b          (i_addr),
-	   .we_b            (1'b0),
-	   .data_b           (wdata[8*(i+1)-1 -: 8]),
-	   .q_b          (i_data[8*(i+1)-1 -: 8])
-	   );	
-     end
-
-
-   //reply with ready 
-   always @(posedge clk, posedge rst)
-     if(rst) begin
-	ready <= 1'b0;
-	i_ready <= 1'b0;
-     end
-     else begin 
-	ready <= valid;
-	i_ready <= |i_en;
-     end
-endmodule
