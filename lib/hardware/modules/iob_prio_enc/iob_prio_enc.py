def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_prio_enc",
        "name": "iob_prio_enc",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_reverse",
                "instance_name": "iob_reverse_inst",
            },
        ],
    }

    return attributes_dict
