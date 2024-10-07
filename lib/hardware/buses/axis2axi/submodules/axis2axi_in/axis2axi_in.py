# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "generate_hw": False,
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
                "name": "rst_i",
                "descr": "Synchronous reset interface",
                "signals": [
                    {
                        "name": "rst",
                        "direction": "input",
                        "width": 1,
                        "descr": "Synchronous reset input",
                    },
                ],
            },
            {
                "name": "config_in",
                "descr": "AXI Stream input configuration interface",
                "signals": [
                    {
                        "name": "config_in_addr",
                        "direction": "input",
                        "width": "AXI_ADDR_W",
                        "descr": "",
                    },
                    {
                        "name": "config_in_valid",
                        "direction": "input",
                        "width": 1,
                        "descr": "",
                    },
                    {
                        "name": "config_in_ready",
                        "direction": "output",
                        "width": 1,
                        "descr": "",
                    },
                ],
            },
            {
                "name": "axis_in",
                "descr": "AXI Stream input interface",
                "signals": [
                    {
                        "name": "axis_in_data",
                        "direction": "input",
                        "width": "AXI_DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "axis_in_valid",
                        "direction": "input",
                        "width": 1,
                        "descr": "",
                    },
                    {
                        "name": "axis_in_ready",
                        "direction": "output",
                        "width": 1,
                        "descr": "",
                    },
                ],
            },
            {
                "name": "axi_write_m",
                "interface": {
                    "type": "axi_write",
                    "subtype": "master",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                },
                "descr": "AXI write interface",
            },
            {
                "name": "extmem",
                "descr": "External memory interface",
                "signals": [
                    {
                        "name": "ext_mem_w_en",
                        "direction": "output",
                        "width": 1,
                        "descr": "Memory write enable",
                    },
                    {
                        "name": "ext_mem_w_addr",
                        "direction": "output",
                        "width": "BUFFER_W",
                        "descr": "Memory write address",
                    },
                    {
                        "name": "ext_mem_w_data",
                        "direction": "output",
                        "width": "AXI_DATA_W",
                        "descr": "Memory write data",
                    },
                    {
                        "name": "ext_mem_r_en",
                        "direction": "output",
                        "width": 1,
                        "descr": "Memory read enable",
                    },
                    {
                        "name": "ext_mem_r_addr",
                        "direction": "output",
                        "width": "BUFFER_W",
                        "descr": "Memory read address",
                    },
                    {
                        "name": "ext_mem_r_data",
                        "direction": "input",
                        "width": "AXI_DATA_W",
                        "descr": "Memory read data",
                    },
                ],
            },
        ],
        "blocks": [],
    }

    return attributes_dict
