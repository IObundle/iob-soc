// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

module iob_fifo_async #(
    parameter W_DATA_W = 21,
    parameter R_DATA_W = 21,
    parameter ADDR_W = 3,  //higher ADDR_W lower DATA_W
    //determine W_ADDR_W and R_ADDR_W
    parameter MAXDATA_W = iob_max(W_DATA_W, R_DATA_W),
    parameter MINDATA_W = iob_min(W_DATA_W, R_DATA_W),
    parameter R = MAXDATA_W / MINDATA_W,
    parameter ADDR_W_DIFF = $clog2(R),
    parameter MINADDR_W = ADDR_W - $clog2(R),  //lower ADDR_W (higher DATA_W)
    parameter W_ADDR_W = (W_DATA_W == MAXDATA_W) ? MINADDR_W : ADDR_W,
    parameter R_ADDR_W = (R_DATA_W == MAXDATA_W) ? MINADDR_W : ADDR_W
) (
    `include "iob_fifo_async_io.vs"
);

  `include "iob_functions.vs"

  localparam [ADDR_W:0] FIFO_SIZE = {1'b1, {ADDR_W{1'b0}}};  //in bytes

  //binary read addresses on both domains
  wire [R_ADDR_W:0] r_raddr_bin;
  wire [R_ADDR_W:0] w_raddr_bin;
  wire [W_ADDR_W:0] r_waddr_bin;
  wire [W_ADDR_W:0] w_waddr_bin;

  //normalized binary addresses (for narrower data side)
  wire [  ADDR_W:0] r_raddr_bin_n;
  wire [  ADDR_W:0] r_waddr_bin_n;
  wire [  ADDR_W:0] w_waddr_bin_n;
  wire [  ADDR_W:0] w_raddr_bin_n;

  //assign according to assymetry type
  localparam [ADDR_W-1:0] W_INCR = (W_DATA_W > R_DATA_W) ? 1'b1 << ADDR_W_DIFF : 1'b1;
  localparam [ADDR_W-1:0] R_INCR = (R_DATA_W > W_DATA_W) ? 1'b1 << ADDR_W_DIFF : 1'b1;

  generate
    if (W_DATA_W > R_DATA_W) begin : g_write_wider_bin
      assign w_waddr_bin_n = w_waddr_bin << ADDR_W_DIFF;
      assign w_raddr_bin_n = w_raddr_bin;
      assign r_raddr_bin_n = r_raddr_bin;
      assign r_waddr_bin_n = r_waddr_bin << ADDR_W_DIFF;
    end else if (R_DATA_W > W_DATA_W) begin : g_read_wider_bin
      assign w_waddr_bin_n = w_waddr_bin;
      assign w_raddr_bin_n = w_raddr_bin << ADDR_W_DIFF;
      assign r_raddr_bin_n = r_raddr_bin << ADDR_W_DIFF;
      assign r_waddr_bin_n = r_waddr_bin;
    end else begin : g_write_equals_read_bin
      assign w_raddr_bin_n = w_raddr_bin;
      assign w_waddr_bin_n = w_waddr_bin;
      assign r_waddr_bin_n = r_waddr_bin;
      assign r_raddr_bin_n = r_raddr_bin;
    end
  endgenerate


  //sync write gray address to read domain
  wire [W_ADDR_W:0] w_waddr_gray;
  wire [W_ADDR_W:0] r_waddr_gray;
  iob_sync #(
      .DATA_W (W_ADDR_W + 1),
      .RST_VAL({(W_ADDR_W + 1) {1'd0}})
  ) w_waddr_gray_sync0 (
      .clk_i   (r_clk_i),
      .arst_i  (r_arst_i),
      .signal_i(w_waddr_gray),
      .signal_o(r_waddr_gray)
  );

  //sync read gray address to write domain
  wire [R_ADDR_W:0] r_raddr_gray;
  wire [R_ADDR_W:0] w_raddr_gray;
  iob_sync #(
      .DATA_W (R_ADDR_W + 1),
      .RST_VAL({(R_ADDR_W + 1) {1'd0}})
  ) r_raddr_gray_sync0 (
      .clk_i   (w_clk_i),
      .arst_i  (w_arst_i),
      .signal_i(r_raddr_gray),
      .signal_o(w_raddr_gray)
  );


  //READ DOMAIN FIFO LEVEL
  wire [(ADDR_W+1)-1:0] r_level_int;
  assign r_level_int = r_waddr_bin_n - r_raddr_bin_n;
  assign r_level_o   = r_level_int[0+:(ADDR_W+1)];

  //READ DOMAIN EMPTY AND FULL FLAGS
  assign r_empty_o   = (r_level_int < {2'd0, R_INCR});
  assign r_full_o    = (r_level_int > (FIFO_SIZE - {2'd0, R_INCR}));

  //WRITE DOMAIN FIFO LEVEL
  wire [(ADDR_W+1)-1:0] w_level_int;
  assign w_level_int = w_waddr_bin_n - w_raddr_bin_n;
  assign w_level_o   = w_level_int[0+:(ADDR_W+1)];

  //WRITE DOMAIN EMPTY AND FULL FLAGS
  assign w_empty_o   = (w_level_int < {2'd0, W_INCR});
  assign w_full_o    = (w_level_int > (FIFO_SIZE - {2'd0, W_INCR}));


  //read address gray code counter
  wire r_en_int = (r_en_i & (~r_empty_o));
  iob_gray_counter #(
      .W(R_ADDR_W + 1)
  ) r_raddr_gray_counter (
      .clk_i (r_clk_i),
      .cke_i (r_cke_i),
      .arst_i(r_arst_i),
      .rst_i (r_rst_i),
      .en_i  (r_en_int),
      .data_o(r_raddr_gray)
  );

  //write address gray code counter
  wire w_en_int = (w_en_i & (~w_full_o));
  iob_gray_counter #(
      .W(W_ADDR_W + 1)
  ) w_waddr_gray_counter (
      .clk_i (w_clk_i),
      .cke_i (w_cke_i),
      .arst_i(w_arst_i),
      .rst_i (w_rst_i),
      .en_i  (w_en_int),
      .data_o(w_waddr_gray)
  );

  //convert gray read address to binary
  iob_gray2bin #(
      .DATA_W(R_ADDR_W + 1)
  ) gray2bin_r_raddr (
      .gr_i (r_raddr_gray),
      .bin_o(r_raddr_bin)
  );

  //convert synced gray write address to binary
  iob_gray2bin #(
      .DATA_W(W_ADDR_W + 1)
  ) gray2bin_r_raddr_sync (
      .gr_i (r_waddr_gray),
      .bin_o(r_waddr_bin)
  );

  //convert gray write address to binary
  iob_gray2bin #(
      .DATA_W(W_ADDR_W + 1)
  ) gray2bin_w_waddr (
      .gr_i (w_waddr_gray),
      .bin_o(w_waddr_bin)
  );

  //convert synced gray read address to binary
  iob_gray2bin #(
      .DATA_W(R_ADDR_W + 1)
  ) gray2bin_w_raddr_sync (
      .gr_i (w_raddr_gray),
      .bin_o(w_raddr_bin)
  );

  wire [W_ADDR_W-1:0] w_addr = w_waddr_bin[W_ADDR_W-1:0];
  wire [R_ADDR_W-1:0] r_addr = r_raddr_bin[R_ADDR_W-1:0];

  assign ext_mem_w_clk_o = w_clk_i;
  assign ext_mem_r_clk_o = r_clk_i;

  iob_asym_converter #(
      .W_DATA_W(W_DATA_W),
      .R_DATA_W(R_DATA_W),
      .ADDR_W  (ADDR_W)
  ) asym_converter (
      .ext_mem_w_en_o  (ext_mem_w_en_o),
      .ext_mem_w_addr_o(ext_mem_w_addr_o),
      .ext_mem_w_data_o(ext_mem_w_data_o),
      .ext_mem_r_en_o  (ext_mem_r_en_o),
      .ext_mem_r_addr_o(ext_mem_r_addr_o),
      .ext_mem_r_data_i(ext_mem_r_data_i),
      .clk_i           (r_clk_i),
      .cke_i           (r_cke_i),
      .arst_i          (r_arst_i),
      .rst_i           (r_rst_i),
      .w_addr_i        (w_addr),
      .w_en_i          (w_en_int),
      .w_data_i        (w_data_i),
      .r_addr_i        (r_addr),
      .r_en_i          (r_en_int),
      .r_data_o        (r_data_o)
  );

endmodule
