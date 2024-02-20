`timescale 1 ns / 1 ps

module iob_fp_dq # (
             parameter WIDTH=8,
             parameter DEPTH=2
             )
  (
   input              clk_i,
   input              rst_i,
   output [WIDTH-1:0] q_o,
   input [WIDTH-1:0]  d_i
   );

   integer            i;
   integer            j;
   reg [WIDTH-1:0]    delay_line [DEPTH-1:0];
   always @(posedge clk_i,posedge rst_i) begin
      if(rst_i) begin
         for (i=0; i < DEPTH; i=i+1) begin
            delay_line[i] <= 0;
         end
      end else begin
         delay_line[0] <= d_i;
         for (j=1; j < DEPTH; j=j+1) begin
            delay_line[j] <= delay_line[j-1];
         end
      end
   end

   assign q_o = delay_line[DEPTH-1];

endmodule
