def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_fp_uint2float",
        "name": "iob_fp_uint2float",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_fp_dq",
                "instance_name": "iob_fp_dq_inst",
            },
        ],
    }

    return attributes_dict
