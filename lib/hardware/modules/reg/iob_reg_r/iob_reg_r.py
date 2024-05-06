def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_reg_r",
        "name": "iob_reg_r",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_reg",
                "instance_name": "iob_reg_inst",
            },
        ],
    }

    return attributes_dict
