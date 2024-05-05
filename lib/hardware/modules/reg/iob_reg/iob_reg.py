def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_reg",
        "name": "iob_reg",
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "1",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "RST_VAL",
                "type": "P",
                "val": "{DATA_W{1'b0}}",
                "min": "NA",
                "max": "NA",
                "descr": "Reset value.",
            },
            {
                "name": "RST_POL",
                "type": "M",
                "val": "1",
                "min": "0",
                "max": "1",
                "descr": "Reset polarity.",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst",
                "descr": "Clock, clock enable, and reset",
                "signals": [],
            },
            {
                "name": "io",
                "descr": "Input and output",
                "signals": [
                    {
                        "name": "data",
                        "width": "DATA_W",
                        "direction": "input",
                        "descr": "Input",
                    },
                    {
                        "name": "data",
                        "width": "DATA_W",
                        "direction": "output",
                        "descr": "Output",
                    },
                ],
            },
        ],
    }

    return attributes_dict
