`timescale 1ns / 1ps

module iob_sync #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {DATA_W{1'b0}},
   parameter CLKEDGE = "posedge"
) (
   `include "iob_sync_io.vs"
);

   reg [DATA_W-1:0] synchronizer;
   reg [DATA_W-1:0] output_reg;
   assign signal_o = output_reg;

   generate
      if (CLKEDGE == "posedge") begin : positive_edge
         always @(posedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               synchronizer <= RST_VAL;
            end else begin
               synchronizer <= signal_i;
            end
         end

         always @(posedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               output_reg <= RST_VAL;
            end else begin
               output_reg <= synchronizer;
            end
         end
      end else begin : negative_edge
         always @(negedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               synchronizer <= RST_VAL;
            end else begin
               synchronizer <= signal_i;
            end
         end

         always @(negedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               output_reg <= RST_VAL;
            end else begin
               output_reg <= synchronizer;
            end
         end
      end
   endgenerate

endmodule
