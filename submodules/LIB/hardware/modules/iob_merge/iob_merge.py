import os

from iob_module import iob_module

from iob_reg_e import iob_reg_e
from iob_mux import iob_mux
from iob_demux import iob_demux


class iob_merge(iob_module):
    name = "iob_merge"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_reg_e,
                iob_mux,
                iob_demux,
                {"interface": "clk_en_rst_s_s_portmap"},
                {"interface": "clk_en_rst_s_port"},
            ]
        )
