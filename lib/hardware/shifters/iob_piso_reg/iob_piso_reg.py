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
                "val": "32",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
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
                "name": "ld_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "ld",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "p_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "p",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "s_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "s",
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "data_reg_int",
                "descr": "data_reg_int wire",
                "signals": [
                    {"name": "data_reg_int", "width": "DATA_W"},
                ],
            },
            {
                "name": "data_int",
                "descr": "data_int wire",
                "signals": [
                    {"name": "data_int", "width": "DATA_W"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg",
                "instance_name": "reg0",
                "parameters": {
                    "DATA_W": "DATA_W",
                    "RST_VAL": 0,
                },
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    "data_i": "data_int",
                    "data_o": "data_reg_int",
                },
            },
        ],
        "snippets": [
            {
                "verilog_code": """
        assign data_int = ld_i ? p_i : data_reg_int << 1'b1;
        assign  s_o = data_reg_int[DATA_W-1];

            """,
            },
        ],
    }

    return attributes_dict
