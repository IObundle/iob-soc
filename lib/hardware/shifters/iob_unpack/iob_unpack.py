# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_unpack",
        "name": "iob_unpack",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_bfifo",
                "instance_name": "iob_bfifo_inst",
            },
        ],
    }

    return attributes_dict
