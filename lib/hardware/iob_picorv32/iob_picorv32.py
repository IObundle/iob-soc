# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "32",
                "min": "1",
                "max": "?",
                "descr": "Address bus width",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "1",
                "max": "?",
                "descr": "description here",
            },
            {
                "name": "USE_COMPRESSED",
                "type": "P",
                "val": "1",
                "min": "0",
                "max": "1",
                "descr": "description here",
            },
            {
                "name": "USE_MUL_DIV",
                "type": "P",
                "val": "1",
                "min": "0",
                "max": "1",
                "descr": "description here",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst_i",
                "signals": [
                    {
                        "name": "clk",
                        "direction": "input",
                        "width": "1",
                        "descr": "Clock input",
                    },
                    {
                        "name": "cke",
                        "direction": "input",
                        "width": "1",
                        "descr": "Clock enable input",
                    },
                    {
                        "name": "rst",
                        "direction": "input",
                        "width": "1",
                        "descr": "Synchronous reset input",
                    },
                ],
                "descr": "Clock, enable and synchronous reset",
            },
            {
                "name": "general_o",
                "descr": "General interface signals",
                "signals": [
                    {
                        "name": "trap",
                        "direction": "output",
                        "width": "1",
                        "descr": "CPU trap output",
                    },
                ],
            },
            {
                "name": "i_bus_m",
                "interface": {
                    "type": "iob",
                    "subtype": "master",
                    "file_prefix": "iob_picorv32_ibus_",
                    "port_prefix": "ibus_",
                    "wire_prefix": "ibus_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
                "descr": "iob-picorv32 instruction bus",
            },
            {
                "name": "d_bus_m",
                "interface": {
                    "type": "iob",
                    "subtype": "master",
                    "file_prefix": "iob_picorv32_dbus_",
                    "port_prefix": "dbus_",
                    "wire_prefix": "dbus_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
                "descr": "iob-picorv32 data bus",
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg",
                "instance_name": "iob_reg_inst",
            },
            {
                "core_name": "iob_edge_detect",
                "instance_name": "iob_edge_detect_inst",
            },
        ],
    }

    return attributes_dict
