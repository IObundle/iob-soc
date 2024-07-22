def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_soc_int_mem",
        "name": "iob_soc_int_mem",
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "0",
                "max": "NA",
                "descr": "Width of data interface",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Width of address interface",
            },
            {
                "name": "HEXFILE",
                "type": "P",
                "val": "none",
                "min": "NA",
                "max": "NA",
                "descr": "Name of the firmware hex file",
            },
            {
                "name": "BOOT_HEXFILE",
                "type": "P",
                "val": "none",
                "min": "NA",
                "max": "NA",
                "descr": "Name of the boot hex file",
            },
            {
                "name": "SRAM_ADDR_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Width of sram address interface",
            },
            {
                "name": "BOOTROM_ADDR_W",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Width of bootrom address interface",
            },
            {
                "name": "B_BIT",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "NA",
                "descr": "Address boot bit",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst",
                "interface": {
                    "type": "clk_en_rst",
                },
                "descr": "Clock, clock enable and reset",
            },
            {
                "name": "general",
                "descr": "General signals for internal memory",
                "signals": [
                    {"name": "boot", "width": 1, "direction": "output"},
                    {"name": "cpu_reset", "width": 1, "direction": "output"},
                ],
            },
            {
                "name": "i_bus",
                "interface": {
                    "type": "iob",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
                "descr": "Instruction bus",
            },
            {
                "name": "d_bus",
                "interface": {
                    "type": "iob",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
                "descr": "Data bus",
            },
        ],
    }

    return attributes_dict
