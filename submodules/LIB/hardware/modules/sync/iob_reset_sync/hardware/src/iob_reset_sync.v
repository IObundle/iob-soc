`timescale 1ns / 1ps
`include "iob_reg_conf.vh"

module iob_reset_sync (
   input  clk_i,
   input  arst_i,
   output arst_o
);

   localparam RST_POL = `IOB_REG_RST_POL;

   reg [1:0] sync;

   generate
      if (RST_POL == 1) begin: rst_pol_1
         always @(posedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               sync <= 2'd3;
            end else begin
               sync <= {sync[0], 1'b0};
            end
         end
      end else begin: rst_pol_0 // block: rst_pol_1
         always @(posedge clk_i, negedge arst_i) begin
            if (!arst_i) begin
               sync <= 2'd0;
            end else begin
               sync <= {sync[0], 1'b1};
            end
         end
      end
   endgenerate

   assign arst_o = sync[1];
   
endmodule
