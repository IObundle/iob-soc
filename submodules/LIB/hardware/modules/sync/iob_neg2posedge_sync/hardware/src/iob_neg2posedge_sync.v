`timescale 1ns / 1ps
`include "iob_reg_conf.vh"

module iob_neg2posedge_sync #(
   parameter DATA_W  = 21,
   parameter RST_VAL = {2*DATA_W{1'b0}}
) (
   `include "clk_en_rst_s_port.vs"
   input      [DATA_W-1:0] signal_i,
   output reg [DATA_W-1:0] signal_o
);
   
   localparam RST_POL = `IOB_REG_RST_POL;
   
   reg [DATA_W-1:0] synchronizer;

   generate
      if (RST_POL == 1) begin: g_rst_pol_1
         // negedge stage
         always @(negedge clk_i, posedge arst_i) begin
            if (arst_i) begin
               synchronizer <= RST_VAL;
            end else if (cke_i) begin
               synchronizer <= signal_i;
            end
         end
         // posedge stage
         always @(posedge clk_i, posedge arst_i) begin
            if(arst_i) begin
               signal_o <= RST_VAL;
            end else if (cke_i) begin
               signal_o <= synchronizer;
            end
         end
      end else begin: g_rst_pol_0 // block: g_rst_pol_1
         // negedge stage
         always @(negedge clk_i, negedge arst_i) begin
            if (!arst_i) begin
               synchronizer <= RST_VAL;
            end else if (cke_i) begin
               synchronizer <= signal_i;
            end
         end
         // posedge stage
         always @(posedge clk_i, negedge arst_i) begin
            if(!arst_i) begin
               signal_o <= RST_VAL;
            end else if (cke_i) begin
               signal_o <= synchronizer;
            end
         end
      end // block: g_rst_pol_0
   endgenerate // block: g_rst_pol_1

endmodule
