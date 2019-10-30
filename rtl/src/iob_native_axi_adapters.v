`timescale 1ns / 1ps
//This modules were adapted from picorv32_axi_adapter presented in file
//picorv32.v, under /submodules/iob-rv32

//NATIVE - AXI_LITE adapter
module native_axi_adapter (
                             input         clk, resetn,

                             // AXI4-lite interface
                             output        mem_axi_awvalid,
                             input         mem_axi_awready,
                             output [31:0] mem_axi_awaddr,

                             output        mem_axi_wvalid,
                             input         mem_axi_wready,
                             output [31:0] mem_axi_wdata,
                             output [ 3:0] mem_axi_wstrb,

                             input         mem_axi_bvalid,
                             output        mem_axi_bready,

                             output        mem_axi_arvalid,
                             input         mem_axi_arready,
                             output [31:0] mem_axi_araddr,

                             input         mem_axi_rvalid,
                             output        mem_axi_rready,
                             input [31:0]  mem_axi_rdata,

                             // Native interface
                             input         mem_valid,
                             output        mem_ready,
                             input [31:0]  mem_addr,
                             input [31:0]  mem_wdata,
                             input [ 3:0]  mem_wstrb,
                             output [31:0] mem_rdata
                             );
   reg                                     ack_awvalid;
   reg                                     ack_arvalid;
   reg                                     ack_wvalid;
   reg                                     xfer_done;

   assign mem_axi_awvalid = mem_valid && |mem_wstrb && !ack_awvalid;
   assign mem_axi_awaddr = mem_addr;

   assign mem_axi_arvalid = mem_valid && !mem_wstrb && !ack_arvalid;
   assign mem_axi_araddr = mem_addr;

   assign mem_axi_wvalid = mem_valid && |mem_wstrb && !ack_wvalid;
   assign mem_axi_wdata = mem_wdata;
   assign mem_axi_wstrb = mem_wstrb;

   assign mem_ready = mem_axi_bvalid || mem_axi_rvalid;
   assign mem_axi_bready = mem_valid && |mem_wstrb;
   assign mem_axi_rready = mem_valid && !mem_wstrb;
   assign mem_rdata = mem_axi_rdata;

   always @(posedge clk) begin
      if (!resetn) begin
         ack_awvalid <= 0;
      end else begin
         xfer_done <= mem_valid && mem_ready;
         if (mem_axi_awready && mem_axi_awvalid)
           ack_awvalid <= 1;
         if (mem_axi_arready && mem_axi_arvalid)
           ack_arvalid <= 1;
         if (mem_axi_wready && mem_axi_wvalid)
           ack_wvalid <= 1;
         if (xfer_done || !mem_valid) begin
            ack_awvalid <= 0;
            ack_arvalid <= 0;
            ack_wvalid <= 0;
         end
      end
   end
endmodule

//NATIVE - Slave AXI_STREAM adapter
module native_s_axis_adapter (
                             input         clk,

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
   reg                                     ack_wvalid;
   reg                                     xfer_done;

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
