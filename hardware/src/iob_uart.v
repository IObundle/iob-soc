`timescale 1ns/1ps
`include "iob_lib.vh"
`include "interconnect.vh"
`include "iob_uart.vh"
`include "UARTsw_reg.vh"

module iob_uart 
  # (
     parameter ADDR_W = `UART_ADDR_W, //NODOC Address width
     parameter DATA_W = `UART_RDATA_W, //NODOC CPU data width
     parameter WDATA_W = `UART_WDATA_W //NODOC CPU data width
     )

  (
`ifndef USE_AXI4LITE
 `include "cpu_nat_s_if.v"
`else
 `include "cpu_axi4lite_s_if.v"
`endif

   //`OUTPUT(interrupt, 1), //to be done

   `OUTPUT(txd, 1),
   `INPUT(rxd, 1),
   `INPUT(cts, 1),
   `OUTPUT(rts, 1),
`include "gen_if.v"
   );

//BLOCK Register File & Holds the current configuration of the UART as well as internal parameters. Data to be sent or that has been received is stored here temporarily.
`include "UARTsw_reg.v"
`include "UARTsw_reg_gen.v"

   `SIGNAL_OUT(tx_ready, 1)
   `SIGNAL_OUT(rx_ready, 1)
   `SIGNAL_OUT(rx_data, 8)

   // read registers
   `COMB UART_TXREADY = tx_ready;
   `COMB UART_RXREADY = rx_ready;
   `COMB UART_RXDATA = rx_data;
   
   //ready signal   
   `SIGNAL(ready_int, 1)
   `REG_AR(clk, rst, 0, ready_int, valid)
   `SIGNAL2OUT(ready, ready_int)

   uart_core uart_core0 
     (
      .clk(clk),
      .rst(rst),
      .rst_soft(UART_SOFTRESET),
      .tx_en(UART_TXEN),
      .rx_en(UART_RXEN),
      .tx_ready(tx_ready),
      .rx_ready(rx_ready),
      .tx_data(UART_TXDATA),
      .rx_data(rx_data),
      .data_write_en(valid & |wstrb & (address == `UART_TXDATA_ADDR)),
      .data_read_en(valid & !wstrb & (address == `UART_RXDATA_ADDR)),
      .bit_duration(UART_DIV),
      .rxd(rxd),
      .txd(txd),
      .cts(cts),
      .rts(rts)
      );
   
endmodule


