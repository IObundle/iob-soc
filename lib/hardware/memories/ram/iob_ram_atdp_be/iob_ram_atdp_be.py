def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_ram_atdp_be",
        "name": "iob_ram_atdp_be",
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "13",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "TILE_ADDR_W",
                "type": "P",
                "val": "11",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
            {
                "name": "K",
                "type": "F",
                "val": "$ceil(2 ** (ADDR_W - TILE_ADDR_W))",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "clk_i",
                "descr": "Input port",
                "signals": [
                    {"name": "clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "w_en_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_en", "width": 1, "direction": "input"},
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
                "name": "w_data_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_data", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "addr_i",
                "descr": "Input port",
                "signals": [
                    {"name": "addr", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "r_data_o",
                "descr": "Input port",
                "signals": [
                    {"name": "r_data", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "wires": [
            {
                "name": "addr_en",
                "descr": "addr_en wire",
                "signals": [
                    {"name": "addr_en", "width": "K"},
                ],
            },
            {
                "name": "addr_int",
                "descr": "addr_int wire",
                "signals": [
                    {"name": "addr_int", "width": "ADDR_W"},
                ],
            },
            {
                "name": "r_data_vec",
                "descr": "r_data_vec wire",
                "signals": [
                    {"name": "r_data_vec", "width": "DATA_W"},
                ],
            },
            {
                "name": "r_data_vec_int",
                "descr": "r_data_vec_int wire",
                "signals": [
                    {"name": "r_data_vec_int", "width": "DATA_W"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_ram_2p",
                "instantiate": False,
            },
            {
                "core_name": "muxN",
                "instance_name": "bram_out_sel",
                "parameters": {
                    "N_INPUTS": "K",
                    "INPUT_W": "DATA_W",
                },
                "connect": {
                    "data_i": "r_data_vec_int",
                    "sel_i": "addr_int",
                    "data_o": "r_data_o",
                },
            },
            {
                "core_name": "decN",
                "instance_name": "addr_dec",
                "parameters": {
                    "N_OUTPUTS": "K",
                },
                "connect": {
                    "dec_i": "addr_int",
                    "dec_o": "addr_en",
                },
            },
        ],
    }

    return attributes_dict
