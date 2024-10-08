# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "ports": [
            {
                "name": "io",
                "descr": "",
                "signals": [
                    {"name": "aclr", "direction": "input", "width": "1"},
                    {"name": "data_h", "direction": "input", "width": "1"},
                    {"name": "data_l", "direction": "input", "width": "1"},
                    {"name": "clk", "direction": "input", "width": "1"},
                    {"name": "data", "direction": "output", "width": "1"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
    ddio_out_clkbuf ddio_out_clkbuf_inst (
        .aclr    (aclr_i),
        .datain_h(data_h_i),
        .datain_l(data_l_i),
        .outclock(clk_i),
        .dataout (data_o)
    );
""",
            },
        ],
    }

    return attributes_dict
