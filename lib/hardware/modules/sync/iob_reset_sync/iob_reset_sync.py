def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_reset_sync",
        "name": "iob_reset_sync",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_r",
                "instance_name": "iob_r_inst",
            },
        ],
    }

    return attributes_dict
