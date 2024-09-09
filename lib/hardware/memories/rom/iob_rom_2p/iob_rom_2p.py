def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_rom_2p",
        "name": "iob_rom_2p",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_rom_sp",
                "instance_name": "iob_rom_sp_inst",
            },
        ],
    }

    return attributes_dict
