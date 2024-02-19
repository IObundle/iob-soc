import os

from iob_module import iob_module

from iob_fifo_sync import iob_fifo_sync
from iob_counter import iob_counter
from iob_reg_r import iob_reg_r
from iob_reg_re import iob_reg_re
from axi_ram import axi_ram
from iob_ram_t2p import iob_ram_t2p


class axis2axi(iob_module):
    name = "axis2axi"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {
                    "interface": "axi_write",
                    "file_prefix": "",
                    "wire_prefix": "",
                    "port_prefix": "",
                    "widths": {
                        "ID_W": "AXI_ID_W",
                        "ADDR_W": "AXI_ADDR_W",
                        "DATA_W": "AXI_DATA_W",
                        "LEN_W": "AXI_LEN_W",
                    },
                },
                {
                    "interface": "axi_read",
                    "file_prefix": "",
                    "wire_prefix": "",
                    "port_prefix": "",
                    "widths": {
                        "ID_W": "AXI_ID_W",
                        "ADDR_W": "AXI_ADDR_W",
                        "DATA_W": "AXI_DATA_W",
                        "LEN_W": "AXI_LEN_W",
                    },
                },
                iob_fifo_sync,
                iob_counter,
                iob_reg_r,
                iob_reg_re,
                (axi_ram, {"purpose": "simulation"}),
                (iob_ram_t2p, {"purpose": "simulation"}),
            ]
        )

    @classmethod
    def _setup_ios(cls):
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
                "name": "axi",
                "type": "master",
                "port_prefix": "",
                "wire_prefix": "",
                "descr": "AXI master interface",
                "ports": [],
                "widths": {
                    "ADDR_W": "ADDR_W",
                    "DATA_W": "DATA_W",
                },
            },
        ]
