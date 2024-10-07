# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "original_name": "fifo2axis",
        "name": "fifo2axis",
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_reg_re",
                "instance_name": "iob_reg_re_inst",
            },
            {
                "core_name": "iob_modcnt",
                "instance_name": "iob_modcnt_inst",
            },
        ],
    }

    return attributes_dict
