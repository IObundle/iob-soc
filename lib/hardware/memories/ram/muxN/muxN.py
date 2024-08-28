def setup(py_params_dict):
    attributes_dict = {
        "original_name": "muxN",
        "name": "muxN",
        "version": "0.1",
        "confs": [
            {
                "name": "N_INPUTS",
                "type": "P",
                "val": "4",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "INPUT_W",
                "type": "P",
                "val": "8",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "S",
                "type": "P",
                "val": "$clog2(N_INPUTS)",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "W",
                "type": "P",
                "val": "N_INPUTS * INPUT_W",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "data_i",
                "descr": "Input port",
                "signals": [
                    {"name": "data", "width": "INPUT_W", "direction": "input"},
                ],
            },
            {
                "name": "sel_i",
                "descr": "Input port",
                "signals": [
                    {"name": "sel", "width": "S", "direction": "input"},
                ],
            },
            {
                "name": "data_o",
                "descr": "Output port",
                "signals": [
                    {"name": "data", "width": "INPUT_W", "direction": "output"},
                ],
            },
        ],
        "combs": 
            {
                "verilog_code": """
            
             data_o = data_i[sel_i*INPUT_W+:INPUT_W];
            """,
            },
    }

    return attributes_dict
