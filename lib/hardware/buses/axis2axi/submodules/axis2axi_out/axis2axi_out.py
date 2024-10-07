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
                "name": "config_out",
                "descr": "AXI Stream output configuration interface",
                "signals": [
                    {
                        "name": "config_out_addr",
                        "direction": "input",
                        "width": "AXI_ADDR_W",
                        "descr": "",
                    },
                    {
                        "name": "config_out_length",
                        "direction": "input",
                        "width": "AXI_ADDR_W",
                        "descr": "",
                    },
                    {
                        "name": "config_out_valid",
                        "direction": "input",
                        "width": 1,
                        "descr": "",
                    },
                    {
                        "name": "config_out_ready",
                        "direction": "output",
                        "width": 1,
                        "descr": "",
                    },
                ],
            },
            {
                "name": "axis_out",
                "descr": "AXI Stream output interface",
                "signals": [
                    {
                        "name": "axis_out_data",
                        "direction": "output",
                        "width": "AXI_DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "axis_out_valid",
                        "direction": "output",
                        "width": 1,
                        "descr": "",
                    },
                    {
                        "name": "axis_out_ready",
                        "direction": "input",
                        "width": 1,
                        "descr": "",
                    },
                ],
            },
            {
                "name": "axi_read_m",
                "interface": {
                    "type": "axi_read",
                    "subtype": "master",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                },
                "descr": "AXI read interface",
            },
        ],
        "blocks": [],
    }

    return attributes_dict
