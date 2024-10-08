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
            {
                "name": "RST_VAL",
                "type": "P",
                "val": "{DATA_W{1'b0}}",
                "min": "NA",
                "max": "NA",
                "descr": "Reset value.",
            },
        ],
        "ports": [
            {
                "name": "clk_rst_s",
                "interface": {
                    "type": "clk_rst",
                    "subtype": "slave",
                },
                "descr": "Clock and reset",
            },
            {
                "name": "signal_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "signal",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "signal_o",
                "descr": "Output port",
                "signals": [
                    {
                        "name": "signal",
                        "width": "DATA_W",
                        "direction": "output",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "synchronizer",
                "descr": "synchronizer wire",
                "signals": [
                    {"name": "synchronizer", "width": "DATA_W"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_r",
                "instance_name": "reg1",
                "parameters": {
                    "DATA_W": "DATA_W",
                    "RST_VAL": "RST_VAL",
                },
                "connect": {
                    "clk_rst_s": "clk_rst_s",
                    "iob_r_data_i": "signal_i",
                    "iob_r_data_o": "synchronizer",
                },
            },
            {
                "core_name": "iob_r",
                "instance_name": "reg2",
                "parameters": {
                    "DATA_W": "DATA_W",
                    "RST_VAL": "RST_VAL",
                },
                "connect": {
                    "clk_rst_s": "clk_rst_s",
                    "iob_r_data_i": "synchronizer",
                    "iob_r_data_o": "signal_o",
                },
            },
        ],
    }

    return attributes_dict
