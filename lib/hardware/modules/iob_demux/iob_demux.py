def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_demux",
        "name": "iob_demux",
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "1",
                "min": "0",
                "max": "NA",
                "descr": "Width of data interface",
            },
            {
                "name": "N",
                "type": "P",
                "val": "2",
                "min": "0",
                "max": "NA",
                "descr": "Number of outputs",
            },
        ],
        "ports": [
            {
                "name": "sel",
                "descr": "Selector interface",
                "signals": [
                    {
                        "name": "sel",
                        "width": "($clog2(N)+($clog2(N)==0))",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "io",
                "descr": "Data interface",
                "signals": [
                    {
                        "name": "data",
                        "width": "DATA_W",
                        "direction": "input",
                    },
                    {
                        "name": "data",
                        "width": "(N*DATA_W)",
                        "direction": "output",
                    },
                ],
            },
        ],
    }

    return attributes_dict
