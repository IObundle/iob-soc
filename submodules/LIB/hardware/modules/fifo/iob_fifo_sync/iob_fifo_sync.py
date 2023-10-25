import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg_e import iob_reg_e
from iob_reg_r import iob_reg_r
from iob_reg import iob_reg
from iob_counter import iob_counter
from iob_asym_converter import iob_asym_converter
from iob_ram_2p import iob_ram_2p
from iob_utils import iob_utils


class iob_fifo_sync(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_fifo_sync"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            iob_reg_e,
            iob_reg_r,
            iob_reg,
            iob_counter,
            iob_asym_converter,
            iob_utils,
            (iob_ram_2p, {"purpose": "simulation"}),
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
                "name": "write",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Write interface",
                "ports": [
                    {
                        "name": "w_en",
                        "direction": "input",
                        "width": 1,
                        "descr": "Write enable",
                    },
                    {
                        "name": "w_data",
                        "direction": "input",
                        "width": "W_DATA_W",
                        "descr": "Write data",
                    },
                    {
                        "name": "w_full",
                        "direction": "output",
                        "width": 1,
                        "descr": "Write full signal",
                    },
                ],
            },
            {
                "name": "read",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "Read interface",
                "ports": [
                    {
                        "name": "r_en",
                        "direction": "input",
                        "width": 1,
                        "descr": "Read enable",
                    },
                    {
                        "name": "r_data",
                        "direction": "output",
                        "width": "R_DATA_W",
                        "descr": "Read data",
                    },
                    {
                        "name": "r_empty",
                        "direction": "output",
                        "width": 1,
                        "descr": "Read empty signal",
                    },
                ],
            },
            {
                "name": "extmem",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "External memory interface",
                "ports": [
                    {
                        "name": "ext_mem_clk",
                        "direction": "output",
                        "width": 1,
                        "descr": "Memory clock",
                    },
                    #  Write port
                    {
                        "name": "ext_mem_w_en",
                        "direction": "output",
                        "width": "R",
                        "descr": "Memory write enable",
                    },
                    {
                        "name": "ext_mem_w_addr",
                        "direction": "output",
                        "width": "MINADDR_W",
                        "descr": "Memory write address",
                    },
                    {
                        "name": "ext_mem_w_data",
                        "direction": "output",
                        "width": "MAXDATA_W",
                        "descr": "Memory write data",
                    },
                    #  Read port
                    {
                        "name": "ext_mem_r_en",
                        "direction": "output",
                        "width": "R",
                        "descr": "Memory read enable",
                    },
                    {
                        "name": "ext_mem_r_addr",
                        "direction": "output",
                        "width": "MINADDR_W",
                        "descr": "Memory read address",
                    },
                    {
                        "name": "ext_mem_r_data",
                        "direction": "input",
                        "width": "MAXDATA_W",
                        "descr": "Memory read data",
                    },
                ],
            },
            {
                "name": "fifo",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "FIFO interface",
                "ports": [
                    {
                        "name": "level",
                        "direction": "output",
                        "width": "ADDR_W+1",
                        "descr": "FIFO level",
                    },
                ],
            },
        ]


if __name__ == "__main__":
    iob_fifo_sync.setup_as_top_module()
