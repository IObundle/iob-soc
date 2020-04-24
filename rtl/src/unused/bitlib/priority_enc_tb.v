`timescale 1ns / 1ps

`define N 4
`define M 4


module priority_enc_tb;

   reg [`N-1:0] v;
   reg [`M*`N-1:0] wi;
   wire [`M-1:0]   wo;
   
   
   
   initial begin

      v = 0; wi = 16'hABCD;
      #10;

      $display("%04b", uut.valid);
      $display("%x", uut.word_in);
      $display("%04b", uut.l1m);
      $display();
      $display("%x", uut.wmask[0]);
      $display("%x", uut.wmask[1]);
      $display("%x", uut.wmask[2]);
      $display("%x", uut.wmask[3]);
      $display();      
      $display();
      $display("%x", uut.orsum[0]);
      $display("%x", uut.orsum[1]);
      $display("%x", uut.orsum[2]);
      $display("%x", uut.orsum[3]);
      $display("%x", uut.orsum[4]);
      $display();      
      $display("%x", uut.word_out);
   end

   priority_enc #(.N(`N), .M(`M)) uut (.valid(v), .word_in(wi), .word_out(wo));

endmodule // priority_enc_tb

