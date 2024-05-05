def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_sync",
        "name": "iob_sync",
        "version": "0.1",
        "generate_hw": False,
        "ports": [
            {
                "name": "clk_rst",
                "descr": "Clock and reset",
                "signals": [],
            },
            {
                "name": "io",
                "descr": "Input and output",
                "signals": [
                    {
                        "name": "signal",
                        "direction": "input",
                        "width": "DATA_W",
                        "descr": "Input",
                    },
                    {
                        "name": "signal",
                        "direction": "output",
                        "width": "DATA_W",
                        "descr": "Output",
                    },
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_r",
                "instance_name": "iob_r_inst",
            },
        ],
    }

    return attributes_dict
