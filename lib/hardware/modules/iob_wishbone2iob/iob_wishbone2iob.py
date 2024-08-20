def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_wishbone2iob",
        "name": "iob_wishbone2iob",
        "version": "0.1",
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "32",
                "min": "NA",
                "max": "NA",
                "descr": "ADDR width",
            },
        ],
        "ports": [
            {
                "name": "wb_addr_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "wb_addr",
                        "width": "ADDR_W",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "wb_select_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "wb_select",
                        "width": "DATA_W/8",
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "wb_we_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "wb_we",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "wb_cyc_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "wb_cyc",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
            {
                "name": "wb_stb_i",
                "descr": "Input port",
                "signals": [
                    {
                        "name": "wb_stb",
                        "width": 1,
                        "direction": "input",
                    },
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_re_inst",
            },
        ],
    }

    return attributes_dict
