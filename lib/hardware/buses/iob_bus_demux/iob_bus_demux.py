# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "generate_hw": False,
        "ports": [
            {
                "name": "clk_rst_s",
                "interface": {
                    "type": "clk_rst",
                    "subtype": "slave",
                },
                "descr": "Clock and reset",
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_re_inst",
            },
            {
                "core_name": "iob_demux",
                "instance_name": "iob_demux_inst",
            },
            {
                "core_name": "iob_mux",
                "instance_name": "iob_mux_inst",
            },
        ],
    }
    return attributes_dict
