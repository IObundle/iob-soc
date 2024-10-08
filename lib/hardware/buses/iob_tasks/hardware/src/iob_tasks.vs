// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

//
// Tasks for the IOb Native protocol
//

`define IOB_NBYTES (DATA_W/8)
`define IOB_GET_NBYTES(WIDTH) (WIDTH/8 + |(WIDTH%8))
`define IOB_NBYTES_W $clog2(`IOB_NBYTES)
`define IOB_WORD_ADDR(ADDR) ((ADDR>>`IOB_NBYTES_W)<<`IOB_NBYTES_W)

`define IOB_BYTE_OFFSET(ADDR) (ADDR%(DATA_W/8))

`define IOB_GET_WDATA(ADDR, DATA) (DATA<<(8*`IOB_BYTE_OFFSET(ADDR)))
`define IOB_GET_WSTRB(ADDR, WIDTH) (((1<<`IOB_GET_NBYTES(WIDTH))-1)<<`IOB_BYTE_OFFSET(ADDR))
`define IOB_GET_RDATA(ADDR, DATA, WIDTH) ((DATA>>(8*`IOB_BYTE_OFFSET(ADDR)))&((1<<WIDTH)-1))

// Write data to IOb Native slave
task iob_write;
   input [ADDR_W-1:0] addr;
   input [DATA_W-1:0] data;
   input [$clog2(DATA_W):0] width;

   begin
      @(posedge clk) #1 iob_valid_i = 1;  //sync and assign
      iob_addr_i  = `IOB_WORD_ADDR(addr);
      iob_wdata_i = `IOB_GET_WDATA(addr, data);
      iob_wstrb_i = `IOB_GET_WSTRB(addr, width);

      #1 while (!iob_ready_o) #1;

      @(posedge clk) iob_valid_i = 0;
      iob_wstrb_i = 0;
   end
endtask

// Read data from IOb Native slave
task iob_read;
   input [ADDR_W-1:0] addr;
   output [DATA_W-1:0] data;
   input [$clog2(DATA_W):0] width;

   begin
      @(posedge clk) #1 iob_valid_i = 1;
      iob_addr_i = `IOB_WORD_ADDR(addr);
      iob_wstrb_i = 0;

      #1 while (!iob_ready_o) #1;
      @(posedge clk) #1 iob_valid_i = 0;

      while (!iob_rvalid_o) #1;
      data = #1 `IOB_GET_RDATA(addr, iob_rdata_o, width);
   end
endtask
