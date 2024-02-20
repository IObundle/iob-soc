/*****************************************************************************

  Description: IOB_INOUT 3-State Buffer

  Copyright (C) 2020 IObundle, Lda  All rights reserved

******************************************************************************/
`timescale 1ns / 1ps

module alt_iobuf (
   input  in_i,
   input  en_i,
   output out_o,
   inout  in_out_io
);

   assign in_out_io = en_i ? in_i : 1'bz;
   assign out_o     = in_out_io;

endmodule
