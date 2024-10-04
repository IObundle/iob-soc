// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

`define DATA_W 8
`define ADDR_W 4

module iob_rom_sp_tb;

   // Inputs
   reg               clk;
   reg               r_en;
   reg [`ADDR_W-1:0] addr;

   // Ouptuts
   reg [`DATA_W-1:0] r_data;

   integer i, seq_ini, fp;
   

   parameter clk_per = 10;  // clk period = 10 timeticks

   initial begin
      // optional VCD
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif

      // Initialize Inputs
      clk     = 1;
      r_en    = 0;
      addr    = 0;

      // Number from which to start the incremental sequence to initialize the ROM
      seq_ini = 32;
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         uut.rom[i] = i + seq_ini;
      end

      #clk_per;
      @(posedge clk) #1;
      r_en = 1;

      @(posedge clk) #1;
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         addr = i;
         @(posedge clk) #1;
         if (i + seq_ini != r_data) begin
            $display("ERROR: read error in position %d, where expected data=%h but r_data=%h", i,
                     i + seq_ini, r_data);
            $fatal();
         end else begin
            fp = $fopen("test.log", "w");
            $fdisplay(fp, "Test passed!");
         end
      end

      @(posedge clk) #1;
      r_en = 0;

      #clk_per;
      $display("%c[1;34m", 27);
      $display("Test completed successfully.");
      $display("%c[0m", 27);
      #(5 * clk_per) $finish();

   end

   // Instantiate the Unit Under Test (UUT)
   iob_rom_sp #(
      .DATA_W(`DATA_W),
      .ADDR_W(`ADDR_W)
   ) uut (
      .clk_i   (clk),
      .r_en_i  (r_en),
      .addr_i  (addr),
      .r_data_o(r_data)
   );

   // system clock
   always #(clk_per / 2) clk = ~clk;

endmodule
