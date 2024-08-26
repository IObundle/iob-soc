def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_ram_t2p",
        "name": "iob_ram_t2p",
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
                "name": "MEM_INIT_FILE_INT",
                "type": "P",
                "val": "HEXFILE",
                "min": "0",
                "max": "NA",
                "descr": "",
            },
        ],
        "ports": [
            {
                "name": "w_clk_i",
                "descr": "Input port",
                "signals": [
                    {"name": "w_clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "w_en_i",
                "descr": "Input",
                "signals": [
                    {"name": "w_en", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "w_addr_i",
                "descr": "Input",
                "signals": [
                    {"name": "w_addr", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "w_data_i",
                "descr": "Input",
                "signals": [
                    {"name": "w_data", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "r_clk_i",
                "descr": "Input",
                "signals": [
                    {"name": "r_clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "r_en_i",
                "descr": "Input",
                "signals": [
                    {"name": "r_en", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "r_addr_i",
                "descr": "Input",
                "signals": [
                    {"name": "r_addr", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "r_data_o",
                "descr": "Output",
                "signals": [
                    {"name": "r_data", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
    }

    return attributes_dict
