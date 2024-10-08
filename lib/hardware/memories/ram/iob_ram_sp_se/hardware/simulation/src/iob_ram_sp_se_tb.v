// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

`define DATA_W 32
`define ADDR_W 4

module iob_ram_sp_se_tb;

   // Inputs
   reg                 clk;
   reg                 en;  // enable access to ram
   reg [`DATA_W/8-1:0] we;  // write enable vector
   reg [  `ADDR_W-1:0] addr;
   reg [  `DATA_W-1:0] data_in;

   // Ouptuts
   reg [  `DATA_W-1:0] data_out;

   integer i, seq_ini;
   integer fd;

   parameter CLK_PER = 10;  // clk period = 10 timeticks
   parameter COL_W = 8;
   
   initial begin
      // optional VCD
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif

      // Initialize Inputs
      clk = 1;
      en  = 0;
      for (i = 0; i < `DATA_W / 8; i = i + 1) we[i] = 0;
      addr    = 0;

      // Number from which to start the incremental sequence to write into the RAM
      seq_ini = 32;

      #CLK_PER;
      @(posedge clk) #1;
      en = 1;

      // Write into RAM in all positions and read from it
      @(posedge clk) #1;

      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         we[i] = 1;
         @(posedge clk) #1;
         addr    = i;
         data_in = i + seq_ini;
         @(posedge clk) #1;
      end

      @(posedge clk) #1;
      for (i = 0; i < `DATA_W / 8; i = i + 1) we = 0;

      @(posedge clk) #1;
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         addr = i;
         @(posedge clk) #1;
         if (i + seq_ini != data_out) begin
            $display("ERROR: write error in position %d, where data=%h but data_out=%h", i,
                     i + seq_ini, data_out);
            $fatal();
         end
      end

      // Number from which to start the incremental sequence to write into the RAM
      seq_ini = 64;

      // Test if output is truly different
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         addr = i;
         @(posedge clk) #1;
         if (i + seq_ini == data_out) begin
            $display(
                "ERROR: read error in position %d, where data and data_out are '%h' but should not be the same",
                i, data_out);
            $fatal();
         end
      end

      @(posedge clk) #1;
      en = 0;

      #CLK_PER;
      $display("%c[1;34m", 27);
      $display("Test completed successfully.");
      $display("%c[0m", 27);
      fd = $fopen("test.log", "w");
      $fdisplay(fd, "Test passed!");
      $fclose(fd);
      #(5 * CLK_PER) $finish();

   end

   // Instantiate the Unit Under Test (UUT)
   iob_ram_sp_se #(
      .DATA_W(`DATA_W),
      .ADDR_W(`ADDR_W),
      .COL_W(COL_W)
   ) uut (
      .clk_i (clk),
      .en_i  (en),
      .we_i  (we),
      .addr_i(addr),
      .d_i   (data_in),
      .d_o   (data_out)
   );

   // system clock
   always #(CLK_PER / 2) clk = ~clk;

endmodule
