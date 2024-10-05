// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

//
// Tasks for the AXI Stream protocol
//

// Write data to AXI Stream
task axis_write;
   input [AXIS_W_DATA_W-1:0] data;
   input last;

   begin
      @(posedge axis_w_clk) axis_w_tvalid = 1;  //sync and assign
      axis_w_tdata = data;
      axis_w_tlast = last;

      #1 while (!axis_w_tready) #1;

      @(posedge axis_w_clk) axis_w_tvalid = 0;
   end
endtask

// Read data from AXI Stream
task axis_read;
   output [AXIS_R_DATA_W-1:0] data;
   output last;

   begin
      @(posedge axis_r_clk) axis_r_tready = 1;

      #1 while (!axis_r_tvalid) #1;

      data = axis_r_tdata;
      last = axis_r_tlast;
      @(posedge axis_r_clk) #1 axis_r_tready = 0;
   end
endtask
