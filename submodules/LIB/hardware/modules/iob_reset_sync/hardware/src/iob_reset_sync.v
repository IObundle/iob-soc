`timescale 1ns / 1ps

module iob_reset_sync (
   input  clk_i,
   input  arst_i,
   output arst_o
);

   reg [1:0] sync;

   always @(posedge clk_i, posedge arst_i) begin
      if (arst_i) begin
         sync <= 2'd3;
      end else begin
         sync <= {sync[0], 1'b0};
      end
   end

   assign arst_o = sync[1];

endmodule
