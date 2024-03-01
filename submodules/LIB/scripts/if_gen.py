#!/usr/bin/env -S python3 -B

# Generates IOb Native, Clock and Reset, External Memory, AXI4 Full and AXI4
# Lite ports, port maps and signals
#
#   See "Usage" below
#

import argparse
import re
from typing import List, Dict

table: List[Dict] = []

interfaces = [
    "iob_m_port",
    "iob_s_port",
    "iob_portmap",
    "iob_m_portmap",
    "iob_s_portmap",
    "iob_m_m_portmap",
    "iob_s_s_portmap",
    "iob_wire",
    "iob_m_tb_wire",
    "iob_s_tb_wire",
    "clk_en_rst_m_port",
    "clk_en_rst_s_port",
    "clk_en_rst_m_portmap",
    "clk_en_rst_s_portmap",
    "clk_en_rst_m_m_portmap",
    "clk_en_rst_s_s_portmap",
    "clk_en_rst_wire",
    "clk_en_rst_m_tb_wire",
    "clk_en_rst_s_tb_wire",
    "clk_rst_m_port",
    "clk_rst_s_port",
    "clk_rst_m_portmap",
    "clk_rst_s_portmap",
    "clk_rst_m_m_portmap",
    "clk_rst_s_s_portmap",
    "clk_rst_wire",
    "clk_rst_m_tb_wire",
    "clk_rst_s_tb_wire",
    #    "rom_sp_port",
    "rom_sp_m_port",
    "rom_sp_s_port",
    "rom_sp_m_portmap",
    "rom_sp_s_portmap",
    "rom_sp_m_m_portmap",
    "rom_sp_s_s_portmap",
    "rom_sp_wire",
    "rom_sp_m_tb_wire",
    "rom_sp_s_tb_wire",
    #    "rom_dp_port",
    "rom_dp_m_port",
    "rom_dp_s_port",
    "rom_dp_m_portmap",
    "rom_dp_s_portmap",
    "rom_dp_m_m_portmap",
    "rom_dp_s_s_portmap",
    "rom_dp_wire",
    "rom_dp_m_tb_wire",
    "rom_dp_s_tb_wire",
    #    "rom_tdp_port",
    "rom_tdp_m_port",
    "rom_tdp_s_port",
    "rom_tdp_m_portmap",
    "rom_tdp_s_portmap",
    "rom_tdp_m_m_portmap",
    "rom_tdp_s_s_portmap",
    "rom_tdp_wire",
    "rom_tdp_m_tb_wire",
    "rom_tdp_s_tb_wire",
    #    "ram_sp_be_port",
    "ram_sp_be_m_port",
    "ram_sp_be_s_port",
    "ram_sp_be_m_portmap",
    "ram_sp_be_s_portmap",
    "ram_sp_be_m_m_portmap",
    "ram_sp_be_s_s_portmap",
    "ram_sp_be_wire",
    "ram_sp_be_m_tb_wire",
    "ram_sp_be_s_tb_wire",
    #    "ram_2p_port",
    "ram_2p_m_port",
    "ram_2p_s_port",
    "ram_2p_m_portmap",
    "ram_2p_s_portmap",
    "ram_2p_m_m_portmap",
    "ram_2p_s_s_portmap",
    "ram_2p_wire",
    "ram_2p_m_tb_wire",
    "ram_2p_s_tb_wire",
    #    "ram_2p_be_port",
    "ram_2p_be_m_port",
    "ram_2p_be_s_port",
    "ram_2p_be_m_portmap",
    "ram_2p_be_s_portmap",
    "ram_2p_be_m_m_portmap",
    "ram_2p_be_s_s_portmap",
    "ram_2p_be_wire",
    "ram_2p_be_m_tb_wire",
    "ram_2p_be_s_tb_wire",
    #    "ram_2p_tiled_port",
    "ram_2p_tiled_m_port",
    "ram_2p_tiled_s_port",
    "ram_2p_tiled_m_portmap",
    "ram_2p_tiled_s_portmap",
    "ram_2p_tiled_m_m_portmap",
    "ram_2p_tiled_s_s_portmap",
    "ram_2p_tiled_wire",
    "ram_2p_tiled_m_tb_wire",
    "ram_2p_tiled_s_tb_wire",
    #    "ram_t2p_port",
    "ram_t2p_m_port",
    "ram_t2p_s_port",
    "ram_t2p_m_portmap",
    "ram_t2p_s_portmap",
    "ram_t2p_m_m_portmap",
    "ram_t2p_s_s_portmap",
    "ram_t2p_wire",
    "ram_t2p_m_tb_wire",
    "ram_t2p_s_tb_wire",
    #    "ram_dp_port",
    "ram_dp_m_port",
    "ram_dp_s_port",
    "ram_dp_m_portmap",
    "ram_dp_s_portmap",
    "ram_dp_m_m_portmap",
    "ram_dp_s_s_portmap",
    "ram_dp_wire",
    "ram_dp_m_tb_wire",
    "ram_dp_s_tb_wire",
    #    "ram_dp_be_port",
    "ram_dp_be_m_port",
    "ram_dp_be_s_port",
    "ram_dp_be_m_portmap",
    "ram_dp_be_s_portmap",
    "ram_dp_be_m_m_portmap",
    "ram_dp_be_s_s_portmap",
    "ram_dp_be_wire",
    "ram_dp_be_m_tb_wire",
    "ram_dp_be_s_tb_wire",
    #    "ram_dp_be_xil_port",
    "ram_dp_be_xil_m_port",
    "ram_dp_be_xil_s_port",
    "ram_dp_be_xil_m_portmap",
    "ram_dp_be_xil_s_portmap",
    "ram_dp_be_xil_m_m_portmap",
    "ram_dp_be_xil_s_s_portmap",
    "ram_dp_be_xil_wire",
    "ram_dp_be_xil_m_tb_wire",
    "ram_dp_be_xil_s_tb_wire",
    #    "ram_tdp_port",
    "ram_tdp_m_port",
    "ram_tdp_s_port",
    "ram_tdp_m_portmap",
    "ram_tdp_s_portmap",
    "ram_tdp_m_m_portmap",
    "ram_tdp_s_s_portmap",
    "ram_tdp_wire",
    "ram_tdp_m_tb_wire",
    "ram_tdp_s_tb_wire",
    #    "ram_tdp_be_port",
    "ram_tdp_be_m_port",
    "ram_tdp_be_s_port",
    "ram_tdp_be_m_portmap",
    "ram_tdp_be_s_portmap",
    "ram_tdp_be_m_m_portmap",
    "ram_tdp_be_s_s_portmap",
    "ram_tdp_be_wire",
    "ram_tdp_be_m_tb_wire",
    "ram_tdp_be_s_tb_wire",
    # "ram_tdp_be_xil_port",
    "axi_m_port",
    "axi_s_port",
    "axi_m_write_port",
    "axi_s_write_port",
    "axi_m_read_port",
    "axi_s_read_port",
    "axi_portmap",
    "axi_m_portmap",
    "axi_s_portmap",
    "axi_m_m_portmap",
    "axi_s_s_portmap",
    "axi_m_write_portmap",
    "axi_s_write_portmap",
    "axi_m_m_write_portmap",
    "axi_s_s_write_portmap",
    "axi_m_read_portmap",
    "axi_s_read_portmap",
    "axi_m_m_read_portmap",
    "axi_s_s_read_portmap",
    "axi_wire",
    "axi_m_tb_wire",
    "axi_s_tb_wire",
    "axil_m_port",
    "axil_s_port",
    "axil_m_write_port",
    "axil_s_write_port",
    "axil_m_read_port",
    "axil_s_read_port",
    "axil_portmap",
    "axil_m_portmap",
    "axil_s_portmap",
    "axil_m_m_portmap",
    "axil_s_s_portmap",
    "axil_m_write_portmap",
    "axil_s_write_portmap",
    "axil_m_m_write_portmap",
    "axil_s_s_write_portmap",
    "axil_m_read_portmap",
    "axil_s_read_portmap",
    "axil_m_m_read_portmap",
    "axil_s_s_read_portmap",
    "axil_wire",
    "axil_m_tb_wire",
    "axil_s_tb_wire",
    "ahb_m_port",
    "ahb_s_port",
    "ahb_portmap",
    "ahb_m_portmap",
    "ahb_s_portmap",
    "ahb_m_m_portmap",
    "ahb_s_s_portmap",
    "ahb_wire",
    "ahb_m_tb_wire",
    "ahb_s_tb_wire",
    "apb_m_port",
    "apb_s_port",
    "apb_portmap",
    "apb_m_portmap",
    "apb_s_portmap",
    "apb_m_m_portmap",
    "apb_s_s_portmap",
    "apb_wire",
    "apb_m_tb_wire",
    "apb_s_tb_wire",
]

