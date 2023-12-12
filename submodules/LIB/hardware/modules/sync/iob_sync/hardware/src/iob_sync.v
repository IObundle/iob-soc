`timescale 1ns / 1ps
`include "iob_reg_conf.vh"

module iob_sync #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {DATA_W{1'b0}}
) (
   `include "clk_rst_s_port.vs"
   input      [DATA_W-1:0] signal_i,
   output reg [DATA_W-1:0] signal_o
);

   localparam RST_POL = `IOB_REG_RST_POL;
   
   reg [DATA_W-1:0] synchronizer;

   generate
      if (RST_POL == 1) begin: rst_pol_1
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
      end else begin: rst_pol_0 // block: rst_pol_1
         always @(posedge clk_i, negedge arst_i) begin
            if (~arst_i) begin
               synchronizer <= RST_VAL;
            end else begin
               synchronizer <= signal_i;
            end
         end
   
         always @(posedge clk_i, negedge arst_i) begin
            if (~arst_i) begin
               signal_o <= RST_VAL;
            end else begin
               signal_o <= synchronizer;
            end
         end
      end // block: rst_pol_1
   endgenerate // block: rst_pol_0
   
endmodule
