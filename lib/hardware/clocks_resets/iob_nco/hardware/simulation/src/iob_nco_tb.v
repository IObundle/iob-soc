// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

`include "iob_nco_conf.vh"
`include "iob_nco_csrs_def.vh"

`define IOB_NBYTES (DATA_W/8)
`define IOB_GET_NBYTES(WIDTH) (WIDTH/8 + |(WIDTH%8))
`define IOB_NBYTES_W $clog2(`IOB_NBYTES)

`define IOB_WORD_ADDR(ADDR) ((ADDR>>`IOB_NBYTES_W)<<`IOB_NBYTES_W)

`define IOB_BYTE_OFFSET(ADDR) (ADDR%(DATA_W/8))

`define IOB_GET_WDATA(ADDR, DATA) (DATA<<(8*`IOB_BYTE_OFFSET(ADDR)))
`define IOB_GET_WSTRB(ADDR, WIDTH) (((1<<`IOB_GET_NBYTES(WIDTH))-1)<<`IOB_BYTE_OFFSET(ADDR))
`define IOB_GET_RDATA(ADDR, DATA, WIDTH) ((DATA>>(8*`IOB_BYTE_OFFSET(ADDR)))&((1<<WIDTH)-1))

module iob_nco_tb;

  integer fd;

  localparam CLK_PER = 10;
  localparam ADDR_W = `IOB_NCO_CSRS_ADDR_W;
  localparam DATA_W = 32;


  reg clk = 1;

  // Drive clock
  always #(CLK_PER / 2) clk = ~clk;

  reg                             cke = 1'b1;
  reg                             arst;


  wire                            clk_out;

  //IOb-Native interface
  reg                             iob_valid_i;
  reg  [`IOB_NCO_CSRS_ADDR_W-1:0] iob_addr_i;
  reg  [     `IOB_NCO_DATA_W-1:0] iob_wdata_i;
  reg  [                     3:0] iob_wstrb_i;
  wire [     `IOB_NCO_DATA_W-1:0] iob_rdata_o;
  wire                            iob_ready_o;
  wire                            iob_rvalid_o;

  initial begin

`ifdef VCD
    $dumpfile("uut.vcd");
    $dumpvars();
`endif

    //init cpu bus signals
    iob_valid_i = 0;
    iob_wstrb_i = 0;

    // Reset signal
    arst = 0;
    #100 arst = 1;
    #1_000 arst = 0;
    #100;
    @(posedge clk) #1;

    IOB_NCO_SET_SOFTRESET(1'b1);
    IOB_NCO_SET_SOFTRESET(1'b0);

    IOB_NCO_SET_PERIOD(16'h1280);
    IOB_NCO_SET_ENABLE(1'b1);

    $display("%c[1;34m", 27);
    $display("Test completed successfully.");
    $display("%c[0m", 27);
    fd = $fopen("test.log", "w");
    $fdisplay(fd, "Test passed!");
    $fclose(fd);
    #1000 $finish();

  end

  iob_nco nco (
      `include "iob_nco_clk_en_rst_s_portmap.vs"
      `include "iob_nco_iob_s_s_portmap.vs"
      .clk_in_i(clk),
      .clk_out_o(clk_out)
  );

  `include "iob_nco_csrs_emb_tb.vs"

  `include "iob_tasks.vs"

endmodule
