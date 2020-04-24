//
// 
//


`timescale 1ns / 1ps

module expand_mask
  #(
    parameter N = 4, //number of words
    parameter M = 4  //word width
    )
   (
    input [N-1:0]   mask_in,
    output [N*M-1:0]  mask_out
    );

   genvar                i;
   //generate masks
   generate 
      for (i=0; i<N; i=i+1) begin : m_loop
         assign mask_out[(i+1)*M-1 -: M] = {M{mask_in[i]}};
      end
   endgenerate
   
endmodule
