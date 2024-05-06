def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_div_subshift_frac",
        "name": "iob_div_subshift_frac",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_reg",
                "instance_name": "iob_reg_inst",
            },
            {
                "core_name": "iob_reg_e",
                "instance_name": "iob_reg_e_inst",
            },
            {
                "core_name": "iob_div_subshift",
                "instance_name": "iob_div_subshift_inst",
            },
        ],
    }

    return attributes_dict
