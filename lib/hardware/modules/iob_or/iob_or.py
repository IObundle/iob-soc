def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_or",
        "name": "iob_or",
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
                "name": "b",
                "descr": "Input port",
                "signals": [
                    {"name": "b", "width": "W", "direction": "input"},
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
        "snippets": [{"outputs": ["y"], "verilog_code": "   assign y_o = a_i | b_i;"}],
    }

    return attributes_dict
