// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

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

function [31:0] iob_cshift_left;
   input [31:0] DATA;
   input integer DATA_W;
   input integer SHIFT;
   begin
      iob_cshift_left = (DATA << SHIFT) | (DATA >> (DATA_W - SHIFT));
   end
endfunction

function [31:0] iob_cshift_right;
   input [31:0] DATA;
   input integer DATA_W;
   input integer SHIFT;
   begin
      iob_cshift_right = (DATA >> SHIFT) | (DATA << (DATA_W - SHIFT));
   end
endfunction