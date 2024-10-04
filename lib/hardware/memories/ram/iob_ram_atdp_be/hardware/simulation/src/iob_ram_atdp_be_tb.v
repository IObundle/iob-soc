// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

`define DATA_W 32
`define ADDR_W 4

module iob_ram_atdp_be_tb;

   // Inputs
   reg                 clkA;
   reg                 enaA;  // enable access to ram
   reg [`DATA_W/8-1:0] weA;  // write enable vector
   reg [  `ADDR_W-1:0] addrA;
   reg [  `DATA_W-1:0] data_inA;

   reg                 clkB;
   reg                 enaB;  // enable access to ram
   reg [`DATA_W/8-1:0] weB;  // write enable vector
   reg [  `ADDR_W-1:0] addrB;
   reg [  `DATA_W-1:0] data_inB;

   // Ouptuts
   reg [  `DATA_W-1:0] data_outA;
   reg [  `DATA_W-1:0] data_outB;

   integer i, seq_ini, first_seq_ini;
   integer fd;

   parameter clk_per = 10;  // clk period = 10 timeticks

   initial begin
      // optional VCD
`ifdef VCD
      $dumpfile("uut.vcd");
      $dumpvars();
`endif

      // Initialize Inputs
      clkA = 1;
      clkB = 1;
      enaA = 0;
      enaB = 0;
      for (i = 0; i < `DATA_W / 8; i = i + 1) begin
         weA[i] = 0;
         weB[i] = 0;
      end
      addrA         = 0;
      addrB         = 0;

      // Number from which to start the incremental sequence to write into the RAM
      seq_ini       = 32;
      first_seq_ini = seq_ini;

      #clk_per;
      @(posedge clkA) #1;
      @(posedge clkB) #1;


      @(posedge clkA) #1;
      enaA = 1;

      // Write into RAM port A in all positions and read from it
      @(posedge clkA) #1;

      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         weA[i] = 1;
         @(posedge clkA) #1;
         addrA    = i;
         data_inA = i + seq_ini;
         @(posedge clkA) #1;
      end

      @(posedge clkA) #1;
      for (i = 0; i < `DATA_W / 8; i = i + 1) weA[i] = 0;

      @(posedge clkA) #1;
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         addrA = i;
         @(posedge clkA) #1;
         if (i + seq_ini != data_outA) begin
            $display("ERROR: write error in port A position %d, where data=%h but data_outA=%h", i,
                     i + seq_ini, data_outA);
            $finish();
         end
      end

      // Number from which to start the incremental sequence to write into the RAM
      seq_ini = 64;

      @(posedge clkB) #1;
      enaB = 1;

      // Write into RAM port B in all positions and read from it
      @(posedge clkB) #1;

      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         weB[i] = 1;
         @(posedge clkB) #1;
         addrB    = i;
         data_inB = i + seq_ini;
         @(posedge clkB) #1;
      end

      @(posedge clkB) #1;
      for (i = 0; i < `DATA_W / 8; i = i + 1) weB[i] = 0;

      @(posedge clkB) #1;
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         addrB = i;
         @(posedge clkB) #1;
         if (i + seq_ini != data_outB) begin
            $display("ERROR: write error in port B position %d, where data=%h but data_outB=%h", i,
                     i + seq_ini, data_outB);
            $finish();
         end
      end

      // Number from which to start the incremental sequence to write into the RAM
      seq_ini = first_seq_ini;

      // Test if output is truly different
      // Port A
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         addrA = i;
         @(posedge clkA) #1;
         if (i + seq_ini == data_outA) begin
            $display(
                "ERROR: read error in port A position %d, where data and data_outA are '%h' but should not be the same",
                i, data_outA);
            $finish();
         end
      end

      @(posedge clkA) #1;
      enaA = 0;

      // Port B
      for (i = 0; i < 2 ** `ADDR_W; i = i + 1) begin
         addrB = i;
         @(posedge clkB) #1;
         if (i + seq_ini == data_outB) begin
            $display(
                "ERROR: read error in port B position %d, where data and data_outB are '%h' but should not be the same",
                i, data_outB);
            $finish();
         end
      end

      @(posedge clkB) #1;
      enaB = 0;

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
   iob_ram_atdp_be #(
      .DATA_W(`DATA_W),
      .ADDR_W(`ADDR_W)
   ) uut (
      .clkA_i (clkA),
      .enA_i  (enaA),
      .weA_i  (weA),
      .addrA_i(addrA),
      .dA_i   (data_inA),
      .dA_o   (data_outA),

      .clkB_i (clkB),
      .enB_i  (enaB),
      .weB_i  (weB),
      .addrB_i(addrB),
      .dB_i   (data_inB),
      .dB_o   (data_outB)
   );

   // system clock
   always #(clk_per / 2) clkA = ~clkA;
   always #(clk_per / 2) clkB = ~clkB;

endmodule
