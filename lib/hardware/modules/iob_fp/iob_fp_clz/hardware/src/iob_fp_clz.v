`timescale 1ns / 1ps

module iob_fp_clz #(
             parameter DATA_W = 32 
             )
  (
   input [DATA_W-1:0]                data_i,
   output reg [$clog2(DATA_W+1)-1:0] data_o
   );

   localparam BIT_W = $clog2(DATA_W+1);

   integer                         i;

   always @* begin
      data_o = DATA_W[BIT_W-1:0];
      for (i=0; i < DATA_W; i=i+1) begin
         if (data_i[i]) begin
            data_o = (DATA_W[BIT_W-1:0] - i[BIT_W-1:0] - 1);
         end
      end
   end

endmodule
