// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

`define DATA_W 8
`define ADDR_W 4

module iob_ram_tdp_tb;

   // Inputs
   reg               clk;

   reg [`DATA_W-1:0] data_a;
   reg [`ADDR_W-1:0] addr_a;
   reg               en_a;
   reg               we_a;

   reg [`DATA_W-1:0] data_b;
   reg [`ADDR_W-1:0] addr_b;
   reg               en_b;
   reg               we_b;

   // Outputs
   reg [`DATA_W-1:0] q_a;
   reg [`DATA_W-1:0] q_b;

   integer i, seq_ini;
   integer fd;

   parameter clk_per = 10;  // clk period = 10 timeticks

   initial begin
      // optional VCD
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif

      // Initialize Inputs
      clk     = 1;

      data_a  = 0;
      addr_a  = 0;
      en_a    = 0;
      we_a    = 0;

      data_b  = 0;
      addr_b  = 0;
      en_b    = 0;
      we_b    = 0;

      // Number from which to start the incremental sequence to write into the RAM
      seq_ini = 32;

      #clk_per;
      @(posedge clk) #1;
      en_a = 1;

      // Write into port A and read from it
      @(posedge clk) #1;
      we_a = 1;

      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         addr_a = i;
         data_a = i + seq_ini;
         @(posedge clk) #1;
      end

      @(posedge clk) #1;
      we_a = 0;

      @(posedge clk) #1;
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         addr_a = i;
         @(posedge clk) #1;
         if (i + seq_ini != q_a) begin
            $display("ERROR: write error in port A position %d, where data=%h but q_a=%h", i,
                     i + seq_ini, q_a);
            $fatal();
         end
      end

      // Number from which to start the incremental sequence to write into the RAM
      seq_ini = 64;

      @(posedge clk) #1;
      en_b = 1;

      // Write into port B and read from it
      @(posedge clk) #1;
      we_b = 1;

      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         addr_b = i;
         data_b = i + seq_ini;
         @(posedge clk) #1;
      end

      @(posedge clk) #1;
      we_b = 0;

      @(posedge clk) #1;
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         addr_b = i;
         @(posedge clk) #1;
         if (i + seq_ini != q_b) begin
            $display("ERROR: write error in port B position %d, where data=%h but q_b=%h", i,
                     i + seq_ini, q_b);
            $fatal();
         end
      end

      @(posedge clk) #1;
      en_a = 0;
      en_b = 0;

      #clk_per;
      $display("%c[1;34m", 27);
      $display("Test completed successfully.");
      $display("%c[0m", 27);
      fd = $fopen("test.log", "w");
      $fdisplay(fd, "Test passed!");
      $fclose(fd);
      #(5 * clk_per) $finish();

   end

   // Instantiate the Unit Under Test (UUT)
   iob_ram_tdp #(
      .DATA_W(`DATA_W),
      .ADDR_W(`ADDR_W)
   ) uut (
      .clk_i(clk),

      .dA_i   (data_a),
      .addrA_i(addr_a),
      .enA_i  (en_a),
      .weA_i  (we_a),
      .dA_o   (q_a),

      .dB_i   (data_b),
      .addrB_i(addr_b),
      .enB_i  (en_b),
      .weB_i  (we_b),
      .dB_o   (q_b)
   );

   // system clock
   always #(clk_per / 2) clk = ~clk;

endmodule
