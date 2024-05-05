def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_fp_sqrt",
        "name": "iob_fp_sqrt",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_int_sqrt",
                "instance_name": "iob_int_sqrt_inst",
            },
        ],
    }

    return attributes_dict
