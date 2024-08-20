def setup(py_params_dict):
    attributes_dict = {
        "original_name": "timer_core",
        "name": "timer_core",
        "version": "0.1",
        "generate_hw": False,
        "ports": [
            {
                "name": "clk_en_rst",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "Clock and reset",
            },
            {
                "name": "reg_interface",
                "descr": "",
                "signals": [
                    {"name": "en", "width": "1", "direction": "input"},
                    {"name": "rst", "width": "1", "direction": "input"},
                    {"name": "rstrb", "width": "1", "direction": "input"},
                    {"name": "time", "width": "64", "direction": "output"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_re_inst",
            },
            {
                "core_name": "iob_counter",
                "instance_name": "iob_counter_inst",
            },
        ],
    }

    return attributes_dict
