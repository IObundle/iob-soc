`timescale 1ns / 1ps

module iob_ram_2p #(
   parameter HEXFILE  = "none",
   parameter DATA_W   = 0,
   parameter ADDR_W   = 0,
   parameter WRITE_FIRST = 1 // 0: read first | 1: write first
) (
   input clk_i,

   //write port
   input              w_en_i,
   input [ADDR_W-1:0] w_addr_i,
   input [DATA_W-1:0] w_data_i,
   output             w_ready_o,

   //read port
   input               r_en_i,
   input  [ADDR_W-1:0] r_addr_i,
   output [DATA_W-1:0] r_data_o,
   output              r_ready_o
);

   wire en_int;
   wire we_int;
   wire [ADDR_W-1:0] addr_int;

   // Internal Single Port RAM
   iob_ram_sp #(
      .HEXFILE(HEXFILE),
      .DATA_W(DATA_W),
      .ADDR_W(ADDR_W)
   ) iob_ram_sp_inst (
      .clk_i (clk_i),
      .en_i  (en_int),
      .we_i  (we_int),
      .addr_i(addr_int),
      .d_i   (w_data_i),
      .d_o   (r_data_o)
   );

   generate
    if (WRITE_FIRST) begin : write_first
        assign en_int = w_en_i | r_en_i;
        assign we_int = w_en_i;
        assign addr_int = w_en_i ? w_addr_i : r_addr_i;
        assign w_ready_o = 1'b1;
        assign r_ready_o = ~w_en_i;
    end else begin : read_first
        assign en_int = w_en_i | r_en_i;
        assign we_int = w_en_i & (~r_en_i);
        assign addr_int = r_en_i ? r_addr_i : w_addr_i;
        assign w_ready_o = ~r_en_i;
        assign r_ready_o = 1'b1;
    end
   endgenerate

endmodule
