`timescale 1ns / 1ps
`include "iob_nco_conf.vh"
`include "iob_nco_swreg_def.vh"

module iob_nco #(
    `include "iob_nco_params.vs"
) (
    `include "iob_nco_io.vs"
);

  wire [     DATA_W-1:0] period_r;
  wire [     DATA_W-1:0] diff;
  wire [DATA_W-1:FRAC_W] cnt;
  wire [DATA_W-1:0] acc_in, acc_out;
  wire clk_int;

  //Dummy iob_ready_nxt_o and iob_rvalid_nxt_o to be used in swreg (unused ports)
  wire iob_ready_nxt;
  wire iob_rvalid_nxt;

  //BLOCK Register File & Configuration, control and status registers accessible by the sofware
  `include "iob_nco_swreg_inst.vs"

  // PERIOD Manual logic
  assign PERIOD_wready_wr = 1'b1;

  reg [DATA_W-1:FRAC_W] quant;

  assign diff = period_r - {quant, {FRAC_W{1'b0}}};
  assign clk_int = (cnt > (quant / 2));

  always @* begin
    if (acc_out[FRAC_W-1:0] == {1'b1, {FRAC_W - 1{1'b0}}})
      quant = acc_out[DATA_W-1:FRAC_W] + ^acc_out[DATA_W-1:FRAC_W];
    else if (acc_out[FRAC_W-1]) quant = acc_out[DATA_W-1:FRAC_W] + 1'b1;
    else quant = acc_out[DATA_W-1:FRAC_W];
  end

  //fractional period value register
  iob_reg_re #(
      .DATA_W(DATA_W)
  ) per_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (SOFT_RESET_wr),
      .en_i  (PERIOD_wen_wr),
      .data_i(PERIOD_wdata_wr),
      .data_o(period_r)
  );

  //output clock register
  iob_reg_re #(
      .DATA_W(1)
  ) clk_out_reg (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (SOFT_RESET_wr),
      .en_i  (ENABLE_wr),
      .data_i(clk_int),
      .data_o(clk_o)
  );

  //modulator accumulator
  iob_acc_ld #(
      .DATA_W(DATA_W)
  ) acc_ld (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i(SOFT_RESET_wr),
      .en_i(ENABLE_wr),
      .ld_i(PERIOD_wen_wr),
      .ld_val_i(PERIOD_wdata_wr),
      .incr_i(diff),
      .data_o(acc_out)
  );


  //output period counter
  iob_modcnt #(
      .DATA_W(DATA_W - FRAC_W)
  ) modcnt (
      `include "clk_en_rst_s_s_portmap.vs"
      .rst_i (PERIOD_wen_wr),
      .en_i  (ENABLE_wr),
      .mod_i (quant),
      .data_o(cnt)
  );


endmodule
