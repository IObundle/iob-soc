`timescale 1ns / 1ps
`include "iob_reg_conf.vh"

module iob_regn #(
   `include "iob_reg_params.vs"
) (
`include "clk_en_rst_s_port.vs"

   input      [DATA_W-1:0] data_i,
   output reg [DATA_W-1:0] data_o
);

   localparam RST_POL = `IOB_REG_RST_POL;

   generate
      if (RST_POL == 1) begin: g_rst_pol_1
         always @(negedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               data_o <= RST_VAL;
            end else if (cke_i) begin
               data_o <= data_i;
            end
         end
      end else begin: g_rst_pol_0
         always @(negedge clk_i, negedge arst_i) begin
            if (~arst_i) begin
               data_o <= RST_VAL;
            end else if (cke_i) begin
               data_o <= data_i;
            end
         end
      end
   endgenerate

endmodule
