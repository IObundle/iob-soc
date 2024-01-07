import os

from iob_module import iob_module
from iob_counter import iob_counter
from iob_edge_detect import iob_edge_detect


class axis2fifo(iob_module):
    name = "axis2fifo"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_counter,
                iob_edge_detect,
                {"interface": "clk_en_rst_s_port"},
                {"interface": "clk_en_rst_s_s_portmap"},
            ]
        )
