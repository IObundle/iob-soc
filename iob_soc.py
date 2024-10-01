def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_soc",
        "name": "iob_soc",
        "parent": {"core_name": "iob_system", **py_params_dict},
        "version": "0.1",
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
                "is_peripheral": True,
                "parameters": {},
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    # TODO: Cbus should be connected automatically
                    # The iob_system blocks are handled by iob_system_utils.py, but
                    # the iob_system scripts do not have access to info in iob_soc.py,
                    # nor do they have permission to modify it (even if iob_system receives info about child module, it can't modify its dictionary).
                    "cbus_s": "uart0_cbus",
                    "rs232_m": "rs232_m",
                },
            },
            {
                "core_name": "iob_timer",
                "instance_name": "TIMER0",
                "instance_description": "Timer peripheral",
                "is_peripheral": True,
                "parameters": {},
                "connect": {
                    "clk_en_rst_s": "clk_en_rst_s",
                    # TODO: Cbus should be connected automatically
                    "cbus_s": "timer0_cbus",
                },
            },
        ],
    }

    return attributes_dict
