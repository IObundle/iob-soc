def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_inv",
        "name": "iob_inv",
        "version": "0.1",
        "confs": [
            {
                "name": "W",
                "type": "P",
                "val": "21",
                "min": "1",
                "max": "32",
                "descr": "IO width",
            },
        ],
        "ports": [
            {
                "name": "a",
                "descr": "Input port",
                "signals": [
                    {"name": "a", "width": "W", "direction": "input"},
                ],
            },
            {
                "name": "y",
                "descr": "Output port",
                "signals": [
                    {"name": "y", "width": "W", "direction": "output"},
                ],
            },
        ],
        "snippets": [{"verilog_code": "   assign y_o = ~a_i;"}],
    }

    return attributes_dict
