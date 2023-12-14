`timescale 1ns / 1ps

module iob_edge_detect
#(
  parameter EDGE_TYPE = "rising", // "rising", "falling", "both"
  parameter OUT_TYPE = "pulse" // "step", "pulse"
) (
`include "clk_en_rst_s_port.vs"
   input rst_i,
   input  bit_i,
   output detected_o
);

   wire   bit_int;
   reg    bit_int_q;

   generate
      if (EDGE_TYPE == "rising") begin : gen_rising
         assign bit_int = bit_i;
      end else if (EDGE_TYPE == "falling") begin : gen_falling
         assign bit_int = ~bit_i;
      end else begin : gen_default_rising
         assign bit_int = bit_i;
      end
   endgenerate

   reg enabled;

   generate if (OUT_TYPE == "pulse") begin : gen_pulse
      assign detected_o = bit_int & ((~bit_int_q) & enabled);
   end else if (OUT_TYPE == "step") begin : gen_step
      reg detected_q;
      assign detected_o = detected_q | (bit_int & ((~bit_int_q) & enabled));

      always @(posedge clk_i, posedge arst_i) begin
         if(arst_i) begin
            detected_q <= 1'b0;
         end else if (cke_i) begin
            if(rst_i) begin
               detected_q <= 1'b0;
            end else begin
               detected_q <= detected_o;
            end
         end
      end
   end else begin
      assign detected_o = 1'b0;
   end endgenerate

   always @(posedge clk_i, posedge arst_i) begin
      if(arst_i) begin
         bit_int_q <= 1'b0;
         enabled <= 1'b0;
      end else if (cke_i) begin
         if(rst_i) begin
            bit_int_q <= 1'b0;
            enabled <= 1'b0;
         end else begin
            bit_int_q <= bit_int;
            enabled <= 1'b1;
         end
      end
   end

endmodule
