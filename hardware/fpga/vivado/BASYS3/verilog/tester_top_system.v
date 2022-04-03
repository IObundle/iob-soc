`timescale 1ns / 1ps
`include "system.vh"

module top_system(
	          input         clk,
	          input         reset,

	          //uart
	          output        uart_txd,
	          input         uart_rxd
		  );

   //
   // RESET MANAGEMENT
   //

   //system reset

   wire                         sys_rst;

   reg [15:0] 			rst_cnt;
   reg                          sys_rst_int;

   always @(posedge clk, posedge reset)
     if(reset) begin
        sys_rst_int <= 1'b0;
        rst_cnt <= 16'hFFFF;
     end else begin
        if(rst_cnt != 16'h0)
          rst_cnt <= rst_cnt - 1'b1;
        sys_rst_int <= (rst_cnt != 16'h0);
     end

   assign sys_rst = sys_rst_int;

   wire [1:0]                   trap_signals;
   assign trap = trap_signals[0] || trap_signals[1];

   //
   // TESTER (includes SUT)
   //
   tester tester
     (
      .clk           (clk),
      .reset         (sys_rst),
      .trap          (trap_signals),

      //UART
      .tester_UART0_txd      (uart_txd),
      .tester_UART0_rxd      (uart_rxd),
      .tester_UART0_rts      (),
      .tester_UART0_cts      (1'b1)
      );

endmodule
