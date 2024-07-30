def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_rom_sp",
        "name": "iob_rom_sp",
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "HEXFILE",
                "type": "P",
                "val": "none",
                "min": "NA",
                "max": "NA",
                "descr": "Name of file to load into RAM",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "10",
                "min": "0",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "NA",
                "descr": "Data bus width",
            },
        ],
        "ports": [
            {
                "name": "clk",
                "descr": "Clock",
                "signals": [
                    {"name": "clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "rom_if",
                "descr": "Memory interface",
                "signals": [
                    {"name": "r_en", "width": 1, "direction": "input"},
                    {"name": "addr", "width": "ADDR_W", "direction": "input"},
                    {"name": "r_data", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
    }

    return attributes_dict
