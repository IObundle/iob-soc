def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_modcnt",
        "name": "iob_modcnt",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_counter_ld",
                "instance_name": "iob_counter_ld_inst",
            },
        ],
    }

    return attributes_dict
