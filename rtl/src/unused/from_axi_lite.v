`timescale 1ns / 1ps

module from_axi_lite (
                      input         clk,

                      // AXI4-lite interface
                      input         s_axis_tvalid,
                      output        s_axis_tready,
                      input [31:0]  s_axis_tdata,

                      // Native interface
                      input         mem_valid,
                      output        mem_ready,
                      input [ 3:0]  mem_wstrb,
                      output [31:0] mem_rdata
                      );

   assign mem_ready = s_axis_tvalid;
   assign s_axis_tready = mem_valid && !mem_wstrb;
   assign mem_rdata = s_axis_tdata;
endmodule

//NATIVE - Master AXI_STREAM adapter
module native_m_axis_adapter (
                              input         clk,

                              // AXI4-lite interface
                              output        m_axis_tvalid,
                              input         m_axis_tready,
                              output [31:0] m_axis_tdata,

                              // Native interface
                              input         mem_valid,
                              output        mem_ready,
                              input [31:0]  mem_wdata,
                              input [ 3:0]  mem_wstrb
                              );
   reg                                      ack_wvalid;
   reg                                      xfer_done;

   assign m_axis_tvalid = mem_valid && |mem_wstrb && !ack_wvalid;
   assign m_axis_tdata = mem_wdata;
   assign mem_ready = m_axis_tready;

   always @(posedge clk) begin
      xfer_done <= mem_valid && mem_ready;
      if (m_axis_tready && m_axis_tvalid)
        ack_wvalid <= 1;
      if (xfer_done || !mem_valid) begin
         ack_wvalid <= 0;
      end
   end
endmodule
