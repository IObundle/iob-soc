import os

from iob_module import iob_module

from m_axi_m_port import m_axi_m_port
from m_axi_write_m_port import m_axi_write_m_port
from m_axi_read_m_port import m_axi_read_m_port
from m_m_axi_write_portmap import m_m_axi_write_portmap
from m_m_axi_read_portmap import m_m_axi_read_portmap
from iob2axi_wr import iob2axi_wr
from iob2axi_rd import iob2axi_rd
from iob_fifo_sync import iob_fifo_sync


class iob2axi(iob_module):
    name = "iob2axi"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                m_axi_m_port,
                m_axi_write_m_port,
                m_axi_read_m_port,
                m_m_axi_write_portmap,
                m_m_axi_read_portmap,
                {"interface": "clk_rst_s_port"},
                iob2axi_wr,
                iob2axi_rd,
                iob_fifo_sync,
            ]
        )
