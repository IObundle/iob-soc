`timescale 1ns/1ps
`include "iob_lib.vh"
`include "iob_axistream_in_swreg_def.vh"

module iob_axistream_in 
  # (
     parameter DATA_W = 32, //PARAM CPU data width
     parameter ADDR_W = `iob_axistream_in_swreg_ADDR_W //MACRO CPU address section width
     )

  (

   //CPU interface
`include "iob_s_if.vh"

   //additional inputs and outputs

   //START_IO_TABLE rs232
   //`IOB_OUTPUT(interrupt, 1), //to be done
   `IOB_OUTPUT(txd, 1), //Serial transmit line
   `IOB_INPUT(rxd, 1), //Serial receive line
   `IOB_INPUT(cts, 1), //Clear to send; the destination is ready to receive a transmission sent by theAXISTREAMIN 
   `IOB_OUTPUT(rts, 1), //Ready to send; the AXISTREAMIN is ready to receive a transmission from the sender.
`include "gen_if.vh"
   );

//BLOCK Register File & Configuration control and status register file.
`include "iob_axistream_in_swreg.vh"
`include "iob_axistream_in_swreg_gen.vh"
   
   axistream_in_core axistream_in_core0 
     (
      .clk(clk),
      .rst(rst),
      .rst_soft(AXISTREAMIN_SOFTRESET),
      .tx_en(AXISTREAMIN_TXEN),
      .rx_en(AXISTREAMIN_RXEN),
      .tx_ready(AXISTREAMIN_TXREADY),
      .rx_ready(AXISTREAMIN_RXREADY),
      .tx_data(AXISTREAMIN_TXDATA),
      .rx_data(AXISTREAMIN_RXDATA),
      .data_write_en(valid & |wstrb & (address == `AXISTREAMIN_TXDATA_ADDR)),
      .data_read_en(valid & !wstrb & (address == `AXISTREAMIN_RXDATA_ADDR)),
      .bit_duration(AXISTREAMIN_DIV),
      .rxd(rxd),
      .txd(txd),
      .cts(cts),
      .rts(rts)
      );
   
endmodule


