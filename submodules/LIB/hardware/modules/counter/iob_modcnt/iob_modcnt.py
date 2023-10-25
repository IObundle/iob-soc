import os

from iob_module import iob_module

from iob_counter_ld import iob_counter_ld


class iob_modcnt(iob_module):
    name = "iob_modcnt"
    version = "V0.10"
    flows = "sim"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "clk_en_rst_s_port"},
                {"interface": "clk_en_rst_s_s_portmap"},
                iob_modcnt,
                iob_counter_ld,
            ]
        )
