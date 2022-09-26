// ----------------------------------------------------------------------
// Copyright (c) 2016, The Regents of the University of California All
// rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
// 
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
// 
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
// 
//     * Neither the name of The Regents of the University of California
//       nor the names of its contributors may be used to endorse or
//       promote products derived from this software without specific
//       prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL REGENTS OF THE
// UNIVERSITY OF CALIFORNIA BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
// OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
// USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
// DAMAGE.
// ----------------------------------------------------------------------
// Modified for latest Vivado 2018.x and Quartus 18.x 
//      by Yasunori Osana at University of the Ryukyus
// License of the Vivado/Quartus patch follows the original license above.
// ----------------------------------------------------------------------
//----------------------------------------------------------------------------
// Filename:			functions.vh
// Version:				1.00
// Verilog Standard:	Verilog-2005
// Description:         A simple file containing clog2 function declarations
// Author:				Dustin Richmond (@darichmond)
//-----------------------------------------------------------------------------
`ifndef clog2
`define clog2(N) ( \
N == 0 ? 32 : \
N == 1 ? 0 : \
N <= 2 ? 1 : \
N <= 4 ? 2 : \
N <= 8 ? 3 : \
N <= 16 ? 4 : \
N <= 32 ? 5 : \
N <= 64 ? 6 : \
N <= 128 ? 7 : \
N <= 256 ? 8 : \
N <= 512 ? 9 : \
N <= 1024 ? 10 : \
N <= 2048 ? 11 : \
N <= 4096 ? 12 : \
N <= 8192 ? 13 : \
N <= 16384 ? 14 : \
N <= 32768 ? 15 : \
N <= 65536 ? 16 : \
N <= 131072 ? 17 : \
N <= 262144 ? 18 : \
N <= 524288 ? 19 : \
N <= 1048576 ? 20 : \
N <= 2097152 ? 21 : \
N <= 4194304 ? 22 : \
N <= 8388608 ? 23 : \
N <= 16777216 ? 24 : \
N <= 33554432 ? 25 : \
N <= 67108864 ? 26 : \
N <= 134217728 ? 27 : \
N <= 268435456 ? 28 : \
N <= 536870912 ? 29 : \
N <= 1073741824 ? 30 : \
N <= 2147483648 ? 31 : \
           32 )
`endif
`ifndef clog2s     
// clog2s -- calculate the ceiling log2 value, min return is 1 (safe).
`define clog2s(N) ( \
N == 0 ? 32 : \
N <= 1 ? 1 : \
N <= 2 ? 1 : \
N <= 4 ? 2 : \
N <= 8 ? 3 : \
N <= 16 ? 4 : \
N <= 32 ? 5 : \
N <= 64 ? 6 : \
N <= 128 ? 7 : \
N <= 256 ? 8 : \
N <= 512 ? 9 : \
N <= 1024 ? 10 : \
N <= 2048 ? 11 : \
N <= 4096 ? 12 : \
N <= 8192 ? 13 : \
N <= 16384 ? 14 : \
N <= 32768 ? 15 : \
N <= 65536 ? 16 : \
N <= 131072 ? 17 : \
N <= 262144 ? 18 : \
N <= 524288 ? 19 : \
N <= 1048576 ? 20 : \
N <= 2097152 ? 21 : \
N <= 4194304 ? 22 : \
N <= 8388608 ? 23 : \
N <= 16777216 ? 24 : \
N <= 33554432 ? 25 : \
N <= 67108864 ? 26 : \
N <= 134217728 ? 27 : \
N <= 268435456 ? 28 : \
N <= 536870912 ? 29 : \
N <= 1073741824 ? 30 : \
N <= 2147483648 ? 31 : \
           32 )

`endif
