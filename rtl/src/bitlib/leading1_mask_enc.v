`timescale 1ns / 1ps

module leading1_mask_enc
  #(
    parameter N = 4 //WORD WIDTH
    )
   (
    input [N-1:0]   valid,
    output [N-1:0]  l1me
    );

   wire [N:0]            l1; //leading ones representation

   wire [N-1:0]            l1me; //leading 1 mask
   
   genvar                  i;
   
   //generate leading ones encoding (l1e):
   //replaces leading 0s with 1s
   //replaces rest of word with zero
   
   assign l1[N] = 1'b1;  
   generate 
      for (i=N-1; i>=0; i=i-1) begin : l1_loop
        assign l1[i] = l1[i+1] & ~valid[i];
      end
   endgenerate  

   //generate leading ones mask (l1m) from l1e:
   //replace leading ones with zeros
   //replace most signicant 0 with 1

   generate 
      for (i=N; i>0; i=i-1) begin : l1me_loop
        assign l1me[i-1] = l1[i] & ~l1[i-1];
      end
   endgenerate
   
endmodule
