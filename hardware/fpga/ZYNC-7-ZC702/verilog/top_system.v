`timescale 1ns / 1ps
`include "system.vh"

module top_system(
	          	  input         c0_sys_clk_clk_p, 
                  input         c0_sys_clk_clk_n,
                
	          input         reset,

	          //uart
	          output        uart_txd,
	          input         uart_rxd
               
		  );


   //
   // CLOCK MANAGEMENT
   //

   //system clock
   wire 			sys_clk;
   

   IBUFGDS clk_buf(.O(sys_clk), .I(c0_sys_clk_clk_p), .IB(c0_sys_clk_clk_n));


   //   
   // RESET MANAGEMENT
   //

   //system reset
 
   wire                         sys_rst=reset;

                 

   //
   // SYSTEM
   //
   system system 
     (
      .clk           (sys_clk),
      .reset         (sys_rst),
      .trap          (),

      
      //UART
      .uart_txd      (uart_txd),
      .uart_rxd      (uart_rxd),
      .uart_rts      (),
      .uart_cts      (1'b1)
      );
   
endmodule
