// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps
`define ADDR_W 10
`define DATA_W 32

module iob_rom_2p_tb;

   // Inputs
   reg                clk;

   // Read 1 signals
   reg                r1_en;
   reg  [`ADDR_W-1:0] r1_addr;
   wire               r1_ready;


   // Read 2 signals
   reg                r2_en;
   reg  [`ADDR_W-1:0] r2_addr;
   wire               r2_ready;

   wire [`DATA_W-1:0] r_data;

   integer i, seq_ini;
   integer fd;

   parameter clk_per = 10;  // clk period = 10 timeticks

   initial begin

      // Initialize Inputs
      clk      = 1;
      r1_en    = 0;
      r2_en    = 0;
      r1_addr  = 0;
      r2_addr  = 0;

      // optional VCD
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif

      // Number from which to start the incremental sequence to initialize the ROM
      seq_ini = 32;
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         uut.iob_rom_sp_inst.rom[i] = i + seq_ini;
      end

      // Attempt to read all the locations of ROM with r1_en = 0
      r1_en = 0;
      @(posedge clk) #1;

      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         r1_addr = i;
         @(posedge clk) #1;
         if (r_data != 0) begin
            $display("ERROR: with r1_en = 0, at position %0d, r_data should be 0 but is %d", i,
                     r_data);
            $fatal(1);
         end
      end

      r2_en = 1;
      @(posedge clk) #1;

      // Read all the locations of ROM with r2_en = 1
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         r2_addr = i;
         // wait for r2_ready
         while (!r2_ready) begin
            @(posedge clk) #1;
         end
         @(posedge clk) #1;
         if (r_data != i + seq_ini) begin
            $display("ERROR: on position %0d, r_data is %d where it should be %0d", i, r_data,
                     i + seq_ini);
            $fatal(1);
         end
      end

      r2_en = 0;

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
   iob_rom_2p #(
      .DATA_W(`DATA_W),
      .ADDR_W(`ADDR_W)
   ) uut (
      .clk_i     (clk),
      .r1_en_i   (r1_en),
      .r1_addr_i (r1_addr),
      .r1_ready_o(r1_ready),
      .r2_en_i   (r2_en),
      .r2_addr_i (r2_addr),
      .r2_ready_o(r2_ready),
      .r_data_o  (r_data)
   );

   // Clock
   always #(clk_per / 2) clk = ~clk;

endmodule
