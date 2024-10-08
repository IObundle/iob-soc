// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1 ns / 1 ps

module iob_regfile_2p #(
    parameter N       = 0,           //number of registers
    parameter W       = 0,           //register width
    parameter WDATA_W = 0,           //width of write data
    parameter WADDR_W = 0,           //width of write address
    parameter RDATA_W = 0,           //width of read data
    parameter RADDR_W = 0,           //width of read address
    //cpu interface
    //the address on the cpu side must be a byte address
    parameter DATA_W  = 0,           //width of data
    parameter WSTRB_W = WDATA_W / 8  //width of write strobe
) (
    `include "iob_regfile_2p_clk_en_rst_s_port.vs"
    input                                              wen_i,
    input  [((RADDR_W+WADDR_W)+(WSTRB_W+WDATA_W))-1:0] req_i,
    output [                              RDATA_W-1:0] resp_o
);

  //register file and register file write enable
  wire [(N*W)-1 : 0] regfile;
  wire [      N-1:0] wen;

  //reconstruct write address from waddr_i and wstrb_i
  wire [WSTRB_W-1:0] wstrb = req_i[WDATA_W+:WSTRB_W];
  wire [WADDR_W-1:0] waddr = req_i[WSTRB_W+WDATA_W+:WADDR_W];
  localparam WADDR_INT_W = (WADDR_W > ($clog2(
      DATA_W / 8
  ) + 1)) ? WADDR_W : ($clog2(
      DATA_W / 8
  ) + 1);
  wire [($clog2(DATA_W/8)+1)-1:0] waddr_incr;
  wire [         WADDR_INT_W-1:0] waddr_int = waddr + waddr_incr;

  iob_ctls #(
      .W     (DATA_W / 8),
      .MODE  (0),
      .SYMBOL(0)
  ) iob_ctls_txinst (
      .data_i (wstrb),
      .count_o(waddr_incr)
  );

  //write register file
  wire [WDATA_W-1:0] wdata_int = req_i[WDATA_W-1:0];
  genvar row_sel;
  genvar col_sel;

  localparam LAST_I = (N / WSTRB_W) * WSTRB_W;
  localparam REM_I = (N - LAST_I) + 1;

  generate
    for (row_sel = 0; row_sel < N; row_sel = row_sel + WSTRB_W) begin : g_rows
      for (
          col_sel = 0; col_sel < ((row_sel == LAST_I) ? REM_I : WSTRB_W); col_sel = col_sel + 1
      ) begin : g_columns
        if ((row_sel + col_sel) < N) begin : g_if
          assign wen[row_sel+col_sel] = wen_i & (waddr_int == (row_sel + col_sel)) & wstrb[col_sel];
          iob_reg_e #(
              .DATA_W (W),
              .RST_VAL({W{1'b0}})
          ) iob_reg_inst (
              `include "iob_regfile_2p_clk_en_rst_s_s_portmap.vs"
              .en_i  (wen[row_sel+col_sel]),
              .data_i(wdata_int[(col_sel*8)+:W]),
              .data_o(regfile[(row_sel+col_sel)*W+:W])
          );
        end
      end
    end
  endgenerate

  //read register file
  generate
    if (RADDR_W > 0) begin : g_read
      wire [RADDR_W-1:0] raddr = req_i[(WSTRB_W+WDATA_W)+WADDR_W+:RADDR_W];
      assign resp_o = regfile[RDATA_W*raddr+:RDATA_W];
    end else begin : g_read
      assign resp_o = regfile;
    end
  endgenerate

endmodule
