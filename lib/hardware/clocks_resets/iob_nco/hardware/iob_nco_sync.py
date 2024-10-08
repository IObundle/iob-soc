# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "PERIOD_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "32",
                "descr": "Period width",
            },
        ],
        "ports": [
            {
                "name": "clk_rst_s",
                "interface": {
                    "type": "clk_rst",
                    "subtype": "slave",
                },
                "descr": "Clock and reset",
            },
            {
                "name": "clk_i",
                "descr": "Source clock domain",
                "signals": [
                    {
                        "name": "clk_in",
                        "direction": "input",
                        "width": "1",
                        "descr": "Source clock input",
                    },
                ],
            },
            {
                "name": "soft_reset_i",
                "descr": "System soft reset",
                "signals": [
                    {
                        "name": "soft_reset",
                        "direction": "input",
                        "width": "1",
                        "descr": "System soft reset",
                    },
                ],
            },
            {
                "name": "enable_i",
                "descr": "System enable",
                "signals": [
                    {
                        "name": "enable",
                        "direction": "input",
                        "width": "1",
                        "descr": "System enable",
                    },
                ],
            },
            {
                "name": "period_wdata_i",
                "descr": "System period data",
                "signals": [
                    {
                        "name": "period_wdata",
                        "direction": "input",
                        "width": "PERIOD_W",
                        "descr": "System period data",
                    },
                ],
            },
            {
                "name": "period_wen_i",
                "descr": "System period write enable",
                "signals": [
                    {
                        "name": "period_wen",
                        "direction": "input",
                        "width": "1",
                        "descr": "System period write enable",
                    },
                ],
            },
            {
                "name": "soft_reset_o",
                "descr": "Source clock domain soft reset",
                "signals": [
                    {
                        "name": "soft_reset",
                        "direction": "output",
                        "width": "1",
                        "descr": "Source clock domain soft reset",
                    },
                ],
            },
            {
                "name": "enable_o",
                "descr": "Source clock domain enable",
                "signals": [
                    {
                        "name": "enable",
                        "direction": "output",
                        "width": "1",
                        "descr": "Source clock domain enable",
                    },
                ],
            },
            {
                "name": "period_wdata_o",
                "descr": "Source clock domain period data",
                "signals": [
                    {
                        "name": "period_wdata",
                        "direction": "output",
                        "width": "PERIOD_W",
                        "descr": "Source clock domain period data",
                    },
                ],
            },
            {
                "name": "period_wen_o",
                "descr": "Source clock domain period write enable",
                "signals": [
                    {
                        "name": "period_wen",
                        "direction": "output",
                        "width": "1",
                        "descr": "Source clock domain period write enable",
                    },
                ],
            },
        ],
        "wires": [
            # Period wires
            {
                "name": "period_int",
                "descr": "",
                "signals": [
                    {"name": "period_int", "width": "PERIOD_W+1"},
                ],
            },
            {
                "name": "period_out",
                "descr": "",
                "signals": [
                    {"name": "period_out", "width": "PERIOD_W+1"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_sync",
                "instance_name": "soft_reset_sync",
                "instance_description": "Syncronize soft reset to clk_in domain",
                "parameters": {
                    "DATA_W": "1",
                },
                "connect": {
                    "clk_rst_s": "clk_rst_s",
                    "signal_i": "soft_reset_i",
                    "signal_o": "soft_reset_o",
                },
            },
            {
                "core_name": "iob_sync",
                "instance_name": "enable_sync",
                "instance_description": "Syncronize enable to clk_in domain",
                "parameters": {
                    "DATA_W": "1",
                },
                "connect": {
                    "clk_rst_s": "clk_rst_s",
                    "signal_i": "enable_i",
                    "signal_o": "enable_o",
                },
            },
            {
                "core_name": "iob_sync",
                "instance_name": "period_sync",
                "instance_description": "Syncronize period to clk_in domain",
                "parameters": {
                    "DATA_W": "PERIOD_W+1",
                },
                "connect": {
                    "clk_rst_s": "clk_rst_s",
                    "signal_i": "period_int",
                    "signal_o": "period_out",
                },
            },
        ],
        "snippets": [
            {
                "verilog_code": """
    // Period pack/unpack
    assign period_int = {period_wdata_i, period_wen_i};

    assign period_wdata_o = period_out[1+:PERIOD_W];
    assign period_wen_o = period_out[0];
""",
            },
        ],
    }

    return attributes_dict
