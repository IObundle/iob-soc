`timescale 1ns / 1ps

module iob_reg #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {DATA_W{1'b0}},
   parameter CLKEDGE = "posedge"
) (
   `include "iob_reg_io.vs"
);
   reg [DATA_W-1:0] data_o_reg;
   assign data_o = data_o_reg;
   generate
      if (CLKEDGE == "posedge") begin : positive_edge
         always @(posedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               data_o_reg <= RST_VAL;
            end else if (cke_i) begin
               data_o_reg <= data_i;
            end
         end
      end else if (CLKEDGE == "negedge") begin : negative_edge
         always @(negedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               data_o_reg <= RST_VAL;
            end else if (cke_i) begin
               data_o_reg <= data_i;
            end
         end
      end
   endgenerate

endmodule
