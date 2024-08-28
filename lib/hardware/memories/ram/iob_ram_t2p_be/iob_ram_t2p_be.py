def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_ram_t2p_be",
        "name": "iob_ram_t2p_be",
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "HEXFILE",
                "type": "P",
                "val": '"none"',
                "min": "NA",
                "max": "NA",
                "descr": "Name of file to load into RAM",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "COL_W",
                "type": "F",
                "val": "8",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "NUM_COL",
                "type": "F",
                "val": "DATA_W / COL_W",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "mem_init_file_int",
                "type": "F",
                "val": "HEXFILE",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "w_en_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_en", "width": "DATA_W/8", "direction": "input"},
                ],
            },
            {
                "name": "w_addr_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_addr", "width": "ADDR", "direction": "input"},
                ],
            },
            {
                "name": "w_data_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_data", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "r_en_i",
                "descr": "Input port",
                "signals": [
                    {"name": "r_en", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "r_addr_i",
                "descr": "Input port",
                "signals": [
                    {"name": "r_addr", "width": "ADDR", "direction": "input"},
                ],
            },
            {
                "name": "r_data_o",
                "descr": "Output port",
                "signals": [
                    {"name": "r_data", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "wires": [
              {
                "name": "mem",
                "descr": "mem wire",
                "signals": [
                    {"name": "mem", "width": "(DATA_W*(2**ADDR_W))"},
                ],
            },

        ],
        "blocks": [
            {
                "core_name": "iob_ram_t2p",
                "instantiate": False,
            },
        ],
    }

    return attributes_dict
