# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_reg_r",
                "instance_name": "iob_reg_r_inst",
            },
            # For simulation
            {
                "core_name": "iob_functions",
                "instance_name": "iob_functions_inst",
            },
        ],
    }

    return attributes_dict
