def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_f2s_1bit_sync",
        "name": "iob_f2s_1bit_sync",
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
