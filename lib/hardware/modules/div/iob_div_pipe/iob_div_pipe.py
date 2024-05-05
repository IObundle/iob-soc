def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_div_pipe",
        "name": "iob_div_pipe",
        "version": "0.1",
        "ports": [
            {
                "name": "clk",
                "descr": "Clock",
                "signals": [
                    {"name": "clk", "width": 1, "direction": "input"},
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
    }

    return attributes_dict
