def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_regfile_2p",
        "name": "iob_regfile_2p",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_ctls",
                "instance_name": "iob_ctls_inst",
            },
        ],
    }

    return attributes_dict
