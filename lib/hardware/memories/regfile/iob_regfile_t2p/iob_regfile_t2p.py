def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_regfile_t2p",
        "name": "iob_regfile_t2p",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_sync",
                "instance_name": "iob_sync_inst",
            },
            {
                "core_name": "iob_reg_e",
                "instance_name": "iob_reg_e_inst",
            },
        ],
    }

    return attributes_dict
