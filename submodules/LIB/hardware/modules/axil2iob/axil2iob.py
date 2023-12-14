import os

from iob_module import iob_module

from iob_reg_e import iob_reg_e


class axil2iob(iob_module):
    name = "axil2iob"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "axil_s_port"},
                {"interface": "axil_s_s_portmap"},
                {"interface": "iob_m_port"},
                {"interface": "iob_m_portmap"},
                {"interface": "iob_wire"},
                {"interface": "clk_rst_s_s_portmap"},
                {"interface": "clk_rst_s_port"},
                {"interface": "iob_s_portmap"},
                iob_reg_e,
            ]
        )
