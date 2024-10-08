# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "ports": [
            {
                "name": "io",
                "descr": "IBUFG io",
                "signals": [
                    {"name": "i", "direction": "input", "width": "1"},
                    {"name": "o", "direction": "output", "width": "1"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
    IBUFG ibufg_inst (
      .I(i_i),
      .O(o_o)
    );
""",
            },
        ],
    }

    return attributes_dict
