def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_r",
        "name": "iob_r",
        "version": "0.1",
        "generate_hw": False,
        "ports": [
            {
                "name": "clk_rst",
                "descr": "Clock, clock enable and reset",
                "signals": [],
            },
            {
                "name": "io",
                "descr": "Input and output",
                "signals": [
                    {
                        "name": "data",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "Data input",
                    },
                    {
                        "name": "data",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "Data output",
                    },
                ],
            },
        ],
    }

    return attributes_dict
