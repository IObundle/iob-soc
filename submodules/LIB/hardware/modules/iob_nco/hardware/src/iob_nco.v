`timescale 1ns / 1ps
`include "iob_nco_conf.vh"
`include "iob_nco_swreg_def.vh"

module iob_nco #(
    `include "iob_nco_params.vs"
) (
    `include "iob_nco_io.vs"
);

// USING NCO FROM ASRC submodules!!!
  localparam PERIOD_W = 2*DATA_W;
  localparam FRAC_W = DATA_W;

  wire [PERIOD_W-1:0] period_r;
  wire [PERIOD_W-1:0] diff;
  wire [DATA_W-1:0] cnt;
  wire [PERIOD_W-1:0] acc_in, acc_out;
  wire clk_int;

  wire soft_reset;
  wire enable;
  wire [PERIOD_W-1:0] period_wdata;
  wire period_wen;

  //BLOCK Register File & Configuration, control and status registers accessible by the sofware
  `include "iob_nco_swreg_inst.vs"

  // Concatenate Integer and fractional Period registers
  wire [(2*DATA_W)-1:0] period_full_wdata;
  wire period_full_wen;
  // integer period value register
  iob_reg_re #(
      .DATA_W(DATA_W)
  ) int_reg (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .rst_i (SOFT_RESET_wr),
      .en_i  (PERIOD_INT_wen_wr),
      .data_i(PERIOD_INT_wdata_wr),
      .data_o(period_full_wdata[DATA_W+:DATA_W])
  );
  // fractional period value register
  iob_reg_re #(
      .DATA_W(DATA_W)
  ) frac_reg (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .rst_i (SOFT_RESET_wr),
      .en_i  (PERIOD_FRAC_wen_wr),
      .data_i(PERIOD_FRAC_wdata_wr),
      .data_o(period_full_wdata[0+:DATA_W])
  );
  // period valid register
  wire per_valid_en;
  wire per_valid_rst;
  wire [2-1:0] per_valid_nxt;
  wire [2-1:0] per_valid;
  assign per_valid_en = PERIOD_INT_wen_wr | PERIOD_FRAC_wen_wr;
  assign per_valid_rst = SOFT_RESET_wr | (&per_valid);
  assign per_valid_nxt = per_valid | ({PERIOD_INT_wen_wr, PERIOD_FRAC_wen_wr});
  iob_reg_re #(
      .DATA_W(2)
  ) valid_reg (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),
      .rst_i (per_valid_rst),
      .en_i  (per_valid_en),
      .data_i(per_valid_nxt),
      .data_o(per_valid)
  );
  assign period_full_wen = &per_valid;


   iob_nco_sync #(
    .PERIOD_W(PERIOD_W)
   ) nco_sync_inst (
    .clk_i(clk_i),
    .cke_i(cke_i),
    .arst_i(arst_i),

    .clk_in_i(clk_in_i),
    .clk_in_arst_i(clk_in_arst_i),
    .clk_in_cke_i(clk_in_cke_i),

    .soft_reset_i(SOFT_RESET_wr),
    .enable_i(ENABLE_wr),
    .period_wdata_i(period_full_wdata),
    .period_wen_i(period_full_wen),

    .soft_reset_o(soft_reset),
    .enable_o(enable),
    .period_wdata_o(period_wdata),
    .period_wen_o(period_wen)
   );


  // PERIOD Manual logic
  assign PERIOD_INT_wready_wr = 1'b1;
  assign PERIOD_FRAC_wready_wr = 1'b1;

  reg [DATA_W-1:0] quant;

  assign diff = period_r - {quant, {FRAC_W{1'b0}}};
  assign clk_int = (cnt > (quant / 2));

  always @* begin
    if (acc_out[FRAC_W-1:0] == {1'b1, {FRAC_W - 1{1'b0}}})
      quant = acc_out[PERIOD_W-1:FRAC_W] + ^acc_out[PERIOD_W-1:FRAC_W];
    else if (acc_out[FRAC_W-1]) quant = acc_out[PERIOD_W-1:FRAC_W] + 1'b1;
    else quant = acc_out[PERIOD_W-1:FRAC_W];
  end

  //fractional period value register
  iob_reg_re #(
      .DATA_W(PERIOD_W)
  ) per_reg (
      .clk_i (clk_in_i),
      .cke_i (clk_in_cke_i),
      .arst_i(clk_in_arst_i),
      .rst_i (soft_reset),
      .en_i  (period_wen),
      .data_i(period_wdata),
      .data_o(period_r)
  );

  //output clock register
  iob_reg_re #(
      .DATA_W(1)
  ) clk_out_reg (
      .clk_i (clk_in_i),
      .cke_i (clk_in_cke_i),
      .arst_i(clk_in_arst_i),
      .rst_i (soft_reset),
      .en_i  (enable),
      .data_i(clk_int),
      .data_o(clk_out_o)
  );

  //modulator accumulator
  iob_acc_ld #(
      .DATA_W(PERIOD_W)
  ) acc_ld (
      .clk_i (clk_in_i),
      .cke_i (clk_in_cke_i),
      .arst_i(clk_in_arst_i),
      .rst_i(soft_reset),
      .en_i(enable),
      .ld_i(period_wen),
      .ld_val_i(period_wdata),
      .incr_i(diff),
      .data_o(acc_out),
      .data_nxt_o()
  );

  //output period counter
  iob_modcnt #(
      .DATA_W(DATA_W)
  ) modcnt (
      .clk_i (clk_in_i),
      .cke_i (clk_in_cke_i),
      .arst_i(clk_in_arst_i),
      .rst_i (period_wen),
      .en_i  (enable),
      .mod_i (quant),
      .data_o(cnt)
  );

endmodule
