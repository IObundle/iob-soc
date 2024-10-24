# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    # Py2hwsw dictionary describing current core
    core_dict = {
        "version": "0.1",
        "parent": {
            "core_name": "iob_system",
            **py_params_dict,
            "system_attributes": {
                "board_list": ["aes_ku040_db_g", "cyclonev_gt_dk", "zybo_z7"],
                "ports": [
                    {
                        "name": "rs232_m",
                        "descr": "iob-system uart interface",
                        "signals": {
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
