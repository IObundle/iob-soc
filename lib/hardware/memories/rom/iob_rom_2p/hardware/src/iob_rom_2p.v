// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

module iob_rom_2p #(
   parameter HEXFILE = "none",
   parameter DATA_W  = 0,
   parameter ADDR_W  = 0
) (
   input clk_i,

   //read port 1
   input               r1_en_i,
   input  [ADDR_W-1:0] r1_addr_i,
   output              r1_ready_o,

   //read port 2
   input               r2_en_i,
   input  [ADDR_W-1:0] r2_addr_i,
   output              r2_ready_o,

   output [DATA_W-1:0] r_data_o
);

   wire              en_int;
   wire [ADDR_W-1:0] addr_int;

   // Internal Single Port ROM
   iob_rom_sp #(
      .HEXFILE(HEXFILE),
      .DATA_W (DATA_W),
      .ADDR_W (ADDR_W)
   ) iob_rom_sp_inst (
      .clk_i   (clk_i),
      .r_en_i  (en_int),
      .addr_i  (addr_int),
      .r_data_o(r_data_o)
   );

   assign en_int     = r1_en_i | r2_en_i;
   assign addr_int   = r1_en_i ? r1_addr_i : r2_addr_i;
   assign r1_ready_o = 1'b1;
   assign r2_ready_o = ~r1_en_i;

endmodule
