import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from iob_reg_e import iob_reg_e
from iob_utils import iob_utils


class iob_asym_converter(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob_asym_converter"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
            {"interface": "clk_en_rst_s_s_portmap"},
            {"interface": "clk_en_rst_s_port"},
            iob_reg_e,
            iob_utils,
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
                        "name": "w_addr",
                        "direction": "input",
                        "width": "W_ADDR_W",
                        "descr": "Write address",
                    },
                    {
                        "name": "w_data",
                        "direction": "input",
                        "width": "W_DATA_W",
                        "descr": "Write data",
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
                        "name": "r_addr",
                        "direction": "input",
                        "width": "R_ADDR_W",
                        "descr": "Read address",
                    },
                    {
                        "name": "r_data",
                        "direction": "output",
                        "width": "R_DATA_W",
                        "descr": "Read data",
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
        ]


if __name__ == "__main__":
    iob_asym_converter.setup_as_top_module()
