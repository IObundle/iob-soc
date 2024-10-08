# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
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
