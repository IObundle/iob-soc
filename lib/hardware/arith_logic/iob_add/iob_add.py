def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_add",
        "name": "iob_add",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_add2",
                "instance_name": "iob_add2_inst",
            },
        ],
    }

    return attributes_dict
