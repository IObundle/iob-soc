import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_fifo_sync import iob_fifo_sync
from iob_counter import iob_counter
from iob_reg_r import iob_reg_r
from iob_reg_re import iob_reg_re
from axi_ram import axi_ram
from iob_ram_t2p import iob_ram_t2p


class axis2axi(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "axis2axi"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            {"interface": "axi_write"},
            {"interface": "axi_read"},
            iob_fifo_sync,
            iob_counter,
            iob_reg_r,
            iob_reg_re,
            (axi_ram, {"purpose": "simulation"}),
            (iob_ram_t2p, {"purpose": "simulation"}),
        ]

        cls.ios += [
            {
                "name": "clk_en_rst",
                "type": "slave",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Clock, clock enable and reset",
                "ports": [],
            },
            {
                "name": "rst",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Synchronous reset interface",
                "ports": [
                    {
                        "name": "rst",
                        "direction": "input",
                        "width": 1,
                        "descr": "Synchronous reset input",
                    },
                ],
            },
            {
                "name": "config_in",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "AXI Stream input configuration interface",
                "ports": [
                    {
                        "name": "config_in_addr",
                        "direction": "input",
                        "width": "AXI_ADDR_W",
                        "descr": "",
                    },
                    {
                        "name": "config_in_valid",
                        "direction": "input",
                        "width": 1,
                        "descr": "",
                    },
                    {
                        "name": "config_in_ready",
                        "direction": "output",
                        "width": 1,
                        "descr": "",
                    },
                ],
            },
            {
                "name": "config_out",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "AXI Stream output configuration interface",
                "ports": [
                    {
                        "name": "config_out_addr",
                        "direction": "input",
                        "width": "AXI_ADDR_W",
                        "descr": "",
                    },
                    {
                        "name": "config_out_length",
                        "direction": "input",
                        "width": "AXI_ADDR_W",
                        "descr": "",
                    },
                    {
                        "name": "config_out_valid",
                        "direction": "input",
                        "width": 1,
                        "descr": "",
                    },
                    {
                        "name": "config_out_ready",
                        "direction": "output",
                        "width": 1,
                        "descr": "",
                    },
                ],
            },
            {
                "name": "axis_in",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "AXI Stream input interface",
                "ports": [
                    {
                        "name": "axis_in_data",
                        "direction": "input",
                        "width": "AXI_DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "axis_in_valid",
                        "direction": "input",
                        "width": 1,
                        "descr": "",
                    },
                    {
                        "name": "axis_in_ready",
                        "direction": "output",
                        "width": 1,
                        "descr": "",
                    },
                ],
            },
            {
                "name": "axis_out",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "AXI Stream output interface",
                "ports": [
                    {
                        "name": "axis_out_data",
                        "direction": "output",
                        "width": "AXI_DATA_W",
                        "descr": "",
                    },
                    {
                        "name": "axis_out_valid",
                        "direction": "output",
                        "width": 1,
                        "descr": "",
                    },
                    {
                        "name": "axis_out_ready",
                        "direction": "input",
                        "width": 1,
                        "descr": "",
                    },
                ],
            },
            {
                "name": "axi",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "AXI master interface",
                "ports": [],
                # FIXME: Configure ADDR_W of this interface to match AXI_ADDR_W parameter
            },
            {
                "name": "extmem",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "External memory interface",
                "ports": [
                    #  Write port
                    {
                        "name": "ext_mem_w_en",
                        "direction": "output",
                        "width": 1,
                        "descr": "Memory write enable",
                    },
                    {
                        "name": "ext_mem_w_addr",
                        "direction": "output",
                        "width": "BUFFER_W",
                        "descr": "Memory write address",
                    },
                    {
                        "name": "ext_mem_w_data",
                        "direction": "output",
                        "width": "AXI_DATA_W",
                        "descr": "Memory write data",
                    },
                    #  Read port
                    {
                        "name": "ext_mem_r_en",
                        "direction": "output",
                        "width": 1,
                        "descr": "Memory read enable",
                    },
                    {
                        "name": "ext_mem_r_addr",
                        "direction": "output",
                        "width": "BUFFER_W",
                        "descr": "Memory read address",
                    },
                    {
                        "name": "ext_mem_r_data",
                        "direction": "input",
                        "width": "AXI_DATA_W",
                        "descr": "Memory read data",
                    },
                ],
            },
        ]


if __name__ == "__main__":
    axis2axi.setup_as_top_module()
