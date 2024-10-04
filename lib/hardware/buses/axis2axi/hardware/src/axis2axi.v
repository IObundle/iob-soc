// SPDX-FileCopyrightText: 2024 IObundle
//
// SPDX-License-Identifier: MIT

`timescale 1ns / 1ps

/* Important: This unit has not been tested on a FPGA. Only simulation. Take care

Simple AXI Stream (AXIS) to AXI adapter
   This unit breaks down an AXIS into multiple bursts of AXI.
   For AXIS In, this is performed transparently. For AXIS Out, a length argument is required. 
   Address (and length) are set by using the config_in or config_out interfaces. They both use a AXI like handshake process [if (valid && ready) == 1 then start transfer].
   The config_ready interfaces can also be used directly to probe the state of the transfer. When asserted, they indicate that the unit has finished all the data transfers.
   Both AXIS In and AXIS Out operate individually and can work simultaneously (these units can also be instantiated individually, check axis2axi_in.v and axis2axi_out.v)
   4k boundaries are handled automatically.

AXIS In:
   After configuring the config_in values, the axis_in interface can be used. There is no limit to the amount of data that can be sent.

AXIS Out:
   After configuring the config_out values, the unit will start producing data in the axis_out interface. 
   Length is given as the amount of dwords. A length of 1 means that one transfer is performed. (A length of zero does nothing)
   If the axis_out interface is stalled permanently before completing the full transfer, the unit might block the entire system, as it will continue to keep the AXI connection alive.
   If for some reason the user realises that it requested a length bigger then need, the user still needs to keep consuming data out of the axis_out interface. Only when config_out_ready_o is asserted has the transfer fully completed

Very important: if the transfer goes over the maximum size, given by AXI_ADDR_W, the transfer will wrap around and will start reading/writing to the lower addresses. 
*/

module axis2axi #(
    parameter ADDR_W    = 0,
    parameter DATA_W    = 32,          // We currently only support 4 byte transfers
    parameter AXI_LEN_W = 8,
    parameter AXI_ID_W  = 1,
    parameter BURST_W   = 0,
    parameter BUFFER_W  = BURST_W + 1
) (
    `include "axis2axi_io.vs"
);

  axis2axi_in #(
      .AXI_ADDR_W(ADDR_W),
      .AXI_DATA_W(DATA_W),
      .AXI_LEN_W (AXI_LEN_W),
      .AXI_ID_W  (AXI_ID_W),
      .BURST_W   (BURST_W)
  ) axis2axi_in_inst (
      .config_in_addr_i (config_in_addr_i),
      .config_in_valid_i(config_in_valid_i),
      .config_in_ready_o(config_in_ready_o),

      .ext_mem_w_en_o  (ext_mem_w_en_o),
      .ext_mem_w_data_o(ext_mem_w_data_o),
      .ext_mem_w_addr_o(ext_mem_w_addr_o),
      .ext_mem_r_en_o  (ext_mem_r_en_o),
      .ext_mem_r_addr_o(ext_mem_r_addr_o),
      .ext_mem_r_data_i(ext_mem_r_data_i),

      .axis_in_data_i (axis_in_data_i),
      .axis_in_valid_i(axis_in_valid_i),
      .axis_in_ready_o(axis_in_ready_o),

      `include "axis2axi_in_axi_write_m_m_portmap.vs"

      .clk_i (clk_i),
      .cke_i (cke_i),
      .rst_i (rst_i),
      .arst_i(arst_i)
  );

  axis2axi_out #(
      .AXI_ADDR_W(ADDR_W),
      .AXI_DATA_W(DATA_W),
      .AXI_LEN_W (AXI_LEN_W),
      .AXI_ID_W  (AXI_ID_W),
      .BURST_W   (BURST_W)
  ) axis2axi_out_inst (
      .config_out_addr_i  (config_out_addr_i),
      .config_out_length_i(config_out_length_i),
      .config_out_valid_i (config_out_valid_i),
      .config_out_ready_o (config_out_ready_o),

      .axis_out_data_o (axis_out_data_o),
      .axis_out_valid_o(axis_out_valid_o),
      .axis_out_ready_i(axis_out_ready_i),

      `include "axis2axi_out_axi_read_m_m_portmap.vs"

      .clk_i (clk_i),
      .cke_i (cke_i),
      .rst_i (rst_i),
      .arst_i(arst_i)
  );

endmodule
