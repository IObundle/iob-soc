//
// Tasks for the IOb Native protocol
//

// Write data to IOb Native slave
task iob_write;
   input [ADDR_W-1:0] addr;
   input [DATA_W-1:0] data;
   input [$clog2(DATA_W):0] width;

   begin
      @(posedge clk) #1 iob_avalid_i = 1;  //sync and assign
      iob_addr_i  = `IOB_WORD_ADDR(addr);
      iob_wdata_i = `IOB_GET_WDATA(addr, data);
      iob_wstrb_i = `IOB_GET_WSTRB(addr, width);

      while (!iob_ready_o) #1;

      @(posedge clk) iob_avalid_i = 0;
      iob_wstrb_i = 0;
   end
endtask

// Read data from IOb Native slave
task iob_read;
   input [ADDR_W-1:0] addr;
   output [DATA_W-1:0] data;
   input [$clog2(DATA_W):0] width;

   begin
      @(posedge clk) #1 iob_avalid_i = 1;
      iob_addr_i = `IOB_WORD_ADDR(addr);

      while (!iob_ready_o) #1;
      @(posedge clk) #1 iob_avalid_i = 0;

      while (!iob_rvalid_o) #1;
      data = #1 `IOB_GET_RDATA(addr, iob_rdata_o, width);
   end
endtask