#
# IOb Native Bus Signals
#

iob = [
    {
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "iob_valid",
        "default": "0",
        "description": "Request valid.",
    },
    {
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "ADDR_W",
        "name": "iob_addr",
        "default": "0",
        "description": "Address.",
    },
    {
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "DATA_W",
        "name": "iob_wdata",
        "default": "0",
        "description": "Write data.",
    },
    {
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "(DATA_W/8)",
        "name": "iob_wstrb",
        "default": "0",
        "description": "Write strobe.",
    },
    {
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "iob_rvalid",
        "default": "0",
        "description": "Read data valid.",
    },
    {
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "DATA_W",
        "name": "iob_rdata",
        "default": "0",
        "description": "Read data.",
    },
    {
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "iob_ready",
        "default": "0",
        "description": "Interface ready.",
    },
]

clk_rst = [
    {
        "master": 1,
        "slave": 1,
        "enable": 0,
        "signal": "output",
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock signal",
    },
    {
        "master": 1,
        "slave": 1,
        "enable": 0,
        "signal": "output",
        "width": "1",
        "name": "arst",
        "default": "0",
        "description": "asynchronous reset",
    },
]

clk_en_rst = [
    {
        "master": 1,
        "slave": 1,
        "enable": 0,
        "signal": "output",
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock signal",
    },
    {
        "master": 1,
        "slave": 1,
        "enable": 1,
        "signal": "output",
        "width": "1",
        "name": "cke",
        "default": "0",
        "description": "clock enable",
    },
    {
        "master": 1,
        "slave": 1,
        "enable": 0,
        "signal": "output",
        "width": "1",
        "name": "arst",
        "default": "0",
        "description": "asynchronous reset",
    },
]

rom = [
    {
        "sp": 1,
        "tdp": 0,
        "dp": 1,
        "signal": "input",
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock",
    },
    {
        "sp": 1,
        "tdp": 0,
        "dp": 0,
        "signal": "input",
        "width": "1",
        "name": "r_en",
        "default": "0",
        "description": "read enable",
    },
    {
        "sp": 1,
        "tdp": 0,
        "dp": 0,
        "signal": "input",
        "width": "ADDR_W",
        "name": "addr",
        "default": "0",
        "description": "address",
    },
    {
        "sp": 1,
        "tdp": 0,
        "dp": 0,
        "signal": "output",
        "width": "DATA_W",
        "name": "r_data",
        "default": "0",
        "description": "read data",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 0,
        "signal": "input",
        "width": "1",
        "name": "clk_a",
        "default": "0",
        "description": "clock port A",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 0,
        "signal": "input",
        "width": "1",
        "name": "clk_b",
        "default": "0",
        "description": "clock port B",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "signal": "input",
        "width": "1",
        "name": "r_en_a",
        "default": "0",
        "description": "read enable port A",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "signal": "input",
        "width": "ADDR_W",
        "name": "addr_a",
        "default": "0",
        "description": "address port A",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "signal": "output",
        "width": "DATA_W",
        "name": "r_data_a",
        "default": "0",
        "description": "read data port A",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "signal": "input",
        "width": "1",
        "name": "r_en_b",
        "default": "0",
        "description": "read enable port B",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "signal": "input",
        "width": "ADDR_W",
        "name": "addr_b",
        "default": "0",
        "description": "address port B",
    },
    {
        "sp": 0,
        "tdp": 1,
        "dp": 1,
        "signal": "output",
        "width": "DATA_W",
        "name": "r_data_b",
        "default": "0",
        "description": "read data port B",
    },
]

