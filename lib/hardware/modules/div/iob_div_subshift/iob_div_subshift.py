def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_div_subshift",
        "name": "iob_div_subshift",
        "version": "0.1",
        "generate_hw": False,
        "ports": [
            {
                "name": "clk_en_rst",
                "descr": "Clock, clock enable and reset",
                "signals": [
                    {"name": "clk", "width": 1, "direction": "input"},
                    {"name": "clk_en", "width": 1, "direction": "input"},
                    {"name": "rst", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "status",
                "descr": "",
                "signals": [
                    {"name": "start", "width": 1, "direction": "input"},
                    {"name": "done", "width": 1, "direction": "output"},
                ],
            },
            {
                "name": "div",
                "descr": "Division interface",
                "signals": [
                    {"name": "dividend", "width": "DATA_W", "direction": "input"},
                    {"name": "divisor", "width": "DATA_W", "direction": "input"},
                    {"name": "quotient", "width": "DATA_W", "direction": "output"},
                    {"name": "remainder", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg",
                "instance_name": "iob_reg_inst",
            },
        ],
    }

    return attributes_dict
