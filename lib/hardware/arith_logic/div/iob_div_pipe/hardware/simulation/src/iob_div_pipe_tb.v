// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

`define CLK_FREQ (100000000)

module iob_div_pipe_tb;

   parameter clk_frequency = `CLK_FREQ;
   parameter clk_period = 1e9/clk_frequency; //ns

   parameter DATA_W = 32;
   parameter OPERS_PER_STAGE = 8;

   parameter TEST_SZ = 100;

   reg clk;

   wire [DATA_W-1:0] dividend;
   wire [DATA_W-1:0] divisor;
   wire [DATA_W-1:0] quotient;
   wire [DATA_W-1:0] remainder;

   wire [DATA_W-1:0] q;
   wire [DATA_W-1:0] r;

   reg [DATA_W-1:0]  dividend_in [0:TEST_SZ-1];
   reg [DATA_W-1:0]  divisor_in [0:TEST_SZ-1];
   reg [DATA_W-1:0]  quotient_out [0:TEST_SZ-1];
   reg [DATA_W-1:0]  remainder_out [0:TEST_SZ-1];

   integer           i, j;
   integer           fp;
   
   iob_div_pipe # (
               .DATA_W(DATA_W),
               .OPERS_PER_STAGE(OPERS_PER_STAGE)
               )
   uut (
		.clk_i(clk),

		.dividend_i(dividend),
		.divisor_i(divisor),

		.quotient_o(quotient),
		.remainder_o(remainder)
		);

   initial begin

`ifdef VCD
      $dumpfile("div_pipe.vcd");
      $dumpvars();
`endif

      clk = 0;

      j=0;

      // generate test data
      for (i=0; i < TEST_SZ; i=i+1) begin
	     dividend_in[i] = $random%(2**(DATA_W-1));
	     divisor_in[i] = $random%(2**(DATA_W-1));
	     quotient_out[i] = dividend_in[i] / divisor_in[i];
	     remainder_out[i] = dividend_in[i] % divisor_in[i];
      end

      #((TEST_SZ+DATA_W/OPERS_PER_STAGE)*clk_period);

      #clk_period;
      $display("%c[1;34m", 27);
      $display("Test completed successfully.");
      $display("%c[0m", 27);

      fp = $fopen("test.log", "w");
      $fdisplay(fp, "Test passed!");
      
      #(5 * clk_period) $finish();
   end

   always 
     #(clk_period/2) clk = ~clk;   

   always @ (posedge clk) begin
      j <= j+1;
   end

   // assign inputs
   assign dividend = dividend_in[j];
   assign divisor = divisor_in[j];

   // show expected results
   assign q = quotient_out[j];
   assign r = remainder_out[j];

   always @ (negedge clk) begin
      if(j >= DATA_W/OPERS_PER_STAGE && (quotient != quotient_out[j-DATA_W/OPERS_PER_STAGE] ||
                                         remainder != remainder_out[j-DATA_W/OPERS_PER_STAGE])) begin
	     $display("Test failed at %d", $time);
	     $finish;
      end
   end

endmodule
