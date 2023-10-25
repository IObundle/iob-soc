import os

from iob_module import iob_module

from iob_sync import iob_sync


class iob_s2f_sync(iob_module):
    name = "iob_s2f_sync"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                iob_sync,
                {"interface": "clk_rst_s_port"},
                {"interface": "clk_rst_s_s_portmap"},
            ]
        )
