`timescale 1ns / 1ps
`include "iob_reg_conf.vh"

module iob_reg #(
    `include "iob_reg_params.vs"
) (
    `include "iob_reg_io.vs"
);

  localparam RST_POL = `IOB_REG_RST_POL;

  reg [DATA_W-1:0] data_o_reg;
  assign data_o = data_o_reg;
  generate
    if (RST_POL == 1) begin : g_rst_pol_1
      always @(posedge clk_i, posedge arst_i) begin
        if (arst_i) begin
          data_o_reg <= RST_VAL;
        end else if (cke_i) begin
          data_o_reg <= data_i;
        end
      end
    end else begin : g_rst_pol_0
      always @(posedge clk_i, negedge arst_i) begin
        if (~arst_i) begin
          data_o_reg <= RST_VAL;
        end else if (cke_i) begin
          data_o_reg <= data_i;
        end
      end
    end
  endgenerate

endmodule
