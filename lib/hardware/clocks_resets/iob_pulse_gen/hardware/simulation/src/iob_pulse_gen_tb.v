// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

module iob_pulse_gen_tb;

   localparam START    = 2;
   localparam DURATION = 10;

   parameter clk_per = 10;  // clk period = 10 timeticks

   reg clk;
   reg rst;
   reg start_i;
   wire pulse_o;

   iob_pulse_gen #(
      .START   (START),
      .DURATION(DURATION)
   ) 
   pulse_gen 
     (
      .clk_i   (clk),
      .arst_i  (rst),
      .cke_i   (1'b1),
      .start_i (start_i),
      .pulse_o (pulse_o)
      );

   integer i;
   integer fd;
   integer duration;
   integer start;
   initial begin
`ifdef VCD
    $dumpfile("uut.vcd");
    $dumpvars();
`endif

      clk     = 0;
      rst     = 1;
      start_i = 0;

      duration= 0;
      start = 0;

      #clk_per rst = 0;

      #clk_per start_i = 1;
      #clk_per start_i = 0;

      @(posedge clk); 
      // wait for pulse to enable
      while(pulse_o == 0) begin
        @(posedge clk);
        start = start + 1;
      end

      while(pulse_o == 1) begin
        duration = duration + 1;
        @(posedge clk);
      end

      if((duration == DURATION) & (start == START)) begin
          $display("%c[1;34m", 27);
          $display("Test completed successfully.");
          $display("%c[0m", 27);
          fd = $fopen("test.log", "w");
          $fdisplay(fd, "Test passed!");
          $fclose(fd);
      end else begin
          $display("Test failed: duration %d\texpected %d", duration, DURATION);
          $display("Test failed: start %d\texpected %d", start, START);
          fd = $fopen("test.log", "w");
          $fdisplay(fd, "Test failed: duration %d\texpected %d", duration, DURATION);
          $fdisplay(fd, "Test failed: start %d\texpected %d", start, START);
          $fclose(fd);


      end
      #(10*clk_per) $finish;
   end // initial begin

   always #(clk_per / 2) clk = ~clk;

endmodule


