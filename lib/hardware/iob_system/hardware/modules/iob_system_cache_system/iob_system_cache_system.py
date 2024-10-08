# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    ADDR_W = py_params_dict["addr_w"] if "addr_w" in py_params_dict else 32
    DATA_W = py_params_dict["data_w"] if "data_w" in py_params_dict else 32
    MEM_ADDR_W = py_params_dict["mem_addr_w"] if "mem_addr_w" in py_params_dict else 32
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "FIRM_ADDR_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Width of firmware",
            },
            {
                "name": "DDR_DATA_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "NA",
                "descr": "Width of data bus in ddr interface",
            },
            {
                "name": "DDR_ADDR_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Width of address bus in ddr interface",
            },
            {
                "name": "AXI_ID_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "NA",
                "descr": "Width of id signal in axi interface",
            },
            {
                "name": "AXI_LEN_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Width of len signal in axi interface",
            },
            {
                "name": "AXI_DATA_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "NA",
                "descr": "Width of data bus in axi interface",
            },
            {
                "name": "AXI_ADDR_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Width of address bus in axi interface",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst_s",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "Clock, clock enable and reset",
            },
            {
                "name": "i_bus_s",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "port_prefix": "i_",
                    "DATA_W": DATA_W,
                    "ADDR_W": ADDR_W,
                },
                "descr": "Instruction bus",
            },
            {
                "name": "d_bus_s",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                    "port_prefix": "d_",
                    "DATA_W": DATA_W,
                    "ADDR_W": ADDR_W,
                },
                "descr": "Data bus",
            },
            {
                "name": "axi_m",
                "interface": {
                    "type": "axi",
                    "subtype": "master",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                },
                "descr": "AXI master interface for external memory",
            },
        ],
    }
    attributes_dict["wires"] = [
        {
            "name": "never_reset",
            "descr": "Reset signal for common components (always low)",
            "signals": [
                {"name": "always_low", "width": 1},
            ],
        },
        {
            "name": "icache",
            "interface": {
                "type": "iob",
                "wire_prefix": "icache_be_",
                "DATA_W": DATA_W,
                "ADDR_W": MEM_ADDR_W,
            },
            "descr": "iob-system external memory instruction cache interface",
        },
        {
            "name": "dcache",
            "interface": {
                "type": "iob",
                "wire_prefix": "dcache_be_",
                "DATA_W": DATA_W,
                "ADDR_W": MEM_ADDR_W,
            },
            "descr": "iob-system external memory data cache interface",
        },
        {
            "name": "l2cache",
            "interface": {
                "type": "iob",
                "wire_prefix": "l2cache_",
                "DATA_W": DATA_W,
                "ADDR_W": MEM_ADDR_W,
            },
            "descr": "iob-system external memory l2 cache interface",
        },
    ]
    attributes_dict["blocks"] = [
        {
            "core_name": "iob_merge",
            "name": "iob_i_d_into_l2_merge",
            "instance_name": "iob_i_d_into_l2_merge",
            "connect": {
                "clk_en_rst_s": "clk_en_rst_s",
                "reset_i": "never_reset",
                "input_0": "dcache",
                "input_1": "icache",
                "output_m": "l2cache",
            },
            "num_inputs": 2,
            "addr_w": MEM_ADDR_W,
        },
        {
            "core_name": "iob_cache",
            "instance_name": "iob_cache_inst",
            "instantiate": False,
        },
    ]
    attributes_dict["snippets"] = [
        {
            "verilog_code": f"""
  assign always_low = 1'b0;

  // Instruction cache instance
  iob_cache_iob #(
      .FE_ADDR_W    (FIRM_ADDR_W),
      .BE_ADDR_W    ({MEM_ADDR_W}),
      .NWAYS_W      (1),            //Number of ways
      .NLINES_W     (7),            //Cache Line Offset (number of lines)
      .WORD_OFFSET_W(3),            //Word Offset (number of words per line)
      .WTBUF_DEPTH_W(5),            //FIFO's depth -- 5 minimum for BRAM implementation
      .USE_CTRL     (0),            //Cache-Control can't be accessed
      .USE_CTRL_CNT (0)             //Remove counters
  ) icache (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),

      // Front-end interface
      .iob_valid_i (i_iob_valid_i),
      .iob_addr_i  (i_iob_addr_i[FIRM_ADDR_W-1:2]),
      .iob_wdata_i (i_iob_wdata_i),
      .iob_wstrb_i (i_iob_wstrb_i),
      .iob_rdata_o (i_iob_rdata_o),
      .iob_rvalid_o(i_iob_rvalid_o),
      .iob_ready_o (i_iob_ready_o),
      //Control IO
      .invalidate_i(1'b0),
      .invalidate_o(),
      .wtb_empty_i (1'b1),
      .wtb_empty_o (),
      // Back-end interface
      .be_valid_o  (icache_be_iob_valid),
      .be_addr_o   (icache_be_iob_addr),
      .be_wdata_o  (icache_be_iob_wdata),
      .be_wstrb_o  (icache_be_iob_wstrb),
      .be_rdata_i  (icache_be_iob_rdata),
      .be_rvalid_i (icache_be_iob_rvalid),
      .be_ready_i  (icache_be_iob_ready)
  );

  //mem control signals
  wire l2_wtb_empty;
  wire invalidate;
  reg  invalidate_reg;
  //Necessary logic to avoid invalidating L2 while it's being accessed by a request
  always @(posedge clk_i, posedge arst_i)
    if (arst_i) invalidate_reg <= 1'b0;
    else if (invalidate) invalidate_reg <= 1'b1;
    else if (~l2cache_iob_valid) invalidate_reg <= 1'b0;
    else invalidate_reg <= invalidate_reg;

  //
  // DATA CACHE
  //

  // IOb ready and rvalid signals

  // Data cache instance
  iob_cache_iob #(
      .FE_ADDR_W    ({MEM_ADDR_W}),
      .BE_ADDR_W    ({MEM_ADDR_W}),
      .NWAYS_W      (1),           //Number of ways
      .NLINES_W     (7),           //Cache Line Offset (number of lines)
      .WORD_OFFSET_W(3),           //Word Offset (number of words per line)
      .WTBUF_DEPTH_W(5),           //FIFO's depth -- 5 minimum for BRAM implementation
      .USE_CTRL     (1),           //Either 1 to enable cache-control or 0 to disable
      .USE_CTRL_CNT (0)            //do not change (it's implementation depends on the previous)
  ) dcache (
      .clk_i (clk_i),
      .cke_i (cke_i),
      .arst_i(arst_i),

      // Front-end interface
      .iob_valid_i (d_iob_valid_i),
      .iob_addr_i  (d_iob_addr_i[1+{MEM_ADDR_W}-1:2]),
      .iob_wdata_i (d_iob_wdata_i),
      .iob_wstrb_i (d_iob_wstrb_i),
      .iob_rdata_o (d_iob_rdata_o),
      .iob_rvalid_o(d_iob_rvalid_o),
      .iob_ready_o (d_iob_ready_o),
      //Control IO
      .invalidate_i(1'b0),
      .invalidate_o(invalidate),
      .wtb_empty_i (l2_wtb_empty),
      .wtb_empty_o (),
      // Back-end interface
      .be_valid_o  (dcache_be_iob_valid),
      .be_addr_o   (dcache_be_iob_addr),
      .be_wdata_o  (dcache_be_iob_wdata),
      .be_wstrb_o  (dcache_be_iob_wstrb),
      .be_rdata_i  (dcache_be_iob_rdata),
      .be_rvalid_i (dcache_be_iob_rvalid),
      .be_ready_i  (dcache_be_iob_ready)
  );

  // L2 cache instance
  iob_cache_axi #(
      .AXI_ID_W     (AXI_ID_W),
      .AXI_LEN_W    (AXI_LEN_W),
      .FE_ADDR_W    ({MEM_ADDR_W}),
      .BE_ADDR_W    (DDR_ADDR_W),
      .BE_DATA_W    (DDR_DATA_W),
      .NWAYS_W      (2),           //Number of Ways
      .NLINES_W     (7),           //Cache Line Offset (number of lines)
      .WORD_OFFSET_W(3),           //Word Offset (number of words per line)
      .WTBUF_DEPTH_W(5),           //FIFO's depth -- 5 minimum for BRAM implementation
      .USE_CTRL     (0),           //Cache-Control can't be accessed
      .USE_CTRL_CNT (0)            //Remove counters
  ) l2cache (
      // Native interface
      .iob_valid_i (l2cache_iob_valid),
      .iob_addr_i  (l2cache_iob_addr[{MEM_ADDR_W}-1:2]),
      .iob_wdata_i (l2cache_iob_wdata),
      .iob_wstrb_i (l2cache_iob_wstrb),
      .iob_rdata_o (l2cache_iob_rdata),
      .iob_rvalid_o(l2cache_iob_rvalid),
      .iob_ready_o (l2cache_iob_ready),
      //Control IO
      .invalidate_i(invalidate_reg & ~l2cache_iob_valid),
      .invalidate_o(),
      .wtb_empty_i (1'b1),
      .wtb_empty_o (l2_wtb_empty),
      // AXI interface
      `include "iob_system_cache_system_axi_m_m_portmap.vs"
      .clk_i       (clk_i),
      .cke_i       (cke_i),
      .arst_i      (arst_i)
  );
""",
        },
    ]

    return attributes_dict
