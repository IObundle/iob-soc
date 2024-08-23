// True-Dual-Port BRAM with Byte-wide Write Enable
// Read-First mode 

`timescale 1 ns / 1 ps
`include "bsp.vh"

module iob_ram_tdp_be #(
   parameter HEXFILE = "none",
   parameter ADDR_W  = 10,      // Addr Width in bits : 2*ADDR_W = RAM Depth
   parameter DATA_W  = 32       // Data Width in bits
) (
   // Port A
   input                 clkA_i,
   input                 enA_i,
   input  [DATA_W/8-1:0] weA_i,
   input  [  ADDR_W-1:0] addrA_i,
   input  [  DATA_W-1:0] dA_i,
   output [  DATA_W-1:0] dA_o,

   // Port B
   input                 clkB_i,
   input                 enB_i,
   input  [DATA_W/8-1:0] weB_i,
   input  [  ADDR_W-1:0] addrB_i,
   input  [  DATA_W-1:0] dB_i,
   output [DATA_W-1 : 0] dB_o
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

         iob_ram_tdp #(
            .HEXFILE(mem_init_file_int),
            .ADDR_W (ADDR_W),
            .DATA_W (COL_W)
         ) ram (
            .clkA_i (clkA_i),
            .enA_i  (enA_i),
            .addrA_i(addrA_i),
            .dA_i   (dA_i[i*COL_W+:COL_W]),
            .weA_i  (weA_i[i]),
            .dA_o   (dA_o[i*COL_W+:COL_W]),

            .clkB_i (clkB_i),
            .enB_i  (enB_i),
            .addrB_i(addrB_i),
            .dB_i   (dB_i[i*COL_W+:COL_W]),
            .weB_i  (weB_i[i]),
            .dB_o   (dB_o[i*COL_W+:COL_W])
         );
      end
   endgenerate
`else  // !IOB_MEM_NO_READ_ON_WRITE
   // this allow ISE 14.7 to work; do not remove
   localparam mem_init_file_int = {HEXFILE, ".hex"};

   // Core Memory
   reg [DATA_W-1:0] ram_block[(2**ADDR_W)-1:0];

   // Initialize the RAM
   initial
      if (mem_init_file_int != "none.hex")
         $readmemh(mem_init_file_int, ram_block, 0, 2 ** ADDR_W - 1);

   // Port-A Operation
   reg     [DATA_W-1:0] dA_o_int;
   integer              i;
   always @(posedge clkA_i) begin
      if (enA_i) begin
         for (i = 0; i < NUM_COL; i = i + 1) begin
            if (weA_i[i]) begin
               ram_block[addrA_i][i*COL_W+:COL_W] <= dA_i[i*COL_W+:COL_W];
            end
         end
         dA_o_int <= ram_block[addrA_i];  // Send Feedback
      end
   end

   assign dA_o = dA_o_int;

   // Port-B Operation
   reg     [DATA_W-1:0] dB_o_int;
   integer              j;
   always @(posedge clkB_i) begin
      if (enB_i) begin
         for (j = 0; j < NUM_COL; j = j + 1) begin
            if (weB_i[j]) begin
               ram_block[addrB_i][j*COL_W+:COL_W] <= dB_i[j*COL_W+:COL_W];
            end
         end
         dB_o_int <= ram_block[addrB_i];  // Send Feedback
      end
   end

   assign dB_o = dB_o_int;
`endif

endmodule
