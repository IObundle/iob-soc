import os

from iob_module import iob_module
from iob_bfifo import iob_bfifo
from iob_utils import iob_utils


class iob_unpack(iob_module):
    name = "iob_unpack"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "clk_en_rst_s_s_portmap"},
                {"interface": "clk_en_rst_s_port"},
                iob_bfifo,
                iob_utils,
            ]
        )
