# SPDX-FileCopyrightText: 2024 IObundle
#
# SPDX-License-Identifier: MIT


def setup(py_params_dict):
    attributes_dict = {
        "version": "0.1",
        "generate_hw": False,
        "blocks": [
            {
                "core_name": "m_axi_m_port",
                "instance_name": "m_axi_m_port_inst",
            },
            {
                "core_name": "m_axi_write_m_port",
                "instance_name": "m_axi_write_m_port_inst",
            },
            {
                "core_name": "m_axi_read_m_port",
                "instance_name": "m_axi_read_m_port_inst",
            },
            {
                "core_name": "m_m_axi_write_portmap",
                "instance_name": "m_m_axi_write_portmap_inst",
            },
            {
                "core_name": "m_m_axi_read_portmap",
                "instance_name": "m_m_axi_read_portmap_inst",
            },
            {
                "core_name": "iob2axi_wr",
                "instance_name": "iob2axi_wr_inst",
            },
            {
                "core_name": "iob2axi_rd",
                "instance_name": "iob2axi_rd_inst",
            },
            {
                "core_name": "iob_fifo_sync",
                "instance_name": "iob_fifo_sync_inst",
            },
            {
                "core_name": "iob_functions",
                "instance_name": "iob_functions_inst",
            },
        ],
    }

    return attributes_dict
