def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_regfile_sp",
        "name": "iob_regfile_sp",
        "version": "0.09",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_re_inst",
            },
        ],
    }

    return attributes_dict
