`timescale 1ns / 1ps
`include "system.vh"

module top_system (
                  //differential clock and reset
	          input  clk,
	          input  reset,

	          //uart
	          output uart_txd,
	          input  uart_rxd,
	          input  uart_cts_n,
	          output uart_rts_n,

		  output trap
		  );

   //   
   //RESET CONTROL
   //
   reg [15:0] 			reset_cnt;
   wire 			reset_int;

   wire uart_rts;

   
   always @(posedge clk, posedge reset)
     if(reset)
       reset_cnt <= 16'b0;
     else if (reset_cnt != 16'hFFFF)
       reset_cnt <= reset_cnt+1'b1;
   
   assign reset_int  = (reset_cnt != 16'hFFFF);   

   assign uart_rts_n = ~uart_rts;
 
   
   //
   // SYSTEM
   //
   system system (
        	  .clk           (clk),
		  .reset         (reset_int),
		  .trap          (trap),

                  //UART
		  .uart_txd      (uart_txd),
		  .uart_rxd      (uart_rxd),
		  .uart_rts      (uart_rts),
		  .uart_cts      (~uart_cts_n)
		  );


endmodule
