import os

from iob_module import iob_module

from iob_ctls import iob_ctls


class iob_regfile_2p(iob_module):
    name = "iob_regfile_2p"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_ctls,
                {"interface": "clk_en_rst_s_port"},
                {"interface": "clk_en_rst_s_s_portmap"},
            ]
        )
