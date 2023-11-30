`timescale 1ns / 1ps

module iob_reg #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {DATA_W{1'b0}}
) (
   `include "iob_reg_io.vs"
);
   reg [DATA_W-1:0] data_r;

   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         data_r <= RST_VAL;
      end else if (cke_i) begin
         data_r <= data_i;
      end
   end

   assign data_o = data_r;

endmodule
