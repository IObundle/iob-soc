// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1 ns / 1 ps


module iob_regfile_at2p #(
   parameter ADDR_W = 3,
   parameter DATA_W = 21
) (
   // Write Port
   input              w_clk_i,
   input              w_cke_i,
   input              w_arst_i,
   input [ADDR_W-1:0] w_addr_i,
   input [DATA_W-1:0] w_data_i,

   // Read Port
   input               r_clk_i,
   input               r_cke_i,
   input               r_arst_i,
   input  [ADDR_W-1:0] r_addr_i,
   output [DATA_W-1:0] r_data_o
);

   //write
   wire [((2**ADDR_W)*DATA_W)-1:0] regfile_in;
   wire [((2**ADDR_W)*DATA_W)-1:0] regfile_synced;
   wire [         (2**ADDR_W)-1:0] regfile_en;

   genvar addr;
   generate
      for (addr = 0; addr < (2 ** ADDR_W); addr = addr + 1) begin : gen_register_file
         assign regfile_en[addr] = (w_addr_i == addr);
         iob_reg_e #(
            .DATA_W (DATA_W),
            .RST_VAL({DATA_W{1'd0}})
         ) rdata (
            .clk_i (w_clk_i),
            .cke_i (w_cke_i),
            .arst_i(w_arst_i),
            .en_i  (regfile_en[addr]),
            .data_i(w_data_i),
            .data_o(regfile_in[addr*DATA_W+:DATA_W])
         );
      end
   endgenerate


   //sync
   iob_sync #(
      .DATA_W ((2 ** ADDR_W) * DATA_W),
      .RST_VAL({((2 ** ADDR_W) * DATA_W) {1'b0}})
   ) iob_sync_regfile_synced (
      .clk_i   (r_clk_i),
      .arst_i  (r_arst_i),
      .signal_i(regfile_in),
      .signal_o(regfile_synced)
   );

   wire [DATA_W-1:0] r_data = regfile_synced[r_addr_i*DATA_W+:DATA_W];
   //read
   iob_reg #(
      .DATA_W (DATA_W),
      .RST_VAL({DATA_W{1'd0}})
   ) rdata (
      .clk_i (r_clk_i),
      .cke_i (r_cke_i),
      .arst_i(r_arst_i),
      .data_i(r_data),
      .data_o(r_data_o)
   );

endmodule
