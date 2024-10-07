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
                "name": "data_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "data",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "data_l_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "data_l",
                        "width": "DATA_W",
                        "direction": "output",
                    },
                ],
            },
            {
                "name": "data_h_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "data_h",
                        "width": "DATA_W",
                        "direction": "output",
                    },
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": f"""
            always @(posedge clk_i) 
            data_h_o <= data_i;
            always @(negedge clk_i) 
            data_l_o <= data_i;
         """,
            },
        ],
    }

    return attributes_dict
