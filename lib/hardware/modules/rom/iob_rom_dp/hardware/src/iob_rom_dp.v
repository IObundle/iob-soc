`timescale 1 ns / 1 ps

module iob_rom_dp #(
   parameter HEXFILE = "none",
   parameter DATA_W  = 32,
   parameter ADDR_W  = 11
) (
   input clk_i,

   input      [(ADDR_W-1):0] addr_a_i,
   input                     r_en_a_i,
   output reg [(DATA_W-1):0] r_data_a_o,

   input      [(ADDR_W-1):0] addr_b_i,
   input                     r_en_b_i,
   output reg [(DATA_W-1):0] r_data_b_o
);

   //this allows ISE 14.7 to work; do not remove
   localparam MEM_INIT_FILE_INT = HEXFILE;


   // Declare the ROM
   reg [DATA_W-1:0] rom[(2**ADDR_W)-1:0];

   // Initialize the ROM
   initial begin
       if (MEM_INIT_FILE_INT != "none") begin
           $readmemh(MEM_INIT_FILE_INT, rom, 0, (2 ** ADDR_W) - 1);
       end
   end

   always @(posedge clk_i) begin  // Port A
      if (r_en_a_i) begin
         r_data_a_o <= rom[addr_a_i];
      end
   end

   always @(posedge clk_i) begin  // Port B
      if (r_en_b_i) begin
         r_data_b_o <= rom[addr_b_i];
      end
   end

endmodule
