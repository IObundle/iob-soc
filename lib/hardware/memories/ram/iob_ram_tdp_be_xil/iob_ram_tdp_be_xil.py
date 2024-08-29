def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_ram_tdp_be_xil",
        "name": "iob_ram_tdp_be_xil",
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
                "val": '{HEXFILE, ".hex"}',
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
                "name": "port_a",
                "descr": "Memory interface A",
                "signals": [
                    {"name": "enA", "width": 1, "direction": "input"},
                    {"name": "weA", "width": "DATA_W/8", "direction": "input"},
                    {"name": "addrA", "width": "ADDR_W", "direction": "input"},
                    {"name": "dA", "width": "DATA_W", "direction": "input"},
                    {"name": "dA", "width": "DATA_W", "direction": "output"},
                ],
            },
            {
                "name": "port_b",
                "descr": "Memory interface B",
                "signals": [
                    {"name": "enB", "width": 1, "direction": "input"},
                    {"name": "weB", "width": "DATA_W/8", "direction": "input"},
                    {"name": "addrB", "width": "ADDR_W", "direction": "input"},
                    {"name": "dB", "width": "DATA_W", "direction": "input"},
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
    }

    return attributes_dict
