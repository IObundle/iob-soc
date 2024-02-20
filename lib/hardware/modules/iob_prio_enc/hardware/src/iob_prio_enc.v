`timescale 1ns / 1ps

module iob_prio_enc #(
   parameter W    = 21,
   // Priority: "LOW", "HIGH"
   parameter MODE = "LOW"  //"LOW" -> smaller index
) (
   input      [        W-1:0] unencoded_i,
   output reg [$clog2(W)-1:0] encoded_o
);

   integer pos;
   generate
      if (MODE == "LOW") begin : gen_low_prio
         always @* begin
            encoded_o = {$clog2(W) {1'd0}};  //In case input is 0
            for (pos = W - 1; pos != -1; pos = pos - 1) begin
               if (unencoded_i[pos]) begin
                  encoded_o = pos;
               end
            end
         end
      end else begin : gen_highest_prio  //MODE == "HIGH"
         always @* begin
            encoded_o = {$clog2(W) {1'd0}};  //In case input is 0
            for (pos = {W{1'd0}}; pos < W; pos = pos + 1) begin
               if (unencoded_i[pos]) begin
                  encoded_o = pos;
               end
            end
         end
      end
   endgenerate

endmodule
