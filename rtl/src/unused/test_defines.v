`define valid _valid
`define a(x) wire [1:0] x`valid = 3;


module tb;

   `a(my)
   initial 
     $display(my_valid);
   
endmodule
