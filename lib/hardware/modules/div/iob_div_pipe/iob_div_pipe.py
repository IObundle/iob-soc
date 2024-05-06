def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_div_pipe",
        "name": "iob_div_pipe",
        "version": "0.1",
        "generate_hw": False,
        "ports": [
            {
                "name": "clk",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock",
                "signals": [
                    {
                        "name": "clk",
                        "direction": "input",
                        "width": 1,
                        "descr": "Clock",
                    },
                ],
            },
            {
                "name": "div",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Division interface",
                "signals": [
                    {
                        "name": "dividend",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "divisor",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "quotient",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "remainder",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "",
                    },
                ],
            },
        ],
    }

    return attributes_dict
