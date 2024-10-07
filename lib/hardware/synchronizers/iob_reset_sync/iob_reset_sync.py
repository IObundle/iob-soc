# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

edge = 1


def setup(py_params_dict):
    global edge
    if "RST_POL" in py_params_dict:
        edge = py_params_dict["RST_POL"]
    attributes_dict = {
        "version": "0.1",
        "ports": [
            {
                "name": "clk_rst_s",
                "interface": {
                    "type": "clk_rst",
                    "subtype": "slave",
                },
                "descr": "clock and reset",
            },
            {
                "name": "arst_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "arst",
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "data_int",
                "descr": "data_int wire",
                "signals": [
                    {"name": "data_int", "width": 2},
                ],
            },
            {
                "name": "sync",
                "descr": "sync wire",
                "signals": [
                    {"name": "sync", "width": 2},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_r",
                "instance_name": "reg1",
                "parameters": {
                    "DATA_W": 2,
                    "RST_VAL": "2'd3" if edge else "2'd0",
                },
                "connect": {
                    "clk_rst_s": "clk_rst_s",
                    "iob_r_data_i": "data_int",
                    "iob_r_data_o": "sync",
                },
            },
        ],
        "snippets": [
            {
                "verilog_code": f"""
    assign data_int = {{sync[0], {"1'b0" if edge else "1'b1"}}};
    assign arst_o = sync[1];
            """,
            },
        ],
    }

    return attributes_dict
