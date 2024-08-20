def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_ram_2p_tiled",
        "name": "iob_ram_2p_tiled",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_ram_2p",
                "instance_name": "iob_ram_2p_inst",
            },
        ],
    }

    return attributes_dict
