`timescale 1ns/1ps
`include "iob_lib.vh"
`include "iob_uart.vh"
`include "iob_uart_sw_reg_def.vh"

module iob_uart 
  # (
     parameter DATA_W = 32, //PARAM CPU data width
     parameter ADDR_W = `iob_uart_sw_reg_ADDR_W //MACRO CPU address width
     )

  (

   //CPU interface
`include "iob_s_if.vh"

   //additional inputs and outputs

   //`OUTPUT(interrupt, 1), //to be done
   `OUTPUT(txd, 1), //Serial transmit line
   `INPUT(rxd, 1), //Serial receive line
   `INPUT(cts, 1), //Clear to send; the destination is ready to receive a transmission sent by the UART
   `OUTPUT(rts, 1), //Ready to send; the UART is ready to receive a transmission from the sender.
`include "gen_if.vh"
   );

//BLOCK Register File & Configuration control and status register file.
`include "iob_uart_sw_reg.vh"
`include "iob_uart_sw_reg_gen.vh"
   
   uart_core uart_core0 
     (
      .clk(clk),
      .rst(rst),
      .rst_soft(UART_SOFTRESET),
      .tx_en(UART_TXEN),
      .rx_en(UART_RXEN),
      .tx_ready(UART_TXREADY),
      .rx_ready(UART_RXREADY),
      .tx_data(UART_TXDATA),
      .rx_data(UART_RXDATA),
      .data_write_en(valid & |wstrb & (address == `UART_TXDATA_ADDR)),
      .data_read_en(valid & !wstrb & (address == `UART_RXDATA_ADDR)),
      .bit_duration(UART_DIV),
      .rxd(rxd),
      .txd(txd),
      .cts(cts),
      .rts(rts)
      );
   
endmodule


