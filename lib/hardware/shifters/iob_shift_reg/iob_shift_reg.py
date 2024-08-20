def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_shift_reg",
        "name": "iob_shift_reg",
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
            # TODO: Remaining ports
        ],
        "blocks": [
            {
                "core_name": "iob_reg",
                "instance_name": "iob_reg_inst",
            },
            {
                "core_name": "iob_counter",
                "instance_name": "iob_counter_inst",
            },
            # For simulation
            {
                "core_name": "iob_ram_2p",
                "instance_name": "iob_ram_2p_inst",
            },
        ],
    }

    return attributes_dict
