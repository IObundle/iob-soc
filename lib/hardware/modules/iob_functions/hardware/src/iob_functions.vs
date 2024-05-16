function [31:0] iob_max;
   input [31:0] a;
   input [31:0] b;
   begin
      if (a > b) iob_max = a;
      else iob_max = b;
   end
endfunction

function [31:0] iob_min;
   input [31:0] a;
   input [31:0] b;
   begin
      if (a < b) iob_min = a;
      else iob_min = b;
   end
endfunction
