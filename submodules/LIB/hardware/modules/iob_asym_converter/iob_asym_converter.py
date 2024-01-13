import os

from iob_module import iob_module
from iob_reg_r import iob_reg_r
from iob_reg_re import iob_reg_re
from iob_utils import iob_utils


class iob_asym_converter(iob_module):
    name = "iob_asym_converter"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "clk_en_rst_s_s_portmap"},
                {"interface": "clk_en_rst_s_port"},
                iob_reg_r,
                iob_reg_re,
                iob_utils,
            ]
        )
