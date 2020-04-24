//
// 
//


`timescale 1ns / 1ps

module expand_word
  #(
    parameter N = 4, //number of words
    parameter M = 4  //word width
    )
   (
    input [N-1:0]    valid,
    input [M-1:0]    word_in,
    output [N*M-1:0] cat_bus_out
    );

   //create expanded valid mask
   wire [N*M-1:0]     expanded_valid;          
   expand_mask  #(.N(N), .M(M)) expander (.mask_in(valid), .mask_out(expanded_valid) );
   

   //create word of replicated input words
   genvar                i;
   wire [N*M-1:0]        replicated;
 
   generate 
      for (i=0; i<N; i=i+1) begin : m_loop
         assign replicated[(i+1)*M-1 -: M] = word_in;
      end
   endgenerate

   //apply expanded valid mask to replicated
   assign cat_bus_out = expanded_valid & replicated;
   
endmodule
