# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "generate_hw": False,
        "ports": [
            {
                "name": "clk_en_rst_s",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "Clock, clock enable and reset",
            },
            {
                "name": "axil_s",
                "interface": {
                    "type": "axil",
                    "subtype": "slave",
                    "ADDR_W": "AXIL_ADDR_W",
                    "DATA_W": "AXIL_DATA_W",
                },
                "descr": "AXIL interface",
            },
            {
                "name": "iob_m",
                "interface": {
                    "type": "iob",
                    "subtype": "master",
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                },
                "descr": "CPU native interface",
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg_e",
                "instance_name": "iob_reg_e_inst",
            },
        ],
    }

    return attributes_dict
