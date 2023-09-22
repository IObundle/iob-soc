`timescale 1ns / 1ps

module iob_soc_fpga_wrapper (
   input clk,
   input reset,

   //uart
   output uart_txd_o,
   input  uart_rxd_i
);

   //
   // RESET MANAGEMENT
   //

   //system reset

   wire        sys_rst;

   reg  [15:0] rst_cnt;
   reg         sys_rst_int;

   always @(posedge clk, posedge reset)
      if (reset) begin
         sys_rst_int <= 1'b0;
         rst_cnt     <= 16'hFFFF;
      end else begin
         if (rst_cnt != 16'h0) rst_cnt <= rst_cnt - 1'b1;
         sys_rst_int <= (rst_cnt != 16'h0);
      end

   assign sys_rst = sys_rst_int;

   //
   // SYSTEM
   //
   iob_soc iob_soc (
      .clk_i   (clk),
      .cke_i   (1'b1),
      .arst_i  (sys_rst),
      .trap_o  (trap),
      //UART
      .UART_txd_o(uart_txd_o),
      .UART_rxd_i(uart_rxd_i),
      .UART_rts_i(),
      .UART_cts_o(1'b1)
   );

endmodule
