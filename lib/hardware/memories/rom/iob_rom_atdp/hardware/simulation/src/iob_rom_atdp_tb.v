// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

`define DATA_W 8
`define ADDR_W 4

module iob_rom_atdp_tb;

   // Inputs
   reg               clk_a;
   reg               clk_b;
   reg               r_en_a;
   reg [`ADDR_W-1:0] addr_a;
   reg               r_en_b;
   reg [`ADDR_W-1:0] addr_b;

   // Ouptuts
   reg [`DATA_W-1:0] r_data_a;
   reg [`DATA_W-1:0] r_data_b;

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
      clk_a   = 1;
      clk_b   = 1;
      r_en_a  = 0;
      addr_a  = 0;
      r_en_b  = 0;
      addr_b  = 0;

      // Number from which to start the incremental sequence to initialize the ROM
      seq_ini = 32;
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         uut.rom[i] = i + seq_ini;
      end

      #clk_per;
      @(posedge clk_a) #1;
      @(posedge clk_b) #1;

      @(posedge clk_a) #1;
      r_en_a = 1;
      r_en_b = 1;

      @(posedge clk_a) #1;
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         addr_a = i;
         addr_b = 2 ** `ADDR_W - 1 - i;
         @(posedge clk_a) #1;
         if (i + seq_ini != r_data_a) begin
            $display(
                "ERROR: Port A - read error in position %d, where expected data=%h but r_data=%h",
                i, i + seq_ini, r_data_a);
            $fatal();
         end
         if (seq_ini + 2 ** `ADDR_W - 1 - i != r_data_b) begin
            $display(
                "ERROR: Port B - read error in position %d, where expected data=%h but r_data=%h",
                2 ** `ADDR_W - 1 - i, seq_ini + 2 ** `ADDR_W - 1 - i, r_data_b);
            $fatal();
         end
      end

      @(posedge clk_b) #1;
      r_en_a = 0;
      r_en_b = 0;

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
   iob_rom_atdp #(
      .DATA_W(`DATA_W),
      .ADDR_W(`ADDR_W)
   ) uut (
      .clk_a_i   (clk_a),
      .r_en_a_i  (r_en_a),
      .addr_a_i  (addr_a),
      .r_data_a_o(r_data_a),

      .clk_b_i   (clk_b),
      .r_en_b_i  (r_en_b),
      .addr_b_i  (addr_b),
      .r_data_b_o(r_data_b)
   );

   // system clock
   always #(clk_per / 2) clk_a = ~clk_a;
   always #(clk_per / 2) clk_b = ~clk_b;

endmodule
