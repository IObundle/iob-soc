import os

from iob_module import iob_module


class iob2axil(iob_module):
    name = "iob2axil"
    version = "V0.10"
    setup_dir = os.path.dirname(__file__)

    @classmethod
    def _create_submodules_list(cls):
        """Create submodules list with dependencies of this module"""
        super()._create_submodules_list(
            [
                {"interface": "iob_s_port"},
                {"interface": "iob_s_s_portmap"},
                {"interface": "axil_m_port"},
                {"interface": "axil_m_portmap"},
                {"interface": "iob_m_tb_wire"},
                {"interface": "axil_wire"},
            ]
        )
