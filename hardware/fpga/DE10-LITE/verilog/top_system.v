`timescale 1ns / 1ps
`include "system.vh"

module top_system(
  input         clk,
  input         resetn,

  //uart
  output        uart_txd,
  input         uart_rxd,

	output        trap
  );
   //
   // CLOCK MANAGEMENT
   //

   //system clock
   wire 			sys_clk = clk;

   //
   // RESET MANAGEMENT
   //

   //system reset

   wire                         sys_rst;

   reg [15:0] 			rst_cnt;

   always @(posedge sys_clk, negedge resetn)
     if(!resetn)
       rst_cnt <= 16'hFFFF;
     else if (rst_cnt != 16'h0)
       rst_cnt <= rst_cnt - 1'b1;

   assign sys_rst  = (rst_cnt != 16'h0);

   //
   // SYSTEM
   //
   system system (
      .clk           (sys_clk),
		  .reset         (sys_rst),
		  .trap          (trap),
      //UART
		  .uart_txd      (uart_txd),
		  .uart_rxd      (uart_rxd),
		  .uart_rts      (),
		  .uart_cts      (1'b1)
		);

endmodule
