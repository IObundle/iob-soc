`timescale 1ns / 1ps

module iob_ram_2p #(
   parameter HEXFILE = "none",
   parameter DATA_W  = 0,
   parameter ADDR_W  = 0
) (
   input clk_i,

   //write port
   input              w_en_i,
   input [ADDR_W-1:0] w_addr_i,
   input [DATA_W-1:0] w_data_i,

   //read port
   input               r_en_i,
   input  [ADDR_W-1:0] r_addr_i,
   output [DATA_W-1:0] r_data_o
);

   //this allows ISE 14.7 to work; do not remove
   localparam MEM_INIT_FILE_INT = HEXFILE;

   // Declare the RAM
   reg [DATA_W-1:0] mem    [(2**ADDR_W)-1:0];

   reg [DATA_W-1:0] r_data;
   // Initialize the RAM
   initial begin
       if (MEM_INIT_FILE_INT != "none") begin
           $readmemh(MEM_INIT_FILE_INT, mem, 0, (2 ** ADDR_W) - 1);
       end
   end

   //read port
   always @(posedge clk_i) begin
       if (r_en_i) begin
           r_data <= mem[r_addr_i];
       end
   end

   //write port
   always @(posedge clk_i) begin
       if (w_en_i) begin
           mem[w_addr_i] <= w_data_i;
       end
   end

   assign r_data_o = r_data;

endmodule
