def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_nco",
        "name": "iob_nco",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_reg_r",
                "instance_name": "iob_reg_r_inst",
            },
            {
                "core_name": "iob_reg",
                "instance_name": "iob_reg_inst",
            },
            {
                "core_name": "iob_modcnt",
                "instance_name": "iob_modcnt_inst",
            },
            {
                "core_name": "iob_acc_ld",
                "instance_name": "iob_acc_ld_inst",
            },
            {
                "core_name": "iob_functions",
                "instance_name": "iob_functions_inst",
            },
            # For simulation
            {
                "core_name": "iob_clock",
                "instance_name": "iob_clock_inst",
            },
        ],
    }

    return attributes_dict
