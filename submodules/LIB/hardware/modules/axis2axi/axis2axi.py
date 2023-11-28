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
                {"interface": "axi_m_port"},
                {"interface": "axi_m_write_port"},
                {"interface": "axi_m_read_port"},
                {"interface": "axi_m_m_write_portmap"},
                {"interface": "axi_m_m_read_portmap"},
                {"interface": "clk_en_rst_s_port"},
                iob_fifo_sync,
                iob_counter,
                iob_reg_r,
                iob_reg_re,
                (axi_ram, {"purpose": "simulation"}),
                (iob_ram_t2p, {"purpose": "simulation"}),
            ]
        )
