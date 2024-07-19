def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_add2",
        "name": "iob_add2",
        "version": "0.1",
        "confs": [
            {
                "name": "W",
                "type": "P",
                "val": "21",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "in1",
                "descr": "Input_1 port",
                "signals": [
                    {
                        "name": "in1",
                        "width": "W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "in2",
                "descr": "Input_2 port",
                "signals": [
                    {
                        "name": "in2",
                        "width": "W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "sum",
                "descr": "sum port",
                "signals": [
                    {
                        "name": "sum",
                        "width": "W",
                        "direction": "output",
                    },
                ],
            },
            {
                "name": "carry",
                "descr": "carry port",
                "signals": [
                    {
                        "name": "carry",
                        "width": 1,
                        "direction": "output",
                    },
                ],
            },
        ],
        "snippets": [
            {
                "outputs": [],
                "verilog_code": """
          assign sum_o   = in1_i + in2_i;
          assign carry_o = sum_o[W];
         """,
            },
        ],
    }

    return attributes_dict
