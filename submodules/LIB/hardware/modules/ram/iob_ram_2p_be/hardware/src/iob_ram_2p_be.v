// 2p BRAM with Byte-wide Write Enable

`timescale 1ns / 1ps
`include "bsp.vh"

module iob_ram_2p_be #(
   parameter HEXFILE = "none",
   parameter DATA_W  = 0,
   parameter ADDR_W  = 0
) (
   input clk_i,

   //write port
   input [DATA_W/8-1:0] w_en_i,
   input [  ADDR_W-1:0] w_addr_i,
   input [  DATA_W-1:0] w_data_i,

   //read port
   input                   r_en_i,
   input      [ADDR_W-1:0] r_addr_i,
   output reg [DATA_W-1:0] r_data_o
);

   localparam COL_W = 8;
   localparam NUM_COL = DATA_W / COL_W;

`ifdef IOB_MEM_NO_READ_ON_WRITE
   localparam file_suffix = {"7", "6", "5", "4", "3", "2", "1", "0"};

   genvar i;
   generate
      for (i = 0; i < NUM_COL; i = i + 1) begin : ram_col
         localparam mem_init_file_int = (HEXFILE != "none") ?
             {HEXFILE, "_", file_suffix[8*(i+1)-1-:8], ".hex"} : "none";

         iob_ram_2p #(
            .HEXFILE(mem_init_file_int),
            .ADDR_W (ADDR_W),
            .DATA_W (COL_W)
         ) ram (
            .clk_i(clk_i),

            .w_en_i  (w_en_i[i]),
            .w_addr_i(w_addr_i),
            .w_data_i(w_data_i[i*COL_W+:COL_W]),
            .r_en_i  (r_en_i),
            .r_addr_i(r_addr_i),
            .r_data_o(r_data_o[i*COL_W+:COL_W])
         );
      end
   endgenerate
`else  // !IOB_MEM_NO_READ_ON_WRITE
   //this allows ISE 14.7 to work; do not remove
   localparam mem_init_file_int = HEXFILE;

   // Declare the RAM
   reg [DATA_W-1:0] mem[(2**ADDR_W)-1:0];

   // Initialize the RAM
   initial if (mem_init_file_int != "none") $readmemh(mem_init_file_int, mem, 0, (2 ** ADDR_W) - 1);

   //read port
   always @(posedge clk_i) if (r_en_i) r_data_o <= mem[r_addr_i];

   //write port
   integer i;
   always @(posedge clk_i) begin
      for (i = 0; i < NUM_COL; i = i + 1) begin
         if (w_en_i[i]) begin
            mem[w_addr_i][i*COL_W+:COL_W] <= w_data_i[i*COL_W+:COL_W];
         end
      end
   end
`endif

endmodule
