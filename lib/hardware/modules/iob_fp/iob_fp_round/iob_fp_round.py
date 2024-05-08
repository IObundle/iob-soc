def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_fp_round",
        "name": "iob_fp_round",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_fp_clz",
                "instance_name": "iob_fp_clz_inst",
            },
        ],
    }

    return attributes_dict
