`define a(x) wire x = 3;


module tb;

   `a(x)
   initial 
     $display(x);
   
endmodule
