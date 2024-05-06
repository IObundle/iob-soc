def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_counter_ld",
        "name": "iob_counter_ld",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_re_inst",
            },
        ],
    }

    return attributes_dict
