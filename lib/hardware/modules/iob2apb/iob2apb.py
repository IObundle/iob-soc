def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob2apb",
        "name": "iob2apb",
        "version": "0.1",
        "confs": [
            {
                "name": "APB_ADDR_W",
                "type": "P",
                "val": "22",
                "min": "NA",
                "max": "NA",
                "descr": "Data bus width",
            },
            {
                "name": "APB_DATA_W",
                "type": "P",
                "val": "22",
                "min": "NA",
                "max": "NA",
                "descr": "Reset value.",
            },
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "APB_ADDR_W",
                "min": "NA",
                "max": "NA",
                "descr": "Reset value.",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "APB_DATA_W",
                "min": "NA",
                "max": "NA",
                "descr": "Reset value.",
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
                "name": "iob",
                "interface": {
                    "type": "iob",
                    "subtype": "slave",
                },
                "descr": "CPU native interface",
            },
            {
                "name": "apb",
                "interface": {
                    "type": "apb",
                    "subtype": "master",
                },
                "descr": "APB interface",
            },
        ],
        "wires": [
            {
                "name": "pc_int",
                "descr": "pc_int wire",
                "signals": [
                    {"name": "pc_int", "width": 1},
                ],
            },
            {
                "name": "pc_nxt_int",
                "descr": "pc_nxt_int wire",
                "signals": [
                    {"name": "pc_nxt_int", "width": 1},
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg",
                "instance_name": "pc_reg",
                "parameters": {
                    "DATA_W": 2,
                    "RST_VAL": 0,
                },
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "data_i": "pc_nxt_int",
                    "data_o": "pc_int",
                },
            },
            {
                "core_name": "iob_reg",
                "instance_name": "pc_reg",
                "parameters": {
                    "DATA_W": "DATA_W",
                    "RST_VAL": 0,
                },
                "connect": {
                    "clk_en_rst": "clk_en_rst",
                    "data_i": "apb_rdata_i",
                    "data_o": "iob_rdata_o",
                },
            },
        ],
    }

    return attributes_dict
