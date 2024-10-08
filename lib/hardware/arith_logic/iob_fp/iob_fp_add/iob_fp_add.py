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
                "val": "32",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "EXP_W",
                "type": "P",
                "val": "8",
                "min": "NA",
                "max": "NA",
                "descr": "Exponent width",
            },
            {
                "name": "MAN_W",
                "type": "F",
                "val": "DATA_W-EXP_W",
                "min": "NA",
                "max": "NA",
                "descr": "MAN width",
            },
            {
                "name": "BIAS",
                "type": "F",
                "val": "2**(EXP_W-1)-1",
                "min": "NA",
                "max": "NA",
                "descr": "BIAS",
            },
            {
                "name": "EXTRA",
                "type": "F",
                "val": "3",
                "min": "NA",
                "max": "NA",
                "descr": "EXTRA",
            },
            {
                "name": "STICKY_BITS",
                "type": "F",
                "val": "2*BIAS-1",
                "min": "NA",
                "max": "NA",
                "descr": "STICKY_BITS",
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
                "name": "rst_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "rst",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "start_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "start",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "op_a_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": " op_a",
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
                        "width": "$clog2(DATA_W+1)",
                        "direction": "output",
                    },
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_fp_special",
                "instance_name": "iob_fp_special_inst",
            },
            {
                "core_name": "iob_fp_clz",
                "instance_name": "iob_fp_clz_inst",
            },
            {
                "core_name": "iob_fp_round",
                "instance_name": "iob_fp_round_inst",
            },
        ],
    }

    return attributes_dict
