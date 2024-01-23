`timescale 1ns / 1ps


module iob_mux #(
   parameter DATA_W = 21,
   parameter N      = 21
) (
   input      [($clog2(N)+($clog2(N)==0))-1:0] sel_i,
   input      [                (N*DATA_W)-1:0] data_i,
   output reg [                    DATA_W-1:0] data_o
);

   integer input_sel;
   always @* begin
      data_o = {DATA_W{1'b0}};
      for (input_sel = 0; input_sel < N; input_sel = input_sel + 1) begin : gen_mux
         if (input_sel == sel_i) begin
            data_o = data_i[input_sel*DATA_W+:DATA_W];
         end
      end
   end

endmodule
