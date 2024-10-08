# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "21",
                "min": "1",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "RST_VAL",
                "type": "P",
                "val": "{DATA_W{1'b0}}",
                "min": "0",
                "max": "NA",
                "descr": "",
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
                "name": "en_rst_i",
                "descr": "Enable and Synchronous reset interface",
                "signals": [
                    {
                        "name": "en",
                        "direction": "input",
                        "width": 1,
                        "descr": "Enable input",
                    },
                    {
                        "name": "rst",
                        "direction": "input",
                        "width": 1,
                        "descr": "Synchronous reset input",
                    },
                ],
            },
            {
                "name": "ld_i",
                "descr": "Input port",
                "signals": [
                    {"name": "ld", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "ld_val_i",
                "descr": "Input port",
                "signals": [
                    {"name": "ld_val", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "data_o",
                "descr": "Output port",
                "signals": [
                    {"name": "data", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "wires": [
            {
                "name": "data_int",
                "descr": "data wire",
                "signals": [
                    {"name": "data_int", "width": "DATA_W"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg_re",
                "instance_name": "reg0",
                "parameters": {
                    "DATA_W": "DATA_W",
                    "RST_VAL": "RST_VAL",
                },
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "en_rst_i": "en_rst_i",
                    "data_i": "data_int",
                    "data_o": "data_o",
                },
            },
        ],
        "snippets": [
            {
                "verilog_code": """
        assign data_int = ld_i ? ld_val_i : data_o + 1'b1;
            """,
            },
        ],
    }

    return attributes_dict
