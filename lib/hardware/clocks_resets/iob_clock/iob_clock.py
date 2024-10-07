# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "CLK_PERIOD",
                "type": "P",
                "val": "10",
                "min": "",
                "max": "",
                "descr": "Clock period",
            },
        ],
        "ports": [
            {
                "name": "clk_o",
                "descr": "Output clock",
                "signals": [
                    {"name": "clk", "width": "1", "direction": "output"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
   reg clk;
   assign clk_o = clk;
   initial clk = 0; always #(CLK_PERIOD/2) clk = ~clk;
        """,
            }
        ],
    }

    return attributes_dict
