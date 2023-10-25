// Dual-Port BRAM with Byte-wide Write Enable
// Read-First mode 

`timescale 1 ns / 1 ps

module iob_ram_dp_be #(
   parameter HEXFILE              = "none",
   parameter ADDR_W               = 10,      // Addr Width in bits : 2*ADDR_W = RAM Depth
   parameter DATA_W               = 32,      // Data Width in bits
   parameter MEM_NO_READ_ON_WRITE = 0        //no simultaneous read/write
) (
   input clk_i,

   // Port A
   input                 enA_i,
   input  [DATA_W/8-1:0] weA_i,
   input  [  ADDR_W-1:0] addrA_i,
   input  [  DATA_W-1:0] dA_i,
   output [  DATA_W-1:0] dA_o,

   // Port B
   input                 enB_i,
   input  [DATA_W/8-1:0] weB_i,
   input  [  ADDR_W-1:0] addrB_i,
   input  [  DATA_W-1:0] dB_i,
   output [DATA_W-1 : 0] dB_o
);

   localparam COL_W = DATA_W / 4;
   localparam NUM_COL = DATA_W / COL_W;

   localparam file_suffix = {"7", "6", "5", "4", "3", "2", "1", "0"};

   genvar index;
   generate
      for (index = 0; index < NUM_COL; index = index + 1) begin : ram_col
         localparam mem_init_file_int = (HEXFILE != "none") ?
             {HEXFILE, "_", file_suffix[8*(index+1)-1-:8], ".hex"} : "none";
         iob_ram_dp #(
            .HEXFILE             (mem_init_file_int),
            .ADDR_W              (ADDR_W),
            .DATA_W              (COL_W),
            .MEM_NO_READ_ON_WRITE(MEM_NO_READ_ON_WRITE)
         ) ram (
            .clk_i(clk_i),

            .enA_i  (enA_i),
            .addrA_i(addrA_i),
            .dA_i   (dA_i[index*COL_W+:COL_W]),
            .weA_i  (weA_i[index]),
            .dA_o   (dA_o[index*COL_W+:COL_W]),

            .enB_i  (enB_i),
            .addrB_i(addrB_i),
            .dB_i   (dB_i[index*COL_W+:COL_W]),
            .weB_i  (weB_i[index]),
            .dB_o   (dB_o[index*COL_W+:COL_W])
         );
      end
   endgenerate

endmodule
