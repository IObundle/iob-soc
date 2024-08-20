def setup(py_params_dict):
    attributes_dict = {
        "original_name": "axis2fifo",
        "name": "axis2fifo",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_counter",
                "instance_name": "iob_counter_inst",
            },
            {
                "core_name": "iob_edge_detect",
                "instance_name": "iob_edge_detect_inst",
            },
        ],
    }

    return attributes_dict
