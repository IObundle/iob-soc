# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "ports": [
            {
                "name": "io",
                "descr": "ODDRE1 io",
                "signals": [
                    {"name": "q", "direction": "output", "width": "1"},
                    {"name": "c", "direction": "input", "width": "1"},
                    {"name": "d1", "direction": "input", "width": "1"},
                    {"name": "d2", "direction": "input", "width": "1"},
                    {"name": "sr", "direction": "input", "width": "1"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
    ODDRE1 ODDRE1_inst (
      .Q (q_o),
      .C (c_i),
      .D1(d1_i),
      .D2(d2_i),
      .SR(sr_i)
    );
""",
            },
        ],
    }

    return attributes_dict
