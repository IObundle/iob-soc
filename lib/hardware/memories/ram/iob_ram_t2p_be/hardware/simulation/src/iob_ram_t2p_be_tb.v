// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

`define DATA_W 8
`define ADDR_W 4

module iob_ram_t2p_be_tb;

   // Inputs
   reg                clk;

   // Write signals
   reg                w_en;
   reg  [`DATA_W-1:0] w_data;
   reg  [`ADDR_W-1:0] w_addr;


   // Read signals
   reg                r_en;
   reg  [`ADDR_W-1:0] r_addr;
   wire [`DATA_W-1:0] r_data;

   integer i, seq_ini;
   integer fd;

   parameter clk_per = 10;  // clk period = 10 timeticks

   initial begin
      clk     = 1;
      r_en    = 0;
      w_en    = 0;
      r_addr  = 0;
      w_addr  = 0;
      w_data  = 0;

      // Number from which to start the incremental sequence to write into the RAM
      seq_ini = 32;

      // optional VCD
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif

      @(posedge clk) #1;
      w_en = 1;

      // Write all the locations of RAM
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         w_data = i + seq_ini;
         w_addr = i;
         @(posedge clk) #1;
      end

      w_en = 0;
      @(posedge clk) #1;

      // Read all the locations of RAM with r_en = 0
      r_en = 0;
      @(posedge clk) #1;

      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         r_addr = i;
         @(posedge clk) #1;
         if (r_data != 0) begin
            $display("ERROR: with r_en = 0, at position %0d, r_data should be 0 but is %d", i,
                     r_data);
            $fatal();
         end
      end

      r_en = 1;
      @(posedge clk) #1;

      // Read all the locations of RAM with r_en = 1
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         r_addr = i;
         @(posedge clk) #1;
         if (r_data != i + seq_ini) begin
            $display("ERROR: on position %0d, r_data is %d where it should be %0d", i, r_data,
                     i + seq_ini);
            $fatal();
         end
      end

      r_en = 0;

      #(5 * clk_per);
      $display("%c[1;34m", 27);
      $display("Test completed successfully.");
      $display("%c[0m", 27);
      fd = $fopen("test.log", "w");
      $fdisplay(fd, "Test passed!");
      $fclose(fd);
      $finish();
   end

   // Instantiate the Unit Under Test (UUT)
   iob_ram_t2p_be #(
      .DATA_W(`DATA_W),
      .ADDR_W(`ADDR_W)
   ) uut (
      .clk_i(clk),

      .w_en_i  (w_en),
      .w_addr_i(w_addr),
      .w_data_i(w_data),

      .r_en_i  (r_en),
      .r_addr_i(r_addr),
      .r_data_o(r_data)
   );

   // Clock
   always #(clk_per / 2) clk = ~clk;

endmodule
