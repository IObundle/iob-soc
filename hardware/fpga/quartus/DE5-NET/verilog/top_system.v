`timescale 1ns / 1ps
`include "system.vh"

module top_system(
  input        IE_PERST_n,
  input        PCIE_REFCLK_p,
  input [7:0]  PCIE_RX_p,
  input        PCIE_SMBCLK,
  output       PCIE_SMBDAT,
  output [7:0] PCIE_TX_p,
  output       PCIE_WAKE_n
		  
  // output [0:0] led_bracket,
  // output [0:0] led_board
		  
  );
   //
   // CLOCK MANAGEMENT
   //

   //system clock
   wire 			sys_clk = PCIE_REFCLK_p;
   // assign led_board[0] = 0;
   // assign led_bracket[0] = 0;
   //
   // RESET MANAGEMENT
   //

   //system reset

   wire                         sys_rst;

   reg [15:0] 			rst_cnt;

   always @(posedge sys_clk, negedge IE_PERST_n)
     if(!IE_PERST_n)
       rst_cnt <= 16'hFFFF;
     else if (rst_cnt != 16'h0)
       rst_cnt <= rst_cnt - 1'b1;

   assign sys_rst  = (rst_cnt != 16'h0);

   //
   // SYSTEM
   //
   system system (
   		  .clk           (sys_clk),
   		  .rst         (sys_rst),
   		  .trap          (),
   		  //UART
   		  .uart_txd      (),
   		  .uart_rxd      (),
   		  .uart_rts      (),
   		  .uart_cts      (1'b1)
   		  );

endmodule
