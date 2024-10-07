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
            {
                "name": "reg_interface",
                "descr": "",
                "signals": [
                    {"name": "rst_soft", "width": "1", "direction": "input"},
                    {"name": "tx_en", "width": "1", "direction": "input"},
                    {"name": "rx_en", "width": "1", "direction": "input"},
                    {"name": "tx_ready", "width": "1", "direction": "output"},
                    {"name": "rx_ready", "width": "1", "direction": "output"},
                    {"name": "tx_data", "width": "8", "direction": "input"},
                    {"name": "rx_data", "width": "8", "direction": "output"},
                    {"name": "data_write_en", "width": "1", "direction": "input"},
                    {"name": "data_read_en", "width": "1", "direction": "input"},
                    {
                        "name": "bit_duration",
                        "width": "`IOB_UART_DIV_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "rs232_m",
                "interface": {
                    "type": "rs232",
                },
                "descr": "RS232 interface",
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg_e",
            },
        ],
    }

    return attributes_dict
