# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT

def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_fp_mul",
        "name": "iob_fp_mul",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_fp_special",
                "instance_name": "iob_fp_special_inst",
            },
            {
                "core_name": "iob_fp_round",
                "instance_name": "iob_fp_round_inst",
            },
        ],
    }

    return attributes_dict
