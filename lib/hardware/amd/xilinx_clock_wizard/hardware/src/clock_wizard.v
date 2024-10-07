// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ps / 1ps

module clock_wizard #(
   parameter OUTPUT_PER = 10,
   parameter INPUT_PER  = 4
) (  // Clock in ports
     // Clock out ports
   output clk_out1,
   output arst_out1,
   input  clk_in1_p,
   input  clk_in1_n,
   input  arst_i
);

   wire clk_in1_clock_wizard;

   IBUFDS clkin1_ibufds (
      .O (clk_in1_clock_wizard),
      .I (clk_in1_p),
      .IB(clk_in1_n)
   );

   wire        clk_out1_clock_wizard;
   wire        clk_out2_clock_wizard;
   wire        clk_out3_clock_wizard;
   wire        clk_out4_clock_wizard;
   wire        clk_out5_clock_wizard;
   wire        clk_out6_clock_wizard;
   wire        clk_out7_clock_wizard;

   wire [15:0] do_unused;
   wire        drdy_unused;
   wire        psdone_unused;
   wire        locked_int;
   wire        clkfbout_clock_wizard;
   wire        clkfboutb_unused;
   wire        clkout0b_unused;
   wire        clkout1_unused;
   wire        clkout1b_unused;
   wire        clkfbstopped_unused;
   wire        clkinstopped_unused;


   PLLE3_ADV #(
      .COMPENSATION      ("AUTO"),
      .STARTUP_WAIT      ("FALSE"),
      .DIVCLK_DIVIDE     (1),
      .CLKFBOUT_MULT     (4),
      .CLKFBOUT_PHASE    (0.000),
      .CLKOUT0_DIVIDE    (4 * OUTPUT_PER / INPUT_PER),
      .CLKOUT0_PHASE     (0.000),
      .CLKOUT0_DUTY_CYCLE(0.500),
      .CLKIN_PERIOD      (INPUT_PER)
   ) plle3_adv_inst (
      .CLKFBOUT   (clkfbout_clock_wizard),
      .CLKOUT0    (clk_out1_clock_wizard),
      .CLKOUT0B   (clkout0b_unused),
      .CLKOUT1    (clkout1_unused),
      .CLKOUT1B   (clkout1b_unused),
      // Input clock control
      .CLKFBIN    (clkfbout_clock_wizard),
      .CLKIN      (clk_in1_clock_wizard),
      // Ports for dynamic reconfiguration
      .DADDR      (7'h0),
      .DCLK       (1'b0),
      .DEN        (1'b0),
      .DI         (16'h0),
      .DO         (do_unused),
      .DRDY       (drdy_unused),
      .DWE        (1'b0),
      .CLKOUTPHYEN(1'b0),
      .CLKOUTPHY  (),
      // Other control and status signals
      .LOCKED     (locked_int),
      .PWRDWN     (1'b0),
      .RST        (arst_i)
   );


   assign arst_out1 = ~locked_int;

   BUFG clkout1_buf (
      .O(clk_out1),
      .I(clk_out1_clock_wizard)
   );

endmodule
