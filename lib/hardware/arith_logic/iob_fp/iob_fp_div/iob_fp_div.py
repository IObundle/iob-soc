def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_fp_div",
        "name": "iob_fp_div",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_fp_special",
                "instance_name": "iob_fp_special_inst",
            },
            {
                "core_name": "iob_div_subshift",
                "instance_name": "iob_div_subshift_inst",
            },
            {
                "core_name": "iob_fp_clz",
                "instance_name": "iob_fp_clz_inst",
            },
            {
                "core_name": "iob_fp_round",
                "instance_name": "iob_fp_round_inst",
            },
        ],
    }

    return attributes_dict
