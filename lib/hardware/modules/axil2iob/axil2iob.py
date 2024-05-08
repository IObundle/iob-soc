def setup(py_params_dict):
    attributes_dict = {
        "original_name": "axil2iob",
        "name": "axil2iob",
        "version": "0.1",
        "generate_hw": False,
        "ports": [
            {
                "name": "clk_en_rst",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock, clock enable and reset",
                "signals": [],
            },
            {
                "name": "axil",
                "type": "slave",
                "descr": "AXIL interface",
                "signals": [],
            },
            {
                "name": "iob",
                "type": "master",
                "descr": "CPU native interface",
                "signals": [],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reg_e",
                "instance_name": "iob_reg_e_inst",
            },
        ],
    }

    return attributes_dict
