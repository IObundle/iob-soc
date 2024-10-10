`timescale 1ns / 1ps
`include "iob_r_rstn_conf.vh"

module iob_r_rstn #(
   `include "iob_r_rstn_params.vs"
) (
`include "clk_rst_s_port.vs"

   input      [DATA_W-1:0] iob_r_data_i,
   output reg [DATA_W-1:0] iob_r_data_o
);

    always @(posedge clk_i, negedge arst_i) begin
        if (~arst_i) begin
            iob_r_data_o <= RST_VAL;
        end else begin
            iob_r_data_o <= iob_r_data_i;
        end
    end

endmodule
