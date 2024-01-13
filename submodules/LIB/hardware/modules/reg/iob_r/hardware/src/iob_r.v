`timescale 1ns / 1ps
`include "iob_reg_conf.vh"

module iob_r #(
   `include "iob_reg_params.vs"
) (
`include "clk_rst_s_port.vs"

   input      [DATA_W-1:0] iob_r_data_i,
   output reg [DATA_W-1:0] iob_r_data_o
);

   localparam RST_POL = `IOB_REG_RST_POL;

   generate
      if (RST_POL == 1) begin: g_rst_pol_1
         always @(posedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               iob_r_data_o <= RST_VAL;
            end else begin
               iob_r_data_o <= iob_r_data_i;
            end
         end
      end else begin: g_rst_pol_0
         always @(posedge clk_i, negedge arst_i) begin
            if (~arst_i) begin
               iob_r_data_o <= RST_VAL;
            end else begin
               iob_r_data_o <= iob_r_data_i;
            end
         end
      end
   endgenerate

endmodule
