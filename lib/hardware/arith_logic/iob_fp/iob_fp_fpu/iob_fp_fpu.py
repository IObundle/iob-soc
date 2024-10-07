# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "iob_fp_add",
                "instance_name": "iob_fp_add_inst",
            },
            {
                "core_name": "iob_fp_mul",
                "instance_name": "iob_fp_mul_inst",
            },
            {
                "core_name": "iob_fp_div",
                "instance_name": "iob_fp_div_inst",
            },
            {
                "core_name": "iob_fp_sqrt",
                "instance_name": "iob_fp_sqrt_inst",
            },
            {
                "core_name": "iob_fp_minmax",
                "instance_name": "iob_fp_minmax_inst",
            },
            {
                "core_name": "iob_fp_cmp",
                "instance_name": "iob_fp_cmp_inst",
            },
            {
                "core_name": "iob_fp_int2float",
                "instance_name": "iob_fp_int2float_inst",
            },
            {
                "core_name": "iob_fp_uint2float",
                "instance_name": "iob_fp_uint2float_inst",
            },
            {
                "core_name": "iob_fp_float2int",
                "instance_name": "iob_fp_float2int_inst",
            },
            {
                "core_name": "iob_fp_float2uint",
                "instance_name": "iob_fp_float2uint_inst",
            },
        ],
    }

    return attributes_dict
