import os

# Find python modules
if __name__ == "__main__":
    import sys

    sys.path.append("./scripts")
from iob_module import iob_module

if __name__ == "__main__":
    iob_module.find_modules()

from m_axi_m_port import m_axi_m_port
from m_axi_write_m_port import m_axi_write_m_port
from m_axi_read_m_port import m_axi_read_m_port
from m_m_axi_write_portmap import m_m_axi_write_portmap
from m_m_axi_read_portmap import m_m_axi_read_portmap
from iob2axi_wr import iob2axi_wr
from iob2axi_rd import iob2axi_rd
from iob_fifo_sync import iob_fifo_sync


class iob2axi(iob_module):
    @classmethod
    def _init_attributes(cls):
        """Init module attributes"""
        cls.name = "iob2axi"
        cls.version = "V0.10"
        cls.flows = "sim"
        cls.setup_dir = os.path.dirname(__file__)
        cls.submodules = [
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


if __name__ == "__main__":
    iob2axi.setup_as_top_module()
