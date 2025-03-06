`timescale 1ns / 1ps

module iob_prio_enc #(
   parameter W    = 21,
   // Priority: "LOW", "HIGH"
   parameter MODE = "LOW"  //"LOW" -> smaller index
) (
   input      [        W-1:0] unencoded_i,
   output reg [$clog2(W+1)-1:0] encoded_o
);
   wire [W:0] unencoded_int;
   // MSB = 1 if unencoded_i = 0
   assign unencoded_int = {(~(|unencoded_i)), unencoded_i};

   integer pos;
   generate
      if (MODE == "LOW") begin : gen_low_prio
         always @* begin
            encoded_o = 1'b0;  //placeholder default value
            for (pos = W; pos != -1; pos = pos - 1) begin
               if (unencoded_int[pos]) begin
                  encoded_o = pos;
               end
            end
         end
      end else begin : gen_highest_prio  //MODE == "HIGH"
         always @* begin
            encoded_o = 1'b0;  //placeholder default value
            for (pos = {W{1'd0}}; pos < (W+1); pos = pos + 1) begin
               if (unencoded_int[pos]) begin
                  encoded_o = pos;
               end
            end
         end
      end
   endgenerate
endmodule
