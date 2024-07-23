def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_prio_enc",
        "name": "iob_prio_enc",
        "version": "0.1",
        "generate_hw": False,
        "confs": [
            {
                "name": "W",
                "type": "P",
                "val": "21",
                "min": "0",
                "max": "NA",
                "descr": "Number of input bits.",
            },
            {
                "name": "MODE",
                "type": "P",
                "val": "LOW",
                "min": "NA",
                "max": "NA",
                "descr": "'LOW' = Prioritize smaller index",
            },
        ],
        "ports": [
            {
                "name": "io",
                "descr": "Data interface",
                "signals": [
                    {
                        "name": "unencoded",
                        "direction": "input",
                        "width": "W",
                        "descr": "Unencoded input bits",
                    },
                    {
                        "name": "encoded",
                        "direction": "output",
                        "width": "$clog2(W)",
                        "descr": "Encoded priority bit",
                    },
                ],
            },
        ],
        "blocks": [
            {
                "core_name": "iob_reverse",
                "instance_name": "iob_reverse_inst",
            },
        ],
    }

    return attributes_dict
