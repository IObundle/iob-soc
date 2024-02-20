`timescale 1ns / 1ps

module iob_rom_sp #(
   parameter DATA_W  = 8,
   parameter ADDR_W  = 10,
   parameter HEXFILE = "none"
) (
   input                   clk_i,
   input                   r_en_i,
   input      [ADDR_W-1:0] addr_i,
   output reg [DATA_W-1:0] r_data_o
);

   // this allows ISE 14.7 to work; do not remove
   localparam mem_init_file_int = HEXFILE;

   // Declare the ROM
   reg [DATA_W-1:0] rom[(2**ADDR_W)-1:0];

   // Initialize the ROM
   initial if (mem_init_file_int != "none") $readmemh(mem_init_file_int, rom, 0, (2 ** ADDR_W) - 1);

   // Operate the ROM
   always @(posedge clk_i) if (r_en_i) r_data_o <= rom[addr_i];

endmodule
