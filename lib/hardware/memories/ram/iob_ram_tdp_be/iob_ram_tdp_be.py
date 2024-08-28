def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_ram_tdp_be",
        "name": "iob_ram_tdp_be",
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
                "name": "enA_i",
                "descr": "Input",
                "signals": [
                    {"name": "enA", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "weA_i",
                "descr": "Input",
                "signals": [
                    {"name": "weA", "width": "DATA_W/8", "direction": "input"},
                ],
            },
            {
                "name": "addrA_i",
                "descr": "Input",
                "signals": [
                    {"name": "addrA", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "dA_i",
                "descr": "Input",
                "signals": [
                    {"name": "dA", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "enB_i",
                "descr": "Input",
                "signals": [
                    {"name": "enB", "width": 1, "direction": "input"},
                ],
            },
            {
                "name": "weB_i",
                "descr": "Input",
                "signals": [
                    {"name": "weB", "width": "DATA_W/8", "direction": "input"},
                ],
            },
            {
                "name": "addrB_i",
                "descr": "Input",
                "signals": [
                    {"name": "addrB", "width": "ADDR_W", "direction": "input"},
                ],
            },
            {
                "name": "dB_i",
                "descr": "Input",
                "signals": [
                    {"name": "dB", "width": "DATA_W", "direction": "input"},
                ],
            },
            {
                "name": "dA_o",
                "descr": "Output",
                "signals": [
                    {"name": "dA", "width": "DATA_W", "direction": "output"},
                ],
            },
            {
                "name": "dB_o",
                "descr": "Output",
                "signals": [
                    {"name": "dB", "width": "DATA_W", "direction": "output"},
                ],
            },
        ],
        "wires": [
            {
                "name": "dA_o_int",
                "descr": "dA_o_int wire",
                "signals": [
                    {"name": "dA_o_int", "width": "DATA_W"},
                ],
            },
            {
                "name": "dB_o_int",
                "descr": "dB_o_int wire",
                "signals": [
                    {"name": "dB_o_int", "width": "DATA_W"},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_ram_tdp",
                "instantiate": False,
            },
        ],
    }

    return attributes_dict
