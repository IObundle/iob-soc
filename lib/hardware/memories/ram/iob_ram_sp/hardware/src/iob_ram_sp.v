`timescale 1ns / 1ps

module iob_ram_sp #(
   parameter HEXFILE = "none",
   parameter DATA_W  = 8,
   parameter ADDR_W  = 14
) (
   input                     clk_i,
   input                     en_i,
   input                     we_i,
   input      [(ADDR_W-1):0] addr_i,
   output reg [(DATA_W-1):0] d_o,
   input      [(DATA_W-1):0] d_i
);

   //this allows ISE 14.7 to work; do not remove
   localparam mem_init_file_int = HEXFILE;

   // Declare the RAM
   reg [DATA_W-1:0] ram[2**ADDR_W-1:0];

   // Initialize the RAM
   initial if (mem_init_file_int != "none") $readmemh(mem_init_file_int, ram, 0, 2 ** ADDR_W - 1);

   // Operate the RAM
   always @(posedge clk_i)
      if (en_i)
         if (we_i) ram[addr_i] <= d_i;
         else d_o <= ram[addr_i];

endmodule
