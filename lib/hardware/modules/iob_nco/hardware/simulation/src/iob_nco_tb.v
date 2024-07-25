`timescale 1ns / 1ps
`include "iob_reg_conf.vh"

`define IOB_CLOCK(CLK, PER) initial CLK=0; always #(PER/2) CLK = ~CLK;
`define IOB_RESET(CLK, RESET, PRE, DURATION, POST) RESET=~`IOB_NCO_RST_POL;\
   #PRE RESET=`IOB_NCO_RST_POL; #DURATION RESET=~`IOB_NCO_RST_POL; #POST;\
   @(posedge CLK) #1;
`define IOB_PULSE(VAR, PRE, DURATION, POST) VAR=0; #PRE VAR=1; #DURATION VAR=0; #POST;

module iob_nco_tb;

  integer fd;

  localparam CLK_PER = 10;

  reg clk;
  `IOB_CLOCK(clk, CLK_PER)
  reg  cke = 1'b1;
  reg  arst;

  reg  ld;

  wire clk_out;

  initial begin

`ifdef VCD
    $dumpfile("uut.vcd");
    $dumpvars();
`endif

    `IOB_RESET(clk, arst, 23, 23, 23)

    `IOB_PULSE(ld, 23, 20, 20)

    $display("%c[1;34m", 27);
    $display("Test completed successfully.");
    $display("%c[0m", 27);
    fd = $fopen("test.log", "w");
    $fdisplay(fd, "Test passed!");
    $fclose(fd);
    #1000 $finish();

  end

  iob_nco #(
      .DATA_W(16),
      .FRAC_W(8)
  ) nco (
      `include "clk_en_rst_s_portmap.vs"
      .rst_i(1'b0),
      .en_i(1'b1),
      .period_i(16'h1280),
      .ld_i(ld),
      .clk_o(clk_out)
  );


endmodule
