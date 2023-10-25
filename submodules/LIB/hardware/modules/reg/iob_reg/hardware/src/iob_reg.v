`timescale 1ns / 1ps

module iob_reg #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {DATA_W{1'b0}},
   parameter CLKEDGE = "posedge"
) (
   `include "clk_en_rst_s_port.vs"

   input      [DATA_W-1:0] data_i,
   output reg [DATA_W-1:0] data_o
);

   generate
      if (CLKEDGE == "posedge") begin : positive_edge
         always @(posedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               data_o <= RST_VAL;
            end else if (cke_i) begin
               data_o <= data_i;
            end
         end
      end else if (CLKEDGE == "negedge") begin : negative_edge
         always @(negedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               data_o <= RST_VAL;
            end else if (cke_i) begin
               data_o <= data_i;
            end
         end
      end
   endgenerate

endmodule
