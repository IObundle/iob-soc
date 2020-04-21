//
// inputs N concatenated M-bit words and respective valid bits
// outputs left most valid word
//


`timescale 1ns / 1ps

module priority_enc
  #(
    parameter N = 4, //NUMBER OF WORDS
    parameter M = 4 //WORD WIDTH
    )
   (
    input [N-1:0]   valid,
    input [N*M-1:0] word_in,
    output [M-1:0]  word_out
    );


   wire [N-1:0]          l1m; //bit leading one mask
   wire [N*M-1:0]        wmask;//word level mask
   
   //M-bit OR-sumation words
   wire [M-1:0]          orsum [N:0];

   leading1_mask_enc #(.N(N)) l1mask_enc (.valid(valid), .l1me(l1m));

   expand_mask #(.N(N), .M(M)) mask_expand (.mask_in(l1m), .mask_out(wmask));
      
   genvar                i;

   //apply mask to N-word input and accumulate
   assign orsum[0] = {M{1'b0}};
   generate
      for (i=1; i<=N; i=i+1) begin : s_loop
         assign orsum[i] = orsum[i-1] + (wmask[i*M-1 -: M] & word_in[i*M-1 -: M]);
      end
   endgenerate

   assign word_out = orsum[N];
   
endmodule