ram_sp = [
    {
        "be": 1,
        "sp": 1,
        "signal": "input",
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock",
    },
    {
        "be": 1,
        "sp": 1,
        "signal": "input",
        "width": "DATA_W",
        "name": "d",
        "default": "0",
        "description": "ram sp data input",
    },
    {
        "be": 1,
        "sp": 1,
        "signal": "input",
        "width": "ADDR_W",
        "name": "addr",
        "default": "0",
        "description": "ram sp address",
    },
    {
        "be": 1,
        "sp": 1,
        "signal": "input",
        "width": "1",
        "name": "en",
        "default": "0",
        "description": "ram sp enable",
    },
    {
        "be": 1,
        "sp": 1,
        "signal": "output",
        "width": "DATA_W",
        "name": "d",
        "default": "0",
        "description": "ram sp data output",
    },
    {
        "be": 0,
        "sp": 1,
        "signal": "input",
        "width": "1",
        "name": "we",
        "default": "0",
        "description": "ram sp write enable",
    },
    {
        "be": 1,
        "sp": 0,
        "signal": "input",
        "width": "DATA_W/8",
        "name": "we",
        "default": "0",
        "description": "ram sp write strobe",
    },
]

ram_2p = [
    {
        "2p": 1,
        "be": 1,
        "tiled": 1,
        "t2p": 0,
        "signal": "input",
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock",
    },
    {
        "2p": 0,
        "be": 0,
        "tiled": 0,
        "t2p": 1,
        "signal": "input",
        "width": "1",
        "name": "w_clk",
        "default": "0",
        "description": "write clock",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 1,
        "t2p": 1,
        "signal": "input",
        "width": "DATA_W",
        "name": "w_data",
        "default": "0",
        "description": "ram 2p write data",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 0,
        "t2p": 1,
        "signal": "input",
        "width": "ADDR_W",
        "name": "w_addr",
        "default": "0",
        "description": "ram 2p write address",
    },
    {
        "2p": 0,
        "be": 0,
        "tiled": 1,
        "t2p": 0,
        "signal": "input",
        "width": "ADDR_W",
        "name": "addr",
        "default": "0",
        "description": "ram 2p address",
    },
    {
        "2p": 1,
        "be": 0,
        "tiled": 1,
        "t2p": 1,
        "signal": "input",
        "width": "1",
        "name": "w_en",
        "default": "0",
        "description": "ram 2p write enable",
    },
    {
        "2p": 0,
        "be": 1,
        "tiled": 0,
        "t2p": 0,
        "signal": "input",
        "width": "DATA_W/8",
        "name": "w_en",
        "default": "0",
        "description": "ram 2p write strobe",
    },
    {
        "2p": 0,
        "be": 0,
        "tiled": 0,
        "t2p": 1,
        "signal": "input",
        "width": "1",
        "name": "r_clk",
        "default": "0",
        "description": "read clock",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 0,
        "t2p": 1,
        "signal": "input",
        "width": "ADDR_W",
        "name": "r_addr",
        "default": "0",
        "description": "ram 2p read address",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 1,
        "t2p": 1,
        "signal": "input",
        "width": "1",
        "name": "r_en",
        "default": "0",
        "description": "ram 2p read enable",
    },
    {
        "2p": 1,
        "be": 1,
        "tiled": 1,
        "t2p": 1,
        "signal": "output",
        "width": "DATA_W",
        "name": "r_data",
        "default": "0",
        "description": "ram 2p read data",
    },
]


ram_dp = [
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 0,
        "tdp_be": 0,
        "signal": "input",
        "width": "1",
        "name": "clk",
        "default": "0",
        "description": "clock",
    },
    {
        "dp": 0,
        "dp_be": 0,
        "dp_be_xil": 0,
        "tdp": 1,
        "tdp_be": 1,
        "signal": "input",
        "width": "1",
        "name": "clkA",
        "default": "0",
        "description": "clock A",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "signal": "input",
        "width": "DATA_W",
        "name": "dA",
        "default": "0",
        "description": "Data in A",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "signal": "input",
        "width": "ADDR_W",
        "name": "addrA",
        "default": "0",
        "description": "Address A",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "signal": "input",
        "width": "1",
        "name": "enA",
        "default": "0",
        "description": "Enable A",
    },
    {
        "dp": 1,
        "dp_be": 0,
        "dp_be_xil": 0,
        "tdp": 1,
        "tdp_be": 0,
        "signal": "input",
        "width": "1",
        "name": "weA",
        "default": "0",
        "description": "Write enable A",
    },
    {
        "dp": 0,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 0,
        "tdp_be": 1,
        "signal": "input",
        "width": "DATA_W/8",
        "name": "weA",
        "default": "0",
        "description": "Write strobe A",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "signal": "output",
        "width": "DATA_W",
        "name": "dA",
        "default": "0",
        "description": "Data out A",
    },
    {
        "dp": 0,
        "dp_be": 0,
        "dp_be_xil": 0,
        "tdp": 1,
        "tdp_be": 1,
        "signal": "input",
        "width": "1",
        "name": "clkB",
        "default": "0",
        "description": "clock B",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "signal": "input",
        "width": "DATA_W",
        "name": "dB",
        "default": "0",
        "description": "Data in B",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "signal": "input",
        "width": "ADDR_W",
        "name": "addrB",
        "default": "0",
        "description": "Address B",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "signal": "input",
        "width": "1",
        "name": "enB",
        "default": "0",
        "description": "Enable B",
    },
    {
        "dp": 1,
        "dp_be": 0,
        "dp_be_xil": 0,
        "tdp": 1,
        "tdp_be": 0,
        "signal": "input",
        "width": "1",
        "name": "weB",
        "default": "0",
        "description": "Write enable B",
    },
    {
        "dp": 0,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 0,
        "tdp_be": 1,
        "signal": "input",
        "width": "DATA_W/8",
        "name": "weB",
        "default": "0",
        "description": "Write strobe B",
    },
    {
        "dp": 1,
        "dp_be": 1,
        "dp_be_xil": 1,
        "tdp": 1,
        "tdp_be": 1,
        "signal": "output",
        "width": "DATA_W",
        "name": "dB",
        "default": "0",
        "description": "Data out B",
    },
]

#
# AXI4 Bus Signals
#

# bus constants
AXI_SIZE_W = "3"
AXI_BURST_W = "2"
AXI_LOCK_W = "2"
AXI_CACHE_W = "4"
AXI_PROT_W = "3"
AXI_QOS_W = "4"
AXI_RESP_W = "2"

