# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "confs": [
            {
                "name": "W",
                "type": "P",
                "val": "21",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
        ],
        "ports": [
            {
                "name": "in1_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "in1",
                        "width": "W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "in2_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "in2",
                        "width": "W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "sum_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "sum",
                        "width": "W",
                        "direction": "output",
                    },
                ],
            },
            {
                "name": "carry_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "carry",
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "sum_int",
                "descr": "sum wire",
                "signals": [
                    {"name": "sum_int", "width": "W+1"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": f"""
            assign sum_int = in1_i + in2_i;
            assign sum_o = sum_int[W-1:0];
            assign carry_o = sum_int[W];
         """,
            },
        ],
    }

    return attributes_dict
