def setup(py_params_dict):
    attributes_dict = {
        "original_name": "axil2iob",
        "name": "axil2iob",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_reg_e",
                "instance_name": "iob_reg_e_inst",
            },
        ],
    }

    return attributes_dict
