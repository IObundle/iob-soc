def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_ram_dp_be_xil",
        "name": "iob_ram_dp_be_xil",
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
    }

    return attributes_dict
