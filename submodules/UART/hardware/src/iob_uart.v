`timescale 1ns / 1ps
`include "iob_uart_conf.vh"
`include "iob_uart_swreg_def.vh"

module iob_uart #(
   `include "iob_uart_params.vs"
) (
   `include "iob_uart_io.vs"
);

   //BLOCK Register File & Configuration control and status register file.
   `include "iob_uart_swreg_inst.vs"

   // TXDATA Manual logic
   assign TXDATA_wready_wr = 1'b1;

   // RXDATA Manual logic
   assign RXDATA_rready_rd = 1'b1;

   // RXDATA rvalid is iob_valid registered
   wire RXDATA_rvalid_nxt;
   assign RXDATA_rvalid_nxt = iob_valid_i & RXDATA_ren_rd;
   iob_reg #(
      .DATA_W (1),
      .RST_VAL(1'd0)
   ) iob_reg_rvalid (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .data_i(RXDATA_rvalid_nxt),
      .data_o(RXDATA_rvalid_rd)
   );

   uart_core uart_core0 (
      .clk_i          (clk_i),
      .arst_i         (arst_i),
      .rst_soft_i     (SOFTRESET_wr),
      .tx_en_i        (TXEN_wr),
      .rx_en_i        (RXEN_wr),
      .tx_ready_o     (TXREADY_rd),
      .rx_ready_o     (RXREADY_rd),
      .tx_data_i      (TXDATA_wdata_wr),
      .rx_data_o      (RXDATA_rdata_rd),
      .data_write_en_i(TXDATA_wen_wr),
      .data_read_en_i (RXDATA_ren_rd),
      .bit_duration_i (DIV_wr),
      .rxd_i          (rxd_i),
      .txd_o          (txd_o),
      .cts_i          (cts_i),
      .rts_o          (rts_o)
   );

endmodule


