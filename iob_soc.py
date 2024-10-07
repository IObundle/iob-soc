# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    # Py2hwsw dictionary describing current core
    core_dict = {
        "version": "0.1",
        "board_list": ["basys3"],
        "parent": {
            "core_name": "iob_system",
            **py_params_dict,
            "system_attributes": {
                "ports": [
                    {
                        "name": "rs232_m",
                        "descr": "iob-system uart interface",
                        "interface": {
                            "type": "rs232",
                        },
                    },
                ],
                "blocks": [
                    {
                        "core_name": "iob_uart",
                        "instance_name": "UART0",
                        "instance_description": "UART peripheral",
                        "peripheral_addr_w": 3,
                        "parameters": {},
                        "connect": {
                            "clk_en_rst_s": "clk_en_rst_s",
                            # Cbus connected automatically
                            "rs232_m": "rs232_m",
                        },
                    },
                    {
                        "core_name": "iob_timer",
                        "instance_name": "TIMER0",
                        "instance_description": "Timer peripheral",
                        "peripheral_addr_w": 4,
                        "parameters": {},
                        "connect": {
                            "clk_en_rst_s": "clk_en_rst_s",
                            # Cbus connected automatically
                        },
                    },
                ],
            },
        },
    }

    return core_dict
