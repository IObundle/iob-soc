def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_ram_t2p_tiled",
        "name": "iob_ram_t2p_tiled",
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "13",
                "min": "0",
                "max": "NA",
                "descr": "Data bus width",
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
                "type": "P",
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
                    {"name": "addr", "width": "ADDR", "direction": "input"},
                ],
            },
            {
                "name": "r_data_o",
                "descr": "Output port",
                "signals": [
                    {"name": "r_data", "width": "ADDR", "direction": "output"},
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
         ],
        
        "blocks": [
            {
                "core_name": "iob_ram_t2p",
                "instance_name": "iob_ram_t2p_inst",
            },
        ],
    }

    return attributes_dict
