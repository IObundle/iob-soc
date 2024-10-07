# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "ports": [
            {
                "name": "in_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "in",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "en_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "en",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "out_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "out",
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
            {
                "name": "in_out_io",
                "descr": "In/Output port",
                "signals": [
                    {
                        "name": "in_out",
                        "width": 1,
                        "direction": "inout",
                    },
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": f"""
            assign in_out_io = en_i ? in_i : 1'bz;
            assign out_o     = in_out_io;
         """,
            },
        ],
    }

    return attributes_dict
