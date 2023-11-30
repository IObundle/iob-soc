`timescale 1ns / 1ps

module iob_sync #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {DATA_W{1'b0}}
) (
   `include "clk_rst_s_port.vs"
   input      [DATA_W-1:0] signal_i,
   output reg [DATA_W-1:0] signal_o
);

   reg [DATA_W-1:0] synchronizer;

   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         synchronizer <= RST_VAL;
      end else begin
         synchronizer <= signal_i;
      end
   end
   
   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         signal_o <= RST_VAL;
      end else begin
         signal_o <= synchronizer;
      end
   end

endmodule