axi_write = [
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AXI_ID_W",
        "name": "axi_awid",
        "default": "0",
        "description": "Address write channel ID.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AXI_ADDR_W",
        "name": "axi_awaddr",
        "default": "0",
        "description": "Address write channel address.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AXI_LEN_W",
        "name": "axi_awlen",
        "default": "0",
        "description": "Address write channel burst length.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_SIZE_W,
        "name": "axi_awsize",
        "default": "2",
        "description": "Address write channel burst size. This signal indicates the size of each transfer in the burst.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_BURST_W,
        "name": "axi_awburst",
        "default": "1",
        "description": "Address write channel burst type.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_LOCK_W,
        "name": "axi_awlock",
        "default": "0",
        "description": "Address write channel lock type.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_CACHE_W,
        "name": "axi_awcache",
        "default": "2",
        "description": "Address write channel memory type. Set to 0000 if master output; ignored if slave input.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_PROT_W,
        "name": "axi_awprot",
        "default": "2",
        "description": "Address write channel protection type. Set to 000 if master output; ignored if slave input.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_QOS_W,
        "name": "axi_awqos",
        "default": "0",
        "description": "Address write channel quality of service.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "axi_awvalid",
        "default": "0",
        "description": "Address write channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "axi_awready",
        "default": "1",
        "description": "Address write channel ready.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AXI_DATA_W",
        "name": "axi_wdata",
        "default": "0",
        "description": "Write channel data.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "(AXI_DATA_W/8)",
        "name": "axi_wstrb",
        "default": "0",
        "description": "Write channel write strobe.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "axi_wlast",
        "default": "0",
        "description": "Write channel last word flag.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "axi_wvalid",
        "default": "0",
        "description": "Write channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "axi_wready",
        "default": "1",
        "description": "Write channel ready.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "AXI_ID_W",
        "name": "axi_bid",
        "default": "0",
        "description": "Write response channel ID.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": AXI_RESP_W,
        "name": "axi_bresp",
        "default": "0",
        "description": "Write response channel response.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "axi_bvalid",
        "default": "0",
        "description": "Write response channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "axi_bready",
        "default": "1",
        "description": "Write response channel ready.",
    },
]

axi_read = [
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AXI_ID_W",
        "name": "axi_arid",
        "default": "0",
        "description": "Address read channel ID.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AXI_ADDR_W",
        "name": "axi_araddr",
        "default": "0",
        "description": "Address read channel address.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AXI_LEN_W",
        "name": "axi_arlen",
        "default": "0",
        "description": "Address read channel burst length.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_SIZE_W,
        "name": "axi_arsize",
        "default": "2",
        "description": "Address read channel burst size. This signal indicates the size of each transfer in the burst.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_BURST_W,
        "name": "axi_arburst",
        "default": "1",
        "description": "Address read channel burst type.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_LOCK_W,
        "name": "axi_arlock",
        "default": "0",
        "description": "Address read channel lock type.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_CACHE_W,
        "name": "axi_arcache",
        "default": "2",
        "description": "Address read channel memory type. Set to 0000 if master output; ignored if slave input.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_PROT_W,
        "name": "axi_arprot",
        "default": "2",
        "description": "Address read channel protection type. Set to 000 if master output; ignored if slave input.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AXI_QOS_W,
        "name": "axi_arqos",
        "default": "0",
        "description": "Address read channel quality of service.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "axi_arvalid",
        "default": "0",
        "description": "Address read channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "axi_arready",
        "default": "1",
        "description": "Address read channel ready.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "AXI_ID_W",
        "name": "axi_rid",
        "default": "0",
        "description": "Read channel ID.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "AXI_DATA_W",
        "name": "axi_rdata",
        "default": "0",
        "description": "Read channel data.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": AXI_RESP_W,
        "name": "axi_rresp",
        "default": "0",
        "description": "Read channel response.",
    },
    {
        "lite": 0,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "axi_rlast",
        "default": "0",
        "description": "Read channel last word.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "axi_rvalid",
        "default": "0",
        "description": "Read channel valid.",
    },
    {
        "lite": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "axi_rready",
        "default": "1",
        "description": "Read channel ready.",
    },
]

#
# AMBA Bus Signals
#

# bus constants
AHB_BURST_W = "3"
AHB_PROT_W = "4"
AHB_SIZE_W = "3"
AHB_TRANS_W = "2"

amba = [
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AHB_ADDR_W",
        "name": "ahb_addr",
        "default": "0",
        "description": "Byte address of the transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AHB_BURST_W,
        "name": "ahb_burst",
        "default": "0",
        "description": "Burst type.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "ahb_mastlock",
        "default": "0",
        "description": "Transfer is part of a lock sequence.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AHB_PROT_W,
        "name": "ahb_prot",
        "default": "1",
        "description": "Protection type. Set to 0000 if master output; ignored if slave input.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AHB_SIZE_W,
        "name": "ahb_size",
        "default": "2",
        "description": "Burst size. Indicates the size of each transfer in the burst.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "ahb_nonsec",
        "default": "0",
        "description": "Non-secure transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "ahb_excl",
        "default": "0",
        "description": "Exclusive transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AHB_MASTER_W",
        "name": "ahb_master",
        "default": "0",
        "description": "Master ID.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": AHB_TRANS_W,
        "name": "ahb_trans",
        "default": "0",
        "description": "Transfer type. Indicates the type of the transfer.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "ahb_sel",
        "default": "0",
        "description": "Slave select.",
    },
    {
        "ahb": 0,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "ahb_enable",
        "default": "0",
        "description": "Enable. Indicates the number of clock cycles of the transfer.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "ahb_write",
        "default": "0",
        "description": "Write. Indicates the direction of the operation.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "AHB_DATA_W",
        "name": "ahb_wdata",
        "default": "0",
        "description": "Write data.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "signal": "output",
        "width": "(AHB_DATA_W/8)",
        "name": "ahb_wstrb",
        "default": "0",
        "description": "Write strobe.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "AHB_DATA_W",
        "name": "ahb_rdata",
        "default": "0",
        "description": "Read data.",
    },
    {
        "ahb": 1,
        "apb": 1,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "ahb_ready",
        "default": "0",
        "description": "Ready. Indicates the end of a transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 0,
        "slave": 1,
        "signal": "output",
        "width": "1",
        "name": "ahb_ready",
        "default": "0",
        "description": "Ready input. Indicates the end of the last transfer.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "ahb_resp",
        "default": "0",
        "description": "Transfer response.",
    },
    {
        "ahb": 1,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "ahb_exokay",
        "default": "1",
        "description": "Exclusive transfer response.",
    },
    {
        "ahb": 0,
        "apb": 0,
        "master": 1,
        "slave": 1,
        "signal": "input",
        "width": "1",
        "name": "ahb_slverr",
        "default": "0",
        "description": "Slave error. Indicates if the transfer has falied.",
    },
]

