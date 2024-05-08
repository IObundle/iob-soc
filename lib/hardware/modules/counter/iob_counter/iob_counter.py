def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_counter",
        "name": "iob_counter",
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "21",
                "min": "1",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "RST_VAL",
                "type": "P",
                "val": "{DATA_W{1'b0}}",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst",
                "descr": "Clock, clock enable and reset",
                "signals": [],
            },
            {
                "name": "rst",
                "descr": "Input port",
                "signals": [
                    {"name": "rst", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "en",
                "descr": "Input port",
                "signals": [
                    {"name": "en", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "data",
                "descr": "Output port",
                "signals": [
                    {"name": "data", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_re_inst",
            },
        ],
    }

    return attributes_dict
