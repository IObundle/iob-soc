// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps
module iob_ctls_tb;

   localparam W = 8;

   reg     [      W-1:0] data_i = 1;
   wire    [$clog2(W):0] data_o;

   integer               i;
   integer               fd;

   initial begin
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif

      for (i = 0; i < 2 ** W; i = i + 1) begin
         #10 data_i = i;
      end
      #10 
      $display("%c[1;34m", 27);
      $display("Test completed successfully.");
      $display("%c[0m", 27);
      fd = $fopen("test.log", "w");
      $fdisplay(fd, "Test passed!");
      $fclose(fd);
      $finish();
   end

   iob_ctls #(
      .W(W)
   ) iob_ctls_inst (
      .data_i (data_i),
      .count_o(data_o)
   );

endmodule