top_macro = ""

#
# IOb Native
#


def make_iob():
    bus = []
    for i in range(len(iob)):
        bus.append(iob[i])
    return bus


#
# Clk En Rst
#


def make_clk_en_rst():
    bus = []
    for i in range(len(clk_en_rst)):
        bus.append(clk_en_rst[i])
    return bus


def make_clk_rst():
    bus = []
    for i in range(len(clk_rst)):
        bus.append(clk_rst[i])
    return bus


#
# ROM
#
def make_rom():
    bus = []
    for i in range(len(rom)):
        bus.append(rom[i])
    return bus


#
# RAM SP
#
def make_ram_sp():
    bus = []
    for i in range(len(ram_sp)):
        bus.append(ram_sp[i])
    return bus


#
# RAM 2P
#
def make_ram_2p():
    bus = []
    for i in range(len(ram_2p)):
        bus.append(ram_2p[i])
    return bus


#
# RAM DP
#
def make_ram_dp():
    bus = []
    for i in range(len(ram_dp)):
        bus.append(ram_dp[i])
    return bus


#
# AXI4 Full
#


def make_axi_write():
    bus = []
    for i in range(len(axi_write)):
        bus.append(axi_write[i])
    return bus


def make_axi_read():
    bus = []
    for i in range(len(axi_read)):
        bus.append(axi_read[i])
    return bus


def make_axi():
    return make_axi_write() + make_axi_read()


#
# AXI4 Lite
#


def make_axil_write():
    bus = []
    for signal in axi_write:
        if signal["lite"] == 1:
            bus.append(signal.copy())
            bus[-1]["name"] = bus[-1]["name"].replace("axi_", "axil_")
            bus[-1]["width"] = bus[-1]["width"].replace("AXI_", "AXIL_")
    return bus


def make_axil_read():
    bus = []
    for signal in axi_read:
        if signal["lite"] == 1:
            bus.append(signal.copy())
            bus[-1]["name"] = bus[-1]["name"].replace("axi_", "axil_")
            bus[-1]["width"] = bus[-1]["width"].replace("AXI_", "AXIL_")
    return bus


def make_axil():
    return make_axil_write() + make_axil_read()


#
# AHB
#


def make_ahb():
    bus = []
    for i in range(len(amba)):
        if amba[i]["ahb"] == 1:
            bus.append(amba[i])
    return bus


#
# APB
#


def make_apb():
    bus = []
    for i in range(len(amba)):
        if amba[i]["apb"] == 1:
            bus.append(amba[i])
            bus[-1]["name"] = bus[-1]["name"].replace("ahb_", "apb_")
            bus[-1]["width"] = bus[-1]["width"].replace("AHB_", "APB_")
    return bus


#
# Auxiliary Functions
#


def reverse(direction):
    if direction == "input":
        return "output"
    elif direction == "output":
        return "input"
    else:
        print("ERROR: reverse_direction : invalid argument")
        quit()


def tbsignal(direction):
    if direction == "input":
        return "wire"
    elif direction == "output":
        return "reg"
    else:
        print("ERROR: tb_reciprocal : invalid argument")
        quit()


def suffix(direction):
    if direction == "input" or direction == "reg":
        return "_i"
    elif direction == "output" or direction == "wire":
        return "_o"
    else:
        print("ERROR: get_signal_suffix : invalid argument")
        quit()


# Add a given prefix (in upppercase) to every parameter/macro found in the string
def add_param_prefix(string, param_prefix):
    return re.sub(r"([a-zA-Z_][\w_]*)", param_prefix.upper() + r"\g<1>", string)


#
# Port
#


# Write port with given direction, bus width, name and description to file
def write_port(direction, width, name, fout):
    if direction == "I":
        direction = "input"
    elif direction == "O":
        direction = "output"

    fout.write(f"{direction} [{width}-1:0] {name}," + "\n")


def m_port(prefix, param_prefix, bus_size=1):
    """
    Create a list of ports for the master interface
    @param prefix: prefix to add to the port name
    @param param_prefix: prefix to add to the port width
    @param bus_size: bus size
    @return: list of interface ports
    """

    port_list = []
    for port in range(len(table)):
        if table[port]["master"] == 1:
            signal = table[port]["signal"]
            if signal == "input":
                direction = "I"
            elif signal == "output":
                direction = "O"

            name = prefix + table[port]["name"] + suffix(table[port]["signal"])
            if bus_size == 1:
                width = table[port]["width"]
            else:
                width = "(" + str(bus_size) + "*" + table[port]["width"] + ")"
            width = add_param_prefix(width, param_prefix)
            description = top_macro + table[port]["description"]

            # Create port
            port = {
                "name": name,
                "type": direction,
                "n_bits": width,
                "descr": description,
            }
            # Add to port list
            port_list.append(port)

    return port_list


def s_port(prefix, param_prefix, bus_size=1):
    """
    Create a list of ports for the master interface
    @param prefix: prefix to add to the port name
    @param param_prefix: prefix to add to the port width
    @param bus_size: bus size
    @return: list of interface ports
    """

    port_list = []
    for port in range(len(table)):
        if table[port]["slave"] == 1:
            signal = reverse(table[port]["signal"])
            if signal == "input":
                direction = "I"
            elif signal == "output":
                direction = "O"

            name = prefix + table[port]["name"] + suffix(signal)
            if bus_size == 1:
                width = table[port]["width"]
            else:
                width = "(" + str(bus_size) + "*" + table[port]["width"] + ")"
            width = add_param_prefix(width, param_prefix)
            description = top_macro + table[port]["description"]

            # Create port
            port = {
                "name": name,
                "type": direction,
                "n_bits": width,
                "descr": description,
            }

            # Add to port list
            port_list.append(port)

    return port_list


#
# Portmap
#


# Write portmap with given port, connection name, width, bus start, bus size and description to file
def write_portmap(port, connection_name, width, bus_start, bus_size, description, fout):
    if bus_size == 1:
        connection = connection_name
    else:
        bus_select_size = str(bus_size) + "*" + width
        if bus_start == 0:
            bus_start_index = str(0)
        else:
            bus_start_index = str(bus_start) + "*" + width
        connection = (
            connection_name + "[" + bus_start_index + "+:" + bus_select_size + "]"
        )
    fout.write("." + port + "(" + connection + "), //" + description + "\n")


def write_plain_portmap(port, connection, width, description, fout):
    fout.write("." + port + "(" + connection + "), //" + description + "\n")


def portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        port = port_prefix + table[i]["name"]
        connection_name = wire_prefix + table[i]["name"]
        write_portmap(
            port,
            connection_name,
            table[i]["width"],
            bus_start,
            bus_size,
            table[i]["description"],
            fout,
        )


def m_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["master"] == 1:
            port = port_prefix + table[i]["name"] + suffix(table[i]["signal"])
            connection_name = wire_prefix + table[i]["name"]
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
                bus_start,
                bus_size,
                table[i]["description"],
                fout,
            )


def s_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["slave"] == 1:
            port = port_prefix + table[i]["name"] + suffix(reverse(table[i]["signal"]))
            connection_name = wire_prefix + table[i]["name"]
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
                bus_start,
                bus_size,
                table[i]["description"],
                fout,
            )


def m_m_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["master"] == 1:
            port = port_prefix + table[i]["name"] + suffix(table[i]["signal"])
            connection_name = (
                wire_prefix + table[i]["name"] + suffix(table[i]["signal"])
            )
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
                bus_start,
                bus_size,
                table[i]["description"],
                fout,
            )


def s_s_portmap(port_prefix, wire_prefix, fout, bus_start=0, bus_size=1):
    for i in range(len(table)):
        if table[i]["slave"] == 1:
            port = port_prefix + table[i]["name"] + suffix(reverse(table[i]["signal"]))
            connection_name = (
                wire_prefix + table[i]["name"] + suffix(reverse(table[i]["signal"]))
            )
            write_portmap(
                port,
                connection_name,
                table[i]["width"],
                bus_start,
                bus_size,
                table[i]["description"],
                fout,
            )


#
# Wire
#


# Write wire with given name, bus size, width and description to file
def write_wire(name, param_prefix, bus_size, width, description, fout):
    width = add_param_prefix(width, param_prefix)
    if bus_size == 1:
        bus_width = " [" + width + "-1:0] "
    else:
        bus_width = " [" + str(bus_size) + "*" + width + "-1:0] "
    fout.write("wire" + bus_width + name + "; //" + description + "\n")


# Write reg with given name, bus size, width, initial value and description to file
def write_reg(name, param_prefix, bus_size, width, default, description, fout):
    width = add_param_prefix(width, param_prefix)
    if bus_size == 1:
        bus_width = " [" + width + "-1:0] "
    else:
        bus_width = " [" + str(bus_size) + "*" + width + "-1:0] "
    fout.write("reg" + bus_width + name + " = " + default + "; //" + description + "\n")


# Write tb wire with given tb_signal, prefix, name, bus size, width and description to file
def write_tb_wire(
    tb_signal,
    prefix,
    name,
    param_prefix,
    bus_size,
    width,
    description,
    fout,
    default="0",
):
    signal_name = prefix + name + suffix(tb_signal)
    if tb_signal == "reg":
        write_reg(
            signal_name, param_prefix, bus_size, width, default, description, fout
        )
    else:
        write_wire(signal_name, param_prefix, bus_size, width, description, fout)


