def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_ram_sp",
        "name": "iob_ram_sp",
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
                "val": "14",
                "min": "0",
                "max": "NA",
                "descr": "Address bus width",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "8",
                "min": "0",
                "max": "NA",
                "descr": "Data bus width",
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
                "name": "clk",
                "descr": "Clock",
                "signals": [
                    {"name": "clk", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "en_i",
                "descr": "Input",
                "signals": [
                    {"name": "en", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "we_i",
                "descr": "Input",
                "signals": [
                    {"name": "we", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "addr_i",
                "descr": "Input",
                "signals": [
                    {"name": "addr", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "d_i",
                "descr": "Input",
                "signals": [
                    {"name": "d", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "d_o",
                "descr": "Output",
                "signals": [
                    {"name": "d", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
    }

    return attributes_dict
