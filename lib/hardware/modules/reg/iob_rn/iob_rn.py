def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_rn",
        "name": "iob_rn",
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
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock, clock enable and reset",
                "signals": [],
            },
            {
                "name": "io",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
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
