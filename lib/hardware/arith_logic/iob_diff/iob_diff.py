def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_diff",
        "name": "iob_diff",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_reg_r",
                "instance_name": "iob_reg_r_inst",
            },
        ],
    }

    return attributes_dict
