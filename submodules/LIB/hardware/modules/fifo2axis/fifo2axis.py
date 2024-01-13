import os

from iob_module import iob_module
from iob_reg_re import iob_reg_re


class fifo2axis(iob_module):
    name = "fifo2axis"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_reg_re,
                {"interface": "clk_en_rst_s_port"},
                {"interface": "clk_en_rst_s_s_portmap"},
            ]
        )
