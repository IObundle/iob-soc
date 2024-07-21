def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob2apb",
        "name": "iob2apb",
        "version": "0.1",
        "generate_hw": False,
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
        "blocks": [
            {
                "core_name": "iob_reg",
                "instance_name": "iob_reg_inst",
            },
        ],
    }

    return attributes_dict
