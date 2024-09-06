def setup(py_params_dict):
    attributes_dict = {
        "original_name": "axi2iob",
        "name": "axi2iob",
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "ADDR_WIDTH",
                "descr": "",
                "type": "P",
                "val": "32",
                "min": "1",
                "max": "32",
            },
            {
                "name": "DATA_WIDTH",
                "descr": "",
                "type": "P",
                "val": "32",
                "min": "1",
                "max": "32",
            },
            {
                "name": "STRB_WIDTH",
                "descr": "",
                "type": "P",
                "val": "(DATA_WIDTH / 8)",
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_ID_WIDTH",
                "descr": "",
                "type": "P",
                "val": "8",
                "min": "1",
                "max": "32",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst",
                "interface": {
                    "type": "clk_en_rst",
                    "subtype": "slave",
                },
                "descr": "Clock, clock enable and reset",
            },
            {
                "name": "axi",
                "descr": "Slave AXI interface",
                "interface": {
                    "type": "axi",
                    "subtype": "slave",
                    "port_prefix": "s_",
                    "ADDR_W": "ADDR_WIDTH",
                    "DATA_W": "DATA_WIDTH",
                },
            },
            {
                "name": "iob",
                "descr": "Master IOb interface",
                "interface": {
                    "type": "iob",
                    "subtype": "master",
                    "ADDR_W": "ADDR_WIDTH",
                    "DATA_W": "DATA_WIDTH",
                },
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_re_inst",
            },
        ],
    }

    return attributes_dict