def wire(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        write_wire(
            prefix + table[i]["name"],
            param_prefix,
            bus_size,
            table[i]["width"],
            table[i]["description"],
            fout,
        )


def m_tb_wire(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        if table[i]["slave"] == 1:
            tb_signal = tbsignal(table[i]["signal"])
            write_tb_wire(
                tb_signal,
                prefix,
                table[i]["name"],
                param_prefix,
                bus_size,
                table[i]["width"],
                table[i]["description"],
                fout,
                table[i]["default"],
            )
    fout.write("\n")


def s_tb_wire(prefix, param_prefix, fout, bus_size=1):
    for i in range(len(table)):
        if table[i]["master"] == 1:
            tb_signal = tbsignal(reverse(table[i]["signal"]))
            write_tb_wire(
                tb_signal,
                prefix,
                table[i]["name"],
                param_prefix,
                bus_size,
                table[i]["width"],
                table[i]["description"],
                fout,
                table[i]["default"],
            )
    fout.write("\n")


#
# Parse Arguments
#
def valid_interface_type(original_interface):
    for interface in interfaces:
        if original_interface.endswith(interface):
            return interface
    return None


def parse_types(arg):
    interface = valid_interface_type(arg)
    if not interface:
        msg = f"{arg} is not a valid type"
        raise argparse.ArgumentTypeError(msg)
    else:
        return arg


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="if_gen.py verilog interface generation.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "type",
        type=lambda s: parse_types(s),
        help="""
                            type can defined as one of the following:
                            [*]clk_en_rst_m_port: iob native master port
                            [*]clk_en_rst_s_port: iob native slave port
                            [*]clk_en_rst_s_s_portmap: iob native portmap
                            [*]clk_en_rst_m_portmap: iob native master portmap
                            [*]clk_en_rst_s_portmap: iob native slave portmap
                            [*]clk_en_rst_m_m_portmap: iob native master to master portmap
                            [*]clk_en_rst_s_s_portmap: iob native slave to slave portmap
                            [*]clk_en_rst_wire: iob native wires for interconnection
                            [*]clk_en_rst_m_tb_wire: iob native master wires for testbench
                            [*]clk_en_rst_s_tb_wire: iob native slave wires for testbench

                            [*]clk_rst_m_port: iob native master port
                            [*]clk_rst_s_port: iob native slave port
                            [*]clk_rst_portmap: iob native portmap
                            [*]clk_rst_m_portmap: iob native master portmap
                            [*]clk_rst_s_portmap: iob native slave portmap
                            [*]clk_rst_m_m_portmap: iob native master to master portmap
                            [*]clk_rst_s_s_portmap: iob native slave to slave portmap
                            [*]clk_rst_wire: iob native wires for interconnection
                            [*]clk_rst_m_tb_wire: iob native master wires for testbench
                            [*]clk_rst_s_tb_wire: iob native slave wires for testbench

                            [*]iob_m_port: iob native master port
                            [*]iob_s_port: iob native slave port
                            [*]iob_portmap: iob native portmap
                            [*]iob_m_portmap: iob native master portmap
                            [*]iob_s_portmap: iob native slave portmap
                            [*]iob_m_m_portmap: iob native master to master portmap
                            [*]iob_s_s_portmap: iob native slave to slave portmap
                            [*]iob_wire: iob native wires for interconnection
                            [*]iob_m_tb_wire: iob native master wires for testbench
                            [*]iob_s_tb_wire: iob native slave wires for testbench


                            [*]rom_sp_port: external rom sp ports
                            [*]rom_dp_port: external rom dp ports
                            [*]rom_tdp_port: external rom tdp ports
                            [*]rom_sp_portmap: external rom sp portmap
                            [*]rom_dp_portmap: external rom dp portmap
                            [*]rom_tdp_portmap: external rom tdp portmap

                            [*]ram_sp_port: external ram sp ports
                            [*]ram_sp_be_port: external ram sp be ports
                            [*]ram_sp_portmap: external ram sp portmap
                            [*]ram_sp_be_portmap: external ram sp be portmap

                            [*]ram_2p_port: external ram 2p ports
                            [*]ram_2p_be_port: external ram 2p be ports
                            [*]ram_2p_portmap: external ram 2p portmap
                            [*]ram_2p_be_portmap: external ram 2p be portmap
                            [*]ram_2p_tiled_port: external ram 2p ports
                            [*]ram_t2p_port: external ram 2p be ports
                            [*]ram_2p_tiled_portmap: external ram 2p portmap
                            [*]ram_t2p_portmap: external ram 2p be portmap

                            [*]ram_dp_port: external ram dp ports
                            [*]ram_dp_portmap: external ram dp portmap
                            [*]ram_dp_be_port: external ram dp_be ports
                            [*]ram_dp_be_portmap: external ram dp_be portmap
                            [*]ram_dp_be_xil_port: external ram dp_be_xil ports
                            [*]ram_dp_be_xil_portmap: external ram dp_be_xil portmap
                            [*]ram_tdp_port: external ram tdp ports
                            [*]ram_tdp_portmap: external ram tdp portmap
                            [*]ram_tdp_be_port: external ram tdp_be ports
                            [*]ram_tdp_be_portmap: external ram tdp_be portmap

                            [*]axi_m_port: axi full master port
                            [*]axi_s_port: axi full slave port
                            [*]axi_m_write_port: axi full master write port
                            [*]axi_s_write_port: axi full slave write port
                            [*]axi_m_read_port: axi full master read port
                            [*]axi_s_read_port: axi full slave read port
                            [*]axi_portmap: axi full portmap
                            [*]axi_m_portmap: axi full master portmap
                            [*]axi_s_portmap: axi full slave portmap
                            [*]axi_m_m_portmap: axi full master to master portmap
                            [*]axi_s_s_portmap: axi full slave to slave portmap
                            [*]axi_m_write_portmap: axi full master write portmap
                            [*]axi_s_write_portmap: axi full slave write portmap
                            [*]axi_m_m_write_portmap: axi full master to master write portmap
                            [*]axi_s_s_write_portmap: axi full slave to slave write portmap
                            [*]axi_m_read_portmap: axi full master read portmap
                            [*]axi_s_read_portmap: axi full slave read portmap
                            [*]axi_m_m_read_portmap: axi full master to master read portmap
                            [*]axi_s_s_read_portmap: axi full slave to slave read portmap
                            [*]axi_wire: axi full wires for interconnection
                            [*]axi_m_tb_wire: axi full master wires for testbench
                            [*]axi_s_tb_wire: axi full slave wires for testbench

                            [*]axil_m_port: axi lite master port
                            [*]axil_s_port: axi lite slave port
                            [*]axil_m_write_port: axi lite master write port
                            [*]axil_s_write_port: axi lite slave write port
                            [*]axil_m_read_port: axi lite master read port
                            [*]axil_s_read_port: axi lite slave read port
                            [*]axil_portmap: axi lite portmap
                            [*]axil_m_portmap: axi lite master portmap
                            [*]axil_s_portmap: axi lite slave portmap
                            [*]axil_m_m_portmap: axi lite master to master portmap
                            [*]axil_s_s_portmap: axi lite slave to slave portmap
                            [*]axil_m_write_portmap: axi lite master write portmap
                            [*]axil_s_write_portmap: axi lite slave write portmap
                            [*]axil_m_m_write_portmap: axi lite master to master write portmap
                            [*]axil_s_s_write_portmap: axi lite slave to slave write portmap
                            [*]axil_m_read_portmap: axi lite master read portmap
                            [*]axil_s_read_portmap: axi lite slave read portmap
                            [*]axil_m_m_read_portmap: axi lite master to master read portmap
                            [*]axil_s_s_read_portmap: axi lite slave to slave read portmap
                            [*]axil_wire: axi lite wires for interconnection
                            [*]axil_m_tb_wire: axi lite master wires for testbench
                            [*]axil_s_tb_wire: axi lite slave wires for testbench

                            [*]ahb_m_port: ahb master port
                            [*]ahb_s_port: ahb slave port
                            [*]ahb_portmap: ahb portmap
                            [*]ahb_m_portmap: ahb master portmap
                            [*]ahb_s_portmap: ahb slave portmap
                            [*]ahb_m_m_portmap: ahb master to master portmap
                            [*]ahb_s_s_portmap: ahb slave to slave portmap
                            [*]ahb_wire: ahb wires for interconnection
                            [*]ahb_m_tb_wire: ahb master wires for testbench
                            [*]ahb_s_tb_wire: ahb slave wires for testbench

                            [*]apb_m_port: apb master port
                            [*]apb_s_port: apb slave port
                            [*]apb_portmap: apb portmap
                            [*]apb_m_portmap: apb master portmap
                            [*]apb_s_portmap: apb slave portmap
                            [*]apb_m_m_portmap: apb master to master portmap
                            [*]apb_s_s_portmap: apb slave to slave portmap
                            [*]apb_wire: apb wires for interconnection
                            [*]apb_m_tb_wire: apb master wires for testbench
                            [*]apb_s_tb_wire: apb slave wires for testbench
                        """,
    )

    parser.add_argument(
        "file_prefix", nargs="?", help="""Output file prefix.""", default=""
    )
    parser.add_argument("port_prefix", nargs="?", help="""Port prefix.""", default="")
    parser.add_argument("wire_prefix", nargs="?", help="""Wire prefix.""", default="")
    parser.add_argument("--top", help="""Top Module interface.""", action="store_true")

    return parser.parse_args()


#
# Create signal table
#
def create_signal_table(interface_name):
    global table
    table = []

    if interface_name.find("iob_") >= 0:
        table = make_iob()

    if interface_name.find("clk_en_rst_") >= 0:
        table = make_clk_en_rst()

    if interface_name.find("clk_rst_") >= 0:
        table = make_clk_rst()

    if interface_name.find("rom_") >= 0:
        table = make_rom()

    if interface_name.find("ram_sp_") >= 0:
        table = make_ram_sp()

    if interface_name.find("ram_2p_") >= 0 or interface_name.find("ram_t2p_") >= 0:
        table = make_ram_2p()

    if interface_name.find("ram_dp_") >= 0 or interface_name.find("ram_tdp_") >= 0:
        table = make_ram_dp()

    if interface_name.find("axi_") >= 0:
        if interface_name.find("write_") >= 0:
            table = make_axi_write()
        elif interface_name.find("read_") >= 0:
            table = make_axi_read()
        else:
            table = make_axi()

    if interface_name.find("axil_") >= 0:
        if interface_name.find("write_") >= 0:
            table = make_axil_write()
        elif interface_name.find("read_") >= 0:
            table = make_axil_read()
        else:
            table = make_axil()

    if interface_name.find("ahb_") >= 0:
        table = make_ahb()

    if interface_name.find("apb_") >= 0:
        table = make_apb()


def default_interface_fields(if_dict):
    # update interface dictionary fields if they are not set
    # interface: remove prefix and keep matching supported interface name
    # file_prefix: set to original interface prefix, if not set
    # wire_prefix: set to original interface prefix, if not set
    # port_prefix: set to original interface prefix, if not set
    # Example:
    #   input: if_dict = { "interface": "test_iob_m_port" }
    #   output: if_dict = {
    #             "interface": "iob_m_port",
    #             "file_prefix": "test_",
    #             "wire_prefix": "test_",
    #             "port_prefix": "test_",
    #          }

    # get supported interface name
    supported_interface = valid_interface_type(if_dict["interface"])
    prefix = if_dict["interface"].split(supported_interface)[0]

    # set prefixes if they do not exist
    if not "file_prefix" in if_dict:
        if_dict["file_prefix"] = prefix
    if not "port_prefix" in if_dict:
        if_dict["port_prefix"] = prefix
    if not "wire_prefix" in if_dict:
        if_dict["wire_prefix"] = prefix

    # set interface to supported_interface
    if_dict["interface"] = supported_interface

    return if_dict


def generate_interface(
    interface_name,
    port_prefix,
    param_prefix,
    bus_size=1,
):
    """
    Generate interface which is a list of ports
    @param interface_name: interface name
    @param port_prefix: prefix for ports
    @param wire_prefix: prefix for wires
    @param bus_size: bus size
    @param bus_start: bus start
    @return: list of ports
    """
    func_name = (
        interface_name.replace("axil_", "")
        .replace("clk_en_rst_", "")
        .replace("clk_rst_", "")
        .replace("rom_", "")
        .replace("ram_", "")
        .replace("axi_", "")
        .replace("write_", "")
        .replace("read_", "")
        .replace("iob_", "")
        .replace("apb_", "")
        .replace("ahb_", "")
    )

    param_prefix = port_prefix.upper()

    # add '_' prefix for func_names starting with digit
    # (examples: 2p_port, 2p_be_portmap, 2p_tiled_port)
    if func_name[0].isdigit():
        func_name = f"_{func_name}"

    interface = eval(func_name + "(port_prefix, param_prefix, bus_size=bus_size)")

    return interface


#
# Write to .vs file
#


def write_interface_ports(
    interface_name, port_prefix, param_prefix, bus_size=1, file_object=None
):
    """
    Write ports to file
    @param interface_name: interface name
    @param param_prefix: prefix for parameters
    @param port_prefix: prefix for ports
    @param bus_size: bus size
    @param file_object: file object
    """

    interface = generate_interface(
        interface_name, port_prefix, param_prefix, bus_size=bus_size
    )
    for port in interface:
        write_port(port["type"], port["n_bits"], port["name"], file_object)


# port_prefix: Prefix for ports in a portmap file; Prefix for ports in a `*port.vs` file; Use PORT_PREFIX (upper case) for parameters in signal width for ports or wire.
# wire_prefix: Prefix for wires in a portmap file; Prefix for wires in a `*wires.vs` file;
def write_vs_contents(
    interface_name,
    port_prefix,
    wire_prefix,
    file_object,
    bus_size=1,
    bus_start=0,
):
    func_name = (
        interface_name.replace("axil_", "")
        .replace("clk_en_rst_", "")
        .replace("clk_rst_", "")
        .replace("rom_", "")
        .replace("ram_", "")
        .replace("axi_", "")
        .replace("write_", "")
        .replace("read_", "")
        .replace("iob_", "")
        .replace("apb_", "")
        .replace("ahb_", "")
    )

    param_prefix = port_prefix.upper()

    # add '_' prefix for func_names starting with digit
    # (examples: 2p_port, 2p_be_portmap, 2p_tiled_port)
    if func_name[0].isdigit():
        func_name = f"_{func_name}"

    if interface_name.find("portmap") + 1:
        eval(
            func_name
            + "(port_prefix, wire_prefix, file_object, bus_start=bus_start, bus_size=bus_size)"
        )
    elif interface_name.find("wire") + 1:
        eval(func_name + "(wire_prefix, param_prefix, file_object, bus_size=bus_size)")
    else:
        write_interface_ports(
            interface_name,
            port_prefix,
            param_prefix,
            bus_size=bus_size,
            file_object=file_object,
        )


#
# Main
#


def main():
    args = parse_arguments()

    # bus type
    if_dict = {
        "interface": args.type,
    }
    # port and wire prefix
    if args.file_prefix:
        if_dict["file_prefix"] = args.file_prefix
    if args.port_prefix:
        if_dict["port_prefix"] = args.port_prefix
    if args.wire_prefix:
        if_dict["wire_prefix"] = args.wire_prefix

    if_dict = default_interface_fields(if_dict)

    # top flag
    top = args.top
    if top:
        top_macro = "V2TEX_IO "

    # make AXI bus
    create_signal_table(if_dict["interface"])

    # open output .vs file
    fout = open(if_dict["file_prefix"] + if_dict["interface"] + ".vs", "w")

    # write pragma for doc production
    if (
        if_dict["interface"].find("port") + 1
        and not if_dict["interface"].find("portmap") + 1
    ):
        fout.write(
            "  //START_IO_TABLE " + if_dict["port_prefix"] + if_dict["interface"] + "\n"
        )

    # call function func to generate .vs file
    write_vs_contents(
        if_dict["interface"], if_dict["port_prefix"], if_dict["wire_prefix"], fout
    )

    fout.close()


if __name__ == "__main__":
    main()
