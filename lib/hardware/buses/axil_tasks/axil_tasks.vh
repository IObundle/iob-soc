// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

//
// AXI-Lite write and read 
//
//axil_address_write(addr, data, width, awvalid, wvalid, awaddr, wdata, wstrb)
task axil_write;
   input [AXIL_ADDR_W-1:0] addr;
   input [AXIL_DATA_W-1:0] data;
   input [$clog2(AXIL_DATA_W):0] width;

   localparam DATA_W = AXIL_DATA_W;

   begin
      @(posedge clk) #1 axil_awvalid_i = 1;  //sync and assign
      axil_wvalid_i = 1;
      axil_awaddr_i = `IOB_WORD_ADDR(addr);
      axil_wdata_i  = `IOB_GET_WDATA(addr, data);
      axil_wstrb_i  = `IOB_GET_WSTRB(addr, width);

      while (!axil_awready_o) #1;
      if (axil_wready_o) begin
         @(posedge clk) #1 axil_awvalid_i = 0;
         axil_wvalid_i = 0;  //awvalid must remain high one cycle before low     
      end else begin
         @(posedge clk) #1 axil_awvalid_i = 0;  //awvalid must remain high one cycle before low     
         while (!axil_wready_o) #1;
         @(posedge clk) #1 axil_wvalid_i = 0;
      end
   end
endtask


//axil_read (addr, data, width)
task axil_read;
   input [AXIL_ADDR_W-1:0] addr;
   output [AXIL_DATA_W-1:0] data;
   input [$clog2(AXIL_DATA_W):0] width;

   localparam DATA_W = AXIL_DATA_W;

   begin
      @(posedge clk) #1 axil_arvalid_i = 1;  //sync and assign
      axil_araddr_i = `IOB_WORD_ADDR(addr);
      axil_wstrb_i  = 0;

      while (!axil_arready_o) #1;
      @(posedge clk) #1 axil_arvalid_i = 0;  //arvalid must remain high one cycle before low

      while (!axil_rvalid_o) #1;
      data = `IOB_GET_RDATA(addr, axil_rdata_o, width);  //sample data
      @(posedge clk) #1;
   end
endtask
