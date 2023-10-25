`timescale 1 ns / 1 ps

module iob_rom_tdp #(
   parameter HEXFILE = "none",
   parameter DATA_W  = 32,
   parameter ADDR_W  = 11
) (
   input                     clk_a_i,
   input      [(ADDR_W-1):0] addr_a_i,
   input                     r_en_a_i,
   output reg [(DATA_W-1):0] r_data_a_o,

   input                     clk_b_i,
   input      [(ADDR_W-1):0] addr_b_i,
   input                     r_en_b_i,
   output reg [(DATA_W-1):0] r_data_b_o
);

   //this allows ISE 14.7 to work; do not remove
   localparam mem_init_file_int = HEXFILE;


   // Declare the ROM
   reg [DATA_W-1:0] rom[2**ADDR_W-1:0];

   // Initialize the ROM
   initial if (mem_init_file_int != "none") $readmemh(mem_init_file_int, rom, 0, 2 ** ADDR_W - 1);

   always @(posedge clk_a_i)  // Port A
      if (r_en_a_i)
         r_data_a_o <= rom[addr_a_i];

   always @(posedge clk_b_i)  // Port B
      if (r_en_b_i)
         r_data_b_o <= rom[addr_b_i];

endmodule
