def setup(py_params_dict):
    attributes_dict = {
        "original_name": "decN",
        "name": "decN",
        "version": "0.1",
        "confs": [
            {
                "name": "N_OUTPUTS",
                "type": "P",
                "val": "16",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "dec_i",
                "descr": "Input port",
                "signals": [
                    {"name": "dec", "width": "$clog2(N_OUTPUTS)", "direction": "input"},
                ],
            },
            {
                "name": "dec_o",
                "descr": "Output port",
                "signals": [
                    {"name": "dec", "width": "N_OUTPUTS", "direction": "output"},
                ],
            },
        ],
        "combs": 
            {
                "verilog_code": """
            dec_o        = 0;
            dec_o[dec_i] = 1'b1;
            """,
            },
    }

    return attributes_dict
