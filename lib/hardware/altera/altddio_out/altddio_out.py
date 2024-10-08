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
                "val": "1",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
        ],
        "ports": [
            {
                "name": "clk_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "clk",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "data_l_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "data_l",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "data_h_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "data_h",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "data_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "data",
                        "width": "DATA_W",
                        "direction": "output",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "data_l_i_reg",
                "descr": "data_l_i_reg wire",
                "signals": [
                    {"name": "data_l_i_reg", "width": "DATA_W"},
                ],
            },
            {
                "name": "data_h_i_reg",
                "descr": "data_h_i_reg wire",
                "signals": [
                    {"name": "data_h_i_reg", "width": "DATA_W"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
            always @(posedge clk_i) 
            data_h_i_reg <= data_h_i;
            always @(negedge clk_i) 
            data_l_i_reg <= data_l_i;
            assign data_o = clk_i ? data_h_i_reg : data_l_i_reg;
            """,
            },
        ],
    }

    return attributes_dict
