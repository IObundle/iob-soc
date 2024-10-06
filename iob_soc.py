# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    # Py2hwsw dictionary describing current core
    core_dict = {
        "original_name": "iob_soc",
        "name": "iob_soc",
        "version": "0.1",
        "parent": {"core_name": "iob_system", **py_params_dict},
    }

    # Dictionary of "iob_system" attributes to modify
    system_attributes = {
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
    }

    # Pass system_attributes dictionary via python parameter to the parent core (iob_system)
    core_dict["parent"]["system_attributes"] = system_attributes

    return core_dict
